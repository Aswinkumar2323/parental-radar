import 'package:flutter/material.dart';
import '../../../apis/get.dart';
import '../../../decryption/parent_decryption.dart';

class TotalInstalledAppsCard extends StatefulWidget {
  final String username;
  final Function(int) onJumpToIndex;
  final VoidCallback onModuleLoaded;

  const TotalInstalledAppsCard({
    Key? key,
    required this.username,
    required this.onJumpToIndex,
    required this.onModuleLoaded,
  }) : super(key: key);

  @override
  State<TotalInstalledAppsCard> createState() => _TotalInstalledAppsCardState();
}

class _TotalInstalledAppsCardState extends State<TotalInstalledAppsCard> {
  int totalApps = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppCount();
  }

  Future<void> fetchAppCount() async {
    try {
      final apidata = await fetchModuleData(
        module: 'iapp',
        userId: widget.username,
      );
      final data = await ParentDecryption.decrypt(apidata, widget.username);
      final apps = data?['data']?['InstalledApps'] ?? [];
      setState(() {
        totalApps = apps.length;
        isLoading = false;
      });
      widget.onModuleLoaded();
    } catch (e) {
      setState(() {
        totalApps = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: InkWell(
        onTap: () => widget.onJumpToIndex(7),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.apps, color: Colors.orange, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Installed Apps',
                      style: const TextStyle(
                        fontFamily: 'NexaBold',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                          'Total: $totalApps',
                          style: TextStyle(
                            fontFamily: 'NexaBold',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
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
