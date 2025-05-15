import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../apis/get.dart';
import '../../apis/post.dart';
import '../../decryption/parent_decryption.dart';

class BlockedAppsScreen extends StatefulWidget {
  final String username;

  const BlockedAppsScreen({super.key, required this.username});

  @override
  State<BlockedAppsScreen> createState() => _BlockedAppsScreenState();
}

class _BlockedAppsScreenState extends State<BlockedAppsScreen> {
  List<Map<String, String>> installedApps = [];
  Map<String, DateTime> blockedApps = {};
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showBlockedOnly = false;

  bool _isProcessing = false;
  int _remainingSeconds = 0;
  Timer? _countdownTimer;
  Timer? _uiTimer;
  String _pendingActionMessage = '';

  @override
  void initState() {
    super.initState();
    loadAll();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _uiTimer = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final newMap = Map.of(blockedApps);
      newMap.removeWhere((key, value) => value.isBefore(now));
      if (mounted) setState(() => blockedApps = newMap);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _countdownTimer?.cancel();
    _uiTimer?.cancel();
    super.dispose();
  }

  Future<void> loadAll() async {
    setState(() => isLoading = true);
    try {
      final data = await fetchModuleData(
        module: 'iapp',
        userId: widget.username,
      );

      final installedResult = await ParentDecryption.decrypt(data, widget.username);


      final blockedResult = await fetchModuleData(
        module: 'bapp',
        userId: widget.username,
      );

      List<Map<String, String>> fetchedInstalled = [];
      Map<String, DateTime> fetchedBlocked = {};

      if (installedResult != null &&
          installedResult['data']?['InstalledApps'] is List) {
        final appsList = installedResult['data']['InstalledApps'] as List;
        fetchedInstalled = appsList.map<Map<String, String>>((e) {
          return {
            'name': e['name'] ?? 'Unknown',
            'package': e['package'] ?? '',
          };
        }).toList();
      }

      final blockedList = blockedResult?['data']?['blockedApps'];
      if (blockedList is List) {
        for (var e in blockedList) {
          if (e is Map && e['app'] is String && e['blocked_until'] is String) {
            final blockedUntil = DateTime.tryParse(e['blocked_until']);
            if (blockedUntil != null && blockedUntil.isAfter(DateTime.now())) {
              fetchedBlocked[e['app']] = blockedUntil;
            }
          }
        }
      }

      setState(() {
        installedApps = fetchedInstalled;
        blockedApps = fetchedBlocked;
      });

      await updateBlockedAppsToBackend(fetchedBlocked);
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateBlockedAppsToBackend(Map<String, DateTime> newMap) async {
    final data = {
      'blockedApps': newMap.entries
          .map((e) => {
                'app': e.key,
                'blocked_until': e.value.toUtc().toIso8601String(),
              })
          .toList(),
    };
    await sendModuleData(module: 'bapp', data: data, userId: widget.username);
  }

  Future<void> toggleBlock(String packageName) async {
    final isCurrentlyBlocked = blockedApps.containsKey(packageName);

    final confirmed = await showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCurrentlyBlocked ? 'Unblock App?' : 'Block App?'),
        content: isCurrentlyBlocked
            ? Text('Are you sure you want to unblock this app?')
            : Text('Select duration to block this app:'),
        actions: isCurrentlyBlocked
            ? [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Unblock'),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 15),
                  child: Text('15 mins'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 30),
                  child: Text('30 mins'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 60),
                  child: Text('1 hour'),
                ),
              ],
      ),
    );

    if (confirmed == null || (confirmed is bool && confirmed == false)) return;

    final newBlocked = Map<String, DateTime>.from(blockedApps);
    final actionText = isCurrentlyBlocked ? 'Unblocked' : 'Blocked';

    if (isCurrentlyBlocked) {
      newBlocked.remove(packageName);
    } else {
      newBlocked[packageName] =
          DateTime.now().add(Duration(minutes: confirmed as int));
    }

    setState(() {
      blockedApps = newBlocked;
      _isProcessing = true;
      _remainingSeconds = 120;
      _pendingActionMessage = '$actionText "${packageName.split('.').last}"';
    });

    await updateBlockedAppsToBackend(newBlocked);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() => _isProcessing = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Update Complete"),
            content: Text('$_pendingActionMessage successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    });
  }

  IconData getIconFromAppName(String appName) {
    final lower = appName.toLowerCase();
    if (lower.contains('whatsapp')) return FontAwesomeIcons.whatsapp;
    if (lower.contains('instagram')) return FontAwesomeIcons.instagram;
    if (lower.contains('facebook')) return FontAwesomeIcons.facebook;
    if (lower.contains('youtube')) return FontAwesomeIcons.youtube;
    if (lower.contains('snapchat')) return FontAwesomeIcons.snapchat;
    if (lower.contains('twitter') || lower.contains('x')) {
      return FontAwesomeIcons.twitter;
    }
    return FontAwesomeIcons.android;
  }

  String getRemainingTime(DateTime until) {
    final diff = until.difference(DateTime.now());
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;
    return '${minutes}m ${seconds}s left';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final filteredApps = installedApps.where((app) {
      final name = app['name']?.toLowerCase() ?? '';
      final isBlocked = blockedApps.containsKey(app['package']);
      return name.contains(_searchQuery) &&
          (!_showBlockedOnly || isBlocked);
    }).toList();

    final blockedOnlyApps = installedApps.where(
      (app) => blockedApps.containsKey(app['package']),
    ).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Blocked Apps',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAll,
            tooltip: 'Refresh',
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: isDark
                ? [Colors.black, Colors.black, Colors.black]
                : [Color(0xFF0090FF), Color(0xFF15D6A6), Color(0xFF123A5B)],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.only(top: kToolbarHeight + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isProcessing)
                      MaterialBanner(
                        backgroundColor: isDark
                            ? Colors.amber.shade800
                            : Colors.yellow.shade100,
                        content: Text(
                          '$_pendingActionMessage will reflect in target device within $_remainingSeconds seconds...',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                setState(() => _isProcessing = false),
                            child: Text('Dismiss'),
                          ),
                        ],
                      ),
                    if (blockedOnlyApps.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Text(
                          'List of All Blocked Apps',
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: blockedOnlyApps.length,
                          separatorBuilder: (_, __) => SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final app = blockedOnlyApps[index];
                            final name = app['name'] ?? 'Unknown';
                            final icon = getIconFromAppName(name);
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: FaIcon(icon, color: Colors.red, size: 20),
                                ),
                                SizedBox(height: 4),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.labelMedium!.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search apps...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: Text('Show only blocked apps',
                          style: const TextStyle(color: Colors.white)),
                      value: _showBlockedOnly,
                      onChanged: (value) =>
                          setState(() => _showBlockedOnly = value),
                    ),
                    if (filteredApps.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No matching apps found.',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ...filteredApps.map((app) {
                      final name = app['name'] ?? 'Unknown';
                      final package = app['package'] ?? '';
                      final icon = getIconFromAppName(name);
                      final isBlocked = blockedApps.containsKey(package);
                      final blockedUntil = blockedApps[package];
                      final timeLeft = blockedUntil != null
                          ? getRemainingTime(blockedUntil)
                          : null;

                      return Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Card(
                          elevation: 0,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundColor: isBlocked
                                  ? Colors.redAccent
                                  : Colors.tealAccent.shade700,
                              child: FaIcon(
                                icon,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(name,
                                style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black)),
                            subtitle: Text(package,
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white70 : Colors.black54)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _isProcessing
                                      ? null
                                      : () => toggleBlock(package),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isBlocked
                                        ? Colors.grey[800]
                                        : Colors.redAccent,
                                  ),
                                  child: Text(
                                    isBlocked ? 'Unblock' : 'Block',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isBlocked && timeLeft != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      timeLeft,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.orangeAccent
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
      ),
    );
  }
}
