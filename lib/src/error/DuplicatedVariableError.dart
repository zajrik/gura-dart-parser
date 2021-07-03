part of gura;

/// Thrown when a variable is defined more than once
class DuplicatedVariableError extends _GuraError
{
	DuplicatedVariableError([String? message]):
		super(message);
}
