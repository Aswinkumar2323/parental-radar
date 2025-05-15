// Only included on Web
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

void downloadApkInWeb(Uint8List bytes) {
  final blob = html.Blob([bytes], 'application/vnd.android.package-archive');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor =
      html.AnchorElement(href: url)
        ..setAttribute("download", "target_app.apk")
        ..click();

  html.Url.revokeObjectUrl(url);
}
