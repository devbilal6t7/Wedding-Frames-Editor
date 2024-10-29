import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wedding_frames_editor/consts/app_colors.dart';
import '../consts/assets.dart';

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
  }

  Future<void> _loadImages() async {
    try {
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/wedding_frames';
      final dir = Directory(path);
      if (await dir.exists()) {
        final files = dir.listSync().where((item) => item.path.endsWith(".png")).toList();
        setState(() {
          _images = files;
        });
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
        title: const Text(
          "Downloads/Saved",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: _images.isEmpty
          ? const Center(child: Text("No images saved yet."))
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
              const Text('Select an Option', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              _buildDialogButton(
                'Expand',
                WeddingAssets.expand,
                    () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePreviewScreen(image: _selectedImage),
                        ),
                      );
                },
              ),
              const SizedBox(height: 10),
              _buildDialogButton(
                'Delete',
                WeddingAssets.delete,
                    () {
                  Navigator.pop(context);
                  _deleteImage(_selectedImage);
                },
              ),
              const SizedBox(height: 10),
              _buildDialogButton(
                'Share With Friends',
                WeddingAssets.share,
                    () {
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
            borderSide: BorderSide(color: WeddingColors.mainColor, width: 2)),
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
          const SnackBar(content: Text('Image deleted successfully.')),
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
        await Share.shareXFiles([XFile(file.path)],
            text: 'Check out this wedding frame!');
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
        title: const Text("Downloaded Image",style: TextStyle(fontSize: 18),),
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
