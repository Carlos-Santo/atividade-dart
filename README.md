# Localizações — Atividade 1

Programação para Dispositivos Móveis I — Prof. Arley — Fatec

## Integrantes

- Carlos Santo

## Sobre

Aplicativo Flutter (Android) que coleta a localização do aparelho a cada 20 segundos
por meio de um stream, salva as posições em SQLite e mostra o histórico em uma lista
e em um mapa interativo (OpenStreetMap).

## Como executar

```bash
flutter pub get
flutter run
```

## Estrutura

```
lib/
├── main.dart
├── app.dart
└── features/localizacoes/
    ├── models/localizacao.dart
    ├── data/
    │   ├── database/banco_localizacoes.dart
    │   └── repositories/repositorio_localizacoes.dart
    ├── services/
    │   ├── servico_localizacao.dart
    │   └── cache_mapa.dart
    └── presentation/
        ├── screens/ (tela_coleta, tela_localizacoes, tela_mapa)
        └── widgets/ (item_localizacao, mapa_localizacoes)
```

## Pacotes

| Pacote | Uso |
| --- | --- |
| geolocator | Permissões, stream de posições e serviço em primeiro plano |
| permission_handler | Permissão de notificação (Android 13+) |
| sqflite / path | Banco `localizacoes.db` |
| flutter_map / latlong2 | Mapa e coordenadas |
| path_provider | Pasta privada para o cache do mapa |
| intl | Formatação de data e hora |

Dados do mapa © colaboradores do OpenStreetMap.
