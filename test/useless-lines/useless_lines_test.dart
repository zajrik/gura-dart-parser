import 'package:test/test.dart';

import '../util/util_functions.dart';

void main()
{
	final String parentFolder = 'useless-lines';

	final Map<String, dynamic> expected = {
		'a_string': 'test string',
		'int1': 99,
		'int2': 42,
		'int3': 0,
		'int4': -17,
		'int5': 1000,
		'int6': 5349221,
		'int7': 5349221
	};

	final Map<String, dynamic> expectedObject = {
		'testing': {
			'test_2': 2,
			'test': {
				'name': 'JWARE',
				'surname': 'Solutions'
			}
		}
	};

	final Map<String, dynamic> expectedObjectComplex = {
		'testing': {
			'test': {
				'name': 'JWARE',
				'surname': 'Solutions',
				'skills': {
					'good_testing': false,
					'good_programming': false,
					'good_english': false
				}
			},
			'test_2': 2,
			'test_3': {
				'key_1': true,
				'key_2': false,
				'key_3': 55.99
			}
		}
	};

	group('Uesless lines', ()
	{
		test('are absent and file parses successfully', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'without.ura');
			expect(parsedData, equals(expected));
		});

		test('on top of the file are ignored and file parses successfully', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'on_top.ura');
			expect(parsedData, equals(expected));
		});

		test('on bottom of the file are ignored and file parses successfully', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'on_bottom.ura');
			expect(parsedData, equals(expected));
		});

		test('on top and bottom of file are ignored and file parses successfully', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'on_both.ura');
			expect(parsedData, equals(expected));
		});

		test('in the middle of the file are ignored and file parses successfully', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'in_the_middle.ura');
			expect(parsedData, equals(expected));
		});

		test('are absent and object parses successfully', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'without_object.ura');
			expect(parsedData, equals(expectedObject));
		});

		test('in the middle of an object are ignored and object parses successfully', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'in_the_middle_object.ura');
			expect(parsedData, equals(expectedObject));
		});

		test('in the middle of a complex object are ignored and complex object parses successfully', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(
				parentFolder,
				'in_the_middle_object_complex.ura'
			);

			expect(parsedData, equals(expectedObjectComplex));
		});
	});
}
