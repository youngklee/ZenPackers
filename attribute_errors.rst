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

You still have problem removing the device: Possible stale devices
------------------------------------------------------------------

If you still have errors removing the device with an error 
that refers to your ZP objects, similar to::

  ... lots of stuff before this ...
  ImportError: No module named xyz_implementation
  ERROR:zen.ZenPackCmd:zenpack command failed

It may indicate that you have a stale object that failed to be removed.
You *might* be able to 

* Remove the bad device by going into zendmd and deleting it twice::

   zenoss@mp2:/opt/zenoss/ZenPacks]: zendmd
    >>> device = find('mp8.osi')
    >>> device
      <Endpoint at /zport/dmd/Devices/ABC/XYZ/devices/mp8.osi>
    >>> device.deleteDevice()
      File "/zenpacks/ZenPacks.zenoss.XYZ/ZenPacks/zenoss/XYZ/catalogs.py",
      line 84, in get_xyz_core_catalog
          from ZenPacks.zenoss.OpenStackInfrastructure.xyz_implementation
          import all_core_components
          ImportError: No module named xyz_implementation
    >>> device.deleteDevice()
     ... more tracebacks ...
    >>> commit()
    >>> exit()

* Now try to remote the ZP again::

    zenpack --remove ZenPacks.zenoss.XYZ

* Now restart all Zenoss services 




If all else Fails
---------------------

If these trials fail you may have to:

* Somehow manually edit the ZoDB and remove the problem object
* Use heavier methods like *zenwipe.sh*


