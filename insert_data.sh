#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

insert_data() {
    filename="games.csv"
    # Loop through each line in the CSV file
    while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
        # Skip the header line
        if [ "$YEAR" == "year" ]; then
            continue
        fi
        # Check if year is not empty
        if [[ ! -z "$YEAR" ]]; then
            # Check if the team exists in the teams table and insert if not
            WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
            if [[ -z "$WINNER_ID" ]]; then
                $PSQL "INSERT INTO teams(name) VALUES ('$WINNER')"
            fi
            OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
            if [[ -z "$OPPONENT_ID" ]]; then
                $PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')"
            fi
            # Insert data into games table
            $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$YEAR', '$ROUND', (SELECT team_id FROM teams WHERE name='$WINNER'), (SELECT team_id FROM teams WHERE name='$OPPONENT'), '$WINNER_GOALS', '$OPPONENT_GOALS');"
        fi
    done < "$filename"
}

# Call the insert_data function
insert_data
