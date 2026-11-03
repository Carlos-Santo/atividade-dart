import 'package:flutter/material.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../widgets/item_localizacao.dart';

/// Histórico com as últimas 100 localizações.
class TelaLocalizacoes extends StatefulWidget {
  const TelaLocalizacoes({super.key, required this.coletaAtiva});

  /// Usado para avisar, na confirmação, que novos registros continuarão
  /// sendo salvos.
  final bool coletaAtiva;

  @override
  State<TelaLocalizacoes> createState() => _TelaLocalizacoesState();
}

class _TelaLocalizacoesState extends State<TelaLocalizacoes> {
  final _repositorio = RepositorioLocalizacoes();
  late Future<List<Localizacao>> _localizacoes;

  @override
  void initState() {
    super.initState();
    _localizacoes = _repositorio.consultarRecentes();
  }

  /// Consulta de novo o banco. A coleta não é afetada, pois a assinatura do
  /// stream fica na tela de coleta.
  Future<void> _atualizar() async {
    final consulta = _repositorio.consultarRecentes();
    setState(() {
      _localizacoes = consulta;
    });
    try {
      await consulta;
    } catch (_) {
      // O erro é exibido pelo FutureBuilder.
    }
  }

  Future<void> _confirmarLimpeza() async {
    final aviso = widget.coletaAtiva
        ? '\n\nA coleta está ativa: novos registros continuarão sendo salvos.'
        : '';

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: Text(
          'Todas as localizações salvas serão apagadas, inclusive as que '
          'não aparecem na lista. Esta operação é permanente.$aviso',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar histórico'),
          ),
        ],
      ),
    );

    // Fechar o diálogo tocando fora devolve null.
    if (confirmou != true) return;
    await _limpar();
  }

  Future<void> _limpar() async {
    try {
      await _repositorio.excluirTodos();
      if (!mounted) return;
      await _atualizar();
      if (!mounted) return;
      _mostrarMensagem('Histórico apagado com sucesso.');
    } catch (erro) {
      if (!mounted) return;
      _mostrarMensagem('Erro ao apagar o histórico: $erro');
    }
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            onPressed: _atualizar,
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _confirmarLimpeza,
            tooltip: 'Limpar histórico',
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizar,
        child: FutureBuilder<List<Localizacao>>(
          future: _localizacoes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _textoRolavel(
                'Erro ao consultar o histórico.\n${snapshot.error}',
              );
            }

            final localizacoes = snapshot.data;
            if (localizacoes == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (localizacoes.isEmpty) {
              return _textoRolavel('Nenhuma localização salva.');
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: localizacoes.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, indice) => ItemLocalizacao(
                localizacao: localizacoes[indice],
                destaque: indice == 0,
              ),
            );
          },
        ),
      ),
    );
  }

  /// O RefreshIndicator só funciona com algo rolável, por isso até as
  /// mensagens ficam dentro de um ListView.
  Widget _textoRolavel(String texto) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [Text(texto, textAlign: TextAlign.center)],
    );
  }
}
