==========================
General Concepts for CP
==========================

Links for Serviced
=========================

* https://github.com/zenoss/serviced/wiki
* https://github.com/zenoss/serviced/wiki/Starting-CP-Beta

General Links for Zendev
=========================

* http://zenoss.github.io/zendev
* http://zenoss.github.io/zendev/devimg.html

Development Workflow Cycle
===========================

Normally, once you deploy zendev, your workflow is very much the same
as it always is:

* Create a feature against develop
* git flow feature publish (once only)
* Fix Fix Fix, Commit, Push
* Pull Requests etc... 
* Someone merges
* All rejoice and continue!

However, during release we have a special workflow in Zendev:

* zendev restore europa-release
* cdz serviced
* CURRENTBRANCH=$(git rev-parse --abbrev-ref HEAD)
* git flow feature start CC-1234 $CURRENTBRANCH
* git flow feature publish (once only)
* [...CODE FIX CODE FIX, COMMIT, push...]
* Someone merges
* All rejoice and continue!


General ZenDev Tasks
===========================

::

   ZOPE=$(serviced service list | grep Zope | awk '{print $2}')

   # Open zendmd
   serviced service run -i $ZOPE zendmd

   # Run zenup
   serviced service run $ZOPE zenup [args…]

   # Install a zenpack in Zendev: Log into container, then do install.
   zendev devshell 
   zenpack --link --install /mnt/src/zenpacks/ZenPacks.zenoss.ControlCenter

   # Install a zenpack
   serviced service run $ZOPE zenpack --link --install ZenPacks.zenoss.ControlCenter

   # Report daemon stats
   serviced service action $DAEMON stats

   # Set daemon to debug
   serviced service action $DAEMON debug

   # Attach
   serviced service attach $SERVICEID bash

   # Shell
   serviced service shell -i $SERVICEID bash

Container Creation Specifics
=============================
::

      # zendev devshell: defaults to a Zope imports
      zendev devshell

      # Create a Zenhub imports environment this way
      zendev devshell zenhub

