==============================================================================
Migration Guide for Slackers
==============================================================================

Zenpacks that get upgraded often need some sort of migration of configuration 
data from the older version to the new. This is achieved via migration scripts
that are described in this doc.

We assume this basic set of knowledge for this article:

* Zenoss ZenPack Development 
* Python 2.7
* Familiarity with ZenPack development and Python coding.
* We work from the base of ZP_DIR. For NetBotz for example::

   export ZP_DIR_TOP=$ZENHOME/ZenPacks/ZenPacks.training.NetBotz
   export ZP_DIR=$ZP_DIR_TOP/ZenPacks/training/NetBotz

Relative to this folder all migration scripts will reside in::

   $ZP_DIR/migrate/

In the first example_.  we have a simple migration of the
a zProperty (zOraclePassword) to the new ZP version. 
In the secont second-example_ we will see a much more significant
migration() implementation. 


##########################
Migrating Properties 
##########################


In this example DatabaseMonitor (OracleDB) is a device that inherits its
/Device base from the parent server, be it Linux, AIX, Solaris, or some
"other" operating system. This means that it needs to be able to patch itself
underneath the device tree of that server target type and not have a
stand-alone device root.

The basic code strategy is to create a class that has a "migrate" method.
The migrate() method gets called automatically by the ZenPack Installer.
The first example is a very old version that does nothing but migrate 
the password from one version to the next.

We only need to set a single zProperty value. In order to do so, we use:

.. _Products.ZenModel.migrate.MigrateUtils.migratePropertyType() : https://github.com/zenoss/pm-resmgr-4.2.4/blob/master/src/core/Products/ZenModel/migrate/MigrateUtils.py

.. _example:

MigratePassword.py::

   ##############################################################################
   # Copyright (C) Zenoss, Inc. 2009, all rights reserved.
   ##############################################################################

   import logging
   log = logging.getLogger("zen.migrate")

   import Globals
   from Products.ZenModel.migrate.Migrate import Version
   from Products.ZenModel.ZenPack import ZenPackMigration
   from Products.ZenModel.migrate.MigrateUtils import migratePropertyType

   class MigratePassword(ZenPackMigration):
       version = Version(2, 2, 0)

       def migrate(self, dmd):
           log.info("Migrating zOraclePassword")
           migratePropertyType("zOraclePassword", dmd, "string")
           
   MigratePassword()

Notice that there is a "version" line just after the class definition. 
This version must identify the new version number of the ZP being migrated to.

The migration() method is very simple; in fact just one line that uses
the migratePropertyType() method to migrate the zOraclePassword.

##############################################
Migration of Modeling Templates
##############################################

This section is specific to a modeling templates.

The Basic idea behind this migration scenario is as follows:

* Identify the old zenpack objects, bound to a device.

   - Find all device classes and devices where "Oracle" modeling template is bound.
   - Look for all **zDeviceTemplates** that are overridden

* Extract the old information from those templates

   - Leave them bound, for continuity sake.
   - Enable our modeler plugin for device class or device 
     (uses zCollectorPlugins)

* Populate the New ZP Data Structures

   - Create new Instance components from the old templates 
   - Populate the new instances or components with data
   - As always, test your migration script by installing the new ZP over
     the old.

4. Give Users Instructions on Removing Old Object Templates

   - Since you may have left the old ZP objects in tact, 
     provide documentation on how to un-bind the old templates. 


Migration Example for DatabaseMonitor
-------------------------------------------

This migration updates the older 2.X version to the 3.X version of the ZP,
and transitions from a dedicated Device to a pure component model (Instance). 
You don't need to worry about handling component binding because that is taken
care of by the actual modeler. Here is the ~migration/AddInstances.py code:


