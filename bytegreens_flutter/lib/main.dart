import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

const Map<String, Map<String, String>> translations = {
  'en': {
    'scan': 'Scan Crop',
    'market': 'Marketplace',
    'dashboard': 'Dashboard',
    'weather': 'Weather',
    'english': 'English',
    'hindi': 'हिन्दी',
    'kannada': 'ಕನ್ನಡ',
    'choose_photo': 'Capture or choose a crop image to start diagnosis.',
    'gallery': 'Gallery',
    'camera': 'Camera',
    'crop_name': 'What crop are you selling?',
    'quantity': 'How many kg?',
    'location': 'Your village or city?',
    'rate': 'Price per kg in rupees?',
    'farmer_name': 'Your name (optional)',
    'submit': 'Post Listing',
    'crop_added': 'Great! Your crop listing is now visible to buyers.',
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
    'loading': 'Analyzing crop...',
    'no_listings': 'No crops listed yet. Add your first one above.',
    'speak_instructions': 'Hear instructions',
    'welcome': 'Welcome to ByteGreens!',
    'scan_help': 'Show your crop leaf to the camera.',
    'market_help': 'Add the crop details buyers need.',
    'weather_help': 'Check farm conditions before you plan your day.',
    'details': 'Details',
    'summary': 'Daily Summary',
    'view_more': 'Tap for more',
    'uploaded': 'Uploaded image',
    'live': 'Live Status',
  },
  'hi': {
    'scan': 'फसल स्कैन',
    'market': 'बाजार',
    'dashboard': 'डैशबोर्ड',
    'weather': 'मौसम',
    'english': 'English',
    'hindi': 'हिन्दी',
    'kannada': 'ಕನ್ನಡ',
    'choose_photo': 'रोग निदान शुरू करने के लिए फसल की तस्वीर कैप्चर या चुनें।',
    'gallery': 'गैलरी',
    'camera': 'कैमरा',
    'crop_name': 'आप कौन सी फसल बेच रहे हैं?',
    'quantity': 'कितने किलो हैं?',
    'location': 'आपका गाँव या शहर?',
    'rate': 'एक किलो का दाम?',
    'farmer_name': 'आपका नाम (वैकल्पिक)',
    'submit': 'लिस्टिंग पोस्ट करें',
    'crop_added': 'शानदार! आपकी फसल लिस्टिंग अब खरीदारों को दिख सकती है।',
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
    'loading': 'फसल का विश्लेषण हो रहा है...',
    'no_listings': 'अभी कोई फसल सूचीबद्ध नहीं है। ऊपर अपना पहला जोड़ें।',
    'speak_instructions': 'निर्देश सुनें',
    'welcome': 'ByteGreens में आपका स्वागत है!',
    'scan_help': 'अपनी फसल की पत्ती को कैमरे में दिखाएं।',
    'market_help': 'खरीदारों को आवश्यक फसल विवरण जोड़ें।',
    'weather_help': 'दिन की योजना बनाने से पहले खेत की स्थिति जांचें।',
    'details': 'विवरण',
    'summary': 'दैनिक सारांश',
    'view_more': 'अधिक देखने के लिए टैप करें',
    'uploaded': 'अपलोड की गई तस्वीर',
    'live': 'लाइव स्थिति',
  },
  'kn': {
    'scan': 'ಬೆಳೆ ಪರಿಶೀಲನೆ',
    'market': 'ಮಾರುಕಟ್ಟೆ',
    'dashboard': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
    'weather': 'ಹವಾಮಾನ',
    'english': 'English',
    'hindi': 'हिन्दी',
    'kannada': 'ಕನ್ನಡ',
    'choose_photo':
        'ರೋಗ ನಿರ诊ೆಯನ್ನು ಪ್ರಾರಂಭಿಸಲು ಬೆಳೆ ಚಿತ್ರವನ್ನು ತೆಗೆದುಕೊಳ್ಳಿ ಅಥವಾ ಆರಿಸಿ.',
    'gallery': 'ಗ್ಯಾಲರಿ',
    'camera': 'ಕ್ಯಾಮೆರಾ',
    'crop_name': 'ನೀವು ಯಾವ ಬೆಳೆ ಮಾರುತ್ತಿದ್ದೀರಿ?',
    'quantity': 'ಎಷ್ಟು ಕೆಜಿ?',
    'location': 'ನಿಮ್ಮ ಊರ ಅಥವಾ ನಗರ?',
    'rate': 'ಒಂದು ಕೆಜಿಗೆ ಬೆಲೆ?',
    'farmer_name': 'ನಿಮ್ಮ ಹೆಸರು (ಐಚ್ಛಿಕ)',
    'submit': 'ಪಟ್ಟಿಯನ್ನು ಪ್ರಕಟಿಸಿ',
    'crop_added': 'ಶ್ರೇಷ್ಠ! ನಿಮ್ಮ ಬೆಳೆ ಪಟ್ಟಿ ಈಗ ಖರೀದಕರಿಗೆ ಗೋಚರವಾಗಿದೆ.',
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
    'loading': 'ಬೆಳೆ ವಿಶ್ಲೇಷಣೆ ನಡೆಯುತ್ತಿದೆ...',
    'no_listings': 'ಇನ್ನೂ ಯಾವುದೇ ಬೆಳೆ ಪಟ್ಟಿ ಇಲ್ಲ. ಮೇಲಿನ ಪಟ್ಟಿ ಸೇರಿಸಿ.',
    'speak_instructions': 'ಸೂಚನೆಗಳನ್ನು ಕೇಳಿ',
    'welcome': 'ByteGreens ಗೆ ಸ್ವಾಗತ!',
    'scan_help': 'ನಿಮ್ಮ ಬೆಳೆ ಎಲೆಯನ್ನು ಕ್ಯಾಮೆರಾದಲ್ಲಿ ತೋರಿಸಿ.',
    'market_help': 'ಖರೀದಕರು ಅಗತ್ಯವಾಗಿ ಬಯಸುವ ಬೆಳೆ ವಿವರಗಳನ್ನು ಸೇರಿಸಿ.',
    'weather_help': 'ದಿನದ ಯೋಜನೆ ಮಾಡಲು ಮೊದಲು ಹೊಲದ ಪರಿಸ್ಥಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.',
    'details': 'ವಿವರಗಳು',
    'summary': 'ದೈನಂದಿನ ಸಾರಾಂಶ',
    'view_more': 'ಹೆಚ್ಚಿನ ಮಾಹಿತಿಗಾಗಿ ಟ್ಯಾಪ್ ಮಾಡಿ',
    'uploaded': 'ಅಪ್‌ലೋಡ್ ಮಾಡಿದ ಚಿತ್ರ',
    'live': 'ನೇರ ಸ್ಥಿತಿ',
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3FBF2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: Color(0xFFB7E4C7),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w600),
          ),
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
    _tts = FlutterTts();
    _setupTts();
  }

  Future<void> _setupTts() async {
    try {
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _setLanguage(_lang);
      setState(() => _ttsReady = true);
    } catch (e) {
      debugPrint('TTS init failed: $e');
    }
  }

  Future<void> _setLanguage(String lang) async {
    _lang = lang;
    final locale = languageCodes[lang] ?? 'en-US';
    try {
      await _tts.setLanguage(locale);
    } catch (e) {
      debugPrint('Failed to set language: $e');
    }
  }

  Future<void> _speak(String text) async {
    if (!_ttsReady || text.trim().isEmpty) return;
    try {
      await _tts.setLanguage(languageCodes[_lang] ?? 'en-US');
      await _tts.speak(text);
    } catch (e) {
      debugPrint('Speak error: $e');
    }
  }

  String _t(String key) => translations[_lang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    final label = ['scan', 'market', 'dashboard', 'weather'][_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌾 ByteGreens',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
            Text(
              _t(label),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _lang,
                dropdownColor: const Color(0xFF1B5E20),
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                items: [
                  DropdownMenuItem(value: 'en', child: Text(_t('english'))),
                  DropdownMenuItem(value: 'hi', child: Text(_t('hindi'))),
                  DropdownMenuItem(value: 'kn', child: Text(_t('kannada'))),
                ],
                onChanged: (value) async {
                  if (value != null) {
                    await _setLanguage(value);
                    setState(() {});
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: _buildPage(_currentIndex, key: ValueKey(_currentIndex)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() => _currentIndex = value);
          final helpKeys = [
            'scan_help',
            'market_help',
            'dashboard',
            'weather_help',
          ];
          final helpKey = helpKeys[value];
          if (helpKey != 'dashboard') {
            _speak(_t(helpKey));
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.camera_alt_outlined),
            label: _t('scan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            label: _t('market'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            label: _t('dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.cloud_queue_outlined),
            label: _t('weather'),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index, {Key? key}) {
    switch (index) {
      case 0:
        return ScanPage(key: key, lang: _lang, speak: _speak);
      case 1:
        return MarketPage(key: key, lang: _lang, speak: _speak);
      case 2:
        return DashboardPage(key: key, lang: _lang, speak: _speak);
      default:
        return WeatherPage(key: key, lang: _lang, speak: _speak);
    }
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
    final children = <Widget>[
      _heroCard(context),
      const SizedBox(height: 16),
      _actionRow(),
      const SizedBox(height: 20),
    ];

    if (_loading) {
      children.add(
        _statusCard(
          icon: Icons.autorenew,
          title: _t('loading'),
          subtitle: _t('live'),
        ),
      );
    } else if (_error != null) {
      children.add(_errorCard(_error!));
    } else if (_result != null) {
      children.add(_resultsCard());
    } else {
      children.add(
        _statusCard(
          icon: Icons.eco,
          title: _t('choose_photo'),
          subtitle: _t('view_more'),
        ),
      );
    }

    return ListView(children: children);
  }

  Widget _heroCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('uploaded'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: _imageFile == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.grass,
                            size: 70,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _t('choose_photo'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRow() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.photo_library_rounded,
            label: _t('gallery'),
            onPressed: () => _pickImage(ImageSource.gallery),
            color: const Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.camera_alt_rounded,
            label: _t('camera'),
            onPressed: () {
              widget.speak(_t('scan_help'));
              _pickImage(ImageSource.camera);
            },
            color: const Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _statusCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFDCFFD6),
              child: Icon(icon, color: const Color(0xFF1B5E20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String error) {
    return Card(
      color: const Color(0xFFFFF1F0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('error'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 8),
            Text(error, style: const TextStyle(color: Color(0xFFB71C1C))),
          ],
        ),
      ),
    );
  }

  Widget _resultsCard() {
    final entries = _result?.entries.toList() ?? [];
    return Column(
      children: entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.value?.toString() ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
        'farmer': _farmerController.text.trim().isEmpty
            ? 'Farmer'
            : _farmerController.text.trim(),
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
        final backendListings =
            snapshot.data?.cast<Map<String, dynamic>>() ?? [];
        final allListings = [..._customListings, ...backendListings];

        return ListView(
          children: [
            _formCard(),
            const SizedBox(height: 18),
            Text(
              _t('summary'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (allListings.isEmpty)
              _emptyState()
            else
              ...allListings.map((item) => _listingCard(item)).toList(),
          ],
        );
      },
    );
  }

  Widget _formCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('market'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t('market_help'),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              _buildInputField(_cropController, _t('crop_name'), Icons.grass),
              _buildInputField(
                _quantityController,
                _t('quantity'),
                Icons.scale,
                isNumber: true,
              ),
              _buildInputField(
                _locationController,
                _t('location'),
                Icons.location_on,
              ),
              _buildInputField(
                _rateController,
                _t('rate'),
                Icons.currency_rupee,
                isNumber: true,
              ),
              _buildInputField(
                _farmerController,
                _t('farmer_name'),
                Icons.person,
                isOptional: true,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitListing,
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  label: Text(
                    _t('submit'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1B5E20),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        validator: (value) =>
            !isOptional && (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _emptyState() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.storefront_rounded,
              size: 42,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 12),
            Text(
              _t('no_listings'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listingCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${item['crop']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFFD6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '₹${item['bytegreens_price']}/kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _tag(Icons.scale, '${item['quantity']} kg'),
                _tag(Icons.location_on, '${item['location']}'),
                _tag(Icons.person, '${item['farmer']}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
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
          return const Center(child: CircularProgressIndicator(strokeWidth: 5));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${_t('error')}: ${snapshot.error}',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        final stats = snapshot.data ?? {};
        return ListView(
          children: [
            _headlineCard(context, stats),
            const SizedBox(height: 18),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: [
                _statTile(
                  _t('farmers_helped'),
                  stats['farmers_helped'],
                  Icons.people_alt_rounded,
                  const Color(0xFF1565C0),
                ),
                _statTile(
                  _t('crops_scanned'),
                  stats['crops_scanned'],
                  Icons.grass_rounded,
                  const Color(0xFF2E7D32),
                ),
                _statTile(
                  _t('diseases_caught'),
                  stats['diseases_caught'],
                  Icons.bug_report_rounded,
                  const Color(0xFFFF8F00),
                ),
                _statTile(
                  _t('accuracy'),
                  '${stats['accuracy_percent']}%',
                  Icons.verified_rounded,
                  const Color(0xFF00897B),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: _t('income_saved'),
              value: '${stats['income_saved_lakhs']} L',
              icon: Icons.currency_rupee_rounded,
              color: const Color(0xFF43A047),
            ),
          ],
        );
      },
    );
  }

  Widget _headlineCard(BuildContext context, Map<String, dynamic> stats) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          gradient: LinearGradient(
            colors: [Color(0xFF388E3C), Color(0xFFA5D6A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('summary'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              'Your farm is staying productive and connected.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  '${stats['income_saved_lakhs']} L saved this season',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String title, Object? value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.18),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
          return const Center(child: CircularProgressIndicator(strokeWidth: 5));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${_t('error')}: ${snapshot.error}',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        final weather = snapshot.data ?? {};
        return ListView(
          children: [
            _locationCard(weather),
            const SizedBox(height: 18),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: [
                _weatherTile(
                  _t('temperature'),
                  '${weather['temperature']}°C',
                  Icons.thermostat_rounded,
                  const Color(0xFFD32F2F),
                ),
                _weatherTile(
                  _t('humidity'),
                  '${weather['humidity']}%',
                  Icons.water_drop_rounded,
                  const Color(0xFF1976D2),
                ),
                _weatherTile(
                  _t('rainfall'),
                  weather['rainfall_forecast'] ?? '-',
                  Icons.cloud_rounded,
                  const Color(0xFF5E35B1),
                ),
                _weatherTile(
                  _t('soil_moisture'),
                  '${weather['soil_moisture']}%',
                  Icons.grain_rounded,
                  const Color(0xFF8D6E63),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _soilCard(weather),
            const SizedBox(height: 18),
            Text(
              _t('alerts'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...(weather['alerts'] as List<dynamic>? ?? []).map((alert) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: const Color(0xFFFFF3E0),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFF57C00),
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          alert.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _locationCard(Map<String, dynamic> weather) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          gradient: LinearGradient(
            colors: [Color(0xFF0288D1), Color(0xFF81D4FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('location_label'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              weather['location'] ?? '-',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _t('weather_help'),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherTile(String label, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _soilCard(Map<String, dynamic> weather) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('soil_ph'),
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              weather['soil_ph'] ?? '-',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
