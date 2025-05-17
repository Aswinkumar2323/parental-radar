import 'package:flutter/material.dart';
import '../../../apis/get.dart';

class BlockedAppsCountCard extends StatefulWidget {
  final String username;
  final Function(int) onJumpToIndex;
  final VoidCallback onModuleLoaded;

  const BlockedAppsCountCard({
    super.key,
    required this.username,
    required this.onJumpToIndex,
    required this.onModuleLoaded,
  });

  @override
  State<BlockedAppsCountCard> createState() => _BlockedAppsCountCardState();
}

class _BlockedAppsCountCardState extends State<BlockedAppsCountCard> {
  int blockedAppCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBlockedAppCount();
  }

  Future<void> loadBlockedAppCount() async {
    setState(() => isLoading = true);
    try {
      final decrypted = await fetchModuleData(
        module: 'bapp',
        userId: widget.username,
      );

      int count = 0;
      final blockedList = decrypted?['data']?['blockedApps'];
      if (blockedList is List) {
        for (var e in blockedList) {
          if (e is Map && e['app'] is String && e['blocked_until'] is String) {
            final until = DateTime.tryParse(e['blocked_until']);
            if (until != null && until.isAfter(DateTime.now())) {
              count++;
            }
          }
        }
      }

      setState(() => blockedAppCount = count);
    } catch (e) {
      debugPrint("Error loading blocked app count: $e");
    } finally {
      setState(() => isLoading = false);
      widget.onModuleLoaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey.shade900 : const Color.fromARGB(255, 255, 255, 255),
      child: InkWell(
        onTap: () => widget.onJumpToIndex(8),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.block,
                      color: isDark ? Colors.redAccent.shade100 : Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Blocked Apps',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'NexaBold',
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Active: $blockedAppCount',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'NexaBold',
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.redAccent,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
