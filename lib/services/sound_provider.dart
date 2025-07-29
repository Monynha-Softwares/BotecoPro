import 'package:flutter/material.dart';
import 'sound_service.dart';

class SoundProvider with ChangeNotifier {
  final SoundService _soundService = SoundService();
  
  SoundProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _soundService.init();
    notifyListeners();
  }
  
  bool get isSoundEnabled => _soundService.isSoundEnabled;
  
  Future<void> toggleSound(bool enabled) async {
    await _soundService.toggleSound(enabled);
    notifyListeners();
  }
  
  // Sound effect methods
  Future<void> playMesaAberta() async => await _soundService.playMesaAberta();
  Future<void> playMesaFechada() async => await _soundService.playMesaFechada();
  Future<void> playPedidoAdicionado() async => await _soundService.playPedidoAdicionado();
  Future<void> playPedidoEntregue() async => await _soundService.playPedidoEntregue();
  Future<void> playVendaFechada() async => await _soundService.playVendaFechada();
  Future<void> playProdutoAdicionado() async => await _soundService.playProdutoAdicionado();
  Future<void> playSucesso() async => await _soundService.playSucesso();
  Future<void> playErro() async => await _soundService.playErro();
  Future<void> playNotificacao() async => await _soundService.playNotificacao();
  Future<void> playNavegacao() async => await _soundService.playNavegacao();
}