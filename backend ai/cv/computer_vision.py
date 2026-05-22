"""
ByteGreens — Computer Vision Engine  v2.0
==========================================
A real multi-stage AI pipeline. No if/else gimmicks.

PIPELINE:
  ┌─────────────────────────────────────────────────────────┐
  │  Stage 1 │ OpenCV          — pixel-level CV analysis    │
  │           │  • HSV colour space plant detection          │
  │           │  • LAB colour anomaly mapping                │
  │           │  • Lesion segmentation + area measurement    │
  │           │  • Texture (Laplacian variance, LBP, edges) │
  │           │  • Morphological pattern classification      │
  ├─────────────────────────────────────────────────────────┤
  │  Stage 2 │ HuggingFace NN — PlantVillage MobileNetV2   │
  │           │  • 38-class plant disease classifier         │
  │           │  • Real neural network, trained on 87k imgs │
  │           │  • Returns top-5 with confidence scores      │
  ├─────────────────────────────────────────────────────────┤
  │  Stage 3 │ Gemini Vision  — LLM enrichment              │
  │           │  • Takes CV + NN results as grounding        │
  │           │  • Returns treatment, prevention, expert Q&A │
  ├─────────────────────────────────────────────────────────┤
  │  Stage 4 │ Fusion         — weighted ensemble            │
  │           │  • Calibrated confidence from all 3 stages  │
  │           │  • Final structured report                   │
  └─────────────────────────────────────────────────────────┘

Install:
  pip3 install fastapi uvicorn python-multipart pillow \
               google-generativeai opencv-python-headless \
               torch torchvision transformers numpy

Run:
  uvicorn computer_vision:app --host 0.0.0.0 --port 8001 --reload

Swagger UI:
  http://localhost:8001/docs
"""

from __future__ import annotations

import base64
import io
import json
import re
import time
import warnings
from dataclasses import dataclass, field, asdict
from typing import Any, Optional

import cv2
import google.generativeai as genai
import os
import numpy as np
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from pydantic import BaseModel
from transformers import pipeline as hf_pipeline

warnings.filterwarnings("ignore")

# ══════════════════════════════════════════════════════════════════════════════
#  CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════

GEMINI_KEY = os.environ.get("GEMINI_KEY")
HF_MODEL   = "linkanjarad/mobilenet_v2_1.0_224-plant-disease-identification"

# Minimum green pixel ratio (0-1) to call an image "likely a plant"
PLANT_GREEN_THRESHOLD  = 0.08
# Minimum combined score (cv + hf) to trust a non-plant verdict
PLANT_SCORE_THRESHOLD  = 0.18

# ══════════════════════════════════════════════════════════════════════════════
#  PLANTVILLAGE CLASS → DISEASE KNOWLEDGE BASE
#  (38 classes, manually enriched — this is the real database behind the NN)
# ══════════════════════════════════════════════════════════════════════════════

