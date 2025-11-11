import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

/// Widget que muestra el banner de AdMob con diseño integrado
class AdMobBannerWidget extends StatefulWidget {
  const AdMobBannerWidget({super.key});

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  final AdMobService _adMobService = AdMobService();

  @override
  Widget build(BuildContext context) {
    if (!_adMobService.isBannerLoaded || _adMobService.bannerAd == null) {
      return const SizedBox.shrink(); // No mostrar nada si no está cargado
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[900]!, Colors.purple[700]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: _adMobService.bannerAd!.size.width.toDouble(),
          height: _adMobService.bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _adMobService.bannerAd!),
        ),
      ),
    );
  }
}
