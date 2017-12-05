/*
 * Class        : OpportunityServiceTest
 * Developer/Org: Jagjeet Singh
 * Created      : Mar 30, 2016
 * Objective    : Test class for Opportunity Service
 * Modified By                   Modified On                      Description
 * Ashu Gupta                   July 25,2016                    Implemented coding standards and increased coverage
 * Rohit B                      July 27, 2016                   Added two new methods to cover some functionalities
 * Ravi Chauhan                 Aug 17,2016                     Added assertions
 * Suminder Singh               Dec 26,2016                     Increased code coverage
 * Suminder Singh               Dec 26,2016                     Fixed for errors and code coverage
 * Suminder Singh               Jan 24,2017                     Fixed for errors and code coverage
 * Suminder Singh               Jan 25,2017                     Fixed for errors and code coverage
 * Suminder Singh               Feb 9,2017                      Fixed for errors and code coverage
 * Suminder Singh               Mar 23,2017                     Fixed for errors and code coverage
 * Suminder Singh               Mar 31,2017                     Fixed for errors and code coverage
*/ 
@isTest
private class OpportunityServiceTest {
    
    static Opportunity parentOpp, testOpp, testOpp1, testOpp2, testOpp3, testOpp4, oppNew, parentOppNew, opportunityNew, preferenceRecordOpp;
    static Contact con, con1, con_DA, participant, participant0, participant1, participant2, preferenceRecordContact;
    static Account acc, chAccount, acc1, national_Office_Acc, local_Part_Acc, communityAccount, updateOwner_LP_account, updateOwner_NO_account ;
    static Campaign testCamp,testCampNew;
    static rC_Giving__Payment_Method__c paymentMethod;
    static rC_Giving__GAU__c testGAU,testGAU2;
    static final string RT_OPP_TRANS = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    static final string RT_OPP_DONAT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    static final string RT_OPP_PPLAN = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Prospect Plan').getRecordTypeId();
    static final string RT_CON_HHOLD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    static final string RT_CON_PARTI = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    static final string RT_ACC_COMMU = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    static final string RT_ACC_LOCAL = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    static final string RT_ACC_NAOFF = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    static final string RT_ACC_HHOLD = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    static final string RT_ACC_CFUND = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
    static final string RT_PLG_BEQUE = Schema.SObjectType.rC_Giving__Planned_Giving__c.getRecordTypeInfosByName().get('Bequest').getRecordTypeId();
    static final string RT_PAYMT_EFT = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
    static final string SPONSORSHIP = 'Sponsorship';
    static final string CHILD_SPONSORSHIP = 'Child Sponsorship';
    static final string PHILANTHROPY = 'Philanthropy';
    static final string DESIGNATED_FUND = 'Designated Fund';
    static final string BELATED_CHRISTMAS = 'Belated Christmas';
    static final string AS_INSTRUCTED = 'As Instructed';
    static final string RECURRING_GIFT = 'Recurring Gift';
    static final string ONE_TIME_GIFT = 'One Time Gift';
    
