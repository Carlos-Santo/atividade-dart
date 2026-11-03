import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Prepara o cache local das imagens (tiles) do mapa.
///
/// As imagens baixadas do OpenStreetMap ficam numa pasta privada do app e são
/// reaproveitadas, respeitando o tempo de validade enviado pelo servidor.
/// Isso reduz o tráfego, como pede a política de uso dos tiles do OSM.
class CacheMapa {
  CacheMapa._();

  static const _nomePasta = 'cache_mapa';
  static const _tamanhoMaximo = 200 * 1024 * 1024; // 200 MB

  static Future<MapCachingProvider>? _preparacao;

  /// Deve ser aguardado antes de criar o mapa.
  /// Chamadas seguintes reutilizam o mesmo resultado.
  static Future<MapCachingProvider> preparar() async {
    final existente = _preparacao;
    if (existente != null) return existente;

    final preparacao = _criar();
    _preparacao = preparacao;
    try {
      return await preparacao;
    } catch (_) {
      _preparacao = null; // permite tentar de novo
      rethrow;
    }
  }

  static Future<MapCachingProvider> _criar() async {
    // No navegador não há pasta privada; o próprio browser faz o cache HTTP.
    if (kIsWeb) return const DisabledMapCachingProvider();

    // Pasta de cache privada: outros apps não acessam e o sistema pode limpá-la.
    final base = await getApplicationCacheDirectory();
    final pasta = Directory(join(base.path, _nomePasta));
    await pasta.create(recursive: true);

    return BuiltInMapCachingProvider.getOrCreateInstance(
      cacheDirectory: pasta.path,
      maxCacheSize: _tamanhoMaximo,
    );
  }
}
