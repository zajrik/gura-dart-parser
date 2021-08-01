part of gura;

class _GuraParser extends _Parser
{
	final Map<String, dynamic> _variables = {};
	final List<int> _indentationLevels = [];
	final Set<String> _importedFiles = {};

	/// Mutable snapshot of environment variables taken at construction
	final Map<String, String> env;

	_GuraParser(): env = Map.from(Platform.environment);

	/// Parses the given [text] in Gura format.
	///
	/// Throws a [ParseError] if [text] is invalid.
	///
	/// Returns a `Map<String, Dynamic>` of the values contained in the text
	Map<String, dynamic> parse(String text)
	{
		_resetInput(text);

		final Map<String, dynamic>? result = _start();

		assertEnd();

		return result ?? {};
	}

	/// Parses imports in the current Gura input String (given to [parse()]), followed
	/// by the top-level object containing all defined key/value pairs defined in
	/// the input.
	///
	/// Returns a `Map<String, dynamic>` containing all of the parsed Gura values
	Map<String, dynamic>? _start()
	{
		_parseAndLoadImports();

		final _MatchResult<Tuple2<Map<String, dynamic>, int>>? result = match([object]);

		_consumeWhitespaceAndNewlines();

		return result?.value?.item1;
	}

	/// Sets the internal Gura input string to the given [input] string and resets
	/// the parsing position to the beginning
	void _resetInput(String input)
	{
		text = input;
		pos = -1;
		line = 1;
		len = input.length - 1;
	}

	/// Consumes whitespaces and newlines
	void _consumeWhitespaceAndNewlines()
	{
		while (maybeChar(' \f\v\r\n\t') != null)
			continue;
	}

	/// Sets the loaded Gura input value to [guraText], parses and loads its imports,
	/// and builds a new Gura string that combines [guraText] with all imported file
	/// contents, with all import statements removed.
	///
	/// Returns a tuple containing the new Gura string and a Set of all import paths
	/// contained in all of the loaded Gura files
	///
	/// [parentDirectory] is used for calculating relative import paths.
	///
	/// This should be used internally via a fresh [_GuraParser] instance to recursively
	/// load imported files and prepare everything for later parsing
	Tuple2<String, Set<String>> _getContentAndImports(String guraText, String parentDirectory)
	{
		_resetInput(guraText);
		_parseAndLoadImports(parentDirectory);

		return Tuple2(text, _importedFiles);
	}

	/// Parses all import statements in the current Gura input string, caches them
	/// internally, and loads the content of the imported files. Any encountered
	/// variables will also be cached and stripped.
	///
	/// Can be given a `String` [parentDirectory] as a base for relative import paths.
	///
	/// Current input will be set to the combined content of all imported files plus
	/// the original input, with imports leading up to and including the final import
	/// stripped
	void _parseAndLoadImports([String? parentDirectory])
	{
		List<String> filesToImport = [];

		// Consume all import statements, vars, and useless lines in the current input,
		// until hitting something other than those three terms
		while (pos < len)
		{
			final _MatchResult<dynamic>? matchResult = maybeMatch([guraImport, variable, uselessLine]);

			if (matchResult == null)
				break;

			if (matchResult.kind == _MatchResultKind.IMPORT)
				filesToImport.add(matchResult.value as String);
		}

		String finalContent = '';

		if (filesToImport.isNotEmpty)
		{
			for (final String filePath in filesToImport)
			{
				File subFile = File(filePath);

				// Update file path with parentDirectory if it is not null
				if (parentDirectory != null)
					subFile = File(parentDirectory.joinWithPath(subFile.path));

				// Disallow importing a file multiple times
				if (_importedFiles.contains(subFile.path))
					throw DuplicatedImportError('The file "${subFile.path}" has already been imported');

				// Check if file exists
				if (!subFile.existsSync())
					throw FileNotFoundError('The file "${subFile.path}" does not exist');

				// Get imported file content and parse it for its imports as well
				final String subFileContent = subFile.readAsStringSync();
				final String subFileParentDirectory = subFile.parent.path;
				final _GuraParser subFileParser = _GuraParser();

				final Tuple2<String, Set<String>> updatedContentAndImports = subFileParser
					._getContentAndImports(subFileContent, subFileParentDirectory);

				final String updatedSubFileContent = updatedContentAndImports.item1;
				final Set<String> subFileImports = updatedContentAndImports.item2;

				finalContent += updatedSubFileContent + '\n';

				subFileImports.add(subFile.path);
				_importedFiles.addAll(subFileImports);
			}

			// Inject imported file content in place of current input's imports
			_resetInput(finalContent + text.substring(pos + 1));
		}
	}

