# Gura Dart parser

This repository contains the implementation of a [Gura configuration format](https://gura.netlify.app/)
parser for Dart, written in pure Dart. (Compliant with spec version 1.0.0).

## Installation
```
dart pub add gura
```

## Usage
Import `package:gura/gura.dart` and use the [parse()], [parseFile()], or [parseFileSync()]
functions to convert your Gura input into a `Map<String, dynamic>` for use in your code.

### Examples
```dart
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

void main()
{
    // parse: transforms a Gura string into a Map of Gura key/value pairs
    final Map<String, dynamic> parsedGura = parse(guraString);
    print(parsedGura);

    // Access a specific field
    print('Title -> ${parsedGura['title']}');

    // Iterate over structures (parsedGura['hosts'] is List<dynamic> but we know
    // it contains strings so we can safely cast to String when iterating over it)
    for (final String host in parsedGura['hosts'])
        print('Host -> $host');

    // dump: stringifies Map<String, dynamic> as a Gura-compatible string
    print(dump(parsedGura));
}
```

```dart
import 'dart:io';
import 'package:gura/gura.dart';

Future<void> main() async
{
	final File guraFile = File('foo_bar.ura');
	final Map<String, dynamic> parsedGura = await parseFile(guraFile);
	...
}
```

```dart
import 'dart:io';
import 'package:gura/gura.dart';

void main()
{
	final File guraFile = File('foo_bar.ura');
	final Map<String, dynamic> parsedGura = parseFileSync(guraFile);
	...
}
```

In the event that any of the library function names (`parse`, `parseFile`, etc.)
conflict with functions from another library, alias gura and use qualified function
calls via the alias:

```dart
import 'dart:io';
import 'package:gura/gura.dart' as gura;

void main()
{
	final File guraFile = File('foo_bar.ura');
	final Map<String, dynamic> parsedGura = await gura.parseFile(guraFile);
	...
}
```

## Contributing
1. Fork this project
2. Create new branch for your feature
3. Commit and push your changes
4. Submit a pull request

Sadly, Dart's selection of tools for maintaining a consistent code style do not
allow for much customization in a way that supports my personal code style, and
I don't like the opinionated style of `dartfmt`, so if you choose to contribute,
please do your best to maintain code style consistent with the rest of the repo
in your contributions. I'll review PRs to ensure this.

### Tests
To run all tests, run `dart test` in the project root.

## Credits
Credit for the vast majority of code and logic in this project goes to the original
authors of the [TS/JS Gura parser](https://github.com/gura-conf/gura-js-parser).

This parser started as a 1:1 port of the TypeScript/JavaScript parser implementation,
but I've since done a lot of cleanup, restructuring, some logic refactoring, and
I've redocumented everything, all to help me better solidify my understanding of the
inner-workings of the original implementation.

There are also a lot of TypeScript/JavaScript mechanics that simply didn't translate
well to Dart so keeping the implementation port 1:1 was never going to work out,
though I didn't know quite how frequently I would encounter that problem until I
started the project.

## License
This repository is distributed under the terms of the MIT license.
