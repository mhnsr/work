#!/bin/bash
#
# Startup script for the munin-node & munin-asyncd
#
# description: This script starts munin-node & munin-asyncd
# processname: munin-node & munin-asyncd

PATH="/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin"
munin_node="/usr/local/munin/sbin/munin-node"
munin_asyncd="/usr/local/munin/lib/munin-asyncd"

[ -f $munin_node ] || exit 0
[ -f $munin_asyncd ] || exit 0

RETVAL=0

# See how we were called.
case "$1" in
  start)
    echo "Starting munin-node: "
    $munin_node

    echo "Starting munin-asyncd: "
    pid="`ps -ef | grep munin-asyncd | grep -v grep | awk '{ print $2 }'`"
    if [ -z ${pid} ]; then
      $munin_asyncd &
    else
      echo "munin-asyncd already exists for running process(${pid})... aborting"
      RETVAL=1
    fi

    RETVAL=$?
    echo
    sleep 1
    ps -ef | grep -e munin-node -e munin-asyncd | grep -v grep
  ;;

  stop)
    echo "Shutting down munin-node: "
    pkill munin-node

    echo "Shutting down munin-asyncd: "
    pkill munin-asyncd
    RETVAL=$?

    echo
    sleep 1
    ps -ef | grep -e munin-node -e munin-asyncd | grep -v grep
  ;;

  check)
    echo "Check munin-node & munin-asyncd: "
    ps -ef | grep -e munin-node -e munin-asyncd | grep -v grep
  ;;

  restart)
    $0 stop
    $0 start
    RETVAL=$?
  ;;

  *)
    echo "Usage: $0 {start|stop|restart|reload|check}"
    exit 1
  ;;
esac

exit $RETVAL
