import 'package:flutter/material.dart';
import '../../apis/get.dart';
import '../../apis/post.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StealthModeScreen extends StatefulWidget {
  final String username;

  const StealthModeScreen({super.key, required this.username});

  @override
  _StealthModeScreenState createState() => _StealthModeScreenState();
}

class _StealthModeScreenState extends State<StealthModeScreen> {
  bool isStealthEnabled = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStealthData();
  }

  Future<void> fetchStealthData() async {
    final result = await fetchModuleData(
      module: 'stealth',
      userId: widget.username,
    );
    if (result != null && result['data'] != null) {
      setState(() {
        isStealthEnabled = result['data']['stealth'] ?? false;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void refresh() => fetchStealthData();

  Future<void> updateStealthMode(bool isEnabled) async {
    await sendModuleData(
      module: 'stealth',
      data: {'stealth': isEnabled},
      userId: widget.username,
    );
  }

  Future<void> _confirmToggle(bool newValue) async {
    final action = newValue ? "Enable" : "Disable";
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "$action Stealth Mode?",
          style: const TextStyle(fontFamily: 'NexaBold'),
        ),
        content: Text(
          "Are you sure you want to $action stealth mode?",
          style: const TextStyle(fontFamily: 'NexaBold'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(fontFamily: 'NexaBold')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action, style: const TextStyle(fontFamily: 'NexaBold')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isStealthEnabled = newValue);
      await updateStealthMode(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabledColor = Colors.blueAccent;
    final disabledColor = const Color.fromARGB(255, 255, 64, 64);
    final boxColor = isDark ? Colors.grey.shade900 : Colors.white;
    final containerBg = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            'Stealth Mode',
            style: TextStyle(
              fontFamily: 'NexaBold',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
            color: Colors.white,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: isDark
                    ? [Colors.black, Colors.black, Colors.black]
                    : [
                        const Color(0xFF0090FF),
                        const Color(0xFF15D6A6),
                        const Color(0xFF123A5B),
                      ],
              ),
            ),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: boxColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Enable Stealth",
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Switch(
                                value: isStealthEnabled,
                                onChanged: (value) => _confirmToggle(value),
                                activeColor: enabledColor,
                                inactiveTrackColor: disabledColor.withOpacity(0.6),
                                inactiveThumbColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),

                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: containerBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: boxColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 12,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    isStealthEnabled
                                        ? Icons.lock_outline_rounded
                                        : Icons.visibility_off,
                                    size: 70,
                                    color: isStealthEnabled
                                        ? enabledColor
                                        : disabledColor,
                                  ),
                                ),
                              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

                              const SizedBox(height: 24),

                              Text(
                                isStealthEnabled
                                    ? "Stealth Mode is ON"
                                    : "Stealth Mode is OFF",
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isStealthEnabled
                                      ? enabledColor
                                      : disabledColor,
                                ),
                              ).animate().fadeIn(duration: 300.ms),

                              const SizedBox(height: 12),

                              Text(
                                "Target App: ${isStealthEnabled ? "Active" : "Inactive"}",
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontSize: 16,
                                  color: isStealthEnabled
                                      ? enabledColor
                                      : disabledColor,
                                ),
                              ).animate().fadeIn(duration: 300.ms),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
