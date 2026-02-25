import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class TextFromImagePage extends StatefulWidget {
  const TextFromImagePage({super.key});

  @override
  State<TextFromImagePage> createState() => _TextFromImagePageState();
}

class _TextFromImagePageState extends State<TextFromImagePage> {
  Uint8List? imageBytes;
  File? pickedImage; // only used on mobile/desktop for ML Kit
  String extractedText = '';
  bool isLoading = false;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? xFile = await picker.pickImage(source: source);
    if (xFile == null) return;

    setState(() {
      isLoading = true;
      extractedText = '';
    });

    Uint8List bytes = await xFile.readAsBytes();
    String text = '';

    if (!kIsWeb) {
      // Mobile/Desktop: full OCR support
      pickedImage = File(xFile.path);
      text = await extractText(pickedImage!);
    } else {
      // Web: no ML Kit support yet
      text = "Text recognition is not supported in web browsers yet.\n\n"
          "Please use the mobile app (Android/iOS) for OCR functionality.\n"
          "You can still view the image and copy/save it manually.";
    }

    if (mounted) {
      setState(() {
        imageBytes = bytes;
        extractedText = text;
        isLoading = false;
      });
    }
  }

  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      return recognizedText.text;
    } catch (e) {
      return "Error during text recognition:\n$e";
    }
  }

  Future<void> savePDF() async {
    if (extractedText.isEmpty) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Text(extractedText),
        ),
      ),
    );

    String? folderPath;

    if (Platform.isAndroid && !kIsWeb) {
      folderPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Select folder to save PDF",
      );
      if (folderPath == null) return;
    } else {
      final dir = await getTemporaryDirectory();
      folderPath = dir.path;
    }

    final file = File(
      '$folderPath/extracted_text_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("PDF saved at ${file.path}")));
    }
  }

  Future<void> sharePDF() async {
    if (extractedText.isEmpty) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Text(extractedText),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/extracted_text.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(filePath),
    ], text: "Extracted text from image");
  }

  Future<void> copyText() async {
    if (extractedText.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: extractedText));

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Text copied to clipboard")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Text From Image"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (imageBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imageBytes!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (extractedText.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: SelectableText(
                        extractedText,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ] else if (!isLoading && imageBytes == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: Text(
                          "Pick an image from camera or gallery\nto start extracting text",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SafeArea(
              top: false,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text("Camera"),
                    onPressed: () => pickImage(ImageSource.camera),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.photo_library, size: 20),
                    label: const Text("Gallery"),
                    onPressed: () => pickImage(ImageSource.gallery),
                  ),
                  if (!kIsWeb) ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf, size: 20),
                      label: const Text("Save PDF"),
                      onPressed: savePDF,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.share, size: 20),
                      label: const Text("Share PDF"),
                      onPressed: sharePDF,
                    ),
                  ],
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 20),
                    label: const Text("Copy Text"),
                    onPressed: copyText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
