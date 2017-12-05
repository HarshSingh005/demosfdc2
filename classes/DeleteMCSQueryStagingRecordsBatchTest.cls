/***********************************************************************************************************
 * Appirio, Inc
 * Name         : DeleteMCSQueryStagingRecordsBatchTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the DeleteMCSQueryStagingRecordsBatch
 * Created Date : 05/02/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 05/02/2016                   Munib Ur Rehman         Created
 **********************************************************************************************************/
@isTest
public with sharing class DeleteMCSQueryStagingRecordsBatchTest
{
	static integer TOT_REC = 50;
	
	@isTest
	public static void TestdeleteMCSQueryStagingRecordsBatch()
    {
    	List<MCS_Query_Staging__c> listOfStagings = new List<MCS_Query_Staging__c>();
    	 //staging records older then 2 hours
    	 for(integer i = 0; i < TOT_REC; i++){
    	 	datetime olderDateTime = datetime.now().addHours(-3);
    	 	MCS_Query_Staging__c mqs = new MCS_Query_Staging__c();
    	 	mqs.CreatedDate = olderDateTime;
    	 	listOfStagings.add(mqs);
    	 }
    	 insert listOfStagings;
    	 listOfStagings = new List<MCS_Query_Staging__c>();
    	  //staging records created now
    	 for(integer i = 0; i < TOT_REC; i++){
    	 	MCS_Query_Staging__c mqs = new MCS_Query_Staging__c();
    	 	listOfStagings.add(mqs);
    	 }
    	 insert listOfStagings;
	  
	  	// total staging  records created should be 100
	  	List<MCS_Query_Staging__c> listStages = [select Id from MCS_Query_Staging__c];
	  	System.assertEquals(listStages.size(),100);
	  	//test starts
       	Test.startTest();
        Database.executebatch(new DeleteMCSQueryStagingRecordsBatch());
	  	DeleteMCSQueryStagingRecordsBatch  batch = new DeleteMCSQueryStagingRecordsBatch();
	  	batch.execute(null);
		//test stops        
        Test.stopTest();
        listStages = new List<MCS_Query_Staging__c>();
        // staging records before 2 hours will be deleted, asserting that those records will be deleted.
        listStages = [select Id from MCS_Query_Staging__c];
        System.assertEquals(listStages.size(), TOT_REC);
    } // END public static void TestdeleteMCSQueryStagingRecordsBatch()
} // END public with sharing class DeleteMCSQueryStagingRecordsBatchTest