import 'package:gura/gura.dart';
import 'package:test/test.dart';

import '../util/util_functions.dart';

void main()
{
	final String parentFolder = 'strings';

	// Basic
	final String escapedValue = '\$name is cool';
	final Map<String, dynamic> expectedBasic = {
		'str': 'I\'m a string. "You can quote me". Na\bme\tJos\u00E9\nLocation\tSF.',
		'str_2': 'I\'m a string. "You can quote me". Na\bme\tJosé\nLocation\tSF.',
		'with_var': 'Gura is cool',
		'escaped_var': escapedValue,
		'with_env_var': 'Gura is very cool'
	};

	// Multiline basic
	final String multilineValue = 'Roses are red\nViolets are blue';
	final String multilineValueWithoutNewline = 'The quick brown fox jumps over the lazy dog.';
	final Map<String, dynamic> expectedMultilineBasic = {
		'str': multilineValue,
		'str_2': multilineValue,
		'str_3': multilineValue,
		'with_var': multilineValue,
		'with_env_var': multilineValue,
		'str_with_backslash': multilineValueWithoutNewline,
		'str_with_backslash_2': multilineValueWithoutNewline,
		'str_4': 'Here are two quotation marks: "". Simple enough.',
		'str_5': 'Here are three quotation marks: """.',
		'str_6': 'Here are fifteen quotation marks: """"""""""""""".',
		'escaped_var': escapedValue
	};

	// Literal
	final Map<String, dynamic> expectedLiteral = {
		'quoted': 'John "Dog lover" Wick',
		'regex': '<\\i\\c*\\s*>',
		'winpath': 'C:\\Users\\nodejs\\templates',
		'winpath2': '\\\\ServerX\\admin\$\\system32\\',
		'with_var': '\$no_parsed variable!',
		'escaped_var': escapedValue
	};

	// Multiline literal
	final Map<String, dynamic> expectedMultilineLiteral = {
		'lines': 'The first newline is\ntrimmed in raw strings.\n   All other whitespace\n   is preserved.\n',
		'regex2': "I [dw]on't need \\d{2} apples",
		'with_var': '\$no_parsed variable!',
		'escaped_var': escapedValue
	};

	group('Strings', ()
	{
		test('are successfully parsed (basic strings)', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(
				parentFolder,
				'basic.ura',
				env: { 'env_var_value': 'very' }
			);

			expect(parsedData, equals(expectedBasic));
		});

		test('are successfully parsed (multi-line strings)', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(
				parentFolder,
				'multiline_basic.ura',
				env: { 'env_var_value': 'Roses' }
			);

			expect(parsedData, equals(expectedMultilineBasic));
		});

		test('are successfully parsed (literal strings)', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'literal.ura');
			expect(parsedData, equals(expectedLiteral));
		});

		test('are successfully parsed (multi-line literal strings)', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'multiline_literal.ura');
			expect(parsedData, equals(expectedMultilineLiteral));
		});

		test('error when interpolating undefined variables', ()
		{
			expect(
				() => parse('test: "\$false_var_${DateTime.now().microsecondsSinceEpoch}"'),
				throwsA(TypeMatcher<VariableNotDefinedError>())
			);
		});
	});
}
