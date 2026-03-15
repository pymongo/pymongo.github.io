# [Sampled LRU](/2026/02/sampled_lru.md)

In a traditional, strict LRU every time you read an item, you have to lock the list, remove the item from its current position, and move it to the "most recently used" end of the list. In a highly concurrent locking and pointer-updating on every single read would destroy performance

To solve this, modern high-performance caches (like Redis, and Solana's accounts-db) use **Sampled LRU** (or **Pseudo-LRU**)

The cache is just a standard concurrent hash map (DashMap)

**Eviction time**: When the cache gets too big and needs to evict an item, it doesn't know which item is the absolute oldest because there is no sorted list. Instead of scanning millions of accounts to find the oldest one, it uses the RNG to pick a random sample of N items from the cache

- non-cryptographic but faster: rand::small_rng::SmallRng, rustc_hash,ahash
- slower: rand::thread_rng, std::hash

