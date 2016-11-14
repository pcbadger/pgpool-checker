#!/usr/bin/expect
set PCP_PWD [lindex $argv 0]
set DB_NAME_IN [lindex $argv 1]
set PGPOOL_DB_USER [lindex $argv 2]
set POSTGRES_SERVER1 [lindex $argv 3]
set POSTGRES_SERVER2 [lindex $argv 4]
set PCP_PORT [lindex $argv 5]

if {$PCP_PORT eq ""} {

    puts "USAGE: ./pgp_nodes_check.sh PCP_PWD DB_NAME_IN PGPOOL_DB_USER POSTGRES_SERVER1 POSTGRES_SERVER2 PCP_PORT"
    exit
}

set DB_IP_list [list $POSTGRES_SERVER1 $POSTGRES_SERVER2 ]
set NODE_ID 0

#Reset Vars
set NODE_CHECKS 0
set CHECK_NODE_RESULT ""

proc CHECK_NODE_PROC NODE_ID_arg {
	# Pulling in external vars
	global PCP_PWD
	global PGPOOL_DB_USER
	global PCP_PORT
	set NODE_ID $NODE_ID_arg

	# Resetting local vars
	set DB_CHK_RESULTS ""
	set DB_NAME_OUT ""
	set NODE_STATUS ""


	puts "Checking node $NODE_ID"
	# Check to see if node is attached
	spawn ./chkpcpinfo.sh $PGPOOL_DB_USER $PCP_PORT chknode $NODE_ID
		expect "Password:" { send "$PCP_PWD\r" }
			# 1 or 2 status means node is attached
			expect {
				"1" { set NODE_STATUS "OK" }
				"2" { set NODE_STATUS "OK" }
				}
				if { $NODE_STATUS == "OK" } {
					puts "NODE $NODE_ID is attached !\r";
					# Check next DB
				} else {
					puts "Bad Node $NODE_ID !\r";
					# If node not attached, try to attach it
					ATTACH_NODE_PROC $NODE_ID
				}
	}
########## end proc CHECK_NODE_PROC


proc ATTACH_NODE_PROC NODE_ID_arg {
	# Pulling in external vars
	global NODE_CHECKS
	global PCP_PWD
	global PGPOOL_DB_USER
	global PCP_PORT

	if { $NODE_CHECKS < 3 } {
	set NODE_ID $NODE_ID_arg
		puts "Trying to attach node $NODE_ID\r"
		puts "Attempt: $NODE_CHECKS"
		spawn ./chkpcpinfo.sh $PGPOOL_DB_USER $PCP_PORT attachnode $NODE_ID
			expect "Password:" { send "$PCP_PWD\r" }
				# The output of that command is almost always "success" so lets have another look
				puts "Check node again!\r";
				incr NODE_CHECKS
				CHECK_NODE_PROC $NODE_ID

	} else {
		puts "Giving up!\r";
	}
}
########## end proc ATTACH_NODE_PROC


proc CHECK_DB_PROC { DB_IP_arg NODE_ID_arg } {
	# Pulling in external vars
	global DB_NAME_IN
	global PGPOOL_DB_USER
	global PCP_PORT

	set DB_IP $DB_IP_arg
	set NODE_ID $NODE_ID_arg

	# Reset local vars
	set DB_CHK_RESULTS ""

	#Check if DB is accessible
	puts "Checking DB on $DB_IP"
	spawn ./chkpcpinfo.sh $PGPOOL_DB_USER $PCP_PORT chklocaldb $DB_IP $DB_NAME_IN
		# If the expected DB name is returned, that means the connection is ok
		expect {
			$DB_NAME_IN { set DB_CHK_RESULTS "OK" }
		}
			if { $DB_CHK_RESULTS == "OK" } {
				puts "DB is up !\r";
					# Check to see if node is attached
					set NODE_CHECKS 0
					CHECK_NODE_PROC $NODE_ID
			} else {
				puts "\rUh oh, DB on $DB_IP is down!\r";
				#Check next DB
			}
 }
########## end proc CHECK_DB_PROC


# Iterate over each IP in list, do stuff
foreach item $DB_IP_list {
	CHECK_DB_PROC $item $NODE_ID;
	incr NODE_ID;
}

