part of util_extensions;

extension ListExtension<T> on List<T>
{
	/// The entries of this list
	Iterable<ListEntry<T>> get entries sync*
	{
		int index = 0;

		for (final T value in this)
			yield ListEntry(index++, value);
	}

	/// Returns whether or not this list shares deep equality with the given list
	bool deepEquals(List other)
	{
		if (length != other.length)
			return false;

		for (ListEntry<dynamic> entry in entries)
		{
			final dynamic valA = entry.value;
			final dynamic valB = other[entry.index];

			if (valA == null && valB == null)
				continue;

			if (valA is List && valB != null)
			{
				if (valA.deepEquals(valB))
					continue;

				return false;
			}

			if (valA is Map && valB != null)
			{
				if (valA.deepEquals(valB))
					continue;

				return false;
			}

			if (valB == null || valA.runtimeType != valB.runtimeType)
				return false;

			if (valA == valB)
				continue;

			return false;
		}

		return true;
	}
}
