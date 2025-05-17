import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String? username;
  final bool? isDarkMode;
  final Function(bool)? onThemeChanged;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.username,
    this.isDarkMode,
    this.onThemeChanged,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int hoveredIndex = -1;
  int? tappedIndex;
  bool isCollapsed = false;

  final List<String> items = [
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

  final List<IconData> icons = [
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
    final bool isDark = widget.isDarkMode ?? false;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    final Color primaryColor1 = const Color(0xFF0090FF);
    final Color primaryColor2 = const Color(0xFF15D6A6);
    final Color hoverColor = const Color(0xFFCCE8FF);

    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color borderColor = isDark ? Colors.white24 : Colors.black12;

    final textStyle = TextStyle(
      fontFamily: 'NexaBold',
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: textColor,
    );

    Widget buildListItem(int index, bool collapsed) {
      final isSelected = index == widget.selectedIndex;
      final isHovered = hoveredIndex == index;
      final isTapped = tappedIndex == index;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
        child: MouseRegion(
          onEnter: (_) => setState(() => hoveredIndex = index),
          onExit: (_) => setState(() => hoveredIndex = -1),
          child: GestureDetector(
            onTapDown: (_) => setState(() => tappedIndex = index),
            onTapCancel: () => setState(() => tappedIndex = null),
            onTapUp: (_) => setState(() => tappedIndex = null),
            onTap: () => widget.onItemSelected(index),
            child: TweenAnimationBuilder<double>(
              duration: 120.ms,
              tween: Tween<double>(begin: 1.0, end: isTapped ? 0.96 : 1.0),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: 250.ms,
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor1.withOpacity(0.1)
                          : isHovered
                              ? hoverColor.withOpacity(0.3)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected || isHovered ? primaryColor1 : borderColor,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: collapsed ? 0 : 12.0,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: collapsed
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: [
                          Icon(
                            icons[index],
                            size: 20,
                            color: isSelected
                                ? primaryColor1
                                : textColor.withOpacity(0.85),
                          ),
                          if (!collapsed) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                items[index],
                                style: textStyle.copyWith(
                                  color: isSelected ? primaryColor1 : textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    if (isMobile) {
      return Container(
        width: 180,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(right: BorderSide(color: borderColor)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 0)),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Image.asset('assets/icon/app_icon.png', height: 40),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) => buildListItem(index, false),
              ),
            ),
            const SizedBox(height: 12),
            if (widget.onThemeChanged != null && widget.isDarkMode != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.brightness_6, size: 18, color: textColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dark Mode',
                          style: textStyle.copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Switch(
                        activeColor: primaryColor2,
                        value: widget.isDarkMode!,
                        onChanged: widget.onThemeChanged!,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool shouldCollapse = constraints.maxWidth < 900;
        isCollapsed = shouldCollapse ? true : isCollapsed;

        return AnimatedContainer(
          duration: 350.ms,
          curve: Curves.easeInOutCubic,
          width: isCollapsed ? 85 : 247,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(right: BorderSide(color: borderColor)),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 0)),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment:
                      isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        isCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                        size: 16,
                        color: textColor,
                      ),
                      onPressed: () => setState(() => isCollapsed = !isCollapsed),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Image.asset('assets/icon/app_icon.png', height: 50),
                  if (!isCollapsed) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Parental Radar',
                      style: TextStyle(
                        fontFamily: 'Righteous',
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (widget.username != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          widget.username!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: textStyle.copyWith(fontSize: 16),
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) => buildListItem(index, isCollapsed),
                ),
              ),
              const SizedBox(height: 16),
              if (!isCollapsed &&
                  widget.onThemeChanged != null &&
                  widget.isDarkMode != null)
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
      },
    );
  }
}