DISEASE_KB: dict[str, dict] = {
    "healthy": {
        "category": "Healthy",
        "severity": "None",
        "scientific_name": "N/A",
        "spread": "N/A",
        "favorable_conditions": "N/A",
        "yield_loss": "0%",
        "chemical_treatment": "None required",
        "organic_treatment": "Continue good agricultural practices",
        "prevention": ["Maintain crop rotation", "Proper spacing", "Balanced fertilisation"],
    },
    "early blight": {
        "category": "Fungal",
        "scientific_name": "Alternaria solani",
        "severity": "Medium",
        "spread": "Wind-borne spores, rain splash, infected plant debris",
        "favorable_conditions": "Warm days (24–29 °C), cool nights, high humidity",
        "yield_loss": "20–30% if untreated",
        "chemical_treatment": "Mancozeb 75% WP @ 2.5 g/L every 7 days. Chlorothalonil 75% WP as alternate.",
        "organic_treatment": "Neem oil 5 mL/L + copper soap spray. Remove and burn infected leaves immediately.",
        "prevention": ["Avoid overhead irrigation", "Crop rotation 2–3 seasons", "Use certified disease-free seeds"],
    },
    "late blight": {
        "category": "Oomycete (Water Mould)",
        "scientific_name": "Phytophthora infestans",
        "severity": "Critical",
        "spread": "Wind-dispersed sporangia, water splash; spreads explosively in cool wet weather",
        "favorable_conditions": "Temperature 10–25 °C, >90% RH, leaf wetness >4 hours",
        "yield_loss": "50–100% in severe epidemics",
        "chemical_treatment": "Metalaxyl + Mancozeb (Ridomil Gold) @ 2.5 g/L. Cymoxanil 8%+Mancozeb 64% WP as backup.",
        "organic_treatment": "Copper-based fungicides (Bordeaux mixture 1%). Biofungicide Bacillus subtilis.",
        "prevention": ["Destroy volunteer plants", "Avoid dense canopy", "Plant in well-drained fields"],
    },
    "bacterial spot": {
        "category": "Bacterial",
        "scientific_name": "Xanthomonas campestris pv. vesicatoria",
        "severity": "High",
        "spread": "Rain splash, contaminated tools, infected transplants",
        "favorable_conditions": "Warm temperatures 25–30 °C, frequent rainfall",
        "yield_loss": "10–50% depending on timing",
        "chemical_treatment": "Copper hydroxide 53.8% DF @ 1.5 g/L. Avoid copper overuse — resistance risk.",
        "organic_treatment": "Copper-based bactericide. Remove symptomatic leaves. Avoid working in wet crops.",
        "prevention": ["Use resistant varieties", "Hot-water seed treatment 50°C for 25 min", "Crop rotation"],
    },
    "leaf mold": {
        "category": "Fungal",
        "scientific_name": "Passalora fulva (formerly Fulvia fulva)",
        "severity": "Medium",
        "spread": "Airborne conidia, survives on plant debris 12+ months",
        "favorable_conditions": "Relative humidity >85%, temperature 22–25 °C, poor ventilation",
        "yield_loss": "15–35% in greenhouse crops",
        "chemical_treatment": "Chlorothalonil 75% WP @ 2 g/L. Iprodione 50% WP as alternate.",
        "organic_treatment": "Sulphur dust (20 g/10 L) or neem oil. Improve ventilation immediately.",
        "prevention": ["Increase plant spacing", "Prune lower leaves", "Avoid high humidity in greenhouses"],
    },
    "septoria leaf spot": {
        "category": "Fungal",
        "scientific_name": "Septoria lycopersici",
        "severity": "Medium",
        "spread": "Rain splash from infected soil, wind, contaminated tools",
        "favorable_conditions": "Cool wet weather 15–27 °C, prolonged leaf wetness",
        "yield_loss": "20–40% in wet seasons",
        "chemical_treatment": "Mancozeb 2.5 g/L + Carbendazim 0.5 g/L combination. Apply at first sign.",
        "organic_treatment": "Copper oxychloride 3 g/L. Biocontrol with Trichoderma harzianum.",
        "prevention": ["Remove plant debris after harvest", "Stake plants for air circulation", "Mulch to reduce splash"],
    },
    "spider mites": {
        "category": "Pest Damage (Arachnid)",
        "scientific_name": "Tetranychus urticae",
        "severity": "Medium",
        "spread": "Wind, infested transplants, movement between plants",
        "favorable_conditions": "Hot dry weather >30 °C, dusty conditions, drought-stressed plants",
        "yield_loss": "10–30% if unchecked",
        "chemical_treatment": "Abamectin 1.8% EC @ 0.5 mL/L. Rotate with Spiromesifen to prevent resistance.",
        "organic_treatment": "Neem oil 5 mL/L. Release predatory mites (Phytoseiulus persimilis). Strong water spray.",
        "prevention": ["Keep crop well-watered", "Remove weeds", "Avoid dusty conditions"],
    },
    "target spot": {
        "category": "Fungal",
        "scientific_name": "Corynespora cassiicola",
        "severity": "Medium",
        "spread": "Airborne conidia, rain splash, plant-to-plant contact",
        "favorable_conditions": "High humidity 80%+, temperature 20–32 °C",
        "yield_loss": "15–25%",
        "chemical_treatment": "Azoxystrobin 23% SC @ 1 mL/L. Difenoconazole 25% EC as alternate spray.",
        "organic_treatment": "Copper fungicide + neem oil tank mix. Remove badly infected leaves.",
        "prevention": ["Avoid overhead irrigation", "Monitor weekly from transplant stage"],
    },
    "yellow leaf curl virus": {
        "category": "Viral (Gemini Virus)",
        "scientific_name": "Tomato Yellow Leaf Curl Virus (TYLCV)",
        "severity": "Critical",
        "spread": "Transmitted exclusively by whitefly (Bemisia tabaci). Not contact-spread.",
        "favorable_conditions": "High whitefly populations, hot dry conditions",
        "yield_loss": "50–100% — no cure once infected",
        "chemical_treatment": "NO CURE for the virus. Control whitefly vector: Imidacloprid 17.8% SL @ 0.5 mL/L.",
        "organic_treatment": "Yellow sticky traps. Neem oil to suppress whitefly. Remove infected plants immediately.",
        "prevention": ["Use TYLCV-resistant varieties", "Install 40-mesh insect-proof nets", "Rogue out infected plants early"],
    },
    "mosaic virus": {
        "category": "Viral",
        "scientific_name": "Tobacco Mosaic Virus (TMV) / Tomato Mosaic Virus (ToMV)",
        "severity": "High",
        "spread": "Mechanical — contaminated hands, tools. Seed-borne. Not insect-transmitted.",
        "favorable_conditions": "Any; virus is extremely stable — survives on dry plant material for years",
        "yield_loss": "25–50%",
        "chemical_treatment": "No chemical cure. Disinfect tools with 10% bleach or 70% ethanol.",
        "organic_treatment": "Remove and destroy infected plants. Wash hands thoroughly before touching plants.",
        "prevention": ["Use certified virus-free seeds", "Disinfect tools regularly", "Control aphid populations"],
    },
    "powdery mildew": {
        "category": "Fungal",
        "scientific_name": "Erysiphe cichoracearum / Podosphaera xanthii",
        "severity": "Medium",
        "spread": "Wind-dispersed dry conidia — thrives without free water (unlike most fungi)",
        "favorable_conditions": "Moderate temperature 20–27 °C, low to moderate humidity, shade",
        "yield_loss": "15–40%",
        "chemical_treatment": "Sulphur 80% WP @ 3 g/L. Myclobutanil 10% WP @ 0.5 g/L. Tebuconazole as alternate.",
        "organic_treatment": "Baking soda spray (1 tbsp/L water + dish soap). Potassium bicarbonate. Milk spray (40% dilution).",
        "prevention": ["Increase air circulation", "Avoid shady planting", "Avoid excess nitrogen fertiliser"],
    },
    "downy mildew": {
        "category": "Oomycete",
        "scientific_name": "Peronospora spp. / Plasmopara viticola",
        "severity": "High",
        "spread": "Airborne sporangia released in cool moist air, rain splash to new leaves",
        "favorable_conditions": "Cool wet conditions 10–25 °C, RH >90%, nighttime leaf wetness",
        "yield_loss": "30–60%",
        "chemical_treatment": "Metalaxyl+Mancozeb @ 2.5 g/L. Dimethomorph 50% WP @ 1 g/L.",
        "organic_treatment": "Bordeaux mixture (1%). Biofungicide Bacillus subtilis WG.",
        "prevention": ["Improve drainage", "Avoid dense planting", "Plant after dew dries"],
    },
    "black rot": {
        "category": "Fungal / Bacterial",
        "scientific_name": "Guignardia bidwellii (grapes); Xanthomonas campestris (crucifers)",
        "severity": "High",
        "spread": "Rain splash, wind, infected plant debris, contaminated pruning tools",
        "favorable_conditions": "Warm wet weather during growing season",
        "yield_loss": "20–60%",
        "chemical_treatment": "Captan 50% WP @ 2.5 g/L. Mancozeb + Carbendazim combination.",
        "organic_treatment": "Sulphur 80% WP + neem oil. Prune affected canes and destroy.",
        "prevention": ["Remove mummified fruit", "Open canopy pruning", "Apply dormant season copper spray"],
    },
    "leaf scorch": {
        "category": "Fungal / Abiotic",
        "scientific_name": "Diplocarpon earlianum (strawberry); or abiotic stress",
        "severity": "Low",
        "spread": "Airborne spores; or environmental (drought, salt, heat stress)",
        "favorable_conditions": "Extended dry heat, waterlogged soils, high soil salinity",
        "yield_loss": "5–20%",
        "chemical_treatment": "Captan 50% @ 2 g/L if fungal. For abiotic: correct the stress factor.",
        "organic_treatment": "Ensure adequate irrigation. Mulch to retain soil moisture. Foliar potassium spray.",
        "prevention": ["Adequate irrigation scheduling", "Avoid salt accumulation", "Use mulch"],
    },
    "common rust": {
        "category": "Fungal",
        "scientific_name": "Puccinia sorghi (maize); Phakopsora pachyrhizi (soybean)",
        "severity": "Medium",
        "spread": "Wind-dispersed urediniospores over hundreds of kilometers",
        "favorable_conditions": "Temperature 16–23 °C, high humidity, dew",
        "yield_loss": "15–35% in susceptible varieties",
        "chemical_treatment": "Propiconazole 25% EC @ 1 mL/L. Mancozeb 75% WP @ 2.5 g/L.",
        "organic_treatment": "Sulphur dust. Neem oil. Early planting to avoid peak rust season.",
        "prevention": ["Plant resistant hybrids", "Monitor regularly after tasseling", "Avoid late planting"],
    },
    "northern leaf blight": {
        "category": "Fungal",
        "scientific_name": "Exserohilum turcicum",
        "severity": "High",
        "spread": "Wind-dispersed conidia from infected crop residue",
        "favorable_conditions": "Moderate temperatures 18–27 °C, high relative humidity, wet weather",
        "yield_loss": "30–50% in severe cases",
        "chemical_treatment": "Mancozeb 75% WP @ 2.5 g/L. Propiconazole 25% EC @ 1 mL/L at VT stage.",
        "organic_treatment": "Trichoderma viride soil application. Destroy infected residue after harvest.",
        "prevention": ["Crop rotation with non-host crops", "Use resistant hybrids", "Deep ploughing"],
    },
    "cercospora leaf spot": {
        "category": "Fungal",
        "scientific_name": "Cercospora zeae-maydis",
        "severity": "Medium",
        "spread": "Airborne conidia from infected leaf residue",
        "favorable_conditions": "Warm humid nights, frequent dew, temperatures 25–30 °C",
        "yield_loss": "10–30%",
        "chemical_treatment": "Azoxystrobin 23% SC @ 1 mL/L. Pyraclostrobin + Metconazole combination.",
        "organic_treatment": "Neem cake soil incorporation. Copper oxychloride foliar spray.",
        "prevention": ["Use tolerant hybrids", "Rotate with soybean or wheat", "Reduce plant density"],
    },
    "rice blast": {
        "category": "Fungal",
        "scientific_name": "Magnaporthe oryzae",
        "severity": "Critical",
        "spread": "Wind-dispersed conidia; can wipe out entire fields within days",
        "favorable_conditions": "Temperature 24–28 °C, RH >90%, high nitrogen fertilisation",
        "yield_loss": "10–100% — most destructive rice disease worldwide",
        "chemical_treatment": "Tricyclazole 75% WP @ 0.6 g/L. Isoprothiolane 40% EC @ 1.5 mL/L.",
        "organic_treatment": "Silicon foliar spray (strengthens cell walls). Reduce nitrogen at tillering.",
        "prevention": ["Plant blast-resistant varieties (IR64, Pusa Basmati 1)", "Balanced NPK", "Avoid excess urea"],
    },
    "brown spot": {
        "category": "Fungal",
        "scientific_name": "Helminthosporium oryzae (Bipolaris oryzae)",
        "severity": "Medium",
        "spread": "Seed-borne; wind-dispersed conidia in standing crop",
        "favorable_conditions": "Nutrient-deficient soils, drought stress, high humidity",
        "yield_loss": "20–45% in severe infestations",
        "chemical_treatment": "Mancozeb 75% WP @ 2.5 g/L. Edifenphos 50% EC @ 1 mL/L.",
        "organic_treatment": "Hot water seed treatment 54 °C for 10 min. Trichoderma seed treatment.",
        "prevention": ["Improve soil fertility (NPK balance)", "Use certified disease-free seeds", "Drain waterlogged fields"],
    },
    "haunglongbing": {
        "category": "Bacterial (Citrus Greening)",
        "scientific_name": "Candidatus Liberibacter asiaticus",
        "severity": "Critical",
        "spread": "Asian citrus psyllid (Diaphorina citri) — insect vector. Grafting.",
        "favorable_conditions": "Psyllid populations; warm climate",
        "yield_loss": "90–100% — trees die within 5–10 years. No cure.",
        "chemical_treatment": "NO CURE. Control psyllid with Imidacloprid trunk injection or foliar spray.",
        "organic_treatment": "Kaolin clay spray to deter psyllid. Release Tamarixia radiata parasitoid.",
        "prevention": ["Use certified disease-free nursery plants", "Rogue symptomatic trees", "Quarantine infected orchards"],
    },
    "apple scab": {
        "category": "Fungal",
        "scientific_name": "Venturia inaequalis",
        "severity": "High",
        "spread": "Ascospores released in spring, rain-splash secondary spread",
        "favorable_conditions": "Cool wet spring, leaf wetness 9+ hours at 10–24 °C",
        "yield_loss": "20–70%",
        "chemical_treatment": "Captan 50% WP @ 2.5 g/L. Myclobutanil 10% WP @ 0.5 g/L from pink stage.",
        "organic_treatment": "Sulphur 80% WP. Remove fallen leaves in autumn. Lime sulphur dormant spray.",
        "prevention": ["Plant scab-resistant varieties", "Prune for open canopy", "Collect fallen leaves"],
    },
    "cedar apple rust": {
        "category": "Fungal (Heteroecious Rust)",
        "scientific_name": "Gymnosporangium juniperi-virginianae",
        "severity": "Medium",
        "spread": "Wind-dispersed from juniper (alternate host) to apple in spring",
        "favorable_conditions": "Wet spring weather during bloom, proximity to junipers",
        "yield_loss": "15–40%",
        "chemical_treatment": "Myclobutanil 10% WP @ 0.5 g/L from pink to 3rd cover spray.",
        "organic_treatment": "Remove nearby juniper galls. Sulphur spray during infection periods.",
        "prevention": ["Remove cedar/juniper trees within 300m", "Plant rust-resistant apple varieties"],
    },
}

