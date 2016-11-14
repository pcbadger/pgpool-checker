# pgpool-checker
basic scripts to check pgpool nodes and make sure they're up

Background

We noticed an issue wherby PGPool would not correctly determine if local or remote postrges nodes were actually up and running. This happened across many different versions of pgpool so these scripts were written as a workaround.

Pre-requisites

These are pulled from ansible templates, so for version 0.1, all variables are hard coded. You'll need to modify each script to update the following variables

PCP_PWD
DB_NAME_IN
POSTGRES_MASTER_SERVER
POSTGRES_SLAVE_SERVER
PGPOOL_DB_USER
PCP_PORT

After version 3.5, pgpool removed the ability to pass in the password as an argument, necessitating the use of expect, so you'll need to install that.

Actual Usage

Simply download both scripts to the same directory, modify the variables as stated about and set up a cron job (or other configuration management tool) to periodically run the pgp_nodes_check.sh. This will check the current status of both nodes and if either of them seems to be unattached, it will call the chkpcpinfo.sh script to attach the node.