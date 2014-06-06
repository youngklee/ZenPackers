=====================================
RRD Topics
=====================================

We use RRD to store monitoring data.
The data is stored in the system root::

  RRD_HOME=/opt/zenoss/perf/Devices

Using RRDtool to Query the Data
--------------------------------

If you want to check or verify data stored in RRD,
simply navigage to $RRD_HOME and look for your data file::

  find . -name "*.rrd"
  find . -name "*my_special_name*"

RRDtool Info
~~~~~~~~~~~~~~~~

Once you find the correct file you can query it with *rrdtool* .
First use the **info** method::

  rrdtool info path/to/my/file.rrd
   
You should get something that looks like the following:

.. literalinclude:: rrdtool_info.txt

RRDtool Dump
~~~~~~~~~~~~~

Now you can dump your data in XML format to see the entire dataset::


  rrdtool dump path/to/my/file.rrd


You should get something that looks like the following:

.. literalinclude:: rrdtool_dump.xml

