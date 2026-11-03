import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/servico_localizacao.dart';
import '../widgets/item_localizacao.dart';
import 'tela_localizacoes.dart';
import 'tela_mapa.dart';

/// Tela inicial. Guarda a assinatura do stream de posições.
///
/// Como é a primeira rota, ela continua na pilha do Navigator enquanto o
/// usuário abre o histórico ou o mapa; por isso a coleta não é interrompida.
class TelaColeta extends StatefulWidget {
  const TelaColeta({super.key});

  @override
  State<TelaColeta> createState() => _TelaColetaState();
}

class _TelaColetaState extends State<TelaColeta> {
  final _servico = ServicoLocalizacao();
  final _repositorio = RepositorioLocalizacoes();

  StreamSubscription<Position>? _assinatura;

  /// Verdadeiro enquanto as permissões são verificadas (evita dois cliques).
  bool _iniciando = false;

  /// Verdadeiro enquanto uma posição está sendo gravada.
  bool _salvando = false;

  int _salvasNestaSessao = 0;
  Localizacao? _ultima;

  bool get _coletando => _assinatura != null;

  Future<void> _iniciarColeta() async {
    // Evita assinaturas duplicadas.
    if (_coletando || _iniciando) return;
    setState(() => _iniciando = true);

    try {
      final status = await _servico.verificarPermissao();
      if (!mounted) return;

      if (status != StatusPermissao.concedida) {
        _orientarUsuario(status);
        return;
      }

      final assinatura = _servico.obterPosicoes().listen(
        _salvarPosicao,
        onError: _tratarErroDoStream,
      );
      setState(() {
        _assinatura = assinatura;
        _salvasNestaSessao = 0;
      });
    } catch (erro) {
      if (mounted) _mostrarMensagem('Erro ao iniciar a coleta: $erro');
    } finally {
      if (mounted) setState(() => _iniciando = false);
    }
  }

  /// Chamado a cada posição recebida pelo stream.
  Future<void> _salvarPosicao(Position posicao) async {
    // Evita gravações sobrepostas: se a anterior ainda não terminou,
    // esta posição é descartada.
    if (_salvando) return;
    _salvando = true;

    final localizacao = Localizacao(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      precisao: posicao.accuracy,
      instante: posicao.timestamp.toUtc(),
    );

    try {
      await _repositorio.inserir(localizacao);
      if (!mounted) return;
      setState(() {
        _ultima = localizacao;
        _salvasNestaSessao++;
      });
    } catch (erro) {
      if (mounted) _mostrarMensagem('Erro ao salvar a localização: $erro');
    } finally {
      _salvando = false;
    }
  }

  void _tratarErroDoStream(Object erro) {
    // Ex.: o usuário desligou o GPS ou revogou a permissão durante a coleta.
    _pararColeta();
    if (!mounted) return;
    if (erro is LocationServiceDisabledException) {
      _mostrarMensagem('O GPS foi desligado. A coleta foi interrompida.');
    } else if (erro is PermissionDeniedException) {
      _mostrarMensagem('Permissão de localização removida. Coleta parada.');
    } else {
      _mostrarMensagem('Erro na coleta de localização: $erro');
    }
  }

  Future<void> _pararColeta() async {
    final assinatura = _assinatura;
    if (assinatura == null) return;

    // Limpa antes do await para que um segundo clique não cancele de novo.
    if (mounted) {
      setState(() => _assinatura = null);
    } else {
      _assinatura = null;
    }
    // Cancelar a assinatura também encerra o serviço em primeiro plano.
    await assinatura.cancel();
  }

  void _orientarUsuario(StatusPermissao status) {
    switch (status) {
      case StatusPermissao.servicoDesabilitado:
        _mostrarMensagem(
          'O serviço de localização está desligado. Ative o GPS.',
          rotuloAcao: 'Ativar',
          acao: _servico.abrirConfiguracoesLocalizacao,
        );
      case StatusPermissao.negada:
        _mostrarMensagem(
          'Permissão negada. Toque em "Iniciar coleta" e permita o acesso.',
        );
      case StatusPermissao.negadaPermanentemente:
        _mostrarMensagem(
          'A permissão foi negada permanentemente. '
          'Habilite a localização nas configurações do app.',
          rotuloAcao: 'Abrir',
          acao: _servico.abrirConfiguracoesPermissao,
        );
      case StatusPermissao.concedida:
        break;
    }
  }

  void _mostrarMensagem(
    String texto, {
    String? rotuloAcao,
    VoidCallback? acao,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        action: rotuloAcao != null && acao != null
            ? SnackBarAction(label: rotuloAcao, onPressed: acao)
            : null,
      ),
    );
  }

  void _abrirHistorico() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TelaLocalizacoes(coletaAtiva: _coletando),
      ),
    );
  }

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const TelaMapa()),
    );
  }

  @override
  void dispose() {
    // Libera a assinatura ao destruir a tela.
    _assinatura?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ultima = _ultima;

    return Scaffold(
      appBar: AppBar(title: const Text('Coleta de localizações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _coletando ? Icons.gps_fixed : Icons.gps_off,
                    color: _coletando ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _coletando
                          ? 'Coleta ativa: $_salvasNestaSessao '
                                'posição(ões) salva(s) nesta sessão.'
                          : 'Coleta parada.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (ultima != null)
            Card(child: ItemLocalizacao(localizacao: ultima, destaque: true)),
          const SizedBox(height: 16),
          FilledButton.icon(
            // Habilitado só quando parado; null desabilita o botão.
            onPressed: _coletando || _iniciando ? null : _iniciarColeta,
            icon: _iniciando
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: const Text('Iniciar coleta'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _coletando ? _pararColeta : null,
            icon: const Icon(Icons.stop),
            label: const Text('Parar coleta'),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _abrirHistorico,
            icon: const Icon(Icons.history),
            label: const Text('Consultar histórico'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _abrirMapa,
            icon: const Icon(Icons.map),
            label: const Text('Ver mapa'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _servico.abrirConfiguracoesPermissao,
            icon: const Icon(Icons.settings),
            label: const Text('Configurações de permissão'),
          ),
        ],
      ),
    );
  }
}
