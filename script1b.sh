#!/bin/bash

myfun(){

 ## Assign the first and second argument of the function into 2 variables.
 link=$1
 c=$2

 ## Use curl on the line and put the result on a temp file and run this in the background.
 ## This will create a temp file for each single curl,so that we can download all lines
 ## at the same time. We run curl on a different subshell to avoid interaction with
 ## other curls
 (curl -sf $link > "temp$c") &

 ## Assign the pid of the previous command into a variable,so that we can use it to 
 ## wait until the command finishes. Then,assign it's return code into response.
 res=$!
 wait $res
 response=$?

 ## If the return code isn't 0 , print the line into the doc,print FAILED after it,so that 
 ## we can later know that it failed in this try,and then print on stderr that it failed.
 ## We redirect stdout to stderr in a subshell to avoid interaction with other redirections.
 if test "$response" != "0"; then
   echo -n "$link " >> doc2448b.txt
   echo FAILED >> doc2448b.txt
   (>&2 echo $link FAILED)

  ## If the return code is 0 , print the line the md5sum of
  ## temp(the result of curl) into the doc.
 else
   echo -n "$link " >> doc2448b.txt
   md5sum "temp$c" >> doc2448b.txt
 fi

 ## Delete the temp file.
  rm "temp$i"
}

myfun2(){

 ## Assign the first and second argument of the function into 2 variables.
 link=$1
 c=$2

 ## Use curl on the line and put the result on a temp file and run this in the background.
 ## This will create a temp file for each single curl.
 ## We run curl on a different subshell to avoid interaction with other curls.
 (curl -sf $link > "tempb$c") &

 ## Assign the pid of the previous command into a variable,so that we can use it to 
 ## wait until the command finishes. Then,assign it's return code into response.
 res=$!
 wait $res
 response=$?

 ## Put the md5sum of the result of curl into another temp.
 ## This will create another temp file for each link.
 md5sum "tempb$c" > "temp$c"

 ## Check if the line was read in a previous run.
 if grep -Fwq "$link" doc2448b.txt
  then

   ## Read every line of the doc to check if a line has been read in a previous run,
   ## and compare their md5sums.
   while read line2
   do
    
    # Check if the "line" is in the first column of the doc.
    if [ $link = `echo $line2 | cut -d ' ' -f1` ]; then

     ## If the response(result of above curl) is not 0 then print in stderr and replace
     ## the 2nd column of the "line" in the doc with the word FAILED.
     ## We redirect stdout to stderr in a subshell to
     ## avoid interaction with other redirections.
     if test "$response" != "0"; then
      (>&2 echo $link FAILED)
      sed -i -e "s/`echo $line2 | cut -d ' ' -f2`/"FAILED"/g" doc2448b.txt

     ## If the reponse is 0 , check if the 2nd column of the "line" in the doc
     ## is the same with temp(the md5sum of curl).
     else

      ## If it's same,do nothing.
      if [ `echo $line2 | cut -d ' ' -f2` = `cut -d ' ' -f1 "temp$c"` ]; then
       continue

      ## If it's not same,print the "line" and replace the 2nd column of the "line" with
      ## temp(the md5sum of curl).
      else
       echo $link
       sed -i -e "s/`echo $line2 | cut -d ' ' -f2`/`cut -d ' ' -f1 "temp$c"`/g" doc2448b.txt
      fi

     fi
    fi
   done < doc2448b.txt

  # If the "line" isn't found on the doc, print INIT and check the response as above.
  else

   echo $link INIT

   ## We redirect stdout to stderr in a subshell
   ## to avoid interaction with other redirections.
   if test "$response" != "0"; then
    echo -n "$link " >> doc2448b.txt
    echo FAILED >> doc2448b.txt
    (>&2 echo $link FAILED)

   else
    echo -n "$link " >> doc2448b.txt
    ## Here temp already contains the md5sum of the curl command.
    echo "temp$c" >> doc2448b.txt
   fi
  fi

 ## delete the temp files
  rm "temp$i"
  rm "tempb$i"
}


## assign the first argument into a variable and keep a counter.
linksfile=$1
i=0

## if the doc doesn't exist already,create an empty one.
touch doc2448b.txt

## check if doc2448 is empty,which means it is the first time the script is running.
if [ ! -s doc2448b.txt ]; then

## read every line of "linksfile" ,ignoring the ones starting with "#".
 while read line
 do
  if [[ "$line" = "#"* ]]; then
   continue
  fi

  echo $line INIT

## run the function myfun in the background having as arguments the "line" and i
## increment i
  ((++i))

  myfun "$line" "$i" &

 done < "$linksfile"

## if the doc isn't empty,it means it's not the first time the script is running.
else

 ## read every line of "linksfile" ,ignoring the ones starting with "#".
 while read line
 do
  if [[ "$line" = "#"* ]]; then
   continue
  fi

  ## run the function myfun2 in the background 
  ## having as arguments the "line" and i , and increment i
  ((++i))

  myfun2 "$line" "$i" &

 done < "$linksfile"

fi
