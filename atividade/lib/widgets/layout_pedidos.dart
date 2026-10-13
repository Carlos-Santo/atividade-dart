import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../services/pedidos_store.dart';
import 'painel_pedido.dart';

class LayoutPedidos extends StatelessWidget {
  final Widget child;
  final String titulo;
  final int etapa;
  final ValueChanged<Pedido> onSelecionarPedido;

  const LayoutPedidos({
    super.key,
    required this.child,
    required this.titulo,
    required this.etapa,
    required this.onSelecionarPedido,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            tooltip: 'Novo pedido',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: const Icon(Icons.add_shopping_cart),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final historico = _HistoricoPedidos(
              onSelecionarPedido: onSelecionarPedido,
            );

            final conteudo = Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: PainelPedido(child: child),
                ),
              ),
            );

            if (constraints.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: conteudo),
                  SizedBox(width: 300, child: historico),
                ],
              );
            }

            return Column(
              children: [
                Expanded(child: conteudo),
                SizedBox(height: 190, child: historico),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoricoPedidos extends StatelessWidget {
  final ValueChanged<Pedido> onSelecionarPedido;

  const _HistoricoPedidos({required this.onSelecionarPedido});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pedidosStore,
      builder: (context, _) {
        final pedidos = pedidosStore.pedidos;

        return Container(
          margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meus pedidos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${pedidos.length} pedido(s)',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const Divider(height: 24),
              Expanded(
                child: pedidos.isEmpty
                    ? Center(
                        child: Text(
                          'Seus pedidos finalizados aparecerão aqui.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidos[index];

                          return Card(
                            elevation: 0,
                            color: const Color(0xFFF3F4F6),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              title: Text(
                                'Pedido #${pedido.id.toString().padLeft(3, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${pedido.prato.nome}\n'
                                '${pedido.data.hour.toString().padLeft(2, '0')}:'
                                '${pedido.data.minute.toString().padLeft(2, '0')}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => onSelecionarPedido(pedido),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
