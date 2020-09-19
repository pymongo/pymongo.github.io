# Programming Rust Ch19: Concurrency

## Atomics

短语: Suffice it to say(使其满足)

上下文: Suffice it to say that multiple threads can read and write an atomic value at once without causing data races.

单词: arithmetic(算术运算)

上下文: Instead of the usual arithmetic and logical operators, atomic types expose methods that perform atomic operations.

## 如何理解Memory Ordering

!> Memory Orderings are something like transaction isolation levels in a database.

单词: crucial(至关重要的)

CREATE TABLE IF NOT EXISTS vip(id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,maker_fee DECIMAL(7,6) NOT NULL DEFAULT '0.001',taker_fee DECIMAL(7,6) NOT NULL DEFAULT '0.001');

上下文: Memory Orderings are crucial to program correctness.

