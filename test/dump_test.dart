import 'package:gura/gura.dart';
import 'package:test/test.dart';

import 'util/util_extensions.dart';

void main()
{
	final Map<String, dynamic> expectedObj = {
		'foo': [
			{
				'bar': {
					'baz': [
						{ 'far': [{ 'faz': 'foo' }] },
						{ 'far': 'faz' },
						{ 'far': 'faz' },
					]
				}
			},
			{
				'bar': {
					'baz': 'boo',
					'far': 'faz'
				}
			},
			{
				'bar': [
					[{ 'baz': 'boo', 'far': 'faz' }],
					[{ 'baz': 'boo', 'far': 'faz' }],
					[{ 'baz': 'boo', 'far': 'faz' }]
				]
			},
		]
	};

	final String expectedString = '''
foo: [
    bar:
        baz: [
            far: [
                faz: "foo"
            ],
            far: "faz",
            far: "faz"
        ],
    bar:
        baz: "boo"
        far: "faz",
    bar: [[
        baz: "boo"
        far: "faz"
    ], [
        baz: "boo"
        far: "faz"
    ], [
        baz: "boo"
        far: "faz"
    ]]
]
''';

	group('Dump', ()
	{
		test('produces the correct output', ()
		{
			expect(dump(expectedObj).trim(), equals(expectedString.trim()));
		});

		test('output produces the original input when re-parsed', ()
		{
			final String dumpedInput = dump(expectedObj);
			expect(parse(dumpedInput).deepEquals(expectedObj), equals(true));
		});
	});
}
