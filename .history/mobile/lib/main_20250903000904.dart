import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/configs/theme/app_theme.dart';
import 'package:mobile/domain/auth/usecases/is_logged_in.dart';
import 'package:mobile/firebase_option.dart';
import 'package:mobile/presentation/splash/bloc/splash_cubit.dart';
import 'package:mobile/presentation/splash/pages/splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/service_locator.dart' as di;
import 'package:mobile/common/helper/navigator/app_navigator.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
   // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  await di.iniatializeServiceLocator();

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(di.sl<IsLoggedInUseCase>())..appStarted(),
      child: MaterialApp(
        theme: AppTheme.appTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashPage()
      ),
    );
  }
}
