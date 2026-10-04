import 'package:flutter/foundation.dart';
import '../models/admin.dart';

class AdminProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  AdminUser? _currentAdmin;

  bool get isAuthenticated => _isAuthenticated;
  AdminUser? get currentAdmin => _currentAdmin;

  bool login(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Sample admin credentials for mini project: Bvcgroup.com / admin123
    if (cleanEmail == 'bvcgroup.com' && cleanPassword == 'admin123') {
      _isAuthenticated = true;
      _currentAdmin = const AdminUser(
        id: 'admin_1',
        name: 'Bvc Students Group',
        email: 'Bvcgroup.com',
        phoneNumber: '8090451729',
        studentId: '24221A05G5',
        canteenName: 'Campus Central Canteen',
        role: 'Student Canteen Admin',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _currentAdmin = null;
    notifyListeners();
  }
}
