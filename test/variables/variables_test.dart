import 'package:gura/gura.dart';
import 'package:test/test.dart';

import '../util/util_extensions.dart';
import '../util/util_functions.dart';

void main()
{
	final String parentFolder = 'variables';

	final Map<String, dynamic> expected = {
		'plain': 5,
		'in_array_middle': [1, 5, 3],
		'in_array_last': [1, 2, 5],
		'in_object': {
			'name': 'Aníbal',
			'surname': 'Troilo',
			'year_of_birth': 1914
		}
	};

	group('Variables', ()
	{
		test('are successfully defined and utilized', ()
		{
			final Map<String, dynamic> parsedData = getParsedFileContent(parentFolder, 'normal.ura');
			expect(parsedData.deepEquals(expected), equals(true));
		});

		test('are successfully loaded from external vars', ()
		{
			final String envVarName = 'env_var_${DateTime.now().microsecondsSinceEpoch}';
			final String envValue = 'using_env_var';

			final Map<String, dynamic> parsedData = parse(
				'test: \$$envVarName',
				env: { envVarName: envValue }
			);

			expect(parsedData.deepEquals({ 'test': envValue }), equals(true));
		});

		test('fail to parse with invalid values (bool, null, complex)', ()
		{
			expect(() => parse('\$invalid: true'), throwsA(TypeMatcher<ParseError>()));
			expect(() => parse('\$invalid: false'), throwsA(TypeMatcher<ParseError>()));
			expect(() => parse('\$invalid: null'), throwsA(TypeMatcher<ParseError>()));
			expect(() => parse('\$invalid: [1, 2, 3]'), throwsA(TypeMatcher<ParseError>()));
			expect(
				() => getParsedFileContent(parentFolder, 'invalid_variable_with_object.ura'),
				throwsA(TypeMatcher<ParseError>())
			);
		});
	});
}
