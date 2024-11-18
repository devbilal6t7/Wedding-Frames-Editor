import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wedding_frames_editor/ads/ad_provider.dart';
import 'package:wedding_frames_editor/consts/app_colors.dart';
import '../consts/assets.dart';
import '../widgets/app_localizations.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<FileSystemEntity> _images = [];
  late FileSystemEntity _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
    AdProvider.instance.loadInterstitialAd(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      AdProvider.instance.loadBanner(
        MediaQuery.of(context).size.width.toInt(),
        100,
      );
      print('AdProvider initialized.');
    } catch (e) {
      print('Error initializing AdProvider: $e');
    }
  }
  final AdProvider _adProvider = AdProvider.instance;
  void _handleClick() async {
    ClickCounter.incrementClick();

    if (ClickCounter.clickCount == 3) {
      await _adProvider.justshowInterstitialAd(context, () {
        ClickCounter.resetClickCount();
      });
    } else {
      print("Click count: ${ClickCounter.clickCount}");
    }
  }

  Future<void> _loadImages() async {
    try {
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/wedding_frames';
      final dir = Directory(path);
      if (await dir.exists()) {
        final files =
        dir.listSync().where((item) => item.path.endsWith(".png")).toList();
        setState(() {
          _images = files;
        });
        print('Loaded ${_images.length} images.');
      } else {
        print('Directory does not exist: $path');
      }
    } catch (e) {
      print("Error loading images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: WeddingColors.mainColor,
        title: Text(
          AppLocalizations.of(context).translate('downloadSaved'),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: _images.isEmpty
          ? Center(
        child: Text(
          AppLocalizations.of(context).translate('noImageSaved'),
          style: const TextStyle(fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                _selectedImage = _images[index];

                _showExportDialog();
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_images[index].path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        height: 100,
        child: AdProvider.instance.getBannerAdWidget(),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: WeddingColors.mainColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(WeddingAssets.export, height: 30, width: 30),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context).translate('selectOption'),
              ),
              const SizedBox(height: 20),
              _buildDialogButton(
                AppLocalizations.of(context).translate('expand'),
                WeddingAssets.expand,
                    () {
                      _handleClick();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImagePreviewScreen(image: _selectedImage),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildDialogButton(
                AppLocalizations.of(context).translate('delete'),
                WeddingAssets.delete,
                    () {
                      _handleClick();
                  Navigator.pop(context);
                  _deleteImage(_selectedImage);
                },
              ),
              const SizedBox(height: 10),
              _buildDialogButton(
                AppLocalizations.of(context).translate('shareWithFriends'),
                WeddingAssets.share,
                    () {
                      _handleClick();
                  Navigator.pop(context);
                  _shareImage(_selectedImage);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(String text, String icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        shape: OutlineInputBorder(
          borderSide: BorderSide(color: WeddingColors.mainColor, width: 2),
        ),
        leading: Image.asset(icon, height: 24, width: 24),
        title: Text(text),
        onTap: onPressed,
      ),
    );
  }

  Future<void> _deleteImage(FileSystemEntity image) async {
    try {
      final file = File(image.path);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          _images.remove(image);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('deletedImage'),
            ),
          ),
        );
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  Future<void> _shareImage(FileSystemEntity image) async {
    try {
      final file = File(image.path);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: AppLocalizations.of(context).translate('checkOut'),
        );
      }
    } catch (e) {
      print("Error sharing image: $e");
    }
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final FileSystemEntity image;

  const ImagePreviewScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: WeddingColors.mainColor,
        title: Text(
          AppLocalizations.of(context).translate('downloadedImage'),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.file(
          File(image.path),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
