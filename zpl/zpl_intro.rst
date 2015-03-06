==============================================================================
ZenPackLib Overview
==============================================================================

The ZenPackLib allows you to automate much of the ZenPack creation process.

Description
==============================================================================

ZenPackLib's use of automatic class creation requires a bit of explanation.
We will attempt to cover some of this here. The official documentation will
be listed at ....


Prerequisites
------------------------------------------------------------------------------

* Zenoss ZenPack Developement
* Python 2.7
* ZenPackLib familiarity

We assume that you are familiar with ZenPack developement and Python coding.
We work from the base of $ZP_DIR. A few things to ensure:

* You have created a DeviceClass for your ZP
* You have set zPythonClass for your DeviceClass to Zenpacks.zenoss.ZP.Class.
  For example: Zenpacks.zenoss.ControlPlane.ControlPlane



Class Definition and Overview (Simplified Form)
------------------------------------------------------------------------------

In your class definition (possibly __init__.py) you will have definitions of
your Pool classes like:

.. code-block:: python
   :emphasize-lines: 5,9,35,45,46
   :linenos:                  

   RELATIONSHIPS_YUML = """
   // --------------------------------------------
   // Containing Relations
   // --------------------------------------------
   [ControlPlane]++pools -controlplane[Pool]
   // --------------------------------------------
   // Non-containing Relations
   // --------------------------------------------
   [Pool]*parentPool -.-childPools 0..1[Pool]
   """

   CFG = zenpacklib.ZenPackSpec(
       name=__name__,

       zProperties={
           'DEFAULTS': {'category': 'Control Plane'},

           'zControlPlaneHost': {},
           'zControlPlanePort': {'default': '8787'},
       },

       classes={
           'DEFAULTS': {
               'base': zenpacklib.Component,
           },

           'ControlPlane': {
               'base': zenpacklib.Device,
               'meta_type': 'ZenossControlPlane',
               'label': 'Zenoss Control Plane',
           },

           'Pool': {
               'meta_type': 'ZenossControlPlanePool',
               'label': 'CP-Pool',    # <-- *** Note this label is ZPL magic.
               # ZenpackLib: Properties that Auto-magically appear in GUI
               'properties': {
                   'priority': {'label': 'Priority'},
                   'coreLimit': {'label': 'CPU Core Limit'},
                   'memoryLimit': {'label': 'Memory Limit'},
               },
               'relationships': {
                #  This is required since the pool <=> pool relationship
                #  can cause recursive ambiguity problems. This breaks that symmetry.
                'parentPool': {'label': 'Parent', 'order': 1.0},
                'childPools': {'label': 'Children', 'order': 1.1},
            }
           },
       },
       class_relationships=zenpacklib.relationships_from_yuml(RELATIONSHIPS_YUML),
    )
    CFG.create()


Special things to note and observe:

* .. note:: 
  
   When you add and new zProperties to your Zenpack you *MUST*
   re-install your Zenpack. This is because those properties get
   created in the ZODB only when you install. New classes create relationship
   maps that subsequently are stored in ZODB. If your new class doesn't create
   a new zProperty then you can get away with a zenos restart and a remodel.
            
* name is set to the name of the class which will resolve to 
  ZenPacks.zenoss.ControlPlane . This should typically not be changed.

* DEFAULTS is a special value that will cause it’s properties to be added as
  the default for all of the other listed zProperties. Otherwise you have to 
  add them manually to each zProp.

* The zProp entry for zControlPlaneHost is a shorthand for the more verbose::

  'zControlCenterHost': {'type': 'string', 'default': ''}

* The class DEFAULTS specifies that all classes will be sub-classes of
  the standard zenpacklib.Component by default. We could choose from:

  - zenpacklib.Device
  - zenpacklib.Component
  - A *user* defined class
  
* The Pools class is automatically created based on the YUML definition

* Go to Advanced->Monitoring Templates: Hit the + at bottom left

* The 'relationships' labels are added in order to disambiguate parent-child names.
  The *parent* and *child* name prefix are ZPL automagically determined from
  the YUML spec defined in RELATIONSHIPS_YUML.

* The label attached to Pool is "CP-Pool". It exists to disambiguate the
  relationship between Pool and contained-Pool objects.

* In particular, you will need to.

   - Create: A template for each label with the EXACT same name as label.
   - Ensure: Template is in the appropriate *Template Path* (/ControlPlane)
   - Ensure: All relationship names are *unique* in the YUML spec

About YUML Relationships Map
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The YUML relationship maps have a very specific format.
In the following generic form::

   [LeftClass](l_cardinality)leftToRightName (seperator) rightToLeftName(r_cardinality)[RightClass]

   For example:

   [Service]0..1serviceRuns -.-serviceDef *[Running]


