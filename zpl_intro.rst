==============================================================================
ZenPackLib Overview
==============================================================================

.. highlight:: python
   :linenothreshold: 5



Description
------------------------------------------------------------------------------

ZenPackLib's use of automatic class creation requires a bit of explanation.


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


Things to note:

* Pools class is automatically created based on the YAML definition

* Go to Advanced->Monitoring Templates: Hit the + at bottom left

* The 'relationships' labels are added in order to disambiguate parent-child names.
  The *parent* and *child* name prefix are ZPL magical.

* The label attached to Pool is "CP-Pool". It exists to disambiguate the
  relationship between Item and SubItem objects.
* In particular, you will need to.

   - Create: a template for each label with the EXACT same name as label.
   - Ensure: template is in the appropriate *Template Path* (/ControlPlane)

ZPL Modeling Templates
--------------------------
Our modeling example has a very simplified version of the ControlPlane ZenPack.
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
                'flavorId':   { 'grid_display': False },             # 1
                'flavorRAM':  { 'type_': 'int',
                                'renderer': 'Zenoss.render.bytesString',
                                'label': 'RAM' },                    # bytes
                'flavorDisk': { 'type_': 'int',
                                'renderer': 'Zenoss.render.bytesString',
                                'label': 'Disk' }                    # bytes
            }
        },
        ... etc ...
    }

The ZPL will take care of setting this renderer whereever those variables
are used.

Ref: https://github.com/zenoss/ZenPacks.zenoss.OpenStack
