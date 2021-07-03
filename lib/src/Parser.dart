part of gura;

class _Parser
{
	String text = '';
	int pos = 1;
	int line = 1;
	int len = 0;

	final Map<String, List<String>> _cache = {};

	_Parser();

	/// Checks that the parser has reached the end of file, otherwise it will
	/// throw a ParseError
	void assertEnd()
	{
		if (pos < len)
		{
			throw ParseError(
				pos: pos + 1,
				line: line,
				message: 'Expected end of string but got ${text[pos + 1]}'
			);
		}
	}

	/// Generates a list of chars from a list of chars which can contain char
	/// ranges (i.e. `a-z` or `0-9`)
	List<String> splitCharRanges(String chars)
	{
		if (_cache.containsKey(chars))
			return _cache[chars]!;

		final List<String> result = [];
		final int length = chars.length;

		int index = 0;

		while (index < length)
		{
			if (index + 2 < length && chars[index + 1] == '-')
			{
				if (chars[index] >= chars[index + 2])
					throw _ValueError('Bad character range');

				result.add(chars.substring(index, index + 3));
				index += 3;
			}
			else
			{
				result.add(chars[index]);
				index += 1;
			}
		}

		_cache[chars] = result;
		return result;
	}

	/// Matches a list of specific chars and returns the first that matched.
	/// If no match is found, it will throw a ParseError
	///
	/// Matches a list of specific characters from the given [charSet] string.
	/// This string should be formatted like a regular expression character
	/// set (e.g. `[a-zA-Z]`) without the square-braces, and can include character
	/// ranges. For example:
	///
	/// ```dart
	/// String character = char('a-zA-Z0-9_');
	/// ```
	///
	/// Returns the first character from the set that is matched in the Gura
	/// input text
	String char([String? charSet])
	{
		if (pos >= len)
		{
			final String param = charSet == null ? 'character' : '[$charSet]';

			throw ParseError(
				pos: pos + 1,
				line: line,
				message: 'Expected $param but got end of string'
			);
		}

		String nextChar = text[pos + 1];

		if (charSet == null)
		{
			pos += 1;
			return nextChar;
		}

		for (final String charRange in splitCharRanges(charSet))
		{
			if (charRange.length == 1)
			{
				if (nextChar == charRange)
				{
					pos += 1;
					return nextChar;
				}
			}
			else if (charRange[0] <= nextChar && nextChar <= charRange[2])
			{
				pos += 1;
				return nextChar;
			}
		}

		throw ParseError(
			pos: pos + 1,
			line: line,
			message: 'Expected "[$charSet]" but got $nextChar'
		);
	}

	/// Matches specific keywords
	String keyword(List<String> keywords)
	{
		if (pos >= len)
		{
			throw ParseError(
				pos: pos + 1,
				line: line,
				message: 'Expected ${keywords.join(',')} but got end of string'
			);
		}

		for (final String keyword in keywords)
		{
			final int low = pos + 1;
			final int high = low + keyword.length;

			String slice = '';

			_tryIgnore(() => slice = text.substring(low, high));

			if (slice == keyword)
			{
				pos += keyword.length;
				return keyword;
			}
		}

		throw ParseError(
			pos: pos + 1,
			line: line,
			message: 'Expected one of [${keywords.join(', ')}] but got "${text[pos + 1]}"'
		);
	}

	/// Matches specific rules which must be implemented as a method in a corresponding
	/// parser. A rule does not match if it throws a ParseError.
	///
	/// Throws ParseError if any of the specified rules matched.
	///
	/// Returns the result of the first matched rule function
	dynamic match(List<_GuraParserRule> rules)
	{
		final List<_GuraParserRule> erroredRules = [];

		ParseError? lastError;
		int lastErrorPos = -1;

		for (final _GuraParserRule rule in rules)
		{
			final int initialPos = pos;

			// Attempt to return rule function result
			try
			{
				return rule();
			}

			// Store ParseErrors
			on ParseError catch (error)
			{
				// Reset position to try the next rule
				pos = initialPos;

				// If error position is after last error position, reset tracked
				// errored rules and add this errored rule and its position
				if (error.pos > lastErrorPos)
				{
					lastError = error;
					lastErrorPos = error.pos;
					erroredRules.clear();
					erroredRules.add(rule);
				}

				// Otherwise just track this errored rule
				else if (error.pos == lastErrorPos)
				{
					erroredRules.add(rule);
				}
			}
		}

		if (erroredRules.length == 1)
		{
			throw lastError!;
		}
		else
		{
			lastErrorPos = min(text.length - 1, lastErrorPos);
			throw ParseError(
				pos: lastErrorPos,
				line: line,
				message: 'Expected [${erroredRules.join(', ')}] but got ${text[lastErrorPos]}'
			);
		}
	}

	/// Like [char()] but returns null instead of throwing [ParseError]
	String? maybeChar([String? chars]) => _tryReturn(() => char(chars));

	/// Like [match()] but returns null instead of throwing [ParseError]
	dynamic? maybeMatch(List<_GuraParserRule> rules) => _tryReturn(() => match(rules));

	/// Like [keyword()] but returns null instead of throwing [ParseError]
	String? maybeKeyword(List<String> keywords) => _tryReturn(() => keyword(keywords));
}
