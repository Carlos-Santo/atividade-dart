import 'package:flutter/material.dart';

import '../models/item_cardapio.dart';
import '../utils/formatar_valor.dart';
import '../widgets/layout_pedidos.dart';
import 'tela_pagamento.dart';
import 'tela_finalizacao.dart';

class TelaSobremesa extends StatefulWidget {
  final ItemCardapio prato;
  final ItemCardapio bebida;
  final ItemCardapio? sobremesaAnterior;
  final String? pagamentoAnterior;

  const TelaSobremesa({
    super.key,
    required this.prato,
    required this.bebida,
    this.sobremesaAnterior,
    this.pagamentoAnterior,
  });

  @override
  State<TelaSobremesa> createState() => _TelaSobremesaState();
}

class _TelaSobremesaState extends State<TelaSobremesa> {
  final sobremesas = const [
    ItemCardapio('Pudim', 9.00),
    ItemCardapio('Sorvete', 10.50),
    ItemCardapio('Brownie', 12.00),
  ];

  ItemCardapio? selecionado;

  @override
  void initState() {
    super.initState();
    selecionado = widget.sobremesaAnterior;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPedidos(
      titulo: 'Restaurante',
      etapa: 3,
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
            '3. Sobremesa',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha sua sobremesa.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ...sobremesas.map(
            (sobremesa) => RadioListTile<ItemCardapio>(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF334155),
              title: Text(sobremesa.nome),
              subtitle: Text(formatarValor(sobremesa.valor)),
              value: sobremesa,
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
                        builder: (_) => TelaPagamento(
                          prato: widget.prato,
                          bebida: widget.bebida,
                          sobremesa: selecionado!,
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
