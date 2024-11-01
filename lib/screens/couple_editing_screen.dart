import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../consts/app_colors.dart';
import '../consts/assets.dart';
import '../providers/frames_provider.dart';
import '../models/frame_model.dart';
import 'package:permission_handler/permission_handler.dart';

class CoupleEditingScreen extends StatefulWidget {
  final FrameModel frame;
  final String imagePath1;
  final String imagePath2;
  final String categoryId;

  CoupleEditingScreen({
    super.key,
    required this.frame,
    required this.imagePath1,
    required this.imagePath2,
    required this.categoryId,
  });

  @override
  State<CoupleEditingScreen> createState() => _CoupleEditingScreenState();
}

class _CoupleEditingScreenState extends State<CoupleEditingScreen> {
  final GlobalKey _captureKey = GlobalKey();
  late String _selectedImagePath1;
  late String _selectedImagePath2;

  int _selectedImageIndex = 0; // 0 for image1, 1 for image2

  // Transformation state variables for both images
  late double _rotationAngle1 = 0.0;
  Offset _imageOffset1 = Offset.zero;

  late double _rotationAngle2 = 0.0;
  Offset _imageOffset2 = Offset.zero;

  @override
  void initState() {
    super.initState();
    _selectedImagePath1 = widget.imagePath1;
    _selectedImagePath2 = widget.imagePath2;
  }

  void _selectImage(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double frameHeight = 500.0;
    const double frameWidth = 355.0;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Wedding Frames Editor', style: TextStyle(fontSize: 18)),
        backgroundColor: WeddingColors.mainColor,
        actions: [
          IconButton(
            icon: Icon(Icons.image, color: _selectedImageIndex == 0 ? Colors.white : Colors.grey),
            onPressed: () => _selectImage(0),
          ),
          IconButton(
            icon: Icon(Icons.image, color: _selectedImageIndex == 1 ? Colors.white : Colors.grey),
            onPressed: () => _selectImage(1),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: _captureKey,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildImageWithFrame(
                      _selectedImagePath1,
                      _rotationAngle1,
                      _imageOffset1,
                      0,
                      frameHeight,
                      frameWidth,
                    ),
                    _buildImageWithFrame(
                      _selectedImagePath2,
                      _rotationAngle2,
                      _imageOffset2,
                      1,
                      frameHeight,
                      frameWidth,
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

  Widget _buildImageWithFrame(
      String imagePath,
      double rotationAngle,
      Offset imageOffset,
      int index,
      double frameHeight,
      double frameWidth,
      ) {
    return index == _selectedImageIndex
        ? GestureDetector(
      onScaleStart: (details) {
        setState(() {
          _imageOffset1 = imageOffset;
        });
      },
      onScaleUpdate: (details) {
        setState(() {
          final dampingFactor = 0.5;
          if (index == 0) {
            _rotationAngle1 += details.rotation * dampingFactor;
            _imageOffset1 += details.focalPoint - imageOffset;
          } else {
            _rotationAngle2 += details.rotation * dampingFactor;
            _imageOffset2 += details.focalPoint - imageOffset;
          }
        });
      },
      child: SizedBox(
        height: frameHeight, // Set a fixed height constraint
        width: frameWidth,
        child: Transform.translate(
          offset: imageOffset,
          child: Transform.rotate(
            angle: rotationAngle,
            child: PhotoView(
              backgroundDecoration: const BoxDecoration(color: Colors.transparent),
              imageProvider: FileImage(File(imagePath)),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              basePosition: Alignment.center,
            ),
          ),
        ),
      ),
    )
        : Offstage();
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
            _pickNewImage();
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

  Future<void> _pickNewImage() async {
    // Implementation for picking a new image
  }

  void _showExportDialog() {
    // Export dialog logic
  }
}