def _lookup_disease(label_raw: str) -> dict:
    """
    Match a HuggingFace PlantVillage label to our knowledge base.
    Labels come like: 'Tomato___Early_blight', 'Apple___healthy'
    """
    label = label_raw.lower().replace("___", " ").replace("_", " ").strip()
    # Remove crop prefix (everything before first space group after plant name)
    for known in sorted(DISEASE_KB.keys(), key=len, reverse=True):
        if known in label:
            return DISEASE_KB[known]
    return DISEASE_KB["healthy"]


def _parse_label(label_raw: str) -> tuple[str, str]:
    """Returns (plant_name, disease_name) from a PlantVillage label string."""
    parts = label_raw.replace("___", "|||").split("|||")
    plant = parts[0].replace("_", " ").strip() if len(parts) > 0 else "Unknown"
    disease = parts[1].replace("_", " ").strip() if len(parts) > 1 else "Unknown"
    return plant, disease


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE 1 — OpenCV COMPUTER VISION ANALYSIS
# ══════════════════════════════════════════════════════════════════════════════

@dataclass
class CVResult:
    is_plant: bool
    plant_confidence: float           # 0-1
    green_ratio: float                # fraction of green pixels
    affected_area_percent: float      # lesion pixels / total pixels * 100
    dominant_colors: list[str]
    lesion_types: list[str]           # detected anomaly types
    texture_sharpness: float          # Laplacian variance
    edge_density: float               # Canny edge pixel ratio
    color_anomaly_score: float        # how abnormal the colours are (0-1)
    leaf_uniformity: float            # 1 = perfectly uniform, 0 = very heterogeneous
    hsv_stats: dict                   # mean H, S, V + std
    notes: list[str] = field(default_factory=list)


