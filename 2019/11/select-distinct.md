# [统计有记录的交易对](2019/11_2/select-distinct)

需求：exchanges表里面有30多个交易对，但是很多交易对都没有交易数据，需要**找出有数据的交易对**

```sql
SELECT
  market_id AS '交易对',
  count(volume) AS '交易量'
  count(*) AS '交易笔数'
FROM exchanges GROUP BY market_id;
```

其实还可以用DISTINCT实现

```sql
SELECT DISTINCT market_id
FROM exchanges
WHERE market_id IS NOT NULL;
```

通过DISTINCT同样能找出有数据的交易对
