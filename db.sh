#!/bin/bash
##
#script for Bulk Registration, Bulk deletion of user, single user deletion and insertion
#

## 
#function for the Bulk registration of user by updating datbase used by dovecot
##

insert_user()
{
	echo "Enter FilePath of student record!!"
	read filename	
	#filename=$1	
	if [ -f "$filename" ];then

#for checking the right format of file that is needed for datbase update 
#roll_no_test will only store value if that only conatain 0-9 valid value and same for name
#if value is not valid that will store null and if condition will be false
		
	roll_no_test=$(awk -F" " ' $1~ "^[0-9]*$" { print $1 }' $filename)		
	name_test=$(awk -F" " ' $2~ "^[a-z,A-Z]*$" { print $2 }' $filename)
	if [ ! -z "$test_var" ] && [ ! -z "$test_var1" ]; then
		echo "Enter a default password for all users!!"
		echo -n "password:"		
		read -s pass

#mkpasswd will create SHA-256 encrypted password for default password		
		
		encrypted_pass=$(mkpasswd -m sha-256 $pass)
		cut -c1-2,6-10,11- < $filename | 
		cut -d ' ' -f1,2  |
	        awk '{print $2 "." $1 "@kiet.edu"}' | 

#for crating a file that will contain proper format according to database need. for example-
#1,"example.1313025@kiet.edu","{SHA256-CRYPT}$5$DE1nTv4.q$13/F7jHdIoVphGKkN4yAlBm"
#here 1 is domain_id email and passsword 
		awk -v var1=$encrypted_pass '{print 1 "," $1 ",""{SHA256-CRYPT}"encrypted_pass}'  > output.txt 

#mysql query to insert in database mailserver.virtual_users , user root and password is root of mysql-server		
                mysql --local-infile -h  "localhost" -u "root" "-proot" -Bse "LOAD DATA LOCAL INFILE 'output.txt' 
							      into table mailserver.virtual_users 
							      fields terminated by','  
							      lines terminated by'\n' 
							      (domain_id,email,password);"

		echo
		echo "DATABASE IS UPDATED!!"
		echo
		 
	else
		echo "File format is not right!! see man page of mailser."	
	fi
else
	echo "File not found!!"
fi
	
}

##
#function for single user registartion. 
##
insert_single_user()
{
echo  enter roll no
read roll_no
lentgh=${#roll_no}

#roll no validation it must conatin only 10 digits
if [ $lentgh -eq 10 ];then
	echo "enter first name"
	read first_name
	echo "enter a default password for users!!"
	read -s pass
	mysql_pass=$(mkpasswd -m sha-256 $pass)
	domain_id=1
	echo $mysql_pass
	mysql_email="$first_name.$(echo $roll_no | cut -c1-2,6-10)@kiet.edu" 
	echo $mysql_email
	mysql -u root -proot -Bse "insert into mailserver.virtual_users (domain_id,email,password) values($domain_id,'$mysql_email','$mysql_pass')"
	echo "Database updated!!"
	else 
		echo "roll no. is not valid"
fi
}

##
#function for the Bulk deletion of user by updating datbase used by dovecot.
#deletion will be according to year of student admission 
##

delete_user_year()
{
echo "Enter year for deletion"
echo -n "year:" 
read year
current_year=$(date "+%Y")

#for validation of year that it sould be in right format like 2016 and not beyond current year
#lower limit can be according to need here for example 1998
if [ "$year" -ge 1998 ] && [[ "$year" -le "$current_year" ]]; then
	var1=${year: -2}
	mysql_var="%.${year: -2}%"
	mysql -u root -proot -Bse "delete from mailserver.virtual_users where email like '$mysql_var'"      
	echo "Deleted from database!!!"	
	echo
else
	echo "enter in range of 1998 to $current_year"
	delete_user_year
fi
}

##
#function for Deletion of user according to branch code and year of admission
##

delete_user_branch()
{
echo "Enter year and branch code for deletion"
echo
echo -n 'Year: '
read year
current_year=$(date "+%Y")
if [ "$year" -ge 1998 ] && [[ "$year" -le "$current_year" ]]; then
	echo -n 'Branch code: '
	read branch
#branch code are two digit for every branch example 1302915025 here 15 is branch code and 13
#is year of admission
	var1=${year: -2}
	mysql_var="%.${year: -2}$branch%"
	mysql -u root -proot -Bse "delete from mailserver.virtual_users where email like '$mysql_var'"      
	echo	
	echo "Deleted from database!!!"	
else
	echo "enter in range of 1998 to $current_year"
	echo
	delete_user_branch
fi
}

##
#function for deletion of single user by entering rollno of student 
##
delete_single_user()
{
echo "enter roll number"
read roll_no
lentgh=${#roll_no}
if [ $lentgh -eq 10 ];then
	var1=$(echo $roll_no | cut -c1-2,6-10) 

#roll_no contain roll no like 1302913025 and in var1 it will be 1313025
	mysql_var="%.$var1@%" 
	mysql -u root -proot -Bse "delete from mailserver.virtual_users where email like '$mysql_var'"      
	echo "Deleted from database!!!"	
else
	echo "roll number is not correct"
	echo	
	delete_single_user
	
fi
}

help_message()
{
	echo "Usage: mailuser [Option...] [FilePath] 
       mailuser [Option...]
	
Options:
	-i, -I   for adding users in DataBase
		(-s, -S for single user insert)

	-d, -D   for deletion of user from DataBase
		(-y, -Y for year of deletion) 	
		(-b, -B for branch code)
		(-s, -S for single user delete)

	-h, -H	 for help" 
echo
echo "For any suggestion please suggest on https://github.com/ankit864"	
}

########################################################################################

#if user will not provice any argument in command line it will show help_message
if [ $# -eq 0 ] || [[ "$1" == "-" ]];
then
    help_message
    exit 0
else

	while getopts ":i:I:a:d:DhH" opt; do
	case $opt in
	    i|I)
	      	
		if [[ "$2" == "-s" || "$2" == "-S" ]]; then
				insert_single_user	
		else
		insert_user      
		fi;		
		;;
	    h|H)
			
		help_message;	
		;;
	    d|D)
	      
		if [[ "$2" == "-y" || "$2" == "-Y" ]];then		
		delete_user_year ;
		elif [[ "$2" == "-b" || "$2" == "-B" ]];then
			#echo "function to defiane for branch"
			delete_user_branch
		elif [[ "$2" == "-s" || "$2" == "-S" ]];then
			delete_single_user
				
		else
			help_message
		fi
		;;
	    
	    ?)	
		echo "mailuser: Invalid option --$1"	
		echo "Try 'mailuser -h or -H' for more information."	
		exit;
	      ;;
	  esac
	done
	
	shift $(( OPTIND - 1 ));
fi
