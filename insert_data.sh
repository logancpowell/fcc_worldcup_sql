#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Line 3 says "if this program is run with the argument "test" typed after it, use the test data"

# '$' is used to pass arguments to the program. we set variable X equal to argument $Y, and then we reference the...
#... result later by using $X, which is more key-stroke efficient than re-typing argument $Y.

# Empty tables so we start with a clean slate by printing a line of code in the 'fake' PSQL terminal since we used 'echo':
echo $($PSQL "TRUNCATE games, teams")

# Use the cat command to read the csv file and the while loop to assign names to the file variables:
# (the IFS="," code makes sure the CSV file is only parsed based on ",")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # check if the current CSV line is NOT the string 'year' (to skip the title line of the CSV file):
  if [[ $YEAR != year ]]
  then
    # if so, get all team IDs:
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    # if the winner ID (and therefore winner name) is not in the teams table yet...
    if [[ -z $WINNER_ID ]]
    then
      # ...add the current winner name to the table, then find the ID
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi
    # if the opponent ID (and therefore opponent name) is not in the teams table yet...
    if [[ -z $OPPONENT_ID ]]
    then
      # ...add the current opponent name to the table, then find the ID
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi

    # populate 'games' table from 'games.csv'
    ($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
  fi
done
