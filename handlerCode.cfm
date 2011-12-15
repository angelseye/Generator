<cfoutput>
/**
 * Created By: #session.userName#
 * Created On: #DateFormat(Now(),'mmm d, yyyy')#
 * Description: handler component that glues together the views with the #arguments.file# model
 * 	*** YOU DO NOT PUT BUSINESS LOGIC IN HERE. PLEASE PUT IT IN THE APPROPRIATE MODEL SERVICE FILE ***
 **/

component output="false" {


	//Dependencies
	property name="#camelCase(arguments.file)#Service"			inject="model:#camelCase(arguments.dir)#.#camelCase(arguments.file)#Service";


	/********************** PRE/POST HANDLER METHODS **********************/
/* UNCOMMENT THIS TO USE
	//preHandler(): used to fire off functionality before EVERY handler called
	function preHandler(){ //code goes here }

	//postHandler(): used to fire off functionality after EVERY handler called
	function postHandler(){ //code goes here }
*/




	/********************** PUBLIC METHODS **********************/


	//index(): default controller when an action is not given
	public void function index(required any event, required any rc, required any prc){
		//handler code goes here
	}


}
</cfoutput>