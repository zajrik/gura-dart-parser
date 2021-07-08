part of gura;

extension _ListExtension<T> on List<T>
{
	/// The entries of this list
	Iterable<ListEntry<T>> get entries sync*
	{
		int index = 0;

		for (final T value in this)
			yield ListEntry(index++, value);
	}
}
