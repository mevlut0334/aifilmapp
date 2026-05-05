import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String countryCode,
    required String phone,
  });

  Future<Result<void>> logout();

  Future<Result<void>> forgotPassword({required String email});

  Future<Result<void>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Result<UserEntity>> getProfile();
}