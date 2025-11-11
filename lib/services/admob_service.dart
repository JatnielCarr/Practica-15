import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Servicio centralizado para manejar todos los anuncios de AdMob
/// Incluye: Banner, Intersticial y Recompensado
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Estados de carga
  bool _isInitialized = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;
  BannerAd? get bannerAd => _bannerAd;

  // ========================================
  // IDs de Anuncios (TEST IDs - Reemplazar en producción)
  // ========================================
  
  /// IDs de prueba de Google (DEBEN reemplazarse en producción)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID iOS
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID iOS
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID iOS
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  // ========================================
  // INICIALIZACIÓN
  // ========================================
  
  /// Inicializa el SDK de Google Mobile Ads
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('✅ AdMob inicializado correctamente');
      
      // Pre-cargar anuncios
      loadBannerAd();
      loadInterstitialAd();
      loadRewardedAd();
    } catch (e) {
      print('❌ Error al inicializar AdMob: $e');
    }
  }

  // ========================================
  // BANNER AD - Parte inferior de la pantalla
  // ========================================
  
  /// Carga el anuncio banner
  void loadBannerAd() {
    if (_isBannerLoaded) return;

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner, // 320x50
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          print('🎯 Banner Ad cargado');
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Error al cargar Banner: $error');
          _isBannerLoaded = false;
          ad.dispose();
          _bannerAd = null;
          
          // Reintentar después de 30 segundos
          Future.delayed(const Duration(seconds: 30), () {
            loadBannerAd();
          });
        },
        onAdOpened: (ad) => print('📱 Banner Ad abierto'),
        onAdClosed: (ad) => print('🔒 Banner Ad cerrado'),
      ),
    );

    _bannerAd?.load();
  }

  /// Libera el banner ad
  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  // ========================================
  // INTERSTITIAL AD - Pantalla completa entre niveles
  // ========================================
  
  /// Carga el anuncio intersticial
  void loadInterstitialAd() {
    if (_isInterstitialLoaded) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          print('🎬 Intersticial Ad cargado');

          // Configurar callbacks
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('📺 Intersticial mostrado');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('❌ Intersticial cerrado');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              
              // Pre-cargar el siguiente
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Error al mostrar Intersticial: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ Error al cargar Intersticial: $error');
          _isInterstitialLoaded = false;
          
          // Reintentar después de 30 segundos
          Future.delayed(const Duration(seconds: 30), () {
            loadInterstitialAd();
          });
        },
      ),
    );
  }

  /// Muestra el anuncio intersticial si está cargado
  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialLoaded || _interstitialAd == null) {
      print('⚠️ Intersticial no está listo');
      return false;
    }

    await _interstitialAd?.show();
    return true;
  }

  // ========================================
  // REWARDED AD - Video recompensado para power-ups
  // ========================================
  
  /// Carga el anuncio recompensado
  void loadRewardedAd() {
    if (_isRewardedLoaded) return;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          print('🎁 Rewarded Ad cargado');
        },
        onAdFailedToLoad: (error) {
          print('❌ Error al cargar Rewarded: $error');
          _isRewardedLoaded = false;
          
          // Reintentar después de 30 segundos
          Future.delayed(const Duration(seconds: 30), () {
            loadRewardedAd();
          });
        },
      ),
    );
  }

  /// Muestra el anuncio recompensado y retorna si se completó
  Future<bool> showRewardedAd({
    required Function(int amount, String type) onUserEarnedReward,
  }) async {
    if (!_isRewardedLoaded || _rewardedAd == null) {
      print('⚠️ Rewarded Ad no está listo');
      return false;
    }

    bool rewardEarned = false;

    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('📺 Rewarded Ad mostrado');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('❌ Rewarded Ad cerrado');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
        
        // Pre-cargar el siguiente
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Error al mostrar Rewarded: $error');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
      },
    );

    await _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        print('🎉 Recompensa ganada: ${reward.amount} ${reward.type}');
        onUserEarnedReward(reward.amount.toInt(), reward.type);
      },
    );

    return rewardEarned;
  }

  // ========================================
  // CLEANUP
  // ========================================
  
  /// Libera todos los recursos
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    
    _isBannerLoaded = false;
    _isInterstitialLoaded = false;
    _isRewardedLoaded = false;
  }
}
