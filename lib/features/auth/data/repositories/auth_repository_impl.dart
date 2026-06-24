import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final SecureStorageService _secureStorage;

  const AuthRepositoryImpl(this._datasource, this._secureStorage);

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _datasource.login(email: email, password: password);
      await _secureStorage.saveToken(response.token);
      final profile = await _datasource.getProfile();
      return Success(profile.toEntity());
    } on UnauthorizedException catch (e) {
      return Failure(e.message, statusCode: 401);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String countryCode,
    required String phone,
  }) async {
    try {
      // 1. Kayıt ol
      await _datasource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        countryCode: countryCode,
        phone: phone,
      );

      // 2. Kayıt başarılı → aynı bilgilerle login yap
      final loginResponse = await _datasource.login(
        email: email,
        password: password,
      );
      await _secureStorage.saveToken(loginResponse.token);
      final profile = await _datasource.getProfile();
      return Success(profile.toEntity());

    } on UnauthorizedException catch (e) {
      return Failure(e.message, statusCode: 401);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _datasource.logout();
      await _secureStorage.clearAll();
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _datasource.deleteAccount();
      await _secureStorage.clearAll();
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> forgotPassword({required String email}) async {
    try {
      await _datasource.forgotPassword(email: email);
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _datasource.resetPassword(
        token: token,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<UserEntity>> getProfile() async {
    try {
      final user = await _datasource.getProfile();
      return Success(user.toEntity());
    } on UnauthorizedException catch (e) {
      return Failure(e.message, statusCode: 401);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}