* [LeftClass] and [RightClass] are classes

* The cardinalities can be: (\*, 0..1, 1..7, 1, +)

* **LeftToRightName** and **RightToLeftName** are the *labels* that identify the
  relationships created. For example:

  - The *pools* relationship on ControlPlane defines the contained pools.
  - The *controlplane* relationship on Pool defines the containing controlplane.

* Relationships do not need a name unless there is ambiguity in relations.
  I recommend naming all your relations though just incase you later add
  a relationship that ambiguates your schema.

* .. note::

    Make Sure All Relationships Have Unique Names!
    If relationships don't have unique names ZPL will not be able to process
    the relationships in a predictable way. Make sure all relation names are
    unique and you should be ok.

Class Definition: Advanced Topics
------------------------------------------------------------------------------

In the begginning there is ZenPacks.zenoss.XYZ class. Its created by Zenoss
when you create the class and install the __init__.py. ZPL creates these two
objects by defaults::

   .schema:  A module that allows customization (overrides) of the ZPL
               created Zenpack class
   .ZenPack: The class that contains all the properties, install(), remove(),
             and cleanup methods for the Zenpack.

When ZPL creates any components (for example, Pool), it creates several objects relative
to ZenPacks.zenoss.XYZ::

   .Pool         : The Pool component class itself
   .schema.Pool  : The Pool schema space for class modification

If you don't create your own Pool.py class file (analagous to .ZenPack),
ZPL will do this for you. Again, this is for property managment and
initializations.

Attribute Definition
--------------------------
In order to modify attributes you must change those attributes in your
__init__.py. The various properties you can change are:

* base: Base Class Type
* meta_type: Component-level identifier
* label: The display label in the GUI
* index_type: index types for component Catalog search efficiency: (field, keyword)
* impacts: What this component impacts: can be list or list-output of a function
* impacted_by: What is component is impacted by: can be list or function
* order: Order of display in the grid

ZPL Modeling
--------------------------

ZPL Automatic set_ and get_ for Non-Containing Relations
==========================================================

You will automatically get a *set_var()* and *get_var()* method when you
invoke them in the modeler. The **set_** method will create or update the 
relationship.

You use it by first creating a non-containing
relationship in the YUML like this::

    [Tenant]1-.-*[Floatingip]

Now you set the relationship up in the modeler by using **set_tenant*:

.. code-block:: python
   :emphasize-lines: 9
   :linenos:                  

    floatingips = []
        for floatingip in results['floatingips']:
 
        floatingips.append(ObjectMap(
            modname = 'ZenPacks.zenoss.OpenStackInfrastructure.FloatingIp',
            data = dict(
                id = 'floatingip-{0}'.format(floatingip['id']),
                floatingipId = floatingip['id'],
                set_tenant = tenant_name[0],
                )))
    
    tenants = []
        ... similar to floatingips above ...
        ... etc ...

    objmaps = {
              'tenants': tenants,
              'floatingips': floatingips,
          }

    # Apply the objmaps in the right order.
    componentsMap = RelationshipMap(relname = 'components')
    for i in ('tenants', 'floatingips'):
        for objmap in objmaps[i]:
            componentsMap.append(objmap)

    return (componentsMap)



ZPL Modeling Templates
==========================

Our modeling example is a very simplified version of the ControlPlane ZenPack.
The modeler itself grabs a pre-made ObjectMap from the helper class in
$ZP_DIR/modeling:

* $ZPDIR/modeler/plugins/zenoss/ControlPlane.py (wrapper for modeling.py)
* $ZPDIR/modeling (Does the heavy lifting)

In the modeler wrapper, ControlPlane.py we have:

.. code-block:: python
   :linenos:                  

      import logging
      LOG = logging.getLogger('zen.ControlPlane')

      from twisted.internet.defer import inlineCallbacks, returnValue
      from Products.DataCollector.plugins.CollectorPlugin import PythonPlugin
      from ZenPacks.zenoss.ControlPlane import modeling, txcpz

      class ControlPlane(PythonPlugin):

          """ControlPlane modeler plugin."""

          required_properties = (
              'zControlPlaneHost',
              'zControlPlanePort',
              'zControlPlaneUser',
              'zControlPlanePassword',
              )

          deviceProperties = PythonPlugin.deviceProperties + required_properties

          @inlineCallbacks
          def collect(self, device, unused):
              """Asynchronously collect data from device. Return a deferred."""
              LOG.info("%s: Collecting data", device.id)

              # Loop through the required_properties and balk if missing.
              for required_property in self.required_properties:
                  if not getattr(device, required_property, None):
                      LOG.warn(
                          "%s: %s not set. Modeling aborted",
                          device.id,
                          required_property)

                      returnValue(None)

              client = txcpz.Client(
                  device.zControlPlaneHost,
                  device.zControlPlanePort,
                  device.zControlPlaneUser,
                  device.zControlPlanePassword)

              producer = modeling.DataMapProducer(client)

              try:
                  results = yield producer.getmaps()
              except Exception as e:
                  LOG.exception(
                      "%s %s ControlPlane error: %s",
                      device.id, self.name(), e)

                  returnValue(None)

              returnValue(results)

          def process(self, device, results, unused):
              """Process results. Return iterable of datamaps or None."""
              if results is None:
                  return None

              LOG.info("%s: Processing data", device.id)
              results = tuple(results)
              return results



