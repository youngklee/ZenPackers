========================================================================
Automatic Templates for Zenpacks
========================================================================

Templating is an important aspect of data modeling and colleciton. 
This article explores automatic template construction for modeling.

Prerequisites
------------------------------------------------------------------------------

* The usual 

Automatically Applied Setters and Getters on Class Objects
-----------------------------------------------------------

In Products/DataCollector/ApplyDataMap.py there is code that automatically
executes all methods in your class that start with 
In order for this to work, follow these general steps:

* Create Methods getXYZ(self, data), setXYZ(self, data)
* Create data attribute 'setXYZ' (in your datamap) for the setter in modeling 
* Apply that datamap to your model. ApplyDataMap will process and apply it. Some details:
 
* getXYZ(self, data)
* setXYZ(self, data)

The *data* that is referenced must be provided by your modeling template in the
form of a map attribute with the same name as the method:

.. code-block:: python

   {
       'setMonitoringTemplateData': attributes['MonitoringProfile'],
       'someOtherAttribute': somedata,
       ... etc ...
   }

 
Example of Auto-Generated and Applied Local Templates
----------------------------------------------------------------

The context of this is using ZenPackLib and the ZenPacks.zenoss.ControlPlane .
The goal is to have an automatically generated template to be *locally* applied
to every component object that gets created. 

Based on an API call to the ControlPlane, you need to:: 

* Create the model data, based on API defs. 
* Insert Data into datamap.
* Append the map to the object map. ApplyDataMap processes all
* Object Instantiation: Create the Local Template based on ObjectMaps
* Ensure template attribute's name matches a getter in object class.

Create the Model Data
~~~~~~~~~~~~~~~~~~~~~~
In our example we create a "MonitoringTemplateData" based on 
the API's return value of MonitoringProfile data:

.. code-block:: python

   def map_pool(attributes):
   """Return ObjectMap data given classname and attributes. """

   return {
       'id': get_pool_id(attributes['ID']),
       'title': attributes['ID'],
       'set_parentPool': get_pool_id(attributes['ParentID']),
       'priority': attributes['Priority'],
       'coreLimit': attributes['CoreLimit'],
       'memoryLimit': attributes['MemoryLimit'],
       'setMonitoringTemplateData': attributes['MonitoringProfile'],
       }

Insert Data into Datamap
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Later on this data is processed in DataMapProducer class (abbreviated):

.. code-block:: python

   class DataMapProducer(object):
       """Produce the DataMap objects required to model """

       def __init__(self, client):
           self.client = client

       @inlineCallbacks
       def getmaps(self):
       """ Return datamaps to modeler. """

       maps = []

       pools = yield self.client.pools()
       pool_maps = []
       for attributes in pools:
           pool_map = map_pool(attributes)
           if pool_map:
               pool_maps.append(pool_map)

Understand that these modules are called by the Modeler and get fed directly
to the other core services. The next section is also part of the same modeler:

Append the Map to the Object Map
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This is the usual and traditional step for appending object maps.
Once you have the dictionary data (pool_maps in our case) for your object or
component, process it in the usual way:

.. code-block:: python

   maps.append(
    RelationshipMap(
        relname='pools',
        modname='ZenPacks.zenoss.ControlPlane.Pool',
        objmaps=pool_maps))

   returnValue(maps)


Ensure Template Attribute's Name Matches a Getter in Object Class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

After the modeler hands these maps off to the other ancillary parts of the
core, the data in the object classes gets initialized with the map data.

Consider the Pool.py class code:

.. code-block:: python

   # ZenPack Imports
   from . import schema
   from .utils import replaceLocalTemplate

   class Pool(schema.Pool):

       """Custom model code for Pool class."""

       _monitoringTemplateData = None

       def getMonitoringTemplateData(self):
           """Return last set monitoring template data."""
           return self._monitoringTemplateData

       def setMonitoringTemplateData(self, data):
           """Create local monitoring template using data."""
           replaceLocalTemplate(self, data, 'ZenPacks.zenoss.ControlPlane.Pool')

Notice that the *setMonitoringTemplateData* is exactly the same name as that
of the mapped data above. This is critical since the ApplyDataMap class is
looking for this match, and without it the process fails.

Object Instantiation: Create the Local Template based on ObjectMap Data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once ApplyDataMap gets the data above, it calls setMonitoringTemplateData()
with the associated data and configures all the templates.

If we look in the util.py import you'll find the 
replaceLocalTemplate(obj, data, targetPythonClass) helper utility
which configures that actual Template:
( See reference: 
https://github.com/zenoss/ZenPacks.zenoss.Microsoft.Windows/blob/develop/load-templates)

.. code-block:: python

   def replaceLocalTemplate(obj, data, targetPythonClass):
    """Replace local monitoring template using data."""
    obj._monitoringTemplateData = data

    # Delete the local template if it already exists.
    template_name = obj.getRRDTemplateName()
    if not template_name:
        return

    template = getattr(aq_base(obj), template_name, None)
    if template:
        obj._delObject(template_name)

    # Create the template.
    template = RRDTemplate(template_name)
    obj._setObject(template.id, template)
    template = obj._getOb(template_name)

    # Configure the template.
    template.description = data.get('Description', '')
    template.targetPythonClass = targetPythonClass

    # Add datasources to the template.
    for metricConfig in data.get('MetricConfigs', []):
        datasource = template.manage_addRRDDataSource(
            metricConfig['ID'],
            'ControlPlaneDataSource.Control Plane')

        # Configure the datasource.
        datasource.component = '${here/id}'
        datasource.eventClass = '/Ignore'
        datasource.severity = 0
        datasource.cycletime = 300
        datasource.perfURL = metricConfig['PerfURL']

        # Add datapoints to the datasource.
        for metric in metricConfig['Metrics']:
            datapoint = datasource.manage_addRRDDataPoint(metric['ID'])

            # Add a default alias for each datapoint.
            datapoint.addAlias(metric['ID'])






