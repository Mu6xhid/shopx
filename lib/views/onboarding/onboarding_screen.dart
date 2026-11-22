
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image':
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1200',
      'eyebrow': 'DISCOVER YOUR IDENTITY',
      'title': 'Style is a\nstatement.',
      'description':
          'Discover pieces that express who you are. Your style, your rules.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=1200',
      'eyebrow': 'CURATED FOR YOU',
      'title': 'Find your\nnext look.',
      'description':
          'Explore collections designed to make every outfit feel exceptional.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=1200',
      'eyebrow': 'MAKE IT YOURS',
      'title': 'Wear your\nconfidence.',
      'description':
          'A new way to shop. A better way to express your individuality.',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final page = _pages[index];

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    page['image']!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;

                      return Container(
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary,
                          size: 40,
                        ),
                      );
                    },
                  ),

                  // Dark gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x99000000),
                          Color(0x22000000),
                          Color(0xEE0B0C0E),
                          Color(0xFF0B0C0E),
                        ],
                        stops: [0.0, 0.30, 0.65, 1.0],
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        26, 25, 26, 35,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'SHOPX',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 5,
                                ),
                              ),
                              Text(
                                '.',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Column(
                              key: ValueKey(index),
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  page['eyebrow']!,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.5,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Text(
                                  page['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 47,
                                    fontWeight: FontWeight.w700,
                                    height: 1.08,
                                    letterSpacing: -1.5,
                                  ),
                                ),

                                const SizedBox(height: 17),

                                Text(
                                  page['description']!,
                                  style: const TextStyle(
                                    color: Color(0xFFB7B7B7),
                                    fontSize: 14,
                                    height: 1.7,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 35),

                          Row(
                            children: [
                              ...List.generate(
                                _pages.length,
                                (index) {
                                  final selected =
                                      _currentPage == index;

                                  return AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    margin: const EdgeInsets.only(
                                      right: 7,
                                    ),
                                    width: selected ? 30 : 7,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.primary
                                          : Colors.white38,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  );
                                },
                              ),

                              const Spacer(),

                              Text(
                                '0${_currentPage + 1} / 0${_pages.length}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: _nextPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.primary,
                                      foregroundColor:
                                          AppColors.background,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _currentPage ==
                                                  _pages.length - 1
                                              ? 'GET STARTED'
                                              : 'CONTINUE',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 19,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              if (_currentPage !=
                                  _pages.length - 1) ...[
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: _goToLogin,
                                  child: const Text(
                                    'SKIP',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
