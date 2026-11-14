import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  bool get isArabic => locale.languageCode == 'ar';

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String text(String key) =>
      (isArabic ? _arabic[key] : _english[key]) ?? _english[key] ?? key;

  static const Map<String, String> _english = {
    'farm': 'My farm',
    'analysis': 'Insights',
    'water': 'Water',
    'advisor': 'Advisor',
    'settings': 'Settings',
    'demo': 'DEMO DATA',
    'farmName': 'Green Valley Farm',
    'location': 'Menoufia, Egypt',
    'goodMorning': 'A good day to grow.',
    'fieldStatus': 'FIELD STATUS',
    'calm': 'Your fields are doing well',
    'stress': 'Water stress detected',
    'heat': 'Heat risk is increasing',
    'zones': 'Your landscape',
    'tapZone': 'Tap a field to explore',
    'zoneNorth': 'North plot',
    'zoneOrchard': 'Orchard',
    'zoneSouth': 'South plot',
    'soil': 'Soil moisture',
    'temperature': 'Temperature',
    'humidity': 'Humidity',
    'rain': 'Rain chance',
    'ndvi': 'Vegetation index',
    'cropHealth': 'Crop health',
    'waterUse': 'Water use',
    'weather': 'Today’s climate',
    'weatherNote': 'Warm and dry conditions expected',
    'recommendation': 'A thought for your farm',
    'why': 'Why this matters',
    'action': 'View recommendation',
    'irrigate': 'Plan irrigation',
    'schedule': 'Irrigation plan',
    'nextIrrigation': 'Next suggested watering',
    'tomorrow': 'Tomorrow · 6:00 AM',
    'waterSaved': 'Water-saving opportunity',
    'waterSavedBody': 'Drip irrigation can reduce water use by up to 18%.',
    'startSchedule': 'Mark plan as scheduled',
    'scheduled': 'Irrigation marked as scheduled',
    'analysisTitle': 'A closer look',
    'overview': 'Overview',
    'satellite': 'Satellite',
    'climate': 'Climate',
    'crop': 'Crop health',
    'cropWheat': 'Wheat',
    'cropCitrus': 'Citrus',
    'observations': 'Recent observations',
    'observationNote': 'Simulated observation · 2 days ago',
    'ndviMeaning': 'What is NDVI?',
    'ndviBody':
        'NDVI is a vegetation indicator. These values are simulated for this demo and are not live satellite measurements.',
    'trend': 'Temperature trend',
    'week': 'Past 7 days',
    'risk': 'Field signals',
    'riskHeat': 'Heat stress',
    'riskHeatBody': 'Afternoon temperatures may raise crop water demand.',
    'riskWater': 'Low moisture',
    'riskWaterBody': 'South plot is below its preferred moisture range.',
    'healthy': 'Good condition',
    'demoNotice': 'Illustrative data only — not live NASA data',
    'advisorTitle': 'Your field advisor',
    'advisorIntro': 'Practical ideas, grounded in your farm’s demo conditions.',
    'askAdvisor': 'Ask the agricultural advisor',
    'advisorDemoContext':
        'Farm location is included with your question. Soil, crop-health, and climate readings are DEMO DATA, not live NASA or sensor data.',
    'advisorWelcome':
        'Ask about crops, irrigation, soil, plant health, pests, climate, or productivity.',
    'askAdvisorHint': 'Write your agricultural question…',
    'send': 'Send question',
    'retry': 'Retry',
    'advisorNotConfigured': 'The agricultural advisor is not connected yet.',
    'advisorProxySetupHint':
        'Set ADVISOR_API_URL to your secure Gemini backend proxy and try again.',
    'advisorError':
        'The advisor could not answer. Check your connection and retry.',
    'explain': 'See why',
    'recommendationTitle': 'Prioritize the south plot',
    'recommendationBody':
        'Soil moisture there is 31%, lower than the other zones. A short early-morning drip cycle can ease water stress while avoiding midday evaporation.',
    'recommendationTwo': 'Check leaf edges after the warm afternoon',
    'recommendationTwoBody':
        'The forecast trend is warmer than the weekly average. Look for curling or dry edges before increasing irrigation.',
    'notifications': 'Field notes',
    'allCaughtUp': 'You’re all caught up',
    'notificationOne': 'South plot moisture is low',
    'notificationOneBody':
        '31% moisture detected in the latest simulated reading.',
    'notificationTwo': 'Warm afternoon ahead',
    'notificationTwoBody': 'Highs near 34° may increase crop water demand.',
    'notificationThree': 'Vegetation looks steady',
    'notificationThreeBody': 'Demo NDVI is stable across the north plot.',
    'farmInfo': 'Farm information',
    'farmLocationTitle': 'Farm location',
    'farmLocationIntro':
        'Choose a country and place, then tap the map to set your farm coordinates.',
    'country': 'Country',
    'cityOrRegion': 'City or region',
    'cityOrRegionHint': 'Search for a city or enter a region',
    'searchLocation': 'Search location',
    'searchCountry': 'Search country',
    'pinFarmOnMap': 'Pin your farm on the map',
    'mapTapHint': 'Tap anywhere on the map',
    'latitude': 'Latitude',
    'longitude': 'Longitude',
    'saveFarmLocation': 'Save farm location',
    'changeFarmLocation': 'Change farm location',
    'noLocationResults': 'No matching places found. Try another name.',
    'locationSearchFailed': 'Location search failed:',
    'locationSaveFailed': 'Could not save this location:',
    'locationStorageError': 'Could not load the saved farm location.',
    'farmLocationLabel': 'Farm location',
    'area': 'Farm area',
    'cropType': 'Primary crop',
    'wheat': 'Wheat & citrus',
    'language': 'Language',
    'english': 'English',
    'arabic': 'العربية',
    'appearance': 'Appearance',
    'darkMode': 'Dark theme',
    'dataAndPrivacy': 'Data & transparency',
    'settingsNote':
        'Farm readings are demo data. Your location stays on this device unless you send a question to the configured advisor service.',
    'about': 'About FieldShift AI',
    'aboutBody':
        'A climate adaptation concept for agriculture. Satellite references are simulated; no NASA service is connected.',
    'sectionExplore': 'Explore your farm',
    'seeAll': 'See all',
    'zoneDetail': 'Field details',
    'close': 'Close',
    'soilLabel': 'Soil',
    'growth': 'Growth stage',
    'growing': 'Active growth',
    'updating': 'Updated today',
    'home': 'Home',
    'empty': 'No observations to show yet',
  };

  static const Map<String, String> _arabic = {
    'farm': 'مزرعتي',
    'analysis': 'الرؤى',
    'water': 'المياه',
    'advisor': 'المستشار',
    'settings': 'الإعدادات',
    'demo': 'بيانات تجريبية',
    'farmName': 'مزرعة الوادي الأخضر',
    'location': 'المنوفية، مصر',
    'goodMorning': 'يوم جميل للنمو.',
    'fieldStatus': 'حالة الحقول',
    'calm': 'حقولك بحالة جيدة',
    'stress': 'تم رصد إجهاد مائي',
    'heat': 'مخاطر الحرارة في تزايد',
    'zones': 'مشهد مزرعتك',
    'tapZone': 'اضغط على حقل لاستكشافه',
    'zoneNorth': 'الحقل الشمالي',
    'zoneOrchard': 'البستان',
    'zoneSouth': 'الحقل الجنوبي',
    'soil': 'رطوبة التربة',
    'temperature': 'الحرارة',
    'humidity': 'الرطوبة',
    'rain': 'احتمال المطر',
    'ndvi': 'مؤشر الغطاء النباتي',
    'cropHealth': 'صحة المحصول',
    'waterUse': 'استهلاك المياه',
    'weather': 'مناخ اليوم',
    'weatherNote': 'أجواء دافئة وجافة متوقعة',
    'recommendation': 'فكرة لمزرعتك',
    'why': 'لماذا يهم ذلك',
    'action': 'عرض التوصية',
    'irrigate': 'تخطيط الري',
    'schedule': 'خطة الري',
    'nextIrrigation': 'موعد الري المقترح',
    'tomorrow': 'غدًا · ٦:٠٠ صباحًا',
    'waterSaved': 'فرصة لتوفير المياه',
    'waterSavedBody': 'يمكن للري بالتنقيط خفض استهلاك المياه حتى ١٨٪.',
    'startSchedule': 'تحديد الخطة كمجدولة',
    'scheduled': 'تم تحديد الري كموعد مجدول',
    'analysisTitle': 'نظرة أقرب',
    'overview': 'نظرة عامة',
    'satellite': 'الأقمار الصناعية',
    'climate': 'المناخ',
    'crop': 'صحة المحصول',
    'cropWheat': 'قمح',
    'cropCitrus': 'حمضيات',
    'observations': 'ملاحظات حديثة',
    'observationNote': 'ملاحظة محاكاة · قبل يومين',
    'ndviMeaning': 'ما هو مؤشر NDVI؟',
    'ndviBody':
        'مؤشر NDVI يقيس الغطاء النباتي. هذه القيم محاكاة تجريبية وليست قياسات أقمار صناعية مباشرة.',
    'trend': 'اتجاه الحرارة',
    'week': 'آخر ٧ أيام',
    'risk': 'مؤشرات الحقول',
    'riskHeat': 'إجهاد حراري',
    'riskHeatBody': 'قد ترفع حرارة الظهيرة احتياج المحاصيل للمياه.',
    'riskWater': 'انخفاض الرطوبة',
    'riskWaterBody': 'رطوبة الحقل الجنوبي أقل من النطاق المفضل.',
    'healthy': 'حالة جيدة',
    'demoNotice': 'بيانات توضيحية فقط — ليست بيانات ناسا مباشرة',
    'advisorTitle': 'مستشار الحقل',
    'advisorIntro': 'أفكار عملية مبنية على ظروف المزرعة التجريبية.',
    'askAdvisor': 'اسأل المستشار الزراعي',
    'advisorDemoContext':
        'يُرسل موقع المزرعة مع سؤالك. قراءات التربة وصحة المحصول والمناخ بيانات تجريبية وليست بيانات ناسا أو مستشعرات مباشرة.',
    'advisorWelcome':
        'اسأل عن المحاصيل أو الري أو التربة أو صحة النباتات أو الآفات أو المناخ أو الإنتاجية.',
    'askAdvisorHint': 'اكتب سؤالك الزراعي…',
    'send': 'إرسال السؤال',
    'retry': 'إعادة المحاولة',
    'advisorNotConfigured': 'المستشار الزراعي غير متصل حتى الآن.',
    'advisorProxySetupHint':
        'اضبط ADVISOR_API_URL على عنوان الخادم الوسيط الآمن لـ Gemini ثم أعد المحاولة.',
    'advisorError':
        'تعذّر على المستشار الإجابة. تحقّق من الاتصال وأعد المحاولة.',
    'explain': 'اعرف السبب',
    'recommendationTitle': 'امنح الحقل الجنوبي الأولوية',
    'recommendationBody':
        'رطوبة التربة فيه ٣١٪، وهي أقل من بقية المناطق. دورة ري قصيرة بالتنقيط صباحًا قد تخفف الإجهاد المائي وتحد من التبخر.',
    'recommendationTwo': 'افحص أطراف الأوراق بعد الظهيرة الدافئة',
    'recommendationTwoBody':
        'اتجاه التوقعات أدفأ من متوسط الأسبوع. راقب التفاف الأوراق أو جفاف أطرافها قبل زيادة الري.',
    'notifications': 'ملاحظات الحقول',
    'allCaughtUp': 'لا توجد تنبيهات جديدة',
    'notificationOne': 'رطوبة الحقل الجنوبي منخفضة',
    'notificationOneBody': 'رطوبة ٣١٪ في أحدث قراءة محاكاة.',
    'notificationTwo': 'ظهيرة دافئة قادمة',
    'notificationTwoBody':
        'قد تزيد الحرارة التي تقارب ٣٤° احتياج المحصول للمياه.',
    'notificationThree': 'الغطاء النباتي مستقر',
    'notificationThreeBody': 'قيمة NDVI التجريبية مستقرة في الحقل الشمالي.',
    'farmInfo': 'معلومات المزرعة',
    'farmLocationTitle': 'موقع المزرعة',
    'farmLocationIntro':
        'اختر الدولة والمكان، ثم اضغط على الخريطة لتحديد إحداثيات المزرعة.',
    'country': 'الدولة',
    'cityOrRegion': 'المدينة أو المنطقة',
    'cityOrRegionHint': 'ابحث عن مدينة أو أدخل اسم منطقة',
    'searchLocation': 'بحث عن الموقع',
    'searchCountry': 'ابحث عن دولة',
    'pinFarmOnMap': 'حدّد المزرعة على الخريطة',
    'mapTapHint': 'اضغط في أي مكان على الخريطة',
    'latitude': 'خط العرض',
    'longitude': 'خط الطول',
    'saveFarmLocation': 'حفظ موقع المزرعة',
    'changeFarmLocation': 'تغيير موقع المزرعة',
    'noLocationResults': 'لم يتم العثور على مكان مطابق. جرّب اسمًا آخر.',
    'locationSearchFailed': 'تعذّر البحث عن الموقع:',
    'locationSaveFailed': 'تعذّر حفظ الموقع:',
    'locationStorageError': 'تعذّر تحميل موقع المزرعة المحفوظ.',
    'farmLocationLabel': 'موقع المزرعة',
    'area': 'مساحة المزرعة',
    'cropType': 'المحاصيل الرئيسية',
    'wheat': 'قمح وحمضيات',
    'language': 'اللغة',
    'english': 'English',
    'arabic': 'العربية',
    'appearance': 'المظهر',
    'darkMode': 'الوضع الداكن',
    'dataAndPrivacy': 'البيانات والشفافية',
    'settingsNote':
        'قراءات المزرعة تجريبية. يبقى الموقع على هذا الجهاز ما لم ترسل سؤالًا إلى خدمة المستشار المضبوطة.',
    'about': 'عن FieldShift AI',
    'aboutBody':
        'مفهوم للتكيف الزراعي مع المناخ. بيانات الأقمار الصناعية محاكاة ولا يوجد اتصال بخدمات ناسا.',
    'sectionExplore': 'استكشف مزرعتك',
    'seeAll': 'عرض الكل',
    'zoneDetail': 'تفاصيل الحقل',
    'close': 'إغلاق',
    'soilLabel': 'التربة',
    'growth': 'مرحلة النمو',
    'growing': 'نمو نشط',
    'updating': 'تم التحديث اليوم',
    'home': 'الرئيسية',
    'empty': 'لا توجد ملاحظات لعرضها الآن',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
