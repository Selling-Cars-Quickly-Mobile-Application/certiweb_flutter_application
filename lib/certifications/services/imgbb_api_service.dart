import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImgBBApiService {
  static const String _apiKey = String.fromEnvironment('5e8520a4a581822f7aef6ae42d2e407b', defaultValue: '');

  Future<String> uploadImageBytes(Uint8List bytes, {String fileName = 'image.jpg'}) async {
    if (_apiKey.isEmpty) {
      throw Exception('IMGBB_API_KEY not configured');
    }
    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$_apiKey');
    final req = http.MultipartRequest('POST', url);
    req.files.add(http.MultipartFile.fromBytes('image', bytes, filename: fileName));
    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final imageUrl = data['data']?['url'] as String?;
      if (imageUrl == null) throw Exception('Invalid response from ImgBB');
      return imageUrl;
    } else {
      throw Exception('ImgBB upload failed: ${res.statusCode}');
    }
  }
}