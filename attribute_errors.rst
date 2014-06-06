===================================
Attribute Errors and Other Oddities
===================================

We discuss various problems with attribute errors.


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


