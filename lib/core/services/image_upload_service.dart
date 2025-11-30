import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../utils.dart';

class ImageUploadService {
  static ImageUploadService? _instance;
  static ImageUploadService get instance => _instance ??= ImageUploadService._();

  ImageUploadService._();

  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Pick an image from camera or gallery
  Future<File?> pickImage({
    required ImageSource source,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      AppLogger.logError('Failed to pick image', error: e);
      rethrow;
    }
  }

  /// Crop the selected image
  Future<File?> cropImage({
    required File imageFile,
    CropAspectRatio aspectRatio = const CropAspectRatio(ratioX: 1, ratioY: 1),
  }) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: aspectRatio,
        compressQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Color(0xFF1976D2),
            toolbarWidgetColor: Color(0xFFFFFFFF),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            hideBottomControls: false,
            statusBarColor: Color(0xFF1976D2),
            activeControlsWidgetColor: Color(0xFF1976D2),
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (croppedFile == null) {
        return null;
      }

      return File(croppedFile.path);
    } catch (e) {
      AppLogger.logError('Failed to crop image', error: e);
      rethrow;
    }
  }

  /// Compress the image
  Future<File?> compressImage({
    required File imageFile,
    int quality = 70,
    int maxSizeKB = 300,
  }) async {
    try {
      final String targetPath = imageFile.path.replaceAll(
        path.extension(imageFile.path),
        '_compressed.jpg',
      );

      // More aggressive compression for faster uploads
      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg, // Always use JPEG for smaller size
      );

      if (compressedFile == null) {
        return imageFile; // Return original if compression fails
      }

      final File compressed = File(compressedFile.path);

      // Check file size and reduce quality if still too large
      final int fileSizeKB = await compressed.length() ~/ 1024;
      if (fileSizeKB > maxSizeKB && quality > 40) {
        AppLogger.logInfo('Image still large ($fileSizeKB KB), compressing further...');
        return await compressImage(
          imageFile: imageFile,
          quality: quality - 15,
          maxSizeKB: maxSizeKB,
        );
      }

      AppLogger.logInfo('✅ Image compressed: ${fileSizeKB}KB (quality: $quality)');
      return compressed;
    } catch (e) {
      AppLogger.logError('Failed to compress image', error: e);
      return imageFile; // Return original on error
    }
  }

  /// Upload image to Supabase Storage
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final String fileName = 'profile_$userId\_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'profiles/$fileName';

      // Upload to Supabase Storage
      final String uploadPath = await _supabase.storage
          .from('avatars')
          .upload(filePath, imageFile, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ));

      // Get public URL
      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      AppLogger.logInfo('Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      AppLogger.logError('Failed to upload image', error: e);
      rethrow;
    }
  }

  /// Delete old profile image from storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final Uri uri = Uri.parse(imageUrl);
      final List<String> pathSegments = uri.pathSegments;
      
      // Find the path after 'avatars'
      final int avatarsIndex = pathSegments.indexOf('avatars');
      if (avatarsIndex != -1 && avatarsIndex < pathSegments.length - 1) {
        final String filePath = pathSegments.sublist(avatarsIndex + 1).join('/');
        
        await _supabase.storage.from('avatars').remove([filePath]);
        AppLogger.logInfo('Old profile image deleted: $filePath');
      }
    } catch (e) {
      AppLogger.logError('Failed to delete old image', error: e);
      // Don't throw - deletion failure shouldn't block upload
    }
  }

  /// Complete workflow: pick, crop, compress, and upload
  Future<String?> pickCropCompressAndUpload({
    required ImageSource source,
    required String userId,
    String? oldImageUrl,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Step 1: Pick image
      AppLogger.logInfo('📷 Starting image selection...');
      final File? pickedImage = await pickImage(source: source);
      if (pickedImage == null) {
        AppLogger.logInfo('❌ No image selected');
        return null;
      }
      AppLogger.logInfo('✅ Image selected (${stopwatch.elapsedMilliseconds}ms)');

      // Step 2: Crop image
      AppLogger.logInfo('✂️ Cropping image...');
      final File? croppedImage = await cropImage(imageFile: pickedImage);
      if (croppedImage == null) {
        AppLogger.logInfo('❌ Image cropping cancelled');
        return null;
      }
      AppLogger.logInfo('✅ Image cropped (${stopwatch.elapsedMilliseconds}ms)');

      // Step 3: Compress image
      AppLogger.logInfo('🗜️ Compressing image...');
      final startCompress = stopwatch.elapsedMilliseconds;
      final File? compressedImage = await compressImage(imageFile: croppedImage);
      if (compressedImage == null) {
        AppLogger.logInfo('❌ Image compression failed');
        return null;
      }
      final compressTime = stopwatch.elapsedMilliseconds - startCompress;
      AppLogger.logInfo('✅ Compression done in ${compressTime}ms (total: ${stopwatch.elapsedMilliseconds}ms)');

      // Step 4: Delete old image if exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        AppLogger.logInfo('🗑️ Deleting old image...');
        await deleteProfileImage(oldImageUrl);
      }

      // Step 5: Upload to Supabase
      AppLogger.logInfo('☁️ Uploading to Supabase Storage...');
      final startUpload = stopwatch.elapsedMilliseconds;
      final String? imageUrl = await uploadProfileImage(
        imageFile: compressedImage,
        userId: userId,
      );
      final uploadTime = stopwatch.elapsedMilliseconds - startUpload;
      AppLogger.logInfo('✅ Upload completed in ${uploadTime}ms');

      // Clean up temporary files
      try {
        if (await pickedImage.exists()) await pickedImage.delete();
        if (await croppedImage.exists() && croppedImage.path != compressedImage.path) {
          await croppedImage.delete();
        }
        if (await compressedImage.exists()) await compressedImage.delete();
      } catch (e) {
        AppLogger.logError('Failed to clean up temp files', error: e);
      }

      stopwatch.stop();
      AppLogger.logInfo('🎉 Total time: ${stopwatch.elapsedMilliseconds}ms (~${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s)');
      
      return imageUrl;
    } catch (e) {
      AppLogger.logError('Failed to process and upload image', error: e);
      rethrow;
    }
  }
}
