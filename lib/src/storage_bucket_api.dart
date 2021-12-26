import 'fetch.dart';
import 'types.dart';

class StorageBucketApi {
  const StorageBucketApi(this.url, this.headers);

  final String url;
  final Map<String, String> headers;

  /// Retrieves the details of all Storage buckets within an existing product.
  Future<List<Bucket>> listBuckets() async {
    final FetchOptions options = FetchOptions(headers: headers);
    final response = await fetch.get('$url/bucket', options: options);
    final buckets = List<Bucket>.from(
      (response.data as List).cast<Map<String, dynamic>>().map(
            (bucket) => Bucket.fromJson(bucket),
          ),
    );
    return buckets;
  }

  /// Retrieves the details of an existing Storage bucket.
  ///
  /// [id] The unique identifier of the bucket you would like to retrieve.
  Future<Bucket> getBucket(String id) async {
    final FetchOptions options = FetchOptions(headers: headers);
    final response = await fetch.get('$url/bucket/$id', options: options);
    return Bucket.fromJson(response.data as Map<String, dynamic>);
  }

  /// Creates a new Storage bucket
  ///
  /// [id] A unique identifier for the bucket you are creating.
  ///
  /// [bucketOptions] A parameter to optionally make the bucket public.
  Future<String> createBucket(
    String id, [
    BucketOptions bucketOptions = const BucketOptions(public: false),
  ]) async {
    final FetchOptions options = FetchOptions(headers: headers);
    final response = await fetch.post(
      '$url/bucket',
      {'id': id, 'name': id, 'public': bucketOptions.public},
      options: options,
    );
    final bucketId = response.data['name'] as String;
    return bucketId;
  }

  /// Updates a new Storage bucket
  ///
  /// [id] A unique identifier for the bucket you are creating.
  ///
  /// [bucketOptions] A parameter to set the publicity of the bucket.
  Future<String> updateBucket(
    String id,
    BucketOptions bucketOptions,
  ) async {
    final FetchOptions options = FetchOptions(headers: headers);
    final response = await fetch.put(
      '$url/bucket/$id',
      {'id': id, 'public': bucketOptions.public},
      options: options,
    );
    final message = response.data['message'] as String;
    return message;
  }

  /// Removes all objects inside a single bucket.
  ///
  /// [id] The unique identifier of the bucket you would like to empty.
  Future<String?> emptyBucket(String id) async {
    final FetchOptions options = FetchOptions(headers: headers);
    final response =
        await fetch.post('$url/bucket/$id/empty', {}, options: options);
    return response.data['message'] as String?;
  }

  /// Deletes an existing bucket. A bucket can't be deleted with existing
  /// objects inside it. You must first `emptyBucket()` the bucket.
  ///
  /// [id] The unique identifier of the bucket you would like to delete.
  Future<String?> deleteBucket(String id) async {
    final FetchOptions options = FetchOptions(headers: headers);
    final response =
        await fetch.delete('$url/bucket/$id', {}, options: options);
    return response.data['message'] as String?;
  }
}
