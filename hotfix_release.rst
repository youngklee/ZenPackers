========================================================================
HotFix Release Notes
========================================================================

Target develop to next minor release if it's not already so:
===============================================================================

    #. git checkout develop
    #. git pull
    #. => edit setup.py: change VERSION 2.2.1dev -> 2.3.0dev
    #. git commit -a -m "Start 2.3.0 Release: Version 2.2.1dev -> 2.3.0dev"
    #. git push

Start the hotfix for the next patch release if it's not already started:
===============================================================================

    #. git checkout master
    #. git pull
    #. git flow hotfix start 2.2.1
    #. => edit setup.py: change VERSION 2.2.0 -> 2.2.1dev
    #. git commit -a -m "Start 2.2.1 Hotfix: Version 2.2.0 -> 2.2.1dev"
    #. git push

Commit changes to hotfix:
===============================================================================

    #. => make and commit changes needed in 2.2.1 hotfix including README.mediawiki updates.
    #. git push

Finish hotfix when all changes are committed:
===============================================================================

    #. => edit setup.py: change VERSION 2.2.1dev -> 2.2.1
    #. git commit -a -m "Finish 2.2.1 Hotfix: Version 2.2.1dev -> 2.2.1"
    #. git flow hotfix finish
    #. git push --all
    #. git push --tags

Build the Master on Jenkins
===============================================================================

Now run a build of the master-ZenPacks.zenoss.X Jenkins job if it hasn't
already run it, and verify that the artifact has the new (2.2.1) version
with no dev suffix.

Hotfix with a Single Patch
===============================================================================

.. NOTE:: For a hotfix with a single patch that isn't going to remain open
          for additional patches you just run through all of these steps
          sequentially. We broke them out to make it clear that a hotfix branch can
          remain open for a while and the process is less synchronous in that case.


