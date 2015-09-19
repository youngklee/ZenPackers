File Locations
===============================================================================

The location of specific files within a ZenPack's directory structure is
technically mandated in some circumstances, and open to the developer's desires
in others. To make it easier for other developers to more easily get up to
speed with the ZenPack in the future, the following recommendations for file
locations should be used.

Note that with ZenPacklib (ZPL), some locations are deprecated. Please see examples to
clarify this. When in double we will endeavor to label the sections with (ZPL)
and (No-ZPL).

* **ZenPacks.<namespace.PackName>/**
* **ZenPacks.<namespace.PackName>/ZenPacks/namespace/PackName/**

  * **analytics/**

    The analytics bundle in .zip format: **analytics-bundle.zip**

  * **browser/** (No-ZPL. See /resources below)

    * **configure.zcml**

      All ZCML definitions related to defining browser views or wiring
      browser-only concerns. This **configure.zcml** should be included by the
      default **configure.zcml** in its parent directory.

    * **resources/**

      * **css/** - All stylesheets loaded by users' browsers.
      * **img/** - All images loaded by users' browsers.
      * **js/** - All javascript loaded by users' browser.
    |
  * **resources/** (Note: ZPL, See /browser above)

    Any javascript code that modifies views go here.
    Especially note these JS file correlations:

    * **device.js** - Modifies the default device page.
    * **ComponentClass.js** - Modifies the component ComponentClass page.

    Folders inside **resources** have the following properties:

    * **icon/** (Note: ZPL)

      All images and icons loaded by the browser.
      Within this folder note the following name correspondence:

      * **DeviceClass.png** - Icon used in top left corner.
      * **ComponentClass.png** - Icon used in Impact diagrams for component.

  * **datasources/**

    All datasources plugin files. Ensure your datasource has a descriptive name
    that closely correlates to the plugin name.

  * **lib/**

    Any third-party modules included with the ZenPack should be located in this
    directory. In the case of pure-Python modules they can be located directly
    here. In the case of binary modules the build process must install them
    here. See the section of License Compliance below for more information on
    how to properly handle third-party content.

  * **libexec/**

    Any scripts intended to be run by the zencommand daemon must be located in
    this directory.

  * **migrate/**

    All migration code.

  * **modeler/**

    All modeling plugins.

  * **objects/**

    There should only ever be a single file called objects.xml in this
    directory. While the ZenPack installation code will load objects from any
    file in this directory with a **.xml** extension, the ZenPack export code
    will dump all objects back to **objects.xml** so creating other files only
    creates future confusion between installation and export.

  * **parsers/**

    All custom parsers here.

  * **patches/**

    All monkeypatches. Note: your patches/__init__.py must specify patch loading.

  * **protocols/**

    AMQP schema: Javascript code is read into the AMQP protocol to modify
    queues and exchanges.

  * **services/**

    Custom collector services plugins.

  * **service-definition/** (Note: 5.X+)

    Service definitions for 5.X services containers.

  * **skins/**

    All TAL template skins in .pt format. These change the UI look.

  * **tests/**

    All unit tests go here.
 
  * **facades.py**

    All facades (classes implementing **Products.Zuul.interfaces.IFacade**)
    should be defined in this file. In ZenPacks where this single file becomes
    hard to maintain, a facades/ directory should be created containing
    individual files named for the group of facades they contain.

  * **info.py**

    All info adapters (classes implementing **Products.Zuul.interfaces.IInfo**)
    should be defined in this file. In ZenPacks where this single file becomes
    hard to maintain, an **info/** directory should be created containing
    individual files named for the group of info adapters they contain.

  * **interfaces.py**

    All interfaces (classes extending **zope.interface.Interface**) should be
    defined in this file. In ZenPacks where this single file becomes hard to
    maintain, an **interfaces/** directory should be created containing
    individual files named for the group of interfaces they contain.

  * **routers.py**

    All routers (classes extending **Products.ZenUtils.Ext.DirectRouter**)
    should be defined in this file. In ZenPacks where this single file becomes
    hard to maintain, a **routers/** directory should be created containing
    individual files named for the group of routers they contain.



