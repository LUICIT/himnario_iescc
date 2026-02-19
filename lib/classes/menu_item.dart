import 'package:flutter/material.dart';

class MenuItem {
  final int id;
  final String title;
  final String route;
  final String icon;

  const MenuItem({
    required this.id,
    required this.title,
    required this.route,
    required this.icon,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: (json['id'] ?? 0) as int,
      title: (json['title'] ?? '').toString(),
      route: (json['route'] ?? '/').toString(),
      icon: (json['icon'] ?? 'menu').toString(),
    );
  }

  IconData get iconData {
    switch (icon.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'hymns':
      case 'hymns_specials':
        return Icons.menu_book;
      case 'donation':
        return Icons.volunteer_activism;
      case 'about':
        return Icons.info;
      default:
        return Icons.chevron_right;
    }
  }
}
