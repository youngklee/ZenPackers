Debugging Control Center: Kung-Pow Style
================================================

Debugging ControlCenter ain't easy. Ask anyone.

Instead of general theory, lets talk about examples.

Catching a PDB in Zope
--------------------------------------

First you need to have a single instance of Zope so that your PDB will
guarantee to fire in the instance you monitor. You also need to run
zope in the foreground and you need to know which one.

* Attach to your 5x host
* Edit the service definition for zope and set the InstanceLimits:Min parameter
  to 1::

    [you@5x.com]: serviced service edit zope
    (search for "Min", change that value from 2 to 1; if already 1, continue)

* In the 5x GUI, go into your Zope defintion, click "Edit Services".
  Set Instances to 1. You should see the instance count become a singleton.

* Now we attach to that unique instance of Zope::

    [you@5x.com]: serviced service attach zope
    [root@42b39f16c058 /]#: su - zenoss
    [zenoss@42b39f16c058 /]#: 

* Now insert your pdb in the right place::

    [zenoss@42b39f16c058 /]#: ZP=$ZENHOME/ZenPacks/ZenPacks.zenoss.ZenJMX-3.11.0-py2.7.egg/
    [zenoss@42b39f16c058 /]#: cd $ZP/ZenPacks/zenoss/ZenJMX/
    [zenoss@42b39f16c058 /]#: vi __init__.py
    [zenoss@42b39f16c058 /]#: (... insert  your pdb.set_trace() ... )

* Now restart zope in place. First find out the PID.
  Its the commmand that looks like "su - zenoss -c /opt/zenoss/bin/runzope"
  You can use this sed expression to get it::

    pid=$(ps aux | sed -n 's|^root *\(\w\+\)\? .*su - zenoss .*/runzope$|\1|p')
    echo $pid

* Restarting Zope will just revert your pdb. 
  You need to kill that process and restart it just afterwards.
  Here is how you do it::

   kill $pid && su - zenoss -c /opt/zenoss/bin/runzope 

* Easy way to restart Zope in foreground with pkill::

   pkill -f zope.conf ; zopectl fg

* Now you need to trigger your bug by using the GUI.
  Go to the GUI and do this now.

* If you are lucky, your terminal will have caught your pdb at the correct place.

Running Various Daemons in Foreground
--------------------------------------

For each of these next commands, you must be attached to the <container>
and su'd into the zenoss account there like this::

   serviced service attach <container> su - zenoss

* Zope::

   pkill -f zope.conf ; zopectl fg

* Zenhub::
   
   pkill -f zenhub.conf ; zenhub run --workers=0 -v10

* Zeneventd::
   
   pkill -f zeneventd.conf ; zeneventd run --workers=0 -v10

* Zenpython, Zenmodeler, Zencommand

  You would normally stop the container and run the daemon manually
  from a zope container.


