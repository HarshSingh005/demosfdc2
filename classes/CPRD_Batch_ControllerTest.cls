/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CPRD_Batch_ControllerTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the CPRD_Batch_Controller
 * Created Date : 28/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 28/07/2016                   Munib Ur Rehman       Created
 **********************************************************************************************************/
@isTest
public with sharing class CPRD_Batch_ControllerTest
{
	
	public static Web_Transaction__c webTransaction;
    public static Batch_Upload_Distribution__c bud;
    public static rC_Connect__Batch_Upload__c upload;
    public static  rC_Giving__Batch__c batch;
    public static Contact kid;
    @isTest
	public static void testCPRD_Batch_Controller() {
		createTesData();
		Test.startTest();
		Test.setCurrentPageReference(new PageReference('Page.CPRD_Batch')); 
		System.currentPageReference().getParameters().put('id', batch.Id);
    	CPRD_Batch_Controller batchCtrl = new CPRD_Batch_Controller();
    	String batchFilter = batchCtrl.batchUploadStatusFilter;
    	Schema.DescribeFieldResult fieldResult = rC_Connect__Batch_Upload__c.rC_Connect__Batch_Upload_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String labelToTest = '';
        for (Schema.PicklistEntry f : ple){
        	labelToTest = f.getLabel();
        	break;
        }
        System.assert(batchFilter.contains(labelToTest));
    	Test.stopTest();
        //System.assertEquals(MCSToInsert.size() , 2);
    } // END public static void testCPRD_Batch_Controller() {
    
    public static void createTesData(){
    	
    	 rC_Giving__Contact_Setting__c settings = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
       settings.rC_Giving__Disable_RollupHardCredits__c = true; 
       upsert settings ; 
        
        Account acc = TestUtils.createAccount('Account1', true);
        
         Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        kid = TestUtils.createContact(acc , 'Good', 'Kid', false);
        kid.RecordTypeId = participantRecordTypeId;
        kid.Participant_Case_Number__c = '12345';
        kid.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        kid.rC_Giving__Track_Hard_Credits__c = true;
        insert kid;
        
    	batch = TestUtils.createBatch('testBatch', 100.0, 1000, true);
        
        webTransaction = TestUtils.createWebTransaction(true);
        upload = TestUtils.createBatchUpload('Test', false);
        upload.Participant_Number__c = kid.Contact_Number__c;
        upload.rC_Connect__Giving_Giving_Amount__c = 100;
        upload.Web_Transaction__c = webTransaction.Id;
        upload.rC_Connect__Batch_Upload_Batch__c = batch.Id;
        upload.rC_Connect__HardCreditContact__c = kid.Id;
        insert upload;
    	
    }
} // END public with sharing class CPRD_Batch_ControllerTest