===============================================================
Developing Custom Routers
===============================================================

Zenoss provides an API for interacting with it and accessing the objects in ZODB.The API is called Zenoss JSON API and documented `here <http://www.zenoss.com/resources/documentation>`__. The API is an web interface that invokes a method defined in an Zenoss instance remotely when it receives a POST request. The interaction is enabled by *routers* and *facades*. A router handles POST requests from outside and invokes methods in the corresponding facade, and returns the outputs of these methods. Zenoss comes with several routers and facades that allow users to access or manipulate various types of objects in ZODB. However, sometimes a pair of custom router and facade is needed in order to accomplish a task that can't be done with the existing routers and facades. These router and facade can be deployed as a ZenPack.

Let us take an example: Hello World ZenPack. Throughout this example it will be assumed that a Zenoss instanace is running. First, create an empty ZenPack called HelloWorld. The router and facade codes live in ZenPacks.zenoss.HelloWorld/zenoss/HelloWorld. The only thing this ZenPack does is to say hello. The method for saying hello is defined in the facade:

.. code-block:: python

    # facades.py
    from zope.interface import implements
    from Products.Zuul.facades import ZuulFacade
    from interfaces import IGreetingFacade

    class GreetingFacade(ZuulFacade):
        implements(IGreetingFacade)

        def sayHello(self, name):
            return {'msg': 'Hello, %s' %name}

The interface of this facade looks like this:

.. code-block:: python

    # interfaces.py
    from Products.Zuul.interfaces import IFacade

    class IGreetingFacade(IFacade):
        """
        A facade for saying a greeting message.
        """

        def sayHello():
            """
            Say hello.
            """

The router is the one who actually invokes sayHello() in the facade:

.. code-block:: python

    # routers.py
    import Globals
    from Products.ZenUtils.Ext import DirectRouter
    from Products import Zuul

    class GreetingRouter(DirectRouter):

        def _getFacade(self):
            return Zuul.getFacade('greeting_facade')

        def sayHello(self, name):
            facade = self._getFacade()
            msg = facade.sayHello(name)
            return Zuul.marshal(msg)

Save this file as routers.py.

To use these router and facade, they must be configured properly first. The configration is stored in configure.zcml that lives in the same directory as the above python files:

.. code-block:: xml

    <?xml version="1.0" encoding="utf-8"?>
    <configure
        xmlns="http://namespaces.zope.org/zope"
        xmlns:browser="http://namespaces.zope.org/browser"
    >
        <browser:directRouter
            name="greeting_router"
            for="*"
            class=".routers.GreetingRouter"
            namespace="Zenoss.remote"
            />
       <adapter
            factory=".facades.GreetingFacade"
            provides="Products.Zuul.interfaces.IFacade"
            name="greeting_facade"
            for="*"
            />
    </configure>

See `here <http://muthukadan.net/docs/zca.html>`__ for details about the xml tags.

Once the router and facade are configured, you can make them say hello by making this POST request:

    curl -u "Young:mypassword" -X POST -H "Content-Type: application/json" -d "{\"action\":\"GreetingRouter\",\"method\":\"sayHello\",\"data\":[{\"name\": \"Young\"}"], \"tid\":1}" -k "https://zenoss5.zenoss-1310-d/zport/dmd/greeting_router"

The request is to call sayHello("Young") in GreetingRouter. Don't forget replace Young, mypassword, and zenoss5.zenoss-1310-d with your Zenoss id, password, and virtual hostname, respectively.

The request can be made programatically in various programming language. Examples of Python and Java clients are given `here <http://community.zenoss.org/community/documentation/official_documentation/api>`_.
