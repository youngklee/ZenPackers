=====================================================
Tab Completion in Python
=====================================================

Python supports tab-completion in several areas.
This allows you to hit the tab key and get possible
attributes and functions listed on the screen.

PDB Completion
---------------

Two simple lines in a ~/.pdbrc file are enough to give you
tab completion in your pdb session::

   import rlcompleter
   pdb.Pdb.complete = rlcompleter.Completer(locals()).complete

Python Interpreter Completion
-------------------------------

Add a ~/.pythonstartup.py file which contains::

   # --------------------------------------------------------------------
   # ~/.pythonstartup.py
   # --------------------------------------------------------------------
   try:
       import readline
       import rlcompleter
       import atexit
       import os
   except ImportError:
       print "Python shell enhancement modules not available."
   else:
       histfile = os.path.join(os.environ["HOME"], ".pythonhistory")
       import rlcompleter
       readline.parse_and_bind("tab: complete")
       if os.path.isfile(histfile):
           readline.read_history_file(histfile)
       atexit.register(readline.write_history_file, histfile)
       del os, histfile, readline, rlcompleter, atexit
       print "Python shell history and tab completion are enabled."
