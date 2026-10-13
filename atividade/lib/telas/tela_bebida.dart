import 'package:flutter/material.dart';

import '../models/item_cardapio.dart';
import '../utils/formatar_valor.dart';
import '../widgets/layout_pedidos.dart';
import 'tela_sobremesa.dart';
import 'tela_finalizacao.dart';

class TelaBebida extends StatefulWidget {
  final ItemCardapio prato;
  final ItemCardapio? bebidaAnterior;
  final ItemCardapio? sobremesaAnterior;
  final String? pagamentoAnterior;

  const TelaBebida({
    super.key,
    required this.prato,
    this.bebidaAnterior,
    this.sobremesaAnterior,
    this.pagamentoAnterior,
  });

  @override
  State<TelaBebida> createState() => _TelaBebidaState();
}

class _TelaBebidaState extends State<TelaBebida> {
  final bebidas = const [
    ItemCardapio('Refrigerante', 7.00),
    ItemCardapio('Suco natural', 8.50),
    ItemCardapio('Água mineral', 4.00),
  ];

  ItemCardapio? selecionado;

  @override
  void initState() {
    super.initState();
    selecionado = widget.bebidaAnterior;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPedidos(
      titulo: 'Restaurante',
      etapa: 2,
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
            '2. Bebida',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha sua bebida.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ...bebidas.map(
            (bebida) => RadioListTile<ItemCardapio>(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF334155),
              title: Text(bebida.nome),
              subtitle: Text(formatarValor(bebida.valor)),
              value: bebida,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TelaSobremesa(
                          prato: widget.prato,
                          bebida: selecionado!,
                          sobremesaAnterior: widget.sobremesaAnterior,
                          pagamentoAnterior: widget.pagamentoAnterior,
                        ),
                      ),
                    );
                  },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
