*********************************************
ZenPack Development Setup in ControlCenter
*********************************************

Welcome to the Control Center cetnral for Zenpackers! The following sections
are hoped to bring clarity and peace to you in your quest for ZenPack
developement.

_______________________________________________________________________________

Setting up the Development Environment
--------------------------------------

Setup for ZenPack development in ControlCenter requires a fully 
functional ZenDev environment as specified items 1-10, but
stop before starting serviced on the last line if item 10:

* http://zenoss.github.io/zendev/installation.html#ubuntu

Once you have zendev fulling installed but before starting serviced, you need
to do the following items:

* cd into your zendev home folder's Zenpack folder::

    cd ~/src/europa/src/zenpacks/

* Now git clone all the ZenPacks you need for your project
* Edit the following file and add (or subtract) the Zenpack names from the
  ZENPACKS environment var ZENPACKS in ~/src/europa/build/devimg/install_core.sh::

   ZENPACKS="PythonCollector ControlCenter"

* Now rebuild the devimg::

   zendev build devimg

* Now start serviced::

   zendev serviced --reset --deploy

* Then after the app was deployed, but before starting it, change the Zope
  startup command (in the GUI) to::

   su - zenoss -c "PYTHONPATH=/opt/zenoss/lib/python /opt/zenoss/bin/zopectl fg"
      
* Then start the application in the GUI.

* Now Zenoss will run on the same IP but with a virtual name: 'zenoss5x.*':
  So if your host is xyz.zenoss.loc, your Zenoss will run on::

    zenoss5x.xyz.zenoss.loc

  You will need to either do one of two things to connect to Zenoss:

  A. add an entry into your /etc/hosts::

      192.168.1.45 xyz.zenoss.loc zenoss5x.xyz.zenoss.loc hbase.xyz.zenoss.loc

  B. Add a CNAME entry in your DNS that points zenoss5x to xyz.zenoss.loc

* You should be able to connect now to: https://zenoss5x.xyz.zenoss.loc
  If not, go back and check your networking setup.

* Once you can connect, you must connect to the container for the daemon
  you are debugging. For example, to debug modeling you connect to the modeler
  container::

   zendev attach zenmodeler
     -or-
   serviced service attach zenmodeler

.. NOTE::

     **Since you can have multiple containers running a service you may want to
     reduce that to a single service. This is done in the ControlCenter GUI
     by changing the Instance value, saving,  and restarting.**

* References

  + http://zenoss.github.io/zendev/devimg.html
  + http://zenoss.github.io/zendev/installation.html#ubuntu

_______________________________________________________________________________

Extra Topics for 5X ZenPack Dev
---------------------------------

Serviced Preliminaries
=======================

* You'll want to remove all non-ascii characters from a serviced command output. 
  This is because **serviced service list** will output some
  non-ascii "tree" characters that can make the awk error prone. Do it like this::

     serviced service list |  tr -cd '\11\12\40-\176'

  Now use that output to capture any SERVICE_ID like this::

     ID=$(serviced service list | grep zenmodeler | tr -cd '\11\12\40-\176' | awk '{print $2}')

Editing Serviced Service Definitions From CLI
================================================

If you are unwilling or unable to use the GUI to edit services, this will be an
invaluable tool for 5X. The method is simple, find the ID, and use serviced to
edit the serviced template.

* Find the ID for a service. In our example Zope::

    ZOPE_SERVICE_ID=$(serviced service list | grep Zope | awk '{print $2}')

* Now edit that service like this::

    serviced service edit $ZOPE_SERVICE_ID

* Once you have finished editing the service you can verify it by either
  looking at the GUI or re-editing the GUI.

* Restart the Service. There are two ways, the first way in 
  :download:`serviced.init <serviced.init>` is preferred by me:

  -  Using the script::
        
      serviced.init  restart

  -  Manually:

      * Kill serviced manually
      * zendev serviced

.. note:: **You must restart Zope to activate your changes.**

Testing Modelers, Collectors, and Services
================================================

In the 4.X world we usually turn off the services and run them manually.
This still can work in 5.X. First you want to turn off the container that
has the service you want to test, then you run it manually from another
container like Zope. Here are the steps:

* Identify the service you want to test, and grab the ID.
  We use  **zenmodeler** for example::

   [zenoss@mp6:~]: serviced service list | grep zenmodeler
     > zenmodeler  24x2cfz4b16ww8gakhgcgnv87  1  ...etc..


* Turn off the **zenmodeler** container in the GUI or manually::

    [zenoss@mp6:~]: serviced service  stop 24x2cfz4b16ww8gakhgcgnv87

* Attach to another service like Zope and run zenmodeler manually::

    [zenoss@mp6:~]: zendev attach Zope
      Yo, you can probably just use serviced attach

    (zenoss)[root@88e2a452751e /]# zenmodeler run -d xyz.zenoss.loc -v10

      2014-07-05 00:56:58 DEBUG zen.ZenModeler: Run in foreground, starting immediately.
      2014-07-05 00:56:58 DEBUG zen.ZenModeler: Starting PBDaemon initialization
      ...etc...
      ...etc...

* When you are finished with your debug session just exit the container
  and restart your zenmodeler service (if you want it to run)::

   (zenoss)[root@88e2a452751e /]# exit
   [zenoss@mp6:~]: serviced service  stop  24x2cfz4b16ww8gakhgcgnv87

Cross Mounted Directories!
===========================

Experimentation shows that there are several shared directories in the
containers. If you edit core code in one container it is changed in other
containers that share this. This includes:

   +----------------------------+-----------------------+------------------+
   +----------------------------+-----------------------+------------------+
   | Share Source               | Target Mount Point    | Mount Type       |
   +============================+=======================+==================+
   | $DEV:~/src/europa/src/core | /mnt/src/core         |   NFS (From Dev) |
   +----------------------------+-----------------------+------------------+
   | /mnt/src/core/Products     | /opt/zenoss/Products  |   Local          |
   +----------------------------+-----------------------+------------------+
   | /opt/zenoss/otherwise      | /opt/zenoss/otherwise |   Local          |
   +----------------------------+-----------------------+------------------+


Questions and Possible Answers
================================

* What is the best way to debug the container processes?
  Candidates include:

  - dgbp: http://docs.activestate.com/komodo/4.4/debugpython.html
  - winpdb: http://winpdb.org/docs/embedded-debugging/

* How do run Zope in the foreground?
  Suggested (untested) answer: *serviced service attach* an existing Zope
  container, edit zope.conf to increment the zope port, and then zopectl fg
  will start another zope in the foreground. whether that will enable you to
  hit that instance with a browser is unknown.

