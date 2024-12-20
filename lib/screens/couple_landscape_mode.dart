import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wedding_frames_editor/screens/couple_editing_screen.dart';
import '../consts/app_colors.dart';
import '../consts/assets.dart';
import '../models/frame_model.dart';
import '../providers/frames_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/app_localizations.dart';

class CoupleLandscape extends StatefulWidget {
  FrameModel frame;
  final String imagePath1;
  final String imagePath2;
  final String categoryId;
  final String type;

  CoupleLandscape({
    super.key,
    required this.frame,
    required this.imagePath1,
    required this.imagePath2,
    required this.categoryId,
    required this.type,
  });

  @override
  State<CoupleLandscape> createState() => _CoupleLandscapeState();
}

class _CoupleLandscapeState extends State<CoupleLandscape> {
  final GlobalKey _captureKey = GlobalKey();
  late String _selectedImagePath1;
  late String _selectedImagePath2;
  int _selectedImageIndex = 0;

  late double _rotationAngle1 = 0.0;
  Offset _imageOffset1 = Offset.zero;

  late double _rotationAngle2 = 0.0;
  Offset _imageOffset2 = Offset.zero;

  final ImagePicker _picker = ImagePicker();

  bool _isFrameLoaded = false;

  @override
  void initState() {
    super.initState();
    _selectedImagePath1 = widget.imagePath1;
    _selectedImagePath2 = widget.imagePath2;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFrame();
  }

  Future<void> _loadFrame() async {
    await precacheImage(NetworkImage(widget.frame.frameImage), context);
    setState(() {
      _isFrameLoaded = true;
    });
  }

  void _selectImage(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }

