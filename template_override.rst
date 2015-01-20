========================================
Override Standard Monitoring Templates
========================================

This question about how a user would override standard monitoring templates
has come up a few times lately.

Here's the best way of doing this:
-----------------------------------

#. Create a ZenPack such as ZenPacks.telus.vSphereExtensions
#. Specifically configure said ZenPack to depend on
   ZenPacks.zenoss.vSphere
#. Create the threshold in one of the monitoring templates delivered by
   ZenPacks.zenoss.vSphere
#. Add said monitoring template to the extension ZenPack
#. Export the extension ZenPack
#. Put the extension ZenPack in version control


Your must be aware and considerate that there's now an ordering dependency
on installing the original and extension ZenPacks. Anytime the original
ZenPack is installed, you must make sure that the extension ZenPack is
subsequently installed. Circumstances where this will happen are:

* Zenoss upgrade (only if the original ZenPack is installed by default with Zenoss)
* Zenoss RPS application (only if the original ZenPack is contained in the RPS)
* Manually installation of original ZenPack

All of this assumes that you don't think the extension would make for a
good out of the box default for the ZenPack. Let someone know if you think the
change would be widely beneficial so we can incorporate it and save you the
trouble.


