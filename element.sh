#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [ $# -eq 0 ]; then
  echo Please provide an element as an argument.
  exit
elif [[ $1 =~ ^[0-9]+$ ]]; then
  ATOMIC_NUMBER=$1
elif [ ${#1} -le 2 ]; then 
  SYMBOL=$1
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
  if [[ -z $ATOMIC_NUMBER ]]; then
   echo "I could not find that element in the database."
   exit
  fi
else
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
  if [[ -z $ATOMIC_NUMBER ]]; then
   echo "I could not find that element in the database."
   exit
  fi
fi

QUERY_RESULT=$($PSQL "SELECT e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
FROM properties p
INNER JOIN types t ON p.type_id = t.type_id
INNER JOIN elements e ON e.atomic_number = p.atomic_number
WHERE p.atomic_number = $ATOMIC_NUMBER")

if [[ -z $QUERY_RESULT ]]; then
  echo "I could not find that element in the database."
else
  echo "$QUERY_RESULT" | while read NAME BAR SYMBOL BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE
  do
    echo "The element with atomic number $(echo $ATOMIC_NUMBER| sed -r 's/^ *| *$//g') is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
fi
