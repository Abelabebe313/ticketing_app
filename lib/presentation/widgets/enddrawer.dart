import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/presentation/auth/login_page.dart';
import 'package:transport_app/utils/clear_hive.dart';
import 'package:transport_app/utils/clear_token.dart';

class EndDrawers extends StatefulWidget {
  // const EndDrawers({super.key});

  @override
  State<EndDrawers> createState() => _EndDrawersState();
}

class _EndDrawersState extends State<EndDrawers> {
  Future<void> clearPreference(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 130,
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Color(0xFF0E5120),
            ),
            title: Text(
              'aboutus'.tr(),
              style: const TextStyle(
                fontFamily: 'Urbanist-Bold',
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.share,
              color: Color(0xFF0E5120),
            ),
            title: Text(
              'shareApp'.tr(),
              style: const TextStyle(
                fontFamily: 'Urbanist-Bold',
                fontSize: 16,
              ),
            ),
            onTap: () async {
              // close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.help,
              color: Color(0xFF0E5120),
            ),
            title: Text(
              'faqs'.tr(),
              style: const TextStyle(
                fontFamily: 'Urbanist-Bold',
                fontSize: 16,
              ),
            ),
            onTap: () {
              // // FAQDialog()
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => FAQScreen(),
              //   ),
              // );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color(0xFF0E5120),
            ),
            title: Text(
              'logout'.tr(),
              style: const TextStyle(
                fontFamily: 'Urbanist-Bold',
                fontSize: 16,
              ),
            ),
            onTap: () async {
              await clearPreference('bus_info');
              clearAuthToken();
              clearAllHiveData();
              // clear Hive.box<String>(pin_code) ('pin');

              clearBox('pin');

              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              // exit(0);
              // Restart.restartApp();
            },
          ),
        ],
      ),
    );
  }
}
