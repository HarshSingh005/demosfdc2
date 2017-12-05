/*
 * Class        : SetPermissionSetForUserBatch
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Sep 11, 2013
 * Objective    : Batch class to update the permission set field on all Users
*/
global class SetPermissionSetForUserBatch implements Database.Batchable<SObject>{
	
	public List<User> testUsers;
	
	//start
	global Database.QueryLocator start(Database.BatchableContext bc){
		String queryStr;
		//get all the Users along with Permission Sets assigned to them 
		if(Test.isRunningTest())
			queryStr = 'SELECT Permission_Set__c, (SELECT PermissionSetId FROM PermissionSetAssignments WHERE PermissionSet.IsOwnedByProfile = false) FROM User WHERE Id IN: testUsers';
		else
			queryStr = 'SELECT Permission_Set__c, (SELECT PermissionSetId FROM PermissionSetAssignments WHERE PermissionSet.IsOwnedByProfile = false) FROM User';
		return Database.getQueryLocator(queryStr);
	}
	
	//execute
	global void execute(Database.BatchableContext bc, List<SObject> scope){
		//Iterate through all User records and update the permission set field
		for(User usr : (List<User>)scope){
			if(usr.PermissionSetAssignments != null && !usr.PermissionSetAssignments.isEmpty()){
				List<String> permissionSetIds = new List<String>();
				//Iterate through each permission set and append it to the permission set field on the User record
				for(PermissionSetAssignment psa : usr.PermissionSetAssignments){
					permissionSetIds.add(psa.PermissionSetId);
				}
				usr.Permission_Set__c = String.join(permissionSetIds, ',');
			}else{//If there are no permission sets blank the field
				usr.Permission_Set__c = '';
			}
		}
		//Update the User records
		update scope; 
	}
	
	//finish
	global void finish(Database.BatchableContext BC){
		
	}
	
}