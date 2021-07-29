part of gura;

/// Thrown when a literal key contains an unsupported character (line-break of some sort)
class InvalidKeyError extends _GuraError
{
	InvalidKeyError([String? message]):
		super(message);
}
