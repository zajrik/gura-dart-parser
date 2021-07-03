part of gura;

/// Thrown when a key is defined more than once
class DuplicatedKeyError extends _GuraError
{
	DuplicatedKeyError([String? message]):
		super(message);
}
