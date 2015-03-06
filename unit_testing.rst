==============================================================================
Unit Testing Rough Guide
==============================================================================

Description
------------------------------------------------------------------------------

Zenpacks need to be tested for internal consistency at build time by Jenkins.

Introduction
------------------------------------------------------------------------------

Unit Tests are becoming more important as continuous deployment technology grows.
These tests provide a sanity check for any software that gets moved into production.

Unit Tests in Zenoss are intended to test major components of ZenPacks whenever
possible.

Jenkins
------------------------------------------------------------------------------

Jenkins builds a Zenoss environment in order to test the Zenpacks at build time.
This means that it does have a live version of Zenoss to test against.
At this time however, Jenkins is not configured to probe Unit Tests..
You will have to test them manually (see below)

Manual Testing
------------------------------------------------------------------------------

You can test Unit Tests manually with **runtests** as follows:

* Your test class TestCheckOracle is part of ZenPacks.zenoss.DatabaseMonitor
  (see below for example).
* You wish to test this entire ZenPack's unit tests.
* You are on the zenoss system as user zenoss:

::

  [zenoss@cdev:$zpdir/tests]: runtests --type unit  ZenPacks.zenoss.DatabaseMonitor
      ==============================
      Packages to be tested:
              ZenPacks.zenoss.DatabaseMonitor
      ==============================
      Parsing /opt/zenoss/etc/zope.conf
      Running tests at level 1
      Running Products.ZenTestCase.BaseTestCase.ZenossTestCaseLayer tests:

        Set up Testing.ZopeTestCase.layer.ZopeLite in 0.422 seconds.
        Set up Products.ZenTestCase.BaseTestCase.ZenossTestCaseLayer in 0.002 seconds.
        Running: ..
        Ran 2 tests with 0 failures and 0 errors in 4.450 seconds.
      Tearing down left over layers:
        Tear down Products.ZenTestCase.BaseTestCase.ZenossTestCaseLayer in 0.000 seconds.
        Tear down Testing.ZopeTestCase.layer.ZopeLite in 0.000 seconds.

In this case we ran 2 tests and had 0 failures. We got lucky.

You can also specify the module to run::

   runtests --type unit  ZenPacks.zenoss.DatabaseMonitor -m test_modeler



Unit Test Framework
------------------------------------------------------------------------------

The unit test framework test functionality in isolation of any monitored 
devices. It inherits from the class **BaseTestCase** and uses it's 
*assert* methods for determining pass or failure.

* Unit tests inherit from BaseTestCase
* All tests go in the $ZPDIR/tests/ folder
* Inside that folder you need to create your test classes which will be 
  called from the following method::

      
      from Products.ZenTestCase.BaseTestCase import BaseTestCase
      from ZenPacks.zenoss.GoodieMonitor.Candy import Candy

      class TestGoodies(BaseTestCase):

          def testCheckGoodies(self):
              item = Candy("chocolate")
              state = item.getSweetOrSour
              self.assertTrue("sweet" in state, "Item %s not sweet" % item)
    
      def test_suite():
          from unittest import TestSuite, makeSuite
          suite = TestSuite()
          suite.addTest( makeSuite(TestGoodies) )
          return suite 


DataSource Example
------------------------------------------------------------------------------

This example shows the test code we created above. We assume:

* You are in your $ZP_DIR/tests/ folder
* You are in your dev environment.
* You have created an empty (or otherwise) __init__.py file
* Your test has a fake or simulated set of data, ie.
* You cant't rely on real device to gather data.
* The filename we create is test_datasources_plugin.py::

      ##########################################################################
      # Copyright (C) Zenoss, Inc. 2013, all rights reserved.
      # test_datasources_plugin.py
      ##########################################################################

      from Products.ZenTestCase.BaseTestCase import BaseTestCase

      class TestCheckOracle(BaseTestCase):
          '''
          This calls check_oracle.py -c "connectionString" -q "query" -t
          Rewrote check_oracle with -t (test) flag, adjusted txojdbc.py 
          '''

          def testCheckOracle(self):
              import subprocess
              import os

              connectionString = "zenoss/zenoss@mp1.zenoss.loc:1521:XE"
              query = 'select * from v$sysstat'
              path=os.path.join(os.path.dirname(__file__), "..")
              checkOracle=os.path.join(path, "check_oracle.py")

              output=subprocess.check_output(["python", checkOracle, "-c", 
                         connectionString, "-q", query, "-t"])
              outputRequired="logonscumulative"

              # BaseTestCase.assertTrue is the method that determines pass/fail
              self.assertTrue(outputRequired in output, 
                   "Output does not contain valid data %s" % outputRequired)
          

      def test_suite():
          from unittest import TestSuite, makeSuite
          suite = TestSuite()
          suite.addTest(makeSuite(TestCheckOracle))
          return suite

