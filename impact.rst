==============================================================================
Impact Rough Guide
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

