/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MultipleDonorsUpdateControllerTest 
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class for "MultipleDonorsUpdateController" class
 * Created Date : 07/Apr/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 06/17/2016                   Ashu Gupta              Increased the coverage
 * 08/09/2016                   Ravi Chauhan            Ramp Up Code Coverage  
 * 08/17/2016                   Ashu Gupta              Created test data using TestUtils class
 **********************************************************************************************************/
@isTest
private class MultipleDonorsUpdateControllerTest {
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_COM_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id ACC_CF_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
    Final Static Id CON_PART_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    Final Static Id oppTransactionRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    final static id BiosPref_RT_SP = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();
    public static Account NO_Acc, LP_Acc, Com_Acc, CF_Acc, acc;
    public static Contact participant, participant2, participant3;
    public static Campaign testCamp;
    public static Opportunity parentOpp, Opp;
    public static List<rC_Bios__Preference__c> lstPref;
    public static rC_Bios__Preference__c pref, prefNO, prefLP, prefCOM; 
    
    @isTest
    private static void test_callbatch() {
        ApexPages.Message[] pageMessages;
        setUpTestData();
        Test.startTest();
        Test.setCurrentPage(Page.MultipleDonorsUpdate);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new rC_Bios__Preference__c());
        MultipleDonorsUpdateController mduc = new MultipleDonorsUpdateController(stdCon);
        System.assertEquals(mduc.allowToRunBatch,true);
        System.assertEquals(mduc.isTimerEnabled,true);
        system.assertEquals(mduc.preferenceoverride,false);
        mduc.childConObj = participant;
        mduc.sponsorOppty = Opp;
        mduc.prfrncObj = prefNO;
        