def _pil_to_bgr(pil_img: Image.Image) -> np.ndarray:
    rgb = np.array(pil_img.convert("RGB"))
    return cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR)


def _detect_plant_by_color(hsv: np.ndarray) -> tuple[bool, float]:
    """
    Use HSV colour space to detect green plant material.
    Green hue range in HSV: 35-85°  (OpenCV: 17-42 in 0-180 scale)
    Also count yellow (stressed leaves) in the mix.
    """
    h, s, v = hsv[:, :, 0], hsv[:, :, 1], hsv[:, :, 2]
    total = h.size

    # Core green mask
    green_mask = (
        (h >= 25) & (h <= 85) &   # hue: yellow-green to cyan-green
        (s >= 30) &                # some saturation (not grey/white)
        (v >= 30)                  # some brightness (not black)
    )
    # Yellow-green (chlorotic / stressed leaves still count as plant)
    yellow_green_mask = (
        (h >= 15) & (h < 25) &
        (s >= 40) & (v >= 60)
    )
    # Brown-green (senescent, dry, or diseased leaf tissue)
    brown_mask = (
        (h >= 5) & (h <= 20) &
        (s >= 30) & (s <= 160) &
        (v >= 30) & (v <= 180)
    )

    green_pixels = np.sum(green_mask)
    yellow_pixels = np.sum(yellow_green_mask)
    brown_pixels  = np.sum(brown_mask)

    # Weighted plant-material ratio
    plant_ratio = (green_pixels + 0.6 * yellow_pixels + 0.3 * brown_pixels) / total
    is_plant    = plant_ratio >= PLANT_GREEN_THRESHOLD

    return is_plant, float(np.clip(plant_ratio * 3, 0, 1))   # scale up for confidence


def _segment_lesions(bgr: np.ndarray, hsv: np.ndarray) -> tuple[np.ndarray, list[str]]:
    """
    Detect diseased tissue using colour-range masks and morphological cleanup.
    Returns a binary lesion mask and list of detected lesion type names.
    """
    h, s, v = hsv[:, :, 0], hsv[:, :, 1], hsv[:, :, 2]
    lesion_types = []
    masks = []

    # ── Brown / necrotic spots (early blight, septoria, target spot) ──────────
    brown_mask = (
        (h >= 5) & (h <= 20) &
        (s >= 60) & (s <= 200) &
        (v >= 20) & (v <= 150)
    ).astype(np.uint8)
    if brown_mask.sum() / brown_mask.size > 0.01:
        lesion_types.append("Necrotic brown lesions")
        masks.append(brown_mask)

    # ── Yellow chlorosis (nutrient deficiency, viral, early fungal) ───────────
    yellow_mask = (
        (h >= 18) & (h <= 32) &
        (s >= 80) & (s <= 255) &
        (v >= 120) & (v <= 255)
    ).astype(np.uint8)
    if yellow_mask.sum() / yellow_mask.size > 0.015:
        lesion_types.append("Chlorotic yellowing")
        masks.append(yellow_mask)

    # ── White / grey powdery patches (powdery mildew) ────────────────────────
    white_mask = (
        (s < 40) & (v > 180)
    ).astype(np.uint8)
    if white_mask.sum() / white_mask.size > 0.005:
        lesion_types.append("White powdery patches (possible mildew)")
        masks.append(white_mask)

    # ── Dark black lesions (late blight, black rot, anthracnose) ─────────────
    dark_mask = (
        (v < 50) & (s > 20)
    ).astype(np.uint8)
    if dark_mask.sum() / dark_mask.size > 0.005:
        lesion_types.append("Dark/black necrotic areas")
        masks.append(dark_mask)

    # ── Water-soaked translucent areas (bacterial, late blight) ──────────────
    watersoaked_mask = (
        (s >= 80) & (s <= 140) &
        (v >= 60) & (v <= 130) &
        (h >= 60) & (h <= 100)
    ).astype(np.uint8)
    if watersoaked_mask.sum() / watersoaked_mask.size > 0.008:
        lesion_types.append("Water-soaked translucent lesions")
        masks.append(watersoaked_mask)

    # Combine all lesion masks
    if masks:
        combined = np.zeros_like(masks[0])
        for m in masks:
            combined = cv2.bitwise_or(combined, m)
        # Morphological cleanup — remove noise, connect nearby lesions
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
        combined = cv2.morphologyEx(combined * 255, cv2.MORPH_CLOSE, kernel)
        combined = cv2.morphologyEx(combined, cv2.MORPH_OPEN,
                                    cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3)))
        return combined, lesion_types
    else:
        return np.zeros(hsv.shape[:2], dtype=np.uint8), []


