import 'dart:io';

import 'package:gura/gura.dart';
import 'package:test/test.dart';

import '../util/util_extensions.dart';
import '../util/util_functions.dart';

void main()
{
	final String parentFolder = 'importing';

	final Map<String, dynamic> expected = {
		'from_file_one': 1,
		'from_file_two': {
			'name': 'Aníbal',
			'surname': 'Troilo',
			'year_of_birth': 1914
		},
		'from_original_1': [1, 2, 5],
		'from_original_2': false,
		'from_file_three': true
	};

	group('Importing', ()
	{
		test('successfully imports other files', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'normal.ura');
			expect(parsedData.deepEquals(expected), equals(true));
		});

		test('successfully imports with a variable in path value', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'with_variable.ura');
			expect(parsedData.deepEquals(expected), equals(true));
		});

		test('successfully imports files with absolute paths', () async
		{
			final String tempFileName = 'gura-temp${DateTime.now().microsecondsSinceEpoch}.ura';
			final File tempFile = File(Directory.systemTemp.path.joinWithPath(tempFileName));

			await tempFile.create();
			await tempFile.writeAsString('from_temp: true');

			final Map<String, dynamic> parsedData = parse('import "${tempFile.path}"\nfrom_original: false');
			final Map<String, dynamic> tempExpected = { 'from_temp': true, 'from_original': false };

			await tempFile.delete();

			expect(parsedData.deepEquals(tempExpected), equals(true));
		});

		test('fails on invalid imports (FileNotFoundError)', ()
		{
			expect(() => parse('import "invalid_file.ura"'), throwsA(TypeMatcher<FileNotFoundError>()));
		});

		test('fails when importing introduces duplicate keys (DuplicatedKeyError)', ()
		{
			expect(
				() => getParsedFileContent(parentFolder, 'duplicated_key.ura'),
				throwsA(TypeMatcher<DuplicatedKeyError>())
			);
		});

		test('fails when importing introduces duplicate variables (DuplicatedVariableError)', ()
		{
			expect(
				() => getParsedFileContent(parentFolder, 'duplicated_variable.ura'),
				throwsA(TypeMatcher<DuplicatedVariableError>())
			);
		});

		test('fails on duplicate imports (DuplicatedImportError)', ()
		{
			expect(
				() => getParsedFileContent(parentFolder, 'duplicated_imports_simple.ura'),
				throwsA(TypeMatcher<DuplicatedImportError>())
			);
		});

		test('fails on import syntax errors', ()
		{
			expect(() => parse('  import "another_file.ura"'), throwsA(TypeMatcher<ParseError>()));
			expect(() => parse('import   "another_file.ura"'), throwsA(TypeMatcher<ParseError>()));
		});
	});
}
