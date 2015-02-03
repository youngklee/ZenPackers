=====================================================
PDB Tricks
=====================================================

Running loops in a PDB session
--------------------------------

* You could do this while in pdb to launch a temporary interactive Python
  session with all the local variables available::

     (pdb) !import code; code.interact(local=vars())
     >>> for k in ctxt: print k
