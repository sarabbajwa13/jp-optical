import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jp_optical/colors/app_color.dart';
import 'package:jp_optical/local_storage/cart_service.dart';
import 'package:jp_optical/presentation/home_screen_new.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartService(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<void> _initializeApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Hive.initFlutter();
    await Hive.openBox('cartBox');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                  child: Container(
                      color: Colors.black,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 35),
                            child: SvgPicture.asset(
                              'assets/images/glass_icon_header.svg',
                            ),
                          ),
                          SizedBox(width: 5),
                          SizedBox(
                              width: 170,
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text('JP Opticals',
                                          style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                  Container(
                                      margin:
                                          EdgeInsets.only(top: 35, right: 45),
                                      child: Text('By RJ Brothers',
                                          style: GoogleFonts.allura(
                                              color: AppColors.cGreenColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 15))),
                                ],
                              ))
                        ],
                      ))
                  //  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.cGreenColor))

                  ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('An error occurred: ${snapshot.error}'),
              ),
            );
          } else {
            return const HomeScreenNew();
          }
        },
      ),
    );
  }
}
