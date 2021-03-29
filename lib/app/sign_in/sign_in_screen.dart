import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/app/sign_in/sign_in_button.dart';
import 'package:flutter_voice_chat_using_agora/app/sign_in/sign_in_view_model.dart';
import 'package:flutter_voice_chat_using_agora/app/top_level_providers.dart';
import 'package:flutter_voice_chat_using_agora/app/utils/utils.dart';
import 'package:flutter_voice_chat_using_agora/constants/keys.dart';
import 'package:flutter_voice_chat_using_agora/constants/strings.dart';
import 'package:flutter_voice_chat_using_agora/routing/app_routes.dart';

final signInModelProvider = ChangeNotifierProvider<SignInViewModel>(
  (ref) => SignInViewModel(auth: ref.watch(firebaseAuthProvider)),
);

class SignInScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final signInModel = watch(signInModelProvider);
    return ProviderListener<SignInViewModel>(
      provider: signInModelProvider,
      onChange: (context, model) async {
        if (model.error != null) {
          Utils.showExceptionAlertDialog(
            context: context,
            title: 'Sign in error',
            message: model.error,
          );
        }
      },
      child: SignInScreenContents(
        viewModel: signInModel,
        title: Strings.appName,
      ),
    );
  }
}

class SignInScreenContents extends StatelessWidget {
  const SignInScreenContents(
      {Key key, this.viewModel, this.title = 'Architecture Demo'})
      : super(key: key);
  final SignInViewModel viewModel;
  final String title;

  static const Key emailPasswordButtonKey = Key(Keys.emailPassword);

  Future<void> _showEmailPasswordSignInPage(BuildContext context) async {
    final navigator = Navigator.of(context);
    await navigator.pushNamed(
      AppRoutes.emailPasswordSignInScreen,
      arguments: () => navigator.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(title),
      ),
      backgroundColor: Colors.grey[200],
      body: _buildSignIn(context),
    );
  }

  Widget _buildHeader() {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return const Text(
      'Sign in',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: min(constraints.maxWidth, 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 32.0),
              SizedBox(
                height: 50.0,
                child: _buildHeader(),
              ),
              const SizedBox(height: 32.0),
              SignInButton(
                key: emailPasswordButtonKey,
                text: 'Use email and password',
                onPressed: viewModel.isLoading
                    ? null
                    : () => _showEmailPasswordSignInPage(context),
              )
            ],
          ),
        );
      }),
    );
  }
}
