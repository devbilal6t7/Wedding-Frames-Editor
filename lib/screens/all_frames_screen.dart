import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wedding_frames_editor/consts/assets.dart';
import 'package:wedding_frames_editor/providers/frames_provider.dart';
import 'package:wedding_frames_editor/models/frame_model.dart';
import 'package:wedding_frames_editor/screens/couple_landscape_mode.dart';
import '../consts/app_colors.dart';
import '../widgets/app_localizations.dart';
import 'couple_editing_screen.dart';
import 'editing_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllFramesScreen extends StatefulWidget {
  final String categoryId;
  final String title;

  const AllFramesScreen(
      {super.key, required this.categoryId, required this.title});

  @override
  State<AllFramesScreen> createState() => _AllFramesScreenState();
}

class _AllFramesScreenState extends State<AllFramesScreen> {
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
                leading: Image.asset(
                  WeddingAssets.gallery,
                  height: 25,
                  width: 25,
                ),
                title: Text( AppLocalizations.of(context).translate('chooseFromGallery'),),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(parentContext, ImageSource.gallery, frame,
                      widget.categoryId, frame.type);
                },
              ),
              ListTile(
                leading: Image.asset(
                  WeddingAssets.camera,
                  height: 25,
                  width: 25,
                ),
                title: Text( AppLocalizations.of(context).translate('takeWithCamera'),),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(parentContext, ImageSource.camera, frame,
                      widget.categoryId, frame.type);
                },
              ),
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

  Widget _getAppBarTitle() {
    if (widget.categoryId == "1") {
      return Text(
        AppLocalizations.of(context).translate('coupleFrames'),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (widget.categoryId == "2") {
      return Text(
        AppLocalizations.of(context).translate('weddingSolo'),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      );
    } else {
      return Text(
        AppLocalizations.of(context).translate('anniversaryFrames'),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title:  _getAppBarTitle(),
        backgroundColor: WeddingColors.mainColor,
      ),
      body: FutureBuilder(
        future: Provider.of<FramesProvider>(context, listen: false)
            .fetchFrames(widget.categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator(color: WeddingColors.mainColor));
          } else if (snapshot.hasError) {
            return Center(child: Text( AppLocalizations.of(context).translate('errorLoading'),));
          } else {
            final frames = Provider.of<FramesProvider>(context)
                .getFrames(widget.categoryId);
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
                    onTap: () =>
                        _showImagePickerOptions(context, frames[index]),
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
      child: CachedNetworkImage(
        imageUrl: frame.frameImage,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
