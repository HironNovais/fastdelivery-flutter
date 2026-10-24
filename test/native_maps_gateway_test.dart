import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:fast_delivery/src/modules/home/service/navigation_service.dart';

class RecordingMapsPlatform extends MapLauncherPlatform {
  Set<String> installed = {'google', 'waze'};
  String? launchedUrl;
  @override
  MapPlatform get platform => MapPlatform.android;
  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async => installed;
  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    launchedUrl = url;
  }
}

void main() {
  late MapLauncherPlatform original;
  late RecordingMapsPlatform platform;
  setUp(() {
    original = MapLauncherPlatform.instance;
    platform = RecordingMapsPlatform();
    MapLauncherPlatform.instance = platform;
  });
  tearDown(() => MapLauncherPlatform.instance = original);
  test(
    'adapter usa API real do map_launcher 7 e omite origem para localização atual',
    () async {
      final options = await NativeMapsGateway().installed(
        const Coordinates(-23.55, -46.63),
      );
      expect(options.map((o) => o.name), ['Google Maps', 'Waze']);
      await options.first.open();
      final uri = Uri.parse(platform.launchedUrl!);
      expect(uri.queryParameters['destination'], '-23.55,-46.63');
      expect(uri.queryParameters.containsKey('origin'), isFalse);
      expect(uri.queryParameters['travelmode'], 'driving');
    },
  );
  test('adapter filtra provedores web quando não há app instalado', () async {
    platform.installed = {};
    expect(
      await NativeMapsGateway().installed(const Coordinates(-23.55, -46.63)),
      isEmpty,
    );
  });
}
