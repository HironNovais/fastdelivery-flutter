abstract final class AddressValidation {
  static const states = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];
  static String cleanCep(String value) =>
      value.replaceAll(RegExp(r'[\s.-]'), '');
  static String? cep(String? value) =>
      RegExp(r'^\d{8}$').hasMatch(cleanCep(value ?? ''))
      ? null
      : 'Informe um CEP com 8 dígitos.';
  static String? state(String? value) =>
      states.contains(value?.toUpperCase()) ? null : 'Selecione uma UF válida.';
  static String? city(String? value) => _text(value, 'A cidade');
  static String? street(String? value) => _text(value, 'O logradouro');
  static String? _text(String? value, String label) =>
      value == null || value.trim().length < 3
      ? '$label deve ter pelo menos 3 caracteres.'
      : null;
}
