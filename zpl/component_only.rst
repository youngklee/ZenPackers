===================================================================
Component-Only Modeling: Add to Existing Device
===================================================================

If your zenpacklib created zenpack does not need a device class and will just
be adding components to an existing device, you will need to add a
relationship between the base device class and your new component. In your
*zenpack.yaml*::

   classes:

      ExchangeServer:
         base: [zenpacklib.Component]

   class_relationships:

   - Products.ZenModel.Device.Device 1:MC ExchangeServer

   ... etc ...

As always, be sure to either install or reinstall the zenpack and restart your
services when making this change. If not, you'll see this 
in the info zenhub log:

If you see a warning in zenhub.log saying you have no relationship when
applying the data map for your new component objects, you may just need to
reinstall your zenpack.

If you've done things correctly, you'll see this in the zenhub log next time
you model::

   2015-08-31 11:28:06,967 INFO zen.zenpacklib: Adding
   ZenPacks.zenoss.Microsoft.Exchange relationships to existing devices


Now, in your modeler, you can set class level vars that apply to the 
current (the one that is being processed in the plugin) component:

* relname
* modname

This applies to self.ObjectMap() only just as in
http://zenpacklib.zenoss.com/en/latest/tutorial-snmp-device/component-modeling.html . 

Alternatively, you can set relname and modname on a per-component basis using
local ObjectMap() as in the following::


    class WinExchange(WinRMPlugin):

        relname = 'exchangeServers'
        modname = 'ZenPacks.zenoss.Microsoft.Exchange.ExchangeServer'


        @defer.inlineCallbacks
        def collect(self, device, log):
           
           .... etc ....

           maps = {}

           device_om = ObjectMap()
           maps['device'] = device_om

           results = yield get_exchange_server

           ... etc ...

           exchange_om = ObjectMap()
           try:
                 ... etc ...
                 exchange_om.title = exchange_om.id =
                 self.prepId(results.stdout[0])
                 exchange_om.role = results.stdout[1]
                 exchange_om.version = results.stdout[2]
                 exchange_om.relanme = 'exchangeServers' exchange_om.modname = 'ZenPacks.zenoss.Microsoft.Exchange.ExchangeServer'
                 ... etc ...
           except IndexError:
                 log.info("Invalid data returned from Exchange Server: }")

           maps['device'] = device_om
           maps['exchange_server'] = exchange_om
           
           .... etc etc ....

           defer.returnValue(maps)

References: https://github.com/zenoss/ZenPacks.zenoss.Microsoft.Windows
