#!/bin/bash
GUESS=0
ID_USER=
NAME=
SECRET_NUMBER=$(( RANDOM%1000 + 1 ))
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only --no-align -c"
function GAME(){
if [[ -z $1 ]]
 then
 # you begin guessing

 #echo "$SECRET_NUMBER"
  echo -e "\nGuess the secret number between 1 and 1000:"
    else
    # you try to get the secret number
    echo -e "\n$1"
  fi
    read INPUT
    # evrey time you read an input it will add the guess number
     GUESS=$(( GUESS + 1 ))
  
  if [[ $INPUT =~ ^[0-9]+$ ]]
    then 
    # input is the number
      case $INPUT in
        $SECRET_NUMBER) ENDGAME  "$SECRET_NUMBER";;
        *) CONTGAME "$INPUT";;
      esac
    else
    # other input
    GAME "That is not an integer, guess again:"
  fi
}
ASK_USERNAME(){
  echo -e "\nEnter your username:"
  read NAME

  USERNAME_CHARACTERS=$(echo $NAME | wc -c)
  if [[ $USERNAME_CHARACTERS -gt 22 ]] || [[ -z $NAME ]]
  then
    ASK_USERNAME
  fi
}

function GUESS_MENU(){
   #start by enter your name
ASK_USERNAME
  if (( $($PSQL "SELECT id_user FROM users WHERE  username ILIKE '$NAME'") ))
  then 
  #user already exist
      ID_USER=$($PSQL "SELECT id_user FROM users WHERE username ILIKE '$NAME'")
      DATA=$($PSQL "SELECT min(nbre_guess), count(*) FROM games INNER JOIN users USING (id_user) WHERE id_user ='$ID_USER'")
      echo "$DATA" | while IFS="|" read BEST_GAME GAMES_PLAYED
   do 
   echo -e "\nWelcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
   done
   # start your Game
   GAME
    else
    #user don't exist
    echo -e "\nWelcome, $NAME! It looks like this is your first time here.\n"
    #insert the new user
    INSERT_NAME=$($PSQL "INSERT INTO users(username) VALUES ('$NAME')")
    ID_USER=$($PSQL "SELECT id_user FROM users WHERE username ILIKE '$NAME'")
    # start the game
    GAME 
  fi

}
function CONTGAME (){
  # continue guessing
          if [[ $1 -gt $SECRET_NUMBER ]] 
            then     
              GAME "It's lower than that, guess again:"
            else 
              GAME "It's higher than that, guess again:"
          fi
}
function ENDGAME (){
  #  finish 
if [[  $ID_USER ]]
  then 
  #insert data and output
  INSERT_GAME=$($PSQL "INSERT INTO games(nbre_guess, id_user) VALUES ($GUESS, '$ID_USER')")
  #echo $INSERT_GAME
  TRIES=$(( GUESS - 1 ))
  echo -e "\nYou guessed it in $GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"
  else 
  echo ERROR!
fi

}

GUESS_MENU
