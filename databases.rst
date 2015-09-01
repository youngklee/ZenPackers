==================================
Databases and Rabbits
==================================

This chapter covers various Zenoss database problems and how to cure them.

Corrupted Mysql Partition File
-------------------------------

If you see this in your **/opt/zenoss/log/zeneventserver.log** file::

     SQL state [HY000]; error code [1696]; Failed to read from the .par file;
     nested exception is java.sql.SQLException: 
     Failed to read from the .par file at ..........

then there is a chance you have a corrupted Mysql database.

You may have to do the following to heal it:

* Stop Mysql
* Drop the zenoss_zep database (you may have to remove /var/lib/zenoss_zep)
* Start Mysql
* Recreate the zenoss_zep database::

  [zenoss@monitor:~]: zeneventserver-create-db --dbtype=mysql

* Restart Zenoss
* Test


Corrupted RabbitMQ DB (Changed Hostnames?) 
--------------------------------------------

You see::

   http://xyz.zenoss.loc:8080/zport/acl_users/cookieAuthHelper/login

If you find that you have broken RabbitMQ you may have some errors like this in
your Event.log::

  2013-10-03T13:16:24 ERROR Zope.SiteErrorLog 1380824184.320.0639042181339 \
  http://192.168.122.24:8080/zport/dmd/Devices/Server/Linux/devices/10.87.110.77/device_router
  Traceback (innermost last):
  Module ZPublisher.Publish, line 134, in publish
  Module Zope2.App.startup, line 301, in commit
  Module transaction._manager, line 89, in commit
  Module transaction._transaction, line 327, in commit
  Module transaction._transaction, line 397, in _callBeforeCommitHooks
  Module Products.ZenMessaging.queuemessaging.publisher, line 269, in beforeCompletionHook
  Module Products.ZenMessaging.queuemessaging.publisher, line 429, in channel
  Module zenoss.protocols.amqp, line 90, in getChannel
  Module zenoss.protocols.amqp, line 47, in __init__
  Module amqplib.client_0_8.connection, line 144, in __init__
  Module amqplib.client_0_8.abstract_channel, line 95, in wait
  Module amqplib.client_0_8.connection, line 202, in _wait_method
  Module amqplib.client_0_8.method_framing, line 221, in read_method
  error: [Errno 104] Connection reset by peer

This indicates that RabbitMQ's internal setup has been corrupted. RabbitMQ does
not have a simple configuration file you can tweak. It must be fixed by setting
environment variables and then restarting RabbitMQ. Its been rumored that even
changing the hostname can make the Rabbit go insane. This is becuase RabbitMQ
names the database folders using the hostname in part.

You may be able to fix this by applying the following (Thanks PC and JC):

* Stop Zenoss
* Execute the following::

   sudo su - root
   export VHOST="/zenoss"
   export USER="zenoss"
   export PASS="zenoss"
   rabbitmqctl stop_app
   rabbitmqctl reset
   rabbitmqctl start_app
   rabbitmqctl add_vhost "$VHOST"
   rabbitmqctl add_user "$USER" "$PASS"
   rabbitmqctl set_permissions -p "$VHOST" "$USER" '.*' '.*' '.*'
   exit

* Start Zenoss

There is a script that may help too:

.. literalinclude:: reset-rabbitmq.sh

You don't need to stop zenoss services, as it does this.
  

