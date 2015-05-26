==============================================================================
GUI Properties and JavaScript Related Methods
==============================================================================

Description
==============================================================================

Zenpack GUIs need to cute.
This is done by getting more properties in the GUI.
We explain how to do this here a bit...

Prerequisites
==============================================================================

* Zenoss ZenPack Developement 
* Python 2.7

We assume that you are familiar with ZenPack developement and Python coding.
We further assume that you have a console/terminal/xterm open on the system
running Zenoss. The CLI default prompt is **[zenoss:~]:**

# Polling (TBD)
# Device Modeling (TBD)
# RRD (TBD)
# Event Traps (TBD)

Variables: Who, What, Where, and How
==============================================================================

Variables in the GUI are primarily set by our ExtJS Javascript library
configuration. These are the steps:

* The variables must first be defined in ZP defined classes that inherit 
  IComponentInfo and ComponentInfo
* Then these variables must be set in either the modeler or the datasource collectors. 
* Finally they can be used in the ExtJS javascript


We use the DatabaseMonitor ZP (Oracle) as an example. We first define the
Instance class (heavily abbreviated)::

  class Instance(DeviceComponent, ManagedEntity):                                 
      meta_type = portal_type = 'OracleInstance'                                  
      .......

      hostname = None
      instance_name = None
      .......
      
      _properties = _properties + (                                               
        {'id': 'hostname', 'type': 'string', 'mode': 'w'},                      
        {'id': 'instance_name', 'type': 'string', 'mode': 'w'},
        ...
      )
      .......

   class IInstanceInfo(IComponentInfo):                                            
                                                                                   
       hostname = schema.TextLine(title=_t(u'Hostname'), readonly=True)                                      
       instance_name = schema.TextLine(title=_t(u'Instance Name'), readonly=True)
      .......

   class InstanceInfo(ComponentInfo):                                              
       implements(IInstanceInfo)                                                   
                                                                                   
       hostname = ProxyProperty('hostname')                                        
       instance_name = ProxyProperty('instance_name')
      .......

