Zenoss 4.X Daemons & Debugging
==================================================================

Zenoss Core has lot of daemons that can be used for various purpose.

While you might not use all of the daemons in your Zenoss environment,
it is still essential for you to understand all available zenoss
daemons, which you can use to solve a specific enterprise monitoring
requirement.

| In Zenoss v4 all daemons interact with Mysql and zenhub. By default
| all the zenoss daemons run in info mode.


1. zeneventserver
~~~~~~~~~~~~~~~~~
In Zenoss 3.X the event processing was managed by zenhub daemon
because of that there was bottleneck in event processing which has
caused some performance related issues, so to avoid that in Zenoss 4.x
they have introduced new daemon zeneventserver.

zeneventserver daemon which is written in java, interact with Rabbitmq
and fetch the events from zenevents
queue[zenoss.queues.zep.zenevents]and insert into the events tables that
are in zenoss\_zep database where the events are getting stored.

Another responsibility of this daemon is to fetch the event related
information like [resource, summary, last seen, first seen, severity
etc.], in Java Script Object Notation [JSON] format so that it get
displayed in zenoss UI also moves the event to zenoss
zenoss.queues.zep.signal queue. Zenpack installation is taken care by
this daemon. [Event Class creation while installing zenpack]

::

    cat /opt/zenoss/etc/zeneventserver.conf [config file of zeneventserver]
    zep.jdbc.dbname=zenoss_zep
    zep.jdbc.hostname=localhost
    zep.jdbc.port=13306
    zep.jdbc.password=xxxxxx
    zep.jdbc.username=xxxxxx

Note: if we stop zeneventserver daemon and check rabbitmq queues by the
command [rabbitmqctl -p /zenoss list\_queues], we could see value of
queue zenoss.queues.zep.zenevents gets increasing.

::

    # zeneventserver stop [Need to run as zenoss user]

    # rabbitmqctl -p /zenoss list_queues
    Listing queues ...
    celery  0
    zenoss.queues.zep.migrated.summary      0
    zenoss.queues.zep.migrated.archive      0
    zenoss.queues.zep.rawevents     0
    zenoss.queues.zep.heartbeats    0
    zenoss.queues.zep.zenevents     12
    zenoss.queues.zep.modelchange   0
    zenoss.queues.zep.signal        0
    ...done.

Once we start zeneventserver we can see the queue count get back to ‘0’
[Zero]

2. zenhub
~~~~~~~~~
zenhub daemon is written in python. Event processing gets triggered when
zenhub daemon gets data from other daemons. In paid version zenoss has
included invalidation worker process for better performance. In
distributed zenoss architecture we normally deploy a Linux VM which
runs a dedicated zenhub daemon only. It’s the single point of failure of
events getting displayed in zenoss.

3. zenping
~~~~~~~~~~
zenping daemon does normal ping on interface and the polling interval is
one-minute. If the interface is down zenoss generate an alert with
critical severity. If the interface comes up zenoss automatically clears
the error event with a clear message. zenping has ability to get data
point for ping monitoring and can be used to generate availability
graphs for the monitored device [Feature in Zenoss4]. The following runs
this daemon in debug mode against a device, and used mainly for
debugging.

::

    zenping –d 3.14.1.59 –v10

.. warning::

   If your device doesn't allow ping connections, your modeler and collector
   may not work. To circumvent this, set **zPingMonitorIgnore** to False.

4. zeneventd
~~~~~~~~~~~~
The zeneventd daemon's major role is to apply **event transforms** (Python code
that manipulates events). This daemon fetches incoming events from
zenoss.queues.zep.rawevents queue and applies transform and necessary device
context such as Device group/Device State [Production/Development] and some
event related information such as [last seen, first seen] time of event. If the
daemon stops running, we could see size of rawevents queue getting increased.
We can debug execution of transform code by putting log.info(‘For Debug’)
statement inside the code which will be printed in
‘/opt/zenoss/log/zeneventd.log’

::

    # zeneventd stop 

    # rabbitmqctl -p /zenoss list_queues
    Listing queues ...
    celery  0
    zenoss.queues.zep.migrated.summary      0
    zenoss.queues.zep.migrated.archive      0
    zenoss.queues.zep.rawevents            10
    zenoss.queues.zep.heartbeats            0
    zenoss.queues.zep.zenevents             0
    zenoss.queues.zep.modelchange           0
    zenoss.queues.zep.signal                0
    ...done.

    # zeneventd run –d 3.14.1.59 –v10 

If you have code that is run as a result of an event transform, place your 
**pdb.set_trace** in that code, and run zeneventd in the foreground to catch it.

5. zensyslog
~~~~~~~~~~~~
zensyslog daemon process syslog messages [/var/log/messages] that are
received from monitored device on to zenoss on port UDP/514.

6. zenprocess
~~~~~~~~~~~~~
| zenprocess daemon, process monitoring capability is integrated to
| zenoss by using HOST-RESOURCES MIB which get loaded into zenoss as part
| of default installation. zenprocess uses SNMP table and get process
| information like PID, path to the binary that is being executed and
| number of running instances.

