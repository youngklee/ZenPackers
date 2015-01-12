==========================
Templates
==========================

Templates form the core of the Serviced service definitions.
They define nearly everything that goes into Zenoss.
In order to use them you will have to start with some base set to make
life easier.

In zendev these templates correspond to entire folders of templates.
They live in::

   export ZENDEV_ROOT=$(zendev root)
   $ZENDEV_ROOT/src/service/services

You may see these folders which hold many other subfolders::
   
   drwxrwxr-x 19 zenoss zenoss 4096 Aug  7 20:40 Zenoss.core
   drwxrwxr-x 17 zenoss zenoss 4096 Aug  7 20:40 Zenoss.core
   drwxrwxr-x 21 zenoss zenoss 4096 Aug  7 20:40 Zenoss.resmgr
   drwxrwxr-x 19 zenoss zenoss 4096 Aug  7 20:40 Zenoss.resmgr.lite

Basic Commands
---------------------

* List a Template:: 
  
   serviced template list

* Compile a Template::

   serviced template compile Zenoss.core
   serviced template compile Zenoss.core > /tmp/Zenoss.core.tpl

* Add a Template::

   serviced template add /tmp/Zenoss.core.tpl

 -- However, its best to grab the Template ID in *this* way::

     TEMPLATE_ID=$(serviced template add /tmp/Zenoss.core.tpl)

* Deploy a Template:

  After you deploy a template, it becomes a real **Application**::

   # ----------------------------------------------------------
   # serviced template deploy TEMPLATE_ID   POOLID   DEPLOY_ID
   # ----------------------------------------------------------
     serviced template deploy $TEMPLATE_ID  default  zenmaster

* .. NOTE:: Note on Resmgr

     In order to compile and deploy Resmgr your Docker image must be created
     correctly. This means that all the required Zenpacks must be compiled into
     that Docker image. See the note in :ref:`setupdevenv`.

Compile the Generic Template
---------------------------------------------------------------------------------

This method is most approprate when you work with a pre-made image like Beta
or a Release image. This is because its a bit easier to tag an image with
the same tag (as the template) than to change the numbers on the templates.

Compile the template::

   serviced template compile $ZENDEV_ROOT/src/services/services/Zenoss.core > /tmp/Zenoss.core.tpl
   serviced.init start
   TEMPLATE_ID=$(serviced template add /tmp/Zenoss.xxx.tpl)

   serviced template deploy $TEMPLATE_ID default zenoss

Map the template to match your Docker Image
--------------------------------------------------------------------------

This may be more appropriate if you use Zendev, since the zendev images
are already created with tags, and you don't want to mess with those.

Build the Template::

   cdz serviced
   serviced template compile -map zenoss/zenoss5x,zendev/devimg \
   $ZENDEV_ROOT/src/service/services/Zenoss.core > /tmp/xxx.tpl
   TEMPLATE_ID=$(serviced template add /tmp/xxx.tpl)

Deploy Templates::

   serviced template deploy $TEMPLATE_ID default zen_monkey


Updating Templates with Json-only Changes
------------------------------------------------
Surgically, you could remove the template from the UI, then compile/add
template and start all services. You could also serviced service edit each of
those services and restart those services after editting, which is probably
easiest if there are only a few minor changes. The incantation to
compile/add (with template mapping)::

   serviced template compile -map zenoss/zenoss5x,zendev/devimg \
      $ZENDEV_ROOT/src/service/services/Zenoss.core \
      | serviced template add

UtilityScripts: But Wait Folks! Thats not all!
---------------------------------------------

Yes, thats right folks, we've worked hard to make life easier for you.
How easy you may ask? So easy, you can do it with one hand tied behind
your back and both eyes closed!

Here is a bash function that will fix up your template and insert it all
in one command::

   liten_up_dude()
   {
      IMAGE=core

      # Compile the Template and *MAP* it to the right zendev image:
      serviced template compile -map zenoss/zenoss5x,zendev/devimg \
         $ZENDEV_ROOT/src/service/services/Zenoss.${IMAGE} > \
         /tmp/Zenoss.xxx.tpl

      # Add the Template to serviced definitions
      TEMPLATE_ID=$(serviced template add /tmp/Zenoss.xxx.tpl)

      # Deploy the template
      # serviced template deploy TEMPLATE_ID   POOL_ID  DEPLOYMENT_ID
      # ----------------------------------------------------------
        serviced template deploy $TEMPLATE_ID  default  zenmaster

      # Get rid of the old Zenoss.core application
      CORE_ID=$(serviced service list | grep -E 'Zenoss.core\s' \
         | tr -cd '\11\12\40-\176' | awk '{print $2}')

      serviced service remove $CORE_ID
      unset CORE_ID

      # Now you should use the GUI to start the Zenoss.core application
      # Warning! Untested: You can also add that to this function if you like::
      # LITE_ID=$(serviced service list | grep -E 'Zenoss.core' \
      #    | tr -cd '\11\12\40-\176' | awk '{print $2}')
      # serviced service start $LITE_ID

   }

