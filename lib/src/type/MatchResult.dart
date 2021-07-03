part of gura;

/// Represents the result of most parser match operations. Holds a [kind] for
/// identifying the kind of match operation the result is for, and for some
/// kinds, a [value] which is the value returned from the match operation
class _MatchResult<T>
{
	final _MatchResultKind kind;
	final T? value;

	/// Constructs a [_MatchResult] indicating a useless line was discarded
	_MatchResult.uselessLine():
		kind = _MatchResultKind.USELESS_LINE,
		value = null;

	/// Constructs a [_MatchResult] indicating a comment was discarded
	_MatchResult.comment():
		kind = _MatchResultKind.COMMENT,
		value = null;

	/// Constructs a [_MatchResult] indicating a variable was added to the cache
	_MatchResult.variable():
		kind = _MatchResultKind.VARIABLE,
		value = null;

	/// Constructs a [_MatchResult] for an import statement. Should be given the
	/// `String` file path of the import
	_MatchResult.import(this.value): kind = _MatchResultKind.IMPORT;

	/// Constructs a [_MatchResult] for a key/value pair. Should be given a tuple
	/// containing the pair information (`String` key, `dynamic` value, `int` indentation)
	_MatchResult.pair(this.value): kind = _MatchResultKind.PAIR;

	/// Constructs a [_MatchResult] for an object. Should be given a tuple containing
	/// the `Map<String, dynamic>` object  value and the `int` indentation of its keys
	_MatchResult.object(this.value): kind = _MatchResultKind.OBJECT;

	/// Constructs a [_MatchResult] for a list. Should be given a `List<dynamic>`
	/// representing the parsed list
	_MatchResult.list(this.value): kind = _MatchResultKind.LIST;

	/// Constructs a [_MatchResult] for a primitive value. Should be given the
	/// `dynamic` value representing the parsed primitive
	_MatchResult.primitive(this.value): kind = _MatchResultKind.PRIMITIVE;
}
