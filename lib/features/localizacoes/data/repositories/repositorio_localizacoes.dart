import '../../models/localizacao.dart';
import '../database/banco_localizacoes.dart';

/// Único ponto do app que faz operações na tabela de localizações.
/// As telas usam este repositório e nunca executam SQL diretamente.
class RepositorioLocalizacoes {
  RepositorioLocalizacoes({BancoLocalizacoes? banco})
    : _banco = banco ?? BancoLocalizacoes.instancia;

  final BancoLocalizacoes _banco;

  /// Quantidade de registros exibidos na lista e no mapa.
  static const limiteConsulta = 100;

  /// Insere uma localização e devolve o id gerado.
  Future<int> inserir(Localizacao localizacao) async {
    final db = await _banco.banco;
    return db.insert(BancoLocalizacoes.tabela, localizacao.toMap());
  }

  /// Devolve as últimas localizações, da mais recente para a mais antiga.
  /// O limite vale só para a consulta: nada é apagado do banco.
  Future<List<Localizacao>> consultarRecentes({
    int limite = limiteConsulta,
  }) async {
    final db = await _banco.banco;
    final linhas = await db.query(
      BancoLocalizacoes.tabela,
      orderBy: 'id DESC',
      limit: limite,
    );
    return linhas.map(Localizacao.fromMap).toList();
  }

  /// Apaga todas as linhas, mantendo a tabela e o arquivo do banco.
  /// Devolve a quantidade de linhas removidas.
  Future<int> excluirTodos() async {
    final db = await _banco.banco;
    return db.delete(BancoLocalizacoes.tabela);
  }
}
