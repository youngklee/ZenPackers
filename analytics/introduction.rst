
Introduction and General Notes
===========================================

The following documents outline how Analytics support is built into our
Zenpacks. If you see any errors, please contribute to these docs as needed.


ZenETL
----------------------------------------------------------------------

Issues related to troubleshooting ETL and expeditiing model load and
aggregation should be directed to:

* https://github.com/zenoss/ZenPacks.zenoss.psSelfMonitoring

Specifically the **"Additional Analytics related scripts provided by the zenpack"** 
section


To install ZenETL, you must find the correct version for your version of Zenoss:

* Always use the latest version of the Analytics Server
* ZenETL version must match your version of Analytics Server
  

  - http://artifacts.zenoss.loc/releases/X.Y.Z/ga/analytics/

  - grab the egg
    ZenPacks.zenoss.ZenETL-X.Y.Z.a.b.cccc-py2.7.egg

  - Replace the numerical values: X.Y.Z and a.b.cccc


Analytics Server
--------------------------------------

We briefly mention that TCP network connectivity must be allow *TO* the
Analytics server. 

The following table lists Analytics pieces that typically must communicate, and
the default network ports that should be open for communication::

   +-----------------------+----------------------------+----------------------+
   | From                  | To                         | Default Port Numbers |
   +=======================+============================+======================+
   | Analytics             | Analytics database server  | 3306                 |
   +-----------------------+----------------------------+----------------------+
   | Analytics             | Resource Manager           | 8080                 |
   +-----------------------+----------------------------+----------------------+
   | Resource Manager      | Analytics                  | 7070                 |
   +-----------------------+----------------------------+----------------------+
   | Analytics Web Users   | Analytics                  | 7070                 |
   | zenperfetl            |                            |                      |
   +-----------------------+----------------------------+----------------------+
   | (on remote collectors)| Analytics                  | 7070                 |
   +-----------------------+----------------------------+----------------------+


