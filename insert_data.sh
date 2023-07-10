#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    RES_WINNER=$($PSQL "INSERT INTO teams (name) values ('$WINNER') ON CONFLICT (name) DO UPDATE SET name=EXCLUDED.name RETURNING team_id")
    RES_OPPONENT=$($PSQL "INSERT INTO teams (name) values ('$OPPONENT') ON CONFLICT (name) DO UPDATE SET name=EXCLUDED.name RETURNING team_id")
    IFS=" " read -ra ARR <<< $RES_WINNER
    WINNER_ID=${ARR[0]}
    IFS=" " read -ra ARR <<< $RES_OPPONENT
    OPPONENT_ID=${ARR[0]}
    echo $($PSQL "insert into games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done
