
import 'package:flutter/material.dart';
import 'package:shopx/views/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Discover Your Style',
      'description':
          'Explore the latest fashion collections and discover your personal style.',
      'image':
          'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=600',
    },
    {
      'title': 'Find Your Favorites',
      'description':
          'Browse clothing, shoes and accessories in one place.',
      'image':
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600',
    },
    {
      'title': 'Shop With Ease',
      'description':
          'Enjoy a simple shopping experience and get your favorites delivered.',
      'image':
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600',
    },
  ];

  void nextPage() {
  if (currentPage < onboardingData.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  _pageController.animateToPage(
                    onboardingData.length - 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            // Onboarding Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = onboardingData[index];

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [

                        Expanded(
                          flex: 6,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              data['image']!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        Text(
                          data['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          data['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentPage == index ? 25 : 8,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? Colors.black
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentPage == onboardingData.length - 1
                        ? 'Get Started'
                        : 'Continue',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
