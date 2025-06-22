import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CertificateView extends StatefulWidget {
  final String language;
  final String date;
  final String name;

  const CertificateView({super.key, required this.language, required this.date, required this.name});

  @override
  State<CertificateView> createState() => _CertificateViewState();
}

class _CertificateViewState extends State<CertificateView> {
  String? userName;
  String? completionDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCertificateData();
  }

  Future<void> fetchCertificateData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final userInfo = await Supabase.instance.client
        .from('users')
        .select('name')
        .eq('id', user.id)
        .maybeSingle();

    final name = userInfo?['name'] ?? user.email ?? 'User';

    final cert = await Supabase.instance.client
        .from('certificates')
        .select('date')
        .eq('user_id', user.id)
        .eq('language', widget.language)
        .maybeSingle();

    final rawDate = cert?['date'];
    final formattedDate = rawDate != null
        ? DateFormat('MMMM d, yyyy').format(DateTime.parse(rawDate))
        : 'Unknown';

    setState(() {
      userName = name;
      completionDate = formattedDate;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2A2575);
    const accentColor = Color(0xFF8E8FFA);
    const backgroundColor = Color(0xFFF5F9FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Certificate'),
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 4),
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎓 Certificate of Completion 🎓',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1.5, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text(
                      'This certifies that',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userName ?? '...',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'has successfully completed the CodeMaster course entitled:',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.language,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Date: $completionDate',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'CodeMaster',
                            style: TextStyle(
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      }
