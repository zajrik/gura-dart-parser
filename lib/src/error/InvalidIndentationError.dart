part of gura;

/// Thrown when indentation is invalid
class InvalidIndentationError extends _GuraError
{
	InvalidIndentationError([String? message]):
		super(message);
}
