
# Kicking off an aggregation job

has three steps:

1. Make sure that Analytics is running.

2. reset yesterday's aggregation status ('reporting' database):
    ```sql
    update meta_agg_daily
    set status = 'UNRUN'
    where date_key = to_days(now()) - 1;
   ```
    If you don't have a record, you can insert one:

    ```sql
    insert into meta_agg_daily (date_key)
    values (to_days(now()) - 1);
    ```

3. Kick off the aggregation job ('reporting' database):

    ```sql
    update QRTZ_TRIGGERS
    set next_run_time = now()
    where trigger_name = "AggregateDataTrigger";
    ```
    
Assumptions:
* There are raw_v2_* tables containing yesterday's data.
* The are no records in meta_batch where batch_status is not COMPLETED or FAILED with a timestamp less than today.  The aggregation won't run if it finds incomplete batches.
