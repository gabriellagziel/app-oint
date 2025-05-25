import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: PageView(
        children: [
          Center(child: Text(t.onboarding_welcome_title)),
          Center(child: Text(t.onboarding_meeting_easy)),
          Center(child: Text(t.onboarding_ready)),
        ],
      ),
    );
  }
} 