#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here"

  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')"

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
fi
