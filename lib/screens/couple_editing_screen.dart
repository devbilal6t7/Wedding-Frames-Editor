import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../consts/app_colors.dart';
import '../consts/assets.dart';
import '../models/frame_model.dart';
import '../providers/frames_provider.dart';

class CoupleEditingScreen extends StatefulWidget {
   FrameModel frame;
  final String imagePath1;
  final String imagePath2;
  final String categoryId;
  final String type;

   CoupleEditingScreen({
    super.key,
    required this.frame,
    required this.imagePath1,
    required this.imagePath2,
    required this.categoryId,
    required this.type,
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
    print("This is type of frame ${widget.type}");
  }

  void _selectImage(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen height to adjust the frame height dynamically
    final double screenHeight = MediaQuery.of(context).size.height;
    const double frameWidth = 355.0;
    const double toolbarHeight = 80.0;
    bool isPortrait = widget.type.contains('p');

    // Calculate frame height as a portion of screen height minus other UI elements
    final double frameHeight = screenHeight - (toolbarHeight + kToolbarHeight + 30); // Adjust as needed

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
                child: SizedBox(
                  height: frameHeight,
                  width: frameWidth,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // First half of the frame (top for portrait, left for landscape)
                      Positioned(
                        left: isPortrait ? 0 : null,
                        top: isPortrait ? 0 : null,
                        right: isPortrait ? null : 0,
                        bottom: isPortrait ? null : 0,
                        width: isPortrait ? frameWidth : frameWidth / 2,
                        height: isPortrait ? frameHeight / 2 : frameHeight,
                        child: ClipRect(
                          child: _buildImageWithFrame(
                            _selectedImagePath1,
                            _rotationAngle1,
                            _imageOffset1,
                            0,
                            isPortrait ? frameHeight / 2 : frameHeight,
                            isPortrait ? frameWidth : frameWidth / 2,
                          ),
                        ),
                      ),
                      Positioned(
                        left: isPortrait ? 0 : frameWidth / 2,
                        top: isPortrait ? frameHeight / 2 : 0,
                        width: isPortrait ? frameWidth : frameWidth / 2,
                        height: isPortrait ? frameHeight / 2 : frameHeight,
                        child: ClipRect(
                          child: _buildImageWithFrame(
                            _selectedImagePath2,
                            _rotationAngle2,
                            _imageOffset2,
                            1,
                            isPortrait ? frameHeight / 2 : frameHeight,
                            isPortrait ? frameWidth : frameWidth / 2,
                          ),
                        ),
                      ),
                      // Overlay frame image that covers both halves
                      IgnorePointer(
                        child: Image.network(
                          widget.frame.frameImage,
                          width: frameWidth,
                          height: frameHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
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
        if (_selectedImageIndex == index) {
          setState(() {
            const dampingFactor = 0.5;

            if (index == 0) {
              // Adjust position with boundary restrictions for left or top image
              _imageOffset1 = _clampOffset(_imageOffset1 + details.focalPointDelta, frameWidth, frameHeight);
              _rotationAngle1 += details.rotation * dampingFactor;
            } else {
              // Adjust position with boundary restrictions for right or bottom image
              _imageOffset2 = _clampOffset(_imageOffset2 + details.focalPointDelta, frameWidth, frameHeight);
              _rotationAngle2 += details.rotation * dampingFactor;
            }
          });
        }
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
              minScale: PhotoViewComputedScale.contained * 0.02,
              maxScale: PhotoViewComputedScale.covered * 2,
              basePosition: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }

  Offset _clampOffset(Offset offset, double frameWidth, double frameHeight) {
    // Adjust clamping to keep images within their respective half
    double dx = offset.dx.clamp(-frameWidth / 4, frameWidth / 4); // Restrict within half frame
    double dy = offset.dy.clamp(-frameHeight / 4, frameHeight / 4); // Restrict within frame height
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
          _buildIconButton(WeddingAssets.editImage, 'Edit Photo', () {
            _pickNewImage();
          }),
          _buildIconButton(WeddingAssets.editFrame, 'Edit Frame', () {
            _openFramesBottomSheet(widget.categoryId);
          }),
          _buildIconButton(WeddingAssets.export, 'Export', () {
            _showExportDialog();
          }),
        ],
      ),
    );
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
            // Title
            Container(
              clipBehavior: Clip.hardEdge,
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: WeddingColors.mainColor,
              ),
              child: const Center(
                child: Text(
                  "All Frames",
                  style: TextStyle(
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
                  ? const Center(child: CircularProgressIndicator())
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
                      setState(() {
                        widget.frame = widget.frame.copyWith(frameImage: frame.frameImage);
                      });
                      Navigator.pop(context);
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

  Future<void> _pickNewImage() async {
    // Implementation for picking a new image
  }

  void _showExportDialog() {
    // Export dialog logic
  }
}
