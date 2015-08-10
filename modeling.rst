========================================================================
Modeling for Zenpacks: Selected Topics
========================================================================

Modeling is an integral part of Zenoss. This article explores specific
tasks related to modeling.

Prerequisites
------------------------------------------------------------------------------

* Zenoss ZenPack Developement Guide

We assume that you are familiar with ZenPack developement and Python coding.
We further assume that we work from the base of ZP_DIR.
For NetBotz for example::

  ZP_DIR_TOP=$ZENHOME/ZenPacks/ZenPacks.training.NetBotz
  ZP_DIR=$ZP_DIR_TOP/ZenPacks/training/NetBotz

As you should know, modelers typically live in the folder::

  $ZP_DIR/modeler/plugins/zenoss/MyModeler.py

Models in General
---------------------------------------------------
Making or changing a model in Zenoss means that you are modifying the ZoDB
representation of your model. ZoDB creates a hierarchical model of 

* Containing Relations: 

  Choose this type when the sub-object can't live without its parent.
  Ex: A DB table *MUST* live inside a database. Its stuck inside of the DB.

  Objects and sub-objects are contained within each other.
  When the parent object is removed, its children are too.
  Its hierarchical. Its dangerous! (not really)

* Non-Containing Relations

  You choose this type of relation when an object can be moved or exist without
  its partner relation. Example: A host is associated with a service. But
  the service can be moved, so its not "stuck" to that host.

  Objects are loosely associated with each other. Deletion of one object
  does not force removal of a related object.

Developing Tips
---------------------------------------------------
Given the information above you need to understand a few critical points
of developing. The ZoDB model representation is sensitive to change 
and must be handled carefully. If you damage the ZoDB it may cause many hours
of repair. 

We discuss two major types of model development: Adding and Modifying.

* Adding to a Model

  When you add to a model, new relations are safely inserted into ZoDB.
  This means that you can update the ZoDB model for your device by doing:

  - Make your model changes in the code
  - Insert those changes into Zenoss; Re-install the ZP or similar
  - Restart services: zenjobs, zenhub, zope (all python daemons that talk to zodb) 
  - In zendmd, execute::

       device = find('mydev.xyz')
       device.buildRelations()
       commit()
  - Model your device if required
  - Test
  - Repeat

* Changing a Model

  Changing a model is more serious, because if done improperly, you end up with
  relations on a device that don't exist in the ZP model. This makes ZoDB very
  angry. To make model changes safely, you must do something of this sort:

  - Remove your ZP and associated devices
  - Make your model changes
  - Install the ZP or otherwise install your model to ZoDB
  - Model your device
  - Test
  - Repeat

.. warning:: Changing a model for a ZP that has been deployed to the field should
          be avoided at all costs. Asking thousands of customers to wipe out
          their zenpacks and re-install is a **major** inconvenience to them.

Debugging Tips in General
---------------------------------------------------
* Run the modeler manually like this::

   zenmodeler run  -workers=0 -v10 -d mp3.zenoss.loc |& tee mod.txt

* If you don't get anything modeled at all you can try this:

  - Restart zenhub: it may have given up loading the modeler
  - Rerun the zenmodeler command above and also monitor the zenhub log
    in /opt/zenoss/log/zenhub.log for good measure.

* Restarting Services: If you make any changes to your modeler code,
  you SHOULD restart ZenHub which caches that code at start-time.

.. note:: 
   You **really** need to restart ZenHub because if you don't and your code fails,
   it will raise an error but reference the new code. Thus, it will not show or
   reference the broken (cached) code in the logs. This can be confusing.

Deleting Components from a Device
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. warning:: 
   When you re-model a device or component, if the returned configuration
   of those devices/components do not change, ZenHub will ***NOT*** trigger an
   event to update any device settings. I other words, if you want to re-model
   and test a device/component, you ***MUST*** remove that device/component from
   Zenoss before attempting any remodel it; otherwise you won't see any
   changes.

Often you want to remodel a device and don't have access to the GUI.
In order to remove components via *Zendmd* you can use the following::

    device = find("mp6.zenoss.loc")
    for component in device.getDeviceComponents():
        component.getPrimaryParent()._delObject(component.id)

    commit()

General Introduction
------------------------------------------------------------------------

Modeler classes generally have two methods that are used by the **zenmodeler**
service. They are:

* collect(): This method collects the data in an asychronous way.
  It returns a dict called results
  Its signature is typically::

      @inlineCallbacks
      def collect(self, device, log)
          ....
          returnValue(results)

* process(self, device, results, log):
  This method (asynchronously) takes that results dict uses it to populate
  the device model. It has a signature resembling::

   def process(self, device, results, log):
        '''results comes back from collect via twisted.'''
       for label, data in results.items():
           ... set your class instance values ....
           .........

       ..... create relationmaps between object instances .....
       return relationmaps


Major Concepts of Modeling
---------------------------------------------------
There are two major parts of Modeling that you must always keep in mind:

* Model Definition
  
  - Base classs must define relationships
  - Both Containing and Non-Containing are possible
  - The relationship ***MUST*** be created in both directions
    

* Model Mapping/Creation/Population

  - Modeler must correctly associate the devices and component
  - The maps are created/defined in one direction only!
  - ApplyDataMap() takes care of the bi-directional associations


Model Definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In our example we'll use two classes: Instance and TableSpace from the Oracle
ZP. Instance is a component off of Device.Device, and Tablespace will hang
off of Instance. We need two defining relation:

* In Instance() we need two relations. The first
  binds Instance to Device.Device and the second give us
  multiple TableSpace to Instance::

    # Generic relations (from ZP Generator)
    _relations = ()
     for Klass in Klasses:
         _relations = _relations + getattr(Klass, '_relations', ())

    # These are the ones we need to define:
    _relations = _relations + (
         ('Instance_host',
              ToOne(ToManyCont,
                    'Products.ZenModel.Device.Device',
                    'oracle_instances',)),
         ('oracle_tablespaces',
              ToManyCont(
                  ToOne,
                  'ZenPacks.zenoss.DatabaseMonitor.TablesSpace.TableSpace',
                  'instance',)),
         )

* In TableSpace() we need just one to define Instance -> TablesSpaces::

    # Generic relations (from ZP Generator)
    _relations = ()
    for Klass in Klasses:
        _relations = _relations + getattr(Klass, '_relations', ())

    # This is the one we define.
    _relations = _relations + (
        ('instance', ToOne(ToManyCont,
                           'Products.ZenModel.Instance.Instance',
                           'oracle_tablespaces',
                             ),
        ),)

Model Mapping/Creation/Population
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
We now discuss what is in your modeler (in our example, Instance) class.

In the collect() method in your modeler, we assume you have collected all the
required data and stored in in the results dictionary. How you do that is
fairly general.

In our Instance modeler's process method, we will first create a temporary
storage dictionary called *datamap*, which has Instance as a key and a list
of TableSpace objects as the values. Once this datamap is created and populated,
we then iterate through it to setup the RelationshipMap() structures.

