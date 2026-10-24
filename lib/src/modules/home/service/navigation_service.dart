import 'dart:async';

import 'package:geocoding/geocoding.dart' as geo;
import 'package:map_launcher/map_launcher.dart' as maps;

import '../../../shared/components/app_exception.dart';
import '../model/address.dart';

class Coordinates {
  const Coordinates(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class NavigationOption {
  const NavigationOption(this.name, this.open);
  final String name;
  final Future<void> Function() open;
}

abstract interface class Geocoder {
  Future<List<Coordinates>> locate(String address);
}

abstract interface class MapsGateway {
  Future<List<NavigationOption>> installed(Coordinates destination);
}

class NativeGeocoder implements Geocoder {
  @override
  Future<List<Coordinates>> locate(String address) async {
    // Criado apenas ao usar rotas, depois do registro dos plugins nativos.
    final locations = await geo.Geocoding().locationFromAddress(address);
    return locations.map((p) => Coordinates(p.latitude, p.longitude)).toList();
  }
}

class NativeMapsGateway implements MapsGateway {
  @override
  Future<List<NavigationOption>> installed(Coordinates destination) async {
    final request = maps.MapLauncher.directions(
      maps.Location.coords(destination.latitude, destination.longitude),
      // A origem é omitida para o mapa usar a localização atual do dispositivo.
      mode: maps.TravelMode.driving,
    );
    final available = await request.getSupportedMaps([
      maps.MapApp.google,
      maps.MapApp.apple,
      maps.MapApp.waze,
    ]);
    return available
        .where((app) => app.isInstalled)
        .map((app) => NavigationOption(app.name, app.show))
        .toList();
  }
}

class NavigationService {
  NavigationService(this._geocoder, this._maps);
  final Geocoder _geocoder;
  final MapsGateway _maps;

  Future<List<NavigationOption>> prepare(Address address) async {
    try {
      final locations = await _geocoder
          .locate(address.fullAddress)
          .timeout(const Duration(seconds: 15));
      if (locations.isEmpty) {
        throw const AppException(
          'Não foi possível localizar esse endereço no mapa.',
        );
      }
      final point = locations.first;
      if (!point.latitude.isFinite ||
          !point.longitude.isFinite ||
          point.latitude.abs() > 90 ||
          point.longitude.abs() > 180) {
        throw const AppException(
          'O serviço de localização retornou coordenadas inválidas.',
        );
      }
      final options = await _maps
          .installed(point)
          .timeout(const Duration(seconds: 10));
      if (options.isEmpty) {
        throw const AppException(
          'Nenhum mapa compatível instalado. Instale Google Maps, Apple Maps ou Waze.',
        );
      }
      return options;
    } on AppException {
      rethrow;
    } on TimeoutException {
      throw const AppException(
        'A localização demorou demais. Verifique sua conexão e tente novamente.',
      );
    } catch (_) {
      throw const AppException(
        'Não foi possível preparar a rota. Verifique sua conexão e o serviço de mapas.',
      );
    }
  }

  Future<void> open(NavigationOption option) async {
    try {
      await option.open().timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const AppException(
        'Não foi possível abrir o aplicativo de mapas. Tente outro aplicativo.',
      );
    }
  }
}
