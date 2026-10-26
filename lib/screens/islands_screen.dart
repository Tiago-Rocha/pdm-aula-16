import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/forecast_notifier.dart';
import '../state/session_notifier.dart';
import '../state/settings.dart';

/// Draws the state of the ForecastNotifier. Knows no URLs and no JSON.
class IslandsScreen extends StatelessWidget {
  const IslandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = context.watch<ForecastNotifier>(); // rebuilds on notify
    final user = context.watch<SessionNotifier>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user?.name ?? ''}'),
        actions: [
          IconButton(
            tooltip: 'Tema',
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final settings = context.read<Settings>();
              final next = settings.theme == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              settings.saveTheme(next);
            },
          ),
          IconButton(
            tooltip: 'Terminar sessão',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<SessionNotifier>().logout(),
          ),
        ],
      ),
      body: _body(context, forecast),
    );
  }

  Widget _body(BuildContext context, ForecastNotifier forecast) {
    if (forecast.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (forecast.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(forecast.error!),
            TextButton(
              onPressed: () => context.read<ForecastNotifier>().load(),
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: forecast.islands.length,
      itemBuilder: (context, i) => ListTile(
        leading: Image.network(forecast.islands[i].imageUrl, width: 56),
        title: Text(forecast.islands[i].name),
      ),
    );
  }
}
