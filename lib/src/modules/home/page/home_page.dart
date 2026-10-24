import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/status_panel.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../components/address_list.dart';
import '../components/last_address.dart';
import '../components/search_form.dart';
import '../components/search_results.dart';
import '../controller/home_controller.dart';
import '../model/address.dart';
import '../service/navigation_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});
  final HomeController controller;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ReactionDisposer _errorReaction;
  final _resultKey = GlobalKey();
  HomeController get _controller => widget.controller;
  @override
  void initState() {
    super.initState();
    _errorReaction = reaction<String?>((_) => _controller.error, (error) {
      if (error == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
      });
    });
    _controller.refreshHistory();
  }

  @override
  void dispose() {
    _errorReaction();
    super.dispose();
  }

  void _viewLocal(Address address) {
    _controller.openLocal(address);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _resultKey.currentContext;
      if (mounted && target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 250),
          alignment: .05,
        );
      }
    });
  }

  Future<void> _history() async {
    final selected = await Navigator.of(
      context,
    ).pushNamed<Address>(AppRoutes.history);
    if (!mounted) return;
    _controller.refreshHistory();
    if (selected != null) _viewLocal(selected);
  }

  Future<void> _route(Address address) async {
    final options = await _controller.prepareRoute(address);
    if (!mounted || options.isEmpty) return;
    final chosen = await showModalBottomSheet<NavigationOption>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Abrir rota com',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(address.title),
              const SizedBox(height: 8),
              const Text(
                'O mapa usará sua localização atual como origem. '
                'Confirme o destino aproximado antes de iniciar a navegação.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              for (final option in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.map_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(option.name),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => Navigator.of(sheetContext).pop(option),
                ),
            ],
          ),
        ),
      ),
    );
    if (chosen != null && mounted) await _controller.openRoute(chosen);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_shipping_outlined, color: AppColors.primary),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'FastDelivery',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _history,
          tooltip: 'Histórico',
          icon: const Icon(Icons.history),
        ),
      ],
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppMetrics.maxWidth),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppMetrics.large),
            children: [
              const Text(
                'MENOS DÚVIDAS. MAIS ENTREGAS.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Encontre seu\npróximo destino.',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Consulte endereços e CEPs de todo o Brasil.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: AppMetrics.large),
              SearchForm(controller: _controller),
              const SizedBox(height: AppMetrics.large),
              SearchResults(
                key: _resultKey,
                controller: _controller,
                onRoute: _route,
              ),
              const SizedBox(height: AppMetrics.large),
              Observer(
                builder: (_) {
                  final last = _controller.last;
                  final recent = _controller.recent.toList();
                  final routeBusy = _controller.routeLoading;
                  if (last == null) {
                    return const StatusPanel(
                      icon: Icons.explore_outlined,
                      title: 'Pronto para a próxima entrega',
                      message:
                          'Busque um CEP ou endereço. Suas consultas ficarão salvas aqui.',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LastAddress(
                        address: last,
                        onDetails: () => _viewLocal(last),
                        onRoute: () => _route(last),
                        routeLoading: routeBusy,
                      ),
                      const SizedBox(height: AppMetrics.large),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Consultas recentes',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: _history,
                            child: const Text('Ver todas'),
                          ),
                        ],
                      ),
                      AddressList(addresses: recent, onSelect: _viewLocal),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppMetrics.medium),
              const Text(
                'Dados de endereço por ViaCEP',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
