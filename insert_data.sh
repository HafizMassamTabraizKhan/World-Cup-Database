#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate tables to avoid duplicate entries
echo "$($PSQL "TRUNCATE games, teams RESTART IDENTITY CASCADE;")"

# Read games.csv and insert unique teams
cat games.csv | tail -n +2 | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Insert winner if not exists
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  if [[ -z $WINNER_ID ]]
  then
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$winner');")"
  fi

  # Insert opponent if not exists
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
  if [[ -z $OPPONENT_ID ]]
  then
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$opponent');")"
  fi
done

# Insert games
cat games.csv | tail -n +2 | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Get team IDs
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

  # Insert game
  echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
    VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals);")"
done
