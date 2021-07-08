/// An index/value pair representing an entry in a List
class ListEntry<T>
{
	/// The index of the entry
	final int index;

	/// The value of the entry
	final T value;

	const ListEntry._(this.index, this.value);

	/// Creates an entry with the given index and value
	const factory ListEntry(int index, T value) = ListEntry._;

	@override
	String toString() => 'ListEntry($index: $value})';
}