	/// Gets a variable name from the Gura input String, char by char
	String _getVariableName()
	{
		String varName = '';
		String? varNameChar = maybeChar(_KEY_ACCEPTABLE_CHARS);

		while (varNameChar != null)
		{
			varName += varNameChar;
			varNameChar = maybeChar(_KEY_ACCEPTABLE_CHARS);
		}

		return varName;
	}

	/// Gets and returns a `dynamic` variable value for the given String [key].
	///
	/// Throws a [VariableNotDefinedError] if [key] is not defined in the Gura
	/// input or as an environment variable
	dynamic _getVariableValue(String key)
	{
		if (_variables.containsKey(key))
			return _variables[key];

		if (env.containsKey(key))
			return env[key];

		throw VariableNotDefinedError(
			'Variable "$key" is not defined in Gura nor as environment variable'
		);
	}

	/// Gets the last indentation level.
	///
	/// Returns the last `int` indentation level, or null if it does not exist
	int? _getLastIndentationLevel() => _indentationLevels.isNotEmpty
		? _indentationLevels.last
		: null;

	/// Removes the last tracked indentation level if it exists
	void _removeLastIndentationLevel()
	{
		if (_indentationLevels.isNotEmpty)
			_indentationLevels.removeLast();
	}

	/// Matches a new line, which is discarded
	_ParserRule<void> get newLine => _ParserRule(name: 'newLine', fn: ()
	{
		final String? res = char('\f\v\r\n');
		if (res != null)
			line += 1;
	});

	/// Matches with a comment, which is discarded.
	///
	/// Returns a `_MatchResult` indicating the presence of a comment
	_ParserRule<_MatchResult<void>> get comment => _ParserRule(name: 'comment', fn: ()
	{
		keyword(['#']);

		while (pos < len)
		{
			final String char = text[pos + 1];
			pos += 1;

			if ('\f\v\r\n'.contains(char))
			{
				line += 1;
				break;
			}
		}

		return _MatchResult.comment();
	});

	/// Matches with a useless line. A line is useless when it contains only
	/// whitespaces and/or a comment terminating in a newline.
	///
	/// Throws a [ParseError] if the line contains valid data.
	///
	/// Returns an empty `_MatchResult` indicating a useless line was discarded
	_ParserRule<_MatchResult<void>> get uselessLine => _ParserRule(name: 'uselessLine', fn: ()
	{
		// Discard whitespace
		match([whitespace]);

		final _MatchResult<void>? commentMatch = maybeMatch([comment]);
		final int initialLine = line;

		// Discard newline
		maybeMatch([newLine]);

		final bool isNewLine = (line - initialLine) == 1;

		if (commentMatch == null && !isNewLine)
		{
			throw ParseError(
				pos: pos + 1,
				line: line,
				message: 'Expected useless line, found valid line'
			);
		}

		return _MatchResult.uselessLine();
	});

	/// Matches with whitespace, taking into consideration indentation levels.
	///
	/// Returns the `int` indentation level consumed
	_ParserRule<int> get whitespaceWithIndentation => _ParserRule(name: 'whitespaceWithIndentation', fn: ()
	{
		int currentIndentationLevel = 0;

		while (pos < len)
		{
			final String? blank = maybeKeyword([' ', '\t']);

			// If it is not a blank or new line, break to return
			if (blank == null)
				break;

			// Throw error if tabs are used for indentation
			if (blank == '\t')
				throw InvalidIndentationError('Tabs are not allowed to define indentation blocks');

			currentIndentationLevel += 1;
		}

		return currentIndentationLevel;
	});

