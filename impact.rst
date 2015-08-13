==============================================================================
Impact Guide (New Style)
==============================================================================

Description
------------------------------------------------------------------------------

Zenoss uses Impact to define the dependency tree (graph) of all devices.
ZenPackLib does a lot of setup for Impact, hiding much of the old-style code.

Prerequisites
------------------------------------------------------------------------------

* Zenoss ZenPack Developement
* Python 2.7
* A ZPL zenpack
* All normal relationships are setup between devices and components

Impact Outline
------------------------------------------------------------------------------

The Basic idea behind Impact is as follows:

* Create a diagram of your impacts, based on device/component relations
* Inside each of your devices/components define the following sections
  which contain a list of relationships that define your impact diagram:

  - impacts
  - impacted_by

* Note: The defining list for (impacts, impacted_by) can also be a function
        that returns a list of objects that belong to your relationship.
        In this case, its common to want a smaller subset of objects because
        the bare relationship has objects that don't affect the impact
        relationship. For example, your device contains many hosts, but only 
        one of those hosts has the API service that your device depends on,
        so you filter out only that one.


An Example
-------------------------------------------------------------------------------

This example uses ControlCenter which has the following devices and components:

* ControlCenter Device (think API)
* Host
* Pool
* Service (definitions of services)
* Running (the actual running service based on a definition)

The ControlCenter devices contains all other components. We focus on the
Host relations for this example. The class relationships look like this::

   class_relationships:
     - ControlCenter 1:MC (controlcenter)Host
     - Pool(poolHosts) 1:M (hostPool)Host
     - Host(hostRuns) 1:M (runHost)Running


Then the impact relations look like this::

   Pool:
     label: CC-Pool
     impacts: [parentPool]
     impacted_by: [poolHosts, childPools]

   Host:
     label: CC-Host
     impacts: [hostPool, hostRuns]
     impacted_by: [containing_linux_device]

   Running:
     label: CC-RunningService
     impacts: [serviceDef]
     impacted_by: [runHost]

Note that containing_linux_device is method that gets impacts from Linux devices
that may be running the (virtual) Host.
See the following code for hints on this functionality::


* ZenPacks.zenoss.ControlCenter/ZenPacks/zenoss/ControlCenter/patches/__init__.py
* ZenPacks.zenoss.ControlCenter/ZenPacks/zenoss/ControlCenter/patches/platform.py
* ZenPacks.zenoss.ControlCenter/ZenPacks/zenoss/ControlCenter/Host.py
* ZenPacks.zenoss.ControlCenter/ZenPacks/zenoss/ControlCenter/configure.zcml

A Second Example
-------------------------------------------------------------------------------

It is also common to have a function that returns just a subset of your full
relationship components. Using the same ZP as an example, 
we have relationships for Service::

   class_relationships:
     - Pool(assignedServices) 1:M (assignedPool)Service
     - Service(serviceRuns) 1:M (serviceDef)Running
     - Service(childServices) 1:M (parentService)Service

and components impact relations::

  Pool:
    label: CC-Pool
    impacts: [parentPool]
    impacted_by: [poolHosts, childPools]

  Service:
    label: CC-Service
    impacts: [parentService]
    impacted_by: [childServices, serviceRuns, getImports]

  Running:
    label: CC-RunningService
    impacts: [serviceDef]
    impacted_by: [runHost]

where getImports() has a signature::

   def getImports(self):
       '''Defines iterable of services that it imports for impact....
           * Input: <Service>self. We use endpoints and services()
           * Output: <list>[service-id] for impact
           * Don't change any of the modeling data.. import it all..
             During modeling, model endpoints on each service...
           * Take what is in endpoints and model it here.. Don't do it in
             modeling because of the auto-diffing mechanisms...
             for service in self.device().services():
       '''

       ... do some work ...
       ... do some more work ...
       ... do alot more work than you want to see ...
       # see ZenPacks.zenoss.ControlCenter/ZenPacks/zenoss/ControlCenter/Service.py

       # Return a list of filtered services unique to this impact.
       return [service(i) for i in _imports]
  
==============================================================================
Impact Rough Guide (Old Style)
==============================================================================

Description
------------------------------------------------------------------------------

Zenoss uses Impact to define the dependency tree (graph) of all devices.
It does this so that it can determine the causal relationships of device failure.
This is useful when you need to know how devices depend on one another.

Prerequisites
------------------------------------------------------------------------------

