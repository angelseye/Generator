<!---------------------------------------------------------------------
***********************************************************************
	Copyright 2011 Coldbox Generator by Erick Wilson and AngelsEye, Inc.
	www.angelseyeinc.com | ewilson@angelseyeinc.com
***********************************************************************

	Author: 	Erick Wilson
	Date:			Dec 7, 2011
	License:	Apache 2 License
	Version:	0.1.0
	Description:
		Allows the user to generate model, modelService, and handler CFC's
		as well as view CFM's for their Coldbox based applications.  There
		are not add'l requirements when using this plugin.  Simply put the
		generator plugin in your plugins directory and create an event
		handler to access and call the plugin.

	Future Work:
		-	Break out model, handler, and view to separate functions
		-	Refactor to use cfdbinfo to make it DB generic
		-	Allow model to build DB tables and columns

---------------------------------------------------------------------->

<cfcomponent name="generator" extends="coldbox.system.Plugin" hint="A generator to quickly generate model, handler and view code from a pre-built database" output="false">


	<!--- dependencies --->
	<cfproperty name="messageBox" inject="coldbox:plugin:messageBox">


	<!--- init(): initialize the object --->
	<cffunction name="init" access="public" returntype="generator" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			super.init(arguments.controller);

			// Plug-in Properties
			setpluginName("Generator");
			setpluginVersion("0.1.0");
			setpluginDescription("I am a generator to create basic model, handler and view code to speed up development.");
			setpluginAuthor("Erick Wilson");
			setpluginAuthorURL("http://www.angelseyeinc.com");
		</cfscript>
		<!--- return data --->
		<cfreturn this>
	</cffunction>


<!--- ********************** PUBLIC METHODS ********************** --->


	<!--- buildCode(): builds all code for a new table that was input --->
	<cffunction name="buildCode" output="false" returntype="boolean">
		<!--- arguments --->
		<cfargument name="action" type="string" required="true" />
		<cfargument name="table" type="string" required="true" />
		<cfargument name="dir" type="string" required="false" />
		<cfargument name="file" type="string" required="false" />
		<!--- functionality --->
		<cfscript>
			try{
				//see if action is legit
				if(!ListFindNoCase('model,handler,view,all',arguments.action)){
					throw('The provided action is not valid. Please use "model", "handler", "view" or "all".');
				}
				//see if table exists and get table information
				if(isValidTable(table=arguments.table)){
					var tableData = getTableData(table=arguments.table);
				}else{
					throw('The table name provided is not valid.  Please check your table name and try again.');
				}

				//build directory name if not one
				arguments.dir = (arguments.dir == '') ? arguments.table : arguments.dir;
				//build file name if not one
				arguments.file = (arguments.file == '') ? arguments.dir : arguments.file;

				//build model cfc
				if(ListFindNoCase('model,all',arguments.action)){
					var model = buildModelCode(tableName=arguments.table, tableData=tableData, dir=arguments.dir, file=arguments.file);
				}
				//build service cfc
				if(ListFindNoCase('model,all',arguments.action)){
					var modelService = buildModelServiceCode(tableData=tableData, dir=arguments.dir, file=arguments.file);
				}
				//build handler cfc
				if(ListFindNoCase('handler,all',arguments.action)){
					var handler = buildHandlerCode(dir=arguments.dir, file=arguments.file);
				}
				//build view cfm
				if(ListFindNoCase('view,all',arguments.action)){
					var view = buildViewCode(dir=arguments.dir, file=arguments.file);
				}
				//set complete message
				messageBox.setMessage(type="info", message="Added files successfully.");

				//return data
				return true;
			}catch(any e){
				messageBox.setMessage(type="error", message="Caught error: " & e.message & "; " & e.detail & "; File: " & e.tagContext[1].template & "; Line: " & e.tagContext[1].line);
				return false;
			}
		</cfscript>
	</cffunction>




