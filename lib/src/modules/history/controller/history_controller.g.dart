// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HistoryController on HistoryControllerBase, Store {
  late final _$entriesAtom = Atom(
    name: 'HistoryControllerBase.entries',
    context: context,
  );

  @override
  ObservableList<Address> get entries {
    _$entriesAtom.reportRead();
    return super.entries;
  }

  @override
  set entries(ObservableList<Address> value) {
    _$entriesAtom.reportWrite(value, super.entries, () {
      super.entries = value;
    });
  }

  late final _$errorAtom = Atom(
    name: 'HistoryControllerBase.error',
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

  late final _$HistoryControllerBaseActionController = ActionController(
    name: 'HistoryControllerBase',
    context: context,
  );

  @override
  void load() {
    final _$actionInfo = _$HistoryControllerBaseActionController.startAction(
      name: 'HistoryControllerBase.load',
    );
    try {
      return super.load();
    } finally {
      _$HistoryControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
entries: ${entries},
error: ${error}
    ''';
  }
}
