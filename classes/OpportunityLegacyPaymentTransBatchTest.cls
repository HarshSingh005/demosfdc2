/***********************************************************************************************************
 * Appirio, Inc
 * Name         : OpportunityLegacyPaymentTransBatchTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the OpportunityLegacyPaymentTransactionBatch
 * Created Date : 27/01/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 27/01/2016                   Munib Ur Rehman       Created
 * Aug 12, 2016                 Ashu Gupta              Made some changes as per coding standards
 * Jan 16, 2017					Suminder Singh		  Fixed for errors and code coverage
 **********************************************************************************************************/
@isTest
public with sharing class OpportunityLegacyPaymentTransBatchTest
{
    
    Final Static Id nationalAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id localAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id commAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static Id conParticipantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    Final Static Id conHouseholdRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id oppDonationRecTypeId = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    
    Static Account nationalOffice, localPartner, community,community2,acc;
    static Contact participant,participant2,con;
    static Opportunity oppNew;
    @isTest
	public static void testOpportunityLegacyPaymentTransBatch() {
        createTestData();
    	 //test starts
    	Test.startTest();
			
        
			List<Opportunity> oppList = [select id, Name, Account.id
				from Opportunity 
				where RecordType.Name = 'Donation'
				AND StageName IN ('Open','Partially Complete')
				AND Product_Type__c = 'Sponsorship'
				AND Product_Sub_Type__c IN ('Legacy Local Partner', 'Legacy Child')
				AND Legacy_type__c IN ('Term','Perpetual')];
            
			System.assertEquals(oppList.size(), 1);
			
			Database.executebatch(new OpportunityLegacyPaymentTransactionBatch(2));
			
			
		//test stops        
        Test.stopTest();
    } // END public static void testOpportunityLegacyPaymentTransBatch() {
    
    static void createTestData(){
        //create account and contact data
        nationalOffice = TestUtils.createAccountWithRT('National Office', nationalAccRecId, null,'819', null, true );
        
        localPartner = TestUtils.createAccountWithRT('Local Partner', localAccRecId, nationalOffice, '908', '1331', true);
        
        List<Account> accCommList = new List<Account>();
        
        community = TestUtils.createAccountWithRT('Community', commAccRecId, localPartner ,null,'4567' , false);
        accCommList.add(community);
        
        community2 =TestUtils.createAccountWithRT('Community 2', commAccRecId, localPartner ,null,'9912' , false);
        accCommList.add(community2);      
        
        
        
        acc = TestUtils.createAccount('My Unit test', false);
        accCommList.add(acc);
        insert accCommList;
        List<Contact> conList = new List<Contact>();
        
        participant = TestUtils.createContact(acc,'Joe','Kid',false);
        participant.Community__c = community.id;
        participant.RecordTypeId = conParticipantRecId;
        participant.Participant_Case_Number__c = '87654';
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        conList.add(participant);
        
        participant2 = TestUtils.createContact(acc,'Joe','Kid',false);
        participant2.Community__c = community.id;
        participant2.RecordTypeId = conParticipantRecId;
        participant2.Participant_Case_Number__c = '49874';
        participant2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        conList.add(participant2);
        
		
		con = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        con.RecordTypeId = conHouseholdRecId;
        //con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.Correspondence_Paused__c = false;
        //con.Participant_Case_Number__c = '12435';
        //con.Participant_Number__c = '53241';
        con.Donor_Flag__c = 'Black';
        con.Flag_Comments__c = 'test comment';
		conList.add(con);
        
        insert conList;
        
        rC_Giving__GAU__c testGAU = TestUtils.createGeneralAccountingUnit('testGAU', true);

    	Campaign testCamp = TestUtils.createCampaign('test camp',false);
		testCamp.Product_Type__c = 'Designated Fund';
		testCamp.Product_Sub_Type__c = 'Belated Christmas';
		testCamp.rC_Giving__GAU__c = testGAU.Id;
		insert testCamp;
        
		//creating Opportunity Data
		oppNew = TestUtils.createOpportunity(acc, 'testOpportunity', 100, false);
		oppNew.recordTypeId  = oppDonationRecTypeId;
		oppNew.Participant__c = participant.Id;
		oppNew.CampaignId = testCamp.Id;
	    oppNew.Product_Type__c = 'Sponsorship';
		oppNew.Product_Sub_Type__c = 'Legacy Child';        
        oppNew.rC_Giving__Is_Sustainer__c = true;
        oppNew.rC_Giving__Anniversary_Date__c = system.today();
		oppNew.rC_Giving__Primary_Contact__c = con.Id;
		insert oppNew;
        
        
    }
} // END public with sharing class OpportunityLegacyPaymentTransBatchTest