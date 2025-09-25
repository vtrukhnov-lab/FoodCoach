import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final VoidCallback onAddPressed;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Основные элементы навигации
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSvgNavItem(
                    svgPath: 'assets/icons/home_filled.svg',
                    label: 'Today',
                    index: 0,
                    isActive: currentIndex == 0,
                  ),
                  _buildSvgNavItem(
                    svgPath: 'assets/icons/heart_outline.svg',
                    label: 'Advice',
                    index: 1,
                    isActive: currentIndex == 1,
                  ),
                  const SizedBox(width: 66), // Пространство для кнопки Add
                  _buildSvgNavItem(
                    svgPath: 'assets/icons/calendar_outline.svg',
                    label: 'Day',
                    index: 2,
                    isActive: currentIndex == 2,
                  ),
                  _buildSvgNavItem(
                    svgPath: 'assets/icons/profile_outline.svg',
                    label: 'Profile',
                    index: 4,
                    isActive: currentIndex == 4,
                  ),
                ],
              ),
            ),
            // Кнопка Add по центру
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Center(
                child: _buildCenterAddButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSvgNavItem({
    required String svgPath,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTabTapped(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: isActive ? 28 : 26,
              height: isActive ? 28 : 26,
              colorFilter: ColorFilter.mode(
                isActive ? Colors.black : const Color(0xFFA5A3A7),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? Colors.black : const Color(0xFFA5A3A7),
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                fontFamily: 'Rubik',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onAddPressed();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8BC34A),
                  Color(0xFF689F38),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8BC34A).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFFA5A3A7),
              fontFamily: 'Rubik',
            ),
          ),
        ],
      ),
    );
  }
}