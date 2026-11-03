import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/localizacao.dart';

/// Mostra os dados de uma localização. Usado na tela inicial, no histórico e
/// nos detalhes de um marcador do mapa.
class ItemLocalizacao extends StatelessWidget {
  const ItemLocalizacao({
    super.key,
    required this.localizacao,
    this.destaque = false,
  });

  final Localizacao localizacao;

  /// Quando verdadeiro, o ícone fica vermelho (registro mais recente).
  final bool destaque;

  static final _formatoData = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    // O banco guarda em UTC; para exibir, converte para o horário local.
    final dataLocal = _formatoData.format(localizacao.instante.toLocal());
    final latitude = localizacao.latitude.toStringAsFixed(6);
    final longitude = localizacao.longitude.toStringAsFixed(6);
    final precisao = localizacao.precisao.toStringAsFixed(1);

    return ListTile(
      leading: Icon(
        Icons.location_on,
        color: destaque ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
      title: Text(dataLocal),
      subtitle: Text(
        'Latitude: $latitude\n'
        'Longitude: $longitude\n'
        'Precisão: $precisao m',
      ),
      isThreeLine: true,
    );
  }
}
