=====================================================================
Startup: Serviced A-la-Carte
=====================================================================

This describes how to run and update serviced in a non-development 
environment. Later we show how to update this environment in a similar
way.

Requirements
---------------

* You must have setup zendev on an Ubuntu 14.04 system or better.
* Make sure your **zenoss** user is in the docker group, otherwise you need sudo
  for all docker commands..

.. note:: See https://github.com/zenoss/serviced/wiki/Starting-CP-Beta 

Docker Prep
~~~~~~~~~~~

Only do this once.
Docker will store credentials in your account:: 

   sudo docker login -u zenossinc+alphaeval -e "alpha2@zenoss.com" \
     -p GETTHEMAGICKEYFROMTHESOURCE \
     https://quay.io/v1/


.. include:: version.rst

You need to grab the magic key from your docker manager.
Only do once per revision or as needed:: 

   # Pull the images...
   sudo docker pull quay.io/zenossinc/daily-zenoss5-${IMAGE}:5.0.0_${BUILD}
   sudo docker pull quay.io/zenossinc/opentsdb:latest
   sudo docker pull quay.io/zenossinc/hbase


Setup Zendev Services: 
--------------------------
Execute the following::

   zendev use europa
   cdz serviced

Starting Serviced  
-----------------

You can do it one of 2 ways, I prefer the first, which 
requires you install my :download:`serviced.init <serviced.init>`  in your ~/bin. 
It also logs to /tmp/serviced.log

* serviced.init start
* cdz serviced ; serviced -master -agent (Don't use this please)

Add a Host::

   export IP_ADDRESS=$(ifconfig eth0 | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}')
   serviced host add $IP_ADDRESS:4979 default

Compile Template:
-------------------
::

   serviced template compile $(zendev root)/build/services/Zenoss.resmgr > /tmp/Zenoss.xxx.tpl

( or pipe it into the following command )
 
Add the Template:
------------------
::

  TEMPLATE_ID=$(serviced template add /tmp/Zenoss.xxx.tpl)

.. note:: Make sure you keep track of the TEMPLATE_ID number
 

Deploy the Template:
--------------------

Method 1: CLI
~~~~~~~~~~~~~~~
Examples::

   serviced template deploy $TEMPLATE_ID default zebra
   serviced template deploy $TEMPLATE_ID default zenoss


Method 2: GUI
~~~~~~~~~~~~~~~

* Go to the UI at: https://you.own.ip/ and Log in as zenoss/zenoss. 
* Deploy template. 
* Done.