	/// Matches with whitespace (spaces and tabs), which is discarded
	_ParserRule<void> get whitespace => _ParserRule(name: 'whitespace', fn: ()
	{
		while (maybeKeyword([' ', '\t']) != null)
			continue;
	});

	/// Matches with a single import statement.
	///
	/// Returns a `_MatchResult<String>` containing the file path of the imported file
	_ParserRule<_MatchResult<String>> get guraImport => _ParserRule(name: 'guraImport', fn: ()
	{
		// Discard import statement
		keyword(['import']);
		char(' ');

		// Capture import path
		final String fileToImport = match([importPath]);

		// Discard whitespace and newline
		match([whitespace]);
		maybeMatch([newLine]);

		return _MatchResult.import(fileToImport);
	});

	/// Matches with import path values.
	///
	/// Import path values are surrounded by single double-quotes (e.g. `"foo"`).
	/// Any variables in the path value will be interpolated into the resulting
	/// string value. Does not handle character escaping.
	///
	/// Returns the matched string value
	_ParserRule<String> get importPath => _ParserRule(name: 'importPath', fn: ()
	{
		final String quote = keyword(['"']);
		final List<String> characters = [];

		while (true)
		{
			final String character = char();

			if (character == quote)
				break;

			// Interpolate variables if we see `$`
			if (character == '\$')
			{
				final String varName = _getVariableName();
				characters.add(_getVariableValue(varName));
			}
			else
			{
				characters.add(character);
			}
		}

		return characters.join('');
	});

	/// Matches with an unquoted string (top-level/object keys).
	///
	/// Returns the parsed unquoted string
	_ParserRule<String> get unquotedString => _ParserRule(name: 'unquotedString', fn: ()
	{
		final List<String> chars = [char(_KEY_ACCEPTABLE_CHARS)];

		while (true)
		{
			final String? char = maybeChar(_KEY_ACCEPTABLE_CHARS);

			if (char == null)
				break;

			chars.add(char);
		}

		return chars.join('').trimRight();
	});

	/// Matches with any primitive or complex type.
	///
	/// Returns a `_MatchResult<dynamic>?` containing the parsed value
	_ParserRule<_MatchResult<dynamic>?> get anyType => _ParserRule(
		name: 'anyType',
		fn: () => maybeMatch([primitive]) ?? match([complex])
	);

	/// Matches with a primitive value (null, bool, strings, numbers, or variables values).
	///
	/// Returns a `_MatchResult<dynamic>` containing the corresponding parsed value
	_ParserRule<_MatchResult<dynamic>> get primitive => _ParserRule(name: 'primitiveType', fn: ()
	{
		// Discard whitespace
		maybeMatch([whitespace]);

		return match([nullValue, emptyObject, boolean, basicString, literalString, number, variableValue]);
	});

	/// Matches with a list or object.
	///
	/// Returns a `_MatchResult<dynamic>?` containing `List<dynamic>` or
	/// `Map<String, dynamic>` depending on the match
	_ParserRule<_MatchResult<dynamic>?> get complex => _ParserRule(
		name: 'complex',
		fn: () => match([list, object])
	);

	/// Matches with an already defined variable.
	///
	/// Returns a `_MatchResult<dynamic>` containing the variable value
	_ParserRule<_MatchResult<dynamic>> get variableValue => _ParserRule(name: 'variableValue', fn: ()
	{
		// Discard `$`
		keyword(['\$']);

		final String variableKey = match([unquotedString]);

		return _MatchResult.primitive(_getVariableValue(variableKey));
	});

	/// Matches with a variable definition, which will be cached for later use.
	///
	/// Throws [DuplicatedVariableError] if the variable is already defined.
	///
	/// Returns an empty `_MatchResult` indicating that a variable has been parsed
	_ParserRule<_MatchResult<void>> get variable => _ParserRule(name: 'variable', fn: ()
	{
		// Discard `$`
		keyword(['\$']);

		// Capture variable key
		final String variableKey = match([key]);

		// Discard whitespace
		maybeMatch([whitespace]);

		// Capture variable value
		final _MatchResult matchResult = match([basicString, literalString, number, variableValue]);

		if (_variables.containsKey(variableKey))
			throw DuplicatedVariableError('Variable "$variableKey" has been already declared');

		// Store as variable
		_variables[variableKey] = matchResult.value;

		return _MatchResult.variable();
	});

