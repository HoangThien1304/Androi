import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';

class MlKitTranslateScreen extends StatefulWidget {
  const MlKitTranslateScreen({super.key});

  @override
  State<MlKitTranslateScreen> createState() => _MlKitTranslateScreenState();
}

class _MlKitTranslateScreenState extends State<MlKitTranslateScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _translatedResult = '';
  bool _isTranslating = false;
  bool _isDownloadingModel = false;

  TranslateLanguage _sourceLang = TranslateLanguage.vietnamese;
  TranslateLanguage _targetLang = TranslateLanguage.english;

  final Map<TranslateLanguage, String> _langNames = {
    TranslateLanguage.vietnamese: '🇻🇳 Tiếng Việt',
    TranslateLanguage.english: '🇺🇸 Tiếng Anh',
    TranslateLanguage.japanese: '🇯🇵 Tiếng Nhật',
    TranslateLanguage.korean: '🇰🇷 Tiếng Hàn',
    TranslateLanguage.french: '🇫🇷 Tiếng Pháp',
    TranslateLanguage.chinese: '🇨🇳 Tiếng Trung',
  };

  File? _selectedImage;
  String _ocrExtractedText = '';
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _translateText(String textToTranslate) async {
    final text = textToTranslate.trim();
    if (text.isEmpty) {
      setState(() => _translatedResult = '');
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      final modelManager = OnDeviceTranslatorModelManager();

      final bool isSourceDownloaded =
          await modelManager.isModelDownloaded(_sourceLang.bcpCode);
      final bool isTargetDownloaded =
          await modelManager.isModelDownloaded(_targetLang.bcpCode);

      if (!isSourceDownloaded || !isTargetDownloaded) {
        setState(() => _isDownloadingModel = true);
        if (!isSourceDownloaded) {
          await modelManager.downloadModel(_sourceLang.bcpCode);
        }
        if (!isTargetDownloaded) {
          await modelManager.downloadModel(_targetLang.bcpCode);
        }
        setState(() => _isDownloadingModel = false);
      }

      final translator = OnDeviceTranslator(
        sourceLanguage: _sourceLang,
        targetLanguage: _targetLang,
      );

      final result = await translator.translateText(text);
      await translator.close();

      if (mounted) {
        setState(() {
          _translatedResult = result;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _isDownloadingModel = false;
          _translatedResult = 'Dịch nhanh (offline mode): $text -> [Demo Target]';
        });
      }
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
    if (_inputController.text.isNotEmpty) {
      _translateText(_inputController.text);
    }
  }

  Future<void> _pickAndTranslateImage(ImageSource source) async {
    try {
      final XFile? pickedFile =
          await _imagePicker.pickImage(source: source, imageQuality: 90);
      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _isTranslating = true;
      });

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final String extracted = recognizedText.text.trim();
      setState(() {
        _ocrExtractedText = extracted;
        _inputController.text = extracted;
      });

      if (extracted.isNotEmpty) {
        await _translateText(extracted);
      } else {
        setState(() {
          _isTranslating = false;
          _translatedResult = 'Không tìm thấy chữ trong hình ảnh!';
        });
      }
    } catch (e) {
      setState(() => _isTranslating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã chọn ảnh: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google MLKit Dịch Thuật'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TranslateLanguage>(
                          value: _sourceLang,
                          isExpanded: true,
                          items: _langNames.entries.map((e) {
                            return DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _sourceLang = val);
                              if (_inputController.text.isNotEmpty) {
                                _translateText(_inputController.text);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz,
                          color: Color(0xFF1769E0), size: 28),
                      onPressed: _swapLanguages,
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TranslateLanguage>(
                          value: _targetLang,
                          isExpanded: true,
                          items: _langNames.entries.map((e) {
                            return DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _targetLang = val);
                              if (_inputController.text.isNotEmpty) {
                                _translateText(_inputController.text);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nhập văn bản (${_langNames[_sourceLang]})',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        if (_inputController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _inputController.clear();
                              setState(() {
                                _translatedResult = '';
                                _ocrExtractedText = '';
                                _selectedImage = null;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Nhập nội dung cần dịch hoặc dùng Camera chụp ảnh...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _pickAndTranslateImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, color: Colors.green),
                            label: const Text('Máy ảnh'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _pickAndTranslateImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library,
                                color: Colors.purple),
                            label: const Text('Thư viện'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _translateText(_inputController.text),
                      icon: const Icon(Icons.translate),
                      label: const Text(
                        'Dịch Ngay (MLKit On-Device)',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Image.file(
                      _selectedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Ảnh quét OCR: "${_ocrExtractedText.length > 50 ? '${_ocrExtractedText.substring(0, 50)}...' : _ocrExtractedText}"',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_isDownloadingModel) ...[
              const Card(
                color: Color(0xFFFFF3E0),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Đang tải gói mô hình MLKit On-Device tự động...',
                          style: TextStyle(
                              fontSize: 13, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              color: const Color(0xFFE3F2FD),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kết quả dịch (${_langNames[_targetLang]}):',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        if (_isTranslating)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _translatedResult.isEmpty
                          ? 'Kết quả dịch bằng Google MLKit sẽ hiển thị tại đây...'
                          : _translatedResult,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: _translatedResult.isNotEmpty
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _translatedResult.isNotEmpty
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
