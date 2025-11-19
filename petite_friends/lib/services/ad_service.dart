import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  // Test Ad Unit IDs (replace with real IDs in production)
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    return '';
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    return '';
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    return '';
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await MobileAds.instance.initialize();

    // Set request configuration for testing
    final configuration = RequestConfiguration(
      testDeviceIds: ['YOUR_TEST_DEVICE_ID'], // Add your test device ID
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);

    _initialized = true;
  }

  // Load Rewarded Ad
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _setupRewardedAdCallbacks();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  void _setupRewardedAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Preload next ad
      },
    );
  }

  // Show Rewarded Ad
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
      await Future.delayed(const Duration(seconds: 2)); // Wait for ad to load
    }

    if (_rewardedAd == null) {
      return false;
    }

    bool rewarded = false;

    await _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
      },
    );

    return rewarded;
  }

  // Load Interstitial Ad
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _setupInterstitialAdCallbacks();
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _setupInterstitialAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Preload next ad
      },
    );
  }

  // Show Interstitial Ad
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      await loadInterstitialAd();
      await Future.delayed(const Duration(seconds: 2)); // Wait for ad to load
    }

    await _interstitialAd?.show();
  }

  // Create Banner Ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
  }

  // Dispose
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}

// Ad Helper Widget for Banner Ads
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdService().createBannerAd()
      ..load().then((_) {
        setState(() {
          _isAdLoaded = true;
        });
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
