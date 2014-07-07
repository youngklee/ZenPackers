Updating Serviced in Go
==========================

Execute these commands::

   zendev use europa
   # I'd probably put these into .bashrc
   export IPADDR=$(ifconfig eth0 | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}')
   export GOPATH=$(zendev root)/src/golang
   export PATH=$(zendev root)/src/golang/bin:${PATH}
   export ZENHOME=$(zendev root)/zenhome

Clear out old Serviced data::

  # stop serviced
  serviced.init stop
  sudo rm -rf /tmp/serviced-root

Clear out old Docker data (you may have to do this more than once)::

  $(zendev root)/build/services/repos/docker_mrclean.sh

Normal Update Serviced::

  # Make sure docker is running
  cdz serviced
  git pull
  make

Enhanced Update Serviced::

  # go into the europa environment
  cdz  serviced
  git status
  # ( This next line may be required if you can't pull properly )
  git checkout HEAD isvcs/resources/logstash/logstash.conf
  git pull
  make

Update Europa Build Environment (Before updating template )
-------------------------------------------------------------

First you need the OpenTSDB and Hbase images to start.
Remember, you just blew those away::

   docker pull quay.io/zenossinc/opentsdb:v1
   docker pull quay.io/zenossinc/hbase:v1

You must update Europa too::

   cdz
   cd build
   git pull
   # Now rebuild/update the templates and re-deploy

Update Templates Method I: Map the template to match Docker
-------------------------------------------------------------

.. include:: version.rst

Build the Template::

   ZVER=daily-zenoss5-${IMAGE}:5.0.0_${BUILD}
   cdz serviced
   serviced template compile -map zenoss/zenoss5x,quay.io/zenossinc/$ZVER \
   $(zendev root)/build/services/Zenoss.${IMAGE} > /tmp/x.tpl

   # serviced template compile $(zendev root)/build/services/Zenoss.${IMAGE} > /tmp/x.tpl

   ( you probably need to start serviced now )
   TEMPLATE_ID=$(serviced template add /tmp/x.tpl)
   serviced host add $IPADDR:4979 default

Deploy Templates::

   serviced template deploy $TEMPLATE_ID default zenoss

Update Templates Method II (Possibly easier): Tag Docker image to match template
---------------------------------------------------------------------------------

First you need the template for the generic service (Do this only once)::

   serviced template compile $(zendev root)/build/services/Zenoss.${IMAGE} > /tmp/Zenoss.xxx.tpl
   serviced.init start
   TEMPLATE_ID=$(serviced template add /tmp/Zenoss.xxx.tpl)
   serviced host add $IPADDR:4979 default

This method pulls the docker image and tags it::

   # Alternative to mapping the template: Tag the image: 
   docker pull quay.io/zenossinc/zenoss-${IMAGE}-testing:5.0.0b1_${BUILD}
   docker tag  quay.io/zenossinc/zenoss-${IMAGE}-testing:5.0.0b1_${BUILD} zenoss/zenoss5x


You don't need to deploy the template since it already matches your docker image.
If this is your first time to deploy though::

   serviced template deploy $TEMPLATE_ID default zenoss


