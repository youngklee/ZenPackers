Getting Data Out of OpenTSDB
================================

* Attach to one of your OpenTSDB instances::

    serviced service attach reader

* Idenitfy one of your metrics::

    /opt/opentsdb/build/tsdb uid --config /opt/zenoss/etc/opentsdb/opentsdb.conf grep metrics ''

      or from API:

    lynx 'http://mp7:4242/api/suggest?type=metrics&max=1000000'

* Metrics will be of the form::

    device_name/metric_name

    ex:

    solutions-xenserver/rrd_memoryFree

* Query one of your metrics::

   /opt/opentsdb/build/tsdb query --config /opt/zenoss/etc/opentsdb/opentsdb.conf 2h-ago sum "solutions-xenserver/rrd_memoryFree"
