import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/api_client.dart';
import 'data/auth_repository.dart';
import 'data/http_forecast_repository.dart';
import 'screens/islands_screen.dart';
import 'screens/login_screen.dart';
import 'state/forecast_notifier.dart';
import 'state/session_notifier.dart';

const clientId = String.fromEnvironment('CLIENT_ID');
const clientSecret = String.fromEnvironment('CLIENT_SECRET');

/// TODO 2: keep the session in secure storage, so the login survives a restart.
/// TODO 3: remember the last email and the theme in shared_preferences.
void main() {
  final api = ApiClient(clientId: clientId, clientSecret: clientSecret);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SessionNotifier(AuthRepository(api)),
        ),
        ChangeNotifierProvider(
          create: (_) => ForecastNotifier(HttpForecastRepository(api))..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Tempo Açores',
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        // Without a session, the login. With one, the islands.
        home: Consumer<SessionNotifier>(
          builder: (context, session, _) =>
              session.isLoggedIn ? const IslandsScreen() : const LoginScreen(),
        ),
      ),
    ),
  );
}
