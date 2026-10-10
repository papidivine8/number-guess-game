#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME
# Clean up whitespace and carriage returns from username input
USERNAME=$(echo "$USERNAME" | xargs)

# Check if user exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
USER_ID=$(echo "$USER_ID" | xargs)

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
  # Insert new user into database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  
  # Retrieve the newly created user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  USER_ID=$(echo "$USER_ID" | xargs)
else
  # Retrieve games played and best game for returning user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  GAMES_PLAYED=$(echo "$GAMES_PLAYED" | xargs)

  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$(echo "$BEST_GAME" | xargs)

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
fi

GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"
read GUESS

while true
do
  # Clean up input to remove any hidden carriage returns or whitespace
  GUESS=$(echo "$GUESS" | xargs)

  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  fi

  GUESS_COUNT=$((GUESS_COUNT + 1))

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
  else
    echo "It's higher than that, guess again:"
    read GUESS
  fi
done

# Insert the completed game stats into the database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $GUESS_COUNT)")

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"