	/// Matches with a list.
	///
	/// Returns a `_MatchResult<List<dynamic>>` containing the list value
	_ParserRule<_MatchResult<List<dynamic>>> get list => _ParserRule(name: 'list', fn: ()
	{
		final List<dynamic> result = [];

		// Discard whitespace and opening bracket
		maybeMatch([whitespace]);
		keyword(['[']);

		while (true)
		{
			// Discard useless lines between elements of array
			final _MatchResult<void>? uselessLineMatch = maybeMatch([uselessLine]);

			if (uselessLineMatch != null)
				continue;

			final _MatchResult? matchResult = maybeMatch([anyType]);
			dynamic resultItem;

			if (matchResult == null)
				break;

			if (matchResult.kind == _MatchResultKind.OBJECT)
				resultItem = matchResult.value.item1;

			else
				resultItem = matchResult.value;

			result.add(resultItem);

			// Discard whitespace and break if we don't find a comma
			maybeMatch([whitespace]);
			maybeMatch([newLine]);
			if (maybeKeyword([',']) == null)
				break;
		}

		// Discard whitespace and closing bracket
		maybeMatch([whitespace]);
		maybeMatch([newLine]);
		keyword([']']);

		return _MatchResult.list(result);
	});

	/// Matches with an object in the current indentation scope.
	///
	/// All key/value pairs in the current indentation scope will be traversed and
	/// a `Map<String, dynamic>` containing every key/value [pair] encountered will
	/// be constructed.
	///
	/// Any encountered variables (outer-most scope) will be cached for later use.
	///
	/// Throws [DuplicatedKeyError] if it parses a key/value pair with a key that
	/// has already been defined in the current scope
	///
	/// Returns a `_MatchResult<Tuple2<Map<String, dynamic>, int>>?` containing
	/// the constructed `Map<String, dynamic>` and the `int` indentation level
	/// of the parsed key/value pairs
	_ParserRule<_MatchResult<Tuple2<Map<String, dynamic>, int>>?> get object => _ParserRule(name: 'object', fn: ()
	{
		final Map<String, dynamic> result = {};
		int indentationLevel = 0;

		while (pos < len)
		{
			final _MatchResult? matchResult = maybeMatch([variable, pair, uselessLine]);

			if (matchResult == null)
				break;

			if (matchResult.kind == _MatchResultKind.PAIR)
			{
				final Tuple3<String, dynamic, int> matchValue = matchResult.value;

				final String key = matchValue.item1;
				final dynamic value = matchValue.item2;
				final int indentation = matchValue.item3;

				if (result.containsKey(key))
					throw DuplicatedKeyError('The key "$key" has been already defined');

				result[key] = value;
				indentationLevel = indentation;
			}

			// Reset indentation level and break if we are are ending a list,
			// or if we see a comma in the list which terminates this object
			if (maybeKeyword([']', ',']) != null)
			{
				_removeLastIndentationLevel();
				pos -= 1;
				break;
			}
		}

		return result.isNotEmpty
			? _MatchResult.object(Tuple2(result, indentationLevel))
			: null;
	});

	/// Matches with a key. A key is an unquoted string followed by a colon (`:`).
	///
	/// Throws a [ParseError] if the key is not a valid string (`[a-zA-Z0-9_]+`).
	///
	/// Returns the matched key string
	_ParserRule<String> get key => _ParserRule(name: 'key', fn: ()
	{
		final String key = match([unquotedString]);

		// Discard `:`
		keyword([':']);

		return key;
	});

