## 1.3.2

- Fix string dumping producing invalid strings when the value contains line breaks

## 1.3.1

- Fix error when parsing additional pairs following a nested list

## 1.3.0

- Add support for `empty` keyword
- Change how dump handles stringifying nested arrays
  - Arrays will no longer line-break if they contain only empty arrays (e.g. `[[]. []. []]`)

## 1.2.0

- Update `dump()` to multi-line nested arrays. This will better visually represent 2-dimensional arrays.

## 1.1.1

- Update readme

## 1.1.0

- Rewrite `dump()` function to produce more readable, consistent output

## 1.0.4

- Add more badges to readme

## 1.0.3

- Add more badges to readme

## 1.0.2

- Update parser internals to properly print names of expected syntax terms when
  no valid term is found

## 1.0.1

- Update pubspec, readme
- Add example file.

## 1.0.0

- Initial version
