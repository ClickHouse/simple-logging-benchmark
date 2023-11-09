## Compression results

The following shows the results for compression rates.

## Simple schema

This represents a naive unoptimized schema. Further optimizations are possible (see below) which improve compression rates by 5% in our tests. However, the above represents a getting started experience for a new user. We therefore test with the least favorable configuration. 


```sql
CREATE TABLE logs
(
  `remote_addr` String,
  `remote_user` String,
  `runtime` UInt64,
  `time_local` DateTime,
  `request_type` String,
  `request_path` String,
  `request_protocol` String,
  `status` UInt64,
  `size` UInt64,
  `referer` String,
  `user_agent` String
)
ENGINE = MergeTree
ORDER BY (toStartOfHour(time_local), status, request_path, remote_addr)
```

```sql
SELECT
	table,
	formatReadableQuantity(sum(rows)) AS total_rows,
	formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
	formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size,
	round(sum(data_uncompressed_bytes) / sum(data_compressed_bytes), 2) AS ratio
FROM system.parts
WHERE (table LIKE 'logs%') AND active
GROUP BY table
ORDER BY sum(rows) ASC

┌─table─────┬─total_rows─────┬─compressed_size─┬─uncompressed_size─┬─ratio─┐
│ logs_66   │ 66.75 million  │ 1.27 GiB    	   │ 18.98 GiB     	   │ 14.93 │
│ logs_133  │ 133.49 million │ 2.67 GiB    	   │ 37.96 GiB     	   │ 14.21 │
│ logs_267  │ 266.99 million │ 5.42 GiB    	   │ 75.92 GiB     	   │	14 │
│ logs_534  │ 533.98 million │ 10.68 GiB   	   │ 151.84 GiB    	   │ 14.22 │
│ logs_1068 │ 1.07 billion   │ 20.73 GiB   	   │ 303.67 GiB    	   │ 14.65 │
│ logs_5340 │ 5.34 billion   │ 93.24 GiB   	   │ 1.48 TiB      	   │ 16.28 │
└───────────┴────────────────┴─────────────────┴───────────────────┴───────┘
```

## More optimized schema

We are more specific with our types below. This reduces the compressed size by around 5%. Compression ratios are reduced as a result of the uncompressed size being reduced (due to lower precision types) - this lowers memory consumption.

```sql
CREATE TABLE logs
(
    `remote_addr` IPv4,
    `remote_user` LowCardinality(String),
    `runtime` UInt16,
    `time_local` DateTime,
    `request_type` LowCardinality(String),
    `request_path` String,
    `request_protocol` LowCardinality(String),
    `status` UInt16,
    `size` UInt32,
    `referer` String,
    `user_agent` String
)
ENGINE = MergeTree
ORDER BY (toStartOfHour(time_local), status, request_path, remote_addr)
```


```sql
SELECT
    table,
    formatReadableQuantity(sum(rows)) AS total_rows,
    formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size,
    round(sum(data_uncompressed_bytes) / sum(data_compressed_bytes), 2) AS ratio
FROM system.parts
WHERE (table LIKE 'logs%') AND active
GROUP BY table
ORDER BY sum(rows) ASC

┌─table─────┬─total_rows──────┬─compressed_size─┬─uncompressed_size─┬─ratio─┐
│ logs_66   │ 66.75 million   │ 1.21 GiB        │ 16.64 GiB         │ 13.76 │
│ logs_133  │ 133.49 million  │ 2.53 GiB        │ 33.27 GiB         │ 13.14 │
│ logs_267  │ 266.99 million  │ 5.12 GiB        │ 66.55 GiB         │    13 │

Coming soon...
```

Note further optimizations may be possible with [codecs](https://clickhouse.com/blog/optimize-clickhouse-codecs-compression-schema). Contributions welcome.
