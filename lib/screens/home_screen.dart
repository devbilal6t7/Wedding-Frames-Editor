import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wedding_frames_editor/consts/app_colors.dart';
import 'package:wedding_frames_editor/consts/assets.dart';
import 'package:wedding_frames_editor/screens/side_drawer.dart';
import 'package:wedding_frames_editor/providers/frames_provider.dart';
import '../models/frame_model.dart';
import '../providers/frame_category_provider.dart';
import 'all_frames_screen.dart';
import 'editing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  Future<void> _refreshCategories() async {
    await Provider.of<CategoryProvider>(context, listen: false)
        .fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Wedding Frames Editor',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: WeddingColors.mainColor,
        leading: IconButton(
          icon: Image.asset(
            WeddingAssets.menu,
            height: 22,
            width: 22,
          ),
          onPressed: () {
            _key.currentState?.openDrawer();
          },
        ),
      ),
      drawer: const SideDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshCategories,
        color: WeddingColors.mainColor,
        backgroundColor: Colors.white,
        child: FutureBuilder(
          future: Provider.of<CategoryProvider>(context, listen: false)
              .fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Check Your Internet Connection"),
              );
            } else {
              final categories =
                  Provider.of<CategoryProvider>(context).categories;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: categories
                      .map((category) => Column(
                            children: [
                              _buildCategoryCard(
                                  category.categoryName, category.categoryId),
                              const SizedBox(height: 16),
                            ],
                          ))
                      .toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            3,
            (index) => Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: double.infinity,
                    height:
                        230.0, // Set height to match _buildCategoryCard height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String categoryId) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder(
              future: Provider.of<FramesProvider>(context, listen: false)
                  .fetchFrames(categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildFramesShimmer();
                } else if (snapshot.hasError) {
                  return const Text("Error loading frames");
                } else {
                  final frames = Provider.of<FramesProvider>(context)
                      .getFrames(categoryId);
                  return _buildFramesRow(frames, categoryId);
                }
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        categoryId: categoryId,
                        title: title,
                      ),
                    ),
                  );
                },
                child: Text(
                  "View all",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFramesShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 120,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFramesRow(List<FrameModel> frames, String categoryId) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: frames.map((frame) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                _showImagePickerOptions(context, frame, categoryId);
              },
              child: _buildFrameThumbnail(
                frame.frameImage,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showImagePickerOptions(
      BuildContext context, FrameModel frame, String categoryId) {
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
                title: const Text("Choose From Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(
                      parentContext, ImageSource.gallery, frame, categoryId);
                },
              ),
              ListTile(
                leading: Image.asset(
                  WeddingAssets.camera,
                  height: 25,
                  width: 25,
                ),
                title: const Text("Take With Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(
                      parentContext, ImageSource.camera, frame, categoryId);
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
    final pickedFile = await picker.pickImage(source: source);

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

  Widget _buildFrameThumbnail(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        imageUrl,
        height: 120,
        width: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 60);
        },
      ),
    );
  }
}
