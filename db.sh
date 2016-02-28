#!/bin/bash

#getopts example
#function for 
#function 
insert_user()
{
	#echo "Enter FileName of student record!!"
	#read filename	
	filename=$1	
	if [ -f "$filename" ];then
	#echo yes
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
		#mysql -h "localhost" -u "root" "-proot" < "db.sql"
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
#function 
test_fun()
{
	echo $1
	#read a
	#echo $a
};

while getopts ":a:b:c" opt; do
case $opt in
    a)
      	#echo "-a used";
	insert_user $OPTARG;     
	;;
    b)
      #echo "-b used: $OPTARG";
	test_fun $OPTARG;;
    c)
      echo "-c used";
      ;;
    ?)
      exit;
      ;;
  esac
done

shift $(( OPTIND - 1 ));

