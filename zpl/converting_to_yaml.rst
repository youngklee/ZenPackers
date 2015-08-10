==================================================================
Converting from Old-Style ZenPackLib to the New-Style.
==================================================================

If you started out using the the original ZPL, you have your YUML specified in your
$ZP/__init__.py, and a dictionary style of class specification.
The new style moves almost all of this to a YAML file called $ZP/zenpack.yaml.
Only special overridden classes get left behind in $ZP/__init__.py.

You might eventually want to convert to the new format.
Fortunately there are tools and notes here to help you do so.

* Assumptions:

  - You zenpack is named ZenPacks.zenoss.XYZ
  - You zenpack uses an older form of ZPL that has YUML class structure and
    properties specified inside of $ZP/__init__.py
  - You want to convert __init__.py's YUML+dict to YAML format 
    inside of $ZP/zenpack.yaml

* Create zenpack.yaml (based on monitoring_templates.yaml.. or an existing ZP)

  - First create a dummy zenpack (or use the existing one), and get
    a new copy of zenpacklib.py installed.

  - Execute::

      python zenpacklib py_to_yaml ZenPacks.zenoss.XYZ

  - basically nest the existing content under a device class) 


* For Local Inherited Classes Only: 

  Ensure: In zenpack.yaml: locally inherited $ZP/modules.classes in separate
  files must (for now) use the fully qualified path specification::

      ZenPacks.zenoss.XYZ.module.class

  The current **py_to_yaml** can interpret your local base class modules
  incorrectly as simply::

      class

  For example::

     'Router': {
                 'base': [SomeComponent],
                 ....
                 }

  can get **incorrectly** translated into YAML as::

     Router:
       base:
         [SomeComponent]

  whereas you really need::

     Router:
       base:
         [ZenPacks.zenoss.OpenStackfrastructure.NeutronIntegrationComponent.SomeComponent]


* In $ZP/__init__.py:

  - Remove all **unnecessary** imports to local modules 
  - Add line to init.py to make it load it.
    In place of::

      RELATIONSHIPS_YUML = """
         ... some YUML class spec stuff ...
      """

      CFG = zenpacklib.ZenPackSpec( 
         ... lots of old stuff ...
         ... lots more old stuff ...
         ... etc ...
         class_relationships=zenpacklib.relationships_from_yuml(RELATIONSHIPS_YUML),
      )
      CFG.create()

    You will have something of this sort::

      CFG = zenpacklib.load_yaml()

  - restart zenoss, 


  .. warning:: Some of the next steps will eventually be automatic.
               You should be able to simply export your objects.xml after setting
               up your zenpack.yaml and the correct components will be included.

* Pruning Objects.xml

  You need to remove all the superfluous junk that now resides in objects.xml.
  This is because zenpack.yaml takes care of most of it.
  Follow these guidelines for pruning:

  - Navigate to Advanced -> ZenPacks -> YourZenPack
  - Go to the the Zenpack's "Provides" section to reduce objects.xml
  - Remove all device classes listed in zenpack.yaml:device_classes
  - Remove all the rrdTemplates items
  - Ensure: Leave all Event related items in your Provides section for now.
  - Hint: To get all contiguous Provides, click top item, then Shift-click bottom item.
  - Export zenpack to regenerate objects.xml, 
  - Check that objects.xml is indeed smaller and has no rrdTemplate items
  - Finally: Re-Export the ZP if other changes were made.
  |

* Save the new Objects.xml

  This only needs to be done if you development environment is not
  mounted/linked to your git repo. Otherwise skip this step.

  - Copy the new $ZP/objects/objects.xml from above to your ZP source tree
  |

* Remove Old Files that Are No Longer Needed:

  - remove no-longer-needed monitoring_templates.yaml 
  - remove load-templates files.
  |

* You need to be careful that nothing breaks, but it should be really obvious breakage, 

  - Try **zendmd** between each change, watching for errors
  - For example: all monitoring templates vanish or something.  
  - It should not be subtle if it's not working
  |

* You may wish to manually prune out at least one montioring template 
  to convince yourself that ZPL is re-creating them at install time.

* Though it would also be clear when you tried to export.. 
  Either they'd get pruned out or they would not.  
  - (if not, ZPL doesn't think it's managing the monitoring templates!)

* Double Checking the Results

  - Remove the existing ZP completely
  - Restart all services
  - Install your ZP
  - Restart all services (again)
  - Install a device on your ZP class
  - Check that all is correct

References
--------------------------------------------------------------------------------

https://github.com/zenoss/ZenPacks.zenoss.OpenStackInfrastructure
https://github.com/zenoss/ZenPacks.zenoss.OpenvSwitch
https://github.com/zenoss/ZenPacks.zenoss.ControlCenter

