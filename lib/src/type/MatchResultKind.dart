part of gura;

/// Represents the different kind of [_MatchResult]s
enum _MatchResultKind
{
	USELESS_LINE,
	COMMENT,
	VARIABLE,
	IMPORT,
	PAIR,
	OBJECT,
	LIST,
	PRIMITIVE
}
