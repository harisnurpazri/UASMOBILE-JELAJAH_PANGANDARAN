import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // Bucket name untuk wisata images
  static const String bucketName = 'wisata-images';

  /// Pick image dari galeri
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick image dari kamera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Upload image ke Supabase Storage
  /// Returns: Public URL of uploaded image, or null if failed
  Future<String?> uploadImage(XFile imageFile, String wisataName) async {
    try {
      // Read image bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Generate unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = imageFile.name.split('.').last.toLowerCase();
      final String sanitizedName = wisataName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '-')
          .replaceAll(RegExp(r'-+'), '-')
          .substring(0, wisataName.length > 20 ? 20 : wisataName.length);
      final String fileName = '$sanitizedName-$timestamp.$extension';
      final String filePath = 'wisata/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
              upsert: false,
            ),
          );

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      debugPrint('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from Supabase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final Uri uri = Uri.parse(imageUrl);
      final String fullPath = uri.path;

      // Remove bucket prefix from path
      final String filePath = fullPath.split('/$bucketName/').last;

      await _supabase.storage.from(bucketName).remove([filePath]);

      debugPrint('✅ Image deleted successfully: $filePath');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Check if bucket exists (don't try to create, admin must create manually)
  Future<bool> ensureBucketExists() async {
    try {
      // Try to get bucket info
      await _supabase.storage.getBucket(bucketName);
      debugPrint('✅ Bucket "$bucketName" exists');
      return true;
    } catch (e) {
      debugPrint(
        '❌ Bucket "$bucketName" not found. Please create it manually in Supabase Dashboard.',
      );
      return false;
    }
  }
}
