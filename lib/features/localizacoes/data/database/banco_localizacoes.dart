import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Abre o banco SQLite e cria a tabela de localizações.
///
/// Existe uma única instância (singleton) para que todo o app reutilize a
/// mesma conexão.
class BancoLocalizacoes {
  BancoLocalizacoes._();

  static final BancoLocalizacoes instancia = BancoLocalizacoes._();

  static const nomeArquivo = 'localizacoes.db';
  static const versao = 1;
  static const tabela = 'localizacoes';

  /// Guarda o Future da abertura (e não o Database) para que chamadas
  /// simultâneas esperem a mesma abertura em vez de abrir o banco duas vezes.
  Future<Database>? _abertura;

  Future<Database> get banco async {
    final existente = _abertura;
    if (existente != null) return existente;

    final abertura = _abrir();
    _abertura = abertura;
    try {
      return await abertura;
    } catch (_) {
      // Se a abertura falhar, descarta o Future para permitir nova tentativa.
      _abertura = null;
      rethrow;
    }
  }

  Future<Database> _abrir() async {
    final caminho = join(await getDatabasesPath(), nomeArquivo);
    return openDatabase(caminho, version: versao, onCreate: _criarTabelas);
  }

  /// Executado só na primeira vez, quando o arquivo do banco ainda não existe.
  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE $tabela (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        precisao REAL NOT NULL,
        instante TEXT NOT NULL
      )
    ''');
  }
}
