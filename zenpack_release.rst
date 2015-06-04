.. _zenpack_release_notes:

=====================================
Zenpack Release Notes
=====================================

We have a formal process for releasing Zenpacks.
The steps are:

* 3rd Party Software approval
* Ensure an appropriate copyright is included in each source file
* Process the Repo through Git-Flow
* Build the Master Egg on Jenkins
* Inform the Release Team
* Publish the Documentation on Wiki

.. warning::

  Do not cut-and-paste from the HTML of this document. The HTML contains
  control characters that will corrupt your git commands!
  Instead you can use the source from github at
  git@github.com:zenoss/ZenPackers.git

3rd Party Software Approval
================================

This is covered above. Please see that document.

Appropriate copyright for each Source File
============================================

Something similar to this should be in each sourcecode file::

   ############################################################################
   #
   # Copyright (C) Zenoss, Inc. 2014 all rights reserved.
   #
   # This content is made available according to terms specified in
   # License.zenoss under the directory where your Zenoss product is installed.
   #
   ############################################################################

Process Repo through Git-Flow
===============================
We use *Git Flow* to release with some custom conventions.
Refer to :ref:`gitflow_setup` for details.

Set the Version
----------------

First pick a version: We recommend using a format x.y.z, typically starting at
1.0.0 (though you can start at 0.x.y if you want.) The first digit is the major
version, the second is the minor version, and the third is the revision.

Set this version in the $ZP_HOME/setup.py file. We use these version number
variables as examples::

   export OLD=3.0.1       # (The previous Master release)
   export CURRENT=3.0.2   # (The current Develop -> new Master release)
   export NEW=3.0.3       # (The new Develop branch after release)

Start the Release Process
----------------------------------
Starting from a clean *develop* branch::

   git checkout develop
   git status
   (ensure develop is clean)

* Start the Release::

    git flow release start $CURRENT

* Update the README.mediawiki and associated docs:

  - Make sure to update essential functionality that has changed
  - Make sure to update the **Changes** section 
  - Include any relevant fixes
|
* Edit setup.py (set the correct version numbers):

  - Typically you just remove the "dev" in the version number
  - Ensure that the version is the $CURRENT value
|
* Commit:

  - For new release::

      git commit -a -m "release: version $CURRENT"

  - For update release::

      git commit -a -m "release: version ${OLD} -> ${CURRENT}"


* Finish the release::

    git flow release finish $CURRENT

  - **You will be prompted for the *Commit String*, enter:**
  - "tag $CURRENT"
  - You will automatically pushed back into develop
|
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


Publish the ZenPack Egg
==============================

OpenSource Zenpacks
-----------------------
For OpenSource zenpacks, our MediaWiki should take care of grabbing the source
and building the Egg. This only happens with the right tag:

* Go into the MediaWiki Page for your ZP
* Log in (if not already)
* Add the **Git Tag** you created above in the release phase. (cf: $CURRENT)
* MediaWiki should grab the source, build it, and post the link on the ZP page.
* Ensure that the correct "Source URI" is listed, usually the Git-Clone URL. 

Commercial Zenpacks
-----------------------

* For commercial ZenPacks, we send the Egg to Rusty or some higher authority.

  - You need to let us know that you have a released a commercial ZP.
  - Consult Chet, John C, Rusty, or the equivalent with questions.

* First: Go to the master branch on Jenkins and build it. This will look like::

   http://jenkins.zenosslabs.com/job/master-ZenPacks.zenoss.XYZ/

* Email the ZP to Rusty: rwilson@zenoss.com

  - Include a list of all dependencies in the email body.

Publish the Documentation on Wiki
=================================

Update your documentation. At the very least:

* Update the http://wiki.zenoss.org version of your docs as per 
  your corrections to README.mediawiki in section `Start the Release Process`_ :

  - Make sure to update essential documentation that has changed
  - Make sure to update the **Changes** section 
  
