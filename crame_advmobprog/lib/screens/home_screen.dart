import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_text.dart';
import 'product_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }

  Widget _buildAppBarTitle() {
    if (_selectedIndex == 0) {
      return Image.asset(
        'assets/images/nubdexchange_logo.png',
        scale: 11.sp,
        errorBuilder: (context, error, stackTrace) => CustomText(
          text: 'Shop',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final title = _selectedIndex == 1
        ? 'Chat'
        : _selectedIndex == 2
            ? 'Profile'
            : 'Home';

    return CustomText(
      text: title,
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          title: _buildAppBarTitle(),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
          children: [
            const ProductScreen(),
            Center(
              child: CustomText(
                text: 'Chat Screen',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Center(
              child: CustomText(
                text: 'Profile Screen',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shop_2),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

