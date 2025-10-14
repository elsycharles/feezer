/// Generic LRU (Least Recently Used) cache implementation
/// Provides efficient caching with automatic eviction of least recently used items
class LRUCache<K, V> {
  final int capacity;
  final _cache = <K, V>{};

  LRUCache(this.capacity);

  /// Get a value from the cache and move it to the most recently used position
  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  /// Put a value in the cache, evicting the least recently used item if capacity is exceeded
  void put(K key, V value) {
    _cache.remove(key);
    _cache[key] = value;
    if (_cache.length > capacity) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Clear all items from the cache
  void clear() => _cache.clear();

  /// Get the current number of items in the cache
  int get length => _cache.length;

  /// Check if the cache contains a key
  bool containsKey(K key) => _cache.containsKey(key);
}