	/// Matches with a key/value pair.
	///
	/// Returns a `_MatchResult<Tuple3<String, dynamic, int>>` where the tuple
	/// contains the `String` key, `dynamic` value, and `int` indentation level
	/// (The indentation level at the start of the pair key).
	///
	/// Returns `null` if the indentation level is lower than the last parsed
	/// indentation level, indicating the ending of a parent object
	_ParserRule<_MatchResult<Tuple3<String, dynamic, int>>?> get pair => _ParserRule(name: 'pair', fn: ()
	{
		final int posBeforePair = pos;
		final int currentIndentationLevel = maybeMatch([whitespaceWithIndentation]) ?? 0;

		// Capture pair key
		final String pairKey = match([key]);

		dynamic pairValue;

		// Discard whitespace
		maybeMatch([whitespace]);

		// Capture previous indentation level
		final int? lastIndentationBlock = _getLastIndentationLevel();

		// Check if indentation is divisible by 4
		if (currentIndentationLevel % 4 != 0)
			throw InvalidIndentationError('Indentation block ($currentIndentationLevel) must be divisible by 4');

		// Track current indentation level if it has increased
		if (lastIndentationBlock == null || currentIndentationLevel > lastIndentationBlock)
		{
			_indentationLevels.add(currentIndentationLevel);
		}

		// Otherwise remove last indentation level if it has decreased
		else if (currentIndentationLevel < lastIndentationBlock)
		{
			_removeLastIndentationLevel();

			// Reset position to before this pair and return null.
			// This will terminate the object currently being parsed
			pos = posBeforePair;
			return null;
		}

		final _MatchResult<dynamic>? matchResult = match([anyType]);

		// If matchResult is null then it's an empty object, and therefore invalid
		if (matchResult == null)
			throw ParseError(pos: pos + 1, line: line, message: 'Invalid pair');

		// Assign object value to result if match is an object
		if (matchResult.kind == _MatchResultKind.OBJECT)
		{
			final _MatchResult<Tuple2<Map<String, dynamic>, int>> resultTuple = matchResult as dynamic;
			final dynamic objectValues = resultTuple.value!.item1;
			final int indentationLevel = resultTuple.value!.item2;

			// Check indentation against parent level
			if (indentationLevel == currentIndentationLevel)
				throw InvalidIndentationError('Invalid indentation level for parent with key "$pairKey"');

			else if ((currentIndentationLevel - indentationLevel).abs() != 4)
				throw InvalidIndentationError(
					'Difference between different indentation levels must be 4 spaces'
				);

			pairValue = objectValues;
		}

		// Otherwise assign non-object value to result
		else
		{
			pairValue = matchResult.value;
		}

		// Indentation tracking can get messed up in nested lists so reset indentation
		// to the start of this pair if the pair value is a list to be safe
		if (pairValue is List)
		{
			_removeLastIndentationLevel();
			_indentationLevels.add(currentIndentationLevel);
		}

		// Discard newline
		maybeMatch([newLine]);

		return _MatchResult.pair(Tuple3(pairKey, pairValue, currentIndentationLevel));
	});

	/// Matches with `null` keyword.
	///
	/// Returns a `_MatchResult.primitive` containing a `null` value
	_ParserRule<_MatchResult> get nullValue => _ParserRule(name: 'nullValue', fn: ()
	{
		// Discard `null` keyword
		keyword(['null']);

		return _MatchResult.primitive(null);
	});

	/// Matches with `empty` keyword
	///
	/// Returns a `_MatchResult.primitive` containing an empty `Map<String, dynamic>`
	_ParserRule<_MatchResult<Map<String, dynamic>>> get emptyObject => _ParserRule(name: 'emptyObject', fn: ()
	{
		// Discard `empty` keyword
		keyword(['empty']);

		return _MatchResult.primitive({});
	});

	/// Matches with a boolean value (`true`, `false`)
	///
	/// Returns a `_MatchResult<bool>` containing the parsed bool
	_ParserRule<_MatchResult<bool>> get boolean => _ParserRule(name: 'boolean', fn: ()
	{
		final bool value = keyword(['true', 'false']) == 'true';
		return _MatchResult.primitive(value);
	});

