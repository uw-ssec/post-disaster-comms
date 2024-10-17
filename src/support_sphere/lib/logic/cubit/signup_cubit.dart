import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/repositories/authentication.dart';
import 'package:formz/formz.dart';
import 'package:support_sphere/data/repositories/user.dart';
import 'package:support_sphere/logic/cubit/utils.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._authenticationRepository, this._userRepository) : super(const SignupState());

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;

  void firstNameChanged(String value) {
    emit(
      state.copyWith(
        givenName: value,
        isAllFieldsFilled: state.copyWith(givenName: value).checkAllFieldsFilled(),
      ),
    );
  }

  void lastNameChanged(String value) {
    emit(
      state.copyWith(
        familyName: value,
        isAllFieldsFilled: state.copyWith(familyName: value).checkAllFieldsFilled(),
      ),
    );
  }

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        isAllFieldsFilled: state.copyWith(email: value).checkAllFieldsFilled(),
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
        isAllFieldsFilled: state.copyWith(password: value).checkAllFieldsFilled(),
      ),
    );
  }

  void signupCodeChanged(String value) {
    emit(
      state.copyWith(
        signupCode: value,
        isAllFieldsFilled: state.copyWith(signupCode: value).checkAllFieldsFilled(),
      ),
    );
  }

  void confirmedPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmedPassword: value,
        isAllFieldsFilled: state.copyWith(confirmedPassword: value).checkAllFieldsFilled(),
      ),
    );
  }

  void toggleShowPassword() => changeShowPassword(emit, state);
  void setValid() => emit(state.copyWith(isValid: true));
  void setInvalid() => emit(state.copyWith(isValid: false));

  /// Sign up with email and password.
  Future<void> signUpWithEmailAndPassword() async {
    // If the form is invalid, do nothing
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      // TODO: Add coupon code check for signup
      final response = await _authenticationRepository.signUp(
        email: state.email,
        password: state.password,
        signupCode: state.signupCode,
      );
      User? user = response.user;
      if (user == null) {
        // If for some reason the user is null, we should set form status to failure
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
        return;
      }

      // Once we have an authenticated user, we can create the user profile and person
      await _userRepository.createNewUser(
        user: user,
        givenName: state.givenName,
        familyName: state.familyName,
      );

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
