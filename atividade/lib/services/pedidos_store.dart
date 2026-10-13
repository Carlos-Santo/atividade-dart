import 'package:flutter/foundation.dart';

import '../models/pedido.dart';

class PedidosStore extends ChangeNotifier {
  final List<Pedido> _pedidos = [];
  int _proximoId = 1;

  List<Pedido> get pedidos => List.unmodifiable(_pedidos.reversed);

  void adicionar(Pedido pedido) {
    _pedidos.add(pedido);
    notifyListeners();
  }

  int gerarId() => _proximoId++;
}

final PedidosStore pedidosStore = PedidosStore();
