import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeViewModel extends ChangeNotifier {
  XFile? _selectedImage;
  String _metadata = 'Please select an image to view metadata.';
  String? _clearedImagePath;
  bool _isLoading = false;
  String? _error;

  XFile? get selectedImage => _selectedImage;
  String get metadata => _metadata;
  String? get clearedImagePath => _clearedImagePath;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> pickImage(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        _isLoading = false;
        _error = 'Image selection cancelled or permission denied.';
        notifyListeners();
        return;
      }
      _selectedImage = image;
      _metadata = 'Please wait... reading metadata...';
      notifyListeners();
      await _readMetadata();
    } catch (e) {
      _error = 'Failed to pick image: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _readMetadata() async {
    if (_selectedImage == null) return;
    final fileBytes = await _selectedImage!.readAsBytes();
    final Map<String, IfdTag> data = await readExifFromBytes(fileBytes);
    if (data.isEmpty) {
      _metadata = "No EXIF data found in the image.";
      notifyListeners();
      return;
    }
    StringBuffer buffer = StringBuffer();
    data.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    _metadata = buffer.toString();
    notifyListeners();
  }

  Future<void> clearAndSaveMetadata(BuildContext context) async {
    if (_selectedImage == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fileBytes = await _selectedImage!.readAsBytes();
      final originalImage = img.decodeImage(fileBytes);
      if (originalImage == null) {
        _error = 'Failed to decode image.';
        notifyListeners();
        return;
      }
      final img.Image cleanImage = img.Image.from(originalImage);
      final directory = await getTemporaryDirectory();
      final String tempPath = directory.path;
      final String newFilePath =
          '$tempPath/cleared_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newFile = File(newFilePath);
      newFile.writeAsBytesSync(img.encodeJpg(cleanImage));
      _clearedImagePath = newFilePath;
      notifyListeners();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Metadata cleared and saved to: $newFilePath')),
      );
    } catch (e) {
      _error = 'Failed to clear metadata: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> shareClearedImage() async {
    if (_clearedImagePath != null) {
      await SharePlus.instance.share(
        ShareParams(
          title: "MaTaDaTa App",
          subject: "Metadata is cleared!",
          previewThumbnail: XFile(_clearedImagePath!),
          files: [XFile(_clearedImagePath!)],
        ),
      );
    }
  }

  void reset() {
    _selectedImage = null;
    _metadata = 'Please select an image to view metadata.';
    _clearedImagePath = null;
    _error = null;
    notifyListeners();
  }
}