    static void createAccounts() {
        rC_Giving__Contact_Setting__c Contact_Setting = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        Contact_Setting.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert Contact_Setting;
        
        List<Account> accList = new List<Account>();
        acc = TestUtils.createAccount('Test Account',false);
        acc.RecordTypeId = RT_ACC_HHOLD;
        accList.add(acc);

        acc1 = TestUtils.createAccount('Test Account',false);
        acc1.RecordTypeId = RT_ACC_CFUND;
        accList.add(acc1);
        
        national_Office_Acc = TestUtils.createAccountWithRT('Test NO Account', RT_ACC_NAOFF, null, '765', '9234', false);
        accList.add(national_Office_Acc);
        
        insert accList;
        
        local_Part_Acc = TestUtils.createAccountWithRT('Test LP Account', RT_ACC_LOCAL, national_Office_Acc, '904', '3467', false);
        local_Part_Acc.Local_Partner_ID__c = '1234567';
        insert local_Part_Acc;
        communityAccount = TestUtils.createAccountWithRT('Test Community Account', RT_ACC_COMMU, local_Part_Acc, '253', '5646', true);
        //hhAccount = TestUtils.createAccountWithRT('Test Household Account', RT_ACC_HHOLD, communityAccount, '565', '2134', true);
        
       
    }
    static void createParticipant() {
        List<Contact> listOfContacts = new List<Contact>();
        participant = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participant.RecordTypeId = RT_CON_PARTI;
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        participant.Correspondence_Paused__c = false;
        participant.Participant_Case_Number__c = '16485';
        participant.Participant_Number__c = '54321';
        //participant.National_Office__c = national_Office_Acc.Id;
        participant.Local_Partner__c = local_Part_Acc.id;
        listOfContacts.add(participant);

        participant0 = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participant0.RecordTypeId = RT_CON_PARTI;
        participant0.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant0.Correspondence_Paused__c = false;
        participant0.Participant_Case_Number__c = '14965';
        participant0.Participant_Number__c = '55001';
        participant0.National_Office__c = national_Office_Acc.Id;
        listOfContacts.add(participant0);

        insert listOfContacts;
    //    System.assertEquals([Select recordType.Name FROM Contact WHERE id  = :participant.Id LIMIT 1].recordType.Name,'test1');
    }
    static void createParticipant1() {
        rC_Giving__Contact_Setting__c Contact_Setting = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        Contact_Setting.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert Contact_Setting;

        acc = TestUtils.createAccount('My Unit test Acc', false);
        acc.RecordTypeId = RT_ACC_HHOLD;
        insert acc;

        chAccount = TestUtils.createAccountWithRT('Test Household Account', RT_ACC_CFUND, acc, '665', '3845', false);
        chAccount.Alliance__c  = true;
        insert chAccount;

        List<Contact> listOfContacts = new List<Contact>();
        con = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        con.RecordTypeId = RT_CON_HHOLD;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored';
        con.Correspondence_Paused__c = false;
        con.Participant_Case_Number__c = '15423';
        con.Participant_Number__c = '51941';
        con.BirthDate = System.today().addYears(20);
        //con.Donor_Flag__c = 'Black';
        listOfContacts.add(con);

        participant1 = TestUtils.createContact(acc, 'Unit test1', 'Apex1', false);
        participant1.RecordTypeId = RT_CON_PARTI;
        participant1.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant1.Correspondence_Paused__c = false;
        participant1.Participant_Case_Number__c = '18395';
        participant1.Accept_DF_Fee__c = true;
        participant1.Donor_Alliance__c = chAccount.Id;
        participant1.rC_Giving__Track_Hard_Credits__c = true;
        participant1.BirthDate = System.today().addYears(20);
        listOfContacts.add(participant1);
        

        participant2 = TestUtils.createContact(acc, 'Unit test2', 'Apex2', false);
        participant2.RecordTypeId = RT_CON_PARTI;
        participant2.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        participant2.Correspondence_Paused__c = false;
        participant2.Participant_Case_Number__c = '18395';
        participant2.Accept_DF_Fee__c = true;
        participant2.rC_Giving__Track_Hard_Credits__c = true;
        listOfContacts.add(participant2);

        insert listOfContacts;
    }
    static void createDonors() {
        List<Contact> listOfContacts = new List<Contact>();
        con = TestUtils.createContact(acc, 'Unit test 1', 'Apex 1', false);
        con.RecordTypeId = RT_CON_HHOLD;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.Correspondence_Paused__c = false;
        con.Participant_Case_Number__c = '14253';
        con.Participant_Number__c = '53241';
        con.Donor_Flag__c = 'Black';
        con.Flag_Comments__c = 'test comment';
        listOfContacts.add(con);

        //con1 = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        //con1.RecordTypeId = RT_CON_HHOLD;
        //con1.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        //con1.Correspondence_Paused__c = false;
        //con1.Participant_Case_Number__c = '12435';
        //con1.Participant_Number__c = '53241';
        //con1.rC_Giving__Track_Hard_Credits__c = true;
        //con1.Donor_Flag__c = 'Black';
        //con1.Flag_Comments__c = 'test comment';
        //listOfContacts.add(con1);

        con_DA = TestUtils.createContact(acc,'Test First Name','Test Last Name',false);
        con_DA.RecordTypeId = RT_CON_HHOLD;
        con_DA.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        con_DA.rC_Bios__Preferred_Phone__c = 'Home';
        con_DA.HomePhone = '020-2656768';
        con_DA.rC_Bios__Preferred_Email__c = 'Home';
        con_DA.rC_Bios__Home_Email__c = 'test@gmail.com';
        con_DA.Lifetime_Amount__c = 1000;
        con_DA.Last_Gift_Amount__c = 100;
        con_DA.Largest_Gift_Amount__c = 500;
        con_DA.Largest_Gift_Date__c = date.today();
        con_DA.rC_Giving__Track_Hard_Credits__c = true;
        con_DA.Accept_DF_Fee__c = true;
        con_DA.Donor_Alliance__c = acc1.Id;
        listOfContacts.add(con_DA);

        insert listOfContacts;
    }
    static void createGAU_SA() {
        testGAU = TestUtils.createGeneralAccountingUnit('testGAU', true);
        TestUtils.createGeneralAccountingUnit('600', true);
        Standard_Allocation__c testStaAll = TestUtils.createStandardAllocation('0001', testGAU.Id, true);

        Standard_Allocation__c standardAllocationInstance = TestUtils.createStandardAllocation('test',testGAU.id,false);  
        standardAllocationInstance.Credit__c = 20.00;
        insert standardAllocationInstance;
    }
    static void createPM() {
        rC_Connect__Payment_Method_Setting__c PM_Setting = rC_Connect__Payment_Method_Setting__c.getInstance();
        PM_Setting.rC_Connect__Disable_All__c = true;
        insert PM_Setting;
        
        paymentMethod = new rC_Giving__Payment_Method__c();
        paymentMethod.rC_Giving__Is_Active__c = true;
        paymentMethod.RecordTypeId = RT_PAYMT_EFT;
        paymentMethod.Name = 'testPaymentMethod';
        paymentMethod.rC_Giving__Contact__c = con.Id;
        paymentMethod.rC_Connect__Payment_Processor__c = 'Sage'; 
        paymentMethod.rC_Connect__Merchant_Name__c = 'testMerchantName';
        paymentMethod.rC_Giving__Payment_Type__c = 'EFT';
        paymentMethod.rC_Giving__Account__c = acc.Id;
        insert paymentMethod;
    }
    static void createCampaigns() {
        List<Campaign> lstCamp = new List<Campaign>();
        testCamp = TestUtils.createCampaign('test camp',false);
        testCamp.Product_Type__c = ONE_TIME_GIFT;
        testCamp.Product_Sub_Type__c = 'DFC Fee';
        testCamp.rC_Giving__GAU__c = testGAU.Id;
        lstCamp.add(testCamp);

        testCampNew = TestUtils.createCampaign('718 - DFC Fee',false);
        testCampNew.Product_Type__c = DESIGNATED_FUND;
        lstCamp.add(testCampNew);

        insert lstCamp;
    }
    static void createOpp() {
        List<Opportunity> lstOpp = new List<Opportunity>();
        oppNew = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        oppNew.recordTypeId  = RT_OPP_DONAT;
        oppNew.Participant__c = participant.Id;
        oppNew.CampaignId = testCamp.Id;
        oppNew.Product_Type__c = DESIGNATED_FUND;
        oppNew.Product_Sub_Type__c = AS_INSTRUCTED;
        oppNew.rC_Giving__Primary_Contact__c = con.Id;
        //oppNew.rC_Giving__Hard_Credit_Contact__c = con.Id;
        oppNew.rC_Sponsorship__Substitute_Contact__c = participant.Id;
        //oppNew.Auto_Assign_Participant__c = 'Request for Participant Change';
        //lstOppToInsert.add(oppNew);
        lstOpp.add(oppNew);

        insert lstOpp;
    }
    static void createPrefOpp() {
        con = TestUtils.createContact(acc, 'Unit test 1', 'Apex 1', false);
        con.RecordTypeId = RT_CON_HHOLD;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.Correspondence_Paused__c = false;
        con.Participant_Case_Number__c = '14253';
        con.Participant_Number__c = '53241';
        con.Donor_Alliance__c = chAccount.Id;
        insert con;

        preferenceRecordContact = TestUtils.createContact(acc, 'Preferrence Contact', 'Apex', false);
        preferenceRecordContact.RecordTypeId = RT_CON_HHOLD;
        preferenceRecordContact.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        preferenceRecordContact.Correspondence_Paused__c = false;
        preferenceRecordContact.Participant_Case_Number__c = '12635';
        preferenceRecordContact.Participant_Number__c = '57241';
        preferenceRecordContact.Donor_Alliance__c = chAccount.Id;
        insert preferenceRecordContact;

        preferenceRecordOpp = TestUtils.createOpportunity(acc, 'PreferenceOpportunity', 100, false);
        preferenceRecordOpp.recordTypeId  = RT_OPP_DONAT;
        preferenceRecordOpp.Participant__c = participant1.Id;
        preferenceRecordOpp.CampaignId = testCamp.Id;
        preferenceRecordOpp.rC_Giving__Is_Sustainer__c = true;
        preferenceRecordOpp.rC_Giving__Anniversary_Date__c = system.today();
        preferenceRecordOpp.Product_Type__c = SPONSORSHIP;
        preferenceRecordOpp.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        preferenceRecordOpp.rC_Giving__Primary_Contact__c = preferenceRecordContact.Id;
        preferenceRecordOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        preferenceRecordOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        preferenceRecordOpp.rC_Sponsorship__Sponsorship_Status_Reason__c = null;
        preferenceRecordOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        preferenceRecordOpp.Legacy_Type__c = '';
        preferenceRecordOpp.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        insert preferenceRecordOpp;
    }
    static void createTestOpp1() {
         FOC__c FOC_Setting = new FOC__c();
        FOC_Setting.Name = 'ITU1 ';
       // FOC_Setting.Description__c = 'Lockbox';
        //FOC_Setting.GAU_Id__c = testGAU.Id;
        insert FOC_Setting;
        
        
        
        parentOpp = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp.recordTypeId  = RT_OPP_DONAT;
        parentOpp.Participant__c = participant1.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.rC_Giving__Is_Sustainer__c = true;
        parentOpp.rC_Giving__Anniversary_Date__c = system.today();
        parentOpp.rC_Giving__Giving_Amount__c = 100;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.rC_Giving__GAU__c = testGAU.Id;
        parentOpp.Product_Type__c = DESIGNATED_FUND;
        parentOpp.Product_Sub_Type__c = AS_INSTRUCTED;
        parentOpp.rC_Sponsorship__Substitute_Contact__c = con.Id;
        parentOpp.rC_Giving__Primary_Contact__c = con.Id;
        parentOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp.Vendor_Name__c = 'Other';
        parentOpp.Start_Date__c = System.today().addMonths(-3);
        parentOpp.StageName = 'Proposal';
        parentOpp.Identified_for_Clawback__c = false;
        insert parentOpp;

        List<Opportunity> lstOpp = new List<Opportunity>();
        testOpp = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        testOpp.recordTypeId  = RT_OPP_DONAT;
        testOpp.Participant__c = participant2.Id;
        testOpp.CampaignId = testCamp.Id;
        testOpp.rC_Giving__Is_Sustainer__c = true;
        testOpp.rC_Giving__Anniversary_Date__c = system.today();
        testOpp.rC_Giving__Giving_Amount__c = 100;
        testOpp.Sponsorship_Status__c = 'Sponsored';
        testOpp.Cost_Extension__c = true;
        testOpp.rC_Giving__Parent__c = parentOpp.Id;
        testOpp.DFC_Status__c = 'test';
        testOpp.Product_Type__c = DESIGNATED_FUND;
        testOpp.Product_Sub_Type__c = AS_INSTRUCTED;
        testOpp.rC_Giving__Primary_Contact__c = con.Id;
        testOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        testOpp.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        lstOpp.add(testOpp);
        //insert testopp;
        
        testOpp1 = TestUtils.createOpportunity(acc,'testOpportunity1',1000,false);
        testOpp1.recordTypeId  = RT_OPP_DONAT;
        testOpp1.Participant__c = participant1.Id;
        testOpp1.CampaignId = testCamp.Id;
        testOpp1.rC_Giving__Giving_Amount__c = 1001;
        testOpp1.Cost_Extension__c = true;
        testOpp1.rC_Giving__Is_Sustainer__c = true;
        testOpp1.rC_Giving__Anniversary_Date__c = system.today();
        testOpp1.rC_Giving__Parent__c = parentOpp.Id;
        testOpp1.DFC_Status__c = 'test';
        testOpp1.Product_Type__c = SPONSORSHIP;
        testOpp1.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        testOpp1.rC_Giving__Primary_Contact__c = con.Id;
        testOpp1.rC_Giving__Hard_Credit_Contact__c = participant1.Id;
        testOpp1.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        testOpp1.Vendor_Name__c = 'Other';
        testOpp1.Start_Date__c = System.today().addMonths(-3);
        testOpp1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        testOpp1.StageName = 'Proposal';
        testOpp1.Identified_for_Clawback__c = false;
        testOpp1.DFC_Related_Opportunity__c = testOpp.Id;
        lstOpp.add(testOpp1);
        //insert testOpp1;

        testOpp2 = TestUtils.createOpportunity(acc, 'testOpportunity2', 100, false);
        testOpp2.recordTypeId  = RT_OPP_TRANS;
        testOpp2.Participant__c = participant2.Id;
        testOpp2.CampaignId = testCamp.Id;
        testOpp2.rC_Giving__Giving_Amount__c = 100;
        testOpp2.Cost_Extension__c = true;
        testOpp2.rC_Giving__Is_Sustainer__c = true;
        testOpp2.rC_Giving__Anniversary_Date__c = system.today();
        testOpp2.rC_Giving__Parent__c = parentOpp.Id;
        testOpp2.rC_Giving__GAU__c = testGAU.Id;
        testOpp2.Product_Type__c = DESIGNATED_FUND;
        testOpp2.Product_Sub_Type__c = AS_INSTRUCTED;
        testOpp2.rC_Giving__Hard_Credit_Contact__c = con.Id;
        lstOpp.add(testOpp2);
        //insert testOpp2;

        testOpp3 = TestUtils.createOpportunity(acc, 'testOpportunity3', 150, false);
        testOpp3.recordTypeId  = RT_OPP_TRANS;
        testOpp3.Participant__c = participant1.Id;
        testOpp3.CampaignId = testCamp.Id;
        testOpp3.rC_Giving__Giving_Amount__c = 120;
        testOpp3.rC_Giving__Parent__c = parentOpp.Id;
        testOpp3.Cost_Extension__c = true;
        testOpp3.rC_Giving__Is_Sustainer__c = true;
        testOpp3.rC_Giving__Anniversary_Date__c = system.today();
        //testOpp3.rC_Giving__GAU__c = testGAU.Id;
        testOpp3.Product_Type__c = DESIGNATED_FUND;
        testOpp3.Product_Sub_Type__c = BELATED_CHRISTMAS;
        testOpp3.rC_Giving__Primary_Contact__c = con.Id;
        testOpp3.rC_Giving__Hard_Credit_Contact__c = con.Id;
        testOpp3.Vendor_Name__c = 'Other';
        testOpp3.Start_Date__c = System.today().addMonths(-3);
        testOpp3.StageName = 'Proposal';
        testOpp3.Identified_for_Clawback__c = false;
        lstOpp.add(testOpp3);

        List<rC_Giving__GAU__c> gauList = [SELECT id FROM rC_Giving__GAU__c WHERE Name = '600'];
        Opportunity temp_testOpp = TestUtils.createOpportunity(acc, 'testOpportunity4', 100, false);
        temp_testOpp.recordTypeId  = RT_OPP_TRANS;
        temp_testOpp.Participant__c = participant1.Id;
        temp_testOpp.CampaignId = testCamp.Id;
        temp_testOpp.rC_Giving__Is_Sustainer__c = true;
        temp_testOpp.rC_Giving__Anniversary_Date__c = system.today();
        temp_testOpp.rC_Giving__Parent__c = parentOpp.Id;
        temp_testOpp.Cost_Extension__c = true;
        if(gauList.size()>0)
            temp_testOpp.rC_Giving__GAU__c = gauList[0].Id;
        temp_testOpp.Product_Type__c = DESIGNATED_FUND;
        temp_testOpp.Product_Sub_Type__c = BELATED_CHRISTMAS;
        temp_testOpp.rC_Giving__Primary_Contact__c = con.Id;
        temp_testOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        temp_testOpp.Vendor_Name__c = 'Other';
        temp_testOpp.Identified_for_Clawback__c = false;
        temp_testOpp.DFC_Status__c = 'Undeliverable - Over $100';
        lstOpp.add(temp_testOpp);
        insert lstOpp;
    }
    static void createTestOpp2() {
        rC_Giving__Contact_Setting__c Contact_Setting = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        Contact_Setting.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert Contact_Setting;

        parentOppNew = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        parentOppNew.recordTypeId  = RT_OPP_DONAT;
        parentOppNew.Participant__c = con.Id;
        parentOppNew.CampaignId = testCampNew.Id;
        parentOppNew.rC_Giving__Is_Sustainer__c = true;
        parentOppNew.rC_Giving__Anniversary_Date__c = system.today();
        parentOppNew.rC_Giving__Giving_Amount__c = 100;
        parentOppNew.DFC_Release_Month_Master__c = 3;
        parentOppNew.Product_Type__c = DESIGNATED_FUND;
        parentOppNew.Product_Sub_Type__c = AS_INSTRUCTED;
        parentOppNew.rC_Sponsorship__Substitute_Contact__c = con.Id;
        parentOppNew.rC_Giving__Hard_Credit_Contact__c = con.Id;
        insert parentOppNew;

        List<Opportunity> lstOpp = new List<Opportunity>();
        opportunityNew = TestUtils.createOpportunity(acc,'Test Opportunity',100,false);
        opportunityNew.RecordTypeId = RT_OPP_PPLAN;
        opportunityNew.StageName = 'Open';
        opportunityNew.rC_Giving__Projected_Amount__c = 100;
        opportunityNew.rC_Giving__Is_Sustainer__c = true;
        opportunityNew.rC_Giving__Anniversary_Date__c = system.today();
        opportunityNew.CloseDate = Date.Today().addMonths(2);
        opportunityNew.Prospect_Plan_type__c = RT_PLG_BEQUE;
        opportunityNew.Product_Type__c = SPONSORSHIP;
        opportunityNew.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opportunityNew.rC_Giving__Hard_Credit_Contact__c = con.Id;
        opportunityNew.Opportunity_Type__c = PHILANTHROPY;
        opportunityNew.Core_Program_Infants__c = true;
        opportunityNew.rC_Giving__Parent__c = parentOppNew.Id;
        opportunityNew.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        opportunityNew.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
        lstOpp.add(opportunityNew);

        testOpp = new Opportunity();
        testOpp.RecordTypeId = RT_OPP_TRANS;
        testOpp.AccountId = acc.Id;
        testOpp.Name = 'Test Opportunity';
        testOpp.StageName = 'Open';
        testOpp.rC_Giving__Is_Sustainer__c = true;
        testOpp.rC_Giving__Anniversary_Date__c = system.today();
        testOpp.rC_Giving__Projected_Amount__c = 100;
        testOpp.CloseDate = Date.Today();
        testOpp.Prospect_Plan_type__c = RT_PLG_BEQUE;
        testOpp.Product_Type__c = SPONSORSHIP;
        testOpp.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        testOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        testOpp.Opportunity_Type__c = PHILANTHROPY;
        testOpp.Core_Program_Infants__c = true;
        testOpp.campaignId = testCamp.Id;
        testOpp.rC_Giving__Parent__c = parentOppNew.Id;
        testOpp.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        testOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        testOpp.Amount = 500;
        testOpp.DFC_Status__c = 'Auto Fee';
        lstOpp.add(testOpp);

        insert lstOpp;
    }
    static void createMCS() {
        Mail_Control_Slip__c mcsData = TestUtils.createMailControlSlip('testDonorId', 'testLetterType','testStatus', participant2.id, 'test', false);
        mcsData.MCS_Status__c = 'Active';
        insert mcsData;
    }

    
    @isTest             //update Approval Path Exempt Test
    private static void updateApprovalPathExemptTest(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createTestOpp1();

        //start Test
        Test.startTest();
        
        //get the opportunity from Db.
        Opportunity oppDb = [select Id,Approval_Path_Exempt__c from Opportunity where Id = :testOpp.Id Limit 1];
        //asserts
        system.assertEquals(true, oppDb.Approval_Path_Exempt__c, 'Path exempt should be set to true');
        //stop Test
        Test.stopTest();
    }
    
    @isTest             //test method for Set Exhange Rate on related fundings.
    private static void setExchangeRateForRelatedFundingsTest(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createTestOpp1();

        //start Test
        Test.startTest();
            Project__c project = TestUtils.createProject('Test Proj', 'Brazil', 'Available', true);
            Funding__c funding = TestUtils.createFunding(project.Id, testOpp.Id, null, true);
        
            //get the opportunity from Db.
            Opportunity oppDb = [select Id,Approval_Path_Exempt__c from Opportunity where Id = :testOpp.Id Limit 1];
            oppDb.Exchange_Rate__c = 1000;
            update oppDB;
        //stop Test
        Test.stopTest();
    }
    
