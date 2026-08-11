import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final destination = Platform.environment['BOTECOPRO_EVIDENCE_DIR'];
  if (destination == null || destination.isEmpty) {
    throw StateError('BOTECOPRO_EVIDENCE_DIR is required.');
  }
  final runDirectory = Directory(destination)..createSync(recursive: true);
  final screenshotDirectory = Directory('${runDirectory.path}/screenshots')
    ..createSync(recursive: true);

  await integrationDriver(
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, Object?>? args,
    ]) async {
      if (screenshotBytes.length < 8 ||
          screenshotBytes[0] != 0x89 ||
          screenshotBytes[1] != 0x50 ||
          screenshotBytes[2] != 0x4e ||
          screenshotBytes[3] != 0x47) {
        return false;
      }
      File('${screenshotDirectory.path}/$screenshotName.png')
          .writeAsBytesSync(screenshotBytes, flush: true);
      return true;
    },
    responseDataCallback: (data) async {
      final sanitized = Map<String, dynamic>.from(data ?? const {});
      sanitized.remove('screenshots');
      File('${runDirectory.path}/integration-response.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(sanitized)}\n',
        flush: true,
      );
    },
    writeResponseOnFailure: true,
  );
}