In this example, the **testCheckOracle** method of **TestCheckOracle** will be tested.
The **check_oracle.py** will call a routine (txojdbc.py) that has some pre-made
flat files of JSON data, so there is no dependency on an actual device to
monitor for data. This is critical because eventually Jenkins will have to run
the unit tests is a vacuum environment.

*Note*: The BaseTestCase.assertTrue is the key method that you need to determine
pass/fail of your test. If this test cas the "logonscumulative" string, it 
passes, otherwise it fails. In general you need one of the *assert* methods
in the BaseTestCase class

Impact Example
------------------------------------------------------------------------------

This example shows how to test Impact. We assume

* You are in your $ZP_DIR/tests/ folder
* You are in your dev environment.
* You have created an empty (or otherwise) __init__.py file
* You have your environment setup with Impact installed (for testing).

This example uses a lot of boilerplate code. It is much simpler than
the XenServer unit tests though. It can be considered one of the simplest
impact tests you will find, because the Instance class is only dependent on
the containing server. Nothing depends on Instance.

Most of the code is simply building a node-link tree diagram. 
The two methods that are non-boilerplate are:

* create_endpoint()
* The (decorated) test_Instance():

Notice also that the tests will always pass if Impact ZP is not installed
so you won't be able to test it properly.

::

   ##############################################################################
   #
   # Copyright (C) Zenoss, Inc. 2013, all rights reserved.
   #
   # This content is made available according to terms specified in
   # License.zenoss under the directory where your Zenoss product is installed.
   #
   ##############################################################################

   '''
   Unit test for all-things-Impact.
   '''

   import transaction
   from zope.component import subscribers
   from Products.Five import zcml
   from Products.ZenTestCase.BaseTestCase import BaseTestCase
   from Products.ZenUtils.guid.interfaces import IGUIDManager
   from Products.ZenUtils.Utils import monkeypatch

   from ZenPacks.zenoss.DatabaseMonitor.utils import guid, require_zenpack
   from ZenPacks.zenoss.DatabaseMonitor.tests.utils import (
       add_contained, add_noncontained,
           )


   @monkeypatch('Products.Zuul')
   def get_dmd():
       '''
       Retrieve the DMD object. Handle unit test connection oddities.

       This has to be monkeypatched on Products.Zuul instead of
       Products.Zuul.utils because it's already imported into Products.Zuul
       by the time this monkeypatch happens.
       '''
       try:
           # original is injected by the monkeypatch decorator.
           return original()

       except AttributeError:
           connections = transaction.get()._synchronizers.data.values()[:]
           for cxn in connections:
               app = cxn.root()['Application']
               if hasattr(app, 'zport'):
                   return app.zport.dmd


   def impacts_for(thing):
       '''
       Return a two element tuple.

       First element is a list of object ids impacted by thing. Second element is
       a list of object ids impacting thing.
       '''
       from ZenPacks.zenoss.Impact.impactd.interfaces \
           import IRelationshipDataProvider

       impacted_by = []
       impacting = []

       guid_manager = IGUIDManager(thing.getDmd())
       for subscriber in subscribers([thing], IRelationshipDataProvider):
           for edge in subscriber.getEdges():
               if edge.source == guid(thing):
                   impacted_by.append(guid_manager.getObject(edge.impacted).id)
               elif edge.impacted == guid(thing):
                   impacting.append(guid_manager.getObject(edge.source).id)

       return (impacted_by, impacting)


   def triggers_for(thing):
       '''
       Return a dictionary of triggers for thing.

       Returned dictionary keys will be triggerId of a Trigger instance and
       values will be the corresponding Trigger instance.
       '''
       from ZenPacks.zenoss.Impact.impactd.interfaces import INodeTriggers

       triggers = {}

       for sub in subscribers((thing,), INodeTriggers):
           for trigger in sub.get_triggers():
               triggers[trigger.triggerId] = trigger

       return triggers


   def create_endpoint(dmd):
       '''
       Return an Endpoint suitable for Impact functional testing.
       This is non-boilerplate code...
       '''
       # DeviceClass
       dc = dmd.Devices.createOrganizer('/Server/Linux')
       dc.setZenProperty('zPythonClass', '')
       linux = dc.createInstance('linux')

       # Instance
       from ZenPacks.zenoss.DatabaseMonitor.Instance import Instance
       add_contained(linux, 'instances', Instance('instance1'))

       return linux


   class TestImpact(BaseTestCase):
       def afterSetUp(self):
           super(TestImpact, self).afterSetUp()

           import Products.ZenEvents
           zcml.load_config('meta.zcml', Products.ZenEvents)

           try:
               import ZenPacks.zenoss.DynamicView
               zcml.load_config('configure.zcml', ZenPacks.zenoss.DynamicView)
           except ImportError:
               return

           try:
               import ZenPacks.zenoss.Impact
               zcml.load_config('meta.zcml', ZenPacks.zenoss.Impact)
               zcml.load_config('configure.zcml', ZenPacks.zenoss.Impact)
           except ImportError:
               return

           import ZenPacks.zenoss.DatabaseMonitor
           zcml.load_config('configure.zcml', ZenPacks.zenoss.DatabaseMonitor)

       def endpoint(self):
           '''
           Return a DatabaseMonitor endpoint device populated in a suitable way
           for Impact testing.
           '''
           if not hasattr(self, '_endpoint'):
               self._endpoint = create_endpoint(self.dmd)

           return self._endpoint

       def assertTriggersExist(self, triggers, expected_trigger_ids):
           '''
           Assert that each expected_trigger_id exists in triggers.
           '''
           for trigger_id in expected_trigger_ids:
               self.assertTrue(
                   trigger_id in triggers, 'missing trigger: %s' % trigger_id)

       @require_zenpack('ZenPacks.zenoss.Impact')
       def test_Instance(self):
           '''
           Decorator will disable tests if required ZenPacks are not installed!
           ZenPacks.zenoss.Impact and ZenPacks.zenoss.DynamicView must be installed!
           Jenkins will eventually be setup to do unit tests at build time.....
           '''
           instance1 = self.endpoint().getObjByPath('instances/instance1')
           impacts, impacted_by = impacts_for(instance1)

           # Host -> Instance
           self.assertTrue(
               'linux' in impacted_by,
               'missing impact: {} -> {}'.format('linux', instance1))


   def test_suite():
       from unittest import TestSuite, makeSuite
       suite = TestSuite()
       suite.addTest(makeSuite(TestImpact))
       return suite


