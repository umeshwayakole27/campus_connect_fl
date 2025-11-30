# Supabase Storage Setup for Profile Pictures

## Overview
Profile pictures are stored as **URLs in the database**, NOT as binary data. The actual images are stored in **Supabase Storage**.

## Database Schema

```sql
-- users table stores the URL (TEXT), not the image itself
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE,
  name TEXT,
  role TEXT,
  profile_pic TEXT,  -- ← Stores the URL, not the image
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Storage Structure

```
Supabase Storage
└── avatars (bucket)
    └── profiles/
        ├── profile_{userId}_{timestamp}.jpg
        ├── profile_{userId}_{timestamp}.jpg
        └── ...
```

## Setup Instructions

### Step 1: Create Storage Bucket

1. Go to your Supabase Dashboard
2. Navigate to **Storage** in the left sidebar
3. Click **"New Bucket"**
4. Settings:
   - **Name**: `avatars`
   - **Public bucket**: ✅ **Yes** (checked)
   - **File size limit**: 5 MB
   - **Allowed MIME types**: `image/jpeg, image/png, image/jpg`

### Step 2: Set Bucket Policies

Go to **Storage** → **Policies** → **avatars** bucket

#### Policy 1: Allow Public Read
```sql
CREATE POLICY "Public Access" ON storage.objects
FOR SELECT
USING ( bucket_id = 'avatars' );
```

#### Policy 2: Allow Authenticated Upload
```sql
CREATE POLICY "Authenticated users can upload" ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
);
```

#### Policy 3: Allow Users to Update Their Own Files
```sql
CREATE POLICY "Users can update own files" ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[2]
);
```

#### Policy 4: Allow Users to Delete Their Own Files
```sql
CREATE POLICY "Users can delete own files" ON storage.objects
FOR DELETE
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[2]
);
```

### Step 3: Verify Setup

Test the bucket by running this in your Supabase SQL Editor:

```sql
-- Check if bucket exists
SELECT * FROM storage.buckets WHERE name = 'avatars';

-- Check bucket policies
SELECT * FROM storage.policies WHERE bucket_id = 'avatars';
```

## How It Works

### Upload Flow

1. **User selects image** (camera or gallery)
2. **Image is cropped** (square aspect ratio)
3. **Image is compressed** (target: < 300KB, 800x800px)
4. **Image is uploaded** to `avatars/profiles/` folder in Supabase Storage
5. **Public URL is returned** (e.g., `https://xxx.supabase.co/storage/v1/object/public/avatars/profiles/profile_123_456.jpg`)
6. **URL is saved** to `users.profile_pic` in the database

### Display Flow

1. **Fetch user from database** (gets `profile_pic` URL)
2. **Display image** using `CachedNetworkImage` widget
3. **Image loads from Supabase Storage** via public URL

## Compression Settings

Current settings for optimal performance:

- **Target size**: < 300KB (reduced from 500KB)
- **Resolution**: 800x800px (reduced from 1080x1080px)
- **Quality**: 70% (reduced from 80%)
- **Format**: Always JPEG (smaller than PNG)

This ensures:
- ✅ Fast uploads (< 3 seconds on average)
- ✅ Fast loading in app
- ✅ Minimal storage cost
- ✅ Good image quality for profile pictures

## Troubleshooting

### Error: "Bucket does not exist"
**Solution**: Create the `avatars` bucket in Supabase Dashboard

### Error: "Permission denied"
**Solution**: Check bucket policies - ensure authenticated users can upload

### Error: "Image takes too long to upload"
**Solution**: 
- Check internet connection
- Images are auto-compressed to < 300KB
- Try re-uploading

### Error: "Image not displaying"
**Solution**:
- Verify bucket is public
- Check URL in database is correct
- Check Supabase Storage is accessible

### Error: "Old images not being deleted"
**Solution**:
- Check delete policy is set
- Verify user has permission to delete own files

## API Reference

### Upload Image
```dart
final imageUrl = await ImageUploadService.instance.uploadProfileImage(
  imageFile: compressedFile,
  userId: currentUser.id,
);
```

### Delete Image
```dart
await ImageUploadService.instance.deleteProfileImage(oldImageUrl);
```

### Complete Flow
```dart
final imageUrl = await ImageUploadService.instance.pickCropCompressAndUpload(
  source: ImageSource.gallery,
  userId: currentUser.id,
  oldImageUrl: currentUser.profilePic, // Optional: auto-deletes old image
);
```

## Security Notes

- ✅ Images are uploaded to user-specific folders
- ✅ Row Level Security (RLS) prevents unauthorized access
- ✅ Only authenticated users can upload
- ✅ Users can only delete their own images
- ✅ Public read access for displaying images
- ✅ File size limits prevent abuse

## Cost Optimization

Supabase Storage free tier:
- **1 GB** storage
- **2 GB** bandwidth per month

With 300KB per image:
- Can store **~3,000 profile pictures**
- Bandwidth supports **~6,500 image loads** per month

## Monitoring

Check storage usage in Supabase Dashboard:
- **Storage** → **Usage**
- Monitor total size
- Monitor bandwidth usage
- Set up alerts for quota limits

---

**Last Updated**: November 30, 2024  
**Version**: 1.0.0
