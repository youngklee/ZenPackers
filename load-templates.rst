=====================
Load-Templates Script
=====================

This script is designed to take a yaml file as an input on the
commandline and update a live instance of Zenoss.

Seee this link first:
http://docs.zenosslabs.com/en/latest/zenpack_development/monitoring_http_api/using_yaml_templates.html

Note: load-templates requires PyYAML_ to be installed.

The commandline accepts a single argument, the filename:

     python load-templates.py template_definition_file.yaml

.. _PyYAML: http://pypi.python.org/pypi/PyYAML

The YAML formatting can be inferred from the zenoss doc for performance
monitoring  Doc-9385_

.. _Doc-9385: http://community.zenoss.org/docs/DOC-9385

yaml formatting: headers
------------------------
The formatting section headers are the paths to the ZenPack.  For
example, Cisco lives under /Devices/Network, but CiscoUCS exists
under /Devices.

The CiscoUCS heading might be::

    /CiscoUCS:

The Cisco heading might be::

    /Network/Cisco:

For a new hypothetical SpecialExample device that lives under
/Devices/Network, the Yaml heading might be::

    /Network/SpecialExample:

In addition, each of the components and subcomponents may also have a
heading.  SpecialExample has three components:  Server, Client and
Services. The headings for each of these components would look something
like the following::

    /NetworkSpecialExample/SpecialExampleServer:
    /NetworkSpecialExample/SpecialExampleClient:
    /NetworkSpecialExample/SpecialExampleServices:


yaml formatting: sections
-------------------------
Each section may contain three sub-sections:  datasources, thresholds
and graphs.

Datasources:
++++++++++++

The *datasources* sub-section contains configuration necessary to
capture datapoints.

