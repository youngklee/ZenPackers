Steps to create bundle with create-analytics-bundle scirpt:
-----------------------------------------------------------
https://github.com/zenoss/ZenPacks.zenoss.Microsoft.HyperV/blob/feature/analytics/create-analytics-bundle


#. Setup your aliases in the ZP
#. Install ZenETL, and allow it to run for 24 to 48 hours

  - Ensure that all your tables (including raw_v2_*, hourly_*, daily_* tables)
    are in the reporing database on analytics server. 

#. Setup your labels in each component::

    _properties = BaseComponent._properties + (
    {'id': 'path', 'label': 'Full Path', 'type': 'string', 'mode': ''},
    {'id': 'replication', 'label': 'Replication', 'type': 'string', 'mode': ''},
    {'id': 'did_status', 'label': 'DID status', 'type': 'string', 'mode': ''},
    )

  - See: https://github.com/zenoss/ZenPacks.zenoss.SolarisMonitor/blob/develop/ZenPacks/zenoss/SolarisMonitor/ClusterDID.py#L25

.. note:: Note you must have a device fully modelled and with all the aliases in place to
   get the measures to come out!

#. Check that Analytics server has your tables created
#. Run the create-analytics-bundle
#. Check results

#. You can also simplify creation of aliases.dsv in the Makefile:
   https://github.com/zenoss/ZenPacks.zenoss.CiscoAPIC/blob/develop/GNUmakefile#L29
   https://github.com/zenoss/ZenPacks.zenoss.Microsoft.HyperV/blob/develop/GNUmakefile
   https://github.com/zenoss/ZenPacks.zenoss.Microsoft.HyperV/blob/develop/get_aliases_dsv.xsl

#. After editing, .dsv file could be added to dmd using chkaliases script, and
  from there exported to objects.xml, so you don't have to edit it from UI or
  by hand in XML.