    @isTest             //test method for Set Exhange Rate on related fundings.
    private static void updatePaidThroughDateTest(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createTestOpp1();

        //start Test
        Test.startTest();
            //get the opportunity from Db.
            CheckRecursive checkRecursiveInstance = new CheckRecursive();
            CheckRecursive.runOpportunity = true;
            Opportunity oppDb = [select Id,Approval_Path_Exempt__c from Opportunity where Id = :testOpp.Id Limit 1];
            oppDb.Exchange_Rate__c = 1000;
            oppDb.rC_Giving__Giving_Frequency__c = 'Monthly';
            oppDb.rC_Giving__Giving_Amount__c = 100;
            oppDb.rC_Giving__Closed_Amount__c = 200;
            oppDb.Remainder_Last_Payment__c = 200;
            oppDb.Paid_Through_Date__c = System.today().addDays(-45);
            update oppDB;
        //stop Test
        Test.stopTest();
    }
    
    
    @isTest             //test method for updateParticipantsOnPaymentReceived on related fundings.
    private static void updateParticipantsOnPaymentReceivedTest(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createTestOpp1();

        //start Test
        Test.startTest();
            //get the opportunity from Db.
            Opportunity oppDb = [select Id,Approval_Path_Exempt__c,Sponsorship_Status__c,Participant__c from Opportunity where Id = :testOpp.Id Limit 1];
            oppDb.Sponsorship_Status__c = 'Reinstateable';
            update oppDB;
        
            //get the contact from DB
            Contact conDb = [select Id,rC_Sponsorship__Sponsorship_Status__c from Contact WHERE id = :oppDb.Participant__c LIMIT 1];
            system.assertEquals(conDb.rC_Sponsorship__Sponsorship_Status__c,oppDb.Sponsorship_Status__c );
        //stop Test
        Test.stopTest();
    }
    
    @isTest             //test for create GL Allocation functionality
    private static void create_GL_AllocationTest(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createTestOpp1();

        //start Test
        Test.startTest();
            CheckRecursive checkRecursiveInstance = new CheckRecursive();
            CheckRecursive.runOpportunity = true;
            testOpp2.StageName = 'Completed';
            update testOpp2;

            checkRecursiveInstance = new CheckRecursive();
            CheckRecursive.runOpportunity = true;
            testOpp3.rC_Giving__GAU__c = null;
            testOpp3.StageName = 'Completed';
            update testOpp3;
        //stop Test
        Test.stopTest();

    }

    @isTest             //test for setReleaseDateforDFCTransaction
    private static void setReleaseDateforDFCTransactionTest(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createTestOpp1();

        //start Test
        Test.startTest();
            //asserts
            Opportunity oppDB = [select Id,DFC_Status__c from Opportunity where Id = :testOpp.Id limit 1];
            system.assertEquals('Pending', oppDb.DFC_Status__c);
        //stop Test
        Test.stopTest();
    }
    
    @isTest             //test for cancelMCSFromOpp
    private static void cancelMCSFromOppTest(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createTestOpp1();
        createMCS();

        //start Test
        Test.startTest();
            //asserts
            Opportunity oppDB = [select Id, Participant__c, DFC_Status__c, Sponsorship_Status__c from Opportunity where Id = :testOpp.Id limit 1];
            oppDB.Sponsorship_Status__c = 'Closed';
            update oppDB;
        
            //asserts
            Mail_Control_Slip__c mcsDbData = [select Id, MCS_Status__c from Mail_Control_Slip__c WHERE Participant__c = :oppDB.Participant__c Limit 1];
            system.assertEquals('Cancel', mcsDbData.MCS_Status__c);
        //stop Test
        Test.stopTest();
    }
    
    @isTest 
    private static void createPreferenceRecordsForNewAssignmentsTest(){
        createParticipant1(); 
        createGAU_SA();
        createCampaigns();
        createPrefOpp();  
        
        Opportunity opport = [Select Id, rC_Giving__Primary_Contact__c ,rC_Giving__Primary_Contact__r.Alliance_Donor__c, rC_Giving__Primary_Contact__r.Donor_Alliance__c, Product_Type__c, Product_Sub_Type__c, Auto_Assign_Participant__c, Sponsorship_Change_Reason_Detail__c, isDFCCloned__c from Opportunity where Id = :preferenceRecordOpp.Id];
        chAccount.Alliance__c = true;
        update chAccount;
        Account accoun = [select Id , Alliance__c from Account where Id =:chAccount.Id];
        opport = [Select Id, rC_Giving__Primary_Contact__c ,rC_Giving__Primary_Contact__r.Alliance_Donor__c ,rC_Giving__Primary_Contact__r.Donor_Alliance__c, Product_Type__c, Product_Sub_Type__c, Auto_Assign_Participant__c, Sponsorship_Change_Reason_Detail__c, isDFCCloned__c from Opportunity where Id = :preferenceRecordOpp.Id];
        opport.Product_Type__c = SPONSORSHIP;
        opport.rC_Giving__Primary_Contact__r.Donor_Alliance__c = chAccount.Id;
        opport.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opport.Auto_Assign_Participant__c = 'Direct Sponsorship';
        //opport.Auto_Assign_Participant__c = 'New Assignment';
        opport.Legacy_Type__c = '';
        //update opport;
       // opport.Sponsorship_Change_Reason_Detail__c = 'Another';
        //opport.isDFCCloned__c = false;
        Test.startTest();
        
            update opport;
            CheckRecursive.run = true;
            CheckRecursive.runOpportunity = true;
            opport.Sponsorship_Change_Reason_Detail__c = 'Another';
            opport.isDFCCloned__c = false;
            update opport;
        
            //asserts
            List<rC_Bios__Preference__c> prefList = [select Id from rC_Bios__Preference__c where rC_Sponsorship__Opportunity__c =:opport.Id];
            //System.assert(prefList.size()>0);
        Test.stopTest();
    }
    
    //Vaibhav Goel : June 15,2016 Added Method 
    //test method for CIFPrintQueue
    @isTest             
    private static void CIFPrintQueueTest(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createPrefOpp();
        createPM();

        chAccount.Alliance__c  = true;
        update chAccount;
        
        con.Donor_Alliance__c = chAccount.Id;
        update con;
            
        Test.startTest();     
            CheckRecursive checkRecursiveInstance = new CheckRecursive();
            CheckRecursive.runOpportunity = true;
                   
            Opportunity opport = [Select Id, rC_Giving__Payment_Method_Selected__c, Participant__c, Sponsorship_Change_Reason_Detail__c, isDFCCloned__c, 
                                rC_Giving__Hard_Credit_Contact__c, rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__c, 
                                Participant_Reserve__c, Participant_Reserve__r.Alliance__c, rC_Giving__Primary_Contact__c, 
                                rC_Giving__Primary_Contact__r.Alliance_Donor__c, rC_Giving__Primary_Contact__r.Donor_Alliance__c, 
                                Product_Type__c, Product_Sub_Type__c, Auto_Assign_Participant__c, rC_Sponsorship__Sponsorship_Status_Reason__c, 
                                rC_Sponsorship__Do_Not_Substitute__c,CFI_Do_Not_Substitute__c,Do_Not_Sub_Reason__c
                                from Opportunity where Id = :preferenceRecordOpp.Id];
                                
            opport.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
            opport.rC_Giving__Hard_Credit_Contact__c = con.Id;
            opport.Product_Type__c = SPONSORSHIP;
            opport.Product_Sub_Type__c = CHILD_SPONSORSHIP;
            opport.Legacy_Type__c = '';
            //opport.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__c = chAccount.Id;
            opport.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Participant Change';
            opport.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
            opport.Sponsorship_Status_Reason_Copy__c = 'Participant Change';
            opport.CFI_Do_Not_Substitute__c = 'Do Not Substitute';
            opport.Do_Not_Sub_Reason__c = 'Alliance Request';
            update opport; 

            checkRecursiveInstance = new CheckRecursive();
            CheckRecursive.runOpportunity = true;

            opport.Auto_Assign_Participant__c = null;
            opport.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
            opport.Cancel_Sponsorship__c = 'Future Cancel';
            opport.rC_Sponsorship__Future_Cancellation_Date__c = System.today().addDays(30);
            opport.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
            opport.Sponsorship_Status_Reason_Copy__c = 'Sponsors Transfer';
            opport.CFI_Do_Not_Substitute__c = 'Do Not Substitute - Contact Donor';
            opport.Legacy_Type__c = '';
            update opport;
        Test.stopTest();
     }
    
    @isTest             //test for validateDonorFlag
    private static void testValidateDonorFlag(){
        createAccounts();
        createParticipant();
        createDonors();
        createGAU_SA();
        createCampaigns();
        
        Test.startTest();
            Opportunity oppNew1 = TestUtils.createOpportunity(acc, 'testOpportunity', 100, false);
            oppNew1.recordTypeId  = RT_OPP_DONAT;
            oppNew1.Participant__c = participant.Id;
            oppNew1.CampaignId = testCamp.Id;
            oppNew1.rC_Giving__Giving_Amount__c = 100;
            oppNew1.Product_Type__c = SPONSORSHIP;
            oppNew1.Product_Sub_Type__c = CHILD_SPONSORSHIP;
            oppNew1.rC_Giving__Primary_Contact__c = con.Id;
            oppNew1.rC_Giving__Hard_Credit_Contact__c = con.Id;
            oppNew1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
            try {
                insert oppNew1;
            } catch(Exception e) {}
            //System.assertEquals(sr.isSuccess(), false);
        //stop Test
        Test.stopTest();
    } // END private static testMethod void testValidateDonorFlag(){
    
   
    @isTest
    private static void createDFCTest(){
        Test.startTest();
            createAccounts();
            createParticipant();
            createDonors();
            createGAU_SA();
            createCampaigns();
            createPM();
            createTestOpp2();
        //stop Test
        Test.stopTest();
     } // END private static testMethod void createDFCTest(){
    
    @isTest
    private static void updateTheTransactionOppNameafterTest(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createTestOpp1();
        
        //start test
        Test.startTest();
            CheckRecursive.runOpportunity = true;
            parentOpp.Participant__c = participant2.Id;
            update parentOpp;
        //stop Test
        Test.stopTest();
    } // END private static testMethod void updateTheTransactionOppNameafterTest(){
     
    @isTest
    private static void updateSubstituteContRecordsTest(){
        createAccounts();
        createParticipant();
        createDonors();
        createGAU_SA();
        createCampaigns();

        //start test
        Test.startTest();
            Opportunity testParentOpp = TestUtils.createOpportunity(acc, 'testOpportunity', 100, false);
            testParentOpp.recordTypeId  = RT_OPP_DONAT;
            testParentOpp.Participant__c = participant.Id;
            testParentOpp.CampaignId = testCamp.Id;
            testParentOpp.rC_Giving__Giving_Amount__c = 100;
            testParentOpp.DFC_Release_Month_Master__c = 3;
            testParentOpp.Product_Type__c = DESIGNATED_FUND;
            testParentOpp.Product_Sub_Type__c = AS_INSTRUCTED;
            testParentOpp.rC_Sponsorship__Substitute_Contact__c = con.Id;
            testParentOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
            insert testParentOpp;

            CheckRecursive.runOpportunity = true;
            testParentOpp.Auto_Assign_Participant__c = 'Request for Participant Change';
            testParentOpp.Legacy_Type__c = '';
            try {
                update testParentOpp;
            } catch(Exception e) {}
        //stop Test
        Test.stopTest();
     } // END private static testMethod void updateSubstituteContRecordsTest(){
     
    @isTest             
    private static void updateOpportunityOwnerTest(){
        createAccounts();
        createParticipant();
        createDonors();
        createGAU_SA();
        createCampaigns();
        
        List<Opportunity> lstOppToInsert = new List<Opportunity>();
        List<Contact> lstContactToUpdate = new List<Contact>();
        Test.startTest();
            participant.Local_Partner__c = local_Part_Acc.Id;
            lstContactToUpdate.add(participant);

            participant0.National_Office__c = national_Office_Acc.Id;
            lstContactToUpdate.add(participant0);

            update lstContactToUpdate;

            Opportunity oppNew1 = TestUtils.createOpportunity(acc, 'testOpportunity', 100, false);
            oppNew1.recordTypeId  = RT_OPP_DONAT;
            oppNew1.Participant__c = participant.Id;
            oppNew1.CampaignId = testCamp.Id;
            oppNew1.rC_Giving__Giving_Amount__c = 100;
            oppNew1.Product_Type__c = DESIGNATED_FUND;
            oppNew1.Product_Sub_Type__c = AS_INSTRUCTED;
            oppNew1.rC_Giving__Primary_Contact__c = con.Id;
            oppNew1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
            lstOppToInsert.add(oppNew1);

            Opportunity oppNew2 = TestUtils.createOpportunity(acc, 'testOpportunity', 100, false);
            oppNew2.recordTypeId  = RT_OPP_DONAT;
            oppNew2.Participant__c = participant0.Id;
            oppNew2.CampaignId = testCamp.Id;
            oppNew2.rC_Giving__Giving_Amount__c = 100;
            oppNew2.Product_Type__c = DESIGNATED_FUND;
            oppNew2.Product_Sub_Type__c = AS_INSTRUCTED;
            oppNew2.rC_Giving__Primary_Contact__c = con.Id;
            oppNew2.rC_Sponsorship__Sponsorship_Status__c = 'Active';
            lstOppToInsert.add(oppNew2);

            insert lstOppToInsert;
            
            //System.assertEquals(sr.isSuccess(), false);
        //stop Test
        Test.stopTest();
    } // END private static testMethod void testValidateDonorFlag(){
   
