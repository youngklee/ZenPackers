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

.. warning:: 
   If you re-model a device or component, if the overall returned configuration
   of those devices/components do not change, ZenHub will *NOT* trigger an
   event to update any device settings. I other words, if you want to re-model
   and test a device/component, you **MUST** remove that device/component from
   Zenoss before attempting any remodel it; otherwise you won't see any
   changes.

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

We talk more in the sections below about this.

Creating Containing Relation Maps from Modeled Data
---------------------------------------------------

Creation of the Relation Maps require several pieces:

* Base class instances must have containing relationships defined
* Modeler must correctly insert the components into the relationships defined.


Base Class Relations Definition
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

Modeler Class Relations Insertion
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

Miscellaneous Debugging
---------------------------

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

* Your ZenPack failed to execute buildRelations() on your device.
* You somehow damaged the relations structure in ZODB.
* The device structure was changed after the ZP was installed, while the old
  relationship map still persists.

You may be able to fix this in **zendmd** by issuing these commands::

   [zenoss:~]: zendmd
   >>> d=find('mp3.zenoss.loc')
   >>> d.buildRelations()
   >>> commit()

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


Miscellaneous Tasks
---------------------

Deleting Components from a Device
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This might be needded if you want to remodel a device and don't have access
to the GUI::

    device = find("device_id")
        for component in device.getDeviceComponents():
            component.getPrimaryParent()._delObject(component.id)commit()

    commit()

