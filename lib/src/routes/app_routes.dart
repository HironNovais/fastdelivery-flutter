import 'package:flutter/material.dart';
import '../app_dependencies.dart';
import '../modules/history/page/history_page.dart';
import '../modules/home/model/address.dart';
import '../modules/home/page/home_page.dart';
import '../modules/initial/page/initial_page.dart';

abstract final class AppRoutes {
  static const initial = '/';
  static const home = '/home';
  static const history = '/history';

  static Route<dynamic> generate(
    RouteSettings settings,
    AppDependencies dependencies,
  ) {
    if (settings.name == history) {
      return MaterialPageRoute<Address>(
        settings: settings,
        builder: (_) => HistoryPage(controller: dependencies.history()),
      );
    }
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => settings.name == home
          ? HomePage(controller: dependencies.home())
          : const InitialPage(),
    );
  }
}
