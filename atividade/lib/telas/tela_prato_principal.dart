import 'package:flutter/material.dart';

import '../models/item_cardapio.dart';
import '../utils/formatar_valor.dart';
import '../widgets/layout_pedidos.dart';
import 'tela_bebida.dart';
import 'tela_finalizacao.dart';

class TelaPratoPrincipal extends StatefulWidget {
  const TelaPratoPrincipal({super.key});

  @override
  State<TelaPratoPrincipal> createState() => _TelaPratoPrincipalState();
}

class _TelaPratoPrincipalState extends State<TelaPratoPrincipal> {
  final pratos = const [
    ItemCardapio('Hambúrguer artesanal', 28.90),
    ItemCardapio('Pizza individual', 32.50),
    ItemCardapio('Lasanha à bolonhesa', 26.00),
  ];

  ItemCardapio? selecionado;

  @override
  Widget build(BuildContext context) {
    return LayoutPedidos(
      titulo: 'Restaurante',
      etapa: 1,
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
            '1. Prato principal',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha seu prato principal.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ...pratos.map(
            (prato) => RadioListTile<ItemCardapio>(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF334155),
              title: Text(prato.nome),
              subtitle: Text(formatarValor(prato.valor)),
              value: prato,
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
                        builder: (_) => TelaBebida(prato: selecionado!),
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
