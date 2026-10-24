import 'package:flutter/material.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../../../shared/components/date_label.dart';
import '../model/address.dart';

class AddressList extends StatelessWidget {
  const AddressList({
    super.key,
    required this.addresses,
    required this.onSelect,
    this.showDates = false,
  });
  final List<Address> addresses;
  final ValueChanged<Address> onSelect;
  final bool showDates;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final address in addresses)
        Padding(
          padding: const EdgeInsets.only(bottom: AppMetrics.small),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onSelect(address),
              child: Padding(
                padding: const EdgeInsets.all(AppMetrics.medium),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppMetrics.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.formattedCep,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (address.neighborhood.isNotEmpty)
                            Text(address.neighborhood),
                          Text(
                            address.cityState,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          if (showDates && address.consultedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppMetrics.small,
                              ),
                              child: Text(
                                dateLabel(context, address.consultedAt!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.muted),
                  ],
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
