# Token Changelog

## 2.0.1 - December 21, 2024

- Bugfix `Token:Hex()`
- Added typecheck `Base94JSONSAFE` and `Base256ASCII` to `Token.isbase()`

## 2.0.0 - December 21, 2024

- Added `Token:Clone()`
- Added `Token:NextBase256ASCII()`, recommend instance attribute case.
- Added `Token:NextBase94JSONSAFE()`, recommend json codec, datastore case.
- Improve speed performance with table allocation.

## 1.0.0

- Initial release
