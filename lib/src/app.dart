import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_dependencies.dart';
import 'routes/app_routes.dart';
import 'shared/components/app_theme.dart';

class FastDeliveryApp extends StatelessWidget {
  const FastDeliveryApp({super.key, required this.dependencies});
  final AppDependencies dependencies;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FastDelivery',
    debugShowCheckedModeBanner: false,
    theme: createTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    initialRoute: AppRoutes.initial,
    onGenerateRoute: (settings) => AppRoutes.generate(settings, dependencies),
  );
}
