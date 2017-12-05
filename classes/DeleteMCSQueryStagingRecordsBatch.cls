/***********************************************************************************************************
 * Appirio, Inc
 * Name         : DeleteMCSQueryStagingRecordsBatch 
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Batch class to Delete MCS Query Staging Records older before 2 hours
 * Created Date : 05/Feb/2016
 *
 * Date Modified                Modified By             Description of the update
  --------------------------------------------------------------------------------------------------------
 **********************************************************************************************************/
global class DeleteMCSQueryStagingRecordsBatch implements Database.Batchable<sObject>, Schedulable {
	global DeleteMCSQueryStagingRecordsBatch() {
		
	}
	global void execute(SchedulableContext SC) 
    {
        DeleteMCSQueryStagingRecordsBatch batch = new DeleteMCSQueryStagingRecordsBatch();
        database.executeBatch(batch);
    }
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String duration = Label.MCS_Correspond_Duration;
		datetime olderDateTime = datetime.now().addHours(-2);
		String query = 'SELECT Id, Name FROM MCS_Query_Staging__c WHERE CreatedDate < :olderDateTime';
		System.debug('--------------------------->'+query);
		return Database.getQueryLocator(query);
	} // END global Database.QueryLocator start(Database.BatchableContext BC) {

   	global void execute(Database.BatchableContext BC, List<MCS_Query_Staging__c> scope) {
		System.debug('[MR] - DeleteMCSQueryStagingRecordsBatch.execute :: Execution Start..');
		List<MCS_Query_Staging__c> lstMCSRecords= new List<MCS_Query_Staging__c>();
		
		lstMCSRecords = (List<MCS_Query_Staging__c>) scope;
		
		if(lstMCSRecords.size()>0)
		    delete lstMCSRecords;
		
		System.debug('[MR] - DeleteMCSQueryStagingRecordsBatch.execute :: Execution End..');
	} // END global void execute(Database.BatchableContext BC, List<sObject> scope) {
	

	global void finish(Database.BatchableContext BC) {
		
	} // END global void finish(Database.BatchableContext BC) {
	
} // END global class DeleteMCSQueryStagingRecordsBatch implements Database.Batchable<sObject> {