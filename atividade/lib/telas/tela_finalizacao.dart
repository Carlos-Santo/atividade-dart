import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../utils/formatar_valor.dart';
import '../widgets/layout_pedidos.dart';
import 'tela_prato_principal.dart';

class TelaFinalizacao extends StatelessWidget {
  final Pedido pedido;

  const TelaFinalizacao({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: LayoutPedidos(
        titulo: 'Resumo do pedido',
        etapa: 5,
        onSelecionarPedido: (outroPedido) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TelaFinalizacao(pedido: outroPedido),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF475569),
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              'Pedido #${pedido.id.toString().padLeft(3, '0')}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pedido realizado com sucesso!',
              textAlign: TextAlign.center,
            ),
            const Divider(height: 32),
            _linha('Prato principal', pedido.prato.nome, pedido.prato.valor),
            _linha('Bebida', pedido.bebida.nome, pedido.bebida.valor),
            _linha('Sobremesa', pedido.sobremesa.nome, pedido.sobremesa.valor),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatarValor(pedido.total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Pagamento: ${pedido.pagamento}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Fazer novo pedido'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(String categoria, String nome, double valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(categoria, style: TextStyle(color: Colors.grey.shade600)),
                Text(nome, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(formatarValor(valor)),
        ],
      ),
    );
  }
}
