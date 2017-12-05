/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MCSGenerationCIL_Batch 
 * Created By   : Rohit B (Appirio)
 * Purpose      : Batch class to generate MCS for Sponsored Participants who has not been correcponded
 * Created Date : 01/Feb/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/Feb/2016					Rohit B.				Creates a separate method for creating MCS "createMCS"
 * 04/Feb/2016					Karl Houseknecht		Filtering by national office id for manual batch run
 * 05/Feb/2016					Munib Ur Rehman			Corrected LAST_N_MONTHS condition
 * 09/Feb/2016					Rohit B.				Removed extra code and schedulable mathods
 **********************************************************************************************************/
global class MCSGenerationCIL_Batch implements Database.Batchable<sObject> {
	Final String MCS_LETTER_TYPE = 'Child Initiated Letter';
	Final String MCS_STATUS = 'Active';
	
	private string nationalOfficeId;
    private integer numberOfMonths;
    
    global MCSGenerationCIL_Batch() {
		
	}
    
	global MCSGenerationCIL_Batch(Id nationalOfficeId, integer numberOfMonths) {
		this.nationalOfficeId = nationalOfficeId;
        this.numberOfMonths = numberOfMonths;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        date nMonthsAgo = date.today().addMonths(-this.numberOfMonths);
		String participantRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
		
        Database.QueryLocator locator;
        
        locator = Database.getQueryLocator([SELECT Id, Name FROM Contact WHERE RecordTypeId = :participantRT AND National_Office__c = :this.nationalOfficeId and rc_Sponsorship__Sponsorship_Status__c = 'Sponsored'
                                           AND Id NOT IN 
                                            (SELECT Participant__c FROM Mail_Control_Slip__c WHERE CreatedDate >= :nMonthsAgo AND MCS_Status__c = 'Active' AND MCS_Letter_Type__c = 'Child Initiated Letter')]);
	
    	return locator;
    } // END global Database.QueryLocator start(Database.BatchableContext BC) {

   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
		System.debug('[RB] - MCSGenerationCIL_Batch.execute :: Execution Start..');
		Integer i=1;
		List<Mail_Control_Slip__c> lstMCSToCreate = new List<Mail_Control_Slip__c>();
		for(Contact con : scope) {
		    lstMCSToCreate.add(createMCS(con));
		    System.debug('[RB] - MCSGenerationCIL_Batch.execute :: Contact(' + String.valueOf(i++) + ') = ' + con);
		} // END for(Contact con : scope) {

		if(lstMCSToCreate.size()>0)
		    insert lstMCSToCreate;
		
		System.debug('[RB] - MCSGenerationCIL_Batch.execute :: Execution End..');
	} // END global void execute(Database.BatchableContext BC, List<sObject> scope) {
	
	private Mail_Control_Slip__c createMCS(Contact con){
		Mail_Control_Slip__c mcs = new Mail_Control_Slip__c();
	    mcs.Participant__c = con.Id;
	    mcs.MCS_Letter_Type__c = MCS_LETTER_TYPE;
	    mcs.MCS_Status__c =  MCS_STATUS;
	    return mcs;
	} // END Mail_Control_Slip__c createMCS(Contact con){

	global void finish(Database.BatchableContext BC) {
		
	} // END global void finish(Database.BatchableContext BC) {
	
} // END global class MCSGeneration_CIL implements Database.Batchable<sObject> {