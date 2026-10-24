import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../shared/components/status_panel.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../../home/components/address_list.dart';
import '../controller/history_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.controller});
  final HistoryController controller;
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Histórico'),
      actions: [
        IconButton(
          onPressed: widget.controller.load,
          tooltip: 'Atualizar histórico',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppMetrics.maxWidth),
          child: Observer(
            builder: (_) {
              final entries = widget.controller.entries.toList();
              final error = widget.controller.error;
              return ListView(
                padding: const EdgeInsets.all(AppMetrics.large),
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.offline_pin_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Salvo neste dispositivo. Disponível sem internet.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppMetrics.large),
                  if (error != null)
                    StatusPanel(
                      icon: Icons.error_outline,
                      title: 'Histórico indisponível',
                      message: error,
                      isError: true,
                    )
                  else if (entries.isEmpty)
                    const StatusPanel(
                      icon: Icons.history,
                      title: 'Seu histórico começa aqui',
                      message:
                          'Os endereços consultados aparecerão nesta tela.',
                    )
                  else
                    AddressList(
                      addresses: entries,
                      showDates: true,
                      onSelect: (address) => Navigator.of(context).pop(address),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
