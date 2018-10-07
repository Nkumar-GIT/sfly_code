# JSON to PostGreSQL

Python script to read the file having json data and load into PostGreSQL database, also calulates customer LTV values.

## Prerequisite:
Programming Language: Python 3.6   
Database: PostGreSQL
  
## Libraries used:
psycopg2 : To connect PostGreSQL database.  
json : To read the json data, this can be done without using json as well with additional coding.  

## Source code:
SQL script to create all the required tables in PostGreSQL and create view for customer LTV.
python script so read the file and load into respective PostGreSQL tables.
The input file (Event.txt) contains json messgages for each event and following are the important key values.  

```
type - this is type of events so created tables for each events to load this data.

verb - this is to perform the required actions. 
e.g. NEW - insert, UPLOAD - insert, UPDATE - update
```

## Future Improvements:
Add logging to have the better log info so it will be easy while debugging and monitoring.  
Add Error handeling to handle the incorrect data.
