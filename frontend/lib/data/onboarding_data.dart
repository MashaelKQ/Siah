// ===========================================================
// Onboarding Data
//
// The questions asked once, after an account is created.
//
// Two principles behind these lists:
//
// Every demographic question has a way to decline. Someone who
// does not want to state their gender should not be blocked
// from a wellbeing app over it, and a forced answer is a false
// answer anyway.

// ===========================================================

const String optOut = 'Prefer not to say';

// ===========================================================
// Age
//
// Starts at 18 on purpose. Collecting data from under-18s
// brings parental consent obligations that this app does not
// currently handle. If you need younger users, that is a
// separate consent flow, not another list item here.
// ===========================================================
const List<String> ageRanges = [
  '18–24',
  '25–34',
  '35–44',
  '45–54',
  '55+',
  optOut,
];

const List<String> genderOptions = [
  'Woman',
  'Man',
  optOut,
];

// ===========================================================
// Occupation
// Doubles as useful context and as an input the burnout model
// will want later.
// ===========================================================
const List<String> occupationOptions = [
  'Student',
  'Employed',
  'Self-employed',
  'Between jobs',
  'Other',
  optOut,
];

const List<String> weeklyHoursOptions = [
  'Under 20 hours',
  '20–40 hours',
  '40–50 hours',
  'Over 50 hours',
  optOut,
];

// ===========================================================
// Goals
// What the person wants out of using the app.
// ===========================================================
const List<String> goalOptions = [
  'Understand my moods',
  'Manage stress better',
  'Sleep better',
  'Feel less overwhelmed',
  'Build steadier habits',
  'Be kinder to myself',
  'Notice patterns over time',
  'Make space to reflect',
];

// ===========================================================
// Reasons
// Why they downloaded it now.
// ===========================================================
const List<String> reasonOptions = [
  'Things have been heavy lately',
  'I want to track how I am doing',
  'Someone I trust suggested it',
  'My university or workplace recommended it',
  'A professional suggested it',
  'Something specific happened',
  'Just curious',
];
