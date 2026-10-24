/// O CEP pode representar uma rua ou município; não um imóvel com número.
class Address {
  const Address({
    required this.cep,
    this.street = '',
    this.complement = '',
    this.neighborhood = '',
    required this.city,
    required this.state,
    this.ibge = '',
    this.consultedAt,
  });
  final String cep;
  final String street;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String ibge;
  final DateTime? consultedAt;

  String get id => cep.replaceAll(RegExp(r'\D'), '');
  String get formattedCep =>
      id.length == 8 ? '${id.substring(0, 5)}-${id.substring(5)}' : cep;
  String get title => street.isEmpty ? 'CEP de $city' : street;
  String get cityState => '$city / $state';
  String get fullAddress => [
    street,
    neighborhood,
    city,
    state,
    formattedCep,
    'Brasil',
  ].where((part) => part.isNotEmpty).join(', ');

  Address consulted(DateTime at) => Address(
    cep: cep,
    street: street,
    complement: complement,
    neighborhood: neighborhood,
    city: city,
    state: state,
    ibge: ibge,
    consultedAt: at,
  );

  factory Address.fromJson(Map<String, dynamic> json) {
    String field(String key) => json[key]?.toString().trim() ?? '';
    final date = field('consultedAt');
    return Address(
      cep: field('cep'),
      street: field('logradouro'),
      complement: field('complemento'),
      neighborhood: field('bairro'),
      city: field('localidade'),
      state: field('uf').toUpperCase(),
      ibge: field('ibge'),
      consultedAt: date.isEmpty ? null : DateTime.tryParse(date),
    );
  }
  Map<String, dynamic> toJson() => {
    'cep': cep,
    'logradouro': street,
    'complemento': complement,
    'bairro': neighborhood,
    'localidade': city,
    'uf': state,
    'ibge': ibge,
    'consultedAt': consultedAt?.toIso8601String(),
  };
}
