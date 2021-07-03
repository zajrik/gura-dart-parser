part of gura;

class _GuraError extends Error
{
	final String message;

	_GuraError([String? message]): message = message ?? '';

	String get _name => runtimeType.toString();

	@override
	String toString() => message != '' ? '$_name: $message' : _name;
}