|  Etc. zenprocess daemon default polling interval is 3 min [180
| seconds]. Not possible to customize the polling interval per device
| level. The following runs this daemon in debug mode against a single device.

::

    zenprocess run –d 3.14.1.59 –v10

7. zenstatus
~~~~~~~~~~~~
zenstatus daemon monitors TCP/UDP services that are available on the
device such as [http/https/net-bios/].

8. zentrap
~~~~~~~~~~
zentrap daemon process the incoming traps that are send from hardware on
port UDP/162. The daemon decodes the incoming trap to a format that is
understandable by zenoss [Python dictionary format] and handover to
zeneventd for further processing and to generate events.

9. zenactiond
~~~~~~~~~~~~~
zenactiond daemon the daemon interact with signal queue in Rabbitmq and
trigger notification via Email/Paging/etc. Signal queue get piled up if
this daemon stops running.

::

    # rabbitmqctl -p /zenoss list_queues
    Listing queues ...
    celery  0
    zenoss.queues.zep.migrated.summary      0
    zenoss.queues.zep.migrated.archive      0
    zenoss.queues.zep.rawevents     0
    zenoss.queues.zep.heartbeats    0
    zenoss.queues.zep.zenevents     0
    zenoss.queues.zep.modelchange   0
    zenoss.queues.zep.signal        5
    ...done.

    # zenactiond start

10. zenperfsnmp
~~~~~~~~~~~~~~~
zenperfsnmp daemon collects performance metrics such as CPU, Memory,
File system Usage via snmpwalk and store the information in RRD [Round
Robin Database] files, the data collection interval is 300 sec by
default. The poll time interval is not customizable per device level, if
we change it, it get reflected globally. The following runs this daemon
in debug mode against a single device.

::

    zenperfsnmp run –d 3.14.1.59 –v10 

11. zencommand
~~~~~~~~~~~~~~
zencommand is responsible for running routine collection for devices not
using snmp style collection. It collects every *cycletime* which is set in 
the UI in "Cycle Time" field for the datasource.

zencommand daemon is capable of running custom scripts against the
device over ssh, SQL, and other protocols to achieve this ssh username/password
need to be configured in zenoss for each monitored device, which is hard if we
are monitoring a huge DC. So performance monitoring is done by configuring
net-snmp on client device.

::

    zencommand run –d 3.14.1.59 –v10

Debugging
+++++++++

Put your pdb.set_trace() in the collect() or onSucess() methods before running
zencommand as above.

12. zenmodeler
~~~~~~~~~~~~~~
zenmodeler daemon gets initial device information such as
interfaces/filesystem/ipservices etc. It collects structural and topological
data as well. The daemon polling interval is 12hrs by default. It mainly
detects configuration changes that happen on device eg: Additional interface
gets added, new partition etc.

::

   zenmodeller run –d 3.14.1.59 –v10

13. zenrrdcached
~~~~~~~~~~~~~~~~
zenrrdcached daemon is a performance enhancer, helps to cache RRD
metrics in the memory, which is used to generate graphs in zenoss. If
the daemon fails to fetch the metrics from the memory it will get the
metrics from rrd files that is stored in the file system.

14. zopectl
~~~~~~~~~~~
zopectl daemon is call zopeclient, used while developing zenpack. To
reflect the code change that we make during zenpack development this
daemon need to be restarted.

::

   zopectl restart

To run it in the foreground for debugging::

   zopectl fg

15. zenjobs
~~~~~~~~~~~
zenjobs daemon run background tasks like discovering network or adding
device these tasks gets added to queue and zenjobs process them. Once a
device gets added successfully [Discovered] modeling happens with the
help of zenmodeler daemon and returns a job ID. If we want to add
devices in a bulk we use zenbatchload command utility.

16. zenrdis
~~~~~~~~~~~
zenrdis daemon is used to collect distributed ping-tree data from
collector to build a complete map.

In zenoss each daemon has a config file that is located in
/opt/zenoss/etc/ directory. By default all daemons are in info mode.
There are two ways to enable debug mode for daemons.

#. Edit config file for daemon change logseverity 10
#. daemon name debug Eg: zeneventd debug [toggle daemon between Info and
   Debug mode]

By listing Rabbitmq queue one can easily determine whether zenoss is
working without any problem or not. If we find any events that get
struck in any of the queue, restart the corresponding daemon that is
responsible for fetching events.

17. zenpython
~~~~~~~~~~~~~~

zenpython is part of the ZenPacks.zenoss.PythonCollector zenpack that allows
data collection of standard COMMAND data source type's functionality without
requiring a new shell and shell subprocess to be spawned each time the data
source is collected. This allows a *pure* python method to collect data
(and to pass python structures) and debug. You can run it in the background
or in the foreground ::

   zenpython run -v10 --device=target.example.com

Debugging
++++++++++

Place your pdb.set_trace() inside your datasource's collect() or onSuccess()
methods and run the above forground command.