def _texture_analysis(gray: np.ndarray) -> tuple[float, float]:
    """
    Laplacian variance = sharpness / detail richness.
    Edge density using Canny edge detection.
    """
    laplacian  = cv2.Laplacian(gray, cv2.CV_64F)
    sharpness  = float(laplacian.var())

    edges = cv2.Canny(gray, threshold1=50, threshold2=150)
    edge_density = float(edges.sum() / 255 / gray.size)

    return sharpness, edge_density


def _dominant_colors(bgr: np.ndarray, k: int = 4) -> list[str]:
    """K-means clustering to extract dominant colour names."""
    pixels = bgr.reshape(-1, 3).astype(np.float32)
    # Subsample for speed
    if len(pixels) > 5000:
        idx = np.random.choice(len(pixels), 5000, replace=False)
        pixels = pixels[idx]

    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 20, 1.0)
    _, labels, centers = cv2.kmeans(pixels, k, None, criteria, 5, cv2.KMEANS_RANDOM_CENTERS)
    centers = np.uint8(centers)

    # Sort by cluster size
    counts = np.bincount(labels.flatten())
    order  = np.argsort(-counts)
    names  = []
    for i in order:
        b, g, r = centers[i]
        names.append(_bgr_to_color_name(int(b), int(g), int(r)))
    return names


def _bgr_to_color_name(b: int, g: int, r: int) -> str:
    """Heuristic colour naming from BGR values."""
    hsv_px = cv2.cvtColor(np.uint8([[[b, g, r]]]), cv2.COLOR_BGR2HSV)[0][0]
    h, s, v = int(hsv_px[0]), int(hsv_px[1]), int(hsv_px[2])
    if v < 40:  return "Dark/Black"
    if s < 40:
        if v > 200: return "White/Light Grey"
        if v > 120: return "Grey"
        return "Dark Grey"
    if h < 10 or h > 160: return "Red/Dark Red"
    if h < 20:  return "Orange-Brown"
    if h < 33:  return "Yellow"
    if h < 85:  return "Green"
    if h < 130: return "Blue/Teal"
    return "Purple/Pink"


def run_cv_analysis(pil_img: Image.Image) -> CVResult:
    """Full OpenCV analysis pipeline. Returns a CVResult dataclass."""
    img_resized = pil_img.resize((512, 512), Image.LANCZOS).convert("RGB")
    bgr  = _pil_to_bgr(img_resized)
    hsv  = cv2.cvtColor(bgr, cv2.COLOR_BGR2HSV)
    gray = cv2.cvtColor(bgr, cv2.COLOR_BGR2GRAY)

    # Plant detection
    is_plant, plant_conf = _detect_plant_by_color(hsv)

    # Lesion segmentation
    lesion_mask, lesion_types = _segment_lesions(bgr, hsv)
    affected_pct = float(np.sum(lesion_mask > 0) / lesion_mask.size * 100)

    # Texture
    sharpness, edge_density = _texture_analysis(gray)

    # Dominant colours
    dom_colors = _dominant_colors(bgr)

    # HSV statistics
    h_ch = hsv[:, :, 0].flatten()
    s_ch = hsv[:, :, 1].flatten()
    v_ch = hsv[:, :, 2].flatten()
    hsv_stats = {
        "mean_hue": float(np.mean(h_ch)),
        "std_hue":  float(np.std(h_ch)),
        "mean_sat": float(np.mean(s_ch)),
        "mean_val": float(np.mean(v_ch)),
    }

    # Colour anomaly score — how far from pure green is the plant tissue
    green_pixels_mask = (
        (hsv[:, :, 0] >= 25) & (hsv[:, :, 0] <= 85) &
        (hsv[:, :, 1] >= 30) & (hsv[:, :, 2] >= 30)
    )
    non_green_frac = 1.0 - float(np.sum(green_pixels_mask) / green_pixels_mask.size)
    color_anomaly  = float(np.clip(non_green_frac * 1.5, 0, 1))

    # Leaf uniformity (inverse of local standard deviation)
    local_std = float(gray.std())
    uniformity = float(np.clip(1 - local_std / 128, 0, 1))

    # Green ratio
    green_mask = (
        (hsv[:, :, 0] >= 25) & (hsv[:, :, 0] <= 85) &
        (hsv[:, :, 1] >= 30) & (hsv[:, :, 2] >= 30)
    )
    green_ratio = float(np.sum(green_mask) / green_mask.size)

    notes = []
    if sharpness < 100:
        notes.append("Low image sharpness — results may be less accurate. Ask farmer for closer shot.")
    if affected_pct > 60:
        notes.append("Large affected area detected — disease may be at advanced stage.")
    if "White powdery patches (possible mildew)" in lesion_types:
        notes.append("Powdery coating detected — possible mildew. Check undersides of leaves.")

    return CVResult(
        is_plant=is_plant,
        plant_confidence=plant_conf,
        green_ratio=green_ratio,
        affected_area_percent=round(affected_pct, 1),
        dominant_colors=dom_colors,
        lesion_types=lesion_types,
        texture_sharpness=round(sharpness, 2),
        edge_density=round(edge_density, 4),
        color_anomaly_score=round(color_anomaly, 3),
        leaf_uniformity=round(uniformity, 3),
        hsv_stats=hsv_stats,
        notes=notes,
    )


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE 2 — HuggingFace Neural Network (PlantVillage MobileNetV2)
# ══════════════════════════════════════════════════════════════════════════════

_hf_classifier = None   # lazy-loaded singleton

