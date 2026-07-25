import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Custom bottom navigation bar for SolasFlow.
///
/// Supports two indicator styles:
/// - [IndicatorStyle.accentLine]: minimal accent line below active icon
/// - [IndicatorStyle.pill]: subtle rounded pill behind active icon
///
/// Both are visually balanced — prototype and choose based on overall feel.
enum IndicatorStyle { accentLine, pill }

/// Navigation destination data.
class NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Custom bottom navigation bar.
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestination> destinations;
  final IndicatorStyle indicatorStyle;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.indicatorStyle = IndicatorStyle.accentLine,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.navBackground,
        border: Border(
          top: BorderSide(color: colors.navBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(destinations.length, (index) {
              final dest = destinations[index];
              final selected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onDestinationSelected(index),
                  child: _NavTab(
                    destination: dest,
                    selected: selected,
                    colors: colors,
                    indicatorStyle: indicatorStyle,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final NavDestination destination;
  final bool selected;
  final ColorTokens colors;
  final IndicatorStyle indicatorStyle;

  const _NavTab({
    required this.destination,
    required this.selected,
    required this.colors,
    required this.indicatorStyle,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = colors.navActive;
    final inactiveColor = colors.navInactive;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (indicatorStyle == IndicatorStyle.pill && selected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: colors.accentLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              destination.activeIcon,
              size: 22,
              color: activeColor,
            ),
          )
        else
          Icon(
            selected ? destination.activeIcon : destination.icon,
            size: 22,
            color: selected ? activeColor : inactiveColor,
          ),
        const SizedBox(height: 4),
        Text(
          destination.label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? activeColor : inactiveColor,
          ),
        ),
        if (indicatorStyle == IndicatorStyle.accentLine && selected) ...[
          const SizedBox(height: 3),
          Container(
            width: 16,
            height: 2,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ],
    );
  }
}
