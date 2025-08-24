import 'package:mobile/domain/auth/usecases/is_logged_in.dart';
import 'package:mobile/presentation/splash/bloc/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<SplashState> {

  final IsLoggedInUseCase _isLoggedInUseCase;

  SplashCubit(this._isLoggedInUseCase) : super(DisplaySplash());

  void appStarted() async {
    await Future.delayed(const Duration(seconds: 2));
    var isLoggedIn = await _isLoggedInUseCase.call();
    if (isLoggedIn) {
      emit(Authenticated());
    } else {
      emit(UnAuthenticated());
    }
  }
}