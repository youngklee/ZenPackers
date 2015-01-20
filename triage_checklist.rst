===============================
ZenPack Triage Checklist
===============================

Before asking for L3 help you should ensure this checklist is satisfied.

Targret Checks
======================================

#. Ensure: Target is running
#. Ensure: No blocking firewall between Target and Modelers/Collectors
#. Ensure: Manual connect (telnet, SSH, SNMP, etc) to Target 
   from Zenoss/Collectors.

Zenoss ZP Checks
======================================

#. Ensure that you have followed the Wiki documentation for setup faithfully.
#. Ensure that all zProperties are correct as per docs
#. Ensure that **zPythonClass** is correct
#. Ensure you can ping all Targets or set zPingMonitorIgnore is set to True

Zenoss Logs Checklist
======================================

Make sure you at least have these logs on hand for the L3 Engineer
(Some may not apply, but if they do, get them)::

   * ALL:       zenoss xstatus &> zstatus.log
   * ALL:       zenpack --list &> /tmp/zenpacks.log
   * Modeler:   zenmodeler run -v10 -d your.device &> /tmp/zenmo.log
   * Collector: zencommand run -v10 --workers 0 -d your.device &> /tmp/zenco.log
   * ZenPython: zenpython run -v10 --workers 0 -d your.device &> /tmp/zenpy.log
   * ZenHub:    zenhub run -v10 --workers 0 -d your.device &> /tmp/zenhub.log

If Support is Still Needed...
======================================

You can save everyone time by requesting data and access as follows:

* On behalf of the assigned L3 Engineer:

  - Gather or Create a full description of the network, environment, Targets.
  - Provide a description of what has been configured, changed, and tried
  - Arrange for GUI access to the system in question.
  - For ZAAS: Open a ticket requesting access (For the L3 Engineer)
  - For other customers: Ask the Client for SSH credentials in advance  
  - If a VPN is required, you should arrange for that ASAP; they take alota time.

