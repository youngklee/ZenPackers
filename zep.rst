========================================================================
ZEP Topics
========================================================================

ZEP is the Zenoss Event Processor. We'll just include a few snippets
that are floating around.

Close Old Acknowledged Events
------------------------------------------------------------------------
::
  
   import time

   from zenoss.protocols.protobufs.zep_pb2 import (
       SEVERITY_CRITICAL, 
       SEVERITY_ERROR,
       STATUS_ACKNOWLEDGED,
       )

   from Products.Zuul import getFacade

   now = int(time.time()) * 1000
   one_hour_ago = now - (3600 * 1000)

   # last_seen can be a range: beginning of range, end of range
   last_seen = (one_hour_ago, now)

   zep = getFacade('zep')
   event_filter = zep.createEventFilter(
       status=[STATUS_ACKNOWLEDGED],
       severity=[SEVERITY_ERROR, SEVERITY_CRITICAL],
       last_seen=last_seen,
       )

   zep.closeEventSummaries(eventFilter=event_filter)

