part of gura;

// Single indent string
const String _INDENT = '    ';

// Number chars
const String _BASIC_NUMBERS_CHARS = '0-9';
const String _HEX_OCT_BIN = 'A-Fa-fxob';

// The rest of the chars are defined in hex_oct_bin
const String _INF_AND_NAN = 'in';

// IMPORTANT: '-' char must be last, otherwise it will be interpreted as a range
const String _ACCEPTABLE_NUMBER_CHARS = _BASIC_NUMBERS_CHARS
	+ _HEX_OCT_BIN
	+ _INF_AND_NAN
	+ 'Ee+._-';

// Acceptable chars for keys
const String _KEY_ACCEPTABLE_CHARS = '0-9A-Za-z_';

// Special characters to be escaped
const Map<String, String> _ESCAPE_SEQUENCES = {
	'b': '\b',
	'f': '\f',
	'n': '\n',
	'r': '\r',
	't': '\t',
	'"': '"',
	'\\': '\\',
	'\$': '\$'
};
