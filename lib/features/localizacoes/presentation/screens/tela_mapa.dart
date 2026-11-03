import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/cache_mapa.dart';
import '../widgets/mapa_localizacoes.dart';

/// Tudo o que o mapa precisa para ser exibido.
class _DadosMapa {
  const _DadosMapa(this.localizacoes, this.cache);

  final List<Localizacao> localizacoes;
  final MapCachingProvider cache;
}

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final _repositorio = RepositorioLocalizacoes();
  late Future<_DadosMapa> _dados;

  @override
  void initState() {
    super.initState();
    _dados = _carregar();
  }

  Future<_DadosMapa> _carregar() async {
    // Prepara o cache antes de o mapa começar a baixar imagens.
    final cache = await CacheMapa.preparar();
    final localizacoes = await _repositorio.consultarRecentes();
    return _DadosMapa(localizacoes, cache);
  }

  void _atualizar() {
    setState(() {
      _dados = _carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          IconButton(
            onPressed: _atualizar,
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_DadosMapa>(
        future: _dados,
        builder: (context, snapshot) {
          // Erro ao abrir o banco ou preparar o cache.
          if (snapshot.hasError) {
            return _Mensagem(
              icone: Icons.error_outline,
              texto: 'Não foi possível carregar o mapa.\n${snapshot.error}',
              acao: FilledButton(
                onPressed: _atualizar,
                child: const Text('Tentar novamente'),
              ),
            );
          }

          // Esperando o primeiro carregamento. Ao atualizar, o FutureBuilder
          // mantém os dados anteriores, então o mapa continua na tela.
          final dados = snapshot.data;
          if (dados == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dados.localizacoes.isEmpty) {
            return const _Mensagem(
              icone: Icons.location_off,
              texto: 'Nenhuma localização salva ainda.',
            );
          }

          return MapaLocalizacoes(
            localizacoes: dados.localizacoes,
            cache: dados.cache,
          );
        },
      ),
    );
  }
}

class _Mensagem extends StatelessWidget {
  const _Mensagem({required this.icone, required this.texto, this.acao});

  final IconData icone;
  final String texto;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
            if (acao != null) ...[const SizedBox(height: 12), acao!],
          ],
        ),
      ),
    );
  }
}
