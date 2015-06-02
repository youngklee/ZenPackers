========================================================================
HotFix Release Notes
========================================================================

Target develop to next minor release if it's not already so:
===============================================================================

    #. git checkout develop
    #. git pull
    #. => Edit setup.py: change VERSION 2.2.1dev -> 2.3.0dev
    #. git commit -a -m "Start 2.3.0 Release: Version 2.2.1dev -> 2.3.0dev"
    #. git push

Start the hotfix for the next patch release if it's not already started:
===============================================================================

    #. git checkout master
    #. git pull
    #. git flow hotfix start 2.2.1
    #. => Edit setup.py: change VERSION 2.2.0 -> 2.2.1dev
    #. git commit -a -m "Start 2.2.1 Hotfix: Version 2.2.0 -> 2.2.1dev"
    #. git flow publish

Commit changes to hotfix:
===============================================================================

    #. => Make and commit changes needed in 2.2.1 hotfix 
        a) git flow feature start ZEN-XXX hotfix/2.2.1
        b) commit fixes
        c) git flow feature publish ZEN-XXX
        d) make pull request from feature/ZEN-XXX to hotfix/2.2.1
        e) review and merge
        f) git checkout hotfix/2.2.1
        g) git pull
        h) repeat with other existing issues

    #. => Update README.mediawiki as required 
    #. git push

Finish hotfix when all changes are committed:
===============================================================================

    #. => Edit setup.py: change VERSION 2.2.1dev -> 2.2.1
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


.. Note:: You should be familiar with the details of :ref:`zenpack_release_notes`
          if you have any questions concerning release details.
