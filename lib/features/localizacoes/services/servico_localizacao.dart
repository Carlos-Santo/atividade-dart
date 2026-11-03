import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Resultado da verificação feita antes de iniciar a coleta.
enum StatusPermissao {
  concedida,
  servicoDesabilitado,
  negada,
  negadaPermanentemente,
}

/// Concentra o acesso ao GPS: permissões, stream de posições e configurações.
class ServicoLocalizacao {
  /// Intervalo solicitado entre as leituras. O Android pode variar esse valor.
  static const intervalo = Duration(seconds: 20);

  /// Verifica se o GPS está ligado e pede a permissão quando necessário.
  Future<StatusPermissao> verificarPermissao() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) return StatusPermissao.servicoDesabilitado;

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    switch (permissao) {
      case LocationPermission.denied:
        return StatusPermissao.negada;
      case LocationPermission.deniedForever:
        return StatusPermissao.negadaPermanentemente;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        // No Android 13+ a notificação do serviço em primeiro plano só
        // aparece na barra se o usuário permitir notificações.
        await Permission.notification.request();
        return StatusPermissao.concedida;
      case LocationPermission.unableToDetermine:
        return StatusPermissao.negada;
    }
  }

  /// Stream contínuo de posições, com alta precisão e intervalo de 20 s.
  ///
  /// A configuração de notificação faz o plugin iniciar um serviço em primeiro
  /// plano no Android, mantendo a coleta ao minimizar o app.
  Stream<Position> obterPosicoes() {
    final configuracao = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      intervalDuration: intervalo,
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'Coleta de localização ativa',
        notificationText: 'Sua posição está sendo registrada a cada 20 s.',
        notificationChannelName: 'Coleta de localização',
        notificationIcon: AndroidResource(
          name: 'ic_notificacao',
          defType: 'drawable',
        ),
        setOngoing: true,
        enableWakeLock: true,
      ),
    );
    return Geolocator.getPositionStream(locationSettings: configuracao);
  }

  /// Abre a tela de permissões do app nas configurações do sistema.
  Future<bool> abrirConfiguracoesPermissao() => Geolocator.openAppSettings();

  /// Abre a tela do sistema para ligar o GPS.
  Future<bool> abrirConfiguracoesLocalizacao() =>
      Geolocator.openLocationSettings();
}
