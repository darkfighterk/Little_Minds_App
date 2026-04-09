import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);

class TextFromImagePage extends StatefulWidget {
  const TextFromImagePage({super.key});
  @override
  State<TextFromImagePage> createState() => _TextFromImagePageState();
}

class _TextFromImagePageState extends State<TextFromImagePage> {
  Uint8List? imageBytes;
  String extractedText = '';
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? xFile = await picker.pickImage(source: source);
    if (xFile == null) return;

    setState(() {
      isLoading = true;
      extractedText = '';
      imageBytes = null;
    });

    final bytes = await xFile.readAsBytes();
    setState(() {
      imageBytes = bytes;
    });

    String text = '';
    if (!kIsWeb) {
      try {
        final inputImage = InputImage.fromFilePath(xFile.path);
        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.latin);
        final recognizedText = await textRecognizer.processImage(inputImage);
        text = recognizedText.text;
        await textRecognizer.close();
      } catch (e) {
        text = "Detection Error: $e";
      }
    } else {
      text = "OCR is best on Mobile! 🚀";
    }

    if (mounted) {
      setState(() {
        extractedText = text;
        isLoading = false;
      });
    }
  }

  Future<void> saveAndSharePDF() async {
    if (extractedText.isEmpty) return;
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Text(extractedText))));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/discovery.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: "Magic Discovery! ✨");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87),
            onPressed: () => Navigator.pop(context)),
        title: const Text("Scan Your Notes",
            style: TextStyle(
                fontFamily: 'Recoleta',
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                _buildPreview(),
                const SizedBox(height: 30),
                if (isLoading)
                  const CircularProgressIndicator(color: mainBlue)
                else
                  _buildTextDisplay(),
              ]),
            ),
          ),
          _buildActionPanel(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
          color: mainBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: mainBlue.withValues(alpha: 0.1))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: imageBytes != null
            ? Image.memory(imageBytes!, fit: BoxFit.contain)
            : const Icon(Icons.image_search_rounded, size: 80, color: mainBlue),
      ),
    );
  }

  Widget _buildTextDisplay() {
    if (extractedText.isEmpty && !isLoading) {
      return Text("Scan your study notes to see magic! ✨",
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold, color: Colors.black38));
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: mainBlue.withValues(alpha: 0.1))),
      child: SelectableText(extractedText,
          style: GoogleFonts.nunito(fontSize: 16, height: 1.5)),
    );
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5))
      ]),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _btn(Icons.camera_alt, "Camera", mainBlue,
              () => pickImage(ImageSource.camera)),
          _btn(Icons.photo_library, "Gallery", secondaryPurple,
              () => pickImage(ImageSource.gallery)),
          if (imageBytes != null) ...[
            _btn(Icons.copy, "Copy", accentOrange, () {
              Clipboard.setData(ClipboardData(text: extractedText));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Magic words copied! 🪄")));
            }),
            _btn(Icons.share, "Share PDF", Colors.redAccent, saveAndSharePDF),
          ],
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label, Color col, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
          backgroundColor: col,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
    );
  }
}
