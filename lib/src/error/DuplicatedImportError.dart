part of gura;

/// Thrown when a file is imported more than once
class DuplicatedImportError extends _GuraError
{
	DuplicatedImportError([String? message]):
		super(message);
}
