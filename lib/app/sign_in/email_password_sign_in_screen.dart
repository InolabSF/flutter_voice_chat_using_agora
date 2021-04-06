
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/app/sign_in/email_password_sign_in_model.dart';
import 'package:flutter_voice_chat_using_agora/app/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_voice_chat_using_agora/widgets/form_submit_button.dart';
import 'dart:math';

class EmailPasswordSignInScreen extends StatefulWidget {
  const EmailPasswordSignInScreen(
      {Key key, @required this.model, this.onSignedIn})
      : super(key: key);
  final EmailPasswordSignInModel model;
  final VoidCallback onSignedIn;

  factory EmailPasswordSignInScreen.withFirebase(
    FirebaseAuth firebaseAuth,
    { @required VoidCallback onSignedIn }
  ) {
    return EmailPasswordSignInScreen(
      model: EmailPasswordSignInModel(firebaseAuth: firebaseAuth),
      onSignedIn: onSignedIn,
    );
  }

  @override
  _EmailPasswordSignInScreenState createState() =>
      _EmailPasswordSignInScreenState();
}

class _EmailPasswordSignInScreenState extends State<EmailPasswordSignInScreen> {
  final FocusScopeNode _node = FocusScopeNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  EmailPasswordSignInModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    // Temporary workaround to update state until a replacement for ChangeNotifierProvider is found
    model.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    model.dispose();
    _node.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSignInError(EmailPasswordSignInModel model, dynamic exception) {
    Utils.showExceptionAlertDialog(
      context: context,
      title: model.errorAlertTitle,
      message: exception.toString(),
    );
  }

  Future<void> _submit() async {
    try {
      final bool success = await model.submit();
      if (success) {
        if (model.formType == EmailPasswordSignInFormType.forgotPassword) {
          await Utils.showAlertDialog(
            context: context,
            title: EmailPasswordSignInStrings.resetLinkSentTitle,
            content: EmailPasswordSignInStrings.resetLinkSentMessage,
            defaultActionText: EmailPasswordSignInStrings.ok,
          );
        } else {
          if (widget.onSignedIn != null) {
            widget.onSignedIn();
          }
        }
      }
    } catch (e) {
      _showSignInError(model, e);
    }
  }

  void _emailEditingComplete() {
    if (model.canSubmitEmail) {
      _node.nextFocus();
    }
  }

  void _passwordEditingComplete() {
    if (!model.canSubmitEmail) {
      _node.previousFocus();
      return;
    }
    _submit();
  }

  void _updateFormType(EmailPasswordSignInFormType formType) {
    model.updateFormType(formType);
    _emailController.clear();
    _passwordController.clear();
  }

  Widget _buildEmailField() {
    return TextFormField(
      key: const Key('email'),
      controller: _emailController,
      decoration: InputDecoration(
        labelText: EmailPasswordSignInStrings.emailLabel,
        hintText: EmailPasswordSignInStrings.emailHint,
        errorText: model.emailErrorText,
        enabled: !model.isLoading,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _emailEditingComplete,
      inputFormatters: <TextInputFormatter>[
        model.emailInputFormatter,
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      key: const Key('password'),
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: model.passwordLabelText,
        errorText: model.passwordErrorText,
        enabled: !model.isLoading,
      ),
      obscureText: true,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _passwordEditingComplete,
    );
  }

  Widget _buildContent() {
    return FocusScope(
      node: _node,
      child: Form(
        onChanged: () => model.updateWith(
            email: _emailController.text, password: _passwordController.text),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 8.0),
            _buildEmailField(),
            if (model.formType != EmailPasswordSignInFormType.forgotPassword) ...<Widget>[
              const SizedBox(height: 8.0),
              _buildPasswordField(),
            ],
            const SizedBox(height: 8.0),
            FormSubmitButton(
              key: const Key('primary-button'),
              text: model.primaryButtonText,
              initialLoading: model.isLoading,
              onPressed: model.isLoading ? null : _submit,
            ),
            const SizedBox(height: 8.0),
            TextButton(
              key: const Key('secondary-button'),
              child: Text(model.secondaryButtonText),
              onPressed: model.isLoading
                  ? null
                  : () => _updateFormType(model.secondaryActionFormType),
            ),
            if (model.formType == EmailPasswordSignInFormType.signIn)
              TextButton(
                key: const Key('tertiary-button'),
                child: const Text(
                    EmailPasswordSignInStrings.forgotPasswordQuestion),
                onPressed: model.isLoading
                    ? null
                    : () => _updateFormType(
                    EmailPasswordSignInFormType.forgotPassword),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(model.title),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            return Container(
              width: min(constraints.maxWidth, 600),
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
