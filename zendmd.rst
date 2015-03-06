==============================================================================
Zendmd Examples
==============================================================================

Zendmd examples, plain and simple. You'll want to see these tips also::

   http://wiki.zenoss.org/Category:ZenDMD

Required: You must be in the **zendmd** interpreter for all these examples.

* Find a device::
     
   device = find('xyz.zenoss.loc')

* Build Relations for a Device::

   d=find('mp3.zenoss.loc')                                                 
   d.buildRelations()                                                       
   commit() 

* Delete a Device::
     
   device = find('xyz.zenoss.loc')                                              
   device.deleteDevice()                                                        
   commit()

* List/Delete Components::

   device = find("mp6.zenoss.loc")                                             
   for component in device.getDeviceComponents():                              
       component.getPrimaryParent()._delObject(component.id)                   
   commit() 

* Print templates for a device::

   devices = dmd.Devices.getSubDevicesGen()
   for d in devices:
       datasource_ids = []
       templates = d.getRRDTemplates()
       for t in templates:
           datasources = t.getRRDDataSources()
           for ds in datasources:
               if ds.id not in datasource_ids:
                   datasource_ids.append(ds.id)
               else:
                   print("Device has duplicate datasource:")
                   print("Device: %s" % d)
                   print("Template: %s" % t)
                   print("Datasource: %s" % ds)

* Delete Local Device Property::

   for d in dmd.Devices.getSubDevices():
       if d.isLocal('zDeviceTemplates'):
           d.deleteZenProperty('zDeviceTemplates')


* Get a Component by Name::

   def getComponentByName(device, component_name):
       cs = device.componentSearch()
       for brain in cs:
           component = brain.getObject()
           if component.name() == component_name:
               return component 

   device = find('mp8.osi')
   comp = getComponentByName(device, 'vm_1')


* Get a Component by ID::

   def getComponentById(device, component_id):
       cs = device.componentSearch()
       for brain in cs:
           component = brain.getObject()
           if component.id == component_id:
               return component 

   device = find('mp8.osi')
   comp = getComponentById(device, 'network-10a893c1-01a6-438a-b231-3d5102cbc639')


