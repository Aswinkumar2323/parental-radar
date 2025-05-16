import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String username;
  final bool? isDarkMode;
  final Function(bool)? onThemeChanged;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.username,
    this.isDarkMode,
    this.onThemeChanged,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isCollapsed = false;
  int hoveredIndex = -1;

  final List<String> items = const [
    'Dashboard',
    'GPS Location Tracking',
    'Geofencing',
    'SMS Monitoring',
    'Call Monitoring',
    'Keylogger',
    'WhatsApp Monitoring',
    'Installed Apps',
    'Blocked Apps',
    'Stealth Mode',
  ];

  final List<IconData> icons = const [
    Icons.dashboard,
    Icons.location_on,
    Icons.map_outlined,
    Icons.sms,
    Icons.call,
    Icons.keyboard,
    FontAwesomeIcons.whatsapp,
    Icons.apps,
    Icons.block,
    Icons.visibility_off,
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor1 = const Color(0xFF0090FF);
    final Color primaryColor2 = const Color(0xFF15D6A6);
    final Color hoverColor = const Color(0xFFCCE8FF);

    final isDark = widget.isDarkMode ?? false;

    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color bgColor = isDark ? Colors.black : Colors.white;
    final Color borderColor = isDark ? Colors.white24 : Colors.black12;

    final textStyle = TextStyle(
      fontFamily: 'NexaBold',
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: textColor,
    );

    return AnimatedContainer(
      duration: 300.ms,
      width: isCollapsed ? 70 : 240,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 0)),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Image.asset('assets/icon/app_icon.png', height: 40),
                if (!isCollapsed) const SizedBox(width: 12),
                if (!isCollapsed)
                  Text(
                    'Parental Radar',
                    style: TextStyle(
                      fontFamily: 'NexaBold',
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.username,
                style: textStyle.copyWith(fontSize: 16),
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(items.length, (index) {
                  final isSelected = index == widget.selectedIndex;
                  final isHovered = hoveredIndex == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => hoveredIndex = index),
                      onExit: (_) => setState(() => hoveredIndex = -1),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor1.withOpacity(0.1)
                              : isHovered
                                  ? hoverColor.withOpacity(0.3)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected || isHovered
                                ? primaryColor1
                                : borderColor,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isCollapsed ? 0 : 16,
                          ),
                          selected: isSelected,
                          leading: Icon(
                            icons[index],
                            color: isSelected
                                ? primaryColor1
                                : textColor.withOpacity(0.8),
                            size: 20,
                          ),
                          title: isCollapsed
                              ? null
                              : Text(
                                  items[index],
                                  style: textStyle.copyWith(
                                    color: isSelected ? primaryColor1 : textColor,
                                  ),
                                ),
                          onTap: () => widget.onItemSelected(index),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!isCollapsed && widget.onThemeChanged != null && widget.isDarkMode != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(Icons.brightness_6, size: 20, color: textColor),
                    const SizedBox(width: 8),
                    Text('Dark Mode', style: textStyle),
                    const Spacer(),
                    Switch(
                      activeColor: primaryColor2,
                      value: widget.isDarkMode!,
                      onChanged: widget.onThemeChanged!,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
