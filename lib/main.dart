import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';

void main() {
  // O sqflite só funciona no Android/iOS. No navegador (usado só para testes)
  // é preciso trocar a fábrica de bancos pela versão web (SQLite em WebAssembly).
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const App());
}
