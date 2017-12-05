/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MultipleDonorsUpdateBatchTest 
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class for "MultipleDonorsUpdateBatch" class
 * Created Date : 06/Apr/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 06/17/2016                    Ashu Gupta             Increased the coverage.
 * 07/21/2016					Kanika Mathur			Creating data using TestUtil class.
 **********************************************************************************************************/
@isTest
private class MultipleDonorsUpdateBatchTest {
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_COM_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id CON_PART_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    Final Static Id OPP_TR_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    Final Static Id BP_SP_RT = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();

    @isTest
    private static void test_batch() {
        Account NO_Acc = TestUtils.createAccountWithRT('1st National Account', ACC_NO_RT, null, '199', '1245', false);
        NO_Acc.BillingCountry = 'IN';
        NO_Acc.NO_Country__c = 'India';
        insert NO_Acc;
        Account LP_Acc = TestUtils.createAccountWithRT('Google Retail Partner', ACC_LP_RT, NO_Acc, '149', '1346', true);
        Account Com_Acc = TestUtils.createAccountWithRT('Maheshwari Community Services', ACC_COM_RT, LP_Acc, '159', '1247', true);
        Account HH_Acc = TestUtils.createAccountWithRT('Test Household Account', ACC_HH_RT, Com_Acc, '565', '2134', true);
        Account acc = TestUtils.createAccount('My Unit test', true);
        
        Contact participant = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participant.RecordTypeId = CON_PART_RT;
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant.Correspondence_Paused__c = false;
        participant.Participant_Case_Number__c = '12345';
        participant.MailingStreet = '23 A Bakers Street';
        participant.MailingCity = 'London';
        participant.MailingState = 'London';
        participant.MailingPostalCode = '30201';
        insert participant;  
        
        Campaign testCamp = TestUtils.createCampaign('test camp', false);
        insert testCamp;
        
        Opportunity parentOpp = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp.CloseDate = system.today() + 30;
        parentOpp.recordTypeId  = OPP_TR_RT;
        parentOpp.Participant__c = participant.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.Product_Type__c = 'Designated Fund';
        insert parentOpp;
        
        Opportunity Opp = TestUtils.createOpportunity(acc, 'testOpportunity', 100, false);
        Opp.CloseDate = system.today() + 30;
        Opp.recordTypeId  = OPP_TR_RT;
        Opp.Participant__c = participant.Id;
        Opp.CampaignId = testCamp.Id;
        Opp.Cost_Extension__c = true;
        Opp.rC_Giving__Parent__c = parentOpp.Id;
        Opp.DFC_Status__c = 'test';
        Opp.CFI_Do_Not_Substitute__c = 'Do Not Substitute - Contact Donor';
        Opp.Do_Not_Sub_Reason__c = 'Auto Upgrade';
        insert  Opp;
        
        List<rC_Bios__Preference__c> lstPref = new List<rC_Bios__Preference__c>();
        rC_Bios__Preference__c pref = TestUtils.createBiosPref(Opp, true, BP_SP_RT, false);
        pref.rC_Bios__Category__c = 'Sponsorship';
        pref.rC_Bios__Subcategory__c = 'Contact Search';
        pref.rC_Bios__Type__c = 'Music';
        pref.rC_Bios__Status__c = 'Confirmed';
        lstPref.add(pref);
       
        rC_Bios__Preference__c prefNO = TestUtils.createBiosPref(Opp, true, BP_SP_RT, false);
         prefNO.rC_Bios__Category__c = 'Sponsorship';
         prefNO.rC_Bios__Subcategory__c = 'Contact Search';
         prefNO.rC_Bios__Type__c = 'National Office';
         prefNO.rC_Bios__Status__c = 'Confirmed';
         prefNO.National_Office__c = NO_Acc.Id;
         lstPref.add(prefNO);
         
        rC_Bios__Preference__c prefLP = TestUtils.createBiosPref(Opp, true, BP_SP_RT, false);
        prefLP.rC_Bios__Category__c = 'Sponsorship'; 
        prefLP.rC_Bios__Subcategory__c = 'Contact Search';
        prefLP.rC_Bios__Type__c = 'Local Partner';
        prefLP.rC_Bios__Status__c = 'Confirmed';
       	prefLP.Local_Partner__c = LP_Acc.Id;
        lstPref.add(prefLP);
        
        rC_Bios__Preference__c prefCOM = TestUtils.createBiosPref(Opp, true, BP_SP_RT, false);
        prefCOM.rC_Bios__Category__c = 'Sponsorship'; 
     	prefCOM.rC_Bios__Subcategory__c = 'Contact Search';
        prefCOM.rC_Bios__Type__c = 'Community';
        prefCOM.rC_Bios__Status__c = 'Confirmed';
        prefCOM.Community__c = Com_Acc.Id;
        lstPref.add(prefCOM);
        
        insert lstPref;   
        
        String query = 'SELECT Id, Name, CFI_Do_Not_Substitute__c, Do_Not_Sub_Reason__c, All_Child_Correspondence__c, rC_Giving__Hard_Credit_Contact__c, ';
        query += '(SELECT Id, rC_Bios__Type__c, National_Office__c, Local_Partner__c, Community__c FROM rC_Sponsorship__Preferences__r) FROM Opportunity';
        
        MultipleDonorsUpdateBatch mdubNO = new MultipleDonorsUpdateBatch('Opportunity', query, opp, prefNO, participant);
        MultipleDonorsUpdateBatch mdubLP = new MultipleDonorsUpdateBatch('Opportunity', query, opp, prefLP, participant);
        MultipleDonorsUpdateBatch mdubCOM = new MultipleDonorsUpdateBatch('Opportunity', query, opp, prefCOM, participant);
        Test.startTest();
            Database.executeBatch(mdubNO);
            Database.executeBatch(mdubLP);
            Database.executeBatch(mdubCOM);
        Test.stopTest();
        
        Integer prefCount = (Integer)[SELECT Id FROM rC_Bios__Preference__c].size();
        System.assertNotEquals(4, prefCount);
    } // END private static void test_batch() {
} // END private class MultipleDonorsUpdateBatchTest {