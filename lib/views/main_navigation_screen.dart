import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'categories/categories_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  // Shared navigation state.
  static final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(),
    const CategoriesScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.grid_view_rounded,
    Icons.favorite_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = ['Home', 'Explore', 'Wishlist', 'Profile'];

  @override
  void initState() {
    super.initState();
    MainNavigationScreen.selectedTab.addListener(_onTabChanged);
    _selectedIndex = MainNavigationScreen.selectedTab.value;
  }

  void _onTabChanged() {
    if (!mounted) return;

    setState(() {
      _selectedIndex = MainNavigationScreen.selectedTab.value;
    });
  }

  @override
  void dispose() {
    MainNavigationScreen.selectedTab.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: IndexedStack(index: _selectedIndex, children: _screens),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 68,
            backgroundColor: AppColors.surface,
            elevation: 0,
            selectedIndex: _selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            indicatorColor: AppColors.primary.withValues(alpha: 0.13),

            onDestinationSelected: (index) {
              MainNavigationScreen.selectedTab.value = index;
            },

            destinations: List.generate(
              _icons.length,
              (index) => NavigationDestination(
                icon: Icon(
                  _icons[index],
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                selectedIcon: Icon(
                  _icons[index],
                  color: AppColors.primary,
                  size: 23,
                ),
                label: _labels[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
