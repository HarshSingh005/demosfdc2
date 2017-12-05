/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountTriggerHandlerTest 
 * Created By   : Rohit B (Appirio)
 * Purpose      : Test class of AccountTriggerHandler class
 * Created Date : 12/Dec/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 12/Jan/2016                  Rohit B.                Added a line to delete account for covering before 
                                                        detele functionality
 * 05/Sep/2016                  Ashu Gupta              Added testUpdateAccountOwner() for T-514023        
 
  * 27/Sept/2016                Sahil Rathore           increased code coverage      
  * 17/Jan/2017                 Suminder Singh          Fixed for errors and code coverage 
  * 10/Feb/2017                 Suminder Singh          Fixed for errors and code coverage 
  * 05/Apr/2017                 Suminder Singh          Fixed for errors and code coverage                                              
 **********************************************************************************************************/
@isTest (SeeAllData = true) //Because of rc_Bios Custom Setting 
private class AccountTriggerHandlerTest {
    static Account hhAccount, communityAccount, local_Part_Acc, local_Part_Acc_New, national_Office_Acc;
    static Contact con;
    static User u;

    @isTest 
    static void test_cascadeUpdateSponsorshipStatus() {
        System.debug('[RB] - AccountTriggerHandlerTest.test_cascadeUpdateSponsorshipStatus :: Method Start..');
        createTestSetupData();
        Account lpAcc = new Account(Id = local_Part_Acc.Id);

        Test.startTest();
            lpAcc.Hold_Status__c = 'Hold All Activity';
            lpAcc.Hold_Reason__c = 'Test Reason';
            update lpAcc;
        
        Account updatedAcc = [SELECT Id, Hold_Status__c FROM Account WHERE Id =: communityAccount.Id];
        Contact updatedCon = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c FROM Contact WHERE Id =: con.Id];

        System.assertEquals(updatedAcc.Hold_Status__c, lpAcc.Hold_Status__c);
        System.assertEquals('On Hold', updatedCon.rC_Sponsorship__Sponsorship_Status__c);
        
        lpAcc.Hold_Status__c = Null;
        update lpAcc;

        updatedAcc = [SELECT Id, Hold_Status__c FROM Account WHERE Id =: communityAccount.Id];
        updatedCon = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c FROM Contact WHERE Id =: con.Id];

        System.assertEquals(updatedAcc.Hold_Status__c, lpAcc.Hold_Status__c);
        System.assertEquals('Available', updatedCon.rC_Sponsorship__Sponsorship_Status__c);
        
        delete lpAcc;   //Added by Rohit B. on 12/Jan/2016.
        Test.stopTest();
        System.debug('[RB] - AccountTriggerHandlerTest.test_cascadeUpdateSponsorshipStatus :: Method End..');
    } // END static void test_cascadeUpdateSponsorshipStatus() {
    
    @isTest 
    static void testDeleteAccount() {
         createTestSetupData();
         con.Local_Partner__c = local_Part_Acc_New.Id;
         update con;
         delete local_Part_Acc_New;
    }
    
     @isTest 
    static void testUpdateAccountOwner() {
        createTestSetupData();
        local_Part_Acc_New.Participant_Contact_Owner__c = u.id;
        update local_Part_Acc_New;
        
        System.assertEquals(communityAccount.parentId,local_Part_Acc.id);
        communityAccount.parentId = local_Part_Acc_New.id;
        update communityAccount;
         
        Account commTest = [SELECT id,ownerId FROM Account WHERE id =: communityAccount.id];
         
        //System.assertEquals(commTest.ownerid,local_Part_Acc_New.Participant_Contact_Owner__c);
    }
    
    static void createTestSetupData() {
        System.debug('[RB] - AccountTriggerHandlerTest.createTestSetupData :: Method Start..');

        /*rC_Bios__Account_Setting__c settings = rC_Bios__Account_Setting__c.getOrgDefaults();
        settings.rC_Bios__Disable_CascadeRecordType__c = true;
        settings.rC_Bios__Disable_All__c = false;
        upsert settings rC_Bios__Account_Setting__c.Id;*/

        String accCommunityRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        String accLPRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        String accNORTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        String accHHRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        String conParticipantRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();

        national_Office_Acc = TestUtils.createAccountWithRT('Test NO Account', accNORTId, null, '765', '9234', true);
        List<Account> localAccList = new List<Account>();
        local_Part_Acc = TestUtils.createAccountWithRT('Test LP Account', accLPRTId, national_Office_Acc, '904', '3468', false);
        local_Part_Acc.Local_Partner_ID__c = '1234557';
        localAccList.add(local_Part_Acc);
        
        local_Part_Acc_New = TestUtils.createAccountWithRT('Test LP Account New', accLPRTId, national_Office_Acc, '896', '3227', false);
        local_Part_Acc_New.Local_Partner_ID__c = '1134997';
        localAccList.add(local_Part_Acc_New);
        
        insert localAccList;
        
        communityAccount = TestUtils.createAccountWithRT('Test Community Account12', accCommunityRTId, local_Part_Acc, '256', '5640', true);
        hhAccount = TestUtils.createAccountWithRT('Test Household Account1', accHHRTId, communityAccount, '569', '2131', true);

        List<Contact> listOfCon = new List<Contact>();
        
        con = TestUtils.createContact(hhAccount, 'test fName', 'test lName', false);
        con.RecordTypeId = conParticipantRTId;
        con.Community__c = communityAccount.id;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        con.Participant_Case_Number__c = '34218';
        listOfCon.add(con);
        
        Contact con1 = TestUtils.createContact(hhAccount, 'Unit test', 'Apex', false);
        con1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        con1.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con1.Correspondence_Paused__c = false;
        con1.Participant_Case_Number__c = '12435';
        con1.Participant_Number__c = '53241';
        con1.Donor_Flag__c = 'Black';
        con1.Flag_Comments__c = 'test comment';
        listOfCon.add(con1);
        insert listOfCon;
        
        Campaign testCamp = TestUtils.createCampaign('test camp',false);
        testCamp.Product_Type__c = 'Designated Fund';
        testCamp.Product_Sub_Type__c = 'Belated Christmas';
        insert testCamp;
        
        Opportunity oppNew = TestUtils.createOpportunity(hhAccount,'testOpportunity',100,false);
        oppNew.rC_Giving__Giving_Amount__c = 100;
        oppNew.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        oppNew.Participant__c = con.Id;
        oppNew.CampaignId = testCamp.Id;
        oppNew.Product_Type__c = 'Designated Fund';
        oppNew.Product_Sub_Type__c = 'As Instructed';
        oppNew.rC_Giving__Primary_Contact__c = con.Id;
        oppNew.rC_Giving__Hard_Credit_Contact__c = con.Id;
        insert oppNew;
        
         //Added by Ashu Gupta for testContactOwnerId
        Profile p = TestUtils.getProfile('System Administrator');    
        u = TestUtils.createUser('TestAG','Gupta',p.id,true); 
        
    } // END static void createTestSetupData() {
} // END private class MCSScanCloseTest {