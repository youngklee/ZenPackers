Managing Containers 
=====================================================================

This section covers various Serviced container topics.

How to Customize and Commit a Container
------------------------------------------
To customize a container and make those changes permanent::

    [zenoss@cc]: serviced service shell -i -s mychange zope bash

    [root@ZOPE]: su - zenoss
    [zenoss@ZOPE]: [make your change change changes in the shell]
    [zenoss@ZOPE]:  exit
    [root@ZOPE]:  exit

    [zenoss@cc]: serviced snapshot commit mychange
    [zenoss@cc]: serviced service restart ...


For example: To add PyYAML to the zope containers::

    [zenoss@cc]: serviced service shell -i -s mychange zope bash

    [root@ZOPE]: su - zenoss
    [zenoss@ZOPE]: easy_install pyyaml
    [zenoss@ZOPE]: zendmd

       In [1]: import yaml
         => (if no errors, its installed correctly)
     
    [zenoss@ZOPE]: exit
    [root@ZOPE]:  exit

    [zenoss@cc]: serviced snapshot commit mychange
    [zenoss@cc]: serviced service restart ...

Installing Linked Zenpack that needs Maven, Java, etc...
---------------------------------------------------------

ZenPacks that need maven offer a slight problem, because you need to install
Maven and Java (OpenSDK) to get them installed in link-mode. There is also a
minor package dependency problem in zenoss-centos-deps.

They can be installed in the following way in a container::

    
    [zenoss@cc]:serviced service attach zenhub

    [root@Zenhub]: yum remove zenoss-centos-deps
    [root@Zenhub]: yum install maven
    [root@Zenhub]: su - zenoss

    [zenoss@Zenhub]: zenpack --link --install /z/ZenPacks.zenoss.XYZ
    ... exit out of the containers ...
    [zenoss@cc]: serviced service restart zenoss.core 

