import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _journalController = TextEditingController();

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Today's journal entry has been saved."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===========================================================
      // App Bar
      // Displays the standard title for the Journal screen.
      // ===========================================================
      appBar: AppBar(
        title: const Text('Journal'),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================================================
              // Journal Header
              // Displays today's reflection title and access to all entries.
              // ===========================================================
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Today's Reflection",
                      style: AppTextStyles.heading1,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Open all journal entries.
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xSmall),

              const Text(
                'Thursday, July 31',
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: AppSpacing.medium),

              const Text(
                'Write about your thoughts, feelings, or anything that stood out today.',
                style: AppTextStyles.body,
              ),

              const SizedBox(height: AppSpacing.medium),

              // ===========================================================
              // Journal Entry
              // Provides the writing area for today's reflection.
              // ===========================================================
              Expanded(
                child: TextField(
                  controller: _journalController,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Start writing here...',
                    alignLabelWithHint: true,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // ===========================================================
              // Save Action
              // Saves today's journal entry.
              // ===========================================================
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveEntry,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("Save Today's Entry"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
