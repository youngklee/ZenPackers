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

