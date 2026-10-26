import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/api_client.dart';
import 'data/http_forecast_repository.dart';
import 'screens/islands_screen.dart';
import 'state/forecast_notifier.dart';

const clientId = String.fromEnvironment('CLIENT_ID');
const clientSecret = String.fromEnvironment('CLIENT_SECRET');

/// TODO 1: a login screen. Without a session, the app opens on it.
/// TODO 2: keep the session in secure storage, so the login survives a restart.
/// TODO 3: remember the last email and the theme in shared_preferences.
void main() {
  final api = ApiClient(clientId: clientId, clientSecret: clientSecret);
  final repository = HttpForecastRepository(api);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ForecastNotifier(repository)..load(),
      child: MaterialApp(
        title: 'Tempo Açores',
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        home: const IslandsScreen(),
      ),
    ),
  );
}
