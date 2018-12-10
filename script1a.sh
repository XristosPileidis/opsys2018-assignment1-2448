#!/bin/bash

## Assign the first argument into a variable.
linksfile=$1

## If the doc doesn't exist already,create an empty one.
touch doc2448a.txt

## Check if doc2448 is empty,which means it is the first time the script is running.
if [ ! -s doc2448a.txt ]; then

 ## Read every line of "linksfile" ,ignoring the ones starting with "#".
 while read line
 do
  if [[ "$line" = "#"* ]]; then
   continue
  fi

  echo $line INIT

  ## Use curl on the line and put the result on a temp file.
  curl -sf $line > temp

  ## Assign the return code of the previous command into a variable.
  response=$?

  ## If the return code isn't 0 , print the line into the doc,print FAILED after it,so that 
  ## we can later know that it failed in this try,and then print on stderr that it failed.
  if test "$response" != "0"; then
   echo -n "$line " >> doc2448a.txt
   echo FAILED >> doc2448a.txt
   >&2 echo $line FAILED

  ## If the return code is 0 , print the line the md5sum of
  ## temp(the result of curl) into the doc.
  else
   echo -n "$line " >> doc2448a.txt
   md5sum temp >> doc2448a.txt
  fi

 done < "$linksfile"
 #delete temp
 rm temp

## If the doc isn't empty,it means it's not the first time the script is running.
else

 ## Read every line of "linksfile", ignoring the ones starting with "#".
 while read line
 do

  if [[ "$line" = "#"* ]]; then
   continue
  fi

  ## Put the result of curl into temp2 so that we can get it's md5sum to compare it with the
  ## ones in the doc.
  curl -sf $line > temp2

  ## Assign the return code of the previous command into a variable.
  response=$?

  ## Put the md5sum of the result of curl into temp.
  md5sum temp2 > temp

  ## Check if the line was read in a previous run.
  if grep -Fwq "$line" doc2448a.txt
  then

   ## Read every line of the doc to check if a line has been read in a previous run,
   ## and compare their md5sums.
   while read line2
   do

    # Check if the "line" is in the first column of the doc.
    if [ $line = `echo $line2 | cut -d ' ' -f1` ]; then

     ## If the response(result of above curl) is not 0 then print in stderr and replace
     ## the 2nd column of the "line" in the doc with the word FAILED.
     if test "$response" != "0"; then
      >&2 echo $line FAILED
      sed -i -e "s/`echo $line2 | cut -d ' ' -f2`/"FAILED"/g" doc2448a.txt

     ## If the reponse is 0 , check if the 2nd column of the "line" in the doc
     ## is the same with temp(the md5sum of curl).
     else

      ## If it's same,do nothing.
      if [ `echo $line2 | cut -d ' ' -f2` = `cut -d ' ' -f1 temp` ]; then
       continue

      ## If it's not same,print the "line" and replace the 2nd column of the "line" with
      ## temp(the md5sum of curl).
      else
       echo $line
       sed -i -e "s/`echo $line2 | cut -d ' ' -f2`/`cut -d ' ' -f1 temp`/g" doc2448a.txt
      fi

     fi
    fi
   done < doc2448a.txt

  # If the "line" isn't found on the doc, print INIT and check the response as above.
  else

   echo $line INIT

   if test "$response" != "0"; then
    echo -n "$line " >> doc2448a.txt
    echo FAILED >> doc2448a.txt
    >&2 echo $line FAILED

   else
    echo -n "$line " >> doc2448a.txt
    ## Here temp already contains the md5sum of the curl command.
    echo temp >> doc2448a.txt
   fi
  fi
 done < "$linksfile"
 
 ## delete temp and temp2
 rm temp
 rm temp2
fi
