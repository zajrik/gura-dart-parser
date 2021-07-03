import 'package:gura/gura.dart';
import 'package:test/test.dart';

import '../util/util_functions.dart';

void main()
{
	final String parentFolder = 'indentation';

	group('Indentation', ()
	{
		test('error is thrown when tabs are used', ()
		{
			expect(
				() => getParsedFileContent(parentFolder, 'with_tabs.ura'),
				throwsA(TypeMatcher<InvalidIndentationError>())
			);
		});

		test('error is thrown when whitespace and tabs are mixed', ()
		{
			expect(
				() => getParsedFileContent(parentFolder, 'different_chars.ura'),
				throwsA(TypeMatcher<InvalidIndentationError>())
			);
		});

		test('error is thrown when indentation is not divisible by 4', ()
		{
			expect(
				() => getParsedFileContent(parentFolder, 'not_divisible_by_4.ura'),
				throwsA(TypeMatcher<InvalidIndentationError>())
			);
		});

		test('error is thrown when indentation is too deep for object entries', ()
		{
			expect(
				() => getParsedFileContent(parentFolder, 'more_than_4_difference.ura'),
				throwsA(TypeMatcher<InvalidIndentationError>())
			);
		});
	});
}
