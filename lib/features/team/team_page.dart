import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/team_member.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isArabic = strings.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('teamTitle')),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            children: [
              _HeaderBanner(isArabic: isArabic, isDark: isDark),
              const SizedBox(height: 20),
              if (isWide)
                _buildWideGrid(context, isArabic, isDark)
              else
                _buildNarrowList(context, isArabic, isDark),
              const SizedBox(height: 24),
              _FooterNote(isArabic: isArabic),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNarrowList(
    BuildContext context,
    bool isArabic,
    bool isDark,
  ) {
    return Column(
      children: [
        for (final member in fieldShiftTeam) ...[
          _TeamMemberCard(
            member: member,
            isArabic: isArabic,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildWideGrid(
    BuildContext context,
    bool isArabic,
    bool isDark,
  ) {
    final col1 = <Widget>[];
    final col2 = <Widget>[];
    for (var i = 0; i < fieldShiftTeam.length; i++) {
      final card = Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _TeamMemberCard(
          member: fieldShiftTeam[i],
          isArabic: isArabic,
          isDark: isDark,
        ),
      );
      if (i.isEven) {
        col1.add(card);
      } else {
        col2.add(card);
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: col1)),
        const SizedBox(width: 14),
        Expanded(child: Column(children: col2)),
      ],
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({required this.isArabic, required this.isDark});

  final bool isArabic;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251E) : AppTheme.paleSage,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2B4235)
              : AppTheme.sage.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.forest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      strings.text('nasaChallengeBadge'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            strings.text('teamSubtitle'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.text('teamMission'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFFB4C7BA) : AppTheme.ink,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({
    required this.member,
    required this.isArabic,
    required this.isDark,
  });

  final TeamMember member;
  final bool isArabic;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final cardColor = isDark ? const Color(0xFF1C2922) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF26382E)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.forest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forest.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  member.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.localizedName(isArabic),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF263A2E)
                            : AppTheme.paleSage,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.localizedRole(isArabic),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.forest,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                member.icon,
                color: isDark ? AppTheme.sage : AppTheme.mutedInk,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            strings.text('contributionLabel').toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.mutedInk,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            member.localizedContribution(isArabic),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? const Color(0xFFD3DDD5) : AppTheme.ink,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in member.tags)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF213027)
                        : const Color(0xFFF0F4EC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C4033)
                          : AppTheme.sage.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFA6C5AF) : AppTheme.forest,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      alignment: Alignment.center,
      child: Text(
        isArabic
            ? 'FieldShift AI · مشروع لتحدي ناسا لتطبيقات الفضاء 2026 🌱'
            : 'FieldShift AI · NASA Space Apps Challenge 2026 Project 🌱',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.mutedInk,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
