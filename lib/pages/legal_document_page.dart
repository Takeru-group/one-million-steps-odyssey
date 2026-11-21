import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

enum LegalDocumentType {
  termsOfService,
  privacyPolicy,
}

class LegalDocumentPage extends StatefulWidget {
  final LegalDocumentType documentType;

  const LegalDocumentPage({
    super.key,
    required this.documentType,
  });

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  String? _markdownContent;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_markdownContent == null) {
      _loadDocument();
    }
  }

  Future<void> _loadDocument() async {
    final langCode = Localizations.localeOf(context).languageCode;
    final isEn = langCode == 'en';

    final String docId;
    final String assetPath;

    if (widget.documentType == LegalDocumentType.termsOfService) {
      docId = isEn ? 'terms_en' : 'terms_ja';
      assetPath = isEn ? 'assets/legal/terms_en.md' : 'assets/legal/terms_ja.md';
    } else {
      docId = isEn ? 'privacy_en' : 'privacy_ja';
      assetPath = isEn ? 'assets/legal/privacy_policy_en.md' : 'assets/legal/privacy_policy_ja.md';
    }

    String? loadedText;

    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('legal_documents')
          .doc(docId)
          .get()
          .timeout(const Duration(seconds: 3));

      if (docSnap.exists) {
        final data = docSnap.data();
        final remoteMd = data?['content'] as String?;
        if (remoteMd != null && remoteMd.trim().isNotEmpty) {
          loadedText = remoteMd.replaceAll(r'\n', '\n');
        }
      }
    } catch (_) {}

    if (loadedText == null || loadedText.isEmpty) {
      try {
        loadedText = await rootBundle.loadString(assetPath);
      } catch (e) {
        loadedText = isEn
            ? 'Failed to load document.'
            : 'ドキュメントの読み込みに失敗しました。';
      }
    }

    if (mounted) {
      setState(() {
        _markdownContent = loadedText;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;
    final isEn = langCode == 'en';

    final title = widget.documentType == LegalDocumentType.termsOfService
        ? (isEn ? 'Terms of Service' : '利用規約')
        : (isEn ? 'Privacy Policy' : 'プライバシーポリシー');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Markdown(
                data: _markdownContent ?? '',
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.amberAccent : Colors.deepPurple,
                    height: 1.4,
                  ),
                  h2: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    height: 1.5,
                  ),
                  h3: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                  p: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.85) : Colors.black87,
                    height: 1.65,
                  ),
                  listBullet: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.amberAccent : Colors.deepPurple,
                  ),
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
