## [0.1.0-dev.1]

- BREAKING: error is now thrown instead of returned within the responses.
Before:
```dart
final response = await ....;
if (response.hasError) {
  final error = response.error!;
  // handle error
} else {
  final data = response.data!;
  // handle data
}
```

Now:
```dart
try {
  final data = await ....;
} on StorageError catch (error) {
  // handle storage errors
} catch (error) {
  // handle other errors
} 
```
- feat: added `createSignedUrls` to create signed URLs in bulk.
- feat: added `copy` method to copy a file to another path.
- feat: added support for custom http client

## [0.0.6+2]

- fix: add status code to `StorageError` within `Fetch`

## [0.0.6+1]

- fix: Bug where `move()` does not work properly

## [0.0.6]

- feat: set custom mime/Content-Type from `FileOptions`
- fix: Move `StorageError` to `types.dart`

## [0.0.5]

- fix: Set `X-Client-Info` header

## [0.0.4]

- fix: Set default meme type to `application/octet-stream` when meme type not found.

## [0.0.3]

- BREAKING CHANGE: rework upload/update binary file methods by removing BinaryFile class and supporting Uint8List directly instead.

## [0.0.2]

- feat: support upload/update binary file
- fix: docker-compose for unit test
- fix: method comment format

## [0.0.1]

- feat: add upsert option to upload
- Initial Release

## [0.0.1-dev.3]

- feat: add public option for createBucket method, and add updateBucket
- feat: add getPublicUrl

## [0.0.1-dev.2]

- fix: replaced dart:io with universal_io
- chore: add example
- chore: update README

## [0.0.1-dev.1]

- Initial pre-release.
