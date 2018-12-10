#!/bin/bash

## Assign the first argument into a variable.
tar2448=$1

## Unzip the .tar.gz file and create a dir named "assignments".
tar xf "$tar2448"

mkdir assignments

dir2448=`echo $tar2448 | cut -d '.' -f1`

## Find the ".txt" files inside the directory and put them into temp.
find "$dir2448" -name "*.txt" > temp


## For each txt inside temp, find the line that include the word https,
## put them into temp2 so that we can keep only the first https line and assign this first ## line into a variable named repo.
#meta pairnw to name tou repo,dimiourgw fakelo kai kanw git clone mesa
#elegxw to return value kai deixnw failed alliws ok
while read line
do
 ## ignore txts that dont have the word https in them
 if [[ `cat "$line" | grep https` = "" ]] 
 then
  continue
 fi
 
 ## Find the lines that include the word https and put them into temp2 so 
 ## that we can keep only the first https line and assign 
 ## this first line into a variable named repo.
 cat $line | grep https > temp2
 repo="`head -1 temp2`"

 ## Create a folder named assignments taking the 5th field separated by "/" inside
 ## the variable "repo"
 name=`echo $repo | cut -d '/' -f5 | cut -d '.' -f1`

 mkdir "assignments/$name"

 ## git clone it and get the return value
 git clone -q "$repo" "assignments/$name"

 res=$?

 if ! test "$res" -eq 0
 then
  >&2 echo "$repo: Cloning FAILED"

 else
  echo "$repo: Cloning OK"
 fi

done < temp


ls assignments > temp
while read line
do

 echo "$line:"

 numdirs=`find assignments/$line -mindepth 1 -maxdepth 1 -type d | wc -l`
 echo Number of directories: $numdirs

 txts=`find assignments/$line -name "*.txt" | wc -l`
 echo Number of txt files: $txts

 otherfs=$((`find assignments/$line -type f | wc -l`-txts))
 echo Number of other files: $otherfs

 if [[ "$numdirs" = "1" && "$txts" = "3" && "$otherfs" = "0" ]]
 then
  txts2=`find assignments/$line -maxdepth 1 -type f | wc -l`
  txts3=`find assignments/$line -mindepth 2 -maxdepth 2 -type f | wc -l`
  
  if [[ "$txts2" = "1" && "$txts3" = "2" ]]
  then
   dir1=`find assignments/$line -mindepth 1 -maxdepth 1 -type d | cut -d -f2`
   txt1=`find assignments/$line -maxdepth 1 -type f | cut -d '/' -f3`
   txt2=`find assignments/$line -mindepth 2 -maxdepth 2 -type f | head -1 | cut -d '/' -f4`
   txt3=`find assignments/$line -mindepth 2 -maxdepth 2 -type f | tail -1 | cut -d '/' -f4`

   if [[ ("$dir1" = "more" && "$txt1" = "dataA.txt" && "$txt2" = "dataB.txt" && "$txt3" = "dataC.txt") || ("$dir1" = "more" && "$txt1" = "dataA.txt" && "$txt2" = "dataC.txt" && "$txt3" = "dataB.txt") ]]
   then
    echo Directory structure is OK.

   else
    >&2 echo Directory structure is NOT OK.
   fi

  else
   >&2 echo Directory structure is NOT OK.
  fi

 else
  >&2 echo Directory structure is NOT OK.
 fi
done < temp

## Delete temp files.
rm temp
rm temp2
