import 'package:flutter/material.dart';
import '../../../apis/get.dart';

class StealthStatusCard extends StatefulWidget {
  final String username;
  final Function(int) onJumpToIndex;
  final VoidCallback onModuleLoaded;

  const StealthStatusCard({
    super.key,
    required this.username,
    required this.onJumpToIndex,
    required this.onModuleLoaded,
  });

  @override
  State<StealthStatusCard> createState() => _StealthStatusCardState();
}

class _StealthStatusCardState extends State<StealthStatusCard> {
  bool? isStealthEnabled;
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

    setState(() {
      isStealthEnabled = result?['data']?['stealth'] ?? false;
      isLoading = false;
    });

    widget.onModuleLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isStealthEnabled == true
        ? Colors.blueAccent
        : const Color.fromARGB(255, 255, 64, 64);

    return InkWell(
      onTap: () => widget.onJumpToIndex(9),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 5,
        color: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isStealthEnabled == true
                    ? Icons.lock_outline_rounded
                    : Icons.visibility_off,
                size: 36,
                color: iconColor,
              ),
              const SizedBox(height: 10),
              Text(
                "Stealth Mode",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NexaBold',
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isStealthEnabled == true ? "ON" : "OFF",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NexaBold',
                        color: iconColor,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
