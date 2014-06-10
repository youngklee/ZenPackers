=====================================
Zenwipe.sh: Erase Everything but Core
=====================================

Zenwipe will remove everything except the Core product.
This includes a full purge of:

* ZODB relstorage
* ZODB session
* ZEP
* Mysql
* Zenpacks

You can get it at 
https://dev.zenoss.com/tracint/browser/branches/core/zenoss-4.x/inst/zenwipe.sh  

You can also selectively purge single items by editing the script.
For example, you can remove the ZEP database only with this derivative script:

.. code-block:: bash

    #!/bin/bash
    ##############################################################################
    # THIS SCRIPT WILL BLOW AWAY YOUR ZEP EVENT DATABASE
    ##############################################################################
 
    if [ -z "${ZENHOME}" ]; then
        if [ -d /opt/zenoss ] ; then
            ZENHOME=/opt/zenoss
        else
            echo "Please define the ZENHOME environment variable"
            exit 1
        fi
    fi
 
    zengc=$ZENHOME/bin/zenglobalconf
 
    # read configuration from global.conf
    dbtype=$(${zengc} -p zodb-db-type)
    host=$(${zengc} -p zodb-host)
    port=$(${zengc} -p zodb-port)
    user=$(${zengc} -p zodb-user)
    userpass=$(${zengc} -p zodb-password)
    admin=$(${zengc} -p zodb-admin-user)
    adminpass=$(${zengc} -p zodb-admin-password)
    dbname=$(${zengc} -p zodb-db)
 
 
    zenoss stop
 
    # Drop and recreate the ZEP event database
    zeneventserver-create-db --dbtype $dbtype --dbhost $host --dbport $port --dbadminuser $admin --dbadminpass "${adminpass}" --dbuser $user --dbpass "${userpass}" --force
 
    zenoss start


Removing Broken Zenpacks
-------------------------
Daniel Robbins has written a script that detects damaged zenpacks and attempts
to remove them: http://wiki.zenoss.org/Removing_Broken_ZenPacks

To use it you must use it via zendmd::

   zendmd --script=zenpack-remove.py

Or you can try to manually remove it interactively in zendmd::

   dmd.ZenPackManager.packs._delObject('ZenPacks.zenoss.ZenPackName')
   commit()
 
   

