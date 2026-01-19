#!/usr/bin/env bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT="$1"

if [[ $INPUT =~ ^[0-9]+$ ]]; then
  CONDITION="e.atomic_number = $INPUT"
else
  SAFE_INPUT=$(printf "%s" "$INPUT" | sed "s/'/''/g")
  CONDITION="e.symbol ILIKE '$SAFE_INPUT' OR e.name ILIKE '$SAFE_INPUT'"
fi

RESULT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol, t.type,
         p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE $CONDITION;
")

if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MP BP <<< "$RESULT"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