    @isTest            
    private static void updateOpportunityOwneronUpdateTest(){
        createAccounts();
        createParticipant();
        createDonors();
        createGAU_SA();
        createCampaigns();
        
        List<Opportunity> lstOppToInsert = new List<Opportunity>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        List<Contact> lstContactToUpdate = new List<Contact>();
        Test.startTest();
            participant.Local_Partner__c = local_Part_Acc.Id;
            lstContactToUpdate.add(participant);

            participant0.National_Office__c = national_Office_Acc.Id;
            lstContactToUpdate.add(participant0);

            update lstContactToUpdate;

            Opportunity oppNew1 = TestUtils.createOpportunity(acc, 'testOpportunity', 100, false);
            oppNew1.recordTypeId  = RT_OPP_DONAT;
            oppNew1.Participant__c = participant.Id;
            oppNew1.CampaignId = testCamp.Id;
            oppNew1.rC_Giving__Giving_Amount__c = 100;
            oppNew1.Product_Type__c = DESIGNATED_FUND;
            oppNew1.Product_Sub_Type__c = AS_INSTRUCTED;
            oppNew1.rC_Giving__Primary_Contact__c = con.Id;
            oppNew1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
            lstOppToInsert.add(oppNew1);

            Opportunity oppNew2 = TestUtils.createOpportunity(acc, 'testOpportunity', 100, false);
            oppNew2.recordTypeId  = RT_OPP_DONAT;
            oppNew2.Participant__c = participant0.Id;
            oppNew2.CampaignId = testCamp.Id;
            oppNew2.rC_Giving__Giving_Amount__c = 100;
            oppNew2.Product_Type__c = DESIGNATED_FUND;
            oppNew2.Product_Sub_Type__c = AS_INSTRUCTED;
            oppNew2.rC_Giving__Primary_Contact__c = con.Id;
            oppNew2.rC_Sponsorship__Sponsorship_Status__c = 'Active';
            lstOppToInsert.add(oppNew2);

            insert lstOppToInsert;
            
            
            for(Opportunity opp : [SELECT Participant__c FROM Opportunity where id = : oppNew1.Id]){
                opp.Participant__c = participant0.Id;
                lstOppToUpdate.add(opp);
            }
            
            update lstOppToUpdate;
            
            //System.assertEquals(sr.isSuccess(), false);
        //stop Test
        Test.stopTest();
    }
     
    @isTest
    private static void createNewDFCforDepartedChildTest() {
        createParticipant1(); 
        createGAU_SA();
        createCampaigns();
        createPrefOpp();
        
        Opportunity newTestOpp1 = TestUtils.createOpportunity(acc, 'PreferenceOpportunity', 100, false);
        newTestOpp1.recordTypeId  = RT_OPP_DONAT;
        newTestOpp1.Participant__c = participant1.Id;
        newTestOpp1.CampaignId = testCamp.Id;
        newTestOpp1.Product_Type__c = SPONSORSHIP;
        newTestOpp1.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        newTestOpp1.rC_Giving__Primary_Contact__c = preferenceRecordContact.Id;
        newTestOpp1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        newTestOpp1.rC_Giving__Hard_Credit_Contact__c = con.Id;
        //newTestOpp1.rC_Sponsorship__Sponsorship_Status_Reason__c = null;
        newTestOpp1.Auto_Assign_Participant__c = 'Direct Sponsorship';
        newTestOpp1.Legacy_Type__c = '';
        newTestOpp1.rC_Giving__Is_Sustainer__c = true;
        newTestOpp1.rC_Giving__Anniversary_Date__c = system.today();
        newTestOpp1.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        newTestOpp1.DFC_Related_Opportunity__c = preferenceRecordOpp.Id;
        insert newTestOpp1;
        
        Test.startTest();
            CheckRecursive checkRecursiveInstance = new CheckRecursive();
            CheckRecursive.runOpportunity = true;
            newTestOpp1.Sponsorship_Change_Reason_Detail__c = 'Another';
            newTestOpp1.isDFCCloned__c = false;
            newTestOpp1.Start_Date__c = System.today().addDays(-1);
            newTestOpp1.Paid_Through_Date__c = System.today().addDays(-1);
            newTestOpp1.Product_Sub_Type__c = 'Birthday';
            update newTestOpp1;

            Opportunity opport = [Select Id, rC_Giving__Primary_Contact__c, rC_Giving__Primary_Contact__r.Alliance_Donor__c, rC_Giving__Primary_Contact__r.Donor_Alliance__c, Product_Type__c, Product_Sub_Type__c, Auto_Assign_Participant__c, Sponsorship_Change_Reason_Detail__c, isDFCCloned__c from Opportunity where Id = :preferenceRecordOpp.Id];
            CheckRecursive.run = true;
            CheckRecursive.runOpportunity = true;
            opport.Sponsorship_Change_Reason_Detail__c = 'Another';
            opport.isDFCCloned__c = false;
            opport.DFC_Related_Opportunity__c = newTestOpp1.Id;
            opport.Start_Date__c = System.today().addDays(-1);
            opport.Paid_Through_Date__c = System.today().addDays(-1);
            opport.Product_Sub_Type__c = 'Birthday';
            update opport;
        Test.stopTest();
    }
    
    @isTest
    private static void markOpportunityForClawBackTest() {
        createAccounts();
        createParticipant();
        createDonors();
        createGAU_SA();
        createCampaigns();
        createPM();
        
        con = TestUtils.createContact(acc, 'Unit test 1', 'Apex 1', false);
        con.RecordTypeId = RT_CON_HHOLD;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.Correspondence_Paused__c = false;
        con.Participant_Case_Number__c = '14253';
        con.Participant_Number__c = '53241';
        con.Flag_Comments__c = 'test comment';
        insert con;
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        Opportunity pOpp = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        pOpp.recordTypeId  = RT_OPP_DONAT;
        pOpp.Participant__c = participant.Id;
        pOpp.CampaignId = testCamp.Id;
        pOpp.rC_Giving__Primary_Contact__c = con.Id;
        pOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        pOpp.rC_Giving__Giving_Amount__c = 100;
        pOpp.DFC_Release_Month_Master__c = 3;
        pOpp.rC_Giving__GAU__c = testGAU.Id;
        pOpp.Product_Type__c = SPONSORSHIP;
        pOpp.rC_Giving__Is_Sustainer__c = true;
        pOpp.rC_Giving__Anniversary_Date__c = system.today();
        pOpp.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        pOpp.Vendor_Name__c = 'Other';
        pOpp.Start_Date__c = System.today().addMonths(-5);
        pOpp.Date_Presponsorship_Started__c = System.today().addMonths(-2);
        pOpp.StageName = 'Proposal';
        pOpp.Identified_for_Clawback__c = false;
        insert pOpp;
        
        Opportunity pOpp1 = TestUtils.createOpportunity(acc, 'parentOpportunity', 110, false);
        pOpp1.recordTypeId  = RT_OPP_DONAT;
        pOpp1.Participant__c = participant.Id;
        pOpp1.CampaignId = testCamp.Id;
        pOpp1.rC_Giving__Primary_Contact__c = con.Id;
        pOpp1.rC_Giving__Hard_Credit_Contact__c = con.Id;
        pOpp1.rC_Giving__Giving_Amount__c = 110;
        pOpp1.DFC_Release_Month_Master__c = 3;
        pOpp1.rC_Giving__GAU__c = testGAU.Id;
        pOpp1.Product_Type__c = RECURRING_GIFT;
        pOpp1.Product_Sub_Type__c = 'CGN';
        pOpp1.Vendor_Name__c = 'Other';
        pOpp1.Start_Date__c = System.today().addMonths(-5);
        pOpp1.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        pOpp1.StageName = 'Proposal';
        pOpp1.Identified_for_Clawback__c = false;
        insert pOpp1;
        
        CheckRecursive checkRecursiveInstance = new CheckRecursive();
        CheckRecursive.runOpportunity = true;
        
        Opportunity dOpp = TestUtils.createOpportunity(acc, 'testOpportunity1', 100, false);
        dOpp.recordTypeId  = RT_OPP_DONAT;
        dOpp.CampaignId = testCamp.Id;
        dOpp.rC_Giving__Giving_Amount__c = 1001;
        dOpp.rC_Giving__Parent__c = pOpp.Id;
        dOpp.Product_Type__c = SPONSORSHIP;
        dOpp.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        dOpp.rC_Sponsorship__Sponsorship_Status__c = 'Closed';
        dOpp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
        dOpp.Vendor_Name__c = 'Other';
        dOpp.Cancelled_Date__c = System.today();
        dOpp.Start_Date__c = System.today().addMonths(-5);
        dOpp.rC_Giving__Is_Sustainer__c = true;
        dOpp.rC_Giving__Anniversary_Date__c = system.today();
        dOpp.Date_Presponsorship_Started__c = System.today().addMonths(-1);
        dOpp.StageName = 'Partially Collected';
        dOpp.Identified_for_Clawback__c = false;
        dOpp.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
        //lstOpp.add(testOpp);
        insert dOpp;
       
       // System.debug('hiiiclawback'+ dOpp.Identified_for_Clawback__c);
        //  system.debug('dateeclawback'+dOpp.Start_Date__c);
        //System.assertEquals(true, dOpp.Identified_for_Clawback__c);
        
        checkRecursiveInstance = new CheckRecursive();
        CheckRecursive.runOpportunity = true;
        
        Opportunity dOpp1 = TestUtils.createOpportunity(acc, 'testOpportunity2', 101, false);
        dOpp1.recordTypeId  = RT_OPP_DONAT;
        dOpp1.CampaignId = testCamp.Id;
        dOpp1.rC_Giving__Giving_Amount__c = 1001;
        dOpp1.rC_Giving__Parent__c = pOpp.Id;
        dOpp1.Product_Type__c = RECURRING_GIFT;
        dOpp1.Product_Sub_Type__c = 'CGN';
        dOpp1.rC_Sponsorship__Sponsorship_Status__c = 'Closed';
        dOpp1.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
        dOpp1.Vendor_Name__c = 'Other';
        dOpp1.Cancelled_Date__c = System.today();
        dOpp1.Start_Date__c = System.today().addMonths(-5);
        dOpp1.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        dOpp1.StageName = 'Partially Collected';
        dOpp1.Identified_for_Clawback__c = false;
        dOpp1.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
        //lstOpp.add(testOpp);
        insert dOpp1;
        //System.assertEquals(true, dOpp1.Identified_for_Clawback__c);
        
        checkRecursiveInstance = new CheckRecursive();
        CheckRecursive.runOpportunity = true;

        Test.StartTest();
            Opportunity tOpp1 = TestUtils.createOpportunity(acc, 'testOpportunity2', 150, false);
            tOpp1.recordTypeId  = RT_OPP_TRANS;
            tOpp1.Participant__c = participant.Id;
            tOpp1.CampaignId = testCamp.Id;
            tOpp1.rC_Giving__Giving_Amount__c = 120;
            tOpp1.rC_Giving__Parent__c = pOpp.Id;
            tOpp1.rC_Giving__Hard_Credit_Contact__c = con.Id;
            tOpp1.Product_Type__c = SPONSORSHIP;
            tOpp1.Product_Sub_Type__c = CHILD_SPONSORSHIP;
            tOpp1.Legacy_Type__c = '';
            tOpp1.Vendor_Name__c = 'Other';
            tOpp1.Start_Date__c = System.today().addMonths(-5);
            tOpp1.Date_Presponsorship_Started__c = System.today().addMonths(-5);
            tOpp1.StageName = 'Partially Collected';
            tOpp1.Identified_for_Clawback__c = false;
            //lstOpp.add(testOpp1);
            insert tOpp1;
            //insert lstOpp;

            checkRecursiveInstance = new CheckRecursive();
            CheckRecursive.runOpportunity = true;

            Opportunity tOpp2 = TestUtils.createOpportunity(acc, 'testOpportunity2', 151, false);
            tOpp2.recordTypeId  = RT_OPP_TRANS;
            tOpp2.Participant__c = participant.Id;
            tOpp2.CampaignId = testCamp.Id;
            tOpp2.rC_Giving__Giving_Amount__c = 120;
            tOpp2.rC_Giving__Parent__c = pOpp1.Id;
            tOpp2.rC_Giving__Hard_Credit_Contact__c = con.Id;
            tOpp2.Product_Type__c = RECURRING_GIFT;
            tOpp2.Product_Sub_Type__c = 'CGN';
            tOpp2.Legacy_Type__c = '';
            tOpp2.Vendor_Name__c = 'Other';
            tOpp2.Start_Date__c = System.today().addMonths(-5);
            tOpp2.Date_Presponsorship_Started__c = System.today().addMonths(-5);
            tOpp2.StageName = 'Partially Collected';
            tOpp2.Identified_for_Clawback__c = false;
            //lstOpp.add(testOpp1);
            insert tOpp2;
            //System.assertEquals(true, tOpp2.rC_Giving__Parent__r.Identified_for_Clawback__c);
            
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            for(Opportunity opp : [SELECT Id, rC_Giving__Parent__c, rC_Giving__Parent__r.Identified_for_Clawback__c FROM Opportunity
                                WHERE Id in (:dOpp.Id, :dOpp1.Id)]) {
                //opp.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
                opp.rC_Giving__Payment_Method_Selected__c = null;
                opp.Identified_for_Clawback__c = false;
                lstOppToUpdate.add(opp);
            }
            
            checkRecursiveInstance = new CheckRecursive();
            CheckRecursive.runOpportunity = true;
            update lstOppToUpdate; 
        Test.StopTest();
        //System.assertEquals(true, dOpp.Identified_for_Clawback__c);
    }
    
