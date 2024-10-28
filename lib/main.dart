import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wedding_frames_editor/providers/frame_category_provider.dart';
import 'package:wedding_frames_editor/providers/frames_provider.dart';
import 'screens/home_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => FramesProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wedding Frames Editor',
        home:   HomeScreen(),
      ),
    );
  }
}
