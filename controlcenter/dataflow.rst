*************************************************
Data Storage and Retreival: OpenTSDB and Friends
*************************************************

Data Storage is done through two primary services:

* CentralQuery
* OpenTSDB

_______________________________________________________________________________

Logical Data Flow for Europa GUI Process
----------------------------------------

When you view the GUI, the system processes in the general order:

.. math::

  \begin{array}{ccccc}
     [GUI]      &\Rightarrow  & \fbox{JS/Perf}         &                &              \\
                &             & \Downarrow             &                &              \\
                &             & \fbox{Central Query}   &                &              \\
                &             & \Downarrow             &                &              \\
                &             & \fbox{OpenTSDB:Reader} & \Rightarrow    & \fbox{HBase} \\
  \end{array}




Logical Data Flow for Europa Modeler
-------------------------------------

 This model is extremely simplified.
 Data flow for the Modeler looks similar to before.

.. math::

  \begin{array}{ccccc}
   [ZenPack]  &\Rightarrow    & \fbox{Modeler}       &                 &              \\
              &               & \Updownarrow         &                 &              \\
              &               & \fbox{Central Query} &                 &              \\
              &               & \Updownarrow         &                 &              \\
              &               & \fbox{ZenHub}        & \Leftrightarrow &  \fbox{ZODB} \\
  \end{array}



Logical Data Flow for Europa Collection
----------------------------------------

 Data flow for Collection looks like this:

.. math::

  \begin{array}{ccc}
     [ZenPack]          &\Rightarrow      & \fbox{Collectors:Various}        \\
                        &                 & \Downarrow                       \\
                        &                 & \fbox{CC- Central Query}         \\
                        &                 & \Downarrow                       \\
  \fbox{MetricShipper}  &\Longleftarrow   & \fbox{Redis}                     \\
  \Downarrow            &                 &                                  \\
  \fbox{MetricConsumer} &\Rightarrow      &  \fbox{OpenTSDB:Writer}          \\
                        &                 & \Downarrow                       \\
                        &                 & \fbox{Hbase}                     \\
  \end{array}




