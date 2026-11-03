import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/localizacao.dart';
import 'item_localizacao.dart';

/// Mapa com a camada de ruas do OpenStreetMap e um marcador por localização.
class MapaLocalizacoes extends StatefulWidget {
  const MapaLocalizacoes({
    super.key,
    required this.localizacoes,
    required this.cache,
  });

  /// Lista não vazia, da mais recente (índice 0) para a mais antiga.
  final List<Localizacao> localizacoes;

  final MapCachingProvider cache;

  @override
  State<MapaLocalizacoes> createState() => _MapaLocalizacoesState();
}

class _MapaLocalizacoesState extends State<MapaLocalizacoes> {
  final _controlador = MapController();

  List<LatLng> get _pontos =>
      widget.localizacoes.map((l) => LatLng(l.latitude, l.longitude)).toList();

  /// Enquadramento que mostra todos os pontos. O maxZoom evita aproximar
  /// demais quando há um único ponto.
  CameraFit get _enquadramento => CameraFit.coordinates(
    coordinates: _pontos,
    padding: const EdgeInsets.all(48),
    maxZoom: 17,
  );

  void _enquadrar() => _controlador.fitCamera(_enquadramento);

  @override
  void didUpdateWidget(MapaLocalizacoes antigo) {
    super.didUpdateWidget(antigo);
    // Ao atualizar os registros, enquadra de novo depois do próximo frame.
    if (antigo.localizacoes != widget.localizacoes) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _enquadrar();
      });
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _mostrarDetalhes(Localizacao localizacao, bool maisRecente) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                maisRecente ? 'Localização mais recente' : 'Localização',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ItemLocalizacao(localizacao: localizacao, destaque: maisRecente),
            ],
          ),
        ),
      ),
    );
  }

  List<Marker> _criarMarcadores() {
    final marcadores = <Marker>[];
    // Percorre da mais antiga para a mais recente: o último marcador
    // adicionado é desenhado por cima, então a mais recente fica visível.
    for (var i = widget.localizacoes.length - 1; i >= 0; i--) {
      final localizacao = widget.localizacoes[i];
      final maisRecente = i == 0;
      marcadores.add(
        Marker(
          point: LatLng(localizacao.latitude, localizacao.longitude),
          width: 40,
          height: 40,
          alignment: Alignment.topCenter, // a ponta do ícone fica no ponto
          child: GestureDetector(
            onTap: () => _mostrarDetalhes(localizacao, maisRecente),
            child: Icon(
              Icons.location_on,
              size: 40,
              color: maisRecente ? Colors.red : Colors.blue,
            ),
          ),
        ),
      );
    }
    return marcadores;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _controlador,
          options: MapOptions(
            initialCameraFit: _enquadramento, // enquadra ao carregar
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              // Identifica o app nas requisições, exigido pelo OSM.
              userAgentPackageName: 'br.fatec.localizacoes',
              tileProvider: NetworkTileProvider(cachingProvider: widget.cache),
            ),
            MarkerLayer(markers: _criarMarcadores()),
            const RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _enquadrar,
            tooltip: 'Enquadrar todos os pontos',
            child: const Icon(Icons.fit_screen),
          ),
        ),
      ],
    );
  }
}
