// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on HomeControllerBase, Store {
  late final _$loadingAtom = Atom(
    name: 'HomeControllerBase.loading',
    context: context,
  );

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$routeLoadingAtom = Atom(
    name: 'HomeControllerBase.routeLoading',
    context: context,
  );

  @override
  bool get routeLoading {
    _$routeLoadingAtom.reportRead();
    return super.routeLoading;
  }

  @override
  set routeLoading(bool value) {
    _$routeLoadingAtom.reportWrite(value, super.routeLoading, () {
      super.routeLoading = value;
    });
  }

  late final _$currentAtom = Atom(
    name: 'HomeControllerBase.current',
    context: context,
  );

  @override
  Address? get current {
    _$currentAtom.reportRead();
    return super.current;
  }

  @override
  set current(Address? value) {
    _$currentAtom.reportWrite(value, super.current, () {
      super.current = value;
    });
  }

  late final _$lastAtom = Atom(
    name: 'HomeControllerBase.last',
    context: context,
  );

  @override
  Address? get last {
    _$lastAtom.reportRead();
    return super.last;
  }

  @override
  set last(Address? value) {
    _$lastAtom.reportWrite(value, super.last, () {
      super.last = value;
    });
  }

  late final _$resultsAtom = Atom(
    name: 'HomeControllerBase.results',
    context: context,
  );

  @override
  ObservableList<Address> get results {
    _$resultsAtom.reportRead();
    return super.results;
  }

  @override
  set results(ObservableList<Address> value) {
    _$resultsAtom.reportWrite(value, super.results, () {
      super.results = value;
    });
  }

  late final _$recentAtom = Atom(
    name: 'HomeControllerBase.recent',
    context: context,
  );

  @override
  ObservableList<Address> get recent {
    _$recentAtom.reportRead();
    return super.recent;
  }

  @override
  set recent(ObservableList<Address> value) {
    _$recentAtom.reportWrite(value, super.recent, () {
      super.recent = value;
    });
  }

  late final _$errorAtom = Atom(
    name: 'HomeControllerBase.error',
    context: context,
  );

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$notFoundAtom = Atom(
    name: 'HomeControllerBase.notFound',
    context: context,
  );

  @override
  bool get notFound {
    _$notFoundAtom.reportRead();
    return super.notFound;
  }

  @override
  set notFound(bool value) {
    _$notFoundAtom.reportWrite(value, super.notFound, () {
      super.notFound = value;
    });
  }

  late final _$isLocalAtom = Atom(
    name: 'HomeControllerBase.isLocal',
    context: context,
  );

  @override
  bool get isLocal {
    _$isLocalAtom.reportRead();
    return super.isLocal;
  }

  @override
  set isLocal(bool value) {
    _$isLocalAtom.reportWrite(value, super.isLocal, () {
      super.isLocal = value;
    });
  }

  late final _$selectResultAsyncAction = AsyncAction(
    'HomeControllerBase.selectResult',
    context: context,
  );

  @override
  Future<void> selectResult(Address address) {
    return _$selectResultAsyncAction.run(() => super.selectResult(address));
  }

  late final _$prepareRouteAsyncAction = AsyncAction(
    'HomeControllerBase.prepareRoute',
    context: context,
  );

  @override
  Future<List<NavigationOption>> prepareRoute(Address address) {
    return _$prepareRouteAsyncAction.run(() => super.prepareRoute(address));
  }

  late final _$openRouteAsyncAction = AsyncAction(
    'HomeControllerBase.openRoute',
    context: context,
  );

  @override
  Future<void> openRoute(NavigationOption option) {
    return _$openRouteAsyncAction.run(() => super.openRoute(option));
  }

  late final _$HomeControllerBaseActionController = ActionController(
    name: 'HomeControllerBase',
    context: context,
  );

  @override
  void refreshHistory() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.refreshHistory',
    );
    try {
      return super.refreshHistory();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetSearch() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.resetSearch',
    );
    try {
      return super.resetSearch();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<void> searchByCep(String cep) {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.searchByCep',
    );
    try {
      return super.searchByCep(cep);
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<void> searchByAddress(String state, String city, String street) {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.searchByAddress',
    );
    try {
      return super.searchByAddress(state, city, street);
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void openLocal(Address address) {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.openLocal',
    );
    try {
      return super.openLocal(address);
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
routeLoading: ${routeLoading},
current: ${current},
last: ${last},
results: ${results},
recent: ${recent},
error: ${error},
notFound: ${notFound},
isLocal: ${isLocal}
    ''';
  }
}
