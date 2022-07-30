#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU () {
echo -e "\n$1"
echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME
do 
  if [[  $SERVICE_NAME != 'name' ]]
  then
    echo "$SERVICE_ID) $SERVICE_NAME"
  fi
done
read SERVICE_ID_SELECTED

if [[ ! $SERVICE_ID_SELECTED =~ [1-5]+$ ]]
then 
  MAIN_MENU "I could not find that service. What would you like today?"

else 
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then 
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_INTO_CUSTOMERS=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi  
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  INSERT_INTO_APPOINTMENTS=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ((SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'),(SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED),'$SERVICE_TIME')")
  
  echo "$($PSQL "SELECT customers.name,services.name,time FROM customers FULL JOIN appointments USING (customer_id) FULL JOIN services USING (service_id) WHERE time = '$SERVICE_TIME'")" | while read NAME BAR SERVICE BAR TIME
  do
    echo -e "\nI have put you down for a $SERVICE at $TIME, $NAME."
  done
fi
}
MAIN_MENU 