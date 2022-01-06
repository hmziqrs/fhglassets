import 'dart:io';
import 'package:recase/recase.dart';

import 'template.dart';
import 'utils.dart';

Future<void> run() async {
  const codeFilePath = "./lib/static/assets.dart";
  final start = DateTime.now();

  final assetsDir = Directory(normalize("./assets/"));
  final assetsDirPaths = assetsDir.listSync();

  final keys = [];

  for (var file in assetsDirPaths) {
    if (file.path.contains('.DS_Store')) {
      return;
    }
    final dir = Directory(file.path);
    final chunks = file.path.split(normalize("/"));
    final scope = chunks.last;
    keys.add("\n\t// $scope paths");
    dir.listSync().forEach((element) {
      if (!element.path.contains(RegExp('(?:jpg|gif|png|json)'))) {
        return;
      }
      final filePath = element.path.replaceFirst("." + normalize("/"), "");
      var fileName = filePath.split(normalize("/")).last.split(".").first;
      final varName =
          scope + " " + fileName.replaceAll(RegExp(r'[^\w\s]+'), " ");
      final key =
          "\tstatic const ${varName.camelCase} = \"${filePath.replaceAll(normalize("/"), "/")}\";";
      keys.add(key);
    });
  }

  final classData = staticClassTemplate(keys.join("\n"));
  final classFile = File(normalize(codeFilePath));
  if (!classFile.existsSync()) {
    classFile.createSync();
    return;
  }
  await classFile.writeAsString(classData);

  final end = DateTime.now();
  print("Took " + end.difference(start).inMilliseconds.toString() + "ms");
}