Another Simple Example
----------------------

Here is another simple example that may help::

   from Products.Five import zcml

   from Products.ZenTestCase.BaseTestCase import BaseTestCase
   from Products.Zuul.interfaces import IReportable

   from ZenPacks.zenoss.OpenVZ.Container import Container


   class TestAnalytics(BaseTestCase):
       def afterSetUp(self):
           super(TestAnalytics, self).afterSetUp()

           # Required to prevent erroring out when trying to define viewlets in
           # ../browser/configure.zcml.
           import Products.ZenUI3.navigation
           zcml.load_config('testing.zcml', Products.ZenUI3.navigation)

           import ZenPacks.zenoss.OpenVZ
           zcml.load_config('configure.zcml', ZenPacks.zenoss.OpenVZ)

       def testContainerReportable(self):
           device = self.dmd.Devices.createInstance('openvz_host')

           container = Container('101')
           device.openvz_containers._setObject(container.id, container)
           container = device.openvz_containers._getOb(container.id)

           reportable = IReportable(container)
           report_properties = reportable.reportProperties()

           self.assertEqual(reportable.entity_class_name, 'container')

           self.assertEqual(len(report_properties), 3)
           self.assertEqual(report_properties[0][0], 'id')
           # .. and so on..


   def test_suite():
       from unittest import TestSuite, makeSuite
       suite = TestSuite()
       suite.addTest(makeSuite(TestAnalytics))
       return suite


DMD fixtures
------------
You could use ``dmd`` in descendants of ``BaseTestCase`` after it ``afterSetUp`` method was executed.

But, you need to remember that this ``dmd`` will be clean, so, if you want to use something like ``dmd.Devices.Network.Router`` it will give you ``AttributeError: Network``.

To create device class you need to call ``dmd.Devices.createOrganizer('/Network')``.


