<cfoutput>
<!---
	Created By: #session.userName#
	Created On: #DateFormat(Now(),'mmm d, yyyy')#
	Description: default #camelCase(arguments.view)# view file for the #camelCase(arguments.file)# handler
--->


<h1>#camelCase(arguments.view)#</h1>

<p>Please input content on this page or remove this content</p>

</cfoutput>