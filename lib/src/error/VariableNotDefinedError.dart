part of gura;

/// Thrown when a variable is not defined
class VariableNotDefinedError extends _GuraError
{
	VariableNotDefinedError([String? message]):
		super(message);
}
