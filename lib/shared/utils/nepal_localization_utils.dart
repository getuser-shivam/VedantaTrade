import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Nepal Localization Utilities
class NepalLocalizationUtils {
  static const String _nprSymbol = 'रू';
  static const String _nprCode = 'NPR';
  static const double _vatRate = 0.13; // 13% VAT for Nepal
  
  static const Map<String, String> _nepaliMonths = {
    'January': 'बैशाख',
    'February': 'जेठ',
    'March': 'असार',
    'April': 'श्रावण',
    'May': 'भाद्र',
    'June': 'आश्विन',
    'July': 'कार्तिक',
    'August': 'मंसिर',
    'September': 'पौष',
    'October': 'माघ',
    'November': 'फाल्गुन',
    'December': 'चैत्र',
  };
  
  static const Map<String, String> _nepaliDays = {
    'Monday': 'सोमबार',
    'Tuesday': 'मंगलबार',
    'Wednesday': 'बुधबार',
    'Thursday': 'बिहिबार',
    'Friday': 'शुक्रबार',
    'Saturday': 'शनिबार',
    'Sunday': 'आइतबार',
  };
  
  static const Map<String, String> _nepaliRegions = {
    'Kathmandu': 'काठमाडौं',
    'Pokhara': 'पोखरा',
    'Biratnagar': 'बिराटनगर',
    'Bhaktapur': 'भक्तपुर',
    'Lalitpur': 'ललितपुर',
    'Dharan': 'धरान',
    'Birgunj': 'बीरगंज',
    'Nepalgunj': 'नेपालगंज',
    'Butwal': 'बुटवल',
    'Hetauda': 'हेटौडा',
    'Janakpur': 'जनकपुर',
    'Bharatpur': 'भरतपुर',
    'Madhyapur Thimi': 'मध्यापुर ठिमी',
    'Bhimphedi': 'भिम्फेदी',
    'Tulsipur': 'तुलसीपुर',
    'Gorkha': 'गोरखा',
    'Dhangadhi': 'धनगढी',
    'Mahendranagar': 'महेन्द्रनगर',
    'Birendranagar': 'वीरेन्द्रनगर',
    'Tikapur': 'तिकापुर',
    'Lahan': 'लहान',
    'Kalaiya': 'कलैया',
    'Gaur': 'गौर',
    'Khadak': 'खडक',
    'Rajbiraj': 'राजविराज',
    'Siraha': 'सिराहा',
    'Namje': 'नाम्जे',
    'Bhojpur': 'भोजपुर',
    'Dhankuta': 'धनकुटा',
    'Terhathum': 'तेह्रथुम',
    'Panchthar': 'पाँचथर',
    'Ilam': 'इलाम',
    'Jhapa': 'झापा',
    'Morang': 'मोरंग',
    'Sunsari': 'सुनसरी',
    'Saptari': 'सप्तरी',
    'Udayapur': 'उदयपुर',
    'Sindhuli': 'सिन्धुली',
    'Ramechhap': 'रामेछाप',
    'Dolakha': 'दोलखा',
    'Sindhupalchok': 'सिन्धुपालचोक',
    'Kavrepalanchok': 'काभ्रेपलान्चोक',
    'Lalitpur': 'ललितपुर',
    'Bhaktapur': 'भक्तपुर',
    'Nuwakot': 'नुवाकोट',
    'Rasuwa': 'रसुवा',
    'Dhading': 'धादिङ',
    'Makwanpur': 'मकवानपुर',
    'Chitwan': 'चितवन',
    'Nawalparasi': 'नवलपरासी',
    'Rupandehi': 'रुपन्देही',
    'Kapilvastu': 'कपिलवस्तु',
    'Arghakhanchi': 'अर्घाखाँची',
    'Gulmi': 'गुल्मी',
    'Palpa': 'पाल्पा',
    'Syangja': 'स्याङ्जा',
    'Parbat': 'पर्वत',
    'Baglung': 'बागलुङ',
    'Mustang': 'मुस्ताङ',
    'Myagdi': 'म्याग्दी',
    'Kaski': 'कास्की',
    'Lamjung': 'लमजुङ',
    'Gorkha': 'गोरखा',
    'Manang': 'मनाङ',
    'Tanahu': 'तनहुँ',
    'Syangja': 'स्याङ्जा',
    'Parbat': 'पर्वत',
    'Baglung': 'बागलुङ',
    'Mustang': 'मुस्ताङ',
    'Dolpa': 'डोल्पा',
    'Mugu': 'मुगु',
    'Humla': 'हुम्ला',
    'Jumla': 'जुम्ला',
    'Kalikot': 'कालिकोट',
    'Jajarkot': 'जाजरकोट',
    'Rukum': 'रुकुम',
    'Salyan': 'सल्यान',
    'Rolpa': 'रोल्पा',
    'Pyuthan': 'प्युठान',
    'Dang': 'दाङ',
    'Banke': 'बाँके',
    'Bardiya': 'बर्दिया',
    'Surkhet': 'सुर्खेत',
    'Dailekh': 'दैलेख',
    'Jajarkot': 'जाजरकोट',
    'Kailali': 'कैलाली',
    'Kanchanpur': 'कञ्चनपुर',
    'Doti': 'डोटी',
    'Achham': 'अछाम',
    'Bajhang': 'बझाङ',
    'Bajura': 'बजुरा',
    'Dadeldhura': 'दैलेखुरा',
    'Kanchanpur': 'कञ्चनपुर',
    'Kailali': 'कैलाली',
    'Baitadi': 'बैतडी',
    'Darchula': 'दार्चुला',
    'Mahakali': 'महाकाली',
    'Sudurpaschim': 'सुदूरपश्चिम',
    'Karnali': 'कर्णाली',
    'Lumbini': 'लुम्बिनी',
    'Gandaki': 'गण्डकी',
    'Bagmati': 'बागमती',
    'Province 1': 'प्रदेश १',
    'Province 2': 'प्रदेश २',
    'Province 3': 'प्रदेश ३',
    'Province 4': 'प्रदेश ४',
    'Province 5': 'प्रदेश ५',
    'Province 6': 'प्रदेश ६',
    'Province 7': 'प्रदेश ७',
  };

