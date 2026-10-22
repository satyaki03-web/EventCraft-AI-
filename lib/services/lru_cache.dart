import 'dart:collection';

/// Memory LRU Cache for caching identical AI request outputs.
class LruCache<K, V> {
  final int capacity;
  final _map = LinkedHashMap<K, V>();

  LruCache({this.capacity = 20});

  V? get(K key) {
    if (!_map.containsKey(key)) return null;
    final value = _map.remove(key)!;
    _map[key] = value; // move to most recent position
    return value;
  }

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    } else if (_map.length >= capacity) {
      _map.remove(_map.keys.first); // remove least recently used
    }
    _map[key] = value;
  }

  bool containsKey(K key) => _map.containsKey(key);

  void clear() => _map.clear();

  int get length => _map.length;
}
