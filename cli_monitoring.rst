==============================================================================
Commandline Monitoring For Slackers (ZP Developers)
==============================================================================

Description
------------------------------------------------------------------------------

Zenpacks need to be monitored for debugging. Thats all you need to know!

Prerequisites
------------------------------------------------------------------------------

* Zenoss ZenPack Developement 
* Python 2.7

We assume that you are familiar with ZenPack developement and Python coding.
We further assume that you have a console/terminal/xterm open on the system
running Zenoss. The CLI prompt is **[zenoss:~]:**

Monitoring Data Collection
------------------------------------------------------------------------------

You can use these examples for **zencommand**:

* Just run it and see:

   - zencommand run -d test-oracle-1.zenoss.loc
   - zencommand run -d test-oracle-1.zenoss.loc -v 10 
     
* Show the full command in addition:

   - zencommand run -v10 --device=<dev> --show-full-command --show-raw-results

* Send it to tee to save output file:

   - zencommand run -d test-oracle-1.zenoss.loc -v 10 \|& tee /tmp/zenco.log

Device Modeling
------------------------------------------------------------------------------

You can use these examples for **zenmodeler** (notice the --now flag):

* Just run it and see:

   - zenmodeler run --now -d test-oracle-1.zenoss.loc
   - zenmodeler run --now -d test-oracle-1.zenoss.loc -v 10 

* Send it to tee to save output file:

   - zenmodeler run --now -d test-oracle-1.zenoss.loc -v 10 \|& tee /tmp/zenco.log

ZenDMD
------------------------------------------------------------------------------

ZenDMD can set and display real-time zenoss hierarchical  properties. 
You really need to use it!

* Here is an example

::

  [zenoss:~]: zendmd
   Welcome to the Zenoss dmd command shell!
   'dmd' is bound to the DataRoot. 'zhelp()' to get a list of commands.
   Use TAB-TAB to see a list of zendmd related commands.
   Tab completion also works for objects -- hit tab after an object name and '.'
   (eg dmd. + tab-key).
   >>> device = find("test-oracle-1.zenoss.loc")
   >>> device.oracle_instances()[0]
   <Instance at /zport/dmd/Devices/Server/Linux/devices/test-oracle-1.zenoss.loc/oracle_instances/orainst-XE>
   >>>
   >>> device.oracle_instances()[0].instanceRole
   'PRIMARY_INSTANCE'
   >>>
   >>> device.Devices.setZenProperty("zWinPerfCycleSeconds",300)
   >>> a=device.getProperty("zWinPerfCycleSeconds")
   >>> a
   300
   >>> device.zOracleUser
   'zenoss'
   >>> exit()
  [zenoss@cdev:~/bin]:




  


