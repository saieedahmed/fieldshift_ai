import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/farm_data.dart';
import '../../data/models/nasa_observation.dart';
import '../../data/repositories/agricultural_advisor_service.dart';
import '../../data/repositories/nasa_power_service.dart';
import '../../shared/widgets/landscape_widgets.dart';

class AdvisorPage extends StatefulWidget {
  const AdvisorPage({required this.farm, required this.onOpenWater, super.key});

  final FarmData farm;
  final VoidCallback onOpenWater;

  @override
  State<AdvisorPage> createState() => _AdvisorPageState();
}

class _AdvisorPageState extends State<AdvisorPage> {
  final _questionController = TextEditingController();
  final _advisorService = AgriculturalAdvisorService();
  final _nasaService = NasaPowerService();
  final List<_AdvisorMessage> _messages = [];
  NasaDailyClimate? _nasaClimate;
  bool _showWhy = false;
  bool _showSecondWhy = false;
  bool _isLoading = false;
  bool _isConfigurationError = false;
  String? _errorMessage;
  String? _lastQuestion;
  List<Map<String, String>> _lastHistory = const [];

  @override
  void initState() {
    super.initState();
    _loadClimateData();
  }

  @override
  void didUpdateWidget(AdvisorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.farm.location.latitude != widget.farm.location.latitude ||
        oldWidget.farm.location.longitude != widget.farm.location.longitude) {
      _loadClimateData();
    }
  }

  Future<void> _loadClimateData() async {
    try {
      final climate = await _nasaService.fetchDailyClimate(
        latitude: widget.farm.location.latitude,
        longitude: widget.farm.location.longitude,
      );
      if (mounted) {
        setState(() => _nasaClimate = climate);
      }
    } catch (e) {
      debugPrint('AdvisorPage: NASA climate fetch error: $e');
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _advisorService.close();
    _nasaService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Text(
          strings.text('advisorTitle'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          strings.text('advisorIntro'),
          style: TextStyle(color: AppTheme.mutedInk),
        ),
        const SizedBox(height: 17),
        const _AdvisorBanner(),
        const SizedBox(height: 16),
        _ConversationCard(
          controller: _questionController,
          messages: _messages,
          farmLocation: widget.farm.location.displayName(
            isArabic: strings.isArabic,
          ),
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          isConfigurationError: _isConfigurationError,
          hasNasaClimate: _nasaClimate != null && _nasaClimate!.hasValidData,
          onSend: _sendMessage,
          onRetry: _retry,
        ),
        const SizedBox(height: 16),
        _AdviceCard(
          title: strings.text('recommendationTitle'),
          body: strings.text('recommendationBody'),
          icon: Icons.water_drop_outlined,
          isExpanded: _showWhy,
          onExplain: () => setState(() => _showWhy = !_showWhy),
          onAction: widget.onOpenWater,
        ),
        const SizedBox(height: 12),
        _AdviceCard(
          title: strings.text('recommendationTwo'),
          body: strings.text('recommendationTwoBody'),
          icon: Icons.spa_outlined,
          isExpanded: _showSecondWhy,
          onExplain: () => setState(() => _showSecondWhy = !_showSecondWhy),
          onAction: widget.onOpenWater,
        ),
        const SizedBox(height: 16),
        Text(
          strings.text('demoNotice'),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.mutedInk),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _isLoading) return;
    final history = _messages
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'model',
            'text': message.text,
          },
        )
        .toList(growable: false);
    _questionController.clear();
    await _ask(question, history);
  }

  Future<void> _retry() async {
    final question = _lastQuestion;
    if (question == null || _isLoading) return;
    await _ask(question, _lastHistory, appendQuestion: false);
  }

  Future<void> _ask(
    String question,
    List<Map<String, String>> history, {
    bool appendQuestion = true,
  }) async {
    setState(() {
      if (appendQuestion) {
        _messages.add(_AdvisorMessage(isUser: true, text: question));
      }
      _isLoading = true;
      _errorMessage = null;
      _lastQuestion = question;
      _lastHistory = history;
    });
    try {
      final reply = await _advisorService.ask(
        question: question,
        languageCode: AppLocalizations.of(context).isArabic ? 'ar' : 'en',
        farm: widget.farm,
        history: history,
        nasaClimate: _nasaClimate,
      );
      if (!mounted) return;
      setState(
        () => _messages.add(_AdvisorMessage(isUser: false, text: reply)),
      );
    } on AdvisorConfigurationException {
      if (!mounted) return;
      setState(() {
        _isConfigurationError = true;
        _errorMessage = AppLocalizations.of(
          context,
        ).text('advisorNotConfigured');
      });
    } on AdvisorServiceException catch (error) {
      debugPrint('Agricultural advisor service error: $error');
      if (!mounted) return;
      setState(() {
        _isConfigurationError = false;
        _errorMessage = error.message;
      });
    } catch (error) {
      debugPrint('Agricultural advisor request failed: $error');
      if (!mounted) return;
      setState(() {
        _isConfigurationError = false;
        _errorMessage = AppLocalizations.of(context).text('advisorError');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _AdvisorMessage {
  const _AdvisorMessage({required this.isUser, required this.text});

  final bool isUser;
  final String text;
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.controller,
    required this.messages,
    required this.farmLocation,
    required this.isLoading,
    required this.errorMessage,
    required this.isConfigurationError,
    required this.onSend,
    required this.onRetry,
    this.hasNasaClimate = false,
  });

  final TextEditingController controller;
  final List<_AdvisorMessage> messages;
  final String farmLocation;
  final bool isLoading;
  final String? errorMessage;
  final bool isConfigurationError;
  final bool hasNasaClimate;
  final VoidCallback onSend;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppTheme.paleSage),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, color: AppTheme.forest),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  strings.text('askAdvisor'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (hasNasaClimate) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.paleSage,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.public, size: 12, color: AppTheme.forest),
                      SizedBox(width: 4),
                      Text(
                        'NASA POWER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.forest,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const DemoBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            strings.text('advisorDemoContext'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedInk,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${strings.text('farmLocationLabel')}: $farmLocation',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.forest,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (messages.isEmpty) ...[
            const SizedBox(height: 14),
            Text(
              strings.text('advisorWelcome'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          for (final message in messages) ...[
            const SizedBox(height: 10),
            Align(
              alignment: message.isUser
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 290),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: message.isUser ? AppTheme.forest : AppTheme.paleSage,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : AppTheme.ink,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
          if (isLoading) ...[
            const SizedBox(height: 12),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(errorMessage!),
                  if (isConfigurationError) ...[
                    const SizedBox(height: 5),
                    Text(
                      strings.text('advisorProxySetupHint'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(strings.text('retry')),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: strings.text('askAdvisorHint'),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                tooltip: strings.text('send'),
                onPressed: isLoading ? null : onSend,
                icon: const Icon(Icons.send_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorBanner extends StatelessWidget {
  const _AdvisorBanner();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppTheme.paleSage,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.forest,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.text('fieldStatus'),
                  style: const TextStyle(
                    color: AppTheme.forest,
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.text('stress'),
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.isExpanded,
    required this.onExplain,
    required this.onAction,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onExplain;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.forest),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: AppTheme.mutedInk,
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '${strings.text('why')}: $body',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: AppTheme.forest,
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: onExplain,
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.info_outline,
                  size: 18,
                ),
                label: Text(strings.text('explain')),
              ),
              const Spacer(),
              TextButton(
                onPressed: onAction,
                child: Text(strings.text('irrigate')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
