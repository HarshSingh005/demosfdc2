/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MCSCPRRequestTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the MCSCPRRequest
 * Created Date : 27/01/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 27/01/2016                   Munib Ur Rehman         Created
 * 17/01/2017					Suminder Singh			Fixed for errors and code coverage
 **********************************************************************************************************/
@isTest
public with sharing class MCSCPRRequestTest {

    
    //static Account nationalOffice, localPartner, community;
    //static Contact participant;

    
    public static testmethod  void testUpdateLocalPartnerNationalOffice() {
    	
    	 User testUser = [Select ID From User where userName = 'shailendra.singh@appirio.com.bridgedev'];
    	 System.debug('userName >>> '+ testUser);
    	 
    	 System.runAs(testUser) {
	    	 String ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
		     String ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
		     String ACC_COM_RT=  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
		     String CON_PR_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
	   
             Account nationalOffice = TestUtils.createAccount('National Office', false);
             nationalOffice.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
             nationalOffice.National_Office_Id__c = '899';
             insert nationalOffice;
             
             Account acc = TestUtils.createAccount('Test Account',false);
        	 acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
             insert acc;
             
             Account localPartner = TestUtils.createAccount('Local Partner', false);
             localPartner.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
             localPartner.ParentId = nationalOffice.Id;
             localPartner.Local_Partner_ID__c = '1121145';
             insert localPartner;
             
             Account community = TestUtils.createAccount('Community', false);
             community.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
             community.ParentId = localPartner.Id;
             community.Community_Id__c = '3456';
             insert community;
	
			Contact participant = new Contact();
	        participant.FirstName = 'Joe';
	        participant.LastName = 'Kid';
	        participant.Participant_Case_Number__c = '87654';	        
	        participant.AccountId = acc.Id;
            participant.rC_Bios__Active__c = true;
            participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
	        participant.RecordTypeId = CON_PR_RT;
	        insert participant;
             
            participant.Community__c = community.Id;
            update participant; 
           
             //added ac account into account list
             List<Account> accList = new List<Account>();
             accList.add(community);
             
             // creating page reference for the page and mark it as current page
             PageReference pageRef = Page.MCSCPRRequest;
             Test.setCurrentPage(pageRef);
             
             // calling standard set controller 
             ApexPages.StandardSetController sc = new ApexPages.StandardSetController(accList);
             sc.setSelected(accList);
             
             //pageRef.getParameters().put('id', String.valueOf(community.Id));
             MCSCPRRequest testMCSCPR = new MCSCPRRequest(sc);
             
             //test starts
             Test.startTest();
             testMCSCPR.submitCPRRequest();
             testMCSCPR.refreshJobInfo();
             //test ends
             Test.stopTest();
             
             //assertion done to check if there is any  Mail_Control_Slip__c record.
             List<Mail_Control_Slip__c> MCSToInsert = [select Id from Mail_Control_Slip__c];
             System.assertEquals(MCSToInsert.size() , 0);
			 system.debug('>>>> + participant >>> '+ participant.Id);
    	 }
        
       
    }
    
} // END public with sharing class MCSCPRRequestTest