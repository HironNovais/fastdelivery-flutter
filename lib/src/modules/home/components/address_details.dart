import 'package:flutter/material.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/date_label.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address.dart';

class AddressDetails extends StatelessWidget {
  const AddressDetails({
    super.key,
    required this.address,
    required this.onRoute,
    this.isLocal = false,
    this.routeLoading = false,
  });
  final Address address;
  final VoidCallback onRoute;
  final bool isLocal;
  final bool routeLoading;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppMetrics.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Icon(
                  isLocal
                      ? Icons.offline_pin_outlined
                      : Icons.check_circle_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  isLocal ? 'Salvo neste dispositivo' : 'Endereço encontrado',
                ),
                side: BorderSide.none,
                backgroundColor: AppColors.primary.withValues(alpha: .08),
              ),
              Chip(
                label: Text(address.formattedCep),
                side: BorderSide.none,
                backgroundColor: AppColors.canvas,
              ),
            ],
          ),
          const SizedBox(height: AppMetrics.medium),
          SelectableText(
            address.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppMetrics.medium),
          _field('Bairro', address.neighborhood),
          _field('Cidade / UF', address.cityState),
          _field('Complemento', address.complement),
          _field('Código IBGE', address.ibge),
          if (address.consultedAt != null)
            _field('Consultado em', dateLabel(context, address.consultedAt!)),
          const SizedBox(height: AppMetrics.medium),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: routeLoading ? null : onRoute,
              icon: routeLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.near_me_outlined),
              label: Text(routeLoading ? 'Preparando rota…' : 'Traçar rota'),
            ),
          ),
          const SizedBox(height: AppMetrics.small),
          const Text(
            'Destino aproximado do CEP. Confirme o local no mapa: '
            'a consulta não inclui número do imóvel.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
  Widget _field(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppMetrics.small),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        SelectableText(value.isEmpty ? 'Não informado' : value),
      ],
    ),
  );
}