    @isTest
    private static void CIFPrintQueueNewTest1() {
        createAccounts();
        createParticipant();
        createGAU_SA();
        createCampaigns();
        
        Account chAccount1 = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount1.Alliance__c  = true;
        insert chAccount1;

        con = TestUtils.createContact(acc, 'Unit test 1', 'Apex 1', false);
        con.RecordTypeId = RT_CON_HHOLD;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.Correspondence_Paused__c = false;
        con.Participant_Case_Number__c = '14253';
        con.Participant_Number__c = '53241';
        con.Flag_Comments__c = 'test comment';
        con.Donor_Alliance__c = chAccount1.Id;
        insert con;
        
        Opportunity dOpp2 = TestUtils.createOpportunity(acc, 'testOpportunity2', 101, false);
        dOpp2.recordTypeId  = RT_OPP_DONAT;
        dOpp2.Participant__c = participant.Id;
        dOpp2.rC_Giving__Hard_Credit_Contact__c = con.Id;
        dOpp2.CampaignId = testCamp.Id;        
        dOpp2.rC_Giving__Is_Sustainer__c = true;
        dOpp2.rC_Giving__Anniversary_Date__c = system.today();
        dOpp2.rC_Giving__Giving_Amount__c = 1001;
        dOpp2.Product_Type__c = SPONSORSHIP;
        dOpp2.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        dOpp2.Vendor_Name__c = 'Other';
        dOpp2.Cancelled_Date__c = System.today();
        dOpp2.Start_Date__c = System.today().addMonths(-5);
        dOpp2.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        dOpp2.StageName = 'Open';
        dOpp2.rC_Sponsorship__Opportunity_Group_Id__c = 2356;
        dOpp2.Identified_for_Clawback__c = false;
        dOpp2.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
        insert dOpp2;
        
        Opportunity opp = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Legacy_Type__c,
                               rC_Sponsorship__Sponsorship_Status_Reason__c,Cancel_Sponsorship__c,Paid_Through_Date__c
                               FROM Opportunity
                               WHERE Id = :dOpp2.Id];
            opp.Legacy_Type__c = '';
            opp.rC_Sponsorship__Sponsorship_Status__c = 'Closed';
            opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
            opp.Cancel_Sponsorship__c = 'Cancel - Reinstateable' ;
            opp.Paid_Through_Date__c = System.today().addDays(-10);
            update opp;
            
    }
    
    @isTest
    private static void CIFPrintQueueNewTest2() {
        createAccounts();
        createParticipant();
        createGAU_SA();
        createCampaigns();
        
        Account chAccount1 = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount1.Alliance__c  = true;
        insert chAccount1;
        
        con = TestUtils.createContact(acc, 'Unit test 1', 'Apex 1', false);
        con.RecordTypeId = RT_CON_HHOLD;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.Correspondence_Paused__c = false;
        con.Participant_Case_Number__c = '14253';
        con.Participant_Number__c = '53241';
        con.Flag_Comments__c = 'test comment';
        con.Donor_Alliance__c = chAccount1.Id;
        insert con;
        
        Opportunity dOpp3 = TestUtils.createOpportunity(acc, 'testOpportunity2', 101, false);
        dOpp3.recordTypeId  = RT_OPP_DONAT;
        dOpp3.Participant__c = participant.Id;
        dOpp3.rC_Giving__Hard_Credit_Contact__c = con.Id;
        dOpp3.CampaignId = testCamp.Id;
        dOpp3.rC_Giving__Giving_Amount__c = 1001;
        dOpp3.Product_Type__c = SPONSORSHIP;
        dOpp3.rC_Giving__Is_Sustainer__c = true;
        dOpp3.rC_Giving__Anniversary_Date__c = system.today();
        dOpp3.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        dOpp3.Vendor_Name__c = 'Other';
        dOpp3.Cancelled_Date__c = System.today();
        dOpp3.Start_Date__c = System.today().addMonths(-5);
        dOpp3.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        dOpp3.StageName = 'Open';
        dOpp3.rC_Sponsorship__Opportunity_Group_Id__c = 2356;
        dOpp3.Identified_for_Clawback__c = false;
        //dOpp1.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
        dOpp3.Sponsorship_Status_Reason_Copy__c = 'Participant Change';
        insert dOpp3;
        
        Opportunity opp = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Legacy_Type__c,
                               rC_Sponsorship__Sponsorship_Status_Reason__c,Cancel_Sponsorship__c,Paid_Through_Date__c
                               FROM Opportunity
                               WHERE Id = :dOpp3.Id];
            opp.Legacy_Type__c = '';
            opp.rC_Sponsorship__Sponsorship_Status__c = 'Closed';
            opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
            opp.Cancel_Sponsorship__c = 'Cancel - Reinstateable' ;
            opp.Paid_Through_Date__c = System.today().addDays(-10);
            update opp;
            
    }
    
     @isTest
    private static void CIFPrintQueueNewTest3() {
        createAccounts();
        createParticipant();
        createGAU_SA();
        createCampaigns();
        
        Account chAccount1 = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount1.Alliance__c  = true;
        insert chAccount1;

        Contact con2 = TestUtils.createContact(acc, 'Unit test 2', 'Apex 2', false);
        con2.RecordTypeId = RT_CON_HHOLD;
        con2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con2.Correspondence_Paused__c = false;
        con2.Participant_Case_Number__c = '14233';
        con2.Participant_Number__c = '53223';
        con2.Flag_Comments__c = 'test comment';
        insert con2;
        
     Opportunity dOpp4 = TestUtils.createOpportunity(acc, 'testOpportunity2', 101, false);
        dOpp4.recordTypeId  = RT_OPP_DONAT;
        dOpp4.Participant__c = participant.Id;
        dOpp4.rC_Giving__Hard_Credit_Contact__c = con2.Id;
        dOpp4.CampaignId = testCamp.Id;
        dOpp4.rC_Giving__Giving_Amount__c = 1001;
        dOpp4.Product_Type__c = SPONSORSHIP;
        dOpp4.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        dOpp4.Vendor_Name__c = 'Other';        
        dOpp4.rC_Giving__Is_Sustainer__c = true;
        dOpp4.rC_Giving__Anniversary_Date__c = system.today();
        dOpp4.Cancelled_Date__c = System.today();
        dOpp4.Start_Date__c = System.today().addMonths(-5);
        dOpp4.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        dOpp4.StageName = 'Open';
        dOpp4.rC_Sponsorship__Opportunity_Group_Id__c = 2356;
        dOpp4.Identified_for_Clawback__c = false;
        dOpp4.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
        dOpp4.Sponsorship_Status_Reason_Copy__c = 'Participant Change';
        insert dOpp4;
        
        Opportunity opp = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Legacy_Type__c,
                               rC_Sponsorship__Sponsorship_Status_Reason__c,Cancel_Sponsorship__c,Paid_Through_Date__c
                               FROM Opportunity
                               WHERE Id = :dOpp4.Id];
            opp.Legacy_Type__c = '';
            opp.rC_Sponsorship__Sponsorship_Status__c = 'Closed';
            opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
            opp.Cancel_Sponsorship__c = 'Cancel - Reinstateable' ;
            opp.Paid_Through_Date__c = System.today().addDays(-10);
            update opp;
            
    }
    
    @isTest
    private static void CIFPrintQueueNewTest4() {
        createAccounts();
        createParticipant();
        createGAU_SA();
        createCampaigns();
        
        Account chAccount1 = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount1.Alliance__c  = true;
        insert chAccount1;

        Contact con2 = TestUtils.createContact(acc, 'Unit test 2', 'Apex 2', false);
        con2.RecordTypeId = RT_CON_HHOLD;
        con2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con2.Correspondence_Paused__c = false;
        con2.Participant_Case_Number__c = '14233';
        con2.Participant_Number__c = '53223';
        con2.Flag_Comments__c = 'test comment';
        insert con2;
        
     Opportunity dOpp4 = TestUtils.createOpportunity(acc, 'testOpportunity2', 101, false);
        dOpp4.recordTypeId  = RT_OPP_DONAT;
        dOpp4.Participant__c = participant.Id;
        dOpp4.rC_Giving__Hard_Credit_Contact__c = con2.Id;
        dOpp4.CampaignId = testCamp.Id;
        dOpp4.rC_Giving__Giving_Amount__c = 1001;
        dOpp4.Product_Type__c = SPONSORSHIP;
        dOpp4.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        dOpp4.Vendor_Name__c = 'Other';
        dOpp4.Cancelled_Date__c = System.today();
        dOpp4.Start_Date__c = System.today().addMonths(-5);
        dOpp4.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        dOpp4.StageName = 'Open';
        dOpp4.rC_Giving__Is_Sustainer__c = true;
        dOpp4.rC_Giving__Anniversary_Date__c = system.today();
        dOpp4.rC_Sponsorship__Opportunity_Group_Id__c = 2356;
        dOpp4.Identified_for_Clawback__c = false;
        dOpp4.Sponsorship_Change_Reason_Detail__c = 'New1';
        dOpp4.Sponsorship_Status_Reason_Copy__c = 'Participant Change';
        insert dOpp4;
        
        Opportunity opp = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Legacy_Type__c,
                               rC_Sponsorship__Sponsorship_Status_Reason__c,Cancel_Sponsorship__c,Paid_Through_Date__c
                               FROM Opportunity
                               WHERE Id = :dOpp4.Id];
            opp.Legacy_Type__c = '';
            opp.rC_Sponsorship__Sponsorship_Status__c = 'Closed';
            opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
            opp.Cancel_Sponsorship__c = 'Cancel - Reinstateable' ;
            opp.Paid_Through_Date__c = System.today().addDays(-10);
            update opp;
            
    }
    
     @isTest
    private static void CIFPrintQueueNewTest5() {
        createAccounts();
        createParticipant();
        createGAU_SA();
        createCampaigns();
        
        Account chAccount1 = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount1.Alliance__c  = true;
        insert chAccount1;

        Contact con2 = TestUtils.createContact(acc, 'Unit test 2', 'Apex 2', false);
        con2.RecordTypeId = RT_CON_HHOLD;
        con2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con2.Correspondence_Paused__c = false;
        con2.Participant_Case_Number__c = '14233';
        con2.Participant_Number__c = '53223';
        con2.Flag_Comments__c = 'test comment';
        insert con2;
        
     Opportunity dOpp4 = TestUtils.createOpportunity(acc, 'testOpportunity2', 101, false);
        dOpp4.recordTypeId  = RT_OPP_DONAT;
        dOpp4.Participant__c = participant.Id;
        dOpp4.rC_Giving__Hard_Credit_Contact__c = con2.Id;
        dOpp4.CampaignId = testCamp.Id;
        dOpp4.rC_Giving__Giving_Amount__c = 1001;
        dOpp4.Product_Type__c = SPONSORSHIP;
        dOpp4.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        dOpp4.Vendor_Name__c = 'Other';
        dOpp4.Cancelled_Date__c = System.today();
        dOpp4.Start_Date__c = System.today().addMonths(-5);
        dOpp4.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        dOpp4.StageName = 'Open';
        dOpp4.rC_Giving__Is_Sustainer__c = true;
        dOpp4.rC_Giving__Anniversary_Date__c = system.today();
        dOpp4.rC_Sponsorship__Opportunity_Group_Id__c = 2356;
        dOpp4.Identified_for_Clawback__c = false;
        dOpp4.Sponsorship_Change_Reason_Detail__c = 'New1';
        dOpp4.Sponsorship_Status_Reason_Copy__c = 'Sponsors Transfer';
        insert dOpp4;
        
        Opportunity opp = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Legacy_Type__c,
                               rC_Sponsorship__Sponsorship_Status_Reason__c,Cancel_Sponsorship__c,Paid_Through_Date__c
                               FROM Opportunity
                               WHERE Id = :dOpp4.Id];
            opp.Legacy_Type__c = '';
            opp.rC_Sponsorship__Sponsorship_Status__c = 'Closed';
            opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
            opp.Cancel_Sponsorship__c = 'Cancel - Reinstateable' ;
            opp.Paid_Through_Date__c = System.today().addDays(-10);
            update opp;
            
    }
    
         @isTest
    private static void CIFPrintQueueNewTest6() {
        createAccounts();
        createParticipant();
        createGAU_SA();
        createCampaigns();
        
        Account chAccount1 = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount1.Alliance__c  = true;
        insert chAccount1;

        Contact con2 = TestUtils.createContact(acc, 'Unit test 2', 'Apex 2', false);
        con2.RecordTypeId = RT_CON_HHOLD;
        con2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con2.Correspondence_Paused__c = false;
        con2.Participant_Case_Number__c = '14233';
        con2.Participant_Number__c = '53223';
        con2.Flag_Comments__c = 'test comment';
        con2.Active_Sponsorships__c = 20;
        insert con2;
        
     Opportunity dOpp4 = TestUtils.createOpportunity(acc, 'testOpportunity2', 101, false);
        dOpp4.recordTypeId  = RT_OPP_DONAT;
        dOpp4.Participant__c = participant.Id;
        dOpp4.rC_Giving__Hard_Credit_Contact__c = con2.Id;
        dOpp4.CampaignId = testCamp.Id;
        dOpp4.rC_Giving__Giving_Amount__c = 1001;
        dOpp4.Product_Type__c = SPONSORSHIP;
        dOpp4.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        dOpp4.Vendor_Name__c = 'Other';
        dOpp4.rC_Giving__Is_Sustainer__c = true;
        dOpp4.rC_Giving__Anniversary_Date__c = system.today();
        dOpp4.Cancelled_Date__c = System.today();
        dOpp4.Start_Date__c = System.today().addMonths(-5);
        dOpp4.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        dOpp4.StageName = 'Open';
        dOpp4.rC_Sponsorship__Opportunity_Group_Id__c = 2356;
        dOpp4.rC_Giving__Primary_Contact__c = con2.Id;
        dOpp4.Identified_for_Clawback__c = false;
        dOpp4.Sponsorship_Change_Reason_Detail__c = 'New1';
        insert dOpp4;
        
        Opportunity opp = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Legacy_Type__c,
                               rC_Sponsorship__Sponsorship_Status_Reason__c,Cancel_Sponsorship__c,Paid_Through_Date__c
                               FROM Opportunity
                               WHERE Id = :dOpp4.Id];
            opp.Legacy_Type__c = 'no';
            update opp; 
            
    }
    
        @isTest
    private static void CIFPrintQueueNewTest8() {
        createAccounts();
        createParticipant();
        createGAU_SA();
        createCampaigns();
        
        Account chAccount1 = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount1.Alliance__c  = true;
        insert chAccount1;

        Contact con2 = TestUtils.createContact(acc, 'Unit test 2', 'Apex 2', false);
        con2.RecordTypeId = RT_CON_HHOLD;
        con2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con2.Correspondence_Paused__c = false;
        con2.Participant_Case_Number__c = '14233';
        con2.Participant_Number__c = '53223';
        con2.Flag_Comments__c = 'test comment';
        insert con2;
        
     Opportunity dOpp4 = TestUtils.createOpportunity(acc, 'testOpportunity2', 101, false);
        dOpp4.recordTypeId  = RT_OPP_DONAT;
        dOpp4.Participant__c = participant.Id;
        dOpp4.rC_Giving__Hard_Credit_Contact__c = con2.Id;
        dOpp4.CampaignId = testCamp.Id;
        dOpp4.rC_Giving__Giving_Amount__c = 1001;
        dOpp4.Product_Type__c = SPONSORSHIP;
        dOpp4.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        dOpp4.Vendor_Name__c = 'Other';
        dOpp4.Cancelled_Date__c = System.today();
        dOpp4.Start_Date__c = System.today().addMonths(-5);
        dOpp4.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        dOpp4.StageName = 'Open';
        dOpp4.rC_Giving__Is_Sustainer__c = true;
        dOpp4.rC_Giving__Anniversary_Date__c = system.today();
        dOpp4.rC_Sponsorship__Opportunity_Group_Id__c = 2356;
        dOpp4.rC_Giving__Primary_Contact__c = con2.Id;
        dOpp4.Identified_for_Clawback__c = false;
        dOpp4.Sponsorship_Change_Reason_Detail__c = 'New1';
        insert dOpp4;
        
        Opportunity opp = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Legacy_Type__c,
                               rC_Sponsorship__Sponsorship_Status_Reason__c,Cancel_Sponsorship__c,Paid_Through_Date__c
                               FROM Opportunity
                               WHERE Id = :dOpp4.Id];
            opp.Legacy_Type__c = 'no';
            update opp; 
            
    }
    
    
        
    
    @isTest
    private static void CIFPrintQueueNewTest9() {
        createAccounts();
        createParticipant();
        createGAU_SA();
        createCampaigns();
        
        Account chAccount1 = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount1.Alliance__c  = true;
        insert chAccount1;

        con = TestUtils.createContact(acc, 'Unit test 1', 'Apex 1', false);
        con.RecordTypeId = RT_CON_HHOLD;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.Correspondence_Paused__c = false;
        con.Participant_Case_Number__c = '14253';
        con.Participant_Number__c = '53241';
        con.Flag_Comments__c = 'test comment';
        con.Donor_Alliance__c = chAccount1.Id;
        insert con;
        

        Opportunity dOpp1 = TestUtils.createOpportunity(acc, 'testOpportunity2', 101, false);
        dOpp1.recordTypeId  = RT_OPP_DONAT;
        dOpp1.Participant__c = participant.Id;
        dOpp1.rC_Giving__Hard_Credit_Contact__c = con.Id;
        dOpp1.CampaignId = testCamp.Id;
        dOpp1.rC_Giving__Giving_Amount__c = 1001;
        dOpp1.Product_Type__c = SPONSORSHIP;
        dOpp1.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        dOpp1.Vendor_Name__c = 'Other';
        dOpp1.Cancelled_Date__c = System.today();
        dOpp1.Start_Date__c = System.today().addMonths(-5);
        dOpp1.Date_Presponsorship_Started__c = System.today().addMonths(-5);
        dOpp1.StageName = 'Open';
        dOpp1.rC_Giving__Is_Sustainer__c = true;
        dOpp1.rC_Giving__Anniversary_Date__c = system.today();
        dOpp1.rC_Sponsorship__Opportunity_Group_Id__c = 2356;
        dOpp1.Identified_for_Clawback__c = false;
        //dOpp1.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
        //dOpp1.Sponsorship_Status_Reason_Copy__c = 'Participant Change';
        insert dOpp1;

        Test.StartTest();

            Opportunity opp = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Legacy_Type__c,
                               rC_Sponsorship__Sponsorship_Status_Reason__c,Cancel_Sponsorship__c,Paid_Through_Date__c
                               FROM Opportunity
                               WHERE Id = :dOpp1.Id];
            opp.Legacy_Type__c = '';
            opp.rC_Sponsorship__Sponsorship_Status__c = 'Closed';
            opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
            opp.Cancel_Sponsorship__c = 'Cancel - Reinstateable' ;
            opp.Paid_Through_Date__c = System.today().addDays(-10);
            update opp;
            
        Test.StopTest();
        //System.assertEquals(true, dOpp.Identified_for_Clawback__c);
    }
    
     @isTest
    private static void updateGAUTest(){
         createGAU_SA();       
        createAccounts();
        createCampaigns();
       
        national_Office_Acc.Reciprocal_GAU__c = testGAU.id;
        update national_Office_Acc;
        createParticipant();
        createDonors();
        
        createOpp();
        Opportunity op = [SELECT id,rC_Giving__GAU__c,Participant__c, rC_Sponsorship__Sponsorship_Status__c FROM Opportunity WHERE id=: oppNew.id];
         op.Participant__c = participant0.id;
         op.rC_Sponsorship__Sponsorship_Status__c = 'Active';
         update op;
    }
    
    //Added by Ashu Gupta
      @isTest
    private static void OppFOCTest(){
       acc = TestUtils.createAccount('test',true);
       createParticipant1();
        createGAU_SA();
        createCampaigns();
        
       
        FOC__c FOC_Setting = new FOC__c();
        FOC_Setting.Name = 'ITU ';
       // FOC_Setting.Description__c = 'Lockbox';
        //FOC_Setting.GAU_Id__c = testGAU.Id;
        insert FOC_Setting;
        parentOpp = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp.recordTypeId  = RT_OPP_DONAT;
        parentOpp.Participant__c = participant1.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.rC_Giving__Giving_Amount__c = 100;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.rC_Giving__GAU__c = testGAU.Id;
        parentOpp.Product_Type__c = DESIGNATED_FUND;
        parentOpp.Product_Sub_Type__c = AS_INSTRUCTED;
        
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp.Vendor_Name__c = 'Other';
        parentOpp.Start_Date__c = System.today().addMonths(-3);
        parentOpp.StageName = 'Proposal';
        parentOpp.Identified_for_Clawback__c = false;
        insert parentOpp;

        
        testOpp4 = TestUtils.createOpportunity(acc, 'testOpportunity4', 100, false);
        testOpp4.recordTypeId  = RT_OPP_TRANS;
        testOpp4.Participant__c = participant1.Id;
       testOpp4.CampaignId = testCamp.Id;
        testOpp4.rC_Giving__Parent__c = parentOpp.Id;
     
        testOpp4.Identified_for_Clawback__c = false;
       testOpp4.StageName = 'Cultivation';
        testOpp4.FOC__c = 'ITU1 - ITU Check';
        insert testOpp4;
    }   
    
  
    //MR  T-528358 Test method to test the BatchLetters_Cancelation when the CFI_Do_Not_Substitute__c is 'Do Not Substitute - Contact Donor'
      @isTest             
    private static void BatchLetters_Cancelation_Test_Participant_Change(){
        createTestDataForBatchLetters_Cancellation();
        List<Print_Queue__c> printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
        System.assert(printQueues.size()>0);
        delete printQueues;

        //start Test
        Test.startTest();
        OpportunityService.isBatchLettersCanceledProcessed = false;
        testOpp1.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
        testOpp1.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
        testOpp1.rC_Sponsorship__Do_Not_Substitute__c = true;
        testOpp1.CFI_Do_Not_Substitute__c = 'Do Not Substitute - Contact Donor';
        testOpp1.Do_Not_Sub_Reason__c = 'Alliance Request';
        update testOpp1;
        // Checking the number of Print Queues records
         printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
      
        //stop Test
        Test.stopTest();
        // At least one Print Queue record should be created
        System.assert(printQueues.size()>0);
        // Asserting Letter Id value of the print Queue record created 
        System.assertEquals(printQueues.get(0).Letter_ID__c , '1352');
    }    
    //MR  T-528358  Test method to test the BatchLetters_Cancelation when the CFI_Do_Not_Substitute__c is not 'Do Not Substitute - Contact Donor'
     @isTest             
    private static void BatchLetters_Cancelation_Test_Participant_ChangeForNoSubstitute(){
        createTestDataForBatchLetters_Cancellation();
        List<Print_Queue__c> printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
        System.assert(printQueues.size()>0);
        delete printQueues;

        //start Test
        Test.startTest();
        OpportunityService.isBatchLettersCanceledProcessed = false;
        //update the opportunity to cover criteria for Change for no Substitute
        testOpp1.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
        testOpp1.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
        testOpp1.rC_Sponsorship__Do_Not_Substitute__c = true;
        testOpp1.CFI_Do_Not_Substitute__c = 'Do Not Substitute';
        testOpp1.Do_Not_Sub_Reason__c = 'Alliance Request';
        update testOpp1;
        // Checking the number of Print Queues records
         printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
      
        //stop Test
        Test.stopTest();
        // At least one Print Queue record should be created
        System.assert(printQueues.size()>0);
        // Asserting Letter Id value of the print Queue record created 
        System.assertEquals(printQueues.get(0).Letter_ID__c , '1350');
    }    
    
    //MR  T-528358  Test method to test the BatchLetters_Cancelation when the sponsorship Status reason is 'Cancellation' with Detail as 'Replacement Child Declined'
     @isTest             
    private static void BatchLetters_Cancelation_Test_CancellationForDecline(){
        createTestDataForBatchLetters_Cancellation();
        List<Print_Queue__c> printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
        System.assert(printQueues.size()>0);
        delete printQueues;
        testOpp1.Legacy_type__c = null;
        update testOpp1;
        //start Test
        Test.startTest();
        OpportunityService.isBatchLettersCanceledProcessed = false;
        //update the opportunity to cover criteria of Cancellation for Decline
        testOpp1.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
        testOpp1.Cancel_Sponsorship__c = 'Cancel - Reinstateable';
        testOpp1.rC_Sponsorship__Future_Cancellation_Date__c = null;
        testOpp1.Sponsorship_Change_Reason_Detail__c = 'Replacement Child Declined';
        update testOpp1;
        // Checking the number of Print Queues records
        printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
        //stop Test
        Test.stopTest();
        // At least one Print Queue record should be created
        System.assert(printQueues.size()>0);
        // Asserting Letter Id value of the print Queue record created 
        System.assertEquals(printQueues.get(0).Letter_ID__c , '1500');
    }   
    
        //MR  T-528358  Test method to test the BatchLetters_Cancelation when the sponsorship Status reason is 'Cancellation' with Detail other except 'Replacement Child Declined'
     @isTest            
    private static void BatchLetters_Cancelation_Test_CancellationForDelinquency(){
        createTestDataForBatchLetters_Cancellation();
        List<Print_Queue__c> printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
        System.assert(printQueues.size()>0);
        delete printQueues;
        testOpp1.Legacy_type__c = null;
        update testOpp1;
        //start Test
        Test.startTest();
        OpportunityService.isBatchLettersCanceledProcessed = false;
       //update the opportunity to cover criteria of Cancellation for Delinquency
        testOpp1.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
        testOpp1.Cancel_Sponsorship__c = 'Cancel - Reinstateable';
        testOpp1.rC_Sponsorship__Future_Cancellation_Date__c = null;
        testOpp1.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
        update testOpp1;
         // Checking the number of Print Queues records
        printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
      
        //stop Test
        Test.stopTest();
         // At least one Print Queue record should be created
        System.assert(printQueues.size()>0);
        // Asserting Letter Id value of the print Queue record created 
        System.assertEquals(printQueues.get(0).Letter_ID__c , '1501');
    }
    
    
    
    //Added by Munib Ur Rehman
    @isTest
    private static void testNameUpdatesOfOpps(){
        acc = TestUtils.createAccount('test',true);
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        parentOpp = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp.recordTypeId  = RT_OPP_DONAT;
        parentOpp.Participant__c = participant1.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.rC_Giving__Giving_Amount__c = 100;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.rC_Giving__GAU__c = testGAU.Id;
        parentOpp.Product_Type__c = DESIGNATED_FUND;
        parentOpp.Product_Sub_Type__c = 'As Instructed';
        parentOpp.Sponsored_Account__c = acc.Id;
        
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp.Vendor_Name__c = 'Other';
        parentOpp.Start_Date__c = System.today().addMonths(-3);
        parentOpp.StageName = 'Proposal';
        parentOpp.Identified_for_Clawback__c = false;
        insert parentOpp;
        
        Contact con2 = TestUtils.createContact(acc, 'Unit test 2', 'Apex 2', false);
        con2.RecordTypeId = RT_CON_HHOLD;
        con2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con2.Correspondence_Paused__c = false;
        con2.Participant_Case_Number__c = '14233';
        con2.Participant_Number__c = '53223';
        con2.Flag_Comments__c = 'test comment';
        insert con2;
        
        Opportunity parentOpp1 = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp1.recordTypeId  = RT_OPP_DONAT;
        parentOpp1.Participant__c = participant1.Id;
        parentOpp1.CampaignId = testCamp.Id;
        parentOpp1.rC_Giving__Giving_Amount__c = 100;
        parentOpp1.DFC_Release_Month_Master__c = 3;
        parentOpp1.rC_Giving__GAU__c = testGAU.Id;
        parentOpp1.Product_Type__c = 'Sponsorship';
        parentOpp1.Product_Sub_Type__c = 'Child Sponsorship';
        parentOpp1.Sponsored_Account__c = acc.Id;
        parentOpp1.rC_Giving__Primary_Contact__c = con2.Id;
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp1.Vendor_Name__c = 'Other';
        parentOpp1.Start_Date__c = System.today().addMonths(-3);
        parentOpp1.StageName = 'Proposal';
        parentOpp1.Identified_for_Clawback__c = false;
        parentOpp1.rC_Giving__Is_Sustainer__c = true;
        parentOpp1.rC_Giving__Anniversary_Date__c = system.today();
        insert parentOpp1;
        
        Opportunity parentOpp2 = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp2.recordTypeId  = RT_OPP_DONAT;
        parentOpp2.Participant__c = participant1.Id;
        parentOpp2.CampaignId = testCamp.Id;
        parentOpp2.rC_Giving__Giving_Amount__c = 100;
        parentOpp2.DFC_Release_Month_Master__c = 3;
        parentOpp2.rC_Giving__GAU__c = testGAU.Id;
        parentOpp2.Product_Type__c = 'Recurring Gift';
        parentOpp2.Product_Sub_Type__c = 'CGN';
        parentOpp2.Sponsored_Account__c = acc.Id;
        
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp2.Vendor_Name__c = 'Other';
        parentOpp2.Start_Date__c = System.today().addMonths(-3);
        parentOpp2.StageName = 'Proposal';
        parentOpp2.Identified_for_Clawback__c = false;
        insert parentOpp2;
        
        Opportunity parentOpp3 = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp3.recordTypeId  = RT_OPP_DONAT;
        parentOpp3.Participant__c = participant1.Id;
        parentOpp3.CampaignId = testCamp.Id;
        parentOpp3.rC_Giving__Giving_Amount__c = 100;
        parentOpp3.DFC_Release_Month_Master__c = 3;
        parentOpp3.rC_Giving__GAU__c = testGAU.Id;
        parentOpp3.Product_Type__c = 'One Time Gift';
        parentOpp3.Product_Sub_Type__c = 'Standard';
        parentOpp3.Sponsored_Account__c = acc.Id;
        
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp3.Vendor_Name__c = 'Other';
        parentOpp3.Start_Date__c = System.today().addMonths(-3);
        parentOpp3.StageName = 'Proposal';
        parentOpp3.Identified_for_Clawback__c = false;
        insert parentOpp3;
        
        Opportunity parentOpp4 = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp4.recordTypeId  = RT_OPP_DONAT;
        parentOpp4.Participant__c = participant1.Id;
        parentOpp4.CampaignId = testCamp.Id;
        parentOpp4.rC_Giving__Giving_Amount__c = 100;
        parentOpp4.DFC_Release_Month_Master__c = 3;
        parentOpp4.rC_Giving__GAU__c = testGAU.Id;
        parentOpp4.Product_Type__c = 'Third Party';
        parentOpp4.Product_Sub_Type__c = 'Foundation';
        parentOpp4.Sponsored_Account__c = acc.Id;
        
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp4.Vendor_Name__c = 'Other';
        parentOpp4.Start_Date__c = System.today().addMonths(-3);
        parentOpp4.StageName = 'Proposal';
        parentOpp4.Identified_for_Clawback__c = false;
        insert parentOpp4;
        
        Opportunity parentOpp5 = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp5.recordTypeId  = RT_OPP_DONAT;
        parentOpp5.Participant__c = participant1.Id;
        parentOpp5.CampaignId = testCamp.Id;
        parentOpp5.rC_Giving__Giving_Amount__c = 100;
        parentOpp5.DFC_Release_Month_Master__c = 3;
        parentOpp5.rC_Giving__GAU__c = testGAU.Id;
        parentOpp5.Product_Type__c = DESIGNATED_FUND;
        parentOpp5.Product_Sub_Type__c = 'Gift For Local Partner';
        parentOpp5.Sponsored_Account__c = acc.Id;
        
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp5.Vendor_Name__c = 'Other';
        parentOpp5.Start_Date__c = System.today().addMonths(-3);
        parentOpp5.StageName = 'Proposal';
        parentOpp5.Identified_for_Clawback__c = false;
        insert parentOpp5;
    }    
    
    
    // T-528359 | Method to cover the BatchLetters_Suspense method When the DFC Status of Adjusted Transaction is 'Undeliverable - Over $100';
    @isTest            
    private static void BatchLettersSuspenseTest1(){
        
        createParticipant1();
        createGAU_SA();
        testGAU2 = TestUtils.createGeneralAccountingUnit('0600', false);// For Batch Suspense Letter method testing
        testGAU2.Receipt_Category__c = '0600';
        insert testGAU2;
        
        createCampaigns();
        testCamp.Product_Type__c = 'One Time Gift';
        testCamp.Product_Sub_Type__c = 'DFC Fee';
        update testCamp;
        
        FOC__c FOC_Setting = new FOC__c();
        FOC_Setting.Name = 'ITU1 ';
        insert FOC_Setting;
        
        OpportunityService.isBatchLetters_SuspenseProcessed = false;
        // Creation of Parent Opportunity
        parentOpp = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp.recordTypeId  = RT_OPP_DONAT;
        parentOpp.Participant__c = participant1.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.rC_Giving__Giving_Amount__c = 100;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.rC_Giving__GAU__c = testGAU2.Id;
        parentOpp.Product_Type__c = DESIGNATED_FUND;
        parentOpp.Product_Sub_Type__c = AS_INSTRUCTED;
        parentOpp.rC_Sponsorship__Substitute_Contact__c = con.Id;
        parentOpp.rC_Giving__Primary_Contact__c = con.Id;
        parentOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp.Vendor_Name__c = 'Other';
        parentOpp.Start_Date__c = System.today().addMonths(-3);
        parentOpp.StageName = 'Proposal';
        parentOpp.Identified_for_Clawback__c = false;
        insert parentOpp;
        
        OpportunityService.isBatchLetters_SuspenseProcessed = false;
        // Creation of Transaction Opportunity with parentOpp as parent
        testOpp3 = TestUtils.createOpportunity(acc, 'testOpportunity3', 150, false);
        testOpp3.recordTypeId  = RT_OPP_TRANS;
        testOpp3.Participant__c = participant1.Id;
        testOpp3.CampaignId = testCamp.Id;
        testOpp3.rC_Giving__Giving_Amount__c = 120;
        testOpp3.rC_Giving__Parent__c = parentOpp.Id;
        testOpp3.Cost_Extension__c = true;
        //testOpp3.rC_Giving__GAU__c = testGAU.Id;
        testOpp3.Product_Type__c = DESIGNATED_FUND;
        testOpp3.Product_Sub_Type__c = BELATED_CHRISTMAS;
        testOpp3.rC_Giving__Primary_Contact__c = con.Id;
        testOpp3.rC_Giving__Hard_Credit_Contact__c = con.Id;
        testOpp3.Vendor_Name__c = 'Other';
        testOpp3.Start_Date__c = System.today().addMonths(-3);
        testOpp3.StageName = 'Proposal';
        testOpp3.Identified_for_Clawback__c = false;
        testOpp3.DFC_Status__c = 'Undeliverable - Over $100';
        insert testOpp3;
        testOpp3.DFC_Status__c = 'Undeliverable - Over $100';
        update testOpp3;
        
        OpportunityService.isBatchLetters_SuspenseProcessed = false;
        Test.startTest();
        Opportunity BatchSuspenseOpp = TestUtils.createOpportunity(acc, 'Batch Suspense Opportunity', 100, false);
        BatchSuspenseOpp.recordTypeId  = RT_OPP_TRANS;
        BatchSuspenseOpp.Participant__c = participant1.Id;
        BatchSuspenseOpp.CampaignId = testCamp.Id;
        BatchSuspenseOpp.rC_Giving__Parent__c = parentOpp.Id;
        BatchSuspenseOpp.Cost_Extension__c = true;
        BatchSuspenseOpp.rC_Giving__GAU__c = testGAU2.Id;
        BatchSuspenseOpp.Product_Type__c = DESIGNATED_FUND;
        BatchSuspenseOpp.Product_Sub_Type__c = BELATED_CHRISTMAS;
        BatchSuspenseOpp.rC_Giving__Primary_Contact__c = con.Id;
        BatchSuspenseOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        BatchSuspenseOpp.Vendor_Name__c = 'Other';
        BatchSuspenseOpp.Identified_for_Clawback__c = false;
        BatchSuspenseOpp.DFC_Status__c = 'Undeliverable - Over $100';
        BatchSuspenseOpp.Adjusted_Transaction__c = testOpp3.Id;
        insert BatchSuspenseOpp;
        
        Test.stopTest();

        // Assertion
        List<Print_Queue__c> printQueues = [select Id, Letter_ID__c from Print_Queue__c];
        System.assertEquals('58', printQueues[0].Letter_ID__c);
        
    }
    
    // T-528359 | Method to cover the BatchLetters_Suspense method When the DFC Status of Adjusted Transaction is 'Undeliverable - Project Closed';
    @isTest            
    private static void BatchLettersSuspenseTest2(){
        
        createParticipant1();
        createGAU_SA();
        testGAU2 = TestUtils.createGeneralAccountingUnit('0600', false);// For Batch Suspense Letter method testing
        testGAU2.Receipt_Category__c = '0600';
        insert testGAU2;
        
        createCampaigns();
        testCamp.Product_Type__c = 'One Time Gift';
        testCamp.Product_Sub_Type__c = 'DFC Fee';
        update testCamp;
        FOC__c FOC_Setting = new FOC__c();
        FOC_Setting.Name = 'ITU1 ';
        insert FOC_Setting;
        OpportunityService.isBatchLetters_SuspenseProcessed = false;
        // Creation of Parent Opportunity
        parentOpp = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp.recordTypeId  = RT_OPP_DONAT;
        parentOpp.Participant__c = participant1.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.rC_Giving__Giving_Amount__c = 100;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.rC_Giving__GAU__c = testGAU2.Id;
        parentOpp.Product_Type__c = DESIGNATED_FUND;
        parentOpp.Product_Sub_Type__c = AS_INSTRUCTED;
        parentOpp.rC_Sponsorship__Substitute_Contact__c = con.Id;
        parentOpp.rC_Giving__Primary_Contact__c = con.Id;
        parentOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp.Vendor_Name__c = 'Other';
        parentOpp.Start_Date__c = System.today().addMonths(-3);
        parentOpp.StageName = 'Proposal';
        parentOpp.Identified_for_Clawback__c = false;
        insert parentOpp;
        
        OpportunityService.isBatchLetters_SuspenseProcessed = false;
        // Creation of Transaction Opportunity with parentOpp as parent
        testOpp3 = TestUtils.createOpportunity(acc, 'testOpportunity3', 150, false);
        testOpp3.recordTypeId  = RT_OPP_TRANS;
        testOpp3.Participant__c = participant1.Id;
        testOpp3.CampaignId = testCamp.Id;
        testOpp3.rC_Giving__Giving_Amount__c = 120;
        testOpp3.rC_Giving__Parent__c = parentOpp.Id;
        testOpp3.Cost_Extension__c = true;
        //testOpp3.rC_Giving__GAU__c = testGAU.Id;
        testOpp3.Product_Type__c = DESIGNATED_FUND;
        testOpp3.Product_Sub_Type__c = BELATED_CHRISTMAS;
        testOpp3.rC_Giving__Primary_Contact__c = con.Id;
        testOpp3.rC_Giving__Hard_Credit_Contact__c = con.Id;
        testOpp3.Vendor_Name__c = 'Other';
        testOpp3.Start_Date__c = System.today().addMonths(-3);
        testOpp3.StageName = 'Proposal';
        testOpp3.Identified_for_Clawback__c = false;
        testOpp3.DFC_Status__c = 'Undeliverable - Project Closed';
        insert testOpp3;
        testOpp3.DFC_Status__c = 'Undeliverable - Project Closed';
        update testOpp3;
        
        OpportunityService.isBatchLetters_SuspenseProcessed = false;
        Test.startTest();
        Opportunity BatchSuspenseOpp = TestUtils.createOpportunity(acc, 'Batch Suspense Opportunity', 100, false);
        BatchSuspenseOpp.recordTypeId  = RT_OPP_TRANS;
        BatchSuspenseOpp.Participant__c = participant1.Id;
        BatchSuspenseOpp.CampaignId = testCamp.Id;
        BatchSuspenseOpp.rC_Giving__Parent__c = parentOpp.Id;
        BatchSuspenseOpp.Cost_Extension__c = true;
        BatchSuspenseOpp.rC_Giving__GAU__c = testGAU2.Id;
        BatchSuspenseOpp.Product_Type__c = DESIGNATED_FUND;
        BatchSuspenseOpp.Product_Sub_Type__c = BELATED_CHRISTMAS;
        BatchSuspenseOpp.rC_Giving__Primary_Contact__c = con.Id;
        BatchSuspenseOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        BatchSuspenseOpp.Vendor_Name__c = 'Other';
        BatchSuspenseOpp.Identified_for_Clawback__c = false;
        BatchSuspenseOpp.DFC_Status__c = 'Undeliverable - Over $100';
        BatchSuspenseOpp.Adjusted_Transaction__c = testOpp3.Id;
        insert BatchSuspenseOpp;
        Test.stopTest();
        
        // Assertion
        List<Print_Queue__c> printQueues = [select Id, Letter_ID__c from Print_Queue__c];
        System.assertEquals('59', printQueues[0].Letter_ID__c);
        
    }
    
       //MR  T-528360  Test method to test the Suspense - Undeliverable DFCs - Batch Letters .
    @isTest            
    private static void TestBatchLetters_SuspenseKeptByLP_ACHReturn(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        
        FOC__c FOC_Setting = new FOC__c();
        FOC_Setting.Name = 'ITU1 ';
        insert FOC_Setting;
        
        // Creation of Parent Opportunity
        parentOpp = TestUtils.createOpportunity(acc, 'parentOpportunity', 100, false);
        parentOpp.recordTypeId  = RT_OPP_DONAT;
        parentOpp.Participant__c = participant1.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.rC_Giving__Giving_Amount__c = 100;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.rC_Giving__GAU__c = testGAU.Id;
        parentOpp.Product_Type__c = DESIGNATED_FUND;
        parentOpp.Product_Sub_Type__c = AS_INSTRUCTED;
        parentOpp.rC_Sponsorship__Substitute_Contact__c = con.Id;
        parentOpp.rC_Giving__Primary_Contact__c = con.Id;
        parentOpp.rC_Giving__Hard_Credit_Contact__c = con.Id;
        //parentOpp.Auto_Assign_Participant__c = 'Direct Sponsorship';
        parentOpp.Vendor_Name__c = 'Other';
        parentOpp.Start_Date__c = System.today().addMonths(-3);
        parentOpp.StageName = 'Proposal';
        parentOpp.Identified_for_Clawback__c = false;
        insert parentOpp;
        
        // Creation of Transaction Opportunity with parentOpp as parent
        testOpp3 = TestUtils.createOpportunity(acc, 'testOpportunity3', 150, false);
        testOpp3.recordTypeId  = RT_OPP_TRANS;
        testOpp3.Participant__c = participant1.Id;
        testOpp3.CampaignId = testCamp.Id;
        testOpp3.rC_Giving__Giving_Amount__c = 120;
        testOpp3.rC_Giving__Parent__c = parentOpp.Id;
        testOpp3.Cost_Extension__c = true;
        //testOpp3.rC_Giving__GAU__c = testGAU.Id;
        testOpp3.Product_Type__c = DESIGNATED_FUND;
        testOpp3.Product_Sub_Type__c = BELATED_CHRISTMAS;
        testOpp3.rC_Giving__Primary_Contact__c = con.Id;
        testOpp3.rC_Giving__Hard_Credit_Contact__c = con.Id;
        testOpp3.Vendor_Name__c = 'Other';
        testOpp3.Start_Date__c = System.today().addMonths(-3);
        testOpp3.StageName = 'Proposal';
        testOpp3.Identified_for_Clawback__c = false;
        testOpp3.DFC_Status__c = 'Undeliverable - Over $100';
        insert testOpp3;
        

        //testing starts
        Test.startTest();
        //updating opportunity by changing the DFC Status to 'Kept by LP/Community'
        testOpp3.DFC_Status__c = 'Kept by LP/Community';
        update testOpp3;
        List<Print_Queue__c> printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
        System.assert(printQueues.size()>0);
        System.assertEquals(printQueues.get(0).Letter_ID__c , '57');
        delete printQueues;
        //changing the DFC Status to 'Undeliverable - Over $100'
        //Commented by Harsh Singh on 3rd April 2017
       /* testOpp3.DFC_Status__c = 'Undeliverable - Over $100';
        testOpp3.Return_Code__c = 'C08 - Reserved';
        update testOpp3;
        // fetching print Queues records 
        printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
        // At least one Print Queue record should be created
        System.assert(false, '==>'+ printQueues.size());
        // Asserting Letter Id value of the print Queue record created 
        System.assertEquals(printQueues.get(0).Letter_ID__c , '683');*/
        Test.stopTest(); 
        
    }
    
        //MR  T-528358  Test method to test the BatchLetters_Cancelation when the sponsorship Status reason is 'Cancellation' with Detail other except 'Replacement Child Declined'
    @isTest            
    private static void BatchLetters_Cancelation_Test_CancellationForDelinquency2(){
        createTestDataForBatchLetters_Cancellation();
        List<Print_Queue__c> printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
        System.assert(printQueues.size()>0);
        delete printQueues;
        testOpp1.Legacy_type__c = null;
        update testOpp1;
        //start Test
        Test.startTest();
        OpportunityService.isBatchLettersCanceledProcessed = false;
        //update the opportunity to cover criteria of Cancellation for Delinquency When Future cancellation date is not null
        testOpp1.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
        testOpp1.Cancel_Sponsorship__c = 'Cancel - Reinstateable';
        testOpp1.Sponsorship_Change_Reason_Detail__c = 'Child Departure';
        testOpp1.rC_Sponsorship__Future_Cancellation_Date__c = System.today().addDays(4);
        update testOpp1;
        // Checking the number of Print Queues records
        printQueues = [select Id, Letter_ID__c from Print_Queue__c order by CreatedDate desc];
        //stop Test
        Test.stopTest();
        // At least one Print Queue record should be created
        System.assert(printQueues.size()>0);
        // Asserting Letter Id value of the print Queue record created 
        System.assertEquals(printQueues.get(0).Letter_ID__c , '1451');
    }
    //Cover BatchLetters_Cancelation method in opportunity service by harsh
    @istest
      private static void batchletterCancelationTest(){
        createParticipant1(); 
        createGAU_SA();
        createCampaigns();
        createPrefOpp();  
        
        Opportunity opport = [Select Id, rC_Giving__Primary_Contact__c ,rC_Giving__Primary_Contact__r.Alliance_Donor__c, rC_Giving__Primary_Contact__r.Donor_Alliance__c, Product_Type__c, Product_Sub_Type__c, Auto_Assign_Participant__c, Sponsorship_Change_Reason_Detail__c, isDFCCloned__c from Opportunity where Id = :preferenceRecordOpp.Id];
        chAccount.Alliance__c = true;
        update chAccount;
          
        Account accoun = [select Id , Alliance__c from Account where Id =:chAccount.Id];
        opport = [Select Id, Participant__c, rC_Giving__Primary_Contact__c ,rC_Giving__Primary_Contact__r.Alliance_Donor__c ,rC_Giving__Primary_Contact__r.Donor_Alliance__c, Product_Type__c, Product_Sub_Type__c, Auto_Assign_Participant__c, Sponsorship_Change_Reason_Detail__c, isDFCCloned__c from Opportunity where recordtype.Id=:RT_OPP_DONAT and Id =:preferenceRecordOpp.Id];
        Contact cont=[Select rC_Sponsorship__Sponsorship_Status__c from Contact where Id=:opport.Participant__c];
          cont.rC_Sponsorship__Sponsorship_Status__c='Departed';
          update cont;
        //  System.AssertEquals(null,cont);
        //  System.AssertEquals(null,[Select Sponsorship_Change_Reason_Detail__c from Opportunity where Id=:opport.ID].Sponsorship_Change_Reason_Detail__c);
          
        opport.Product_Type__c = SPONSORSHIP;
        opport.rC_Giving__Primary_Contact__r.Donor_Alliance__c = chAccount.Id;
        opport.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opport.Auto_Assign_Participant__c = 'Direct Sponsorship';
        opport.rC_Sponsorship__Sponsorship_Status_Reason__c=null;

        //opport.Auto_Assign_Participant__c = 'New Assignment';
        opport.Legacy_Type__c = '';
        //update opport;
       // opport.Sponsorship_Change_Reason_Detail__c = 'Another';
        //opport.isDFCCloned__c = false;
        Test.startTest();
            update opport;
         //system.assertEquals(null,  opport);        
      /*      CheckRecursive.run = true;
            CheckRecursive.runOpportunity = true;
            opport.Sponsorship_Change_Reason_Detail__c = 'Another';
            opport.isDFCCloned__c = false;
          opport.rC_Sponsorship__Sponsorship_Status_Reason__c=null;
            update opport;*/
         // system.assertEquals('temp',  opport.rC_Sponsorship__Sponsorship_Status_Reason__c);
          opport.Sponsorship_Change_Reason_Detail__c='Child Departure';
          opport.rC_Sponsorship__Do_Not_Substitute__c=True;
          opport.CFI_Do_Not_Substitute__c= 'Do Not Substitute - Contact Donor';
          opport.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
          opport.Do_Not_Sub_Reason__c='Auto Upgrade';
         
          update opport;
                  opport.Auto_Assign_Participant__c = 'Direct Sponsorship';
          update opport;

       //  system.assertEquals('temp',  [Select rC_Sponsorship__Sponsorship_Status_Reason__c from opportunity where Id=:opport.ID].rC_Sponsorship__Sponsorship_Status_Reason__c);
        
            //asserts
            List<rC_Bios__Preference__c> prefList = [select Id from rC_Bios__Preference__c where rC_Sponsorship__Opportunity__c =:opport.Id];
            //System.assert(prefList.size()>0);
      //  Test.stopTest();
    }

    
     public static void createTestDataForBatchLetters_Cancellation(){
        createParticipant1();
        createGAU_SA();
        createCampaigns();
        createTestOpp1();
    }
}