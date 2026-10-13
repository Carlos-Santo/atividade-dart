import 'package:flutter/material.dart';

import '../models/item_cardapio.dart';
import '../models/pedido.dart';
import '../services/pedidos_store.dart';
import '../widgets/layout_pedidos.dart';
import 'tela_finalizacao.dart';

class TelaPagamento extends StatefulWidget {
  final ItemCardapio prato;
  final ItemCardapio bebida;
  final ItemCardapio sobremesa;
  final String? pagamentoAnterior;

  const TelaPagamento({
    super.key,
    required this.prato,
    required this.bebida,
    required this.sobremesa,
    this.pagamentoAnterior,
  });

  @override
  State<TelaPagamento> createState() => _TelaPagamentoState();
}

class _TelaPagamentoState extends State<TelaPagamento> {
  final formas = const [
    'Pix',
    'Cartão de crédito',
    'Cartão de débito',
    'Dinheiro',
  ];

  String? selecionado;

  @override
  void initState() {
    super.initState();
    selecionado = widget.pagamentoAnterior;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPedidos(
      titulo: 'Restaurante',
      etapa: 4,
      onSelecionarPedido: (pedido) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TelaFinalizacao(pedido: pedido)),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '4. Pagamento',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Como deseja pagar?',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ...formas.map(
            (forma) => RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF334155),
              title: Text(forma),
              value: forma,
              groupValue: selecionado,
              onChanged: (valor) {
                setState(() => selecionado = valor);
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selecionado == null
                ? null
                : () {
                    final pedido = Pedido(
                      id: pedidosStore.gerarId(),
                      prato: widget.prato,
                      bebida: widget.bebida,
                      sobremesa: widget.sobremesa,
                      pagamento: selecionado!,
                      data: DateTime.now(),
                    );

                    pedidosStore.adicionar(pedido);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TelaFinalizacao(pedido: pedido),
                      ),
                      (route) => false,
                    );
                  },
            child: const Text('Finalizar pedido'),
          ),
        ],
      ),
    );
  }
}
