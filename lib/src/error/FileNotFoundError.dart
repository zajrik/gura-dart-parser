part of gura;

/// Thrown when file to be parsed does not exist
class FileNotFoundError extends _GuraError
{
	FileNotFoundError([String? message]):
		super(message);
}
