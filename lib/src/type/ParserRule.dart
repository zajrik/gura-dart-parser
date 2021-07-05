part of gura;

/// Represents a rule function that matches text for the parser, returning the
/// matched value in some form, typically through a [_MatchResult]
class _ParserRule<T>
{
	final String name;
	final T Function() fn;

	_ParserRule({required this.name, required this.fn});
}
