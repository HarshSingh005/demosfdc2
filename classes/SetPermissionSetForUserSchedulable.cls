/*
 * Class        : SetPermissionSetForUserSchedulable
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Sep 11, 2013
 * Objective    : Schedulable class to execute the SetPermissionSetForUserBatch batch 
*/
global class SetPermissionSetForUserSchedulable implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        SetPermissionSetForUserBatch batch = new SetPermissionSetForUserBatch();
        batch.testUsers = new List<User>();
        Database.executeBatch(batch);    
    }
    
}