import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

/// Service untuk mengelola image pick & crop
class ImageService {
  static final Logger _log = Logger();

  /// Membuka gallery lalu crop gambar.
  /// Menampilkan bottom sheet pilihan sumber gambar.
  /// Mengembalikan [File] hasil crop, atau null jika dibatalkan.
  static Future<File?> pickAndCropImage(BuildContext context) async {
    final source = await _showSourcePicker(context);
    if (source == null) return null;

    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null) {
      _log.i('[ImageService] User cancelled image pick');
      return null;
    }

    _log.i('[ImageService] Image picked: ${picked.path}');

    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Gambar',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Gambar',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],
    );

    if (cropped == null) {
      _log.i('[ImageService] User cancelled crop');
      return null;
    }

    _log.i('[ImageService] Image cropped: ${cropped.path}');
    return File(cropped.path);
  }

  /// Menampilkan bottom sheet untuk memilih sumber gambar (kamera / galeri).
  static Future<ImageSource?> _showSourcePicker(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
