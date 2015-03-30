Getting Data Out of OpenTSDB
================================

* Attach to one of your OpenTSDB instances

* Idenitfy one of your metrics::

    /opt/opentsdb/build/tsdb uid —config=/opt/zenoss/etc/opentsdb/opentsdb.conf grep ""

* Metrics will be of the form::

    device_name/metric_name

    ex:

    solutions-xenserver/rrd_memoryFree

* Query one of your metrics::

   /opt/opentsdb/build/tsdb query --config=/opt/zenoss/etc/opentsdb/opentsdb.conf 2h-ago sum "solutions-xenserver/rrd_memoryFree"
