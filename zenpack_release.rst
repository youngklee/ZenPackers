=====================================
Zenpack Release Notes
=====================================

We have a formal process for releasing Zenpacks.
The steps are:

* 3rd Party Software approval
* Ensure an appropriate copyright is included in each source file
* Set the Version
* Release to Master
* Publish the Documentation on Wiki

.. warning::

  Do not cut-and-paste from the HTML of this document. The HTML contains
  control characters that will corrupt your git commands!

3rd Party Software Approval
--------------------------------

This is covered above. Please see that document.

Appropriate copyright for each Source File
--------------------------------------------

Something similar to this should be in each sourcecode file::

   ############################################################################
   #
   # Copyright (C) Zenoss, Inc. 2014 all rights reserved.
   #
   # This content is made available according to terms specified in
   # License.zenoss under the directory where your Zenoss product is installed.
   #
   ############################################################################

Set the Version
----------------

First pick a version: We recommend using a format x.y.z, typically starting at
1.0.0 (though you can start at 0.x.y if you want.) The first digit is the major
version, the second is the minor version, and the third is the revision.

Set this version in the $ZP_HOME/setup.py file. We use these version number
variables as examples::

   OLD=3.0.1       # (The previous Master release)
   CURRENT=3.0.2   # (The current Develop -> new Master release)
   NEW=3.0.3       # (The new Develop branch)

Release to Master
------------------
We use *Git Flow* to release with some custom conventions:

First we select a RELEASE name according to version name.


Checkout Master and Develop
-----------------------------

Starting from a clean *develop* branch:


* Start the Release::

    git flow release start $CURRENT

* Edit setup.py (set the correct version numbers):

  - Typically you remove the "dev" in the version number

* Commit:

  - For new release::

    git commit -a -m "release: version $CURRENT"

  - For update release::

    git commit -a -m "release: version ${CURRENT}dev -> $CURRENT"


* Finish the release::

    git flow release finish $CURRENT

  - **You will be prompted for the *Commit String*, enter:**

  - "tag $CURRENT"

  - You will automatically pushed back into develop

* Update develop's setup.py: Bump number and add "dev":

    - Example: $CURRENT -> ${NEW}dev

* Commit again::

    git commit -a -m "post release: $CURRENT -> ${NEW}dev"


* Push and tag the  revision with a crpyto-secure key for reference::

    git push
    git push --tags  # ( <- thats a double-dash! )

* Finally, push up the master changes::

    git checkout master
    git push
    git checkout develop


Build the Master on Jenkins
---------------------------

Go to the master branch on Jenkins and build it.
This will look like

http://jenkins.zenosslabs.com/job/master-ZenPacks.zenoss.XYZ/

Send Notice to Zenoss Team
-----------------------------

.. Note::

   You need to let someone know that you have a released ZP.
   Consult Chet, John C, Rusty, or the equivalent.

Method A: Required
~~~~~~~~~~~~~~~~~~~

* Email the ZP to Rusty: rwilson@zenoss.com


