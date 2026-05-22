import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

// Comprehensive translation system with voice prompts
const Map<String, Map<String, String>> translations = {
  'en': {
    'scan': 'Scan Crop',
    'market': 'Sell Crops',
    'dashboard': 'My Impact',
    'weather': 'Weather',
    'english': 'English',
    'hindi': 'हिन्दी',
    'kannada': 'ಕನ್ನಡ',
    'choose_photo': 'Take photo to scan your crop disease',
    'gallery': 'Gallery',
    'camera': 'Camera',
    'crop_name': 'What crop are you selling?',
    'quantity': 'How many kg?',
    'location': 'Your village or city?',
    'rate': 'Price per kg in rupees?',
    'farmer_name': 'Your name (optional)',
    'add_crop': 'Sell My Crop',
    'crop_added': 'Great! Your crop is now visible to buyers!',
    'farmers_helped': 'Farmers Helped',
    'crops_scanned': 'Crops Scanned',
    'diseases_caught': 'Diseases Found',
    'income_saved': 'Money Saved',
    'accuracy': 'Accuracy',
    'location_label': 'Location',
    'temperature': 'Temperature',
    'humidity': 'Humidity',
    'rainfall': 'Rain Coming?',
    'soil_moisture': 'Soil Wetness',
    'soil_ph': 'Soil pH',
    'alerts': 'Important Alerts',
    'error': 'Error',
    'loading': 'Loading...',
    'no_listings': 'No crops listed yet. Add yours above!',
    'speak_instructions': 'Hear Instructions',
    'submit': 'Submit',
    'welcome': 'Welcome to ByteGreens!',
    'scan_help': 'Show your crop leaf to the camera',
    'market_help': 'Tell us what you are selling',
    'weather_help': 'Check if weather is good for farming',
  },
  'hi': {
    'scan': 'फसल स्कैन',
    'market': 'फसल बेचें',
    'dashboard': 'मेरा असर',
    'weather': 'मौसम',
    'english': 'English',
    'hindi': 'हिन्दी',
    'kannada': 'ಕನ್ನಡ',
    'choose_photo': 'अपनी फसल की बीमारी को स्कैन करने के लिए फोटो लें',
    'gallery': 'गैलरी',
    'camera': 'कैमरा',
    'crop_name': 'आप कौन सी फसल बेच रहे हैं?',
    'quantity': 'कितने किलो हैं?',
    'location': 'आपका गाँव या शहर?',
    'rate': 'एक किलो का दाम?',
    'farmer_name': 'आपका नाम (वैकल्पिक)',
    'add_crop': 'मेरी फसल बेचें',
    'crop_added': 'शानदार! आपकी फसल अब खरीदारों को दिख सकती है!',
    'farmers_helped': 'किसानों की मदद',
    'crops_scanned': 'स्कैन की गई फसलें',
    'diseases_caught': 'रोग पाए गए',
    'income_saved': 'पैसे बचे',
    'accuracy': 'सटीकता',
    'location_label': 'स्थान',
    'temperature': 'तापमान',
    'humidity': 'नमी',
    'rainfall': 'बारिश आएगी?',
    'soil_moisture': 'मिट्टी की नमी',
    'soil_ph': 'मिट्टी pH',
    'alerts': 'महत्वपूर्ण सतर्कताएं',
    'error': 'त्रुटि',
    'loading': 'लोड हो रहा है...',
    'no_listings': 'अभी कोई फसल सूचीबद्ध नहीं है। ऊपर अपना जोड़ें!',
    'speak_instructions': 'निर्देश सुनें',
    'submit': 'जमा करें',
    'welcome': 'ByteGreens में आपका स्वागत है!',
    'scan_help': 'अपनी फसल की पत्ती को कैमरे में दिखाएं',
    'market_help': 'हमें बताएं कि आप क्या बेच रहे हैं',
    'weather_help': 'जांचें कि खेती के लिए मौसम अच्छा है',
  },
  'kn': {
    'scan': 'ಬೆಳೆ ಪರಿಶೀಲನೆ',
    'market': 'ಬೆಳೆ ಮಾರಿ',
    'dashboard': 'ನನ್ನ ಪ್ರಭಾವ',
    'weather': 'ಹವಾಮಾನ',
    'english': 'English',
    'hindi': 'हिन्दी',
    'kannada': 'ಕನ್ನಡ',
    'choose_photo': 'ನಿಮ್ಮ ಬೆಳೆಯ ರೋಗವನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಫೋಟೋ ತೆಗೆಯಿರಿ',
    'gallery': 'ಗ್ಯಾಲರಿ',
    'camera': 'ಕ್ಯಾಮೆರಾ',
    'crop_name': 'ನೀವು ಯಾವ ಬೆಳೆ ಮಾರುತ್ತಿದ್ದೀರಿ?',
    'quantity': 'ಎಷ್ಟು ಕೆಜಿ?',
    'location': 'ನಿಮ್ಮ ಊರ ಅಥವಾ ನಗರ?',
    'rate': 'ಒಂದು ಕೆಜಿಗೆ ಬೆಲೆ?',
    'farmer_name': 'ನಿಮ್ಮ ಹೆಸರು (ಐಚ್ಛಿಕ)',
    'add_crop': 'ನನ್ನ ಬೆಳೆ ಮಾರಿ',
    'crop_added': 'ಶ್ರೇಷ್ಠ! ನಿಮ್ಮ ಬೆಳೆ ಈಗ ಖರೀದಕರಿಗೆ ಗೋಚರವಾಗಿದೆ!',
    'farmers_helped': 'ರೈತರಿಗೆ ಸಹಾಯ',
    'crops_scanned': 'ಸ್ಕ್ಯಾನ್ ಮಾಡಿದ ಬೆಳೆಗಳು',
    'diseases_caught': 'ರೋಗ ಕಂಡುಬಂದಿವೆ',
    'income_saved': 'ಹಣ ಉಳಿತ',
    'accuracy': 'ನಿಖುರತೆ',
    'location_label': 'ಸ್ಥಾನ',
    'temperature': 'ತಾಪಮಾನ',
    'humidity': 'ಆರ್ದ್ರತೆ',
    'rainfall': 'ಮಳೆ ಬರುವುದೇ?',
    'soil_moisture': 'ಮಣ್ಣಿನ ನೀರಾವರಣ',
    'soil_ph': 'ಮಣ್ಣಿನ pH',
    'alerts': 'ಪ್ರಮುಖ ಎಚ್ಚರಿಕೆಗಳು',
    'error': 'ದೋಷ',
    'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
    'no_listings': 'ಇನ್ನೂ ಯಾವುದೇ ಬೆಳೆ ಪಟ್ಟಿ ಇಲ್ಲ. ಮೇಲೆ ನಿಮ್ಮದನ್ನು ಸೇರಿಸಿ!',
    'speak_instructions': 'ಸೂಚನೆಗಳನ್ನು ಕೇಳಿ',
    'submit': 'ಸಲ್ಲಿಸಿ',
    'welcome': 'ByteGreens ಗೆ ಸ್ವಾಗತ!',
    'scan_help': 'ನಿಮ್ಮ ಬೆಳೆಯ ಎಲೆಯನ್ನು ಕ್ಯಾಮೆರಾದಲ್ಲಿ ತೋರಿಸಿ',
    'market_help': 'ನೀವು ಏನು ಮಾರುತ್ತಿದ್ದೀರಿ ಎಂದು ಹೇಳಿ',
    'weather_help': 'ಕೃಷಿಗೆ ಹವಾಮಾನ ಸರಿಯಿದೆಯೇ ಎಂದು ಪರಿಶೀಲಿಸಿ',
  },
};

