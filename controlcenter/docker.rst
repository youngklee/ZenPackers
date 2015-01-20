Docker Images
=================

We use a lot of docker images in Europa.

Finding Docker Images
----------------------

To find Images for Impact on docker:

* https://registry.hub.docker.com/u/zenoss/impact-unstable/tags/manage/

* Use curl::

     curl -s -u <<YOUR DOCKER HUB USERNAME>> 
     https://registry.hub.docker.com//v1/repositories/zenoss/impact-unstable/tags \
       | python -m json.tool \
       | sed -n 's/.*"name": "\([^"]*\)"/\1/p' \
       | tail -1


Downgrading Docker in ControlCenter
-------------------------------------

If you find yourself needing to down grade docker:

#. Stop all services::

   service service stop zenoss.core
   
#. Stop/Kill/Maim serviced::

   service serviced stop (if running Release Images)
   killall serviced && killall -9 serviced (Otherwise)

#. Stop Docker::

   service docker stop

#. Remove docker (as root)::

   apt-get purge lxc-docker\\*
   apt-get purge docker

#. Install the new (or older) docker::

   apt-get install lxc-docker-1.3.3

#. Restart Docker and Service::

   service docker start
   service serviced start (If running Release Images)
   zendev serviced >& /tmp/serviced.log & (Otherwise)

#. Start your Zenoss services if required

