#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Steph's Salon2 ~~\n"


SALON_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

echo "Welcome to my salon. What would you like done today?"

SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services;")

# display a numbered list of the services offered
echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR SERVICE
do
  echo "$SERVICE_ID) $SERVICE"
done
read SERVICE_ID_SELECTED
SERVICE_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
# if selected service_id does not exist
if [[ -z $SERVICE_SELECTED ]]
then
  # show the list of serices again
  SALON_MENU "I could not find that service. What would you like done today?"
else
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if customer does not exit
  if [[ -z $CUSTOMER_NAME ]]
  then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
    # insert details into database
    INSERT_CUSTOMER_DETAILS=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # get customer_id from database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # request appointment time from customer
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/ //g'),$CUSTOMER_NAME?"
  read SERVICE_TIME

  # insert info into appointments
  INSERT_APP_INFO=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED')")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ //g') at $SERVICE_TIME, $CUSTOMER_NAME."
fi
}
SALON_MENU
