#!/bin/bash
# getopts example
#function 
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
	#./sample.sh
}
#delete_user()
#{

#}
help_message()
{
	echo "Usage: mailuser [Option...] [FilePath] 
	
Options:
	-i, -I   for adding users in DataBase
	-h, -H	 for help" 
echo
echo "For any bugs please report on https://github.com/ankit864"	
}
test_fun()
{
	echo $1
	#read a
	#echo $a
};


if [ $# -eq 0 ];
then
    help_message
    exit 0
else

	while getopts ":i:I:a:d:D:chH" opt; do
	case $opt in
	    i|I)
	      	#echo "-a used";
		insert_user $OPTARG;     
		;;
	    h|H)
		#echo "test"	
		help_message;	
		;;
	    d|D)
	      #echo "-b used: $OPTARG";
		test_fun $OPTARG;;
	    c)
	      echo "-c used";
	      ;;
	    ?)	
		echo "mailuser: Invalid option --$1"	
		echo "Try 'mailuser -h or -H' for more information."	
		#help_message
	      exit;
	      ;;
	  esac
	done
	
	shift $(( OPTIND - 1 ));
fi
