1.	Login to Ansible server BIABANSIBLE01
2.	Do ssh to the server in which we are not able to login.
testadmin# ssh BIABZTBANCS01
3.	Now login into BIABZTBANCS01 VM using testadmin user.
4.	Then run below commands in BANCS VM.
#sudo pam_tally2 --user testadmin --reset
#sudo passwd testadmin
Enter Labuser1 two times.

Note: finally we get meesage as “All authentication tokens updated successfully”
