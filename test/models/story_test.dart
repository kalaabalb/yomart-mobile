import 'package:e_commerce_flutter/models/story.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a signed HTTPS Cloudinary video download URL', () {
    expect(
      isSafeStoryPlaybackUrl(
        'https://api.cloudinary.com/v1_1/staging/video/download?signature=token',
      ),
      isTrue,
    );
  });

  test('rejects unsafe story playback URL forms', () {
    for (final url in [
      'http://api.cloudinary.com/v1_1/staging/video/download?signature=token',
      'https://user@api.cloudinary.com/v1_1/staging/video/download?signature=token',
      'https://api.cloudinary.com.evil.test/v1_1/staging/video/download?signature=token',
      'https://evil.test/v1_1/staging/video/download?signature=token',
      'https://api.cloudinary.com/v1_1/staging/image/download?signature=token',
      'https://api.cloudinary.com/v1_1/staging/video/download',
      'https://api.cloudinary.com:444/v1_1/staging/video/download?signature=token',
    ]) {
      expect(isSafeStoryPlaybackUrl(url), isFalse, reason: url);
    }
  });
}
