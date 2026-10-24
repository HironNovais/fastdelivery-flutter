import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../shared/components/loading_panel.dart';
import '../../../shared/components/status_panel.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../controller/home_controller.dart';
import '../model/address.dart';
import 'address_details.dart';
import 'address_list.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({
    super.key,
    required this.controller,
    required this.onRoute,
  });
  final HomeController controller;
  final ValueChanged<Address> onRoute;
  @override
  Widget build(BuildContext context) => Observer(
    builder: (_) {
      final busy = controller.loading;
      final error = controller.error;
      final current = controller.current;
      final results = controller.results.toList();
      final empty = controller.notFound;
      final local = controller.isLocal;
      final routeBusy = controller.routeLoading;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (busy) const LoadingPanel(),
          if (!busy && error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppMetrics.medium),
              child: StatusPanel(
                icon: Icons.wifi_off_outlined,
                title: 'Não foi possível concluir',
                message: error,
                isError: true,
              ),
            ),
          if (!busy && empty)
            const StatusPanel(
              icon: Icons.search_off,
              title: 'Nenhum endereço encontrado',
              message:
                  'Confira os dados ou tente um nome de rua mais específico.',
            ),
          if (!busy && current != null)
            AddressDetails(
              address: current,
              isLocal: local,
              routeLoading: routeBusy,
              onRoute: () => onRoute(current),
            ),
          if (!busy && results.isNotEmpty) ...[
            Text(
              '${results.length} endereço(s) encontrado(s)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppMetrics.small),
            const Text(
              'Selecione um endereço para ver os detalhes e salvar a consulta.',
            ),
            const SizedBox(height: AppMetrics.medium),
            if (results.length >= 50)
              const Padding(
                padding: EdgeInsets.only(bottom: AppMetrics.medium),
                child: Text(
                  'O ViaCEP retorna até 50 endereços. Refine o nome da rua '
                  'se o destino não aparecer.',
                ),
              ),
            AddressList(addresses: results, onSelect: controller.selectResult),
          ],
        ],
      );
    },
  );
}
