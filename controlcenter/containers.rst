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
