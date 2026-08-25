import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors from the Siah design
  static const Color green100 = Color(0xFF5ABC5B);
  static const Color blue100 = Color(0xFF58B2E2);
  static const Color yellow100 = Color(0xFFFEC72F);

  // Lighter brand shades
  static const Color green60 = Color(0xFF8BD18C);
  static const Color green40 = Color(0xFFB9E5BA);

  static const Color blue60 = Color(0xFF8CCCEC);
  static const Color blue40 = Color(0xFFBCE2F4);

  static const Color yellow60 = Color(0xFFFFD96D);
  static const Color yellow40 = Color(0xFFFFE9AC);

  // ===========================================================
  // Neutrals
  // The page is a cool blue-white rather than a warm cream, so
  // white cards read as lifted rather than as the same surface.
  // ===========================================================
  static const Color background = Color(0xFFF2F7FD);
  static const Color surface = Colors.white;

  // A blue-tinted fill for inputs and quiet panels. Sits between
  // the page and a white card, which is what removes the need
  // for borders.
  static const Color surfaceMuted = Color(0xFFE9F1FA);

  static const Color textPrimary = Color(0xFF16212E);
  static const Color textSecondary = Color(0xFF64748B);

  // Hairline, tinted blue so it disappears into the page.
  static const Color border = Color(0xFFE2EAF3);

  // Status colors
  static const Color success = green100;
  static const Color warning = yellow100;
  static const Color error = Color(0xFFD92D20);
}



// ===========================================================
// App Gradients
// The green-to-blue blend that carries the Siah identity.
//
// One direction throughout: top-left to bottom-right. Mixing
// directions across a screen is what makes gradients look
// accidental rather than designed.
// ===========================================================
class AppGradients {
  AppGradients._();

  // ===========================================================
  // Brand
  // Full strength. For the one element on a screen that leads.
  // ===========================================================
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.green100,
      AppColors.blue100,
    ],
  );

  // ===========================================================
  // Soft
  // The same blend at low saturation, for surfaces that sit
  // behind dark text.
  // ===========================================================
  static const LinearGradient soft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.green40,
      AppColors.blue40,
    ],
  );

  // ===========================================================
  // Sky
  // The page wash: a blue tint at the top fading into the
  // background. Gives depth without a visible edge.
  // ===========================================================
  static const LinearGradient sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE3EFFB),
      AppColors.background,
    ],
  );
}

// ===========================================================
// App Shadows
// Blue-tinted rather than black, so lifted surfaces match the
// page instead of greying it.
// ===========================================================
class AppShadows {
  AppShadows._();

  // Resting cards.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F1E3A5F),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // Anything that should read as hovering above the page:
  // floating buttons, the nav bar, the header.
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1A1E3A5F),
      blurRadius: 32,
      offset: Offset(0, 14),
    ),
    BoxShadow(
      color: Color(0x0A1E3A5F),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Coloured glow under a gradient button, so it looks lit
  // rather than merely raised.
  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.35),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ];
  }
}

// ===========================================================
// App Radii
// Pills for controls, generous rounding for surfaces.
// ===========================================================
class AppRadius {
  AppRadius._();

  static const double small = 16;
  static const double medium = 24;
  static const double large = 32;
  static const double pill = 999;
}
