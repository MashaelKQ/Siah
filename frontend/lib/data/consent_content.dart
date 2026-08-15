// ===========================================================
// Consent and Privacy Content
// Stores the wording shown before account creation.
//
// IMPORTANT:
// This wording is a placeholder written to describe how Siah
// currently behaves. Replace it with text approved by your
// institution or legal reviewer before any real user signs up.
//
// When the wording changes in a way users must re-accept,
// raise consentVersion. Existing users can then be asked again.
// ===========================================================

const String consentVersion = '2026-08-01';

class ConsentSection {
  const ConsentSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

const List<ConsentSection> consentSections = [
  ConsentSection(
    title: 'What Siah is',
    body: 'Siah is a self-reflection tool. It helps you record how you feel, '
        'write private journal entries, and notice patterns over time. '
        'It is not a medical device and does not provide diagnosis or '
        'treatment.',
  ),
  ConsentSection(
    title: 'Siah is not emergency support',
    body: 'Siah cannot help in a crisis and no one monitors what you write. '
        'If you are in danger or thinking about harming yourself, contact '
        'your local emergency number or a crisis line right away.',
  ),
  ConsentSection(
    title: 'What we collect',
    body: 'Your name and email address, the moods you record, the journal '
        'entries you write, and your answers to the monthly wellness '
        'questionnaire. We do not collect your contacts, location, or '
        'anything from other apps.',
  ),
  ConsentSection(
    title: 'Where it is stored',
    body: 'Your data is stored in Google Cloud Firestore under your account. '
        'It is sent over an encrypted connection and only your signed-in '
        'account can read it.',
  ),
  ConsentSection(
    title: 'Who can see it',
    body: 'Your journal entries and moods are private to you. We do not sell '
        'your data or share it with advertisers. Anonymised, aggregated '
        'figures may be used to improve the app.',
  ),
  ConsentSection(
    title: 'Your control',
    body: 'You can edit your profile at any time and delete your account from '
        'the Profile screen. Deleting your account permanently removes your '
        'profile, moods, journal entries, and assessments.',
  ),
];
