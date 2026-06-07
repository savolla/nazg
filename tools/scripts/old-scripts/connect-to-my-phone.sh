PHONE_NAME='Xiaomi Redmi Note 7'
PHONE_MAC="70:3a:51:2e:eb:e7"
SSH_PORT_ON_PHONE=8022
USERNAME_ON_PHONE="u0_a171"
SEARCH_MESSAGE="searching for phone"
DOT_COUNTER=0
HANG_COUNTER=0


CMD="arp-scan -l | grep $PHONE_MAC | awk '{print $2}'"

while [ "$(arp-scan -l | grep $PHONE_MAC | awk '{print $2}')" != $PHONE_MAC ]
do
	clear
	echo -e "Connecting to $PHONE_NAME"

	echo -e $SEARCH_MESSAGE
	if [ $DOT_COUNTER -ne 3 ]
	then
		SEARCH_MESSAGE="$SEARCH_MESSAGE."
		DOT_COUNTER=$(($DOT_COUNTER+1))
	else
		SEARCH_MESSAGE="search for phone"
		DOT_COUNTER=0
		#echo -e $SEARCH_MESSAGE
	fi

	if [ $HANG_COUNTER -eq 10 ]
	then
		echo -e "reset wifi connection of your phone and try again"	
		exit 0
	fi
	HANG_COUNTER=$(($HANG_COUNTER+1))
done

echo -e "$PHONE_NAME found!"
echo -e "connecting.."
PHONE_IP=$(arp-scan -l | grep $PHONE_MAC | awk '{print $1}')
ssh $USERNAME_ON_PHONE@$PHONE_IP -p $SSH_PORT_ON_PHONE

	
