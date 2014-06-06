========================================================================
Jenkins a la Solutions
========================================================================

Jenkins is a automated build system.

General Points and Goals
------------------------------------------------------------------------
Jenkins does a number of automatic ZenPack building tasks.
We currently have 2 Jenkins servers:

* jenkins.zenosslabs.com (Solutions)
* jenkins.zenoss.com

Task List
--------------------------------------------------------------

Jenkins task list is the entry point. It allows you to search for specific
builds. If you search these

* Master: Builds latest release
* Develop: Builds latest develop branch
* Request: Pull Requests: Feature -> Develop merge build tests

Zenpack Workflow Setup: Git Flow
--------------------------------------------------------------

* Make your zenpack in Github with a Develop branch
* Install and Enable Git Flow
* Push your development branch up to Github

  <bash>: git flow init -f 
  <bash>: git flow feature start ZEN-1234
   .... do your work ....
  <bash>: git commit -am "I changed something"
  <bash>: git push 

* Now go up to Github and create a pull request
* Someone else will review and merge
* See the documents on Git for workflow examples


Go to Jenkins and Probe Build
----------------------------------------------

* Jenkins has a 5 minute delay
* You can force build (Build Now)
* Must have set your "dev" suffix on your version
* Jenkins will automatically increment the dev number and commit hash

Releasing 
-------------------------

* Once devel is stable you can release: (See Git docs on release...)
* Download the egg and push it to Parature.

New Builds
-------------------------

* add-zenpack-jobs -o zenoss -t <very_long_hash_key>

Tests on Builds
----------------
* Unit tests are not yet available
* Jenkins will spin-up a 4.2.4 Zenoss and compile the egg
* All Java artifacts are imported each time
* Includes: See the Manifest.in file


