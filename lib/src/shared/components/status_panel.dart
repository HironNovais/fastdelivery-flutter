import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.isError = false,
  });
  final IconData icon;
  final String title;
  final String message;
  final bool isError;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppMetrics.large),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: isError
                ? Theme.of(context).colorScheme.error
                : AppColors.primary,
          ),
          const SizedBox(height: AppMetrics.medium),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppMetrics.small),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}
