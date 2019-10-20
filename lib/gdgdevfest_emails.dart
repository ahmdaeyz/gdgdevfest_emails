
import 'package:dio/dio.dart';
import 'package:qr/qr.dart';
import 'package:image/image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:html/parser.dart' as html;

/// Generates qr code coressponding to the given text and outputs a list of bytes of a 200*200 png image
Future<List<int>> generateQrCodeImage(String text) {
  final qrCode = QrCode(5, QrErrorCorrectLevel.Q);
  qrCode.addData(text);
  qrCode.make();
  Image image = Image(qrCode.moduleCount, qrCode.moduleCount);
  fill(image, getColor(255, 255, 255));
  for (int x = 0; x < qrCode.moduleCount; x++) {
    for (int y = 0; y < qrCode.moduleCount; y++) {
      if (qrCode.isDark(y, x)) {
        drawPixel(image, x, y, getColor(0, 0, 0));
      }
    }
  }
  var imageResized = copyResize(image, width: 200, height: 200);

  return Future.value(encodePng(imageResized));
}

/// Uploads the given List of Bytes (File) to anonfile.com and returns the Full url(not direct)
Future<String> uploadQrCodeImage(List<int> imageBytes,
    [String fileName]) async {
  var formData = FormData.fromMap({
    "file":
        dio.MultipartFile.fromBytes(imageBytes, filename: "${fileName}.png"),
  });
  var response =
      await dio.Dio().post("https://api.anonfile.com/upload", data: formData);

  return Future.value(response.data["data"]["file"]["url"]["full"].toString());
}

/// Scraps the given url for a direct download url of the image
Future<String> getDirectImageUrl(String URL) async {
  final response = await dio.Dio().get(URL);
  final document = html.parse(response.data);
  final attributes = document.querySelector("#download-url").attributes;
  return Future.value(attributes["href"]);
}

String composeMail(
    String template, String username, String accessCode, String qrCodeUrl) {
  final withUsername = template.replaceAll("{{*username*}}", username);
  final withAccessCode =
      withUsername.replaceAll("{{*access_code*}}", accessCode);
  final withQrCode = withAccessCode.replaceAll("{{*qrcode_url*}}", qrCodeUrl);

  return withQrCode;
}
