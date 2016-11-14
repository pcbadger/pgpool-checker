#!/bin/bash
#set -x

PGPOOL_DB_USER=super-secret-user
PCP_PORT=2525

case "$1" in
	chknode)
		NODE_ID=$2
		/usr/pgpool-9.4/bin/pcp_node_info -U $PGPOOL_DB_USER -h localhost -p $PCP_PORT -n $NODE_ID | cut -d " " -f 3
		;;
	attachnode)
		NODE_ID=$2
		/usr/pgpool-9.4/bin/pcp_attach_node -U $PGPOOL_DB_USER -h localhost -p $PCP_PORT -n $NODE_ID
		;;
	detachnode)
		NODE_ID=$2
		/usr/pgpool-9.4/bin/pcp_detach_node -U $PGPOOL_DB_USER -h localhost -p $PCP_PORT -n $NODE_ID
		;;
	chklocaldb)
		DB_IP=$2
		DB_NAME=$3
		/usr/bin/psql -lqt -U $PGPOOL_DB_USER -h ${DB_IP} | cut -d "|" -f 1 | grep -w ${DB_NAME}
		;;
	*)
		echo $"Usage: $0 {whatev}"
		exit 1

esac
