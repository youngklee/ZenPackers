===========================
Backups and Snapshots
===========================


Backups 
------------------------------------

Backups for ControlCenter are the most durable way to preserve your Z5
installation. It is larger and more time consuming than a Snapshot but 
it is more reliable in preserving all (Docker) images and configurations.

Backups are done as follows:

* First, decide what folder backups should be stored. Often: /opt/serviced/var/backups/
* Second, note that backups can be large. Make sure you have room.
* To create a backup from the 5.X system host::

   serviced backup /opt/serviced/var/backups/

* Once finished, its advisable to copy that file to another safe system::

   scp /opt/serviced/var/backups/file.tgz me@somehost.com:/tmp/

* To restore::

   serviced restore /path/to/file.tgz

   

SnapShots
--------------------------

Snapshots normally temporary and have a limited lifetime in the system.

* To perform a snapshot::

  serviced snapshot commit Zenoss.core

