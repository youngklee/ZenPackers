Installing Impact in Zendev
=====================================================================

* Pull and tag latest impact image (Currently 121)::

   # Note: Need to use an user that has docker privileges
   IMPACT_IMAGE_TAG=4.2.6.70.0_121
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

   - The zenpacks are in $zendev/src/enterprise-zenpacks/ . Call it $EZ
   - You must install them in link mode
   - You should use the devshell environment: zendev devshell

   The install now::

      zenpack --link --install $EZ/ZenPacks.zenoss.ZenJMX
      zenpack --link --install $EZ/ZenPacks.zenoss.DynamicView
      zenpack --link --install $EZ/ZenPacks.zenoss.AdvancedSearch
      zenpack --link --install $EZ/ZenPacks.zenoss.EnterpriseCollector
      zenpack --link --install $EZ/ZenPacks.zenoss.EnterpriseSkin
      zenpack --link --install $EZ/ZenPacks.zenoss.DistributedCollector
      zenpack --link --install $EZ/ZenPacks.zenoss.ImpactServer
      zenpack --link --install $EZ/ZenPacks.zenoss.Impact

* Restart zenoss:

  - serviced service stop zenoss.core
  - serviced service start zenoss.core


