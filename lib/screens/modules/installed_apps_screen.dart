import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../apis/get.dart';
import '../../decryption/parent_decryption.dart';

class InstalledAppsScreen extends StatefulWidget {
  final String username;
  const InstalledAppsScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<InstalledAppsScreen> createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<InstalledAppsScreen> {
  List<Map<String, String>> installedApps = [];
  List<Map<String, String>> filteredApps = [];
  List<Map<String, String>> newApps = [];
  bool isLoading = true;

  final TextEditingController _searchAllController = TextEditingController();
  final TextEditingController _searchNewController = TextEditingController();

  final Map<String, IconData> iconMap = {
    'facebook': FontAwesomeIcons.facebook,
    'whatsapp': FontAwesomeIcons.whatsapp,
    'instagram': FontAwesomeIcons.instagram,
    'twitter': FontAwesomeIcons.twitter,
    'youtube': FontAwesomeIcons.youtube,
    'snapchat': FontAwesomeIcons.snapchat,
    'telegram': FontAwesomeIcons.telegram,
    'gmail': FontAwesomeIcons.envelope,
    'chrome': FontAwesomeIcons.chrome,
    'camera': FontAwesomeIcons.camera,
    'phone': FontAwesomeIcons.phone,
    'maps': FontAwesomeIcons.map,
    'drive': FontAwesomeIcons.googleDrive,
    'netflix': FontAwesomeIcons.n,
    'spotify': FontAwesomeIcons.spotify,
    'zoom': FontAwesomeIcons.video,
    'tiktok': FontAwesomeIcons.music,
  };

  @override
  void initState() {
    super.initState();
    loadApps();
    _searchAllController.addListener(_filterAllApps);
    _searchNewController.addListener(_filterNewApps);
  }

  Future<List<dynamic>> _fetchInstalledAppsData() async {
    final apidata = await fetchModuleData(
      module: 'iapp',
      userId: widget.username,
    );
    final data = await ParentDecryption.decrypt(apidata, widget.username);
    return data?['data']?['InstalledApps'] ?? [];
  }

  Future<void> loadApps() async {
    final appsList = await _fetchInstalledAppsData();
    final apps = appsList
        .map<Map<String, String>>(
          (e) => {'name': e['name'] ?? 'Unknown', 'package': e['package'] ?? ''},
        )
        .toList();

    apps.sort((a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));
    final recent = apps.length > 5 ? apps.sublist(0, 5) : apps;

    setState(() {
      installedApps = apps;
      filteredApps = List.from(apps);
      newApps = List.from(recent);
      isLoading = false;
    });
  }

  void _filterAllApps() {
    final query = _searchAllController.text.toLowerCase();
    setState(() {
      filteredApps = installedApps
          .where((app) => app['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _filterNewApps() {
    final query = _searchNewController.text.toLowerCase();
    setState(() {
      newApps = installedApps
          .sublist(0, installedApps.length > 5 ? 5 : installedApps.length)
          .where((app) => app['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  IconData getIconFromAppName(String appName) {
    final lower = appName.toLowerCase();
    for (final keyword in iconMap.keys) {
      if (lower.contains(keyword)) {
        return iconMap[keyword]!;
      }
    }
    return FontAwesomeIcons.android;
  }

  @override
  void dispose() {
    _searchAllController.dispose();
    _searchNewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.grey.shade800;

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
            boxShadow: isDark
                ? null
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            'Installed Apps',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'NexaBold',
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadApps();
            },
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: isDark
                ? [Colors.black, Colors.black, Colors.black]
                : const [Color(0xFF0090FF), Color(0xFF15D6A6), Color(0xFF123A5B)],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
                padding: const EdgeInsets.only(
                    top: kToolbarHeight + 12, left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Installed Apps
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (!isDark)
                              const BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Text(
                          'Total Installed Apps: ${installedApps.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NexaBold',
                            color: isDark
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // App lists
                    Expanded(
                      child: Row(
                        children: [
                          // All Installed Apps
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade900 : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.apps, color: iconColor),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'All Installed Apps',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NexaBold',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _searchAllController,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontFamily: 'NexaBold',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search apps...',
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                        fontFamily: 'NexaBold',
                                      ),
                                      prefixIcon: Icon(Icons.search,
                                          color:
                                              isDark ? Colors.white : Colors.black),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Scrollbar(
                                      child: ListView.builder(
                                        itemCount: filteredApps.length,
                                        itemBuilder: (context, index) {
                                          final app = filteredApps[index];
                                          final icon =
                                              getIconFromAppName(app['name']!);
                                          return ListTile(
                                            leading:
                                                FaIcon(icon, color: iconColor),
                                            title: Text(
                                              app['name']!,
                                              style: TextStyle(
                                                fontFamily: 'NexaBold',
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ).animate().fadeIn(delay: (index * 50).ms);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Newly Installed Apps
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade900 : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.fiber_new, color: iconColor),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Newly Installed Apps',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NexaBold',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _searchNewController,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontFamily: 'NexaBold',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search new apps...',
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                        fontFamily: 'NexaBold',
                                      ),
                                      prefixIcon: Icon(Icons.search,
                                          color:
                                              isDark ? Colors.white : Colors.black),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Count: ${newApps.length}',
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.white70 : Colors.black54,
                                      fontFamily: 'NexaBold',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Scrollbar(
                                      child: ListView.builder(
                                        itemCount: newApps.length,
                                        itemBuilder: (context, index) {
                                          final app = newApps[index];
                                          return ListTile(
                                            leading: Icon(Icons.new_releases,
                                                color: Colors.blueAccent),
                                            title: Text(
                                              app['name']!,
                                              style: TextStyle(
                                                fontFamily: 'NexaBold',
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ).animate().fadeIn(delay: (index * 80).ms);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