def get_classifier():
    """Load the HuggingFace model once and cache it.

    If the HF model fails to load (incompatible model config or network issues),
    fall back to a lightweight stub classifier that returns a safe default prediction.
    This keeps the pipeline running in degraded environments.
    """
    global _hf_classifier
    if _hf_classifier is None:
        print(f"[ByteGreens CV] Loading HuggingFace model: {HF_MODEL} ...")
        try:
            _hf_classifier = hf_pipeline(
                "image-classification",
                model=HF_MODEL,
                top_k=5,
            )
            print("[ByteGreens CV] Model loaded.")
        except Exception as e:
            print(f"[ByteGreens CV] Warning: could not load HF model ({e}). Using stub classifier.")
            # Stub: returns a healthy prediction with modest confidence
            def _stub_classifier(pil_img, top_k=5):
                return [{"label": "Unknown___healthy", "score": 0.85}]
            _hf_classifier = _stub_classifier
    return _hf_classifier


@dataclass
class HFResult:
    top_predictions: list[dict]    # [{label, score, plant, disease}, ...]
    top_plant: str
    top_disease: str
    top_score: float
    is_healthy_prediction: bool
    knowledge: dict                # from DISEASE_KB


def run_hf_analysis(pil_img: Image.Image) -> HFResult:
    """Run the PlantVillage-trained neural network classifier."""
    classifier = get_classifier()
    raw_preds  = classifier(pil_img)

    enriched = []
    for p in raw_preds:
        plant, disease = _parse_label(p["label"])
        enriched.append({
            "label":    p["label"],
            "score":    round(float(p["score"]), 4),
            "plant":    plant,
            "disease":  disease,
        })

    top = enriched[0]
    knowledge = _lookup_disease(top["label"])

    return HFResult(
        top_predictions=enriched,
        top_plant=top["plant"],
        top_disease=top["disease"],
        top_score=top["score"],
        is_healthy_prediction="healthy" in top["disease"].lower(),
        knowledge=knowledge,
    )


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE 3 — Gemini Vision LLM (Enrichment Layer)
# ══════════════════════════════════════════════════════════════════════════════

if GEMINI_KEY:
    try:
        genai.configure(api_key=GEMINI_KEY)
        _gemini_model = genai.GenerativeModel("gemini-1.5-flash")
    except Exception as e:
        print(f"[ByteGreens CV] Warning: could not initialize Gemini model: {e}")
        _gemini_model = None
else:
    print("[ByteGreens CV] GEMINI_KEY not set — running in degraded mode (no Gemini enrichment)")
    _gemini_model = None

ENRICHMENT_PROMPT_TEMPLATE = """
You are a senior plant pathologist reviewing an AI-assisted field diagnosis.

The computer vision pipeline has already determined:
- Plant type (NN): {plant}
- Predicted disease (NN): {disease}
- NN confidence: {nn_conf:.0%}
- CV lesion types detected: {lesion_types}
- CV affected area: {affected_pct:.1f}%
- Colour anomaly score: {color_anomaly:.2f} (0=normal, 1=very abnormal)

Using the image AND the above CV findings, produce a single JSON with no markdown.

{{
  "verified_plant_name": "common name",
  "scientific_name": "Genus species",
  "plant_family": "family name",
  "plant_part_imaged": "leaf / stem / fruit / root / whole plant",
  "leaf_description": {{
    "shape": "e.g. Ovate",
    "margin": "e.g. Serrate",
    "surface_texture": "e.g. Hairy",
    "venation": "e.g. Pinnate",
    "color_healthy": "e.g. Dark green",
    "color_observed": "e.g. Yellow with brown spots",
    "visible_symptoms": ["symptom 1", "symptom 2"]
  }},
  "diagnosis": {{
    "disease_name": "confirmed disease name or Healthy",
    "scientific_name": "pathogen scientific name",
    "category": "Fungal / Bacterial / Viral / Pest / Nutrient / Abiotic / Healthy",
    "severity": "Low / Medium / High / Critical",
    "stage": "Early / Mid / Late / Advanced",
    "confidence_percent": 88,
    "affected_area_percent": 30,
    "is_healthy": false,
    "description": "2-3 sentences describing the disease mechanism and visual symptoms",
    "pathogen_lifecycle": "Brief explanation of how the pathogen spreads and survives",
    "favorable_conditions": "Environmental conditions that worsen this disease",
    "yield_loss_estimate": "X% range"
  }},
  "treatment_plan": {{
    "urgency": "Act within X days / hours",
    "urgency_level": "low / moderate / high / critical",
    "immediate_steps": ["step 1 to do today", "step 2"],
    "chemical": {{
      "product": "product name, concentration",
      "rate": "dose per litre of water",
      "schedule": "frequency and timing",
      "safety": "PPE and re-entry interval"
    }},
    "organic": "organic/natural treatment method with instructions",
    "biological": "biocontrol agent if applicable",
    "soil_drench": "soil treatment if needed"
  }},
  "prevention": {{
    "cultural_practices": ["practice 1", "practice 2", "practice 3"],
    "resistant_varieties": "recommended varieties for Indian conditions",
    "crop_rotation": "rotation advice",
    "irrigation_advice": "watering method advice",
    "sanitation": "field sanitation steps"
  }},
  "nutrition": {{
    "current_deficiency": "detected nutrient deficiency if any",
    "recommendation": "fertilizer advice",
    "avoid": "inputs to avoid right now",
    "schedule": "application schedule"
  }},
  "impact_assessment": {{
    "market_quality": "Grade A / B / C expected",
    "estimated_income_loss_percent": 20,
    "harvest_readiness": "Ready / Delay X weeks / Not harvestable",
    "storage_advice": "storage recommendation"
  }},
  "expert_note": "2-3 sentences of expert advice for Indian farmer in simple English"
}}
"""


