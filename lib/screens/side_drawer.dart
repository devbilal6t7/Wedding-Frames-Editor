import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wedding_frames_editor/screens/language_screen.dart';
import 'package:wedding_frames_editor/screens/saved_screen.dart';
import '../consts/app_colors.dart';
import '../consts/assets.dart';
import '../widgets/app_localizations.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  void shareApp() {
    const appLink =
        'https://play.google.com/store/apps/details?id=com.weddingcard.weddingframes.weddingeditor';
    Share.share('Check out this amazing app: $appLink');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/drawer_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: null,
          ),
          ListTile(
            leading: Image.asset(
              WeddingAssets.download,
              height: 20,
              width: 20,
            ),
            title:  Text(   AppLocalizations.of(context).translate('downloadSaved'),),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SavedScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              WeddingAssets.share,
              height: 20,
              width: 20,
            ),
            title:   Text(   AppLocalizations.of(context).translate('shareApp'),),
            onTap: shareApp,
          ),
          ListTile(
            leading: Image.asset(
              WeddingAssets.smartPhone,
              height: 20,
              width: 20,
            ),
            title: RichText(
              text: TextSpan(
                children: [
                   TextSpan(
                    text: AppLocalizations.of(context).translate('appVersion'),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '  (1.0.0)',
                    style: TextStyle(
                        color: WeddingColors.mainColor,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Image.asset(
              WeddingAssets.language,
              height: 20,
              width: 20,
            ),
            title: Text(   AppLocalizations.of(context).translate('language'),),
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
