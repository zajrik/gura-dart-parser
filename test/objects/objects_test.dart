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
		}
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
	});
}
