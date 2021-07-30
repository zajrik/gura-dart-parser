import 'package:gura/gura.dart';
import 'package:test/test.dart';

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
			{
				'bar': [
					[1, 2, 3],
					[4, 5, 6],
					[7, 8, 9]
				]
			},
			[[], [], []],
			[['foo'], ['bar'], ['baz']],
			[{}, {}, {}],
			[{}, {}, {}, { 'foo': 'bar' }]
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
    bar: [
        [
            baz: "boo"
            far: "faz"
        ],
        [
            baz: "boo"
            far: "faz"
        ],
        [
            baz: "boo"
            far: "faz"
        ]
    ],
    bar: [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    ],
    [[], [], []],
    [
        ["foo"],
        ["bar"],
        ["baz"]
    ],
    [empty, empty, empty],
    [
        empty,
        empty,
        empty,
        foo: "bar"
    ]
]
''';

	final String complexString = '''
foo: """
	foo\\nbar\\tbaz
	foo\\bar\\baz
	foo\\\$bar\fbaz
"""
'''.trim();

	group('Dump', ()
	{
		test('produces the correct output', ()
		{
			expect(dump(expectedObj).trim(), equals(expectedString.trim()));
		});

		test('output produces the original input when re-parsed', ()
		{
			final String dumpedInput = dump(expectedObj);
			expect(parse(dumpedInput), equals(expectedObj));
		});

		test('output containing complex strings can be re-parsed/dumped many times with the same output', ()
		{
			String previous = dump(parse(complexString)).trim();

			for (int i = 0; i < 10; i++)
			{
				final String result = dump(parse(previous)).trim();
				expect(result, equals(previous));
				previous = result;
			}
		});
	});
}
