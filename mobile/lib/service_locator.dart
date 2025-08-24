import 'package:get_it/get_it.dart';
import 'package:mobile/data/auth/repository/auth_repository_impl.dart';
import 'package:mobile/data/auth/source/auth_firebase_service.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/domain/auth/usecases/get_user.dart';
import 'package:mobile/domain/auth/usecases/is_logged_in.dart';
import 'package:mobile/domain/auth/usecases/send_password_reset_email.dart';
import 'package:mobile/domain/auth/usecases/signin.dart';
import 'package:mobile/domain/auth/usecases/signup.dart';

final sl = GetIt.instance;

Future<void> iniatializeServiceLocator() async {
  // services
  sl.registerLazySingleton<AuthFireseService>(
    () => AuthFirebaseServiceImpl(),
  );
  
  // repositories

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthFireseService>()),
  );

  
  // usecases
  sl.registerSingleton<SignupUseCase>(
    SignupUseCase()
  );

  sl.registerSingleton<SigninUseCase>(
    SigninUseCase()
  );

  sl.registerSingleton<SendPasswordResetEmailUseCase>(
    SendPasswordResetEmailUseCase()
  );

  sl.registerSingleton<IsLoggedInUseCase>(
    IsLoggedInUseCase()
  );

  sl.registerSingleton<GetUserUseCase>(
    GetUserUseCase()
  );
}