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

  stop serviced
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



Start Serviced  
----------------
You can do it one of 2 ways, I prefer the first, which 
requires youinstall serviced.init in your ~/bin. It also
logs to /tmp/serviced.log

* serviced.init start
* cdz serviced ; serviced/serviced -master -agent

