import 'package:gura/gura.dart';
import 'package:test/test.dart';

import '../util/util_functions.dart';

void main()
{
	final String parentFolder = 'objects';

	final Map<String, dynamic> expected = {
		'user1': {
			'name': 'Carlos',
			'surname': 'Gardel',
			'testing_nested': {
				'nested_1': 1,
				'nested_2': 2
			},
			'year_of_birth': 1890
		},
		'user2': {
			'name': 'Aníbal',
			'surname': 'Troilo',
			'year_of_birth': 1914
		},
		'empty_object': {}
	};

	group('Objects', ()
	{
		test('are successfully parsed from a variety of objects', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'normal.ura');
			expect(parsedData, equals(expected));
		});

		test('are successfully parsed with comments', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'with_comments.ura');
			expect(parsedData, equals(expected));
		});

		test('are successfully parsed with key literals', ()
		{
			expect(
				parse('`foo bar`: "baz"\n`boo far`: "faz"'),
				equals({ 'foo bar': 'baz', 'boo far': 'faz' })
			);
		});

		test('parsing fails on invalid objects', ()
		{
			expect(
				() => getParsedFileContent(parentFolder, 'invalid.ura'),
				throwsA(TypeMatcher<ParseError>())
			);

			expect(
				() => getParsedFileContent(parentFolder, 'invalid_2.ura'),
				throwsA(TypeMatcher<InvalidIndentationError>())
			);
		});

		test('parsing fails on literal keys with line breaks/form feeds', ()
		{
			expect(
				() => parse('`foo\nbar`: "baz"'),
				throwsA(TypeMatcher<InvalidKeyError>())
			);

			expect(
				() => parse('`foo\r\nbar`: "baz"'),
				throwsA(TypeMatcher<InvalidKeyError>())
			);

			expect(
				() => parse('`foo\rbar`: "baz"'),
				throwsA(TypeMatcher<InvalidKeyError>())
			);

			expect(
				() => parse('`foo\fbar`: "baz"'),
				throwsA(TypeMatcher<InvalidKeyError>())
			);
		});
	});
}
