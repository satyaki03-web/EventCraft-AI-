import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_ai/services/lru_cache.dart';

void main() {
  group('LruCache Tests', () {
    test('Cache evicts least recently used item when capacity is exceeded', () {
      final cache = LruCache<String, int>(capacity: 2);

      cache.put('key1', 100);
      cache.put('key2', 200);

      // Access key1 to make key2 LRU
      expect(cache.get('key1'), equals(100));

      // Put key3, which should evict key2
      cache.put('key3', 300);

      expect(cache.get('key2'), isNull);
      expect(cache.get('key1'), equals(100));
      expect(cache.get('key3'), equals(300));
    });
  });
}
