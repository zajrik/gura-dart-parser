import 'package:test/test.dart';

import '../util/util_functions.dart';

void main()
{
	final String parentFolder = 'arrays';

	final Map<String, dynamic> expected = {
		'colors': ['red', 'yellow', 'green'],
		'integers': [1, 2, 3],
		'integers_with_new_line': [1, 2, 3],
		'nested_arrays_of_ints': [[1, 2], [3, 4, 5]],
		'nested_mixed_array': [[1, 2], ['a', 'b', 'c']],
		'numbers': [0.1, 0.2, 0.5, 1, 2, 5],
		'tango_singers': [
			{
				'user1': {
					'name': 'Carlos',
					'surname': 'Gardel',
					'testing_nested': {
						'nested_1': 1,
						'nested_2': 2
					},
					'year_of_birth': 1890
				}
			},
			{
				'user2': {
					'name': 'Aníbal',
					'surname': 'Troilo',
					'year_of_birth': 1914
				}
			}
		],
		'mixed_with_object': [
			1,
			{ 'test': { 'genaro': 'Camele' } },
			2,
			[4, 5, 6],
			3
		],
		'separator': [
			{ 'a': 1, 'b': 2 },
			{ 'a': 1 },
			{ 'b': 2 }
		]
	};

	final Map<String, dynamic> expectedInsideObject = {
		'model': {
			'columns': [
				['var1', 'str'],
				['var2', 'str']
			]
		}
	};

	group('Arrays', ()
	{
		test('successfully parse with normal values', ()
		{
			expect(getParsedFileContent(parentFolder, 'normal.ura'), equals(expected));
		});

		test('successfully parse with comments interspersed', ()
		{
			expect(getParsedFileContent(parentFolder, 'with_comments.ura'), equals(expected));
		});

		test('successfully parse inside of objects', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(
				parentFolder,
				'array_in_object.ura'
			);

			expect(parsedData, equals(expectedInsideObject));
		});

		test('successfully parse with trailing commas inside of objects', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(
				parentFolder,
				'array_in_object_trailing_comma.ura'
			);

			expect(parsedData, equals(expectedInsideObject));
		});
	});
}
