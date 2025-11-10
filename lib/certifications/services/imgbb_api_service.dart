import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImgBBApiService {
  
  static const String _apiKey = String.fromEnvironment('IMGBB_API_KEY', defaultValue: '5e8520a4a581822f7aef6ae42d2e407b');

  Future<Map<String, dynamic>> uploadImageBytes(Uint8List bytes, {String fileName = 'image.jpg'}) async {
    if (_apiKey.isEmpty) {
      throw Exception('IMGBB_API_KEY not configured');
    }
    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$_apiKey');
    final req = http.MultipartRequest('POST', url);
    
    req.fields['key'] = _apiKey;
    req.files.add(http.MultipartFile.fromBytes('image', bytes, filename: fileName));
    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final inner = data['data'] as Map<String, dynamic>?;
      if (inner == null) throw Exception('Invalid response from ImgBB');
      
      return {
        'id': inner['id'],
        'url': inner['url'],
        'display_url': inner['display_url'] ?? inner['url'],
      };
    } else {
      
      final base64Image = base64Encode(bytes);
      final formBody = {
        'key': _apiKey,
        'image': base64Image,
      };
      final res2 = await http.post(url, body: formBody);
      if (res2.statusCode >= 200 && res2.statusCode < 300) {
        final data = jsonDecode(res2.body) as Map<String, dynamic>;
        final inner = data['data'] as Map<String, dynamic>?;
        if (inner == null) throw Exception('Invalid response from ImgBB');
        return {
          'id': inner['id'],
          'url': inner['url'],
          'display_url': inner['display_url'] ?? inner['url'],
        };
      }
      throw Exception('ImgBB upload failed: ${res.statusCode} - $body');
    }
  }
}