Kicking off Quick Aggregation Jobs
================================================

Assumptions:
--------------

* There are raw_v2_* tables containing yesterday's data.
* The are no records in meta_batch where batch_status is not COMPLETED or
  FAILED with a timestamp less than today.  The aggregation won't run if it
  finds incomplete batches.

Database Adjustment to Start Aggregation
-----------------------------------------

This involves 3 database-modifying steps:

1. Make sure that Analytics is running.
2. reset yesterday's aggregation status ('reporting' database)::

    update meta_agg_daily
    set status = 'UNRUN'
    where date_key = to_days(now()) - 1;

 - If you don't have a record, you can insert one::

    insert into meta_agg_daily (date_key)
    values (to_days(now()) - 1);

3. Kick off the aggregation job ('reporting' database)::

    update QRTZ_TRIGGERS
    set next_run_time = now()
    where trigger_name = "AggregateDataTrigger";



Using the Tools from ZenPacks.zenoss.psSelfMonitoring
-------------------------------------------------------

* Clone the repo from https://github.com/zenoss/ZenPacks.zenoss.psSelfMonitoring
* On the Analytics server, copy the files as zenoss user::

   cp ZenPacks.zenoss.psSelfMonitoring/scripts/* /opt/zenoss-analytics/bin

Once the files are in place you can use them. Of note are::

* set_analytics_env.sh
  This one sets up all the DB settings for other scripts. Its worth looking at.

* start_model_load_now.sh
  If you haven't yet loaded your model onto the server, this will expedite.
  Sets triggering to 10 minutes in the future.

* start_aggregation_now.sh
  If you are ready to aggregate and have setup batch jobs for it, this will
  speed up that process by setting the trigger time to 10 minutes.

* remove_extractor.sh
  This one can remove some of your unwanted batches

The others we list without comment:

* show_aggregation_detail.sh
* show_aggregation_config.sh
* show_aggregation_highlevel.sh
* show_analytics_task_status.sh
* show_batch_status.sh
* show_processlist.sh
* show_queries.sh
* show_settings.sh
* monitor_aggregation_counts.sh
* monitor_analytics_counts.sh
* monitor_db_connection_counts.sh
* monitor_etl_batch_states.sh
* monitor_etl_performance.sh
* remove_metric.sh
* remove_zenoss_instance.sh
* retry_batch.sh

