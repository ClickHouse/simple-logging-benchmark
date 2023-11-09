# Parallel replicas

This following shows the impact of parallel replicas on performance.

All results assume the use of a ClickHouse Cloud development instance.


### Without parallel replicas


```bash




```


## With parallel replicas

The following settings are required to enable parallel replicas.

```bash
export CLICKHOUSE_SETTINGS="use_hedged_requests = 0, allow_experimental_parallel_reading_from_replicas = 1, max_parallel_replicas = 100, parallel_replicas_single_task_marks_count_multiplier = 2;"
```

Full results are shown beloiw.

```bash


```