import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/api_client.dart';
import 'data/auth_repository.dart';
import 'data/http_forecast_repository.dart';
import 'data/session_store.dart';
import 'screens/islands_screen.dart';
import 'screens/login_screen.dart';
import 'state/forecast_notifier.dart';
import 'state/session_notifier.dart';
import 'state/settings.dart';

const clientId = String.fromEnvironment('CLIENT_ID');
const clientSecret = String.fromEnvironment('CLIENT_SECRET');

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // before any plugin
  final settings = await Settings.load();
  final api = ApiClient(clientId: clientId, clientSecret: clientSecret);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) =>
              SessionNotifier(AuthRepository(api), const SessionStore())
                ..restore(),
        ),
        ChangeNotifierProvider(
          create: (_) => ForecastNotifier(HttpForecastRepository(api))..load(),
        ),
      ],
      child: Consumer<Settings>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Tempo Açores',
          theme: ThemeData(colorSchemeSeed: Colors.teal),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.dark,
          ),
          themeMode: settings.theme,
          home: const _Home(),
        ),
      ),
    ),
  );
}

/// While restoring, a spinner. Without a session, the login.
class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionNotifier>();
    if (session.isRestoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return session.isLoggedIn ? const IslandsScreen() : const LoginScreen();
  }
}
