import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/forecast_notifier.dart';

/// Draws the state of the ForecastNotifier. Knows no URLs and no JSON.
class IslandsScreen extends StatelessWidget {
  const IslandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = context.watch<ForecastNotifier>(); // rebuilds on notify
    return Scaffold(
      appBar: AppBar(title: const Text('Tempo Açores')),
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
