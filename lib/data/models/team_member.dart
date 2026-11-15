import 'package:flutter/material.dart';

class TeamMember {
  const TeamMember({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.roleAr,
    required this.roleEn,
    required this.contributionAr,
    required this.contributionEn,
    required this.initials,
    required this.tags,
    required this.icon,
    this.linkedinUrl,
    this.githubUrl,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String roleAr;
  final String roleEn;
  final String contributionAr;
  final String contributionEn;
  final String initials;
  final List<String> tags;
  final IconData icon;
  final String? linkedinUrl;
  final String? githubUrl;

  String localizedName(bool isArabic) => isArabic ? nameAr : nameEn;
  String localizedRole(bool isArabic) => isArabic ? roleAr : roleEn;
  String localizedContribution(bool isArabic) =>
      isArabic ? contributionAr : contributionEn;
}

const List<TeamMember> fieldShiftTeam = [
  TeamMember(
    id: 'mostafa_neber',
    nameAr: 'مصطفى نيبر',
    nameEn: 'Mostafa Neber',
    roleAr: 'قائد المشروع والباحث الرئيسي',
    roleEn: 'Project Lead & Researcher',
    contributionAr:
        'تخطيط وإدارة المشروع، البحث العلمي الزراعي، وتنسيق جهود الفريق وتطوير الرؤية الاستراتيجية للحل.',
    contributionEn:
        'Project planning, agronomic research, coordinating cross-functional development, and driving the strategic mission.',
    initials: 'MN',
    tags: ['Project Management', 'Agro-Research', 'Strategy'],
    icon: Icons.psychology_outlined,
  ),
  TeamMember(
    id: 'seif_maher',
    nameAr: 'سيف ماهر',
    nameEn: 'Seif Maher',
    roleAr: 'مطور تطبيقات فلاتر',
    roleEn: 'Flutter Developer',
    contributionAr:
        'تطوير تطبيق الموبايل، وبناء واجهات المستخدم المتجاوبة، وضبط الهوية البصرية الحية (Living Landscape).',
    contributionEn:
        'Developing the Flutter mobile application, engineering responsive UI architectures, and crafting the Living Landscape theme.',
    initials: 'SM',
    tags: ['Flutter', 'Dart', 'Mobile Architecture', 'UI/UX'],
    icon: Icons.phone_android_outlined,
  ),
  TeamMember(
    id: 'yassin_mahmoud',
    nameAr: 'ياسين محمود',
    nameEn: 'Yassin Mahmoud',
    roleAr: 'مطور الذكاء الاصطناعي',
    roleEn: 'AI Developer',
    contributionAr:
        'ربط وتكامل خدمات الذكاء الاصطناعي، وتطوير خوارزميات المستشار الزراعي الذكي عبر Gemini API وخادم الـ Backend.',
    contributionEn:
        'Integrating AI services, developing the agricultural advisor engine via Gemini API, and implementing proxy resilience.',
    initials: 'YM',
    tags: ['Gemini AI', 'Node.js', 'AI Advisor', 'Backend'],
    icon: Icons.auto_awesome_outlined,
  ),
  TeamMember(
    id: 'esraa_mohamed',
    nameAr: 'إسراء محمد',
    nameEn: 'Esraa Mohamed',
    roleAr: 'محللة بيانات',
    roleEn: 'Data Analyst',
    contributionAr:
        'تحليل البيانات الزراعية والمناخية، وتفسير مؤشرات التربة والغطاء النباتي لدعم اتخاذ القرارات الذكية.',
    contributionEn:
        'Analyzing agricultural and climatic datasets, interpreting NDVI vegetation and soil moisture for decision support.',
    initials: 'EM',
    tags: ['Data Analysis', 'Agroclimatology', 'NDVI Metrics', 'Decision Support'],
    icon: Icons.analytics_outlined,
  ),
  TeamMember(
    id: 'layan_mohamed',
    nameAr: 'ليان محمد',
    nameEn: 'Layan Mohamed',
    roleAr: 'مصممة تجربة وواجهة المستخدم',
    roleEn: 'UI/UX Designer',
    contributionAr:
        'تصميم تجربة المستخدم وتسهيل الوصول، وهندسة المشهد التفاعلي (Living Farm Landscape) للواجهة.',
    contributionEn:
        'Designing the user experience, enhancing visual accessibility, and orchestrating the interactive farm landscape.',
    initials: 'LM',
    tags: ['UI/UX Design', 'Design System', 'Accessibility', 'Figma'],
    icon: Icons.palette_outlined,
  ),
  TeamMember(
    id: 'mohamed_ahmed',
    nameAr: 'محمد أحمد',
    nameEn: 'Mohamed Ahmed',
    roleAr: 'باحث بيانات ناسا',
    roleEn: 'NASA Data Researcher',
    contributionAr:
        'العمل على بيانات مراقبة الأرض و NASA POWER API، واستكشاف وتطويع تطبيقاتها في الزراعة الدقيقة.',
    contributionEn:
        'Working with NASA Earth observation data and NASA POWER APIs, exploring and validating precision agriculture applications.',
    initials: 'MA',
    tags: ['NASA POWER', 'Earth Observation', 'Satellite Data', 'Climate Science'],
    icon: Icons.public_outlined,
  ),
];
