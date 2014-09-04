===========================
CP Beta and Release Images
===========================


Installing Zenpacks in Beta Images
------------------------------------

Typical commands in the Beta and Release containers are different from Zendev
For example, there is no link-install in the following::

   serviced service run -i zope zenpack [args]
     or
   serviced service run -i zope zenpack install ZenPacks

For example::

   serviced service run -i zope zenpack install ZenPacks.zenoss.DB2-XYZ.egg

.. NOTE::

   Don't install from /root where perms are not readable by non-root.
   The Zenpack egg must be in a readable folder like /tmp

   Also, note there are *NO* double-dashes on the zenpack options.

