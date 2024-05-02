#!/bin/bash
# check if number is number
READ () {
  read NUMBER
  while [[ ! "$NUMBER" =~ ^[0-9]+$ ]]; do
    echo "That is not an integer, guess again:"
    read NUMBER
  done
}

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(($RANDOM % 1000 +1))

echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
if [[ -z $USER_ID ]]; then
  # add new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (name) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # get best game
  GAMES_PLAYED=$($PSQL "SELECT COUNT(guesses_count) FROM users INNER JOIN games USING(user_id) WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses_count) FROM users INNER JOIN games USING(user_id) WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
# guess number
echo "Guess the secret number between 1 and 1000:"
READ
GUESSES_COUNT=1
while [[ $NUMBER != $RANDOM_NUMBER ]]; do
  if [[ $NUMBER -lt $RANDOM_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  READ
  ((GUESSES_COUNT++))
done
# Victory message
echo "You guessed it in $GUESSES_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
# Inserting game
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (user_id, guesses_count) VALUES ($USER_ID, $GUESSES_COUNT)")
