#!/bin/bash
 
insert_user()
{
	#echo "Enter FileName of student record!!"
	#read filename	
	filename=$1	
	if [ -f "$filename" ];then
	#echo test
	test_var=$(awk -F" " ' $1~ "^[0-9]*$" { print $1 }' $filename)
	test_var1=$(awk -F" " ' $2~ "^[a-z,A-Z]*$" { print $2 }' $filename)
	#echo $test_var
	if [ ! -z "$test_var" ] && [ ! -z "$test_var1" ]; then
		echo "enter a default password for users!!"
		read -s pass
		var=$(mkpasswd -m sha-256 $pass)
		#echo $default
		#echo $pass
		cut -c1-2,6-10,11- < $filename | 
		cut -d ' ' -f1,2  |
	        awk '{print $2 "." $1 "@kiet.edu"}' | 
		awk -v var1=$var '{print 1 "," $1 ",""{SHA256-CRYPT}"var1}'  > output.txt 
		#sed 's/$/@kiet.edu/' output.txt > test.txt
		#cut -d ' ' -f2,1
		mysql -h "localhost" -u "root" "-proot" < "db.sql"
		echo
		echo "DATABASE IS UPDATED!!"
		echo
		 
	else
		echo "File format is not right!!"	
	fi
else
	echo "File not found!!"
fi
	
}

insert_single_user()
{
echo  enter roll no
read roll_no
lentgh=${#roll_no}
#echo lentgh $lentgh
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

delete_user_year()
{
echo "Enter year for deletion"
echo -n year 
read year
current_year=$(date "+%Y")
#echo current 

if [ "$year" -ge 1998 ] && [[ "$year" -le "$current_year" ]]; then
	var1=${year: -2}
	mysql_var="%.${year: -2}%"
	mysql -u root -proot -Bse "delete from mailserver.virtual_users where email like '$mysql_var'"      
	echo "Deleted from database!!!"	
	echo
	#echo $mysql_var
else
	echo "enter in range of 1998 to $current_year"
	delete_user_year
fi

}

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
	var1=${year: -2}
	mysql_var="%.${year: -2}$branch%"
	mysql -u root -proot -Bse "delete from mailserver.virtual_users where email like '$mysql_var'"      
	echo	
	echo "Deleted from database!!!"	
	#echo $mysql_var
else
	echo "enter in range of 1998 to $current_year"
	echo
	delete_user_branch
fi
}
delete_single_user()
{
echo "enter roll number"
read roll_no
#echo $roll_no
lentgh=${#roll_no}
#echo lentgh $lentgh
if [ $lentgh -eq 10 ];then
	var1=$(echo $roll_no | cut -c1-2,6-10) 
	mysql_var="%.$var1@%" 
	mysql -u root -proot -Bse "delete from mailserver.virtual_users where email like '$mysql_var'"      
	echo "Deleted from database!!!"	
	#echo $mysql_var
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
#test_fun()
#{
#	echo $1
	#read a
	#echo $a
#};


if [ $# -eq 0 ] || [[ "$1" == "-" ]];
then
    help_message
    exit 0
else

	while getopts ":i:I:a:d:DhH" opt; do
	case $opt in
	    i|I)
	      	#echo "-a used";
		if [[ "$2" == "-s" || "$2" == "-S" ]]; then
	#		echo "enter filename"
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
