#! /bin/bash

set +x

declare -A start_options

start_options[zenhub]="-v10 --workers 0"


start_items=(
zeneventserver
zeneventd
zopectl
zenmodeler 
zenhub
zenrrdcached 
zenperfsnmp 
zenjobs
)

stop_items=(
zeneventserver 
zopectl 
zenhub 
zenjobs 
zeneventd 
zenping 
zensyslog 
zenstatus 
zenperfsnmp 
zenactiond 
zentrap 
zenmodeler 
zencommand 
zenprocess 
zenjmx 
zenwinperf 
zeneventlog 
zenwin 
zenpython 
)


do_start()
{
   for service in "${start_items[@]}"; do
     echo "${service}" start  ${start_options["$service"]}
     "${service}" start  ${start_options["$service"]}
   done
} 

do_stop()
{
   for service in "${stop_items[@]}"; do
     echo "${service}" stop
     "${service}" stop
   done
}

case "$1" in
  start)
        do_start
        ;;

  stop)
        do_stop
        ;;

  restart)
        do_stop
        do_start
        ;;
  *)
        echo "Usage: $N {start|stop}" >&2
        exit 1
        ;;
esac

exit 0