        mduc.callbatch();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(pageMessages[0].getSummary().contains('Your update request has been submitted, batch update is in progress.'), true);
        System.assertEquals(mduc.allowToRunBatch,false);
        mduc.refreshJobInfo();
        system.assertEquals(mduc.jobs.size(),1);
        system.debug('@@@ Status of job before test completion'+mduc.jobs[0].status);
        Test.stopTest();
        system.debug('@@@ Status of job after test completion  '+mduc.jobs[0].status);
        Integer prefCount = (Integer)[SELECT Id FROM rC_Bios__Preference__c].size();
        System.assertEquals(4, prefCount);
    } // END private static void test_callbatch() {
    
    @isTest
    private static void test_callbatchNew(){
        
        setUpTestData();
        
        Test.startTest();
        
        // Calling the Batch When Local Partner and Community on Contact is not null
        Test.setCurrentPage(Page.MultipleDonorsUpdate);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new rC_Bios__Preference__c());
        MultipleDonorsUpdateController mduc = new MultipleDonorsUpdateController(stdCon);
        mduc.childConObj = participant2;
        mduc.sponsorOppty = Opp;
        mduc.prfrncObj = prefNO;
        mduc.preferenceoverride = true;
        mduc.callbatch();
        mduc.refreshJobInfo();
        // Assertion
        Integer count = [SELECT count() FROM rC_Bios__Preference__c];
        System.assertEquals(4, count);
        
        // Calling the Batch When Local Partner on Contact is not null but Community null
        stdCon = new ApexPages.StandardController(new rC_Bios__Preference__c());
        mduc = new MultipleDonorsUpdateController(stdCon);
        mduc.childConObj = participant3;
        mduc.sponsorOppty = Opp;
        mduc.prfrncObj = prefNO;
        mduc.preferenceoverride = true;
        mduc.callbatch();
        mduc.refreshJobInfo();
        
        // Assertion
        count = [SELECT count() FROM rC_Bios__Preference__c];
        System.assertEquals(4, count);
        
        Test.stopTest();
        
    }
    
    private static void setUpTestData(){
        List<Account> listAcc = new List<Account>();
         acc = TestUtils.createAccount('My Unit test', false);
         listAcc.add(acc);
        NO_Acc = TestUtils.createAccountWithRT('1st National Account', ACC_NO_RT, null, '199', '1245', false);
        NO_Acc.BillingCountry = 'IN';
        NO_Acc.NO_Country__c = 'India';
        listAcc.add(NO_Acc);
        
        insert listAcc;
        
        LP_Acc = TestUtils.createAccountWithRT('Google Retail Partner', ACC_LP_RT, NO_Acc, '149', '1346', true);
        
        Com_Acc = TestUtils.createAccountWithRT('Maheshwari Community Services', ACC_COM_RT, LP_Acc, '159', '1247', true);
        
        CF_Acc = TestUtils.createAccountWithRT('Test Household Account', ACC_CF_RT, Com_Acc, '560', '2030', true);
        
       
        
        List<Contact> contactList = new List<Contact>();
        
        participant = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participant.RecordTypeId = CON_PART_RT;
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant.Correspondence_Paused__c = false;
        participant.Community__c = Com_Acc.Id;
        participant.Donor_Alliance__c = CF_Acc.Id;
        participant.Participant_Case_Number__c = '12345';
        participant.MailingStreet = '23 A Bakers Street';
        participant.MailingCity = 'London';
        participant.MailingState = 'London';
        participant.MailingPostalCode = '30201';
        contactList.add(participant);
        
        participant2 = TestUtils.createContact(acc, 'Unit test 2', 'Apex', false);
        participant2.RecordTypeId = CON_PART_RT;
        participant2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant2.Correspondence_Paused__c = false;
        participant2.Community__c = Com_Acc.Id;
        participant2.Donor_Alliance__c = CF_Acc.Id;
        participant2.Local_Partner__c = LP_Acc.Id;
        participant2.Participant_Case_Number__c = '12345';
        participant2.MailingStreet = '23 A Bakers Street';
        participant2.MailingCity = 'London';
        participant2.MailingState = 'London';
        participant2.MailingPostalCode = '30201';
        contactList.add(participant2);
        
        participant3 = TestUtils.createContact(acc, 'Unit test 3', 'Apex', false);
        participant3.RecordTypeId = CON_PART_RT;
        participant3.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant3.Correspondence_Paused__c = false;
        participant3.Community__c = null;
        participant3.Donor_Alliance__c = CF_Acc.Id;
        participant3.Local_Partner__c = LP_Acc.Id;
        participant3.Participant_Case_Number__c = '12345';
        participant3.MailingStreet = '23 A Bakers Street';
        participant3.MailingCity = 'London';
        participant3.MailingState = 'London';
        participant3.MailingPostalCode = '30201';
        contactList.add(participant3);
        
        insert contactList;
        
        testCamp = TestUtils.createCampaign('test camp',true);
      
        
        parentOpp = TestUtils.createOpportunity(acc,'parentOpportunity',100,false);
        parentOpp.recordTypeId  = oppTransactionRecTypeId ;
        parentOpp.Participant__c = participant.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.rC_Giving__Giving_Amount__c = 100;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.Product_Type__c = 'Designated Fund';
        insert parentOpp;
        
        Opp = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        Opp.recordTypeId  = oppTransactionRecTypeId ;
        Opp.Participant__c = participant.Id;
        Opp.CampaignId = testCamp.Id;
        Opp.rC_Giving__Giving_Amount__c = 100;
        Opp.Cost_Extension__c = true;
        Opp.rC_Giving__Parent__c = parentOpp.Id;
        Opp.DFC_Status__c = 'test';
        Opp.CFI_Do_Not_Substitute__c = 'Do Not Substitute - Contact Donor';
        Opp.Do_Not_Sub_Reason__c = 'Auto Upgrade';
        insert  Opp;
        
        lstPref = new List<rC_Bios__Preference__c>();
        
        pref = TestUtils.createBiosPref(Opp,true,BiosPref_RT_SP,false); 
        pref.rC_Bios__Category__c = 'Sponsorship';
        pref.rC_Bios__Subcategory__c = 'Contact Search';
        pref.rC_Bios__Type__c = 'Music';
        pref.rC_Bios__Status__c = 'Confirmed';
        /*new rC_Bios__Preference__c(rC_Sponsorship__Opportunity__c = Opp.Id,
                                          rC_Bios__Active__c = true,
                                          RecordTypeId = 
                                          rC_Bios__Category__c = 'Sponsorship', 
                                          rC_Bios__Subcategory__c = 'Contact Search',
                                          rC_Bios__Type__c = 'Music',
                                          rC_Bios__Status__c = 'Confirmed');
        */
        lstPref.add(pref);
        
        prefNO = TestUtils.createBiosPref(Opp,true,BiosPref_RT_SP,false); 
        prefNO.rC_Bios__Category__c = 'Sponsorship';
        prefNO.rC_Bios__Subcategory__c = 'Contact Search';
        prefNO.rC_Bios__Type__c = 'National Office';
        prefNO.rC_Bios__Status__c = 'Confirmed';
        prefNO.National_Office__c = NO_Acc.Id;
        /*new rC_Bios__Preference__c(rC_Sponsorship__Opportunity__c = Opp.Id,
                                            rC_Bios__Active__c = true,
                                            RecordTypeId = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId(),
                                            rC_Bios__Category__c = 'Sponsorship', 
                                            rC_Bios__Subcategory__c = 'Contact Search',
                                            rC_Bios__Type__c = '',
                                            rC_Bios__Status__c = 'Confirmed',
                                            National_Office__c = NO_Acc.Id);
        */lstPref.add(prefNO);
        
        prefLP = TestUtils.createBiosPref(Opp,true,BiosPref_RT_SP,false); 
        prefLP.rC_Bios__Category__c = 'Sponsorship';
        prefLP.rC_Bios__Subcategory__c = 'Contact Search';
        prefLP.rC_Bios__Type__c = 'Local Partner';
        prefLP.rC_Bios__Status__c = 'Confirmed';
        prefLP.Local_Partner__c = LP_Acc.Id;
        /*new rC_Bios__Preference__c(rC_Sponsorship__Opportunity__c = Opp.Id,
                                            rC_Bios__Active__c = true,
                                            RecordTypeId = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId(),
                                            rC_Bios__Category__c = 'Sponsorship', 
                                            rC_Bios__Subcategory__c = 'Contact Search',
                                            rC_Bios__Type__c = '',
                                            rC_Bios__Status__c = 'Confirmed',
                                            Local_Partner__c = LP_Acc.Id);
        */lstPref.add(prefLP);
        
        prefCOM = TestUtils.createBiosPref(Opp,true,BiosPref_RT_SP,false); 
        prefCOM.rC_Bios__Category__c = 'Sponsorship';
        prefCOM.rC_Bios__Subcategory__c = 'Contact Search';
        prefCOM.rC_Bios__Type__c = 'Community';
        prefCOM.rC_Bios__Status__c = 'Confirmed';
        prefCOM.Community__c = Com_Acc.Id;
        /*new rC_Bios__Preference__c(rC_Sponsorship__Opportunity__c = Opp.Id,
                                             rC_Bios__Active__c = true,
                                             RecordTypeId = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId(),
                                             rC_Bios__Category__c = 'Sponsorship', 
                                             rC_Bios__Subcategory__c = 'Contact Search',
                                             rC_Bios__Type__c = 'Community',
                                             rC_Bios__Status__c = 'Confirmed',
                                             Community__c = Com_Acc.Id);
        */lstPref.add(prefCOM);
        insert lstPref;
        
    }
} // END private class MultipleDonorsUpdateControllerTest {