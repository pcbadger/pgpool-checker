# pgpool-checker
basic scripts to check pgpool nodes and make sure they're up


Background

We noticed an issue wherby PGPool would not correctly determine if local or remote postrges nodes were actually up and running. This happened across many different versions of pgpool so these scripts were written as a workaround.



Setup

After version 3.5, pgpool removed the ability to pass in the password as an argument, necessitating the use of expect, so you'll need to install that.

Simply download both scripts to the same directory, modify the variables as stated about and set up a cron job (or other configuration management tool) to periodically run the pgp_nodes_check.sh. This will check the current status of both nodes and if either of them seems to be unattached, it will call the chkpcpinfo.sh script to attach the node.



Usage

./pgp_nodes_check.sh PCP_PWD DB_NAME_IN PGPOOL_DB_USER POSTGRES_SERVER1 POSTGRES_SERVER2 PCP_PORT