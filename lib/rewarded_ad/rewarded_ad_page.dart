import 'package:flutter/material.dart';
import 'package:google_ads/rewarded_ad/countdown_timer.dart';
import 'package:google_ads/util.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdPage extends StatefulWidget {
  const RewardedAdPage({super.key});

  @override
  RewardedAdPageState createState() => RewardedAdPageState();
}

class RewardedAdPageState extends State<RewardedAdPage> {
  final CountdownTimer _countdownTimer = CountdownTimer();
  var _showWatchVideoButton = false;
  var _coins = 0;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _countdownTimer.addListener(() => setState(() {
          if (_countdownTimer.isComplete) {
            _showWatchVideoButton = true;
            _coins += 1;
          } else {
            _showWatchVideoButton = false;
          }
        }));
    _startNewGame();
  }

  void _startNewGame() {
    _loadAd();
    _countdownTimer.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.blueAccent,
        ),
        body: Stack(
          children: [
            const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Demo Game',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )),
            Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_countdownTimer.isComplete
                        ? 'Game over!'
                        : '${_countdownTimer.timeLeft} seconds left!'),
                    Visibility(
                      visible: _countdownTimer.isComplete,
                      child: TextButton(
                        onPressed: () {
                          _startNewGame();
                        },
                        child: const Text('Play Again'),
                      ),
                    ),
                    Visibility(
                        visible: _showWatchVideoButton,
                        child: TextButton(
                          onPressed: () {
                            setState(() => _showWatchVideoButton = false);

                            _rewardedAd?.show(onUserEarnedReward:
                                (AdWithoutView ad, RewardItem rewardItem) {
                              // ignore: avoid_print
                              print('Reward amount: ${rewardItem.amount}');
                              setState(
                                  () => _coins += rewardItem.amount.toInt());
                            });
                          },
                          child:
                              const Text('Watch video for additional 10 coins'),
                        ))
                  ],
                )),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text('Coins: $_coins')),
            ),
          ],
        ));
  }

  /// Loads a rewarded ad.
  void _loadAd() {
    RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                ad.dispose();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {});

          // Keep a reference to the ad so you can show it later.
          _rewardedAd = ad;
        }, onAdFailedToLoad: (LoadAdError error) {
          // ignore: avoid_print
          print('RewardedAd failed to load: $error');
        }));
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _countdownTimer.dispose();
    super.dispose();
  }
}
