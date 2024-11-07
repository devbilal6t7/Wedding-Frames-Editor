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
import 'package:wedding_frames_editor/models/frame_model.dart';
import 'package:path_provider/path_provider.dart';
import '../consts/app_colors.dart';
import '../consts/assets.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/frames_provider.dart';
import '../widgets/app_localizations.dart';

class EditingScreen extends StatefulWidget {
  FrameModel frame;
  final String imagePath;
  final String categoryId;

  EditingScreen({
    super.key,
    required this.frame,
    required this.imagePath,
    required this.categoryId,
  });

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  final GlobalKey _captureKey = GlobalKey();
  String? _selectedImagePath;

  late double _rotationAngle = 0.0;
  Offset _imageOffset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _startOffset = Offset.zero;

  bool _isFrameLoaded = false;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.imagePath;
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

  @override
  Widget build(BuildContext context) {
    final double frameHeight = MediaQuery.of(context).size.height * 0.56;
    const double frameWidth = 355.0;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context).translate('appBarHome'),
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: WeddingColors.mainColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isFrameLoaded ? _buildFrameContent(frameWidth, frameHeight) : _buildLoadingIndicator(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomSheet: _buildStaticBottomSheet(),
    );
  }

  Widget _buildFrameContent(double frameWidth, double frameHeight) {
    return RepaintBoundary(
      key: _captureKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: frameHeight,
            width: frameWidth,
            decoration: const BoxDecoration(),
            clipBehavior: Clip.hardEdge,
            child: GestureDetector(
              onScaleStart: (details) {
                _initialFocalPoint = details.focalPoint;
                _startOffset = _imageOffset;
              },
              onScaleUpdate: (details) {
                setState(() {
                  const rotationDampingFactor = 0.009;
                  // Update rotation angle
                  _rotationAngle += details.rotation * rotationDampingFactor;
                  // Calculate movement offset
                  final Offset offsetDelta = details.focalPoint - _initialFocalPoint;
                  _imageOffset = _startOffset + offsetDelta;
                });
              },
              child: Transform.translate(
                offset: _imageOffset,
                child: Transform.rotate(
                  angle: _rotationAngle,
                  child: PhotoView(
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    imageProvider: FileImage(File(_selectedImagePath!)),
                    minScale: PhotoViewComputedScale.contained * 0.4,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    basePosition: Alignment.center,
                  ),
                ),
              ),
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
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(color: WeddingColors.mainColor),
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
          _buildIconButton(WeddingAssets.editImage,
              AppLocalizations.of(context).translate('editPhoto'), () {
                _pickNewImage();
              }),
          _buildIconButton(WeddingAssets.editFrame,
              AppLocalizations.of(context).translate('editFrame'), () {
                _openFramesBottomSheet(widget.categoryId);
              }),
          _buildIconButton(WeddingAssets.export,
              AppLocalizations.of(context).translate('export'), () {
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
                        _loadFrame(); // Reload the new frame image
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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
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
              Text(AppLocalizations.of(context).translate('selectOption'),
                  style: TextStyle(fontSize: 18)),
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
        SnackBar(content: Text(AppLocalizations.of(context).translate('snackBarErrorSaving'))),
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
        await Share.shareXFiles([XFile(file.path)],
            text: AppLocalizations.of(context).translate('checkOut'));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('snackBarErrorSharing'))),
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
