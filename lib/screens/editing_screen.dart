import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wedding_frames_editor/models/frame_model.dart';
import 'package:path_provider/path_provider.dart';
import '../consts/app_colors.dart';
import '../consts/assets.dart';
import 'package:permission_handler/permission_handler.dart';

class EditingScreen extends StatefulWidget {
  final FrameModel frame;
  final String imagePath;

  const EditingScreen({super.key, required this.frame, required this.imagePath});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  final GlobalKey _captureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    const double frameHeight = 500.0;
    const double frameWidth = 355.0;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Wedding Frames Editor',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: WeddingColors.mainColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                key: _captureKey,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(),
                      clipBehavior: Clip.hardEdge,
                      height: frameHeight,
                      width: frameWidth,
                      child: PhotoView(
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        imageProvider: FileImage(File(widget.imagePath)),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        basePosition: Alignment.center,
                      ),
                    ),
                    IgnorePointer(
                      child: Image.network(
                        widget.frame.frameImage,
                        width: frameWidth,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomSheet: _buildStaticBottomSheet(),
    );
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
          _buildIconButton(WeddingAssets.editImage, 'Edit Photo', () {
            // Implement Edit Photo action
          }),
          _buildIconButton(WeddingAssets.editFrame, 'Edit Frame', () {
            // Implement Edit Frame action
          }),
          _buildIconButton(WeddingAssets.export, 'Export', () {
            _showExportDialog();
          }),
        ],
      ),
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

  // Show Export Options Dialog
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
              const Text('Select an Option', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              _buildDialogButton(
                'Download/Save',
                WeddingAssets.download,
                () {
                  _saveImage();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _buildDialogButton(
                'Share With Friends',
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
            borderSide: BorderSide(color: WeddingColors.mainColor, width: 2)),
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
                const SnackBar(content: Text('Image saved to gallery')));
          }
          final directory = await getExternalStorageDirectory();
          final path = '${directory?.path}/wedding_frames';
          await Directory(path).create(recursive: true);

          final filePath = '$path/wedding_frame_${DateTime.now().millisecondsSinceEpoch}.png';


        }
      }
    } catch (e) {
      print("Error saving image: $e");
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
        await Share.shareXFiles([XFile(file.path)],
            text: 'Check out my wedding frame!');
      }
    } catch (e) {
      print("Error sharing image: $e");
    }
  }

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _captureKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing image: $e");
      return null;
    }
  }
}
