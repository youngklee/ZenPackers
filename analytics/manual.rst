Creating Analytics Bundles Manually
====================================

Create your Aliases
-----------------------------
First create the aliases for each datapoint in your zenpack.
They should conform to the naming convention in: http://goo.gl/WKOUKI

For each subcomponent, join it to its parent component
This will possibly do the trick:

* dim_oracle_instance.oracle_instance_key -> dim_oracle_table_space.instance_key

Configure Analytics in your Zenpack
--------------------------------------
This step requires you to setup the analytics data in the zenpack so that
the metric data can be collected.

**** Stuff goes here

Create the Joins
-----------------------------
Create the required joins between your dataources, metrics, and dimention
tables.

Create the Reports
-----------------------------

Create your reports now 

Save the Bundle
-----------------
Save the data bundle

