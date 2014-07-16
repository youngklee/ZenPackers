===================================
Attribute Errors and Other Oddities
===================================

We discuss various problems with attribute errors.
Most of these errors come from a mismatch between the Zenpack software 
and the ZODB database that *should* already have the data structure in place,
but for some reason does not. Make sure you re-start Zenoss when you install
your zenpacks, and **before** adding any devices to the Zenpack classes.


Attribute Error After Installing a Device
---------------------------------------------------------------

 If you get an "Attribute Error" for a Zenpack zProperty after installing
 a device to that Zenpack, you may have forgotten to restart Zenoss after
 installing the Zenpack. The class structure and attributes are not yet
 setup in ZODB.

Attribute errors of the type "__of__"
---------------------------------------------------------------

 If you get an error that specifies the "__of__" attribute, especially
 when starting, stopping, or installing a ZP, it could be related to 
 misfit objects in the ZODB.

 AttributeErrors on the __of__ attribute almost always are an indication that
 there's an object in ZODB (of class DatabaseMonitorDataSource in this case)
 for which there's no longer a Python class file for in the expected place in
 the file system.

 The ZenPack appears to have that module/class. Something is out-of-sorts with
 the ZenPack. When this happens you can install the ZenPack twice, then
 remove it. The reason to install twice is that oftentimes the first time will
 fail, but it at least copies the code to the right place that allows the
 second installation to work.

 If that fails you may have to use heavier methods like *zenwipe.sh*

