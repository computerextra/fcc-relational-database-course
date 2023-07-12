#!/bin/bash
SQL="psql -X -U freecodecamp --dbname=salon -t -c "

# FUNCTIONS
MAIN_MENU(){
  if [[ -z $1 ]]
  then
    echo "Welcome to My Salon, how can I help you?"
  else
    echo -e "\n$1"
  fi
  OPTIONS=$($SQL "select service_id,name  from services order by service_id")
  echo "$OPTIONS" | while read SERVICE_ID BAR NAME
  do
    echo $SERVICE_ID\) $NAME
  done
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE=$($SQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($SQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        RES=$($SQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME') returning customer_id")
        read -r -a ARR <<< $RES
        CUSTOMER_ID=${ARR[0]}
      fi
      if [[ -z $NAME ]]
      then
        NAME=$($SQL "select name from customers where id=$CUSTOMER_ID")
      fi
      echo "What time would you like your$SERVICE, $CUSTOMER_NAME?"
      read SERVICE_TIME
      RES=$($SQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo -e "\nI have put you down for a$SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi
  else
    MAIN_MENU "I could not find that service. What would you like today?"
  fi
}



# MAIN
echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU
