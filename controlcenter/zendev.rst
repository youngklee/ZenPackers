===========================
Zendev Essentials
===========================

::

   ZOPE=$(serviced service list | grep Zope | awk '{print $2}')

   # Open zendmd
   zendev devshell
   zendmd

   # Run zenup
   zendev devshell
   zenup [args]

   # Install a zenpack in Zendev: Log into container, then do install.
   # This won't work in Beta or Release images. See below.
   zendev devshell 
   zenpack --link --install /mnt/src/zenpacks/ZenPacks.zenoss.ControlCenter

   # Attach
   zendev attach mysql


Container Creation Specifics
=============================
::

      # zendev devshell: defaults to a Zope imports
      zendev devshell

      # Create a Zenhub imports environment this way
      zendev devshell zenhub

