import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wedding_frames_editor/models/frame_model.dart';
import '../consts/app_colors.dart';

class EditingScreen extends StatefulWidget {
  final FrameModel frame;
  final String imagePath;

  const EditingScreen({super.key, required this.frame, required this.imagePath});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  @override
  void initState() {
    super.initState();
    print('This is Image Path ${widget.imagePath}');
  }

  @override
  Widget build(BuildContext context) {
    // Set frame dimensions to a fixed height and width for accurate alignment
    const double frameHeight = 400.0; // Fixed height based on frame's actual aspect ratio
    const double frameWidth = 355.0; // Fixed width for the frame

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
        child: Column(
          children: [
            const SizedBox(height: 30,),
            Stack(
              alignment: Alignment.center,
              children: [
                // Background photo viewer for the selected image
                Container(
                  height: frameHeight,
                  width: frameWidth,
                  child: PhotoView(
                    backgroundDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    imageProvider: FileImage(File(widget.imagePath)),
                    minScale: PhotoViewComputedScale.contained, // Keep image contained within the frame
                    maxScale: PhotoViewComputedScale.covered * 1.5, // Allow some zooming within frame
                    basePosition: Alignment.center,
                  ),
                ),

                // Foreground frame overlay to be placed on top
                Center(
                  child: IgnorePointer(
                    child: Image.network(
                      widget.frame.frameImage,
                      width: frameWidth,
                      fit: BoxFit.cover, // Cover the frame area exactly
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}
