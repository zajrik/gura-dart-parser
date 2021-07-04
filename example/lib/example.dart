import 'package:gura/gura.dart';

final String guraString = '''
# This is a Gura document.
title: "Gura Example"

an_object:
    username: "Stephen"
    pass: "Hawking"

# Line breaks are ok when inside arrays
hosts: [
    "alpha",
    "omega"
]
''';

Future<void> main() async
{
	// parse: transforms a Gura string into a Map of Gura key/value pairs
	final Map<String, dynamic> parsedGura = parse(guraString);
	print(parsedGura);
	// Prints: {title: Gura Example, an_object: {username: Stephen, pass: Hawking}, hosts: [alpha, omega]}

	// Access a specific field
	print('Title -> ${parsedGura['title']}');
	// Prints: Gura Example

	// Iterate over structures (parsedGura['hosts'] is List<dynamic> but we know
	// it contains strings so we can safely cast to String when iterating over it)
	for (final String host in parsedGura['hosts'])
		print('Host -> $host');

	// dump: stringifies Map<String, dynamic> as a Gura-compatible string
	print(dump(parsedGura));
}