To set this up we first loop through the results data to create the temporary
datamap::

   for connectionString, data in results.items():

       instance1 = data['instance'][0]
       instance_name = instance1.get('INSTANCE_NAME')
       ts_list = data['tablespaces']

       om = self.objectMap()
       om.id = self.prepId('orainst-%s' % instance_name
       om.title = instance_name

       tablespaces = []
       for ts in ts_list:
           tablespaces.append(ObjectMap(data=dict(
               id='{0}_{1}'.format(instance_name, ts['TABLESPACE_NAME'])
               tablespace_name = ts['TABLESPACE_NAME'],
               tablespace_instance = instance1.get('INSTANCE_ROLE'),
               tablespace_maxbytes = ts['BYTES_MAX'],
            )))


       # Add to map: Map the om object to the ts
       datamap[om] = tablespaces

So now you have your datamap setup. Its only used to feed our RelationshipMap.
Notice that in this example we must:

#. Get the list of Instances outside the loop using the dict.keys() for the
   Instance -> Device.Device relation.
#. We need to then loop over the Instances to attache the assiciated TableSpace
   list objects

::

       #------------------------------------------------------------------
       # Now loop over objects to create relation maps.
       #------------------------------------------------------------------

        relmaps = []

        relmaps.append(RelationshipMap(
            relname='oracle_instances',
            modname='ZenPacks.zenoss.DatabaseMonitor.Instance',
            objmaps=datamap.keys()))

        for inst, ts in datamap:
            print type(inst), type(ts)

            relmaps.append(RelationshipMap(
                compname='oracle_instances/{0}'.format(inst.id),
                relname='oracle_tablespaces',
                modname='ZenPacks.zenoss.DatabaseMonitor.TableSpace',
                objmaps=ts))


        log.info('%s: %s instances found', device.id, len(relmaps))
        return relmaps


This is a simple example. To see this how this was implemented see the
ZenPacks.zenoss.DatabaseMonitor's modeler plugin.

To see other examples:

* ZenPacks.zenoss.PostgreSQL (simpler)
* ZenPacks.zenoss.XenServer  (more complex)

Miscellaneous Tasks
---------------------

Deleting a Device 
~~~~~~~~~~~~~~~~~~~~

Open zendmd and remove the device::

   [zenoss@mp4]: zendmd
   device = find('xyz.zenoss.loc')
   device.deleteDevice()
   commit()


Deleting Components from a Device
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This might be needded if you want to remodel a device and don't have access
to the GUI::

    [zenoss@mp4]: zendmd
    device = find("mp6.zenoss.loc")
    for component in device.getDeviceComponents():
        component.getPrimaryParent()._delObject(component.id)
    commit()

Finding Device Components with IInfo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You an find a device's components using the IInfo interface::

    [zenoss@mp4]: zendmd
    device = find("mp6.zenoss.loc")
    from Products.Zuul.interfaces import IInfo
    deviceinfo = IInfo(device)
    deviceinfo
    <ControlCenter Info "mp6.zenoss.loc">
    dir(deviceinfo)


Get Templates and Thresholds
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can to the templates with a Facade::

    tfc=getFacade('template')
    tfc.getTemplates('/zport/dmd/Devices/DB2/devices/xyz.zenoss.loc/hosts/host-5/CP-Host')
    <generator object _getTemplateLeaves at 0x7ddfcd0>

    list = tfc.getTemplates('/zport/dmd/Devices/DB2/devices/xyz.zenoss.loc/hosts/host-5/CP-Host') 
    for i in list:
        print i
    
    <RRDTemplate Info "CP-Host..ControlCenter.devices.mp6.zenoss.loc.mp6.zenoss.loc">

    list = tfc.getThresholds('/zport/dmd/Devices/DB2/devices/xyz.zenoss.loc/hosts/host-5/CP-Host') 
    for i in list:
        print i
 

Miscellaneous Errors and Debugging
-------------------------------------

Error: No Classifier Found, KeyError
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you get an error this this nature::

   2014-02-06 13:59:01,678 DEBUG zen.Classifier: No classifier defined
   2014-02-06 13:59:01,814 ERROR zen.ZenModeler: : Traceback (most recent call last):
     File "/opt/zenoss/Products/ZenHub/PBDaemon.py", line 85, in inner
       return callable(*args, **kw)
     File "/opt/zenoss/Products/ZenHub/services/ModelerService.py", line 132, in remote_applyDataMaps
       result = inner(map)
     File "/opt/zenoss/Products/ZenHub/services/ModelerService.py", line 128, in inner
       return self._do_with_retries(action)
     File "/opt/zenoss/Products/ZenHub/services/ModelerService.py", line 154, in _do_with_retries
       return action()
     File "/opt/zenoss/Products/ZenHub/services/ModelerService.py", line 127, in action
       return bool(adm._applyDataMap(device, map))
     File "/opt/zenoss/lib/python/ZODB/transact.py", line 44, in g
       r = f(*args, **kwargs)
     File "/opt/zenoss/Products/DataCollector/ApplyDataMap.py", line 202, in _applyDataMap
       tobj = device.getObjByPath(datamap.compname)
     File "/opt/zenoss/Products/ZenModel/ZenModelBase.py", line 624, in getObjByPath
       return getObjByPath(self, path)
     File "/opt/zenoss/Products/ZenUtils/Utils.py", line 299, in getObjByPath
       next=obj[name]
     File "/opt/zenoss/lib/python/OFS/ObjectManager.py", line 777, in __getitem__
       raise KeyError, key
   KeyError: 'db2_databases'
   : <no traceback>
   Traceback (most recent call last):
     File "/opt/zenoss/Products/DataCollector/zenmodeler.py", line 693, in processClient
       if driver.next():
     File "/opt/zenoss/Products/ZenUtils/Driver.py", line 63, in result
       raise ex

you probably have a problem where ZODB does not have a relationship map built
to handle your data structure. This can happen if:

* You forgot to restart Zenoss services after installing the ZP, then added a
  device. Such a device won't have your ZP's deviceClass available to it.
* The device structure was changed after the ZP was installed, while the old
  relationship map still persists.
* Your ZenPack failed to execute buildRelations() on your device.
* You somehow damaged the relations structure in ZODB.

You may be able to fix this in **zendmd** by issuing these commands::

   [zenoss:~]: zendmd
   >>> d=find('mp3.zenoss.loc')
   >>> d.buildRelations()
   >>> commit()

Also, sometimes the deviceClass will be wrong/missing for same reasons above.
You can fix this also in **zendmd**::

   d = find('blah')
   d.buildRelations()
   if d.__class__ != d.deviceClass().getPythonDeviceClass():
       d.changeDeviceClass(d.getDeviceClassPath())
   commit()

* Now try to remodel and see if those problems persist

DEBUG zen.Classifier: No classifier defined
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is a remnant of another ZP that never got implemented.
Please ignore this one.


INFO zen.ZenModeler: No change in configuration detected (or similar)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

So you've made changes to your ZP's class structure and have pushed those
changes out. You may have even re-installed the ZP for good measure.
Your modeler seems to be working correctly and gathering data.
But your modeler isn't apply any changes.

If your modeler get this message after modeling, you could be
a victim of ZenDMD Class Mismatch Syndrome (TM). This means that the old
structure is still in place and so none of your changes are being compared
to the new class structure. There are 2 easy ways to fix this:

#. Completely remove and reinstall your ZP, now remodel.
#. Go into ZenDMD and simply load the new class, then remodel

::


   [zenoss@mp4:/home/zenoss]: zendmd
   >>> from ZenPacks.zenoss.ExampleZP import ExampleZP
   >>> ^D
   [zenoss@mp4:/home/zenoss]: zenmodeler run -v10 -d mydev.zenoss.loc


TypeError: unhashable type: 'dict'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You may see and error of the following type::


    2014-07-28 17:02:51,109 ERROR zen.ZenModeler: : Traceback (most recent call last):
    File "/opt/zenoss/Products/ZenHub/PBDaemon.py", line 85, in inner
      return callable(*args, **kw)
    File "/opt/zenoss/Products/ZenHub/services/ModelerService.py", line 132, in remote_applyDataMaps
      result = inner(map)
    File "/opt/zenoss/Products/ZenHub/services/ModelerService.py", line 128, in inner
      return self._do_with_retries(action)
    File "/opt/zenoss/Products/ZenHub/services/ModelerService.py", line 154, in _do_with_retries
      return action()
    File "/opt/zenoss/Products/ZenHub/services/ModelerService.py", line 127, in action
      return bool(adm._applyDataMap(device, map))
    File "/opt/zenoss/lib/python/ZODB/transact.py", line 44, in g
      r = f(*args, **kwargs)
    File "/opt/zenoss/Products/DataCollector/ApplyDataMap.py", line 213, in _applyDataMap
      changed = self._updateRelationship(tobj, datamap)
    File "/zenpacks/ZenPacks.zenoss.PythonCollector/ZenPacks/zenoss/PythonCollector/patches/platform.py", line 36, in _updateRelationship
      return original(self, device, relmap)
    File "/opt/zenoss/Products/DataCollector/ApplyDataMap.py", line 265, in _updateRelationship
      objchange = self._updateObject(obj, objmap)
    File "/opt/zenoss/Products/DataCollector/ApplyDataMap.py", line 378, in _updateObject
      change = not isSameData(value, getter())
    File "/opt/zenoss/Products/DataCollector/ApplyDataMap.py", line 53, in isSameData
      x = set( tuple(sorted(d.items())) for d in x )
    TypeError: unhashable type: 'dict'
    : <no traceback>

The modeler is being passed data that is not a plain dict, string, int, or float. 
In this case it sees a <dict> key of item and it doesn't know how to handle
it. ie: You're trying to use a dict as a key to another dict or in a set.

The data you are passing to the modeler should be a dictionary type or a simple
base type. 

* One way to get around this is to ensure you are passing a dictionary object
  to the modeler. 

* Another way is to serialize and pass in your data (perhaps with JSON).
  Of course you'll have to de-serialize it when you need to use it.


