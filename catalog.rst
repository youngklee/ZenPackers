=====================================
Catalog Tool
=====================================

For fast searching and discovery, Zenoss uses Zope's Catalog Service.
Most catalogs must be created by indexing zProperties, although see the note
later about ComponentBase searches.


Setting Index Properties
----------------------------

In order to put a ZenPack property into the catalog you must set its
*index_type* to field. In ZenPackLib it would be done as follows
(eg: macAddress):

.. code-block:: yaml
   :emphasize-lines: 14-15

   classes: !ZenPackSpec
     DEFAULTS:
       base: [zenpacklib.Component]
     ControlCenter:
       base: [zenpacklib.Device]
       meta_type: ZenossControlCenter
     Host:
       meta_type: ZenossControlCenterHost
       properties:
         ipaddr:
           label: IP Address
         macAddress:
           label: Mac Address
           index_type: field
           index_scope: device

Notice that *index_scope* is set to "device" by default, and is not needed.
It can also be set to global, which will allow it to be searched globally.

When a catalog's scope is set to global, the actual catalog object will be
created on dmd.Devices. The name of the catalog will be the fully-qualified
module name of the class under which the property with index_type and
index_scope are set with a "Search suffix". So let's say you had a ZenPack
named ZenPacks.example.Test that defined a class named Widget. The
catalog would be dmd.Devices.ZenPacks_example_Test_WidgetSearch.


.. Note:: There is a default device-scoped catalog created by any ZenPack that
          uses zenpacklib to create a "Component" class. That's the ComponentBase
          catalog. This catalog does not require any index_type property to be set.

          It's created because the standard componentSearch catalog doesn't have
          an id index, and some of the relationship helper methods require an id
          index to more efficiently find components.

          It's normal to see a ComponentBaseSearch on any device associated with
          a zenpacklib ZenPack.

.. Note:: Removing a ZenPack would remove any associated catalog items.

Examples of Catalog Use
---------------------------

Here is an example of how you use the Catalog:

.. code-block:: python
   :emphasize-lines: 6,14

   ############################################################################
   # Copyright (C) Zenoss, Inc. 2014, all rights reserved.
   ############################################################################

   # Zenoss Imports
   from Products.Zuul.interfaces import ICatalogTool

   # ZenPack Imports
   from ..APIC import APIC

   def cisco_apic_devs(self):
      """Return associated Cisco APIC instances."""

      catalog = ICatalogTool(self.getDmdRoot('Devices'))
      apic_devices = []

      for apic_result in catalog.search(types=[APIC]):
         try:
               apic = apic_result.getObject()
               apic_devices.append(apic)
         except Exception:
               continue

      return apic_devices


Here is a self contained python search:

.. code-block:: python
   :emphasize-lines: 6,14

   #!/usr/bin/env zendmd
   #
   # Print details of all WebTx datasources.

   from Products.Zuul.interfaces import ICatalogTool
   from ZenPacks.zenoss.ZenWebTx.datasources.WebTxDataSource import WebTxDataSource

   catalog = ICatalogTool(dmd.Devices)

   for result in catalog.search(WebTxDataSource):
      datasource = result.getObject()
      template = datasource.rrdTemplate()
      label = "{} - {}".format(template.getUIPath(), datasource.id)
      print "--[ {} ]{}".format(label, "-" * (73 - len(label)))
      print "Initial URL: {}".format(datasource.initialURL)
      print "Initial User: {}".format(datasource.initialUser)
      print "Timeout: {}".format(datasource.webTxTimeout)
      print "Interval: {}".format(datasource.cycletime)

      if datasource.commandTemplate:
         print "Twill Script:"
         print
         print datasource.commandTemplate
      else:
         print "Twill Script: n/a"

      print
                                                                        

Here is class method:

.. code-block:: python
   :emphasize-lines: 2,7

    from zope.event import notify
    from Products.Zuul.interfaces import ICatalogTool

    @classmethod
    def reindex_implementation_components(cls, dmd):
        device_class = dmd.Devices.getOrganizer('/Network/OpenvSwitch')
        results = ICatalogTool(device_class).search(
            ('ZenPacks.zenoss.OpenvSwitch.Port.Port',
             'ZenPacks.zenoss.OpenvSwitch.Interface.Interface',)
        )

        for brain in results:
            obj = brain.getObject()
            obj.index_object()
            notify(IndexingEvent(obj))

Here is a (truncated) class method example from ZenPackLib:

.. code-block:: python
   :emphasize-lines: 2,5,12-15

    def remove(self, app, leaveObjects=False):                                  
        from Products.Zuul.interfaces import ICatalogTool                       
        if not leaveObjects:                                                    
            dc = app.Devices                                                    
            for catalog in self.GLOBAL_CATALOGS:                                
                catObj = getattr(dc, catalog, None)                             
                if catObj:                                                      
                    LOG.info('Removing Catalog %s' % catalog)                   
                    dc._delObject(catalog)

            if self.NEW_COMPONENT_TYPES:
                LOG.info('Removing %s components' % self.id)
                cat = ICatalogTool(app.zport.dmd)
                for brain in cat.search(types=self.NEW_COMPONENT_TYPES):
                    component = brain.getObject()
                    component.getPrimaryParent()._delObject(component.id)

                # Remove our Device relations additions.
                from Products.ZenUtils.Utils import importClass
                for device_module_id in self.NEW_RELATIONS:
                    Device = importClass(device_module_id)
                    Device._relations = tuple([x for x in Device._relations
                                               if x[0] not in self.NEW_RELATIONS[device_module_id]])

                LOG.info('Removing %s relationships from existing devices.' % self.id)
                self._buildDeviceRelations()

References
-----------------

* http://docs.zope.org/zope2/zope2book/SearchingZCatalog.html
* https://pypi.python.org/pypi/Products.AdvancedQuery
* http://community.zenoss.org/docs/DOC-2535 (Removes items from the catalog)
* See AdvancedQuery.html in the doc subfolder.
* http://wiki.zenoss.org/ZenDMD_Tip_-_Refresh_DeviceSearch_Catalog

