import 'dart:io';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:storage_client/src/fetch.dart';
import 'package:storage_client/storage_client.dart';
import 'package:test/test.dart';

const String supabaseUrl = 'SUPABASE_TEST_URL';
const String supabaseKey = 'SUPABASE_TEST_KEY';

class MockFetch extends Mock implements Fetch {}

final FileOptions mockFileOptions = any<FileOptions>();
final FetchOptions mockFetchOptions = any<FetchOptions>(named: 'options');

const Map<String, dynamic> testBucketJson = {
  'id': 'test_bucket',
  'name': 'test_bucket',
  'owner': 'owner_id',
  'created_at': '',
  'updated_at': '',
  'public': false,
};

const Map<String, dynamic> testFileObjectJson = {
  'name': 'test_bucket',
  'id': 'test_bucket',
  'bucket_id': 'public',
  'owner': 'owner_id',
  'updated_at': null,
  'created_at': null,
  'last_accessed_at': null,
  'buckets': testBucketJson
};

const String bucketUrl = '$supabaseUrl/storage/v1/bucket';
const String objectUrl = '$supabaseUrl/storage/v1/object';

void main() {
  late SupabaseStorageClient client;

  group('client', () {
    setUp(() {
      // init SupabaseClient with test url & test key
      client = SupabaseStorageClient('$supabaseUrl/storage/v1', {
        'Authorization': 'Bearer $supabaseKey',
      });

      // Use mocked version for `fetch`, to prevent actual http calls.
      fetch = MockFetch();

      // Register default mock values (used by mocktail)
      registerFallbackValue<FileOptions>(const FileOptions());
      registerFallbackValue<FetchOptions>(const FetchOptions());
    });

    tearDown(() {
      final file = File('a.txt');
      if (file.existsSync()) file.deleteSync();
    });

    test('should list buckets', () async {
      when(() => fetch.get(bucketUrl, options: mockFetchOptions)).thenAnswer(
        (_) => Future.value([testBucketJson, testBucketJson]),
      );

      final response = await client.listBuckets();
      expect(response, isA<List<Bucket>>());
    });

    test('should create bucket', () async {
      const testBucketId = 'test_bucket';
      const requestBody = {
        'id': testBucketId,
        'name': testBucketId,
        'public': false
      };
      when(() => fetch.post(bucketUrl, requestBody, options: mockFetchOptions))
          .thenAnswer(
        (_) => Future.value(
          const {
            'name': 'test_bucket',
          },
        ),
      );

      final response = await client.createBucket(testBucketId);
      expect(response, isA<String>());
      expect(response, 'test_bucket');
    });

    test('should get bucket', () async {
      const testBucketId = 'test_bucket';
      when(
        () => fetch.get(
          '$bucketUrl/$testBucketId',
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => Future.value(testBucketJson),
      );

      final response = await client.getBucket(testBucketId);
      expect(response, isA<Bucket>());
      expect(response.id, testBucketId);
      expect(response.name, testBucketId);
    });

    test('should empty bucket', () async {
      const testBucketId = 'test_bucket';
      when(
        () => fetch.post(
          '$bucketUrl/$testBucketId/empty',
          {},
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => Future.value(
          const {
            'message': 'Emptied',
          },
        ),
      );

      final response = await client.emptyBucket(testBucketId);
      expect(response, 'Emptied');
    });

    test('should delete bucket', () async {
      const testBucketId = 'test_bucket';
      when(
        () => fetch.delete(
          '$bucketUrl/$testBucketId',
          {},
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => Future.value(const {'message': 'Deleted'}),
      );

      final response = await client.deleteBucket(testBucketId);
      expect(response, 'Deleted');
    });

    test('should upload file', () async {
      final file = File('a.txt');
      file.writeAsStringSync('File content');

      when(
        () => fetch.postFile(
          '$objectUrl/public/a.txt',
          file,
          mockFileOptions,
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => Future.value(const {'Key': 'public/a.txt'}),
      );

      final response = await client.from('public').upload('a.txt', file);
      expect(response, isA<String>());
      expect(response.endsWith('/a.txt'), isTrue);
    });

    test('should update file', () async {
      final file = File('a.txt');
      file.writeAsStringSync('Updated content');

      when(
        () => fetch.putFile(
          '$objectUrl/public/a.txt',
          file,
          mockFileOptions,
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => Future.value(const {'Key': 'public/a.txt'}),
      );

      final response = await client.from('public').update('a.txt', file);
      expect(response, isA<String>());
      expect(response.endsWith('/a.txt'), isTrue);
    });

    test('should move file', () async {
      const requestBody = {
        'bucketId': 'public',
        'sourceKey': 'a.txt',
        'destinationKey': 'b.txt',
      };
      when(
        () => fetch.post(
          '$objectUrl/move',
          requestBody,
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => Future.value(const {'message': 'Move'}),
      );

      final response = await client.from('public').move('a.txt', 'b.txt');

      expect(response, 'Move');
    });

    test('should createSignedUrl file', () async {
      when(
        () => fetch.post(
          '$objectUrl/sign/public/b.txt',
          {'expiresIn': 60},
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => Future.value(const {'signedURL': 'url'}),
      );

      final response = await client.from('public').createSignedUrl('b.txt', 60);

      expect(response, isA<String>());
    });

    test('should list files', () async {
      when(
        () => fetch.post(
          '$objectUrl/list/public',
          any(),
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => Future.value([testFileObjectJson, testFileObjectJson]),
      );

      final response = await client.from('public').list();

      expect(response, isA<List<FileObject>>());
      expect(response.length, 2);
    });

    test('should download file', () async {
      final file = File('a.txt');
      file.writeAsStringSync('Updated content');

      when(
        () => fetch.get(
          '$objectUrl/public/b.txt',
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => file.readAsBytes(),
      );

      final response = await client.from('public').download('b.txt');

      expect(response, isA<Uint8List>());
      expect(String.fromCharCodes(response), 'Updated content');
    });

    test('should get public URL of a path', () {
      final response = client.from('files').getPublicUrl('b.txt');

      expect(response, '$objectUrl/public/files/b.txt');
    });

    test('should remove file', () async {
      final requestBody = {
        'prefixes': ['a.txt', 'b.txt']
      };
      when(
        () => fetch.delete(
          '$objectUrl/public',
          requestBody,
          options: mockFetchOptions,
        ),
      ).thenAnswer(
        (_) => Future.value([testFileObjectJson, testFileObjectJson]),
      );

      final response = await client.from('public').remove(['a.txt', 'b.txt']);

      expect(response, isA<List>());
      expect(response.length, 2);
    });
  });

  group('header', () {
    test('X-Client-Info header is set', () {
      client = SupabaseStorageClient(
        '$supabaseUrl/storage/v1',
        {
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      expect(client.headers['X-Client-Info']!.split('/').first, 'storage-dart');
    });

    test('X-Client-Info header can be overridden', () {
      client = SupabaseStorageClient('$supabaseUrl/storage/v1', {
        'Authorization': 'Bearer $supabaseKey',
        'X-Client-Info': 'supabase-dart/0.0.0'
      });

      expect(client.headers['X-Client-Info'], 'supabase-dart/0.0.0');
    });
  });
}
