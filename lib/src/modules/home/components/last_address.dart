import 'package:flutter/material.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address.dart';

class LastAddress extends StatelessWidget {
  const LastAddress({
    super.key,
    required this.address,
    required this.onDetails,
    required this.onRoute,
    this.routeLoading = false,
  });
  final Address address;
  final VoidCallback onDetails;
  final VoidCallback onRoute;
  final bool routeLoading;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppMetrics.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'ÚLTIMA CONSULTA',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppMetrics.medium),
          Text(address.title, style: Theme.of(context).textTheme.titleMedium),
          Text(
            '${address.formattedCep} · ${address.cityState}',
            style: const TextStyle(color: AppColors.muted),
          ),
          const Text(
            'Salvo neste dispositivo',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: AppMetrics.small),
          Wrap(
            spacing: AppMetrics.small,
            children: [
              TextButton.icon(
                onPressed: onDetails,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Ver detalhes'),
              ),
              TextButton.icon(
                onPressed: routeLoading ? null : onRoute,
                icon: const Icon(Icons.near_me_outlined, size: 18),
                label: Text(routeLoading ? 'Preparando…' : 'Traçar rota'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
