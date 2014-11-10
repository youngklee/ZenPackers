==============================================================================
Zendmd Examples
==============================================================================

Description
------------------------------------------------------------------------------

Zendmd examples, plain and simple.
------------------------------------------------------------------------------

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

* Delete Components::

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
