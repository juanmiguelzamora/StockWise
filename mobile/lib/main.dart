import 'package:flutter/material.dart';
import 'package:mobile/core/configs/theme/app_theme.dart';
import 'package:mobile/domain/auth/usecases/is_logged_in.dart';
import 'package:mobile/presentation/ai_assistant/ai_provider.dart';
import 'package:mobile/presentation/product/provider/product_provider.dart';
import 'package:mobile/presentation/splash/bloc/splash_cubit.dart';
import 'package:mobile/presentation/splash/pages/splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/service_locator.dart' as di;
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  await di.iniatializeServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<AiProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<ProductProvider>(),
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            SplashCubit(di.sl<IsLoggedInUseCase>())..appStarted(),
        child: MaterialApp(
          theme: AppTheme.appTheme,
          debugShowCheckedModeBanner: false,
          home: const SplashPage(),
        ),
      ),
    );
  }
}