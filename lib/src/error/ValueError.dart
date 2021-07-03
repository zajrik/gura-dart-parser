part of gura;

/// Used internally for bad character ranges
class _ValueError extends _GuraError
{
	_ValueError([String? message]):
		super(message);
}