* Zenoss ZenPack Developement
* Python 2.7

We assume that you are familiar with ZenPack developement and Python coding.
We further assume that we work from the base of ZP_DIR.
For NetBotz for example:

export ZP_DIR_TOP=$ZENHOME/ZenPacks/ZenPacks.training.NetBotz
export ZP_DIR=$ZP_DIR_TOP/ZenPacks/training/NetBotz

Impact Outline
------------------------------------------------------------------------------

The Basic idea behind Impact is as follows:

* Identify what devices are dependent on one another.

   - It may be useful to create a diagram that shows dependency
   - Make sure you understand how a component or device failure will affect other systems.
   - In your base classes you have defined your _relations which can be
     (ToOne, ToMany, ToManyCont, etc). Example minus Boilerplate:

  In Instance.py::
   
   _relations = _relations + (
       ('Instance_host', ToOne(
                               ToManyCont, 
                               'Products.ZenModel.Device.Device', 
                               'oracle_instances')),
       ('oracle_tablespaces', ToManyCont(
                                 ToOne, 
                                 'ZenPacks.zenoss.DatabaseMonitor.TableSpace.TableSpace', 
                                 'instance')),
       )

  In TableSpace.py::

    _relations = _relations + (
        ('instance', ToOne(ToManyCont,
                           'Products.ZenModel.Instance.Instance',
                           'oracle_tablespaces'),
        ),
    )

* Define the depenency classes for your ZP

   - You need to define a class object that summarizes the depency list for each
     device or component.
   - This is done with inheritance from BaseRelationsProvider
   - There is a tall bit of boilerplate code in this example_
   - For example: **class InstanceRelationsProvider(BaseRelationsProvider)**
   - Here is an example (minus boilerplate)::

      # Give Impact (one-direction => ) dependencies for Devices
      class DeviceRelationsProvider(BaseRelationsProvider):
          impact_relationships = ( 'oracle_instances',)

      # Give Impact the (bi-directional<=> ) dependencies for Instances
      class InstanceRelationsProvider(BaseRelationsProvider):
          impacted_by_relations = ( 'Instance_host',)
          impact_relationships = ( 'oracle_tablespaces',)

      # Tell Impact the (one-directional <= ) dependencies of TableSpaces
      class TableSpaceRelationsProvider(BaseRelationsProvider):                       
          impacted_by_relationships = ( 'instance',) 


* Now that the dependencies are made, you can **register** this code with Impact:

   - Create an impact.zcml file: Yes, it is XML.
   - Populuate for .Device.Device, .Instance.Instance or .MyModule.MyClass entries:
   - Here is an example for DatabaseMonitor::

      <?xml version="1.0" encoding="utf-8"?>
      <configure 
          xmlns="http://namespaces.zope.org/zope"
          xmlns:browser="http://namespaces.zope.org/browser"
          xmlns:zcml="http://namespaces.zope.org/zcml"
          >

          <!-- API: Info Adapters -->
          ... boilderplate ...

          <!-- Impact -->
          <include package="ZenPacks.zenoss.Impact" file="meta.zcml"/>

          <subscriber
              provides="ZenPacks.zenoss.Impact.impactd.interfaces.IRelationshipDataProvider"
              for="Products.ZenModel.Device.Device"
              factory=".impact.DeviceRelationsProvider"
              />

          <subscriber
              provides="ZenPacks.zenoss.Impact.impactd.interfaces.IRelationshipDataProvider"
              for=".Instance.Instance"
              factory=".impact.InstanceRelationsProvider"
              />

          <subscriber
              provides="ZenPacks.zenoss.Impact.impactd.interfaces.IRelationshipDataProvider"
              for=".TableSpace.TableSpace"
              factory=".impact.TableSpaceRelationsProvider"
              />

      </configure>



Boiler Plate Code Example
-------------------------

.. _example

