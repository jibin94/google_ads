import 'package:flutter/material.dart';
import 'package:google_ads/rewarded_ad/rewarded_ad_page.dart';
import 'package:google_ads/util.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<HomePage> {
  BannerAd? bannerAd;
  bool isBannerAdReady = false;

  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;

  loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      // sets 320 x 50 banner size, you can set custom banner sizes using:
      // size: AdSize(
      //   width: 300,
      //   height: 70,
      // ),
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    bannerAd!.load();
  }

  loadInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad InterstitialAd loaded');
            interstitialAd = ad;
            interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            interstitialAd = null;
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    loadBannerAd();
    loadInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    bannerAd!.dispose();
    interstitialAd!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Google Mobile Ads',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () => showInterstitialAd(),
                child: const Text("Show Interstitial Ad"),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => showRewardedAd(),
                child: const Text("Show Rewarded Ad"),
              ),
              const Spacer(),
              SizedBox(
                height:
                    bannerAd!.size.height.toDouble(), // sets container height
                width: bannerAd!.size.width.toDouble(), // sets container width
                child: isBannerAdReady
                    ? AdWidget(
                        ad: bannerAd!, // ad must be loaded before insertion to widget tree
                      )
                    : const SizedBox(),
              ),
              const SizedBox(
                height: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        loadInterstitialAd();
      },
    );
    interstitialAd!.show();
    interstitialAd = null;
  }

  void showRewardedAd() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const RewardedAdPage()));
  }
}