Now you can use your variables in an anonmous function inside your ExtJS::

    ZC.OracleInstancePanel = Ext.extend(ZC.DatabaseMonitorComponentGridPanel, {  
       constructor: function(config) {                                          
           config = Ext.applyIf(config||{}, {                                   
               componentType: 'OracleInstance',                                 
               autoExpandColumn: 'name',                                        
               sortInfo: {                                                      
                   field: 'name',                                               
                   direction: 'asc',                                            
               },                                                               
               fields: [                                                        
                   {name: 'uid'},                                               
                   {name: 'name'},                                              
                   {name: 'hostname'},                                                                    
                   {name: 'instance_name'},                                     
                   ...
               ],                                                               
               columns: [{                                                      
                   id: 'severity',                                              
                   dataIndex: 'severity',                                       
                   ............                                                 
               },{                                                              
                   id: 'name',                                                  
                   dataIndex: 'name',                                           
                   ...........
               },{                                                              
                   id: 'hostname',                                              
                   dataIndex: 'hostname',                                       
                   header: _t('Hostname'),                                      
                   width: 160                                                   
               },{                                                              
                   dataIndex: 'instance_name',                                   
                   header: _t('DB Name'),                                       
                   id: 'instance_name',                                          
                   width: 75                                                    
               }, .... etc ....



Renderer: Changing Column Appearances
==============================================================================

Change the "First Seen" and "Last Seen" columns in the event console to show
how long ago the event occurred in a more human-friendly way. This is done 
through the following JS function exampe (time_ago_columns.js)::


   (function() {

       var time_ago_column = {
           renderer: function(value, metaData, record, rowIndex, colIndex, store) {
               var seconds = Math.floor((new Date() - value) / 1000);
               var interval = Math.floor(seconds / 31536000);

               if (interval > 1)
                  return interval + " years ago";

               interval = Math.floor(seconds / 2592000);
               if (interval > 1)
                   return interval + " months ago";

               interval = Math.floor(seconds / 86400);
               if (interval > 1)
                   return interval + " days ago";

               interval = Math.floor(seconds / 3600);
               if (interval > 1)
                   return interval + " hours ago";

               interval = Math.floor(seconds / 60);
               if (interval > 1)
                   return interval + " minutes ago";

               return Math.floor(seconds) + " seconds";
           }
       };

       Zenoss.events.registerCustomColumn('firstTime', time_ago_column);
       Zenoss.events.registerCustomColumn('lastTime', time_ago_column);

   }());

Renderer: Linking Grid Elements to other Component Views 
==============================================================================

Again we are looking at the JS files in $ZPDIR/browser/resources/js/ .
Inside your anonymous function, we need to define a custom renderer 
(extending Zenoss.render) that creates URL links::

  Ext.apply(Zenoss.render, {                                                      
      ZenPacks_zenoss_DatabaseMonitor_entityLinkFromGrid: function(obj, col, record) {            
          if (!obj)                                                               
              return;                                                             
                                                                                  
          if (typeof(obj) == 'string')                                            
              obj = record.data;                                                  
                                                                                  
          if (!obj.title && obj.name)                                             
              obj.title = obj.name;                                               
                                                                                  
          var isLink = false;                                                     
                                                                                  
          if (this.refName == 'componentgrid') {                                  
              // Zenoss >= 4.2 / ExtJS4                                           
              if (this.subComponentGridPanel || this.componentType != obj.meta_type)
                  isLink = true;                                                  
          } else {                                                                
              // Zenoss < 4.2 / ExtJS3                                            
              if (!this.panel || this.panel.subComponentGridPanel)                
                  isLink = true;                                                  
          }                                                                       
                                                                                  
          if (isLink) {                                                           
              return '<a href="javascript:Ext.getCmp(\'component_card\').componentgrid.jumpToEnti>
          } else {                                                                
              return obj.title;                                                   
          }                                                                       
      },                                                                          
  });


Once that is defined, its really a piece of cake to get your item to link from
your grid objects::

   ZC.OracleTableSpacePanel = Ext.extend(ZC.DatabaseMonitorComponentGridPanel, {   
       constructor: function(config) {                                             
           config = Ext.applyIf(config||{}, {                                      
               autoExpandColumn: 'name',                                           
               componentType: 'OracleTableSpace',                                  
               fields: [                                                           
                   {name: 'uid'},                
                   ......
                   ......
               ],
               columns: [
               {                                                                   
                   id: 'severity',                                                 
                   dataIndex: 'severity',                                          
                   header: _t('Events'),                                           
                   renderer: Zenoss.render.severity,                               
                   sortable: true,                                                 
                   width: 40                                                       
               },{                                                                 
                   id: 'instance',                                                 
                   dataIndex: 'instance',                                          
                   header: _t('Instance'),                                         
      >>           renderer: Zenoss.render.ZenPacks_zenoss_DatabaseMonitor_entityLinkFromGrid,
                   sortable: true,                                                 
                   width: 70                                                       
               },
               ... etc ...


Now this ZC.OracleTableSpacePanel grid will have a link to the ZC.OracleInstancePanel grid.

GUI: Adding an Extra Panel to the Navigator 
==============================================================================

So you have your new component, say TableSpaces and your associated
OracleTableSpacePanel grid as above. But you may want to have a Nav info
view that associates the containing component (Instance in our case).
Do do so we again modify the $ZPDIR/browser/resources/js/DatabaseMonitor.js
source as follows; Inside the main anonymous function, add the following
(See also the JS for PostgreSQL.js)::

   Zenoss.nav.appendTo('Component', [{                                          
       id: 'component_tablespaces',                                             
       text: _t('TableSpaces'),                                                 
       xtype: 'OracleTableSpacePanel',                                          
       subComponentGridPanel: true,                                             
       filterNav: function(navpanel) {                                          
           switch (navpanel.refOwner.componentType) {                           
               case 'OracleInstance': return true;                              
               default: return false;                                           
           }                                                                    
       },                                                                       
       setContext: function(uid) {                                              
           ZC.OracleTableSpacePanel.superclass.setContext.apply(this, [uid]);   
       }                                                                        
   }]);                                                                         
      
Notice that the *switch* that returns True for the super-component
OracleInstance.


GUI: Changing Detail Values in the Navigator
==============================================================================

The Navigator (Nav Panel) contains the Detail View (and others) below the component frame.
We will show how to change the values presented in the Details window of the Nav.

In your component source you have two classes: TablespaceInfo and
ITablespaceInfo (replace "TableSpace" with your actual component name). In
order to change the units on our tablespace_allocbytes and tablespace_maxbytes,
which are in bytes, we create decorated class methods::

  class ITableSpaceInfo(IComponentInfo):
      tablespace_name = schema.TextLine(title=_t(u'TableSpace'), readonly=True)
      allocSize = schema.Float(title=_t(u'Allocated Size'), readonly=True)
      maxSize = schema.Float(title=_t(u'Max Size'), readonly=True)
      ...

   class TableSpaceInfo(ComponentInfo):
       implements(ITableSpaceInfo)

       tablespace_name = ProxyProperty('tablespace_name')
       tablespace_allocbytes = ProxyProperty('tablespace_allocbytes')
       tablespace_maxbytes = ProxyProperty('tablespace_maxbytes')
       ....

       @property
       def allocSize(self):
           return convToUnits(self._object.tablespace_allocbytes)

       @property
       def maxSize(self):
           return convToUnits(self._object.tablespace_maxbytes)

The Nav will auto-magically pick up the values in the ITableSpaceInfo
and present that in the Details page.


GUI: Auto-Expanding Columns and minWidth for Component Grids
==============================================================================

Component grids traditionally use the *Name* field to take up all
the extra slack in the spacing. To do that you first set it up as
an **autoExpandColumn** . I also like to set it with a minimum with
using the **minWidth** parameter so it remains visible.

So in your $ZPDIR/browser/resources/js/DatabaseMonitor.js you should have something
like this::

  ZC.OracleInstancePanel = Ext.extend(ZC.DatabaseMonitorComponentGridPanel, {     
    constructor: function(config) {                                             
        config = Ext.applyIf(config||{}, {                                      
            componentType: 'OracleInstance',                                    
            autoExpandColumn: 'name',                                           
            sortInfo: {                                                         
                field: 'name',                                                  
                direction: 'asc',                                               
            },                                                                  
            fields: [                                                           
                {name: 'uid'},                                                  
                {name: 'name'},                                                 
                {name: 'meta_type'},                                            
                {name: 'status'},                                               
                {name: 'severity'},                                             
                ..................
            ],                                                                  
            columns: [{                                                         
                id: 'severity',                                                 
                dataIndex: 'severity',                                          
                header: _t('Events'),                                           
                renderer: Zenoss.render.severity,                               
                sortale: true,                                                            
                width: 50                                                        
            },{               
                id: 'name',                                                     
                dataIndex: 'name',                                              
                header: _t('Name'),                                             
                sortable: true,
                minWidth: 70
            },........


Missing DocString in Component Class results in Site-Error 
==============================================================================

If you have a component class that has no docstring, or inherits from a class
that is missing a docstring, a direct link to it will
result in a Site-Error in the UI.

Zope will only publish resources with a docstring. When you navigate directly
to an object's primary path you're asking Zope to publish it. It may look like::

    Site error
    An error was encountered while publishing this resource. 
    The requested resource does not exist.
    Please click here to return to the Zenoss dashboard


It's hard to troubleshoot because the missing docstring results in a NotFound
exception. Zope suppresses logging of NotFound errors by default. If you go to
http://yourzenoss:8080/error_log/manage_workspace and remove NotFound from the
list of ignored exception types, you'll see a very helpful error in event.log
when that "Site Error" occurs::

   Traceback (innermost last):

   Module ZPublisher.Publish, line 115, in publish
   Module ZPublisher.BaseRequest, line 521, in traverse
   Module ZPublisher.HTTPResponse, line 727, in debugError

   NotFound: Site Error: An error was encountered while publishing this resource. 
   Debugging Notice:  Zope has encountered a problem publishing your object. 
   The object at
   http://mpX.zenoss.loc:8080/zport/dmd/Devices/OpenStack/Infrastructure/devices/mp8.osi/components/tenant-uuid
   has an empty or missing docstring. Objects must have a docstring to be published. 


* Example: Zenpacks.zenoss.OpenStackInfrastructure

  - Jira: ZEN-17701: 
  - commit: 73fd0fb8599f07e5f0b4174f21ad96dd50952536

  Since the NeutronIntegrationComponent class didn't have a docstring, and it
  was the first class extended by Tenant/etc, Tenant/etc didn't have a docstring.
 
   
  - Log Entry Sample::

       10.1.1.50 - Anonymous [07/May/2015:10:06:24 -0500] 
       "GET /zport/dmd/Devices/OpenStack/Infrastructure/devices/mp8.osi/components/tenant-uuid HTTP/1.1" 
       404 1136
       "http://mp2.zenoss.loc:8080/zport/dmd/Devices/OpenStack/Infrastructure/devices/mp8.osi/devicedetail"
       "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36


