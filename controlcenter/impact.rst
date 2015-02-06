Installing Impact in Zendev
=====================================================================

* Pull and tag latest impact image (Currently 121)::

   # Note: Need to use an user that has docker privileges
   export IMPACT_IMAGE_TAG=4.2.6.70.0_130   # Warning: this tag changes!
   docker pull zenoss/impact-unstable:$IMPACT_IMAGE_TAG
   docker tag zenoss/impact-unstable:$IMPACT_IMAGE_TAG zenoss/impact-unstable:latest

* Deploy zenoss.core or resmgr:
  # Use whatever workflow you wish to add and deploy core/resmgr service

* Start services:
  It is best to start all services.  If you prefer, this subset is the
  minimal that necessary for zenpack install: for svc in mysql rabbitmq /redis
  zencatalogservice zeneventserver ; do serviced service start $svc ; done

* Install Impact ZenPacks:

  Note: 

   - You must install them in link mode
   - You should not use the devshell environment (its broken): 
     Instead use zope container: zendev attach zope
     Optionally (from zendev): zendev attach zope su - zenoss -c "zenpack --list"

   - ***CRITICAL***: Make sure that ImpactServer and Impact zenpacks are on the
     develop branch. Zendev may put them on master by default.

   - Enterprise zenpacks are in /mnt/src/enterprise-zenpacks/, aka: $EZ::

     export EZ=/mnt/src/enterprise_zenpacks

   - Normal zenpacks are in /mnt/src/zenpacks/, aka: $ZP ::
     
     export ZP=/mnt/src/zenpacks


   The install now::

      zenpack --link --install $ZP/ZenPacks.zenoss.ZenJMX

      zenpack --link --install $EZ/ZenPacks.zenoss.DynamicView
      zenpack --link --install $EZ/ZenPacks.zenoss.AdvancedSearch
      zenpack --link --install $EZ/ZenPacks.zenoss.EnterpriseCollector
      zenpack --link --install $EZ/ZenPacks.zenoss.EnterpriseSkin
      zenpack --link --install $EZ/ZenPacks.zenoss.DistributedCollector
      zenpack --link --install $EZ/ZenPacks.zenoss.ImpactServer

* Before you install the Impact zenpack, you **MUST** have ImpactServer 
  running::

   serviced service start Impact

* Now you can finally install the Impact zenpack::

   zenpack --link --install $EZ/ZenPacks.zenoss.Impact

* Optionally install any zenpacks you are testing under Impact

* Restart zenoss:

  - serviced service stop zenoss.core
  - serviced service start zenoss.core


