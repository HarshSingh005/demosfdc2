/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MCSGenerationCIL_BatchTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the MCSGenerationCIL_Batch
 * Created Date : 02/02/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/02/2016                   Munib Ur Rehman         Created
 **********************************************************************************************************/
@isTest
public with sharing class MCSGenerationCIL_BatchTest
{
	static integer TOT_REC = 100;
	Final Static Id CON_PT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
	
	public static testMethod void testMCSGenerationCIL_Batch() {
    	String rt = '';
    	 //create account and contact data
    	Account nationalOffice = TestUtils.createAccount('National Office' , false);
        nationalOffice.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        nationalOffice.National_Office_Id__c = '899';
        insert nationalOffice;
        
        rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        Account localPartner = TestUtils.createAccount('Local Partner' , false);
        localPartner.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        localPartner.ParentId = nationalOffice.Id;
        localPartner.Local_Partner_ID__c = '1121145';
        insert localPartner;
        
        List<Account> accList = new List<Account>();
        Account community = TestUtils.createAccount('Community', false);
        community.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community.ParentId = localPartner.Id;
        community.Community_Id__c = '3467';
        accList.add(community);
        
        Account community2 = TestUtils.createAccount('Community2', false);
        community.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community.ParentId = localPartner.Id;
        community2.Community_Id__c = '9012';
        accList.add(community2);
        
        insert accList;
        
        
        //creating 100 records of Contact
        integer newnum = 10000;
        List<Contact> contactList = new List<Contact>();
        integer i = 10000;
        integer finalRec = i+TOT_REC;
        for(i = 10000; i<finalRec;i++){
	        Contact participant = new Contact();
	        participant.FirstName = 'Joe'+i;
	        participant.LastName = 'Kid';
	       // participant.Community__c = community.id;
	        participant.RecordTypeId = CON_PT_RT;
            participant.National_Office__c = nationalOffice.Id;
	        //newnum = newnum+i;
	        participant.Participant_Case_Number__c = string.valueof(i);
	        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
	        contactList.add(participant);
        }
        insert contactList;
      
      //creating a mail control slip record and adding first contact to it.
        
        Contact cont = [select Id from Contact limit 1];
        Mail_Control_Slip__c mcs1 = TestUtils.createMailControlSlip(null,'Child Initiated Letter','Active', cont.id, null, false);
       // mcs1.Participant__c = cont.Id;
        //mcs1.MCS_Letter_Type__c = 'Child Initiated Letter';
        mcs1.CreatedDate = system.today().addDays(-160);//within 6 months
        mcs1.MCS_Date__c = system.today().addDays(-20);
        mcs1.Due_Date__c = system.today();
        //mcs1.MCS_Status__c = 'Active';
        insert mcs1;
         date nMonthsAgo = date.today().addDays(-160);
        
      /*  List<Contact> contLi = [SELECT Id, Name FROM Contact WHERE National_Office__c = :nationalOffice.Id and id = :contactList[0].ID];
        System.assertEquals(contLi.size() , TOT_REC);
       */
        Contact con=[SELECT RecordType.Name,National_Office__c from Contact Where RecordTypeId =: CON_PT_RT and rc_Sponsorship__Sponsorship_Status__c = 'Sponsored'  limit 1];
        con.National_Office__c=nationalOffice.Id;
        update con;
        System.assertEquals(con.National_Office__c, nationalOffice.Id);
        List<Contact> contList=[SELECT Id, Name FROM Contact WHERE RecordTypeId = :CON_PT_RT AND National_Office__c = :nationalOffice.Id and rc_Sponsorship__Sponsorship_Status__c = 'Sponsored'];
       Test.startTest();
            MCSGenerationCIL_Batch testIns = new MCSGenerationCIL_Batch();
            Database.executebatch(new MCSGenerationCIL_Batch(nationalOffice.Id, 1));
        Test.stopTest();
        List<Mail_Control_Slip__c> listSlip = [select Id from Mail_Control_Slip__c];
        System.assertEquals(listSlip.size(),2 );
    } // END public static testMethod void testMCSGenerationCIL_Batch() {
} // END public with sharing class MCSGenerationCIL_BatchTest