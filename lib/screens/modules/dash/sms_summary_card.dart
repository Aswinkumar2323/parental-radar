import 'package:flutter/material.dart';
import '../../../apis/get.dart';
import '../../../decryption/parent_decryption.dart';

class SmsSummaryCard extends StatefulWidget {
  final String username;
  final Function(int) onJumpToIndex;
  final VoidCallback onModuleLoaded;

  const SmsSummaryCard({
    super.key,
    required this.username,
    required this.onJumpToIndex,
    required this.onModuleLoaded,
  });

  @override
  State<SmsSummaryCard> createState() => _SmsSummaryCardState();
}

class _SmsSummaryCardState extends State<SmsSummaryCard> {
  late Future<List<dynamic>> smsListFuture;

  @override
  void initState() {
    super.initState();
    smsListFuture = _fetchSmsData();
  }

  Future<List<dynamic>> _fetchSmsData() async {
    final apiData = await fetchModuleData(
      module: 'sms',
      userId: widget.username,
    );
    final decrypted = await ParentDecryption.decrypt(apiData, widget.username);
    widget.onModuleLoaded();
    return decrypted?['data']?['sms_data'] ?? [];
  }

  Widget _buildBasicCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$title\n$subtitle',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<dynamic>>(
      future: smsListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('Unable to load SMS data.'));
        }

        final smsList = snapshot.data!;
        final inbox = smsList.where((msg) => msg['type'] == '1').length;
        final sent = smsList.where((msg) => msg['type'] == '2').length;

        final contactFreq = <String, int>{};
        for (var sms in smsList) {
          final address = sms['address'] ?? 'Unknown';
          contactFreq[address] = (contactFreq[address] ?? 0) + 1;
        }
        final topContact =
            contactFreq.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
        final topName = topContact.isNotEmpty ? topContact.first.key : 'N/A';
        final topCount = topContact.isNotEmpty ? topContact.first.value : 0;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: isDark ? Colors.grey.shade900 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: const [
                    Icon(Icons.sms, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'SMS Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBasicCard(
                  context: context,
                  title: 'INCOMING SMS',
                  subtitle: '$inbox msg${inbox == 1 ? '' : 's'}',
                  icon: Icons.call_received,
                  onTap: () => widget.onJumpToIndex(3),
                ),
                const SizedBox(height: 8),
                _buildBasicCard(
                  context: context,
                  title: 'OUTGOING SMS',
                  subtitle: '$sent msg${sent == 1 ? '' : 's'}',
                  icon: Icons.call_made,
                  onTap: () => widget.onJumpToIndex(3),
                ),
                const SizedBox(height: 8),
                _buildBasicCard(
                  context: context,
                  title: 'Top Contact Today',
                  subtitle:
                      '$topName: $topCount msg${topCount == 1 ? '' : 's'}',
                  icon: Icons.person,
                  onTap: () => widget.onJumpToIndex(3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}