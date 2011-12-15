<cfoutput>
/**
 * Created By: #session.userName#
 * Created On: #DateFormat(Now(),'mmm d, yyyy')#
 * Description: model service component that holds all the business logic between the #arguments.file# handler and model
 **/

component extends="coldbox.system.orm.hibernate.VirtualEntityService" accessors="true" output="false" {


	//Dependencies
	//property name="variableName"			inject="model:dir.modelServiceCFC";


	//init(): initialize the component
	#arguments.file#Service function init(){
		super.init(entityName="#arguments.file#");
		return this;
	}




	/********************** PUBLIC METHODS **********************/




	/********************** PRIVATE METHODS **********************/


}
</cfoutput>