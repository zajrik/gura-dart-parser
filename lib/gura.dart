/// Dart library for parsing [Gura configuration files](https://gura.netlify.app/)
library gura;

import 'dart:io';
import 'dart:math';

import 'package:path/path.dart';
import 'package:tuple/tuple.dart';

import 'src/util/ListEntry.dart';

// Private lib components:
part 'src/util/extensions.dart';
part 'src/util/constants.dart';
part 'src/type/NumberType.dart';

part 'src/error/GuraError.dart';
part 'src/error/ValueError.dart';

part 'src/type/ParserRule.dart';
part 'src/type/MatchResult.dart';
part 'src/type/MatchResultKind.dart';

part 'src/Parser.dart';
part 'src/GuraParser.dart';

// Public lib components:
part 'src/util/functions.dart';

part 'src/error/ParseError.dart';

part 'src/error/DuplicatedImportError.dart';
part 'src/error/DuplicatedKeyError.dart';
part 'src/error/DuplicatedVariableError.dart';
part 'src/error/FileNotFoundError.dart';
part 'src/error/InvalidIndentationError.dart';
part 'src/error/InvalidKeyError.dart';
part 'src/error/VariableNotDefinedError.dart';
