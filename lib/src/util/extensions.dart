part of gura;

extension on String
{
 	// ignore: unused_element
	bool operator >(String other) => compareTo(other) > 0;

	// ignore: unused_element
	bool operator <(String other) => compareTo(other) < 0;

	// ignore: unused_element
	bool operator >=(String other) => compareTo(other) >= 0;

	// ignore: unused_element
	bool operator <=(String other) => compareTo(other) <= 0;

	/// Returns this string joined with the given path segment strings and normalized
	String joinWithPath(String a, [String? b, String? c, String? d, String? e, String? f, String? g]) =>
		normalize(join(this, a, b, c, d, e, f, g));
}
