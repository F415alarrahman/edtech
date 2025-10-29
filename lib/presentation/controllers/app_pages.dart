import 'package:edtech/presentation/views/home_view.dart';
import 'package:edtech/presentation/views/auth_view.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class Routes {
  static const login = '/login';
  static const roleSelect = '/role';
  static const home = '/home';
  static const rooms = '/rooms';
}

class AppPages {
  static const initial = Routes.login;
  static final routes = [
    GetPage(name: Routes.login, page: () => const AuthView()),
    GetPage(name: Routes.home, page: () => const HomeView()),
  ];
}
