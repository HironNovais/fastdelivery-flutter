import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/app_dependencies.dart';
import 'src/shared/components/app_theme.dart';
import 'src/shared/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final box = await LocalStorage.open();
    runApp(FastDeliveryApp(dependencies: AppDependencies.production(box)));
  } catch (_) {
    // Não apagar o banco nem iniciar uma sessão que perderia o histórico.
    runApp(
      MaterialApp(
        title: 'FastDelivery',
        theme: createTheme(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storage_outlined, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Não foi possível abrir o armazenamento local.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verifique o espaço livre do dispositivo e tente novamente.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: main,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
