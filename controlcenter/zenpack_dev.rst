ZenPack Development: Setup in ControlCenter
================================================

Welcome to the Control Center cetnral for Zenpackers! The following sections
are hoped to bring clarity and peace to you in your quest for ZenPack
developement.

First let us establish the base directory for Zendev::

    export ZENDEV_ROOT=$(zendev root)
    $ZENDEV_ROOT/src/service/services

This folder is typically in $HOME/src/europa, but it could be elsewhere.

.. _setupdevenv:

Setting up the Development Environment
--------------------------------------

Setup for ZenPack development in ControlCenter requires a fully 
functional ZenDev environment as specified items 1-10, but
stop before starting serviced on the last line if item 10:

* https://github.com/zenoss/zendev/blob/develop/docs/installation.rst

Once you have zendev fulling installed but before starting serviced, you need
to do the following items:

* cd into your zendev home folder's Zenpack folder::

    cd $ZENDEV_ROOT/src/zenpacks/

* Now git clone all the ZenPacks you need for your project
* Edit the following file and add (or subtract) the Zenpack names from the
  ZENPACKS environment var ZENPACKS in $ZENDEV_ROOT/build/devimg/install_core.sh::

   ZENPACKS="PythonCollector ControlCenter"

* .. note:: 

   In order to have a valid Resmgr image, you'll need a LOT more
   zenpacks built into into your image. This means that the above line MUST
   look more like:

   ZENPACKS=
   \"PythonCollector
   ControlCenter
   ZenJMX
   DynamicView
   AdvancedSearch
   EnterpriseCollector
   EnterpriseSkin
   DistributedCollector
   ImpactServer
   Impact
   \"

* Now rebuild the devimg::

   zendev build devimg

* [Optional but recommended]: Pull docker images to avoid timeouts at deployment :

   docker pull zenoss/serviced-isvcs:v16
   docker pull zendev/devimg:latest
   docker pull zenoss/hbase:v2
   docker pull zenoss/opentsdb:v3

* Now start serviced::

   zendev serviced --reset --deploy

* Then start the application (yes, case-insensitive)::

   zendev serviced service start zenoss.core 

* Watch the services with::

   watch serviced service status

*  .. WARNING:: 
      
      Don't use the GUI to start the application as that currently uses a lot
      of resources. This will eat up a lot of CPU and memory just to render a
      few graphs.


* Now Zenoss will run on the same IP but with a virtual name: 'zenoss5x.*':
  So if your host is xyz.zenoss.loc, your Zenoss will run on::

    zenoss5x.xyz.zenoss.loc

  You will need to either do one of two things to connect to Zenoss:

  A. Add an entry into your /etc/hosts::

      192.168.1.45 xyz.zenoss.loc zenoss5x.xyz.zenoss.loc hbase.xyz.zenoss.loc

  B. Add a CNAME entry in your DNS that points zenoss5x to xyz.zenoss.loc

* You should be able to connect now to: https://zenoss5.xyz.zenoss.loc
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

.. Warning::

   **The normal user to attach to a container with is root! This will cause
   you many sleepless nights and untold problems because zenoss commands as
   root will change file owernship. Instead use the "zenoss" user. To make this easy,
   you can use this bash function described in section:**
   `Attaching to Containers`_

* References

  + http://zenoss.github.io/zendev/devimg.html
  + http://zenoss.github.io/zendev/installation.html#ubuntu


_______________________________________________________________________________

Updating Zendev, Bare Bones Style
-----------------------------------

Updating Zendev is getting simpler. Eventually there will be a single button
to push. Until that time try these directions:

* sudo stop docker
* sudo umount $(grep 'aufs' /proc/mounts | awk '{print$2}' | sort -r)
* sudo rm -fr /var/lib/docker
* sudo reboot (Host System)

  - Log back in to host system

* sudo start docker (if not started)
* zendev selfupdate; zendev sync
* cdz serviced && make clean && make

  - That will create devimg and pull in isvcs

* zendev build devimg --clean
* zendev serviced -dx

  - This will start serviced and pull other images

