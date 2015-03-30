==============================================================================
ZPL Errors
==============================================================================

Certain errors are unique to ZPL.


ClassRelationshipSpec Error
---------------------------------

If you get a ZPL schema error like this::

   zenoss@zenoss> zenpack --list
   ERROR:zen.ZenMessaging:Error encountered while processing ZenPacks.zenoss.OpenStackInfrastructure
   Traceback (most recent call last):
   File "/opt/zenoss/Products/ZenMessaging/queuemessaging/schema.py", line 58, in _getZenPackSchemas
      pkg_path = zpkg.load().__path__[0]
   File "/opt/zenoss/lib/python/pkg_resources.py", line 1954, in load
      entry = __import__(self.module_name, globals(),globals(), ['__name__'])
   File "/zenpacks/ZenPacks.zenoss.OpenStackInfrastructure/ZenPacks/zenoss/OpenStackInfrastructure/__init__.py", line 624, in <module>
      class_relationships = zenpacklib.relationships_from_yuml(RELATIONSHIPS_YUML),
   File "/zenpacks/ZenPacks.zenoss.OpenStackInfrastructure/ZenPacks/zenoss/OpenStackInfrastructure/zenpacklib.py", line 937, in __init__
      if relationship.schema.remoteClass in self.imported_classes.keys():
   AttributeError: 'ClassRelationshipSpec' object has no attribute 'schema'
   ERROR:zen.ZenossStartup:Error encountered while processing ZenPacks.zenoss.OpenStackInfrastructure
   Traceback (most recent call last):
   File "/opt/zenoss/Products/ZenossStartup/__init__.py", line 27, in <module>
      pkg_path = zpkg.load().__path__[0]
   File "/opt/zenoss/lib/python/pkg_resources.py", line 1954, in load
      entry = __import__(self.module_name, globals(),globals(), ['__name__'])
   File "/zenpacks/ZenPacks.zenoss.OpenStackInfrastructure/ZenPacks/zenoss/OpenStackInfrastructure/__init__.py", line 21, in <module>
      from . import zenpacklib
   ImportError: cannot import name zenpacklib
   ERROR:zen.ZenPackCmd:zenpack command failed
   Traceback
   ... etc ...

  This error may indicate you changed your internal class relationship (YUML or JSON)
  without first removing existing devices from your system. You therefore have
  an inconsistency between ZODB and your current schema.
  
One way to fix this is to revert the changes:

* Revert your changes to the schema, 
* Restart your Z services (make sure this works)
* Remove the device or zenpack
* Make your changes again to your __init__.py
* Install/re-install the zenpack