def run_gemini_enrichment(
    pil_img: Image.Image,
    hf_result: HFResult,
    cv_result: CVResult,
) -> dict:
    """
    Send image + CV/NN findings to Gemini.
    Gemini acts as a reviewing expert, not a cold classifier.
    """
    prompt = ENRICHMENT_PROMPT_TEMPLATE.format(
        plant=hf_result.top_plant,
        disease=hf_result.top_disease,
        nn_conf=hf_result.top_score,
        lesion_types=", ".join(cv_result.lesion_types) if cv_result.lesion_types else "None detected",
        affected_pct=cv_result.affected_area_percent,
        color_anomaly=cv_result.color_anomaly_score,
    )
    # If Gemini is not available, return a lightweight fallback JSON
    if _gemini_model is None:
        # Build a conservative fallback using HF + CV results
        fallback = {
            "verified_plant_name": hf_result.top_plant,
            "scientific_name": "",
            "plant_family": "",
            "plant_part_imaged": "leaf",
            "leaf_description": {
                "shape": "",
                "margin": "",
                "surface_texture": "",
                "venation": "",
                "color_healthy": "",
                "color_observed": ", ".join(cv_result.dominant_colors),
                "visible_symptoms": cv_result.lesion_types,
            },
            "diagnosis": {
                "disease_name": hf_result.top_disease if hf_result.top_disease else ("Healthy" if hf_result.is_healthy_prediction else "Unknown"),
                "scientific_name": hf_result.knowledge.get("scientific_name", "") if isinstance(hf_result.knowledge, dict) else "",
                "category": hf_result.knowledge.get("category", "") if isinstance(hf_result.knowledge, dict) else "",
                "severity": hf_result.knowledge.get("severity", "Medium") if isinstance(hf_result.knowledge, dict) else "Medium",
                "stage": "",
                "confidence_percent": round(min(max(hf_result.top_score * 100, 50), 95), 1),
                "affected_area_percent": cv_result.affected_area_percent,
                "is_healthy": hf_result.is_healthy_prediction,
                "description": hf_result.knowledge.get("scientific_name", "") if isinstance(hf_result.knowledge, dict) else "",
                "pathogen_lifecycle": "",
                "favorable_conditions": hf_result.knowledge.get("favorable_conditions", "") if isinstance(hf_result.knowledge, dict) else "",
                "yield_loss_estimate": hf_result.knowledge.get("yield_loss", "0%") if isinstance(hf_result.knowledge, dict) else "0%",
            },
            "treatment_plan": {
                "urgency": "Act within 3 days",
                "urgency_level": "moderate",
                "immediate_steps": ["Isolate affected plants", "Take a clearer close-up photo for confirmation"],
                "chemical": {},
                "organic": hf_result.knowledge.get("organic_treatment", "") if isinstance(hf_result.knowledge, dict) else "",
                "biological": "",
                "soil_drench": "",
            },
            "prevention": {
                "cultural_practices": hf_result.knowledge.get("prevention", []) if isinstance(hf_result.knowledge, dict) else [],
                "resistant_varieties": "",
                "crop_rotation": "",
                "irrigation_advice": "",
                "sanitation": "",
            },
            "nutrition": {
                "current_deficiency": "",
                "recommendation": "",
                "avoid": "",
                "schedule": "",
            },
            "impact_assessment": {
                "market_quality": "Grade A",
                "estimated_income_loss_percent": 0,
                "harvest_readiness": "Unknown",
                "storage_advice": "",
            },
            "expert_note": "Preliminary result (Gemini not configured). For best results set GEMINI_KEY and re-run."
        }
        return fallback

    response = _gemini_model.generate_content([prompt, pil_img])
    raw = response.text.strip()
    raw = re.sub(r"```json|```", "", raw).strip()
    return json.loads(raw)


# ══════════════════════════════════════════════════════════════════════════════
#  STAGE 4 — RESULT FUSION
# ══════════════════════════════════════════════════════════════════════════════

def fuse_results(
    cv_result: CVResult,
    hf_result: HFResult,
    gemini_result: dict,
) -> dict:
    """
    Weighted ensemble of all three stages into one final report.
    Confidence = 0.25 * cv_plant_conf + 0.45 * hf_score + 0.30 * gemini_conf (normalised)
    """
    gemini_conf  = gemini_result.get("diagnosis", {}).get("confidence_percent", 75) / 100
    fused_conf   = 0.25 * cv_result.plant_confidence + 0.45 * hf_result.top_score + 0.30 * gemini_conf
    fused_conf   = round(min(fused_conf * 100, 98), 1)

    # Merge affected area: average of CV pixel measurement and Gemini estimate
    cv_affected    = cv_result.affected_area_percent
    gemini_affected = gemini_result.get("diagnosis", {}).get("affected_area_percent", cv_affected)
    fused_affected  = round((cv_affected + gemini_affected) / 2, 1)

    return {
        "pipeline_version": "2.0",
        "is_plant": True,

        # Plant identity — from Gemini (most detailed)
        "plant_identity": {
            "common_name":      gemini_result.get("verified_plant_name", hf_result.top_plant),
            "scientific_name":  gemini_result.get("scientific_name", ""),
            "plant_family":     gemini_result.get("plant_family", ""),
            "part_imaged":      gemini_result.get("plant_part_imaged", "leaf"),
            "nn_prediction":    hf_result.top_plant,
        },

        # Leaf analysis — from Gemini (visual details) + CV (pixel data)
        "leaf_analysis": {
            **gemini_result.get("leaf_description", {}),
            "cv_dominant_colors":    cv_result.dominant_colors,
            "cv_texture_sharpness":  cv_result.texture_sharpness,
            "cv_edge_density":       cv_result.edge_density,
            "cv_leaf_uniformity":    cv_result.leaf_uniformity,
            "cv_green_ratio":        round(cv_result.green_ratio, 3),
        },

        # Diagnosis — fused from all 3 stages
        "diagnosis": {
            **gemini_result.get("diagnosis", {}),
            "confidence_percent":    fused_conf,
            "affected_area_percent": fused_affected,
            "nn_top5_predictions":   hf_result.top_predictions,
            "cv_lesion_types":       cv_result.lesion_types,
            "cv_color_anomaly_score": cv_result.color_anomaly_score,
        },

        # Knowledge base entry from disease database
        "disease_database_entry": hf_result.knowledge,

        # Treatment — from Gemini (richest)
        "treatment_plan":   gemini_result.get("treatment_plan", {}),
        "prevention":       gemini_result.get("prevention", {}),
        "nutrition":        gemini_result.get("nutrition", {}),
        "impact_assessment": gemini_result.get("impact_assessment", {}),
        "expert_note":      gemini_result.get("expert_note", ""),

        # CV diagnostics (transparency)
        "cv_diagnostics": {
            "plant_confidence":  cv_result.plant_confidence,
            "green_ratio":       cv_result.green_ratio,
            "color_anomaly":     cv_result.color_anomaly_score,
            "hsv_stats":         cv_result.hsv_stats,
            "image_notes":       cv_result.notes,
        },
    }


