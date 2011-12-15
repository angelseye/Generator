<cfoutput>
/**
 * Created By: #session.userName#
 * Created On: #DateFormat(Now(),'mmm d, yyyy')#
 * Description: model component that holds all data relationships, constructs, and methods for #arguments.file#
 **/

component output="false" persistent="true" entityname="#camelCase(arguments.file)#" table="#arguments.tableName#" singleton {


	//Properties
	<cfloop index="r" from="1" to="#arguments.tableData.recordCount#">property name="#camelCase(arguments.tableData.name[r])#" column="#arguments.tableData.name[r]#"<cfif arguments.tableData.isIdentity[r]> fieldtype="id" generator="identity"<cfelse> fieldtype="column"</cfif>;
	</cfloop>

	//Relationships


}
</cfoutput>