#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

# Login user
echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  ADD_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_INFO=$($PSQL "SELECT COUNT(*), MIN(number_of_moves) FROM games WHERE user_id=$USER_ID")
  IFS='|' read NUM_OF_GAMES MIN_MOVES <<< $GAMES_INFO
  echo "Welcome back, $USERNAME! You have played $NUM_OF_GAMES games, and your best game took $MIN_MOVES guesses."
fi

# Start game
NUMBER=$(($RANDOM % 1000 + 1))
GUESS_COUNT=1

echo "Guess the secret number between 1 and 1000:"
read GUESS
while [[ $GUESS != $NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS < $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    GUESS_COUNT=$(($GUESS_COUNT + 1))
  else
    echo "It's higher than that, guess again:"
    GUESS_COUNT=$(($GUESS_COUNT + 1))
  fi
  read GUESS
done

SAVE_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_moves) VALUES ($USER_ID, '$GUESS_COUNT')")
echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"
