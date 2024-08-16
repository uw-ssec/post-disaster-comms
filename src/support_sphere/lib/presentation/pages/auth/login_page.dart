import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/constants/routes.dart';
import 'package:support_sphere/presentation/components/icon_logo.dart';
import 'package:support_sphere/presentation/components/auth/text_form_builder.dart';
import 'package:support_sphere/presentation/components/auth/password_form_builder.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          body: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 5),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                  },
                  child: const IconLogo(),
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Text(
                    LoginStrings.loginIntoExisting,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                buildForm(context),
                const SizedBox(height: 10.0),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text(LoginStrings.dontHaveAnAccount),
                  const SizedBox(width: 5.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.register);
                    },
                    child: Text(
                      LoginStrings.signUp,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ]),
              ]),
        ));
  }

  buildForm(BuildContext context) {
    return Form(
        child: Column(
      children: [
        const TextFormBuilder(
          enabled: true,
          prefix: Ionicons.mail_outline,
          hintText: "Email",
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10.0),
        const PasswordFormBuilder(
          enabled: true,
          prefix: Ionicons.lock_closed_outline,
          suffix: Ionicons.eye_outline,
          hintText: "Password",
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      print("Forgot password clicked");
                    },
                    child: const Text(
                      LoginStrings.forgotPassword,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          height: 45.0,
          width: 180.0,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
              backgroundColor: WidgetStateProperty.all<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            // highlightElevation: 4.0,
            child: const Text(
              LoginStrings.login,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => {print("Login submitted")},
          ),
        ),
      ],
    ));
  }

}