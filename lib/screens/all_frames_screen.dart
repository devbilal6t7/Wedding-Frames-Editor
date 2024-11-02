import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wedding_frames_editor/consts/assets.dart';
import 'package:wedding_frames_editor/providers/frames_provider.dart';
import 'package:wedding_frames_editor/models/frame_model.dart';
import '../consts/app_colors.dart';
import 'couple_editing_screen.dart';
import 'editing_screen.dart';

class DetailScreen extends StatefulWidget {
  final String categoryId;
  final String title;

  const DetailScreen({super.key, required this.categoryId, required this.title});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  void _showImagePickerOptions(BuildContext context, FrameModel frame) {
    final parentContext = context;
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
                leading: Image.asset(WeddingAssets.gallery, height: 25,width: 25,),
                title: const Text("Choose From Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(parentContext, ImageSource.gallery, frame, widget.categoryId);
                },
              ),
              ListTile(
                leading: Image.asset(WeddingAssets.camera, height: 25,width: 25,),
                title: const Text("Take With Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(parentContext, ImageSource.camera, frame, widget.categoryId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source,
      FrameModel frame, String categoryId) async {
    final picker = ImagePicker();

    if (categoryId == '1') {
      final XFile? image1 = await picker.pickImage(source: source);

      if (image1 == null) return;

      final XFile? image2 = await picker.pickImage(source: source);

      if (image2 != null && Navigator.of(context, rootNavigator: true).mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoupleEditingScreen(
              frame: frame,
              imagePath1: image1.path,
              imagePath2: image2.path,
              categoryId: categoryId,
            ),
          ),
        );
      }
    } else {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null && Navigator.of(context, rootNavigator: true).mounted) {
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: WeddingColors.mainColor,
      ),
      body: FutureBuilder(
        future: Provider.of<FramesProvider>(context, listen: false)
            .fetchFrames(widget.categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: WeddingColors.mainColor));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading frames"));
          } else {
            final frames = Provider.of<FramesProvider>(context).getFrames(widget.categoryId);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: frames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showImagePickerOptions(context, frames[index]),
                    child: _buildFrameItem(frames[index]),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFrameItem(FrameModel frame) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        frame.frameImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 60);
        },
      ),
    );
  }
}
