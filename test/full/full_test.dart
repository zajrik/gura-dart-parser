import 'package:test/test.dart';

import '../util/util_functions.dart';

void main()
{
	final String parentFolder = 'full';

	final Map<String, dynamic> expected = {
		'a_string': 'test string',
		'int1': 99,
		'int2': 42,
		'int3': 0,
		'int4': -17,
		'int5': 1000,
		'int6': 5349221,
		'int7': 5349221,
		'hex1': 3735928559,
		'hex2': 3735928559,
		'hex3': 3735928559,
		'oct1': 342391,
		'oct2': 493,
		'bin1': 214,
		'flt1': 1.0,
		'flt2': 3.1415,
		'flt3': -0.01,
		'flt4': 5e+22,
		'flt5': 1e06,
		'flt6': -2E-2,
		'flt7': 6.626e-34,
		'flt8': 224617.445991228,
		'sf1': double.infinity,
		'sf2': double.infinity,
		'sf3': double.negativeInfinity,
		'null': null,
		'bool1': true,
		'bool2': false,
		'1234': '1234',
		'services': {
			'nginx': {
				'host': '127.0.0.1',
				'port': 80
			},
			'apache': {
				'virtual_host': '10.10.10.4',
				'port': 81
			}
		},
		'integers': [1, 2, 3],
		'colors': ['red', 'yellow', 'green'],
		'nested_arrays_of_ints': [[1, 2], [3, 4, 5]],
		'nested_mixed_array': [[1, 2], ['a', 'b', 'c']],
		'numbers': [0.1, 0.2, 0.5, 1, 2, 5],
		'tango_singers': [
			{
				'user1': {
					'name': 'Carlos',
					'surname': 'Gardel',
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
		'integers2': [
			1, 2, 3
		],
		'integers3': [
			1,
			2
		],
		'my_server': {
			'host': '127.0.0.1',
			'port': 8080,
			'native_auth': true
		},
		'gura_is_cool': 'Gura is cool',
        'empty_object': {}
	};

	group('Full', ()
	{
		test('set successfully parses', ()
		{
			Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'full.ura');
			expect(parsedData, equals(expected));
		});

		test('test successfully parses NaN values', ()
		{
			Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'nan.ura');
			for (final MapEntry<String, dynamic> entry in parsedData.entries)
				expect((entry.value as double).isNaN, equals(true));
		});
	});
}
