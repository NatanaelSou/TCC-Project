import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String? name;
  String? email;
  String? avatarUrl;

  UserState({this.name, this.email, this.avatarUrl});

  bool get isLoggedIn => name != null;

  String get displayName => name ?? 'Visitante';
  String get displayAvatar => avatarUrl ?? 'https://example.com/default_avatar.png';

  void login({required String userName, required String userEmail, String? avatar}) {
    name = userName;
    email = userEmail;
    avatarUrl = avatar;
    notifyListeners();
  }

  void loginFromMap(Map<String, dynamic> userData) {
    name = userData['name'];
    email = userData['email'];
    avatarUrl = userData['avatar'];
    notifyListeners();
  }

  void logout() {
    name = null;
    email = null;
    avatarUrl = null;
    notifyListeners();
  }

  void setName(String newName) {
    name = newName;
    notifyListeners();
  }

  void setProfile(String avatar) {
    avatarUrl = avatar;
    notifyListeners();
  }

  void updateProfile({String? newName, String? newAvatar}) {
    if (newName != null) name = newName;
    if (newAvatar != null) avatarUrl = newAvatar;
    notifyListeners();
  }
}
