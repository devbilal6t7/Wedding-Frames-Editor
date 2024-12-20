import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wedding_frames_editor/ads/ad_units.dart';
import 'package:wedding_frames_editor/consts/app_colors.dart';
import 'package:wedding_frames_editor/consts/assets.dart';
import 'package:wedding_frames_editor/screens/side_drawer.dart';
import 'package:wedding_frames_editor/providers/frames_provider.dart';
import '../ads/ad_provider.dart';
import '../models/frame_model.dart';
import '../providers/frame_category_provider.dart';
import '../widgets/app_localizations.dart';
import 'all_frames_screen.dart';
import 'couple_editing_screen.dart';
import 'couple_landscape_mode.dart';
import 'editing_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  Future<void> _refreshCategories() async {
    await Provider.of<CategoryProvider>(context, listen: false)
        .fetchCategories();
  }

  Future<void> _loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: AdUnitIds.interstitialAdUnitId, // Replace with your AdMob Interstitial Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd(VoidCallback onAdDismissed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); // Load the next interstitial ad
          onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onAdDismissed();
        },
      );
      _interstitialAd!.show();
    } else {
      onAdDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context).translate('appBarHome'),
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: WeddingColors.mainColor,
        leading: IconButton(
          icon: Image.asset(
            WeddingAssets.menu,
            height: 22,
            width: 22,
          ),
          onPressed: () {
            _key.currentState?.openDrawer();
          },
        ),
      ),
      drawer: const SideDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshCategories,
        color: WeddingColors.mainColor,
        backgroundColor: Colors.white,
        child: FutureBuilder(
          future: Provider.of<CategoryProvider>(context, listen: false)
              .fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            } else if (snapshot.hasError) {
              return RefreshIndicator(
                onRefresh: _refreshCategories,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).translate('checkInternet'),
                  ),
                ),
              );
            } else {
              final categories =
                  Provider.of<CategoryProvider>(context).categories;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: categories
                      .map((category) => Column(
                    children: [
                      _buildCategoryCard(
                          category.categoryName, category.categoryId),
                      const SizedBox(height: 16),
                    ],
                  ))
                      .toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            3,
                (index) => Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: double.infinity,
                    height:
                    230.0, // Set height to match _buildCategoryCard height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String categoryId) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoryId == "1")
              Text(
                AppLocalizations.of(context).translate('coupleFrames'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (categoryId == "2")
              Text(
                AppLocalizations.of(context).translate('weddingSolo'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              )
            else
              Text(
                AppLocalizations.of(context).translate('anniversaryFrames'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            const SizedBox(height: 20),
            FutureBuilder(
              future: Provider.of<FramesProvider>(context, listen: false)
                  .fetchFrames(categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildFramesShimmer();
                } else if (snapshot.hasError) {
                  return Text(AppLocalizations.of(context)
                      .translate('errorLoading'));
                } else {
                  final frames = Provider.of<FramesProvider>(context)
                      .getFrames(categoryId);
                  return _buildFramesRow(frames, categoryId);
                }
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showInterstitialAd(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllFramesScreen(
                          categoryId: categoryId,
                          title: title,
                        ),
                      ),
                    );
                  });
                },
                child: Text(
                  AppLocalizations.of(context).translate('viewAll'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFramesRow(List<FrameModel> frames, String categoryId) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: frames.map((frame) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                _showInterstitialAd(() {
                  _showImagePickerOptions(context, frame, categoryId);
                });
              },
              child: _buildFrameThumbnail(
                frame.frameImage,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  Widget _buildFramesShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          3,
              (index) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 120,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions(
      BuildContext context, FrameModel frame, String categoryId) {
    final parentContext = context;

    // Ensure AdProvider loads the banner
    AdProvider.instance.loadBanner(
      MediaQuery.of(context).size.width.toInt(),
      50, // Adjust banner height
    );

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Image.asset(
                  WeddingAssets.gallery,
                  height: 25,
                  width: 25,
                ),
                title: Text(
                  AppLocalizations.of(context).translate('chooseFromGallery'),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(
                    parentContext,
                    ImageSource.gallery,
                    frame,
                    categoryId,
                    frame.type,
                  );
                },
              ),
              ListTile(
                leading: Image.asset(
                  WeddingAssets.camera,
                  height: 25,
                  width: 25,
                ),
                title: Text(
                  AppLocalizations.of(context).translate('takeWithCamera'),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(
                    parentContext,
                    ImageSource.camera,
                    frame,
                    categoryId,
                    frame.type,
                  );
                },
              ),
              AdProvider.instance.isLoading
                  ? AdProvider.instance.getBannerAdWidget()
                  : const SizedBox(height: 0,),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source,
      FrameModel frame, String categoryId, String type) async {
    final picker = ImagePicker();


    if (categoryId == '1') {
      final List<XFile> images = await picker.pickMultiImage(limit: 2);

      if (images.length == 2 && frame.type.contains("p")) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoupleEditingScreen(
              frame: frame,
              imagePath1: images[0].path,
              imagePath2: images[1].path,
              categoryId: categoryId,
              type: type,
            ),
          ),
        );
      } else if (images.length == 2 && frame.type.contains("l")){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoupleLandscape(
              frame: frame,
              imagePath1: images[0].path,
              imagePath2: images[1].path,
              categoryId: categoryId,
              type: type,
            ),
          ),
        );
      } else if (images.length != 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text( AppLocalizations.of(context).translate('snackBar2Images'),),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    else {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null &&
          Navigator.of(context, rootNavigator: true).mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditingScreen(
              frame: frame,
              imagePath: pickedFile.path,
              categoryId: categoryId,
            ),
          ),
        );
      }
    }
  }



  Widget _buildFrameThumbnail(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 120,
        width: 90,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 120,
            width: 90,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }


}

