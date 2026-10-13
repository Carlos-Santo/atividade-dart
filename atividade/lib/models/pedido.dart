import 'item_cardapio.dart';

class Pedido {
  final int id;
  final ItemCardapio prato;
  final ItemCardapio bebida;
  final ItemCardapio sobremesa;
  final String pagamento;
  final DateTime data;

  const Pedido({
    required this.id,
    required this.prato,
    required this.bebida,
    required this.sobremesa,
    required this.pagamento,
    required this.data,
  });

  double get total => prato.valor + bebida.valor + sobremesa.valor;
}
