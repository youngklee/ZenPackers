=====================================
Graphs 
=====================================

Special Examples
--------------------------

Putting Events in Things
--------------------------
* Jos: does anyone know if it's possible to include a variable (like component id) in a Graph title?
* Bri: Yes
* Bri: I'll give you an example
* Bri: https://github.com/zenoss/ZenPacks.zenoss.UCSCapacity/blob/develop/ZenPacks/zenoss/UCSCapacity/__init__.py#L212-L225
* Bri: Note that this one is monkeypatched, but you can just include it in your regular class
* Bri: All you need to do is update the graph object before you release the list
* Che: That seems dangerous. Wouldn't Zope automatically commit that after processing the request?
* Che: According to Joseph you have to implement getDefaultGraphDefs for Zenoss 4 and getGraphObjects for Zenoss 5. Also, you should do it like this. Note setting the volatile _v_title property.

https://github.com/zenoss/ZenPacks.zenoss.CiscoUCS/blob/develop/ZenPacks/zenoss/CiscoUCS/ServiceProfile.py#L193

