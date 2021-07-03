import 'dart:io';

import 'package:path/path.dart';
import 'package:gura/gura.dart';

/// Gets the content of a specific Gura test file as a parsed Map
Map<String, dynamic> getParsedFileContent(String testFolderName, String fileName, {Map<String, String>? env})
{
	final String fullPath = join('test', testFolderName, 'files', fileName);
	return parse(File(fullPath).readAsStringSync(), env: env);
}
