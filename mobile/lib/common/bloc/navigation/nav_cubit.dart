import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/domain/navigation/entity/nav_item.dart';

class NavCubit extends Cubit<NavItem> {
  NavCubit() : super(NavItem.home);

  void selectTab(NavItem item) => emit(item);
}
