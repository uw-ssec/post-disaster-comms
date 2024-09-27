import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/logic/cubit/signup_cubit.dart';
import 'package:support_sphere/presentation/components/auth/borders.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupCubit, SignupState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Signup Failure'),
              ),
            );
        }
      },
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FirstNameInput(),
            const SizedBox(height: 8),
            _LastNameInput(),
            const SizedBox(height: 8),
            _UserNameInput(),
            const SizedBox(height: 8),
            _EmailInput(),
            const SizedBox(height: 8),
            _PasswordInput(),
            const SizedBox(height: 8),
            _ConfirmedPasswordInput(),
            const SizedBox(height: 8),
            _SignupCodeInput(),
            const SizedBox(height: 8),
            _SignupButton(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Function to validate the form fields
///
/// Takes in a list of [validators], the input [value],
/// and build [context] containing [SignupCubit] as arguments.
/// It will return the error message if the value is invalid
/// and null if the value is valid.
/// Also, it will set the [SignupState.isValid] flag based on
/// the validity of the value.
String? validateValue(List<FormFieldValidator<String?>> validators,
    String? value, BuildContext context) {
  Function validate = FormBuilderValidators.compose(validators);
  String? validateResult = validate(value);
  if (validateResult != null) {
    context.read<SignupCubit>().setInvalid();
    return validateResult;
  }
  context.read<SignupCubit>().setValid();
  return null;
}

class _FirstNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      buildWhen: (previous, current) =>
          previous.givenName != current.givenName ||
          previous.status != current.status,
      builder: (context, state) {
        return TextFormField(
          key: const Key('signupForm_firstNameInput_textFormField'),
          onChanged: (value) =>
              context.read<SignupCubit>().firstNameChanged(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => validateValue(
            [
              FormBuilderValidators.required(),
              FormBuilderValidators.firstName()
            ],
            value,
            context,
          ),
          decoration: InputDecoration(
            labelText: LoginStrings.givenName,
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
            prefixIcon: Icon(
              Ionicons.person_sharp,
              size: 15.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }
}

class _LastNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      buildWhen: (previous, current) =>
          previous.familyName != current.familyName ||
          previous.status != current.status,
      builder: (context, state) {
        return TextFormField(
          key: const Key('signupForm_lastNameInput_textFormField'),
          onChanged: (value) =>
              context.read<SignupCubit>().lastNameChanged(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => validateValue(
            [
              FormBuilderValidators.required(),
              FormBuilderValidators.lastName()
            ],
            value,
            context,
          ),
          decoration: InputDecoration(
            labelText: LoginStrings.familyName,
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
            prefixIcon: Icon(
              Ionicons.person_sharp,
              size: 15.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }
}

class _UserNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      buildWhen: (previous, current) =>
          previous.userName != current.userName ||
          previous.status != current.status,
      builder: (context, state) {
        return TextFormField(
          key: const Key('signupForm_userNameInput_textFormField'),
          onChanged: (value) =>
              context.read<SignupCubit>().userNameChanged(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => validateValue(
            [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(3),
              FormBuilderValidators.maxLength(32),
              FormBuilderValidators.lowercase(),
              
              /// Validates that the username does not contain any special characters
              (String? val) {
                Function validate = FormBuilderValidators.hasSpecialChars();
                String? validateResult = validate(val);
                if (validateResult != null) {
                  return null;
                }
                return ErrorMessageStrings.mustNotContainSpecialCharacters;
              }
              
            ],
            value,
            context,
          ),
          decoration: InputDecoration(
            labelText: LoginStrings.username,
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
            prefixIcon: Icon(
              Ionicons.happy_sharp,
              size: 15.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      buildWhen: (previous, current) =>
          previous.email != current.email || previous.status != current.status,
      builder: (context, state) {
        return TextFormField(
          enabled: !state.status.isInProgress,
          key: const Key('signupForm_emailInput_textFormField'),
          onChanged: (email) => context.read<SignupCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => validateValue(
            [
              FormBuilderValidators.required(),
              FormBuilderValidators.email(),
            ],
            value,
            context,
          ),
          decoration: InputDecoration(
            labelText: LoginStrings.email,
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
            prefixIcon: Icon(
              Ionicons.mail_outline,
              size: 15.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }
}

class _SignupCodeInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      buildWhen: (previous, current) =>
          previous.signupCode != current.signupCode,
      builder: (context, state) {
        return TextFormField(
          enabled: !state.status.isInProgress,
          key: const Key('signupForm_couponCodeInput_textFormField'),
          onChanged: (value) =>
              context.read<SignupCubit>().signupCodeChanged(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          /// Checks input for Signup code to be length of 7 characters
          /// and uppercase value
          validator: (value) => validateValue(
            [
              FormBuilderValidators.required(),
              FormBuilderValidators.equalLength(7),
              FormBuilderValidators.uppercase(),
            ],
            value,
            context,
          ),
          decoration: InputDecoration(
            labelText: LoginStrings.signUpCode,
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
            prefixIcon: Icon(
              Ionicons.qr_code_outline,
              size: 15.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.showPassword != current.showPassword ||
          previous.status != current.status,
      builder: (context, state) {
        return TextFormField(
          enabled: !state.status.isInProgress,
          key: const Key('signupForm_passwordInput_textFormField'),
          onChanged: (password) =>
              context.read<SignupCubit>().passwordChanged(password),
          obscureText: !state.showPassword,
          autovalidateMode: AutovalidateMode.onUserInteraction,

          /// Checks input for password to have minimum character length of 8
          /// at least 1 uppercase, 1 lowercase, 1 number, and 1 special character
          /// see docs: https://pub.dev/documentation/form_builder_validators/latest/form_builder_validators/PasswordValidator-class.html
          validator: (value) => validateValue(
            [
              FormBuilderValidators.required(),
              FormBuilderValidators.password(
                minLength: 8,
              )
            ],
            value,
            context,
          ),
          decoration: InputDecoration(
            labelText: LoginStrings.password,
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
            prefixIcon: Icon(
              Ionicons.lock_closed_outline,
              size: 15.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                context.read<SignupCubit>().toggleShowPassword();
              },
              child: Icon(
                state.showPassword
                    ? Ionicons.eye_off_outline
                    : Ionicons.eye_outline,
                size: 15.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmedPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      buildWhen: (previous, current) =>
          previous.confirmedPassword != current.confirmedPassword ||
          previous.showPassword != current.showPassword ||
          previous.status != current.status,
      builder: (context, state) {
        return TextFormField(
          enabled: !state.status.isInProgress,
          key: const Key('signupForm_confirmedPasswordInput_textFormField'),
          onChanged: (password) =>
              context.read<SignupCubit>().confirmedPasswordChanged(password),
          obscureText: !state.showPassword,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => validateValue(
            [
              FormBuilderValidators.required(),
              /// Validates that the confirmed password matches
              /// current password input
              (String? val) =>
                  val != state.password ? ErrorMessageStrings.invalidConfirmPassword : null,
            ],
            value,
            context,
          ),
          decoration: InputDecoration(
            labelText: LoginStrings.confirmPassword,
            helperText: '',
            border: border(context),
            enabledBorder: border(context),
            focusedBorder: focusBorder(context),
            prefixIcon: Icon(
              Ionicons.lock_open_outline,
              size: 15.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                context.read<SignupCubit>().toggleShowPassword();
              },
              child: Icon(
                state.showPassword
                    ? Ionicons.eye_off_outline
                    : Ionicons.eye_outline,
                size: 15.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SignupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.isValid
              ? () => context.read<SignupCubit>().signUpWithEmailAndPassword()
              : null,
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
            LoginStrings.signUp,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