The *datasources* has a named source with several attributes associated
with that source::

    ...
    /*header/path*:
        ...
        datasources:
          *name_of_source*:
              type: datasource_type_
              *attributes_associated_with_type01*:  *attribute_value*
              *attributes_associated_with_type02*:  *attribute_value*
              ...
              datapoints:
                *name_of_source*: source_type_
                *another_name*:
                  type:  source_type_
                  rrdmin:  *value*
                  rrdmax:  *value*
                  aliases:
                    *alias*: *value*
        ...

The hypothetical /Network/SpecialExample has an SNMP datasource, a
command datasource and a JMX datasource::

    /Network/SpecialExample:
        datasources:
          hrMemoryUsed:
            type: SNMP
            oid: "1.3.6.1.2.1.25.2.3.1.6"
            datapoints:
              hrMemoryUsed: GAUGE_MIN_0

          hrProcessorLoad:
            type: SNMP
            oid: "1.3.6.1.2.1.25.3.3.1.2.1"
            datapoints:
              hrProcessorLoad: GAUGE_MIN_0

          specialExampleCommand:
            datasources:
              echo:
                type: COMMAND
                commandTemplate: 'echo "OK|val1=123 val2=987.6'
                parser: Nagios
                severity: info
                cycletime: 10
                datapoints:
                  val1:
                    rrdmin: 0
                    aliases:
                      value1: "100,/"
                  val2: DERIVE_MIN_0

          heapMemoryUsage:
            type: JMX
            jmxPort: "12345"
            authenticate: True
            objectName: "java.lang:type=Memory"
            attributeName: "HeapMemoryUsage"
            datapoints:
              committed: GAUGE_MIN_0
              used: GAUGE_MIN_0

          nonHeapMemoryUsage:
            type: JMX
            jmxPort: "12345"
            authenticate: True
            objectName: "java.lang:type=Memory"
            attributeName: "NonHeapMemoryUsage"
            datapoints:
              committed: GAUGE_MIN_0
              used: GAUGE_MIN_0

.. _datasource_type:

- *SNMP*:
- *COMMAND*:
- *JMX*:

.. _source_type:

RRD types:
++++++++++

- *COUNTER* - Saves the rate of change of the value over a step period.
  This assumes that the value is always increasing (the difference between
  the current and the previous value is greater than 0). Traffic counters
  on a router are an ideal candidate for using COUNTER.

- *GAUGE* - Does not save the rate of change, but saves the actual
  value. There are no divisions or calculations. To see memory consumption
  in a server, for example, you might want to select this value. ::
  
    **NOTE**
    Rather than COUNTER, you may want to define a data point using
    DERIVED and with a minimum of zero. This creates the same conditions
    as COUNTER, with one exception. Because COUNTER is a "smart" data
    type, it can wrap the data when a maximum number of values is
    reached in the system. An issue can occur when there is a loss of
    reporting and the system (when looking at COUNTER values) thinks
    it should wrap the data. This creates an artificial spike in the
    system and creates statistical anomalies.

- *DERIVE* - Same as COUNTER, but additionally allows negative values.
  If you want to see the rate of change in free disk space on your server,
  for example, then you might want to select this value.
  
- *ABSOLUTE* - Saves the rate of change, but assumes that the previous
  value is set to 0. The difference between the current and the previous
  value is always equal to the current value. Thus, ABSOLUTE stores the
  current value, divided by the step interval.

RRD suffixes:
+++++++++++++

In addition, suffixes can be added to reduce YAML:

- _MIN_*value* - sets rrdmin to *value*
- _MAX_*value* - sets rrdmax to *value*

Examples:
+++++++++

- *GAUGE_MIN_0_MAX_100* - sets the rrd type to gauge; rrd minimum to 0
  and the rrd maximum to 100
- *DERIVE_MAX_10* - sets the rrd type to derive; rrd maximum to 10


Thresholds:
-----------
- The *thresholds* sub-section contains configuration necessary to
  capture thresholds with relation to the datasources datapoints.

**Note**::

 *Make sure that the threshold is really needed.  Too many
 extra events may be overwhelming to a user.*

The general format for the *thresholds* is as follows::

    ...
    /*header/path*:
        ...
        thresholds:
          *human friendly name*:
            type: threshold_type_
            dsnames: ["*datasource_name*_*datapoint_name*"]
            *attributes_associated_with_type01*:  *attribute_value*
            *attributes_associated_with_type02*:  *attribute_value*
            ...

The hypothetical /Network/SpecialExample has an SNMP threshold, and a
Command threshold.  The SNMP threshold looks for a processor load of
greater than 95%.  The Command threshold looks for a value greater than
99. ::

    /Network/SpecialExample:
        datasources:
          ...

        thresholds:
          high load:
            type: MinMaxThreshold
            dsnames: ["hrProcessorLoad_hrProcessorLoad"]
            maxval: "95"

          high values:
            type: MinMaxThreshold
            dsnames: ["ds1_val1", "ds1_val2"]
            maxval: "99"

.. _threshold_type:
Standard Types:

- MinMaxThreshold -
- ValueChangeThreshold -
- CiscoStatus -
- HoltWintersFailure -

Graphs:
-------
- The *graphs* sub-section contains the configuration necessary to
  capture graphs with relation to the thresholds and datasources
  datapoints::

    ...
    /*header/path*:
        ...
        graphs:
          *human friendly graph title*:
            units: "human friendly units"
            miny: *y-axis minimum value*
            maxy: *y-axis maximum value*
            graphpoints:
              *human friendly datapoint name*:
                dpName: "*datasource*_*datapoint*"
                format: rrd_graph_type_format_
                rpn: *reverse_polish_notation*

The /Network/SpecialExample device has several graphs that need to be
displayed.  More specifically, the Server components utilize the SNMP,
the clients utilize JMX and the Services require a Command. ::

    /Network/SpecialExample/SpecialExampleServer:
        graphs:
          CPU Utilization:
            units: "percent"
            miny: 0
            maxy: 100
            graphpoints:
              Used:
                dpName: "hrProcessorLoad_hrProcessorLoad"
                format: "%4.0lf%%"
          Memory Utilization:
            units: "percent"
            miny: 0
            maxy: 100
            graphpoints:
              Used:
                dpName: "hrMemoryUsed_hrMemoryUsed"
                format: "%7.2lf%%"
                rpn: "1024,*,${here/hw/totalMemory},/,100,*"

    /Network/SpecialExample/SpecialExampleClient:
        graphs:
          Values:
            units: number
            miny: 0
            graphpoints:
              Value 1:
                dpName: "ds1_val1"
                format: "%7.2lf%s"
              Value 2:
                dpName: "ds1_val2"
                format: "%7.2lf%s"

    /Network/SpecialExample/SpecialExampleService:
          JVM Memory Usage:
            units: bytes
            base: true
            miny: 0
            graphpoints:
              Heap Committed:
                dpName: heapMemoryUsage_committed
              Heap Used:
                dpName: heapMemoryUsage_used
              NonHeap Committed:
                dpName: nonHeapMemoryUsage_committed
              NonHeap Used:
                dpName: nonHeapMemoryUsage_used

.. _rrd_graph_type_format:

Stolen from: http://oss.oetiker.ch/rrdtool/doc/rrdgraph_graph.en.html
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


   **%%**
   Just prints a literal '%' character


   **%#.#le**
   Prints numbers like 1.2346e+04. The optional integers # denote field width
   and decimal precision.

   **%#.#lf**
   Prints numbers like 12345.6789, with optional field width and precision.

   **%s**
   Place this after %le, %lf or %lg. This will be replaced by the appropriate
   SI magnitude unit and the value will be scaled accordingly (123456 -> 123.456 k).

   **%S**
   is similar to %s. It does, however, use a previously defined magnitude unit.
   If there is no such unit yet, it tries to define one (just like %s) unless
   the value is zero, in which case the magnitude unit stays undefined. Thus,
   formatter strings using %S and no %s will all use the same magnitude unit
   except for zero values.

   If you PRINT a VDEF value, you can also print the time associated with it by
   appending the string :strftime to the format. Note that RRDtool uses the
   strftime function of your OSs C library. This means that the conversion
   specifier may vary. Check the manual page if you are uncertain. The
   following is a list of conversion specifiers usually supported across the
   board.

   **%a**
   The abbreviated weekday name according to the current locale.

   **%A**
   The full weekday name according to the current locale.

   **%b**
   The abbreviated month name according to the current locale.

   **%B**
   The full month name according to the current locale.

   **%c**
   The preferred date and time representation for the current locale.

   **%d**
   The day of the month as a decimal number (range 01 to 31).

   **%H**
   The hour as a decimal number using a 24-hour clock (range 00 to 23).

   **%I**
   The hour as a decimal number using a 12-hour clock (range 01 to 12).

   **%j**
   The day of the year as a decimal number (range 001 to 366).

   **%m**
   The month as a decimal number (range 01 to 12).

   **%M**
   The minute as a decimal number (range 00 to 59).

   **%p**
   Either `AM' or `PM' according to the given time value, or the corresponding
   strings for the current locale. Noon is treated as `pm' and midnight as
   `am'. Note that in many locales and `pm' notation is unsupported and in such
   cases **%p** will return an empty string.

   **%s**
   The second as a decimal number (range 00 to 61).

   **%S**
   The seconds since the epoch (1.1.1970) (libc dependent non standard!)

   **%U**
   The week number of the current year as a decimal number, range 00 to 53,
   starting with the first Sunday as the first day of week 01. See also **%V** and

   **%V**
   The ISO 8601:1988 week number of the current year as a decimal number, range
   01 to 53, where week 1 is the first week that has at least 4 days in the
   current year, and with Monday as the first day of the week. See also **%U** and

   **%w**
   The day of the week as a decimal, range 0 to 6, Sunday being 0. See also **%u**.

   **%W**
   The week number of the current year as a decimal number, range 00 to 53,
   starting with the first Monday as the first day of week 01.

   **%x**
   The preferred date representation for the current locale without the time.

   **%X**
   The preferred time representation for the current locale without the date.

   **%y**
   The year as a decimal number without a century (range 00 to 99).

   **%Y**
   The year as a decimal number including the century.

   **%Z**
   The time zone or name or abbreviation.

   %%
   A literal `%' character.

Events:
-------
- Not Yet Implemented
