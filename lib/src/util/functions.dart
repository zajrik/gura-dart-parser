part of gura;

/// Try/catch the given function and ignore any errors
void _tryIgnore(dynamic? Function() fn)
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

/// Stringifies the given `Map<String, dynamic>` [data] into a Gura-compatible
/// string, which can be written to file if desired.
///
/// Returns the strigified input
String dump(Map<String, dynamic> data) => _GuraParser.dump(data);