.. WARNING::

   Make sure you *Don't* start or use the standard Zenoss.core application
   before starting the Zenoss.core application. Experiments have shown
   that there is some docker image mismatches that happen as a result of
   starting Zenoss.core, stopping it, and starting Zenoss.core.

So here is the workflow scenario for this tool:

* zendev build devimg
* zendev serviced -dx
* liten_up_dude
* Go into GUI, select *Zenoss.core*, Start it

Modifying Service Templates in Europa
--------------------------------------

Modifying templates may be required to add functionality to your zenpacks
or to core. Often, the containers have a very restricted access in order for
good security and simplicity. 


Modfying the Default Templates
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the service you are modifying is in the default template, you
will have to ensure that *ALL* the template definitions have that
change, otherwise someone will deploy a service that is missing
a requirement. Make sure that the template is modified in folder.
The Current Zendev has these template folders:

 +--------------------+-------------------------------------------------------+
 +--------------------+-------------------------------------------------------+
 | Template           | Location                                              | 
 +--------------------+-------------------------------------------------------+
 +====================+=======================================================+
 | Zenoss.core        | $ZENDEV_ROOT/src/service/services/Zenoss.core/        | 
 +--------------------+-------------------------------------------------------+
 | Zenoss.core.full   | $ZENDEV_ROOT/src/service/services/Zenoss.core.full/   | 
 +--------------------+-------------------------------------------------------+
 | Zenoss.resmgr      | $ZENDEV_ROOT/src/service/services/Zenoss.resmgr/      | 
 +--------------------+-------------------------------------------------------+
 | Zenoss.resmgr.lite | $ZENDEV_ROOT/src/service/services/Zenoss.resmgr.lite/ |
 +--------------------+-------------------------------------------------------+
 | Zenoss.ucspm       | $ZENDEV_ROOT/src/service/services/Zenoss.ucspm/       |
 +--------------------+-------------------------------------------------------+
 | Zenoss.ucspm.lite  | $ZENDEV_ROOT/src/service/services/Zenoss.ucspm.lite/  |
 +--------------------+-------------------------------------------------------+
  
Each of these will be modified by adding the following to the Endpoint list::

    {
        "Name": "rabbitmq",
        "Application": "rabbitmq",
        "PortNumber": 5672,
        "Protocol": "tcp",
        "Purpose": "import"
    }

Once the change is made you can compile any of these templates and deploy
just as we have outline above.


Adding RabbitMQ Ports to the Zenpython (PythonCollector) Zenpack
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If you are adding to a service that is bundle with a Zenpack,
you must provide extra templating instructions to Zenoss so that any
installation of that Zenpack will guarantee to have the required services
you need.

In our example,
ZenPacks.zenoss.OpenStackInfrastructure requires that zenpython be able to 
poll the RabbitMQ container. This was not available when we started.
We start by reviewing https://github.com/zenoss/ZenPacks.zenoss.ExampleService
which outlines the way to add template support to a zenpack. We'll try to only
outline the critical components that supplement that document.

* First create folders in $ZP_DIR of ZenPacks.zenoss.PythonCollector::

   su - zenoss
   cd ZenPacks.zenoss.PythonCollector/ZenPacks/zenoss/PythonCollector
   mkdir service_definition
   mkdir -p service_definition/-CONFIGS-/opt/zenoss/etc

* Copy the service configuration file into the right place::

   cp /tmp/zenpython.conf service_definition/-CONFIGS-/opt/zenoss/etc/

* Now copy the template into place::
   
   cp Zenoss.core/localhost/localhost/zenpython/service.json service_definition/

* You now must change a few key items in this template (be sure to add quotes_):

   - servicePath:       /hub/collector
   - serviceDefinition: (Encapsulate the entire contents of original services.json)
   - serviceDefinition  (Make it somewhat different from standard)
   - ConfigFiles::

               "/opt/zenoss/etc/zenpython.conf": {
               "FileName": "/opt/zenoss/etc/zenpython.conf",
               "Owner": "zenoss:zenoss",
               "Permissions": "0664"
               }

   - Endpoints (Add)::

       {
           "Name": "rabbitmq",
           "Application": "rabbitmq",
           "PortNumber": 5672,
           "Protocol": "tcp",
           "Purpose": "import"
       }

   - ImageID:  (set to empty string to be overridden later)


* Once all this is in place, you need to test it by removing and reinstalling
  the ZP. Then you can check the service definition in Zendev::

    serviced service edit zenpython

  If you see your changes, and a nice ImageID, then all is hopefully well.
  See the actual ZenPacks.zenoss.PythonCollector repo for more detail.