In the helper class, $ZPDIR/modeling we have (abbreviated to Pools).
Notice in line 26, the *set_parentPool* attribute is processed by ZPL as a
ManyToOne relationship between Pools and sub-Pools.

.. code-block:: python
   :emphasize-lines: 26
   :linenos:                  

      #------------------------------------------------------------------------------
      # Zenpacks.zenoss.ControlPlane.modeling
      # ControlPlane Modeling: Modeling code for ControlPlane.
      #------------------------------------------------------------------------------
      from twisted.internet.defer import inlineCallbacks, returnValue
      from Products.DataCollector.plugins.DataMaps import RelationshipMap
      from .util import get_pool_id, get_host_id, get_service_id, get_running_id

      def map_pool(attributes):
          """Return ObjectMap data given attributes.

          Example attributes:

              {
                  "Id": "Alternate",
                  "ParentId": "default",
                  "Priority": 0,
                  "CoreLimit": 1,
                  "MemoryLimit": 1,
              }
          """
          return {
              'id': get_pool_id(attributes['Id']),
              'title': attributes['Id'],
              'set_parentPool': get_pool_id(attributes['ParentId']),
              'priority': attributes['Priority'],
              'coreLimit': attributes['CoreLimit'],
              'memoryLimit': attributes['MemoryLimit'],
              }


      class DataMapProducer(object):
          """Produce the DataMap objects required to model """

          def __init__(self, client):
              self.client = client

          @inlineCallbacks
          def getmaps(self):
              """Return a datamaps map. """
              maps = []

              pools = yield self.client.pools()
              pool_maps = []
              for pool in pools:
                  pool_map = map_pool(pool)
                  if pool_map:
                      pool_maps.append(pool_map)

              maps.append(
                  RelationshipMap(
                      relname='pools',
                      modname='ZenPacks.zenoss.ControlPlane.Pool',
                      objmaps=pool_maps))

              returnValue(maps)



ZPL Monitoring Templaees
--------------------------
The datapoints for this model are essentially the dictionary keys of the JSON
data sources. That means the datapoints must match the keys exactly.

* Create a Template: the name must matche the label in __init__.py: CP-Pool
* Add a DataSource: The name is arbitrary
* Add a DataPoint to that DataSource: The name must match an attribute (ZPL)
* Some example points:

  - Priority
  - CoreLimit
  - MemoryLimit   

ZPL Details Auto-Rendering 
----------------------------------------------------
+------------------------------+
| Thu May 29 16:01:30 CDT 2014 |
+------------------------------+

You can now use the same rendering in the details that are used elsewhere.
In your __init__.py you set the *renderer*  property in the class properties
section:

.. code-block:: python
   :emphasize-lines: 11,14
   :linenos:                  

    classes={ .... 

        'Flavor': {
            'base': 'LogicalComponent',
            'meta_type': 'OpenStackFlavor',
            'label': 'Flavor',
            'order': 1,
            'properties': {
                'flavorId':   { 'grid_display': False },       # 1
                'flavorRAM':  { 'type_': 'int',
                                'renderer': 'Zenoss.render.bytesString',
                                'label': 'RAM' },              # bytes
                'flavorDisk': { 'type_': 'int',
                                'renderer': 'Zenoss.render.bytesString',
                                'label': 'Disk' }              # bytes
            }
        },
        ... etc ...
    }

The ZPL will take care of setting this renderer wherever those variables
are used.

Ref: https://github.com/zenoss/ZenPacks.zenoss.OpenStack

Dynamic Classes 
---------------

There are several classes that are created on the fly when ZPL is instantiated.
This includes:

* All the classes created from your YUML description
* schema: Classes schema created from the YUML spec. You'll see this in your
  class files outside of *__init__.py* ::

   from . import schema

Impact in ZPL
--------------

Impact adapters are provided for in the ZPL. In order to get them to work
you must provide the **impacts** and **impacted_by** attributes in the class
specification in **__init.py__**. The values of these attributes can be one
of the following:

* A valid relationship name as defined in the YUML
* A valid function that returns a list of component ID's.

   

