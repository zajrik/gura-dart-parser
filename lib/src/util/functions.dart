part of gura;

/// Try/catch the given function and ignore any errors
void _tryIgnore(dynamic Function() fn)
{
	try { fn(); } catch (e) {}
}

/// Attempt to return the result of the given function, returning null when
/// encountering a [ParseError]. Any other kind of error will not be caught
T? _tryReturn<T>(T Function() fn)
{
	try { return fn(); }
	on ParseError { return null; }
}

/// Matches equatable keys to function return values.
///
/// Given values must be comparable to the matcher keys via `==`.
///
/// Throws [RangeError] if a matcher cannot be found for the given value;
T _match<K, T>(K value, Map<K, T Function()> matchers)
{
	for (final K key in matchers.keys)
		if (key == value)
			return matchers[value]!();

	throw RangeError('Matched value did not have an associated match function');
}

/// Parses the given text following the Gura configuration format.
///
/// Can be given an optional `Map<String, String>` [env] named argument containing
/// key/value pairs to inject into the parser's environment variable snapshot
/// for use within the text to be parsed.
///
/// Returns a `Map<String, dynamic>` containing all key/value pairs from the parsed
/// Gura input.
///
/// Example:
/// ```dart
/// String guraFileContents = File("foo_bar.ura").readAsStringSync();
/// Map<String, dynamic> gura = parse(guraFileContents, env: { 'foo': 'bar' });
/// ```
///
/// **Note**: If a key in the given [env] Map already exists in the parser's env
/// snapshot, it will be overwritten with the given Map's key/value
Map<String, dynamic> parse(String text, {Map<String, String>? env})
{
	final _GuraParser parser = _GuraParser();

	// Add environment variables to the parser's env snapshot
	if (env != null)
		parser.env.addAll(env);

	return parser.parse(text);
}

/// Parses the contents of the given File following the Gura configuration format,
/// asynchronously.
///
/// Can be given an optional `Map<String, String>` [env] named argument containing
/// key/value pairs to inject into the parser's environment variable snapshot
/// for use within the file to be parsed.
///
/// Returns a `Future<Map<String, dynamic>>` containing all key/value pairs from
/// the parsed Gura input.
///
/// Example:
/// ```dart
/// File guraFile = File("foo_bar.ura");
/// Map<String, dynamic> gura = await parseFile(guraFile, env: { 'foo': 'bar' });
/// ```
///
/// **Note**: If a key in the given [env] Map already exists in the parser's env
/// snapshot, it will be overwritten with the given Map's key/value
Future<Map<String, dynamic>> parseFile(File guraFile, {Map<String, String>? env}) async
{
	final String fileContents = await guraFile.readAsString();
	return parse(fileContents, env: env);
}

/// Parses the contents of the given file following the Gura configuration format,
/// synchronously.
///
/// Can be given an optional `Map<String, String>` [env] named argument containing
/// key/value pairs to inject into the parser's environment variable snapshot
/// for use within the file to be parsed.
///
/// Returns a `Map<String, dynamic>` containing all key/value pairs from the parsed
/// Gura input.
///
/// Example:
/// ```dart
/// File guraFile = File("foo_bar.ura");
/// Map<String, dynamic> gura = parseFileSync(guraFile, env: { 'foo': 'bar' });
/// ```
///
/// **Note**: If a key in the given [env] Map already exists in the parser's env
/// snapshot, it will be overwritten with the given Map's key/value
Map<String, dynamic> parseFileSync(File guraFile, {Map<String, String>? env}) =>
	parse(guraFile.readAsStringSync(), env: env);

/// Converts the given [value] to its Gura-compatible string representation.
///
/// Throws [TypeError] if given anything other than these supported types:
/// - `null`
/// - `num`, `int`, or `double`
/// - `bool`
/// - `String`
/// - `List<dynamic>`
/// - `Map<String, dynamic>`
///
/// Returns the stringified [value]
String _stringify(dynamic value)
{
	final String valueType = value.runtimeType.toString();

	if (value == null)
		return 'null';

	if (valueType == 'String')
		return '"$value"';

	if (valueType == 'bool')
		return value.toString();

	if (valueType == 'num' || valueType == 'int' || valueType == 'double')
	{
		// Handle infinity
		if (value == double.infinity)
			return 'inf';

		// Handle negative infinity
		else if (value == double.negativeInfinity)
			return '-inf';

		// Handle NaN
		else if (value == double.nan)
			return 'nan';

		// Otherwise return normal number
		return value.toString();
	}

	// Generic types are a bit more complex so defer to checking the actual
	// type, as any given list or map type will inherit from List/Map if
	// they are not those types directly (i.e. _InternalLinkedHashMap, etc.)

	if (value is Map)
	{
		String result = '';

		for (final MapEntry<dynamic, dynamic> entry in value.entries)
		{
			result += '${entry.key}:';

			// If the entry value is a Map, split the stringified value by
			// newline and indent each line before adding it to the result
			if (entry.value is Map)
			{
				result += '\n';

				final String stringifiedValue = _stringify(entry.value).trimRight();

				for (final String line in stringifiedValue.split('\n'))
					result += ' ' * 4 + line + '\n';
			}

			// Otherwise add the stringified value
			else
			{
				result += ' ${_stringify(entry.value)}\n';
			}
		}

		return result;
	}

	if (value is List)
	{
		final bool shouldMultiline = value.any((element) => element is Map || element is List);

		if (!shouldMultiline)
			return '[${value.map((e) => _stringify(e)).join(', ')}]';

		String result = '[';

		for (final ListEntry<dynamic> entry in value.entries)
		{
			final String stringifiedValue = _stringify(entry.value).trimRight();

			result += '\n';

			// If the stringified value contains multiple lines, indent all
			// of them and add them all to the result
			if (stringifiedValue.contains('\n'))
				result += stringifiedValue
					.split('\n')
					.map((element) => ' ' * 4 + element)
					.join('\n');

			// Otherwise indent the value and add to result
			else
				result += ' ' * 4 + stringifiedValue;

			// Add a comma if this entry is not the final entry in the list
			if (entry.index < value.length - 1)
				result += ',';
		}

		result += '\n]';

		return result;
	}

	throw TypeError();
}

/// Stringifies the given `Map<String, dynamic>` [value] into a Gura-compatible
/// string, which can be written to file if desired.
///
/// Returns the strigified input
String dump(Map<String, dynamic> value) => _stringify(value);