  Future<void> _pickNewImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (_selectedImageIndex == 0) {
          _selectedImagePath1 = pickedFile.path;
        } else {
          _selectedImagePath2 = pickedFile.path;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    bool isPortrait = widget.type.contains('p');

    final double frameWidth = isPortrait ? screenWidth : screenWidth / 2;
    final double frameHeight = screenHeight - (500 + 70);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
         AppLocalizations.of(context)
        .translate('appBarHome'),
          style: const TextStyle(fontSize: 15.5),
        ),
        backgroundColor: WeddingColors.mainColor,
        actions: [
          IconButton(
            icon: Icon(Icons.looks_one, color: _selectedImageIndex == 0 ? Colors.white : Colors.grey),
            onPressed: () => _selectImage(0),
          ),
          IconButton(
            icon: Icon(Icons.looks_two, color: _selectedImageIndex == 1 ? Colors.white : Colors.grey),
            onPressed: () => _selectImage(1),
          ),
        ],
      ),
      body: Center(
        child: _isFrameLoaded
            ? _buildContent(screenWidth, frameWidth, frameHeight, isPortrait)
            : CircularProgressIndicator(
          color: WeddingColors.mainColor,
        ),
      ),
      bottomSheet: _buildStaticBottomSheet(),
    );
  }

  Widget _buildContent(double screenWidth, double frameWidth, double frameHeight, bool isPortrait) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RepaintBoundary(
            key: _captureKey,
            child: SizedBox(
              height: frameHeight,
              width: screenWidth,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    width: frameWidth,
                    height: frameHeight,
                    child: ClipRect(
                      child: _buildImageWithFrame(
                        _selectedImagePath1,
                        _rotationAngle1,
                        _imageOffset1,
                        0,
                        frameHeight + 100,
                        frameWidth / 2,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    width: frameWidth,
                    height: frameHeight,
                    child: ClipRect(
                      child: _buildImageWithFrame(
                        _selectedImagePath2,
                        _rotationAngle2,
                        _imageOffset2,
                        1,
                        frameHeight + 100,
                        frameWidth / 2,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Image.network(
                      widget.frame.frameImage,
                      width: isPortrait ? screenWidth : screenWidth / 0.5,
                      height: frameHeight,
                      fit: isPortrait ? BoxFit.cover : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildImageWithFrame(
      String imagePath,
      double rotationAngle,
      Offset imageOffset,
      int index,
      double frameHeight,
      double frameWidth,
      ) {
    return GestureDetector(
      onScaleUpdate: (details) {
        if (_selectedImageIndex == index) {
          setState(() {
            const dampingFactor = 0.5;
            if (index == 0) {
              _imageOffset1 = _clampOffset(_imageOffset1 + details.focalPointDelta, frameWidth, frameHeight);
              _rotationAngle1 = details.rotation * dampingFactor;
            } else {
              _imageOffset2 = _clampOffset(_imageOffset2 + details.focalPointDelta, frameWidth, frameHeight);
              _rotationAngle2 = details.rotation * dampingFactor;
            }
          });
        }
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        height: frameHeight / 2,
        width: frameWidth,
        child: Transform.translate(
          offset: index == 0 ? _imageOffset1 : _imageOffset2,
          child: Transform.rotate(
            angle: rotationAngle,
            child: PhotoView.customChild(
              backgroundDecoration: const BoxDecoration(color: Colors.transparent),
              customSize: Size(frameWidth, frameHeight),
              minScale: PhotoViewComputedScale.contained * 0.5,
              maxScale: PhotoViewComputedScale.covered * 8,
              basePosition: Alignment.center,
              child: Image.file(
                File(imagePath),
                height: frameHeight / 7,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Offset _clampOffset(Offset offset, double frameWidth, double frameHeight) {
    double dx = offset.dx.clamp(-frameWidth / 4, frameWidth / 4);
    double dy = offset.dy.clamp(-frameHeight / 4, frameHeight / 4);
    return Offset(dx, dy);
  }

  Widget _buildStaticBottomSheet() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: WeddingColors.mainColor, width: 1.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconButton(WeddingAssets.swap, AppLocalizations.of(context).translate('swap'), _swapImages),
          _buildIconButton(WeddingAssets.editImage, AppLocalizations.of(context).translate('editPhoto'), _pickNewImage),
          _buildIconButton(WeddingAssets.editFrame, AppLocalizations.of(context).translate('editFrame'), () {
            _openFramesBottomSheet(widget.categoryId);
          }),
          _buildIconButton(WeddingAssets.export, AppLocalizations.of(context).translate('export'), _showExportDialog),
        ],
      ),
    );
  }

  void _swapImages() {
    setState(() {
      String temp = _selectedImagePath1;
      _selectedImagePath1 = _selectedImagePath2;
      _selectedImagePath2 = temp;
    });
  }

  void _openFramesBottomSheet(String categoryId) async {
    final framesProvider = Provider.of<FramesProvider>(context, listen: false);
    if (framesProvider.getFrames(categoryId).isEmpty) {
      await framesProvider.fetchFrames(categoryId);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        final frames = framesProvider.getFrames(categoryId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: WeddingColors.mainColor,
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).translate('allFrames'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: frames.isEmpty
                  ? Center(child: CircularProgressIndicator(color: WeddingColors.mainColor))
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: frames.length,
                itemBuilder: (BuildContext context, int index) {
                  final frame = frames[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!frame.type.contains("p")) {
                          setState(() {
                            widget.frame = widget.frame.copyWith(frameImage: frame.frameImage);
                          });
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => CoupleEditingScreen(
                                categoryId: categoryId,
                                frame: frame,
                                imagePath1: _selectedImagePath1,
                                imagePath2: _selectedImagePath2,
                                type: frame.type,
                              ),
                            ),
                          );
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            frame.frameImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(String asset, String label, VoidCallback onPressed) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Image.asset(asset, height: 24, width: 24),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(color: WeddingColors.mainColor, fontSize: 12),
        ),
      ],
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
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              _buildDialogButton(
                AppLocalizations.of(context).translate('downloadSaved'),
                WeddingAssets.download,
                    () {
                  _saveImage();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _buildDialogButton(
                AppLocalizations.of(context).translate('shareWithFriends'),
                WeddingAssets.share,
                    () {
                  _shareImage();
                  Navigator.pop(context);
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

  Future<void> _saveImage() async {
    try {
      final Uint8List? imageData = await _capturePng();
      if (imageData != null) {
        if (await _requestPermissions()) {
          final result = await ImageGallerySaverPlus.saveImage(
            imageData,
            quality: 100,
            name: "wedding_frame_${DateTime.now().millisecondsSinceEpoch}",
          );

          if (result["isSuccess"] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).translate('snackBarImageSaver'),
                ),
              ),
            );

            final directory = await getExternalStorageDirectory();
            final path = '${directory?.path}/wedding_frames';
            await Directory(path).create(recursive: true);

            final filePath = '$path/wedding_frame_${DateTime.now().millisecondsSinceEpoch}.png';
            final file = File(filePath);
            await file.writeAsBytes(imageData);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('snackBarErrorSaving')),
        ),
      );
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _shareImage() async {
    try {
      final Uint8List? imageData = await _capturePng();
      if (imageData != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/wedding_frame.png').create();
        await file.writeAsBytes(imageData);
        await Share.shareXFiles([XFile(file.path)], text: 'Check out my wedding frame!');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('snackBarErrorSharing')),
        ),
      );
    }
  }

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}