::

   ##############################################################################
   # Boiler Plate Code for Impact! file: impact.py
   ##############################################################################

   from ZenPacks.zenoss.XenServer import ZENPACK_NAME
   from ZenPacks.zenoss.XenServer.utils import guid

   # Lazy imports to make this module not require Impact.
   ImpactEdge = None
   Trigger = None

   # Constants to avoid typos.
   AVAILABILITY = 'AVAILABILITY'
   PERCENT = 'policyPercentageTrigger'
   THRESHOLD = 'policyThresholdTrigger'
   DOWN = 'DOWN'
   DEGRADED = 'DEGRADED'
   ATRISK = 'ATRISK'


   def edge(source, target):
       '''
       Create an edge indicating that source impacts target.

       source and target are expected to be GUIDs.
       '''
       # Lazy import without incurring import overhead.
       # http://wiki.python.org/moin/PythonSpeed/PerformanceTips#Import_Statement_Overhead
       global ImpactEdge
       if not ImpactEdge:
           from ZenPacks.zenoss.Impact.impactd.relations import ImpactEdge

       return ImpactEdge(source, target, ZENPACK_NAME)


   class BaseImpactAdapterFactory(object):
       '''
       Abstract base for Impact adapter factories.
       '''

       def __init__(self, adapted):
           self.adapted = adapted

       def guid(self):
           if not hasattr(self, '_guid'):
               self._guid = guid(self.adapted)

           return self._guid


   class BaseRelationsProvider(BaseImpactAdapterFactory):
       '''
       Abstract base for IRelationshipDataProvider adapter factories.
       '''

       relationship_provider = ZENPACK_NAME

       impact_relationships = None
       impacted_by_relationships = None

       def belongsInImpactGraph(self):
           return True

       def impact(self, relname):
           relationship = getattr(self.adapted, relname, None)
           if relationship and callable(relationship):
               related = relationship()
               if not related:
                   return

               try:
                   for obj in related:
                       yield edge(self.guid(), guid(obj))

               except TypeError:
                   yield edge(self.guid(), guid(related))

      def impacted_by(self, relname):
           relationship = getattr(self.adapted, relname, None)
           if relationship and callable(relationship):
               related = relationship()
               if not related:
                   return

               try:
                   for obj in related:
                       yield edge(guid(obj), self.guid())

               except TypeError:
                   yield edge(guid(related), self.guid())

       def getEdges(self):
           if self.impact_relationships is not None:
               for impact_relationship in self.impact_relationships:
                   for impact in self.impact(impact_relationship):
                       yield impact

           if self.impacted_by_relationships is not None:
               for impacted_by_relationship in self.impacted_by_relationships:
                   for impacted_by in self.impacted_by(impacted_by_relationship):
                       yield impacted_by


    class BaseTriggers(BaseImpactAdapterFactory):
       '''
       Abstract base for INodeTriggers adapter factories.
       '''
       triggers = []

       def get_triggers(self):
           '''
           Return list of triggers defined by subclass' triggers property.
           '''
           # Lazy import without incurring import overhead.
           # http://wiki.python.org/moin/PythonSpeed/PerformanceTips#Import_Statement_Overhead
           global Trigger
           if not Trigger:
               from ZenPacks.zenoss.Impact.impactd import Trigger

           for trigger_args in self.triggers:
               yield Trigger(self.guid(), *trigger_args)


    # ------------------------------------------------------------------------#
    """ The critical part of Impact: We define the impact relations """
    # ------------------------------------------------------------------------#

    # This tells Impact what (bi-directional) dependencies of Devices for this ZP
    class DeviceRelationsProvider(BaseRelationsProvider):
        impact_relationships = ( 'oracle_instances',)
    
    # Tell Impact of the (bi-directional) dependencies Instances for this ZP
    class InstanceRelationsProvider(BaseRelationsProvider):
        impacted_by_relationships = ( 'Instance_host',)
        impact_relationships = ( 'oracle_tablespaces',)
    
    # Tell Impact of the (bi-directional) dependencies of TableSpaces for this ZP
    class TableSpaceRelationsProvider(BaseRelationsProvider):
        impacted_by_relationships = ( 'instance',)
    
Show Impacts for Thing
------------------------

This is some sample code that shows impacts on an object::

   from zope.component import subscribers
   from Products.ZenUtils.guid.interfaces import IGUIDManager
   from ZenPacks.zeross.Impact.impactd.interfaces import IRelationshipDataProvider


   def show_impacts_for(thing):
       guid_manager = IGUIDManager(thing.getDmd())

       for subscriber in subscribers([thing], IRelationshipDataProvider):
           print "%s:" % subscriber.relationship_provider
           for edge in subscriber.getEdges():
               source = guid_manager.getObject(edge.source)
               impacted = guid_manager.getObject(edge.impacted)
               print "    %s (%s) -> %s (%s)" % (
                   source.id, source.meta_type, impacted.id, impacted.meta_type)
           print

   show_impacts_for(find("VACC").os.interfaces._getOb('VLAN0200'))

