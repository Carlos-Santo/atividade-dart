/// Um registro de localização salvo no banco.
class Localizacao {
  const Localizacao({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.instante,
  });

  /// Nulo enquanto o registro ainda não foi inserido (o SQLite gera o id).
  final int? id;
  final double latitude;
  final double longitude;

  /// Precisão estimada, em metros.
  final double precisao;

  /// Momento da leitura, sempre em UTC.
  final DateTime instante;

  /// Converte o objeto em um mapa com as colunas da tabela.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'precisao': precisao,
      'instante': instante.toUtc().toIso8601String(),
    };
  }

  /// Cria o objeto a partir de uma linha retornada pelo SQLite.
  factory Localizacao.fromMap(Map<String, Object?> mapa) {
    return Localizacao(
      id: mapa['id'] as int?,
      latitude: (mapa['latitude'] as num).toDouble(),
      longitude: (mapa['longitude'] as num).toDouble(),
      precisao: (mapa['precisao'] as num).toDouble(),
      instante: DateTime.parse(mapa['instante'] as String).toUtc(),
    );
  }
}