To cut-n-paste::

     sudo stop docker                                                              
     sudo umount $(grep 'aufs' /proc/mounts | awk '{print$2}' | sort -r)           
     sudo rm -fr /var/lib/docker                                                   
     sudo reboot
     # Log in to host
     sudo start docker
     zendev selfupdate; zendev sync                                                
     # Now time to build serviced and zendev
     cdz serviced && make clean && make                                            
     zendev build devimg --clean
     zendev serviced -dx
     
______________________________________________________________________________

Installing Zenpacks for Development
--------------------------------------------

In development we usually need to install the zenpacks in link-mode.
To do this note that zenpacks in your zendev: $ZENDEV_ROOT/src/zenpackas/*
will be located in the container at /mnt/src/zenpacks/* . So here is the 
process:

#. Attach to the Zope Container. If you have more than one, use the UUID::

    serviced service attach Zope

#. cd /mnt/src/zenpacks
#. Make sure your zenpack is present
#. zenpack --link --instal ZenPacks.zenoss.XYZ


Sometimes you have no choice but to install using Egg. In that case
you must be in the host system (zendev or otherwise)::

    serviced service run zope zenpack install ZenPacks.zenoss.OpenStack-XXX.egg

_______________________________________________________________________________

Serviced Essentials
---------------------
Here are some Serviced topics are relevant.

Getting Listings
~~~~~~~~~~~~~~~~~

You'll want to remove all non-ascii characters from a serviced command output. 
This is because **serviced service list** will output some
non-ascii "tree" characters that can make the awk error prone. Do it like this::

   serviced service list |  tr -cd '\11\12\40-\176'

Now use that output to capture any SERVICE_ID like this::

   ID=$(serviced service list | grep zenmodeler | tr -cd '\11\12\40-\176' | awk '{print $2}')

Attaching to Containers
~~~~~~~~~~~~~~~~~~~~~~~~

Serviced has a utility to attach to containers. By default the user you
attach with is root, which is **BAD** if you intend to issue zenoss commands.

You can attach to a container as root by simply doing::

   serviced service attach <NAME>

where <NAME> is one of the services (zendev, zeneventserver, Zope, etc..).
But as mentioned above, doing anything that involves Zenoss will change the
ownership of files in /opt/zenoss and potentially *BREAK* your install.

Instead, place this bash function in your .bashrc::

    attach()
    {
       local target=$1
       serviced service attach $target su - zenoss
    }

then you can just do a::

   attach zenhub

You can also just do it manually::

   serviced service attach zenhub su - zenoss

Editing Serviced Service Definitions From CLI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are unwilling or unable to use the GUI to edit services, this will be an
invaluable tool for 5X. The method is simple, find the ID, and use serviced to
edit the serviced template.

* Find the ID for a service. In our example Zope::

    ZOPE_SERVICE_ID=$(serviced service list | grep Zope | awk '{print $2}')

* To edit the Zope service definition::

    serviced service edit zope
    # or the old fashioned way:
    serviced service edit $ZOPE_SERVICE_ID

* Once you have finished editing the service you can verify it by either
  looking at the GUI or re-editing the GUI.

* Restart the Service. There are two ways, the first way in 
  the link :download:`serviced.init <serviced.init>` is preferred:

  -  Using the script::
        
      serviced.init  restart

  -  Manually:

      * Kill serviced manually
      * zendev serviced

.. note:: **You must restart Zope to activate your changes.**

Monitoring Logs in Zendev
---------------------------------------------
Monitoring logs in Zendev is easier than one might think. 
That is because the entire Zenoss core folder is bind-mounted 
from the Zendev environment across **ALL** Zope containers.
You don't need to access *ANY* container to see them.

The logs are located in: $ZENDEV_ROOT/zenhome/log/ .
If Serviced and Zenoss are active you should see
these files being updated often.


Testing Modelers, Collectors, and Services
---------------------------------------------

In the 4.X world we usually turn off the services and run them manually.
This still can work in 5.X. First you must stop the container that
has the service you want to test, then you run it manually from another
container like Zope. Here are the steps:

* Identify the service you want to test, and grab the ID.
  We use  **zenmodeler** for example::

* Turn off the **zenmodeler** container in the GUI or manually::

    [zenoss@mp6:~]: serviced service  stop zenmodeler

* Attach to another service like Zope and run zenmodeler manually::

    [zenoss@mp6:~]: zendev attach Zope
      Yo, you can probably just use serviced attach

    [root@zope /]# zenmodeler run -d xyz.zenoss.loc -v10

      2014-07-05 00:56:58 DEBUG zen.ZenModeler: Run in foreground, starting immediately.
      2014-07-05 00:56:58 DEBUG zen.ZenModeler: Starting PBDaemon initialization
      ...etc...
      ...etc...

* When you are finished with your debug session just exit the container
  and restart your zenmodeler service (if you want it to run)::

   (zenoss)[root@zope /]# exit
   [zenoss@mp6:~]: serviced service  stop  24x2cfz4b16ww8gakhgcgnv87

Cross Mounted Directories!
---------------------------------------------

Experimentation shows that there are several shared directories in the
containers. Your core and zenpacks will be shared from your Zendev development
directories.

If you edit core code in one container it is changed in other
containers that share this. This includes:

   +-------------------------------+-----------------------+------------------+
   +-------------------------------+-----------------------+------------------+
   | Share Source                  | Target Mount Point    | Mount Type       |
   +===============================+=======================+==================+
   | $DEV:$ZENDEV_ROOT/src/core    | /mnt/src/core         |   NFS (From Dev) |
   +-------------------------------+-----------------------+------------------+
   | $DEV:$ZENDEV_ROOT/zenhome     | /opt/zenoss           |   NFS (From Dev) |
   +-------------------------------+-----------------------+------------------+
   | /mnt/src/core/Products        | /opt/zenoss/Products  |   Local          |
   +-------------------------------+-----------------------+------------------+
   | /opt/zenoss/otherwise         | /opt/zenoss/otherwise |   Local          |
   +-------------------------------+-----------------------+------------------+


Questions and Possible Answers
---------------------------------------------

* What is the best way to debug the container processes?
  Candidates include:

  - dgbp: http://docs.activestate.com/komodo/4.4/debugpython.html
  - winpdb: http://winpdb.org/docs/embedded-debugging/

* How do run Zope in the foreground?
  Suggested (untested) answer: *serviced service attach* an existing Zope
  container, edit zope.conf to increment the zope port, and then zopectl fg
  will start another zope in the foreground. whether that will enable you to
  hit that instance with a browser is unknown.

* Can I Run Zenhub in the foreground?

  According to the experts, Maybe. In fact, you can run zenhub in the foreground
  using a different shell. However if you actually want other daemons to
  connect to your new zenhub, that won't work because of TCP port mismatch.

  One solution is to attach to the Zenhub container, kill and start Zenhub
  in the foreground in one step::

     zendev attach zenhub
     pid=$(ps ax | grep -E "[[:digit:]]{2} su - zenoss -c" | awk '{print $1;}')
     kill $pid; zenhub run -v10 --workers 0
  
  Zenhub must be in in full contact with all the other containers via TCP port
  connections. The fallback plan is us use a remote debugger like winpdb or dbgp.

* You upgraded Go, but you can't build anymore. You get errors like this::

   ../domain/metric.go:10: import
   $ZENDEV_ROOT/src/golang/pkg/linux_amd64/github.com/zenoss/glog.a:
   object is [linux amd64 go1.2.1 X:none] expected [linux amd64 go1.3 X:precisestack]

  The problem is that you have older libraries from prior version of go. You
  need to clean out the older libraries and rebuild::

      rm $GOPATH/pkg/* -Rf
      cdz serviced
      make clean
      make

* Your entire Zendev environment seems broken, and builds fail. What to do?

  You may have broken your zendev environment by upgrading or getting some 
  environment vars wrong. Check those env vars and try this::

     zendev restore develop:wq
    
* Unit Tests::

     zendev devshell run tests


