import 'package:flutter/foundation.dart';

import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../models/user.dart';

/// Who is logged in. Knows the repository, not the widgets.
class SessionNotifier extends ChangeNotifier {
  SessionNotifier(this._auth); // injected, not created here

  final AuthRepository _auth;

  Session? session;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => session != null;
  AppUser? get user => session?.user;

  Future<void> login(String email, String password) =>
      _start(() => _auth.login(email, password));

  Future<void> register(String name, String email, String password) =>
      _start(() => _auth.register(name, email, password));

  Future<void> logout() async {
    final old = session;
    session = null;
    notifyListeners(); // back to the login screen straight away
    if (old == null) return;
    try {
      await _auth.logout(old.refreshToken);
    } catch (_) {
      // offline: the token expires on its own in 30 days
    }
  }

  Future<void> _start(Future<Session> Function() request) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      session = await request();
    } on ApiException catch (e) {
      error = e.message; // the API already writes it in Portuguese
    } catch (_) {
      error = 'Sem ligação. Tenta de novo.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