	/// Matches with numerical values.
	///
	/// Throws [ParseError] if the matched value is not a valid number.
	///
	/// Returns a `_MatchResult<num>` containing the parsed number value
	_ParserRule<_MatchResult<num>> get number => _ParserRule(name: 'number', fn: ()
	{
		final List<String> chars = [char(_ACCEPTABLE_NUMBER_CHARS)];

		_NumberType numberType = _NumberType.INTEGER;

		// Capture all characters of the number
		while (true)
		{
			final String? char = maybeChar(_ACCEPTABLE_NUMBER_CHARS);

			if (char == null)
				break;

			if ('Ee.'.contains(char))
				numberType = _NumberType.FLOAT;

			chars.add(char);
		}

		// Replace numerical separators as Dart does not currently support them
		final String result = chars
			.join('')
			.trimRight()
			.replaceAll('_', '');

		// Capture potential number literal prefix
		final String prefix = result.length >= 2
			? result.substring(0, 2)
			: result;

		// Check hex, octal, and binary numbers
		if (['0x', '0o', '0b'].contains(prefix))
		{
			final String digits = result.substring(2);
			final int radix = _match(prefix, {
				'0x': () => 16,
				'0o': () => 8,
				'0b': () => 2,
			});

			return _MatchResult.primitive(int.parse(digits, radix: radix));
		}

		final String lastThreeChars = result.length >= 3
			? result.substring(result.length - 3)
			: result;

		// Check infinity or NaN
		if (lastThreeChars == 'inf')
		{
			return _MatchResult.primitive(
				result[0] == '-' ? double.negativeInfinity : double.infinity
			);
		}
		else if (lastThreeChars == 'nan')
		{
			return _MatchResult.primitive(double.nan);
		}

		final num? resultValue = numberType == _NumberType.INTEGER
			? int.tryParse(result)
			: double.tryParse(result);

		if (resultValue == null || resultValue.isNaN)
		{
			throw ParseError(
				pos: pos + 1,
				line: line,
				message: '"$result" is not a valid number'
			);
		}

		return _MatchResult.primitive(resultValue);
	});

	/// Matches with simple/multiline basic strings.
	///
	/// Returns a `_MatchResult<String>` containing the parsed string value
	_ParserRule<_MatchResult<String>> get basicString => _ParserRule(name: 'basicString', fn: ()
	{
		final String quote = keyword(['"""', '"']);
		final bool isMultiline = quote == '"""';

		// Discard newline following opening delimiter
		if (isMultiline)
			maybeChar('\n');

		final List<String> characters = [];

		while (true)
		{
			final String? closingQuote = maybeKeyword([quote]);

			if (closingQuote != null)
				break;

			final String character = char();

			// Check escape characters if we see backslash
			if (character == '\\')
			{
				final String escape = char();

				// Trim whitespace if string is multiline and we see newline
				if (isMultiline && escape == '\n')
				{
					_consumeWhitespaceAndNewlines();
				}

				// Add escaped unicode characters if we encounter 'u' or 'U'
				else if (escape == 'u' || escape == 'U')
				{
					final int numCharsCodePoint = escape == 'u' ? 4 : 8;
					final List<String> codePoints = [];

					for (int i = 0; i < numCharsCodePoint; i++)
						codePoints.add(char('0-9a-fA-F'));

					final int hexValue = int.parse(codePoints.join(''), radix: 16);
					final String charValue = String.fromCharCode(hexValue);

					characters.add(charValue);
				}

				// Otherwise add single escaped character
				else
				{
					characters.add(_ESCAPE_SEQUENCES[escape] ?? character);
				}
			}

			// Interpolate variable values in string if we encounter `$`
			else if (character == '\$')
			{
				final String varName = _getVariableName();
				characters.add(_getVariableValue(varName));
			}

			// Otherwise add single character
			else
			{
				characters.add(character);
			}
		}

		return _MatchResult.primitive(characters.join(''));
	});

	/// Matches with simple/multiline literal strings.
	///
	/// Returns a `_MatchResult<String>` containing the parsed string value
	_ParserRule<_MatchResult<String>> get literalString => _ParserRule(name: 'literalString', fn: ()
	{
		final String quote = keyword(["'''", "'"]);
		final bool isMultiline = quote == "'''";

		// Discard newline following opening delimiter
		if (isMultiline)
			maybeChar('\n');

		final List<String> characters = [];

		while (true)
		{
			final String? closingQuote = maybeKeyword([quote]);

			if (closingQuote != null)
				break;

			final String character = char();
			characters.add(character);
		}

		return _MatchResult.primitive(characters.join(''));
	});
}