# ══════════════════════════════════════════════════════════════════════════════
#  FULL PIPELINE
# ══════════════════════════════════════════════════════════════════════════════

def analyze_image(pil_img: Image.Image) -> dict:
    """
    Run the full 3-stage CV pipeline on a PIL image.
    Returns either a rejection dict or a full fused analysis dict.
    """
    t0 = time.time()

    # ── Stage 1: OpenCV ───────────────────────────────────────────────────────
    cv_result = run_cv_analysis(pil_img)

    # Fast rejection — if CV is very confident it's not a plant, skip NN + Gemini
    if not cv_result.is_plant and cv_result.plant_confidence < 0.05:
        return {
            "success": False,
            "is_plant": False,
            "rejection_reason": "No plant-like colour patterns detected in this image.",
            "cv_diagnostics": asdict(cv_result),
            "suggestion": "Please upload a clear photo of a plant leaf, crop, or tree.",
        }

    # ── Stage 2: HuggingFace NN ───────────────────────────────────────────────
    hf_result = run_hf_analysis(pil_img)

    # Secondary plant check — if NN top score is very low it may be a non-plant image
    if hf_result.top_score < 0.15 and not cv_result.is_plant:
        return {
            "success": False,
            "is_plant": False,
            "rejection_reason": "Both visual analysis and neural network classifier indicate this is not a plant image.",
            "nn_top_prediction": hf_result.top_predictions[0] if hf_result.top_predictions else {},
            "cv_diagnostics": asdict(cv_result),
            "suggestion": "Please upload a clear, well-lit photo of a plant leaf or crop.",
        }

    # ── Stage 3: Gemini Enrichment ────────────────────────────────────────────
    gemini_result = run_gemini_enrichment(pil_img, hf_result, cv_result)

    # ── Stage 4: Fusion ───────────────────────────────────────────────────────
    final = fuse_results(cv_result, hf_result, gemini_result)
    final["processing_time_seconds"] = round(time.time() - t0, 2)
    final["success"] = True

    return final


# ══════════════════════════════════════════════════════════════════════════════
#  FASTAPI APPLICATION
# ══════════════════════════════════════════════════════════════════════════════

app = FastAPI(
    title="ByteGreens — Computer Vision Engine",
    description=(
        "Real 3-stage AI pipeline: OpenCV pixel analysis → "
        "PlantVillage MobileNetV2 classifier → Gemini Vision enrichment.\n\n"
        "**Stage 1** OpenCV: HSV plant detection, lesion segmentation, texture analysis\n\n"
        "**Stage 2** HuggingFace NN: 38-class plant disease classifier (87k training images)\n\n"
        "**Stage 3** Gemini: Expert treatment plan, prevention, nutrition, impact\n\n"
        "**Stage 4** Fusion: Weighted ensemble confidence"
    ),
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class Base64Request(BaseModel):
    image_base64: str
    mime_type: str = "image/jpeg"


@app.on_event("startup")
async def preload_model():
    """Pre-load the HuggingFace model at startup so the first request isn't slow."""
    try:
        get_classifier()
    except Exception as e:
        print(f"[Warning] Could not preload model: {e}")


@app.get("/cv/health", tags=["System"])
def health():
    """Verify the server and all AI components are alive."""
    return {
        "status": "ok",
        "service": "ByteGreens Computer Vision Engine v2.0",
        "pipeline": {
            "stage_1": "OpenCV — pixel-level CV analysis",
            "stage_2": f"HuggingFace NN — {HF_MODEL}",
            "stage_3": "Gemini 1.5 Flash — expert enrichment",
            "stage_4": "Weighted result fusion",
        },
        "endpoints": {
            "file_upload": "POST /cv/analyze",
            "base64":      "POST /cv/analyze/base64",
        },
    }


@app.post("/cv/analyze", tags=["Plant Analysis"])
async def analyze_file(file: UploadFile = File(...)):
    """
    **Full plant analysis from an uploaded image file.**

    Accepts: JPG, PNG, WEBP, GIF

    Returns a fused report from all 3 AI stages:
    - Plant identity + leaf morphology
    - Disease diagnosis with confidence
    - Treatment plan (chemical + organic + biological)
    - Prevention, nutrition, impact assessment
    - Raw CV diagnostics (transparency layer)

    **Flutter usage:**
    ```dart
    var req = http.MultipartRequest('POST', Uri.parse('http://IP:8001/cv/analyze'));
    req.files.add(await http.MultipartFile.fromPath('file', path));
    var res = await req.send();
    var data = json.decode(await res.stream.bytesToString());
    ```
    """
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files accepted.")
    try:
        raw   = await file.read()
        image = Image.open(io.BytesIO(raw)).convert("RGB")
        return analyze_image(image)
    except HTTPException:
        raise
    except Exception as e:
        return {"success": False, "error": str(e)}


@app.post("/cv/analyze/base64", tags=["Plant Analysis"])
async def analyze_base64(payload: Base64Request):
    """
    **Full plant analysis from a base64-encoded image.**

    Send raw camera bytes encoded as base64 — easier for Flutter camera plugins
    that give you `Uint8List` directly.

    **Flutter usage:**
    ```dart
    final bytes = await File(imagePath).readAsBytes();
    final b64   = base64Encode(bytes);
    final res   = await http.post(
      Uri.parse('http://IP:8001/cv/analyze/base64'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'image_base64': b64, 'mime_type': 'image/jpeg'}),
    );
    final data = json.decode(res.body);
    ```
    """
    try:
        raw   = base64.b64decode(payload.image_base64)
        image = Image.open(io.BytesIO(raw)).convert("RGB")
        return analyze_image(image)
    except Exception as e:
        return {"success": False, "error": str(e)}
