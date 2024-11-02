import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../consts/app_colors.dart';
import '../consts/assets.dart';
import '../models/frame_model.dart';

class CoupleEditingScreen extends StatefulWidget {
  final FrameModel frame;
  final String imagePath1;
  final String imagePath2;
  final String categoryId;

  const CoupleEditingScreen({
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

  int _selectedImageIndex = 0;

  // Rotation angles and offsets for images
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
                    // First half of the frame (left side for image 1)
                    Positioned(
                      left: 0,
                      top: 0,
                      width: frameWidth / 2,
                      height: frameHeight,
                      child: _buildImageWithFrame(
                        _selectedImagePath1,
                        _rotationAngle1,
                        _imageOffset1,
                        0,
                        frameHeight,
                        frameWidth / 2,
                      ),
                    ),
                    // Second half of the frame (right side for image 2)
                    Positioned(
                      left: frameWidth / 2,
                      top: 0,
                      width: frameWidth / 2,
                      height: frameHeight,
                      child: _buildImageWithFrame(
                        _selectedImagePath2,
                        _rotationAngle2,
                        _imageOffset2,
                        1,
                        frameHeight,
                        frameWidth / 2,
                      ),
                    ),
                    // Overlay frame image that covers both halves
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
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          const dampingFactor = 0.5;

          if (index == 0) {
            // Adjust the position for sliding (pan)
            _imageOffset1 += details.focalPointDelta;

            // Adjust the rotation
            _rotationAngle1 += details.rotation * dampingFactor;
          } else {
            // Adjust the position for sliding (pan)
            _imageOffset2 += details.focalPointDelta;

            // Adjust the rotation
            _rotationAngle2 += details.rotation * dampingFactor;
          }
        });
      },
      child: SizedBox(
        height: frameHeight,
        width: frameWidth,
        child: Transform.translate(
          offset: index == 0 ? _imageOffset1 : _imageOffset2,
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
