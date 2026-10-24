import 'package:flutter/material.dart';
import '../metrics/app_metrics.dart';

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({super.key, this.message = 'Consultando o ViaCEP…'});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppMetrics.large),
    child: Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppMetrics.medium),
        Text(message),
      ],
    ),
  );
}
