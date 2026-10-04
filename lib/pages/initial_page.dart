import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../main.dart'; // localeNotifier 参照用
import 'main_page.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final currentLocale =
        localeNotifier.value ?? Localizations.localeOf(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final dialogBgColor = isDarkMode
        ? Colors.black.withOpacity(0.70)
        : Colors.white.withOpacity(0.80);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: borderColor),
            ),
            title: Row(
              children: [
                Icon(Icons.language, color: textColor),
                const SizedBox(width: 8),
                Text(
                  'Language / 言語',
                  style: TextStyle(color: textColor, fontSize: 18),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('日本語', style: TextStyle(color: textColor)),
                  trailing: currentLocale.languageCode == 'ja'
                      ? const Icon(Icons.check, color: Colors.deepPurple)
                      : null,
                  onTap: () {
                    localeNotifier.value = const Locale('ja');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('English', style: TextStyle(color: textColor)),
                  trailing: currentLocale.languageCode == 'en'
                      ? const Icon(Icons.check, color: Colors.deepPurple)
                      : null,
                  onTap: () {
                    localeNotifier.value = const Locale('en');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAuthModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            child: Scaffold(
              body: SignInScreen(
                providers: [
                  AppleProvider(),
                  GoogleProvider(
                    clientId:
                        "76760324986-0h46bm26rat5td10kbuh29j2onjfeota.apps.googleusercontent.com",
                  ),
                  EmailAuthProvider(),
                ],
                actions: [
                  AuthStateChangeAction<SignedIn>((context, state) {
                    Navigator.pop(context); // モーダル削除
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainPage(isJustLoggedIn: true),
                      ),
                    );
                  }),
                  AuthStateChangeAction<UserCreated>((context, state) {
                    Navigator.pop(context); // モーダル削除
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainPage(isJustLoggedIn: true),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> onboardingData = [
      {
        'title': l10n.onboardingTitle1,
        'description': l10n.onboardingDesc1,
        'image': 'assets/images/landing1.jpeg',
      },
      {
        'title': l10n.onboardingTitle2,
        'description': l10n.onboardingDesc2,
        'image': 'assets/images/landing2.jpeg',
      },
      {
        'title': l10n.onboardingTitle3,
        'description': l10n.onboardingDesc3,
        'image': 'assets/images/landing3.jpeg',
      },
    ];

    final isLastPage = _currentPage == onboardingData.length - 1;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainPage();
        }

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBackgroundPage(
                  imagePath: onboardingData[_currentPage]['image']!,
                  isDarkMode: isDarkMode,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.language,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            size: 26,
                          ),
                          tooltip: l10n.changeLanguage,
                          onPressed: () => _showLanguageSelector(context),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: onboardingData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(),
                                Text(
                                  onboardingData[index]['title']!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  onboardingData[index]['description']!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const Spacer(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            if (isLastPage) {
                              _showAuthModal(context);
                            } else {
                              _nextPage();
                            }
                          },
                          child: Text(
                            isLastPage ? l10n.btnStartAuth : l10n.btnNext,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedBackgroundPage extends StatefulWidget {
  final String imagePath;
  final bool isDarkMode;

  const AnimatedBackgroundPage({
    super.key,
    required this.imagePath,
    required this.isDarkMode,
  });

  @override
  State<AnimatedBackgroundPage> createState() =>
      _AnimatedBackgroundPageState();
}

class _AnimatedBackgroundPageState extends State<AnimatedBackgroundPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 50),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlayColor = widget.isDarkMode
        ? Colors.black.withOpacity(0.50)
        : Colors.white.withOpacity(0.50);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final imageWidth = screenHeight * (16 / 9);
        final overflowWidth = imageWidth - constraints.maxWidth;

        return Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double alignmentX = overflowWidth > 0
                    ? -1.0 + (_controller.value * 2.0)
                    : 0.0;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: OverflowBox(
                    key: ValueKey<String>(widget.imagePath),
                    minWidth: imageWidth,
                    maxWidth: imageWidth,
                    minHeight: screenHeight,
                    maxHeight: screenHeight,
                    alignment: Alignment(alignmentX, 0.0),
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: widget.isDarkMode
                              ? Colors.grey[900]
                              : Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              color: overlayColor,
            ),
          ],
        );
      },
    );
  }
}