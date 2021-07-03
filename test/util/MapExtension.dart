part of util_extensions;

extension MapExtension on Map
{
	/// Returns whether or not this Map shares deep equality with the given Map
	bool deepEquals(Map other)
	{
		if (length != other.length)
			return false;

		for (MapEntry<dynamic, dynamic> entry in entries)
		{
			final dynamic valA = entry.value;
			final dynamic? valB = other[entry.key];

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
