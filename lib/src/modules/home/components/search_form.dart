import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../controller/home_controller.dart';
import '../service/address_validation.dart';

class SearchForm extends StatefulWidget {
  const SearchForm({super.key, required this.controller});
  final HomeController controller;
  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final _form = GlobalKey<FormState>();
  final _cep = TextEditingController();
  final _city = TextEditingController();
  final _street = TextEditingController();
  bool _byCep = true;
  String? _state;
  @override
  void dispose() {
    _cep.dispose();
    _city.dispose();
    _street.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    if (_byCep) {
      await widget.controller.searchByCep(_cep.text);
    } else {
      await widget.controller.searchByAddress(
        _state!,
        _city.text,
        _street.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Observer(
    builder: (context) {
      final busy = widget.controller.loading;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppMetrics.large),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Por CEP'),
                      icon: Icon(Icons.pin_outlined),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Por endereço'),
                      icon: Icon(Icons.location_on_outlined),
                    ),
                  ],
                  selected: {_byCep},
                  showSelectedIcon: false,
                  onSelectionChanged: busy
                      ? null
                      : (value) {
                          setState(() => _byCep = value.first);
                          _form.currentState?.reset();
                          widget.controller.resetSearch();
                        },
                ),
                const SizedBox(height: AppMetrics.large),
                if (_byCep)
                  TextFormField(
                    key: const ValueKey('cep-field'),
                    controller: _cep,
                    enabled: !busy,
                    decoration: const InputDecoration(
                      labelText: 'CEP',
                      hintText: '00000-000',
                      prefixIcon: Icon(Icons.search),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\s.-]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: AddressValidation.cep,
                    onFieldSubmitted: (_) => _submit(),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    key: const ValueKey('state-field'),
                    initialValue: _state,
                    decoration: const InputDecoration(labelText: 'UF'),
                    items: AddressValidation.states
                        .map(
                          (uf) => DropdownMenuItem(value: uf, child: Text(uf)),
                        )
                        .toList(),
                    validator: AddressValidation.state,
                    onChanged: busy
                        ? null
                        : (value) => setState(() => _state = value),
                  ),
                  const SizedBox(height: AppMetrics.medium),
                  TextFormField(
                    key: const ValueKey('city-field'),
                    controller: _city,
                    enabled: !busy,
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      hintText: 'Ex.: São Paulo',
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: AddressValidation.city,
                  ),
                  const SizedBox(height: AppMetrics.medium),
                  TextFormField(
                    key: const ValueKey('street-field'),
                    controller: _street,
                    enabled: !busy,
                    decoration: const InputDecoration(
                      labelText: 'Rua, avenida ou praça',
                      hintText: 'Nome completo ou parte dele',
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.search,
                    validator: AddressValidation.street,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
                const SizedBox(height: AppMetrics.medium),
                FilledButton.icon(
                  onPressed: busy ? null : _submit,
                  icon: const Icon(Icons.search),
                  label: Text(busy ? 'Consultando…' : 'Consultar endereço'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
