import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_voice_chat_using_agora/app/onboarding/onboarding_view_model.dart';

class OnboardingScreen extends StatelessWidget {
  Future<void> onGetStarted(BuildContext context) async {
    final onboardingViewModel = context.read(onboardingViewModelProvider);
    await onboardingViewModel.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Voice chat app\nOnboarding contents come here.',
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0,),
            ElevatedButton(
              onPressed: () => onGetStarted(context),
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                )
              ), // hei
              child: Text(
                'Get Started',
                style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
