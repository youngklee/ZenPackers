==============================================================================
Zenpackers Documentation
==============================================================================

Description
------------------------------------------------------------------------------

Zenpackers is a documentation source for advanced ZP developers that goes beyond
what is documented in the existing online documents. Its not meant to be
a permanent storage but rather a staging ground for ZP developement ideas that
can be later moved to the Wiki. The Sphinx technology we use is very easy to
write in and has an easy Wike target.

Prerequisites
------------------------------------------------------------------------------

* Zenoss ZenPack Developement
* Python 2.7

We assume that you are familiar with ZenPack Development Guide and Python coding.
We further assume that we work from the base of ZP_DIR.
For NetBotz for example::

   export ZP_DIR_TOP=$ZENHOME/ZenPacks/ZenPacks.training.NetBotz
   export ZP_DIR=$ZP_DIR_TOP/ZenPacks/training/NetBotz

Motivation
------------------------------------------------------------------------------

This documentation is intended to augment (not replace) the existing
documentation, and eventually be imported into the mainstream documents. Its
build in Sphinx-doc.

This project is located at https://github.com/zenoss/ZenPackers 

So we need people to step up and transcribe some of these juicy morsels of
knowledge into new documentation. I'd like to venture that each of us can
easily put in 30mins of documentation per week, to this end.

For veterans of ZP this can help reduce the amount of repeating of answers
that could easily have a well documented solution. For newbies, it could help
you to cement your ideas together and provide you with a good documenation that
can remind you 3 weeks later when you may have forgotten what you have done.

It is the intention of this project to reduce the amount of repeated support
and questions related to ZP dev, and if we all participate in this, its almost
guaranteed that we will suceed.


Writing and Using Sphinx-Doc
-----------------------------------------------------------------------------

Installing
~~~~~~~~~~

General documenation is at http://sphinx-doc.org/latest/install.html

In order to write in Sphinx-Doc you need to be familiar with the
Restructured Text (RST) format for documentation. Its really dirt simple and
there are many examples and docs online like http://sphinx-doc.org/tutorial.html,
http://docutils.sourceforge.net/docs/user/rst/quickref.html, and
http://sphinx-doc.org/rest.html.

In Debian/Ubuntu, you need (at minimum) these packages::

   apt-get install python-sphinx make

In Centos::

   yum install python-sphinx.noarch make

In MacOSX::
  
   sudo port install py27-sphinx make

or::

   brew install sphinx


Downloading the Source from Git
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  git clone git@github.com:zenoss/ZenPackers.git

Building HTML or Other Targets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to build the HTML you simply do this::

  cd Zenpackers
  make html ; cp -a build/html /tmp/


