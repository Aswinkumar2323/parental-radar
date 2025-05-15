import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../apis/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';
import '../../decryption/parent_decryption.dart';

class SmsScreen extends StatefulWidget {
  final String username;

  const SmsScreen({Key? key, required this.username}) : super(key: key);

  @override
  _SmsScreenState createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  late Future<List<dynamic>> smsListFuture;
  String activeCategory = 'All';

  final Map<String, List<String>> categoryFilters = {
    'Bank': ['OTP', 'account', 'transaction', 'Rs.', 'debit', 'credit'],
    'Food': ['order', 'food', 'swiggy', 'zomato'],
    'Promo': ['offer', 'sale', 'discount', 'deal'],
    'Unknown': [],
  };

  @override
  void initState() {
    super.initState();
    smsListFuture = _fetchSmsData();
  }

    Future<List<dynamic>> _fetchSmsData() async {
    final apidata = await fetchModuleData(
      module: 'sms',
      userId: widget.username,
    );
    final data = await ParentDecryption.decrypt(apidata, widget.username);
    return data?['data']?['sms_data'] ?? [];
  }


  void refresh() => setState(() {
        smsListFuture = _fetchSmsData();
      });

  String _formatDate(String timestamp) {
    try {
      final millis = int.tryParse(timestamp);
      if (millis != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(millis);
        return DateFormat("MMM d, h:mm a").format(dt);
      }
    } catch (_) {}
    return timestamp;
  }

  String _smsType(String? type) {
    switch (type) {
      case '1':
        return 'Inbox';
      case '2':
        return 'Sent';
      default:
        return 'Unknown';
    }
  }

  int _countMessages(List list, String type) =>
      list.where((msg) => msg['type'] == type).length;

  bool _matchesCategory(Map sms, String category) {
    if (category == 'All') return true;
    if (category == 'Unknown') {
      final body = (sms['body'] ?? '').toString().toLowerCase();
      return !categoryFilters.values
          .expand((list) => list)
          .any((keyword) => body.contains(keyword.toLowerCase()));
    }
    final keywords = categoryFilters[category]!;
    final body = (sms['body'] ?? '').toString().toLowerCase();
    return keywords.any((keyword) => body.contains(keyword.toLowerCase()));
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
      'SMS Monitoring',
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
      onPressed: refresh,
      color: Colors.white, // Optional: make visible on gradient background
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
        child: FutureBuilder<List<dynamic>>(
          future: smsListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (!snapshot.hasData || snapshot.hasError) {
              return const Center(
                child: Text(
                  'Failed to load data.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final smsList = snapshot.data!;
            final inbox = _countMessages(smsList, '1');
            final sent = _countMessages(smsList, '2');

            final contactFreq = <String, int>{};
            for (var sms in smsList) {
              final address = sms['address'] ?? 'Unknown';
              contactFreq[address] = (contactFreq[address] ?? 0) + 1;
            }
            final topContact = contactFreq.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final filteredList = smsList
                .where((sms) => _matchesCategory(sms, activeCategory))
                .toList()
              ..sort((a, b) =>
                  int.parse(b['date']).compareTo(int.parse(a['date'])));

            return ListView(
              padding: const EdgeInsets.fromLTRB(0, kToolbarHeight + 15, 0, 15),
              children: [
  const SizedBox(height: 20),
  _statCard('INCOMING SMS', inbox, true, isDark),
  const SizedBox(height: 20),
  _statCard('OUTGOING SMS', sent, false, isDark),
  const SizedBox(height: 20),
  _topContactCard(topContact, isDark),
  const SizedBox(height: 20),
  _categoryBar(isDark),
  const SizedBox(height: 20),
  const Divider(color: Colors.white70),
  const SizedBox(height: 20),
  ...filteredList.map((sms) => Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: _smsTile(sms, isDark),
  )),
  const SizedBox(height: 20),
],



            );
          },
        ),
      ),
    );
  }



  Widget _statCard(String title, int count, bool isIncoming, bool isDark) {
    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          isIncoming ? Icons.call_received : Icons.call_made,
          color: isIncoming ? Colors.green : Colors.red,
        ),
        title: Text(
          title,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        subtitle: LinearProgressIndicator(
          value: (count / 100).clamp(0.0, 1.0),
          color: isIncoming ? Colors.green : Colors.red,
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        trailing: RichText(
          textAlign: TextAlign.end,
          text: TextSpan(
            text: '$count ',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            children: [
              TextSpan(
                text: 'msg${count == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topContactCard(List<MapEntry<String, int>> contacts, bool isDark) {
    if (contacts.isEmpty) return const SizedBox();
    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text('Top Contact Today',
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        subtitle: Text(contacts.first.key,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        trailing: Text('${contacts.first.value} msgs',
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _categoryBar(bool isDark) {
    final allCategories = ['All', ...categoryFilters.keys];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: allCategories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: cat == activeCategory,
              onSelected: (_) => setState(() => activeCategory = cat),
              selectedColor: isDark ? Colors.white24 : Colors.white,
              backgroundColor:
                  isDark ? Colors.grey.shade800 : Colors.white70,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _smsTile(Map sms, bool isDark) {
    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDark ? Colors.white10 : Colors.blue.shade100,
          child: const Icon(Icons.sms),
        ),
        title: Text(
          sms['address'] ?? 'Unknown',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        subtitle: Text(
          sms['body'] ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_smsType(sms['type']),
                style:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black)),
            Text(
              _formatDate(sms['date'].toString()),
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