<!--- ********************** PRIVATE METHODS ********************** --->


	<!--- isValidTable(): checks to see if the passed in table name is valid in our DB --->
	<cffunction name="isValidTable" returntype="boolean" output="false">
		<!--- arguments --->
		<cfargument name="table" type="string" required="true" />
		<!--- functionality --->
		<cfscript>
			var sql = "select * from sys.tables where name = :tableName ;";
			var qry = new query(sql=sql);
			qry.addParam(name="tableName", value=arguments.table, cfsqltype="cf_sql_varchar");
			var results = qry.execute().getResult();
			//return data
			return (results.recordCount == 1) ? true : false;
		</cfscript>
	</cffunction>




	<!--- getTableData(): gets the data needed for the table --->
	<cffunction name="getTableData" returntype="query" output="false">
		<!--- arguments --->
		<cfargument name="table" type="string" required="true" />
		<!--- functionality --->
		<cfscript>
			var sql = "SELECT clmns.name AS [Name], usrt.name AS [DataType], ISNULL(baset.name, N'') AS [SystemType], clmns.is_identity as [isIdentity],
									CAST(
										CASE WHEN baset.name IN (N'nchar', N'nvarchar') AND clmns.max_length <> -1
										THEN clmns.max_length/2
										ELSE clmns.max_length END AS int
									) AS [Length],
									CAST(clmns.precision AS int) AS [NumericPrecision]
								FROM sys.tables AS tbl
									INNER JOIN sys.all_columns AS clmns ON clmns.object_id=tbl.object_id
									LEFT OUTER JOIN sys.types AS usrt ON usrt.user_type_id = clmns.user_type_id
									LEFT OUTER JOIN sys.types AS baset ON baset.user_type_id = clmns.system_type_id
										and baset.user_type_id = baset.system_type_id
								WHERE (tbl.name=:tableName and SCHEMA_NAME(tbl.schema_id)=N'dbo')
								ORDER BY clmns.column_id ASC;";
			var qry = new query(sql=sql);
			qry.addParam(name="tableName", value=arguments.table, cfsqltype="cf_sql_varchar");
			//return data
			return qry.execute().getResult();
		</cfscript>
	</cffunction>




	<!--- buildModelCode(): builds the model cfc by the defined params --->
	<cffunction name="buildModelCode" returntype="boolean" output="false">
		<!--- arguments --->
		<cfargument name="tableName" type="string" required="true" />
		<cfargument name="tableData" type="query" required="true" />
		<cfargument name="dir" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		<!--- functionality --->
		<cfset var theDir = "#ExpandPath('/')#/cb/model/#camelCase(arguments.dir)#" />
		<cfset var theFile = theDir & "/#camelCase(arguments.file)#.cfc">
		<!--- create directory if it doesn't exist --->
		<cfif NOT DirectoryExists(theDir)>
			<cfdirectory action="create" directory="#theDir#" />
		</cfif>
		<!--- TODO: build model cfc if it doesn't exist --->
		<cfif NOT FileExists(theFile)>
			<cfsavecontent variable="modelCode">
				<cfoutput><cfinclude template="modelCode.cfm"></cfoutput>
			</cfsavecontent>
			<cffile action="write" file="#theFile#" output="#Trim(modelCode)#">
		</cfif>
		<!--- return data --->
		<cfreturn true />
	</cffunction>




	<!--- buildModelServiceCode(): builds the model service cfc by the defined params --->
	<cffunction name="buildModelServiceCode" returntype="boolean" output="false">
		<!--- arguments --->
		<cfargument name="tableData" type="query" required="true" />
		<cfargument name="dir" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		<!--- functionality --->
		<cfset var theDir = "#ExpandPath('/')#/cb/model/#camelCase(arguments.dir)#" />
		<cfset var theFile = theDir & "/#camelCase(arguments.file)#Service.cfc">
		<!--- create directory if it doesn't exist --->
		<cfif NOT DirectoryExists(theDir)>
			<cfdirectory action="create" directory="#theDir#" />
		</cfif>
		<!--- build model service cfc if it doesn't exist --->
		<cfif NOT FileExists(theFile)>
			<cfsavecontent variable="theCode">
				<cfoutput><cfinclude template="modelServiceCode.cfm"></cfoutput>
			</cfsavecontent>
			<cffile action="write" file="#theFile#" output="#Trim(theCode)#">
		</cfif>
		<!--- return data --->
		<cfreturn true />
	</cffunction>




	<!--- buildHandlerCode(): builds the model service cfc by the defined params --->
	<cffunction name="buildHandlerCode" returntype="boolean" output="false">
		<!--- arguments --->
		<cfargument name="dir" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		<!--- functionality --->
		<cfset var theDir = "#ExpandPath('/')#/cb/handlers" />
		<cfset var theFile = theDir & "/#camelCase(arguments.file)#.cfc">
		<!--- build handler cfc if it doesn't exist --->
		<cfif NOT FileExists(theFile)>
			<cfsavecontent variable="theCode">
				<cfoutput><cfinclude template="handlerCode.cfm"></cfoutput>
			</cfsavecontent>
			<cffile action="write" file="#theFile#" output="#Trim(theCode)#">
		</cfif>
		<!--- return data --->
		<cfreturn true />
	</cffunction>




	<!--- buildViewCode(): builds the CFM file used by the handler by the defined params --->
	<cffunction name="buildViewCode" returntype="boolean" output="false">
		<!--- arguments --->
		<cfargument name="view" type="string" required="false" default="index" />
		<cfargument name="dir" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		<!--- functionality --->
		<cfset var theDir = "#ExpandPath('/')#/cb/views/#camelCase(arguments.dir)#" />
		<cfset var theFile = theDir & "/#camelCase(arguments.view)#.cfm">
		<!--- create directory if it doesn't exist --->
		<cfif NOT DirectoryExists(theDir)>
			<cfdirectory action="create" directory="#theDir#" />
		</cfif>
		<!--- build the cfm if it doesn't exist --->
		<cfif NOT FileExists(theFile)>
			<cfsavecontent variable="theCode">
				<cfoutput><cfinclude template="viewCode.cfm"></cfoutput>
			</cfsavecontent>
			<cffile action="write" file="#theFile#" output="#Trim(theCode)#">
		</cfif>
		<!--- return data --->
		<cfreturn true />
	</cffunction>




	<!--- camelCase(): turns a word with underscores into a camel case word --->
	<cffunction name="camelCase" returntype="string" output="false">
		<!--- arguments --->
		<cfargument name="word" type="string" required="true" />
		<!--- functionality --->
		<cfset var newWord = "" />
		<cfif FindNoCase('_',arguments.word)>
			<cfset wordArray = ListToArray(arguments.word,'_') />
			<cfloop index="w" from="1" to="#arrayLen(wordArray)#">
				<cfif w EQ 1>
					<cfif Len(wordArray[w])-1 IS 0>
						<cfset newWord = "#LCase(wordArray[w])#" />
					<cfelse>
						<cfset newWord = "#LCase(Left(wordArray[w],1))##Right(wordArray[w],Len(wordArray[w])-1)#" />
					</cfif>
				<cfelse>
					<cfif Len(wordArray[w])-1 IS 0>
						<cfset newWord &= "#UCase(Left(wordArray[w],1))#" />
					<cfelse>
						<cfset newWord &= "#UCase(Left(wordArray[w],1))##Right(wordArray[w],Len(wordArray[w])-1)#" />
					</cfif>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset newWord = arguments.word />
		</cfif>
		<!--- return data --->
		<cfreturn newWord />
	</cffunction>


</cfcomponent>