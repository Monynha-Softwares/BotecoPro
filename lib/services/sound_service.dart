import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  // Singleton instance
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();
  
  // Audio player instances
  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  
  // Audio cache to preload sounds
  final AudioCache _cache = AudioCache(prefix: 'assets/sounds/');

  static const List<String> _soundEffectNames = [
    'mesa_aberta',
    'mesa_fechada',
    'pedido_adicionado',
    'pedido_entregue',
    'venda_fechada',
    'produto_adicionado',
    'sucesso',
    'erro',
    'notificacao',
    'navegacao',
  ];
  
  // Initialize sound service
  Future<void> init() async {
    await _loadSoundPreference();
    // Preload all sounds
    await _cache.loadAll(
      _soundEffectNames.map((name) => '$name.mp3').toList(),
    );
  }
  
  Future<void> _loadSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
  }
  
  Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }
  
  bool get isSoundEnabled => _soundEnabled;
  
  Future<void> playSound(String soundName) async {
    if (!_soundEnabled) return;
    
    try {
      await _player.stop(); // Stop any currently playing sound
      await _player.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }
  
  // Sound effects for different actions
  Future<void> playMesaAberta() async => await playSound('mesa_aberta');
  Future<void> playMesaFechada() async => await playSound('mesa_fechada');
  Future<void> playPedidoAdicionado() async => await playSound('pedido_adicionado');
  Future<void> playPedidoEntregue() async => await playSound('pedido_entregue');
  Future<void> playVendaFechada() async => await playSound('venda_fechada');
  Future<void> playProdutoAdicionado() async => await playSound('produto_adicionado');
  Future<void> playSucesso() async => await playSound('sucesso');
  Future<void> playErro() async => await playSound('erro');
  Future<void> playNotificacao() async => await playSound('notificacao');
  Future<void> playNavegacao() async => await playSound('navegacao');
}