  // Currency Formatting
  static String formatNPRCurrency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'en_NP',
      symbol: showSymbol ? _nprSymbol : '',
      decimalDigits: 2,
    );
    
    String formatted = formatter.format(amount);
    
    // Replace NPR with Nepali Rupee symbol if needed
    if (showSymbol && formatted.contains('NPR')) {
      formatted = formatted.replaceAll('NPR', _nprSymbol);
    }
    
    return formatted;
  }
  
  static String formatNPRCompact(double amount) {
    if (amount >= 10000000) {
      return '${_nprSymbol}${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${_nprSymbol}${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${_nprSymbol}${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatNPRCurrency(amount);
    }
  }
  
  // VAT Calculations
  static double calculateVAT(double amount) {
    return amount * _vatRate;
  }
  
  static double calculateAmountWithVAT(double amount) {
    return amount + calculateVAT(amount);
  }
  
  static double extractVATFromTotal(double totalAmount) {
    return totalAmount * (_vatRate / (1 + _vatRate));
  }
  
  static double extractAmountFromTotalWithVAT(double totalAmount) {
    return totalAmount / (1 + _vatRate);
  }
  
  static String formatVATAmount(double amount) {
    return formatNPRCurrency(calculateVAT(amount));
  }
  
  static String formatAmountWithVAT(double amount) {
    return formatNPRCurrency(calculateAmountWithVAT(amount));
  }
  
  // Date and Time Formatting
  static String formatNepaliDate(DateTime date, {bool useNepali = false}) {
    if (useNepali) {
      final englishMonth = DateFormat('MMMM').format(date);
      final nepaliMonth = _nepaliMonths[englishMonth] ?? englishMonth;
      final englishDay = DateFormat('EEEE').format(date);
      final nepaliDay = _nepaliDays[englishDay] ?? englishDay;
      
      return '$nepaliDay, ${date.day} $nepaliMonth ${date.year}';
    } else {
      return DateFormat('dd MMMM yyyy').format(date);
    }
  }
  
  static String formatNepaliDateTime(DateTime date, {bool useNepali = false}) {
    if (useNepali) {
      final englishMonth = _nepaliMonths[DateFormat('MMMM').format(date)] ?? DateFormat('MMMM').format(date);
      final englishDay = _nepaliDays[DateFormat('EEEE').format(date)] ?? DateFormat('EEEE').format(date);
      
      return '$englishDay, ${date.day} $englishMonth ${date.year} • ${DateFormat('hh:mm a').format(date)}';
    } else {
      return DateFormat('dd MMMM yyyy • hh:mm a').format(date);
    }
  }
  
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    }
  }
  
  // Phone Number Formatting
  static String formatNepaliPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Nepal phone numbers are 10 digits
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else if (digits.length == 9) {
      // Some old numbers might be 9 digits
      return '${digits.substring(0, 2)}-${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    
    return phoneNumber; // Return original if format doesn't match
  }
  
  static bool isValidNepaliPhoneNumber(String phoneNumber) {
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Nepal mobile numbers start with 97 or 98 and are 10 digits
    if (digits.length == 10) {
      return digits.startsWith('97') || digits.startsWith('98');
    }
    
    // Some landline numbers might be 9 digits
    if (digits.length == 9) {
      return digits.startsWith('01') || digits.startsWith('02');
    }
    
    return false;
  }
  
  // Address Formatting
  static String formatNepaliAddress({
    required String street,
    required String city,
    required String state,
    required String postalCode,
    String? landmark,
    String? phone,
  }) {
    final nepaliCity = _nepaliRegions[city] ?? city;
    final nepaliState = _nepaliRegions[state] ?? state;
    
    List<String> addressParts = [];
    
    if (street.isNotEmpty) addressParts.add(street);
    if (landmark != null && landmark.isNotEmpty) addressParts.add('Near $landmark');
    if (nepaliCity.isNotEmpty) addressParts.add(nepaliCity);
    if (nepaliState.isNotEmpty) addressParts.add(nepaliState);
    if (postalCode.isNotEmpty) addressParts.add(postalCode);
    if (phone != null && phone.isNotEmpty) {
      addressParts.add('Phone: ${formatNepaliPhoneNumber(phone)}');
    }
    
    return addressParts.join(', ');
  }
  
  static String getNepaliRegionName(String region) {
    return _nepaliRegions[region] ?? region;
  }
  
  // Number Formatting
  static String formatNepaliNumber(int number) {
    // Using Nepali numerals (०, १, २, ३, ४, ५, ६, ७, ८, ९)
    const Map<String, String> nepaliDigits = {
      '0': '०',
      '1': '१',
      '2': '२',
      '3': '३',
      '4': '४',
      '5': '५',
      '6': '६',
      '7': '७',
      '8': '८',
      '9': '९',
    };
    
    String numberStr = number.toString();
    String nepaliNumber = '';
    
    for (int i = 0; i < numberStr.length; i++) {
      nepaliNumber += nepaliDigits[numberStr[i]] ?? numberStr[i];
    }
    
    return nepaliNumber;
  }
  
  // Business Hours Formatting
  static String formatBusinessHours({
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    List<int>? closedDays, // 0 = Monday, 6 = Sunday
  }) {
    final opening = '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}';
    final closing = '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}';
    
    String hours = '$opening - $closing';
    
    if (closedDays != null && closedDays.isNotEmpty) {
      final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final List<String> closedDayNames = closedDays.map((day) => dayNames[day]).toList();
      hours += ' (Closed: ${closedDayNames.join(', ')})';
    }
    
    return hours;
  }
  
  // Distance Formatting
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else if (meters < 100000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    } else {
      return '${(meters / 1000).round()} km';
    }
  }
  
  // Weight Formatting
  static String formatWeight(double grams) {
    if (grams < 1000) {
      return '${grams.round()} g';
    } else if (grams < 1000000) {
      return '${(grams / 1000).toStringAsFixed(2)} kg';
    } else {
      return '${(grams / 1000000).toStringAsFixed(2)} ton';
    }
  }
  
  // Temperature Formatting (Celsius for Nepal)
  static String formatTemperature(double celsius) {
    return '${celsius.toStringAsFixed(1)}°C';
  }
  
  // Getters
  static String get nprSymbol => _nprSymbol;
  static String get nprCode => _nprCode;
  static double get vatRate => _vatRate;
  static double get vatPercentage => _vatRate * 100;
  
  // Validation helpers
  static bool isValidNepaliPostalCode(String postalCode) {
    // Nepal postal codes are 5 digits
    return RegExp(r'^\d{5}$').hasMatch(postalCode);
  }
  
  static bool isValidVATNumber(String vatNumber) {
    // Nepal VAT numbers are typically 9-10 digits
    return RegExp(r'^\d{9,10}$').hasMatch(vatNumber);
  }
  
  static bool isValidPANNumber(String panNumber) {
    // Nepal PAN numbers are 9 digits
    return RegExp(r'^\d{9}$').hasMatch(panNumber);
  }
  
  // Localization helpers
  static String getLocalizedText(String key, Map<String, String> customTranslations) {
    return customTranslations[key] ?? key;
  }
  
  static Map<String, String> getCommonNepaliTranslations() {
    return {
      'Total': 'जम्मा',
      'Subtotal': 'उप-जम्मा',
      'VAT': 'VAT',
      'Discount': 'छुट',
      'Delivery': 'डेलिभरी',
      'Payment': 'भुक्तानी',
      'Order': 'अर्डर',
      'Product': 'उत्पादन',
      'Quantity': 'मात्रा',
      'Price': 'मूल्य',
      'Amount': 'रकम',
      'Date': 'मिति',
      'Time': 'समय',
      'Address': 'ठेगाना',
      'Phone': 'फोन',
      'Email': 'इमेल',
      'Name': 'नाम',
      'Status': 'स्थिति',
      'Active': 'सक्रिय',
      'Inactive': 'निष्क्रिय',
      'Pending': 'प्रतीक्षारत',
      'Completed': 'सम्पन्न',
      'Cancelled': 'रद्द',
      'Confirm': 'पुष्टि गर्नुहोस्',
      'Cancel': 'रद्द गर्नुहोस्',
      'Save': 'बचत गर्नुहोस्',
      'Delete': 'मेटाउनुहोस्',
      'Edit': 'सम्पादन गर्नुहोस्',
      'Add': 'थप्नुहोस्',
      'Remove': 'हटाउनुहोस्',
      'Search': 'खोज्नुहोस्',
      'Filter': 'फिल्टर गर्नुहोस्',
      'Sort': 'क्रमबद्ध गर्नुहोस्',
      'Loading': 'लोड हुँदै',
      'Error': 'त्रुटि',
      'Success': 'सफलता',
      'Warning': 'चेतावनी',
      'Info': 'जानकारी',
      'Close': 'बन्द गर्नुहोस्',
      'OK': 'ठीक छ',
      'Yes': 'हो',
      'No': 'होइन',
      'Next': 'पछिल्लो',
      'Previous': 'अघिल्लो',
      'Submit': 'पेश गर्नुहोस्',
      'Continue': 'जारी राख्नुहोस्',
      'Back': 'पछाडि',
      'Home': 'घर',
      'Profile': 'प्रोफाइल',
      'Settings': 'सेटिङहरू',
      'Logout': 'लगआउट',
      'Login': 'लगइन',
      'Register': 'दर्ता',
      'Forgot Password': 'पासवर्ड बिर्सेको',
      'Reset Password': 'पासवर्ड रिसेट गर्नुहोस्',
      'Change Password': 'पासवर्ड परिवर्तन गर्नुहोस्',
      'Update': 'अपडेट गर्नुहोस्',
      'View': 'हेर्नुहोस्',
      'Download': 'डाउनलोड गर्नुहोस्',
      'Upload': 'अपलोड गर्नुहोस्',
      'Export': 'निर्यात गर्नुहोस्',
      'Import': 'आयात गर्नुहोस्',
      'Print': 'प्रिन्ट गर्नुहोस्',
      'Share': 'साझेदारी गर्नुहोस्',
      'Copy': 'प्रतिलिपि गर्नुहोस्',
      'Paste': 'पेस्ट गर्नुहोस्',
      'Cut': 'काट्नुहोस्',
      'Select All': 'सबै चयन गर्नुहोस्',
      'Clear': 'सबै हटाउनुहोस्',
      'Refresh': 'ताजा पार्नुहोस्',
      'Reload': 'पुन: लोड गर्नुहोस्',
      'Help': 'मद्दत',
      'About': 'बारेमा',
      'Contact': 'सम्पर्क',
      'Support': 'समर्थन',
      'Feedback': 'प्रतिक्रिया',
      'Terms': 'सर्तहरू',
      'Privacy': 'गोपनीयता',
      'Legal': 'कानुनी',
      'Copyright': 'प्रतिलिपि अधिकार',
      'All Rights Reserved': 'सबै अधिकार सुरक्षित',
    };
  }
}
