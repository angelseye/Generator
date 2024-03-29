Generator
=========

Generates model, handler and view files for a coldbox application based on an existing DB structure.

Versions
--------
### 0.1.0:
Only works in a very limited capacity for MS SQL Server databases. 
Generates a model and modelService CFC, a handler CFC, a default index view CFM or all 4 files.
Puts them in to respective directories based on which file is being created.
Skips over files and directories already created

### To Install:
Simply clone this repo into a directory in your plugins directory of your Coldbox application and register it with injection or using getPlugin() in your application.

### buildCode(): 
buildCode is the main method that builds your code based on which action you call.  The buildCode() method takes 4 arguments (minimum of 2).

### Arguments:
* action: this is the action you want to perform.  model, handler, view or all.
* table: the name of the table in your database in which to build your model from.
* dir: the name of the directory to create or put your model and view codes in, inside their respective model and view directories
* file: the name of the file to create.  If your file is "user", then it will create user.cfc, userService.cfc, user.cfc (handler).

### Future Work:
* Break out model, handler, and view to separate functions
* Refactor to use cfdbinfo to make it DB generic
* Allow model to build DB tables and columns
