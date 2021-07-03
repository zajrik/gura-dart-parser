part of gura;

/// Thrown when an error occurred during parsing
class ParseError extends _GuraError
{
	final int pos;
	final int line;

	ParseError({String? message, required this.pos, required this.line}):
		super(message);

	@override
	String toString() => '$_name: "$message" at line $line, position $pos';
}
