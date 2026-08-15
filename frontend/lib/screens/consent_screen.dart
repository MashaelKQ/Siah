import 'package:flutter/material.dart';

import '../data/consent_content.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

// ===========================================================
// Consent Screen
// Shows the privacy rules before an account is created.
//
// Returns true when the user accepts and false otherwise,
// so the Sign Up screen can record the decision.
//
// The Accept button stays disabled until the user reaches the
// end of the text, so consent is given after reading it.
// ===========================================================
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _reachedEnd = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_checkScrollPosition);

    // Short pages have nothing to scroll, so unlock after layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollPosition();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  // ===========================================================
  // Scroll Position
  // Unlocks the Accept button once the text has been read.
  // ===========================================================
  void _checkScrollPosition() {
    if (_reachedEnd) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final isAtEnd = position.pixels >= position.maxScrollExtent - 24;

    if (isAtEnd) {
      setState(() {
        _reachedEnd = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy and Consent'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ===========================================================
            // Policy Text
            // ===========================================================
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.regular),
                children: [
                  const Text(
                    'Before you create an account',
                    style: AppTextStyles.heading1,
                  ),

                  const SizedBox(height: AppSpacing.small),

                  const Text(
                    'Please read how Siah handles what you record.',
                    style: AppTextStyles.body,
                  ),

                  const SizedBox(height: AppSpacing.large),

                  for (final section in consentSections) ...[
                    Text(
                      section.title,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      section.body,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.large),
                  ],

                  Text(
                    'Version $consentVersion',
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),

            // ===========================================================
            // Decision
            // Records whether the user accepts these rules.
            // ===========================================================
            Container(
              padding: const EdgeInsets.all(AppSpacing.regular),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_reachedEnd) ...[
                    const Text(
                      'Scroll to the end to continue.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.small),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _reachedEnd
                          ? () {
                              Navigator.pop(context, true);
                            }
                          : null,
                      child: const Text('I Agree'),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text('Not Now'),
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
