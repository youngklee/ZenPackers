Creating Joins in UI
======================

Component-SubComponent Joins
-----------------------------
You'll want to join your related components in some way.
For each subcomponent, join it to its parent component
This will possibly do the trick:

* dim_oracle_instance.oracle_instance_key -> dim_oracle_table_space.instance_key

Metric-Date Joins
------------------
For each metric in your domain, join its date_key to dim_date.date_key:

* metric.data_key -> dim_data.date_key

Metric-Device Joins
-----------------------------
For each of your metrics you'll want to join them to the right device.
You'll need the dim_device table:

* metric.device_key -> dim_device.device_key 
* metric.data_key -> dim_data.data_key 

Metric-Component Joins
---------------------------------
For each metric in your domain, join it's component key to your component's key:

* instance_metric.component_key -> dim_oracle_instance.oracle_instance_key
* tablespa_metric.component_key -> dim_oracle_tables_space.oracle_instance_key

You may have to check exactly what keys match up: Example::

   SELECT component_key FROM reporting.daily_cache_hit_ratio__pct Ainner join
   reporting.dim_oracle_instance Bwhere A.component_key = B.oracle_instance_key;


