import 'dart:math';

import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final Provider = MockAuthProvider();

    test('should not be initialized', () {
      expect(Provider.isInitialized, false);
    });

    test('user log out function', () {
      expect(
        () => Provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('should be able to initialize', () async {
      await Provider.initialize();
      expect(Provider.isInitialized, true);
    });

    test('should user be null after initialization', () {
      expect(Provider.currentUser, null);
    });

    test('should be able to initialize within 2 seconds', () async {
      await Provider.initialize();
      expect(Provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('create user delegated not log in', () async {
      // Test with invalid email
      expect(
        () async => await Provider.creatUser(email: 'foobar@.com', password: 'anypassword'),
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      // Test with invalid password
      expect(
        () async => await Provider.creatUser(email: 'anybar@.com', password: 'foobar'),
        throwsA(const TypeMatcher<InvaliCredentialAuthException>()),
      );

      // Create a valid user
      final user = await Provider.creatUser(email: 'foo', password: 'bar');
      expect(Provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('should verify user email', () async {
      await Provider.sendEmailVerification();
      final user = Provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('should log out and log in again', () async {
      await Provider.logOut();
      await Provider.logIn(email: 'email', password: 'password');
      final user = Provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> creatUser({required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == "foobar@.com") throw UserNotFoundAuthException();
    if (password == "foobar") throw InvaliCredentialAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
