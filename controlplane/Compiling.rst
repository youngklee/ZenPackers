==========================
Compiling Serviced in Go
==========================

Environmental Setting
======================

These environmental settings are required::

   zendev use europa

   export GOPATH=$(zendev root)/src/golang
   export PATH=$(zendev root)/src/golang/bin:${PATH}
   export ZENHOME=$(zendev root)/zenhome

Now clear out old data::

  serviced.init stop
  sudo rm -rf /tmp/serviced-root

  czd serviced
  git pull
  make

Update Compatiblity
=====================

Update Europa Build Environment (Before updating template )
-------------------------------------------------------------

Contains service templates....

* cdz
* cd build
* git pull
* Now rebuild the template and re-deploy  