.. _second-example:
.. code-block:: python
   :linenos:
   :emphasize-lines: 31-43

   ############################################################################
   # Copyright (C) Zenoss, Inc. 2013, all rights reserved.
   # File: ~migration/AddInstances.py
   ############################################################################

   import logging
   log = logging.getLogger("zen.migrate")

   from Products.ZenModel.DeviceClass import DeviceClass
   from Products.ZenModel.migrate.Migrate import Version
   from Products.ZenModel.ZenPack import ZenPackMigration

   # You must have Oracle's modeling template bound for migration to work
   TEMPLATE_NAME = 'Oracle'
   MODELER_PLUGIN_NAME = 'zenoss.ojdbc.Instances'

   def name_for_thing(thing):
      ''' Helper function to provide the name of the Device or DeviceClass '''

       if isinstance(thing, DeviceClass):
           return thing.getOrganizerName()

       return thing.titleOrId()

   class AddInstances(ZenPackMigration):
       '''
       Main class that contains the migrate() method. Note version setting.
       '''
       version = Version(3, 0, 0)

       def migrate(self, dmd):
           ''' 
           This is the main method. Its searches for overridden objects (templates)
           and then migrates the data to the new format or properties.
           In this case bound objects get assigned the new modeler pluging.
           '''
           overridden_on = dmd.Devices.getOverriddenObjects(
               'zDeviceTemplates', showDevices=True)

           for thing in overridden_on:
               if TEMPLATE_NAME in thing.zDeviceTemplates:
                   self.enable_plugin(thing)
                   self.populate_connection_strings(thing)

       def enable_plugin(self, thing):
           ''' Associate a collector plugin with the thing we have found.
               zCollectorPlugins is used by ModelerService.createDeviceProxy() 
               to add associated (modeler) plugins to the list for self-discovery.
               ModelerService.remote_getDeviceConfig() actually calls the modelers.
           '''
           current_plugins = thing.zCollectorPlugins
           if MODELER_PLUGIN_NAME in current_plugins:
               return

           log.info(
               "Adding %s modeler plugin to %s",
               MODELER_PLUGIN_NAME, name_for_thing(thing))

           current_plugins.append(MODELER_PLUGIN_NAME)
           thing.setZenProperty('zCollectorPlugins', current_plugins)

       def populate_connection_strings(self, thing):
           ''' Just a helper method to collect data for this ZP '''
           if thing.zOracleConnectionStrings:
               return

           connection_string = (
               'jdbc:oracle:thin:'
               '${here/zOracleUser}'
               '/${here/zOraclePassword}'
               '@${here/manageIp}'
               ':${here/zOraclePort}'
               ':${here/zOracleInstance}'
               )

           log.info(
               "Setting zOracleConnectionStrings for %s",
               name_for_thing(thing))

           thing.setZenProperty('zOracleConnectionStrings', [connection_string])

   AddInstances()
      
##############################################
Pre-Install and Post-Install Migration Events
##############################################

There are certain actions that need to happen before or after the installation
process, due to different dependency requirements. We discuss both cases.

In the file __init__.py we have an install method that looks like this:

.. code-block:: python
   :emphasize-lines: 4

    def install(self, app):

        self.pre_install(app)
        super(ZenPack, self).install(app)
        self.post_install(app)

The *super* method is responsible for calling all the migration scripts.


Pre-Installation and Monitoring Templates
------------------------------------------
This section is specific to monitoring (collection) templates.

Monitoring templates get generated at install time, so it is important to 
have all the correct templates you need in the right place. Its also important
to not-have any wrong templates.

.. attention::

   This works because it's ultimately the super() method that uses objects.xml to
   create the monitoring templates you've added to the ZenPack. So if you delete
   what exists before calling super, you'll be sure to end up with
   exactly what the objects.xml contains.

Note that the following:

* The migration scripts [ in ~/migration/* ] are invoked only after the
  initial installation has taken place.

* We must remove/replace older monitoring templates in __init__.py before the
  migration scripts are invoked.

* We use ZenPacks.zenoss.CiscoMonitor as the prime example

* We must implement the pre_install() method

For our purposes the pre_install() method performs the following inside
__init__.py:

.. code-block:: python
   :linenos:
   :emphasize-lines: 1-6,30-31


    REPLACED_MONITORING_TEMPLATES = (
    'Network/Cisco/ACE/rrdTemplates/Device',
    'Network/Cisco/ASA/rrdTemplates/Device',
    'Network/Cisco/Nexus/rrdTemplates/Device',
    'Network/Cisco/rrdTemplates/Device',
    'Network/Cisco/rrdTemplates/ethernetCsmacd',
    )

    class ZenPack(ZenPackBase):
    """CiscoMonitor loader."""
    
    ...some code...

        def install(self, app):
            self.pre_install(app)
            super(ZenPack, self).install(app)
            self.post_install(app)

        def pre_install(self, app):
            """Perform work that must be done b efore normal ZenPack install."""
            # objects.xml assumes /Reports/Enterprise Reports exists. 
            # Validating the organizer exists here is cleaner than defining a 
            # hard requirement on the Enter priseReports ZenPack.
            app.zport.dmd.Reports.createOrganizer('Enterprise Reports')

            # Allow objects.xml to replace all the following monitoring templates.
            LOG.info('Preparing monitoring templates for updates')
            for subpath in REPLACED_MONITORING_TEMPLATES:
                try:
                    template = app.zport.dmd.Devices.getObjByPath(subpath)
                    template.getPrimaryParent()._delObject(template.id)
                except (KeyError, NotFound):             
                    pass


Post-Installation Migration
---------------------------

The post-installation has its own dependencies and is implemented as:


.. code-block:: python

       def post_install(self, app):
           """Perform work that can be done after normal ZenPack install."""

           self.symlinkPlugins()

           # Remove event class mappings that this ZenPack supersedes.
           try:
               net_link_ec = app.zport.dmd.Events.Net.Link
               for mapping_id in ('snmp_linkDown', 'snmp_linkUp'):

                   if mapping_id in net_link_ec.instances.objectIds():
                       LOG.info("Removing standard %s mapping", mapping_id)
                       net_link_ec.removeInstances((mapping_id,))

           except (AttributeError, KeyError):
               pass

