/////////// Metrics II PS3///////////

** housekeeping
clear all                   // remove anything old stored
set more off, permanently   // tell Stata not to pause
set linesize 255            // set line length for the log file
version                     // check the version of the command interpreter

* Set working directory to the current repo folder
cd "C:\Users\42610\OneDrive - Handelshögskolan i Stockholm\Documents\Metrics_II_PS3"
global wd "`c(pwd)'"

* Create folders if they do not exist
cap mkdir figures
cap mkdir output
cap mkdir logs

** Create a RED.ME file, and choose the name (in this case test_stata)
! echo "# Metrics_II_PS3" >> README.md
! git init
! git add README.md
! git commit -m "first commit"
! git branch -M main
! git remote add origin https://github.com/HannaPee/Metrics_II_PS3.git
! git push -u origin main

** capture
cap log close // close a log-file, if one is open
log using "metrics_ii_ps3.log", replace


** Question 1 **