const Map<String, String> languageCodes = {
  'en': 'en-US',
  'hi': 'hi-IN',
  'kn': 'kn_IN',
};

void main() {
  runApp(const ByteGreensApp());
}

class ByteGreensApp extends StatelessWidget {
  const ByteGreensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteGreens',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF1B5E20),
              displayColor: const Color(0xFF1B5E20),
            ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late FlutterTts _tts;
  String _lang = 'en';
  bool _ttsReady = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    _tts = FlutterTts();
    _setupTts();
  }

  void _setupTts() async {
    try {
      await _tts.awaitSpeechCompletion(true);
      _tts.setCompletionHandler(() {
        print('Speech completed');
      });
      _tts.setErrorHandler((msg) {
        print('TTS Error: $msg');
      });
      setState(() => _ttsReady = true);
      _setLanguage(_lang);
    } catch (e) {
      print('TTS init failed: $e');
    }
  }

  void _setLanguage(String lang) async {
    try {
      _lang = lang;
      String locale = languageCodes[lang] ?? 'en-US';
      await _tts.setLanguage(locale);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      print('Language set to: $locale');
    } catch (e) {
      print('Failed to set language: $e');
    }
  }

  void speak(String text) async {
    if (!_ttsReady || text.isEmpty) return;
    try {
      await _tts.speak(text);
    } catch (e) {
      print('Speak error: $e');
    }
  }

  String _t(String key) => translations[_lang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌾 ByteGreens', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _lang,
              dropdownColor: Colors.green,
              items: [
                DropdownMenuItem(value: 'en', child: Text(_t('english'), style: const TextStyle(color: Colors.white, fontSize: 16))),
                DropdownMenuItem(value: 'hi', child: Text(_t('hindi'), style: const TextStyle(color: Colors.white, fontSize: 16))),
                DropdownMenuItem(value: 'kn', child: Text(_t('kannada'), style: const TextStyle(color: Colors.white, fontSize: 16))),
              ],
              onChanged: (value) {
                if (value != null) {
                  _setLanguage(value);
                }
              },
              underline: const SizedBox(),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: [
        ScanPage(lang: _lang, speak: speak),
        MarketPage(lang: _lang, speak: speak),
        DashboardPage(lang: _lang, speak: speak),
        WeatherPage(lang: _lang, speak: speak),
      ][_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() => _currentIndex = value);
          final titles = ['scan_help', 'market_help', 'weather_help', 'weather_help'];
          speak(_t(titles[value]));
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.camera_alt, size: 32),
            label: _t('scan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront, size: 32),
            label: _t('market'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.trending_up, size: 32),
            label: _t('dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.cloud_queue, size: 32),
            label: _t('weather'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

class ScanPage extends StatefulWidget {
  final String lang;
  final Function(String) speak;

  const ScanPage({super.key, required this.lang, required this.speak});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _imageFile;
  Map<String, dynamic>? _result;
  String? _error;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  String _t(String key) => translations[widget.lang]?[key] ?? key;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, maxWidth: 1200);
    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _result = null;
      _error = null;
    });

    widget.speak(_t('loading'));
    await _uploadImage();
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final response = await ApiService.analyzeImage(_imageFile!);
      if (response['success'] == true) {
        setState(() => _result = response['result'] as Map<String, dynamic>?);
        widget.speak('Disease analysis complete!');
      } else {
        setState(() => _error = response['error']?.toString() ?? 'Error');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grass, size: 80, color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            _t('choose_photo'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo, size: 28),
                    label: Text(_t('gallery'), style: const TextStyle(fontSize: 18)),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt, size: 28),
                    label: Text(_t('camera'), style: const TextStyle(fontSize: 18)),
                    onPressed: () {
                      widget.speak(_t('scan_help'));
                      _pickImage(ImageSource.camera);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_loading)
              Column(
                children: [
                  const CircularProgressIndicator(strokeWidth: 6, valueColor: AlwaysStoppedAnimation(Colors.green)),
                  const SizedBox(height: 20),
                  Text(_t('loading'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              )
            else if (_error != null)
              Text('${_t('error')}: $_error', style: const TextStyle(color: Colors.red, fontSize: 18))
            else if (_result != null)
              ..._result!.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                          const SizedBox(height: 12),
                          Text(entry.value?.toString() ?? '', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class MarketPage extends StatefulWidget {
  final String lang;
  final Function(String) speak;

  const MarketPage({super.key, required this.lang, required this.speak});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _rateController = TextEditingController();
  final _farmerController = TextEditingController();

  final List<Map<String, dynamic>> _customListings = [];

  String _t(String key) => translations[widget.lang]?[key] ?? key;

  @override
  void dispose() {
    _cropController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _rateController.dispose();
    _farmerController.dispose();
    super.dispose();
  }

  void _submitListing() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _customListings.insert(0, {
        'crop': _cropController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'location': _locationController.text.trim(),
        'bytegreens_price': _rateController.text.trim(),
        'farmer': _farmerController.text.trim().isEmpty ? 'Farmer' : _farmerController.text.trim(),
      });
    });

    widget.speak(_t('crop_added'));
    _cropController.clear();
    _quantityController.clear();
    _locationController.clear();
    _rateController.clear();
    _farmerController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.fetchMarket(),
      builder: (context, snapshot) {
        final backendListings = snapshot.data?.cast<Map<String, dynamic>>() ?? [];
        final allListings = [..._customListings, ...backendListings];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('market'),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          _buildInputField(_cropController, _t('crop_name'), Icons.grass),
                          _buildInputField(_quantityController, _t('quantity'), Icons.scale, isNumber: true),
                          _buildInputField(_locationController, _t('location'), Icons.location_on),
                          _buildInputField(_rateController, _t('rate'), Icons.currency_rupee, isNumber: true),
                          _buildInputField(_farmerController, _t('farmer_name'), Icons.person, isOptional: true),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_circle, size: 32),
                              label: Text(_t('submit'), style: const TextStyle(fontSize: 20, color: Color(0xFF1B5E20))),
                              onPressed: _submitListing,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...allListings.map((item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item['crop']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item['quantity']} kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('📍 ${item['location']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                ],
                              ),
                              Text('₹${item['bytegreens_price']}/kg', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 16),
          prefixIcon: Icon(icon, color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        validator: (value) => !isOptional && (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final String lang;
  final Function(String) speak;

  const DashboardPage({super.key, required this.lang, required this.speak});

  String _t(String key) => translations[lang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 6));
        }

        final stats = snapshot.data ?? {};
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatCard(_t('farmers_helped'), stats['farmers_helped'], Icons.people, Colors.blue),
                _buildStatCard(_t('crops_scanned'), stats['crops_scanned'], Icons.grass, Colors.green),
                _buildStatCard(_t('diseases_caught'), stats['diseases_caught'], Icons.warning, Colors.orange),
                _buildStatCard(_t('income_saved'), '${stats['income_saved_lakhs']} L', Icons.currency_rupee, Colors.green),
                _buildStatCard(_t('accuracy'), '${stats['accuracy_percent']}%', Icons.check_circle, Colors.teal),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, Object? value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color.withAlpha(200), color.withAlpha(100)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, size: 56, color: Colors.white),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    Text(value?.toString() ?? '-', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherPage extends StatelessWidget {
  final String lang;
  final Function(String) speak;

  const WeatherPage({super.key, required this.lang, required this.speak});

  String _t(String key) => translations[lang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.fetchWeather(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 6));
        }

        final weather = snapshot.data ?? {};
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('location_label'), style: const TextStyle(fontSize: 16, color: Colors.white70)),
                        Text(weather['location'] ?? '-', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildWeatherTile(_t('temperature'), '${weather['temperature']}°C', Icons.thermostat, Colors.red),
                _buildWeatherTile(_t('humidity'), '${weather['humidity']}%', Icons.water_drop, Colors.blue),
                _buildWeatherTile(_t('rainfall'), weather['rainfall_forecast'] ?? '-', Icons.cloud_queue, Colors.indigo),
                _buildWeatherTile(_t('soil_moisture'), '${weather['soil_moisture']}%', Icons.grain, Colors.brown),
                _buildWeatherTile(_t('soil_ph'), weather['soil_ph'] ?? '-', Icons.science, Colors.purple),
                const SizedBox(height: 24),
                Text(_t('alerts'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...((weather['alerts'] as List<dynamic>?) ?? []).map((alert) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange, size: 32),
                          const SizedBox(width: 16),
                          Expanded(child: Text(alert.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherTile(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withAlpha(200), color.withAlpha(100)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 44, color: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

// Comprehensive translation system
const Map<String, Map<String, String>> translations = {
  'en': {
    'scan': 'Scan Crop',
    'market': 'Marketplace',
    'dashboard': 'Dashboard',
    'weather': 'Weather',
    'english': 'English',
    'hindi': 'हिन्दी',
    'kannada': 'ಕನ್ನಡ',
    'choose_photo': 'Choose a photo from gallery or camera to scan your crop.',
    'gallery': 'Gallery',
    'camera': 'Camera',
    'crop_name': 'Crop Name',
    'quantity': 'Quantity (kg)',
    'location': 'Your Location',
    'rate': 'Rate (₹ per kg)',
    'farmer_name': 'Your Name',
    'add_crop': 'Add Crop',
    'crop_added': 'Your crop listing has been added! Buyers can now see it.',
    'farmers_helped': 'Farmers Helped',
    'crops_scanned': 'Crops Scanned',
    'diseases_caught': 'Diseases Caught',
    'income_saved': 'Income Saved (₹ Lakhs)',
    'accuracy': 'Accuracy',
    'location_label': 'Location',
    'temperature': 'Temperature',
    'humidity': 'Humidity',
    'rainfall': 'Rainfall Forecast',
    'soil_moisture': 'Soil Moisture',
    'soil_ph': 'Soil pH',
    'alerts': 'Alerts',
    'error': 'Error',
    'loading': 'Loading...',
    'no_listings': 'No crop listings yet. Add a listing above.',
    'speak_instructions': 'Speak Instructions',
    'submit': 'Submit',
  },
  'hi': {
    'scan': 'फसल स्कैन करें',
    'market': 'बाजार',
    'dashboard': 'डैशबोर्ड',
    'weather': 'मौसम',
    'english': 'English',
    'hindi': 'हिन्दी',
    'kannada': 'ಕನ್ನಡ',
    'choose_photo': 'अपनी फसल को स्कैन करने के लिए गैलरी या कैमरा से फोटो चुनें।',
    'gallery': 'गैलरी',
    'camera': 'कैमरा',
    'crop_name': 'फसल का नाम',
    'quantity': 'मात्रा (किग्रा)',
    'location': 'आपका स्थान',
    'rate': 'दर (₹ प्रति किग्रा)',
    'farmer_name': 'आपका नाम',
    'add_crop': 'फसल जोड़ें',
    'crop_added': 'आपकी फसल सूची जोड़ दी गई है! खरीदार अब इसे देख सकते हैं।',
    'farmers_helped': 'किसानों की मदद की गई',
    'crops_scanned': 'फसलें स्कैन की गईं',
    'diseases_caught': 'रोग पकड़े गए',
    'income_saved': 'आय बचाई गई (₹ लाख)',
    'accuracy': 'सटीकता',
    'location_label': 'स्थान',
    'temperature': 'तापमान',
    'humidity': 'आर्द्रता',
    'rainfall': 'वर्षा पूर्वानुमान',
    'soil_moisture': 'मिट्टी की नमी',
    'soil_ph': 'मिट्टी का pH',
    'alerts': 'सतर्कताएं',
    'error': 'त्रुटि',
    'loading': 'लोड हो रहा है...',
    'no_listings': 'अभी कोई फसल सूची नहीं है। ऊपर एक सूची जोड़ें।',
    'speak_instructions': 'निर्देश सुनें',
    'submit': 'जमा करें',
  },
  'kn': {
    'scan': 'ಬೆಳೆ ಪರಿಶೀಲನೆ ಮಾಡಿ',
    'market': 'ಮಾರುಕಟ್ಟೆ',
    'dashboard': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
    'weather': 'ಹವಾಮಾನ',
    'english': 'English',
    'hindi': 'हिन्दी',
    'kannada': 'ಕನ್ನಡ',
    'choose_photo': 'ನಿಮ್ಮ ಬೆಳೆ ಪರಿಶೀಲಿಸಲು ಗ್ಯಾಲರಿ ಅಥವಾ ಕ್ಯಾಮೆರಾದಿಂದ ಫೋಟೋ ಆಯ್ಕೆಮಾಡಿ.',
    'gallery': 'ಗ್ಯಾಲರಿ',
    'camera': 'ಕ್ಯಾಮೆರಾ',
    'crop_name': 'ಬೆಳೆಯ ಹೆಸರು',
    'quantity': 'ಪ್ರಮಾಣ (ಕೆಜಿ)',
    'location': 'ನಿಮ್ಮ ಸ್ಥಾನ',
    'rate': 'ದರ (₹ ಪ್ರತಿ ಕೆಜಿ)',
    'farmer_name': 'ನಿಮ್ಮ ಹೆಸರು',
    'add_crop': 'ಬೆಳೆ ಸೇರಿಸಿ',
    'crop_added': 'ನಿಮ್ಮ ಬೆಳೆ ಪಟ್ಟಿ ಸೇರಿಸಲಾಗಿದೆ! ಖರೀದಕರು ಈಗ ಇದನ್ನು ನೋಡಬಹುದು.',
    'farmers_helped': 'ರೈತರನ್ನು ಸಹಾಯ ಮಾಡಿದೆ',
    'crops_scanned': 'ಸ್ಕ್ಯಾನ್ ಮಾಡಿದ ಬೆಳೆಗಳು',
    'diseases_caught': 'ಹಿಡಿಯಲಾದ ರೋಗಗಳು',
    'income_saved': 'ಆದಾಯ ಉಳಿಸಲಾಗಿದೆ (₹ ಲಕ್ষ)',
    'accuracy': 'ನಿಖುರತೆ',
    'location_label': 'ಸ್ಥಾನ',
    'temperature': 'ತಾಪಮಾನ',
    'humidity': 'ಆರ್ದ್ರತೆ',
    'rainfall': 'ಮಳೆಯ ಮುನ್ನೋಲೆ',
    'soil_moisture': 'ಮಣ್ಣಿನ ನಿರ್ಜಲೀಕರಣ',
    'soil_ph': 'ಮಣ್ಣಿನ pH',
    'alerts': 'ಎಚ್ಚರಿಕೆಗಳು',
    'error': 'ದೋಷ',
    'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
    'no_listings': 'ಇನ್ನೂ ಯಾವುದೇ ಬೆಳೆ ಪಟ್ಟಿಯಿಲ್ಲ. ಮೇಲಿನ ಪಟ್ಟಿ ಸೇರಿಸಿ.',
    'speak_instructions': 'ನಿರ್ದೇಶನಗಳನ್ನು ಕೇಳಿ',
    'submit': 'ಸಲ್ಲಿಸಿ',
  },
};

const Map<String, String> languageCodes = {
  'en': 'en-US',
  'hi': 'hi-IN',
  'kn': 'kn_IN',
};

void main() {
  runApp(const ByteGreensApp());
}

class ByteGreensApp extends StatelessWidget {
  const ByteGreensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteGreens',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FlutterTts _tts = FlutterTts();
  String _lang = 'en';

  @override
  void initState() {
    super.initState();
    _configureTts();
  }

  Future<void> _configureTts() async {
    try {
      await _tts.setLanguage(languageCodes[_lang]!);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.8);
    } catch (e) {
      print('TTS configuration error for $_lang: $e');
      // Fallback to English if language not available
      if (_lang != 'en') {
        await _tts.setLanguage('en-US');
      }
    }
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    try {
      await _tts.setLanguage(languageCodes[_lang]!);
      await _tts.speak(text);
    } catch (e) {
      print('TTS speak error for $_lang: $e');
      // Try English if target language fails
      try {
        await _tts.setLanguage('en-US');
        await _tts.speak(text);
      } catch (e2) {
        print('TTS fallback error: $e2');
      }
    }
  }

  String _t(String key) => translations[_lang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t(['scan', 'market', 'dashboard', 'weather'][_currentIndex])),
        elevation: 0,
        actions: [
          DropdownButton<String>(
            value: _lang,
            dropdownColor: Colors.green,
            items: [
              DropdownMenuItem(value: 'en', child: Text(_t('english'), style: const TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'hi', child: Text(_t('hindi'), style: const TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'kn', child: Text(_t('kannada'), style: const TextStyle(color: Colors.white))),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _lang = value);
                _configureTts();
              }
            },
            underline: const SizedBox(),
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28),
            tooltip: _t('speak_instructions'),
            onPressed: () {
              final text = spokenText[['scan', 'market', 'dashboard', 'weather'][_currentIndex]]?[_lang] ?? '';
              _speak(text);
            },
          ),
        ],
      ),
      body: [
        ScanPage(lang: _lang, speak: _speak),
        MarketPage(lang: _lang, speak: _speak),
        DashboardPage(lang: _lang, speak: _speak),
        WeatherPage(lang: _lang, speak: _speak),
      ][_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) => setState(() => _currentIndex = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.camera_alt, size: 28), label: _t('scan')),
          NavigationDestination(icon: const Icon(Icons.storefront, size: 28), label: _t('market')),
          NavigationDestination(icon: const Icon(Icons.bar_chart, size: 28), label: _t('dashboard')),
          NavigationDestination(icon: const Icon(Icons.wb_sunny, size: 28), label: _t('weather')),
        ],
      ),
    );
  }
}

const Map<String, Map<String, String>> spokenText = {
  'scan': {
    'en': 'Choose a photo from gallery or camera to scan your crop.',
    'hi': 'अपनी फसल को स्कैन करने के लिए गैलरी या कैमरा से फोटो चुनें।',
    'kn': 'ನಿಮ್ಮ ಬೆಳೆ ಪರಿಶೀಲಿಸಲು ಗ್ಯಾಲರಿ ಅಥವಾ ಕ್ಯಾಮೆರಾದಿಂದ ಫೋಟೋ ಆಯ್ಕೆಮಾಡಿ.',
  },
  'market': {
    'en': 'Add your crop, location and rate here so buyers can see it.',
    'hi': 'यहाँ अपनी फसल, स्थान और दर जोड़ें ताकि खरीदार इसे देख सकें।',
    'kn': 'ಖರೀದಕರು ನೋಡಲು ನಿಮ್ಮ ಬೆಳೆ, ಸ್ಥಳ ಮತ್ತು ದರವನ್ನು ಇಲ್ಲಿ ಸೇರಿಸಿ.',
  },
  'dashboard': {
    'en': 'This dashboard shows your farm impact and crop activity.',
    'hi': 'यह डैशबोर्ड आपके खेत के प्रभाव और फसल गतिविधि को दर्शाता है।',
    'kn': 'ಈ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ನಿಮ್ಮ ಕೃಷಿ ಪ್ರಭಾವ ಮತ್ತು ಬೆಳೆ ಚಟುವಟಿಕೆಯನ್ನು ತೋರಿಸುತ್ತದೆ.',
  },
  'weather': {
    'en': 'Check weather and soil conditions to plan your farming.',
    'hi': 'अपनी खेती की योजना बनाने के लिए मौसम और मिट्टी की स्थिति जांचें।',
    'kn': 'ನೀವು ಕೃಷಿಯನ್ನು ಯೋಜಿಸಲು ಹವಾಮಾನ ಮತ್ತು ಮಣ್ಣುಗಳ ಸ್ಥಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.',
  },
};

class ScanPage extends StatefulWidget {
  final String lang;
  final Function(String) speak;

  const ScanPage({super.key, required this.lang, required this.speak});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _imageFile;
  Map<String, dynamic>? _result;
  String? _error;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  String _t(String key) => translations[widget.lang]?[key] ?? key;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, maxWidth: 1200);
    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _result = null;
      _error = null;
    });

    await _uploadImage();
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final response = await ApiService.analyzeImage(_imageFile!);
      if (response['success'] == true) {
        setState(() => _result = response['result'] as Map<String, dynamic>?);
      } else {
        setState(() => _error = response['error']?.toString() ?? 'Error');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, height: 280, fit: BoxFit.cover)
            else
              Container(
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo, size: 24),
                    label: Text(_t('gallery'), style: const TextStyle(fontSize: 18)),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt, size: 24),
                    label: Text(_t('camera'), style: const TextStyle(fontSize: 18)),
                    onPressed: () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircularProgressIndicator(strokeWidth: 4),
                    const SizedBox(height: 16),
                    Text(_t('loading'), style: const TextStyle(fontSize: 18)),
                  ],
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${_t('error')}: $_error', style: const TextStyle(color: Colors.red, fontSize: 16)),
              )
            else if (_result != null)
              ..._result!.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(entry.value?.toString() ?? '', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList()
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _t('choose_photo'),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MarketPage extends StatefulWidget {
  final String lang;
  final Function(String) speak;

  const MarketPage({super.key, required this.lang, required this.speak});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _rateController = TextEditingController();
  final _farmerController = TextEditingController();

  final List<Map<String, dynamic>> _customListings = [];

  String _t(String key) => translations[widget.lang]?[key] ?? key;

  @override
  void dispose() {
    _cropController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _rateController.dispose();
    _farmerController.dispose();
    super.dispose();
  }

  void _submitListing() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _customListings.insert(0, {
        'crop': _cropController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'location': _locationController.text.trim(),
        'bytegreens_price': _rateController.text.trim(),
        'farmer': _farmerController.text.trim().isEmpty ? _t('farmer_name') : _farmerController.text.trim(),
      });
      _cropController.clear();
      _quantityController.clear();
      _locationController.clear();
      _rateController.clear();
      _farmerController.clear();
    });

    widget.speak(_t('crop_added'));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.fetchMarket(),
      builder: (context, snapshot) {
        final backendListings = snapshot.data?.cast<Map<String, dynamic>>() ?? [];
        final allListings = [..._customListings, ...backendListings];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('add_crop'),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(_cropController, _t('crop_name'), Icons.grass),
                          _buildInputField(_quantityController, _t('quantity'), Icons.scale, isNumber: true),
                          _buildInputField(_locationController, _t('location'), Icons.location_on),
                          _buildInputField(_rateController, _t('rate'), Icons.currency_rupee, isNumber: true),
                          _buildInputField(_farmerController, _t('farmer_name'), Icons.person, isOptional: true),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_circle, size: 28),
                              label: Text(_t('submit'), style: const TextStyle(fontSize: 18)),
                              onPressed: _submitListing,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...allListings.map((item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item['crop']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item['quantity']} kg', style: const TextStyle(fontSize: 16)),
                                  Text('${item['location']}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                              Text('₹${item['bytegreens_price']}/kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(fontSize: 16),
        validator: (value) {
          if (isOptional) return null;
          return value == null || value.isEmpty ? '$label ${_t("error")}' : null;
        },
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final String lang;
  final Function(String) speak;

  const DashboardPage({super.key, required this.lang, required this.speak});

  String _t(String key) => translations[lang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator(strokeWidth: 4));
        }
        if (snapshot.hasError) {
          return Center(child: Text('${_t("error")}: ${snapshot.error}', style: const TextStyle(fontSize: 16)));
        }

        final stats = snapshot.data ?? {};
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatCard(_t('farmers_helped'), stats['farmers_helped'], Icons.people),
                _buildStatCard(_t('crops_scanned'), stats['crops_scanned'], Icons.grass),
                _buildStatCard(_t('diseases_caught'), stats['diseases_caught'], Icons.bug_report),
                _buildStatCard(_t('income_saved'), stats['income_saved_lakhs'], Icons.currency_rupee),
                _buildStatCard(_t('accuracy'), '${stats['accuracy_percent']}%', Icons.check_circle),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, Object? value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(value?.toString() ?? '-', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherPage extends StatelessWidget {
  final String lang;
  final Function(String) speak;

  const WeatherPage({super.key, required this.lang, required this.speak});

  String _t(String key) => translations[lang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.fetchWeather(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 4));
        }
        if (snapshot.hasError) {
          return Center(child: Text('${_t("error")}: ${snapshot.error}', style: const TextStyle(fontSize: 16)));
        }

        final weather = snapshot.data ?? {};
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('location_label'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(weather['location'] ?? '-', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildWeatherTile(_t('temperature'), '${weather['temperature']}°C', Icons.thermostat),
                _buildWeatherTile(_t('humidity'), '${weather['humidity']}%', Icons.water_drop),
                _buildWeatherTile(_t('rainfall'), weather['rainfall_forecast'] ?? '-', Icons.cloud_queue),
                _buildWeatherTile(_t('soil_moisture'), '${weather['soil_moisture']}%', Icons.grain),
                _buildWeatherTile(_t('soil_ph'), weather['soil_ph'] ?? '-', Icons.science),
                const SizedBox(height: 20),
                Text(_t('alerts'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...((weather['alerts'] as List<dynamic>?) ?? []).map((alert) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      color: Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 28),
                            const SizedBox(width: 12),
                            Expanded(child: Text(alert.toString(), style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherTile(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
