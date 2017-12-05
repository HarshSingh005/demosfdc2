/***********************************************************************************************************
 * Appirio, Inc
 * Name         : OpportunityDelinquentCancelBatchTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test Class for OpportunityDelinquentCancelBatch
 * Created Date : 07/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 07/04/2016                   Munib Ur Rehman        Created
 * 23/06/2016                   Munib Ur Rehman        modified
 **********************************************************************************************************/
 @isTest
 public with sharing class OpportunityDelinquentCancelBatchTest {
    @isTest
    public static void TestOpportunityDelinquentCancelBatch(){
        //creating Testing data
        createTestData();
        //Testing starts
        Test.startTest();
        OpportunityDelinquentCancelBatch batch1 = new OpportunityDelinquentCancelBatch();
        id batchId = Database.executeBatch(batch1, 200);
        List<Opportunity> listOpp = [select Id , Cancel_Sponsorship__c from Opportunity where Cancel_Sponsorship__c = 'Cancel - Reinstateable'];
        Test.StopTest();//testing ends
        
        //checking assertion
        List<Opportunity> oppList2 = [Select Id, Sponsorship_Change_Reason_Detail__c , Cancelled_Date__c from Opportunity where Product_Type__c = 'Sponsorship' AND Product_Sub_Type__c = 'Other Contribution'];
        System.assertEquals(oppList2.get(0).Cancelled_Date__c, null);
          
    }
    
    //-----------------------------------------------------------------
    
    @isTest
    public static void TestOpportunityDelinquentCancelBatch1(){
        //creating Testing data
        testdataupdate();
        //Testing starts
        Test.startTest();
        OpportunityDelinquentCancelBatch batch1 = new OpportunityDelinquentCancelBatch();
        id batchId = Database.executeBatch(batch1, 200);
        List<Opportunity> listOpp = [select Id , Cancel_Sponsorship__c from Opportunity where Cancel_Sponsorship__c = 'Cancel - Reinstateable'];
        Test.StopTest();//testing ends
        
        //checking assertion
        List<Opportunity> oppList2 = [Select Id, Sponsorship_Change_Reason_Detail__c , Cancelled_Date__c from Opportunity where Product_Type__c = 'Sponsorship' AND Product_Sub_Type__c = 'Other Contribution'];
         
        System.assertEquals(oppList2.get(0).Cancelled_Date__c, null);
       
    }
    
    public static void createTestData(){
        //sahil rathore
        //added all the opportunity to a list as it was giving error for soql 101 query and hitting governor limit
        
        //contact setting creation
        /*rC_Giving__Contact_Setting__c setting = new rC_Giving__Contact_Setting__c();
        setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert setting; */
        list<Opportunity> opp = new list<Opportunity>();
        
        rC_Giving__Contact_Setting__c rc_giv_con_st = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        rc_giv_con_st.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert rc_giv_con_st ;
        
        //create account and contact data
        Id accNORTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        Account nationalOffice = TestUtils.createAccountWithRT('National Office', accNORTId, null, '899', '1345', true);
        
        Id accLPRTId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        Account localPartner = TestUtils.createAccountWithRT('Local Partner', accLPRTId, null, '999', '1346', false);
        localPartner.Participant_Contact_Owner__c = UserInfo.getUserId();
        localPartner.ParentId = nationalOffice.Id;
        insert localPartner;
        
        Id accCMRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        Account community = TestUtils.createAccountWithRT('Community', accCMRTId, null, '993', '1343', false);
        community.ParentId = localPartner.Id;
        community.Community_Id__c = '3456';
        insert community;
        
        Account community2 = TestUtils.createAccountWithRT('Community', accCMRTId, null, '992', '1341', false);
        community2.ParentId = localPartner.Id;
        community2.Community_Id__c = '9912';
        insert community2;        
        
        Id HHId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        Account acc = TestUtils.createAccountWithRT('Test Account', HHId, null, '734', '2323', true);
        
        Contact contact = TestUtils.createContact(acc, 'Test First Name', 'Test Last Name', false);
        contact.RecordTypeId = Contact_SnapshotController.CONTACT_RECORDTYPE_HOUSEHOLD;
        contact.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        contact.rC_Bios__Preferred_Phone__c = 'Home';
        contact.HomePhone = '020-2656768';
        contact.rC_Bios__Preferred_Email__c = 'Home';
        contact.rC_Bios__Home_Email__c = 'test@gmail.com';
        contact.Lifetime_Amount__c = 1000;
        contact.Last_Gift_Amount__c = 100;
        contact.Largest_Gift_Amount__c = 500;
        contact.Largest_Gift_Date__c = date.today();
        contact.rC_Giving__Track_Hard_Credits__c = true;
        insert contact;
        
        
        
        Contact participant = TestUtils.createContact(acc, 'Joe', 'Kid', false);
        participant.Community__c = community.id;
        participant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        participant.Participant_Case_Number__c = '87654';
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant.Local_Partner__c = localPartner.Id;
        insert participant;
        
        //creating opportunity for Product Type = 'Sponsorship' and ProductSubType = 'CGN'
        Opportunity parentOpp = new Opportunity();
        parentOpp.Name = 'testOpportunity';
        parentOpp.StageName = 'Open';
        parentOpp.CloseDate = system.today() + 30;
        parentOpp.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.Product_Type__c = 'Sponsorship';
        parentOpp.Product_Sub_Type__c = 'CGN';
        parentOpp.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        parentOpp.Paid_Through_Date__c = System.today().addDays(-120);
        parentOpp.rC_Giving__Suspended_Start_Date__c = System.today().addDays(-30);
        parentOpp.rC_Giving__Suspended_End_Date__c = System.today().addDays(30);
        parentOpp.rC_Giving__Is_Sustainer__c=true;
        //insert parentOpp;
        opp.add(parentOpp);
        
        //creating opportunity for Product Type = 'Recurring Gift' and ProductSubType = 'CGN'
        Opportunity parentOpp1 = new Opportunity();
        parentOpp1.Name = 'testOpportunity1';
        parentOpp1.StageName = 'Open';
        parentOpp1.CloseDate = system.today() + 30;
        parentOpp1.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp1.Participant__c = participant.Id;
        parentOpp1.DFC_Release_Month_Master__c = 3;
        parentOpp1.Product_Type__c = 'Recurring Gift';
        parentOpp1.Product_Sub_Type__c = 'CGN';
        parentOpp1.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        parentOpp1.Paid_Through_Date__c = System.today().addDays(-120);
        parentOpp1.rC_Giving__Is_Giving__c=false;
        //insert parentOpp1;
        opp.add(parentOpp1);
        
        //creating opportunity for Product Type = 'Recurring Gift' and ProductSubType = 'EFS'
        Opportunity parentOpp2 = new Opportunity();
        parentOpp2.Name = 'testOpportunity2';
        parentOpp2.StageName = 'Open';
        parentOpp2.CloseDate = system.today() + 30;
        parentOpp2.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp2.DFC_Release_Month_Master__c = 3;
        parentOpp2.Product_Type__c = 'Recurring Gift';
        parentOpp2.Product_Sub_Type__c = 'EFS';
        parentOpp2.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        parentOpp2.Paid_Through_Date__c = System.today().addDays(-120);
        parentOpp2.rC_Giving__Is_Giving__c=false;
        //insert parentOpp2;
        opp.add(parentOpp2);
        //creating opportunity for Product Type = 'Recurring Gift' and ProductSubType = 'Guardian Angel'
        Opportunity parentOpp3 = new Opportunity();
        parentOpp3.Name = 'testOpportunity3';
        parentOpp3.StageName = 'Open';
        parentOpp3.CloseDate = system.today() + 30;
        parentOpp3.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp3.DFC_Release_Month_Master__c = 3;
        parentOpp3.Product_Type__c = 'Recurring Gift';
        parentOpp3.Product_Sub_Type__c = 'Guardian Angel';
        parentOpp3.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        parentOpp3.Paid_Through_Date__c = System.today().addDays(-120);
        parentOpp3.rC_Giving__Is_Giving__c=false;
        //insert parentOpp3;
        opp.add(parentOpp3);
        //creating opportunity for Product Type = 'Recurring Gift' and ProductSubType = 'Other Contribution'
        Opportunity parentOpp4 = new Opportunity();
        parentOpp4.Name = 'testOpportunity4';
        parentOpp4.StageName = 'Open';
        parentOpp4.CloseDate = system.today() + 30;
        parentOpp4.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp4.DFC_Release_Month_Master__c = 3;
        parentOpp4.Product_Type__c = 'Recurring Gift';
        parentOpp4.Product_Sub_Type__c = 'Other Contribution';
        parentOpp4.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        parentOpp4.Paid_Through_Date__c = System.today().addDays(-120);
        parentOpp4.rC_Giving__Is_Giving__c=false;
        //insert parentOpp4;
        opp.add(parentOpp4);
        //creating opportunity for Product Type = 'Sponsorship' and ProductSubType = 'Other Contribution'
        Opportunity parentOpp5 = new Opportunity();
        parentOpp5.Name = 'testOpportunity5';
        parentOpp5.StageName = 'Open';
        parentOpp5.CloseDate = system.today() + 30;
        parentOpp5.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp5.DFC_Release_Month_Master__c = 3;
        parentOpp5.Product_Type__c = 'Sponsorship';
        parentOpp5.Product_Sub_Type__c = 'Other Contribution';
        parentOpp5.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        parentOpp5.Paid_Through_Date__c = System.today().addDays(-240);
        parentOpp5.rC_Giving__Is_Giving__c=false;
        parentOpp5.rC_Giving__Is_Sustainer__c=true;
        //insert parentOpp5;
        opp.add(parentOpp5);
        //added by sahil
       //Opportunity parentOpp6 = new Opportunity();
       // parentOpp6.Name = 'testOpportunity6';
       // parentOpp6.StageName = 'Open';
       // parentOpp6.CloseDate = system.today() + 30;
       // parentOpp6.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
       // parentOpp6.DFC_Release_Month_Master__c = 3;
       // parentOpp6.Product_Type__c = 'Sponsorship';
      //  parentOpp6.Product_Sub_Type__c = 'Other Contribution';
      //  parentOpp6.rC_Giving__Hard_Credit_Contact__c = contact.Id;
      //  parentOpp6.Paid_Through_Date__c = System.today().addDays(-1440);
        //parentOpp6.Number_Months_Delinquent__c=4;
       // insert parentOpp6;
       insert opp;
    }
    
    //Added by sahil  to increase code coverage
    public static void testdataupdate()
    {
        list<Opportunity> opp = new list<Opportunity>();
        list<Contact> con= new list<Contact>();
        rC_Giving__Contact_Setting__c rc_giv_con_st = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        rc_giv_con_st.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert rc_giv_con_st ;
        
        //create account and contact data
        Id accNORTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        Account nationalOffice = TestUtils.createAccountWithRT('National Office', accNORTId, null, '899', '1345', true);
        
        Id accLPRTId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        Account localPartner = TestUtils.createAccountWithRT('Local Partner', accLPRTId, null, '999', '1346', false);
        localPartner.Participant_Contact_Owner__c = UserInfo.getUserId();
        localPartner.ParentId = nationalOffice.Id;
        insert localPartner;
        
        Id accCMRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        Account community = TestUtils.createAccountWithRT('Community', accCMRTId, null, '993', '1343', false);
        community.ParentId = localPartner.Id;
        community.Community_Id__c = '3456';
        insert community;
        
        Account community2 = TestUtils.createAccountWithRT('Community', accCMRTId, null, '992', '1341', false);
        community2.ParentId = localPartner.Id;
        community2.Community_Id__c = '9912';
        insert community2;        
        
        Id HHId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        Account acc = TestUtils.createAccountWithRT('Test Account', HHId, null, '734', '2323', true);
        
        Contact contact = TestUtils.createContact(acc, 'Test First Name', 'Test Last Name', false);
        contact.RecordTypeId = Contact_SnapshotController.CONTACT_RECORDTYPE_HOUSEHOLD;
        contact.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        contact.rC_Bios__Preferred_Phone__c = 'Home';
        contact.HomePhone = '020-2656768';
        contact.rC_Bios__Preferred_Email__c = 'Home';
        contact.rC_Bios__Home_Email__c = 'test@gmail.com';
        contact.Lifetime_Amount__c = 1000;
        contact.Last_Gift_Amount__c = 100;
        contact.Largest_Gift_Amount__c = 500;
        contact.Largest_Gift_Date__c = date.today();
        contact.rC_Giving__Track_Hard_Credits__c = true;
        contact.Active_Sponsorships__c=1;
        
        con.add(contact);
        
        Id HHId1 = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        Account acc1 = TestUtils.createAccountWithRT('Test Account2121', HHId1, null, '794', '2373', true);
        
        Contact contact1 = TestUtils.createContact(acc1, 'Test First Name', 'Test Last Name', false);
        contact1.RecordTypeId = Contact_SnapshotController.CONTACT_RECORDTYPE_HOUSEHOLD;
        contact1.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        contact1.rC_Bios__Preferred_Phone__c = 'Home';
        contact1.HomePhone = '020-2656768';
        contact1.rC_Bios__Preferred_Email__c = 'Home';
        contact1.rC_Bios__Home_Email__c = 'test@gmail.com';
        contact1.Lifetime_Amount__c = 1000;
        contact1.Last_Gift_Amount__c = 100;
        contact1.Largest_Gift_Amount__c = 500;
        contact1.Largest_Gift_Date__c = date.today();
        contact1.rC_Giving__Track_Hard_Credits__c = true;
        contact1.Active_Sponsorships__c=2;
        
        con.add(contact1);
        insert con;
        
        
        Opportunity parentOpp = new Opportunity();
        parentOpp.Name = 'testOpportunity6';
        parentOpp.StageName = 'Open';
        parentOpp.CloseDate = system.today() + 30;
        parentOpp.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.Product_Type__c = 'Sponsorship';
        parentOpp.Product_Sub_Type__c = 'Other Contribution';
        parentOpp.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        parentOpp.Paid_Through_Date__c = System.today().addDays(-120);
         parentOpp.rC_Giving__Is_Sustainer__c=true;
   //     parentOpp.Number_Months_Delinquent__c=4;
       opp.add(parentOpp);
       
        Opportunity parentOpp1 = new Opportunity();
        parentOpp1.Name = 'testOpportunity7';
        parentOpp1.StageName = 'Open';
        parentOpp1.CloseDate = system.today() + 30;
        parentOpp1.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp1.DFC_Release_Month_Master__c = 3;
        parentOpp1.Product_Type__c = 'Sponsorship';
        parentOpp1.Product_Sub_Type__c = 'Other Contribution';
        parentOpp1.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        parentOpp1.Paid_Through_Date__c = System.today().addDays(-160);
        parentOpp1.rC_Giving__Is_Sustainer__c=true;
       
        
   //     parentOpp.Number_Months_Delinquent__c=4;
       opp.add(parentOpp1);
       
       Opportunity parentOpp2 = new Opportunity();
        parentOpp2.Name = 'testOpportunity8';
        parentOpp2.StageName = 'Open';
        parentOpp2.CloseDate = system.today() + 30;
        parentOpp2.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp2.DFC_Release_Month_Master__c = 3;
        parentOpp2.Product_Type__c = 'Sponsorship';
        parentOpp2.Product_Sub_Type__c = 'Other Contribution';
        parentOpp2.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        parentOpp2.Paid_Through_Date__c = System.today().addDays(-190);
        parentOpp2.rC_Giving__Is_Sustainer__c=true;        
   //     parentOpp.Number_Months_Delinquent__c=4;
       opp.add(parentOpp2);
       
        Opportunity parentOpp3 = new Opportunity();
        parentOpp3.Name = 'testOpportunity9';
        parentOpp3.StageName = 'Open';
        parentOpp3.CloseDate = system.today() + 30;
        parentOpp3.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp3.DFC_Release_Month_Master__c = 3;
        parentOpp3.Product_Type__c = 'Sponsorship';
        parentOpp3.Product_Sub_Type__c = 'Other Contribution';
        parentOpp3.rC_Giving__Hard_Credit_Contact__c = contact1.Id;
        parentOpp3.Paid_Through_Date__c = System.today().addDays(-120);
         parentOpp3.rC_Giving__Is_Sustainer__c=true; 
        
   //     parentOpp.Number_Months_Delinquent__c=4;
        opp.add(parentOpp3);
       
        Opportunity parentOpp4 = new Opportunity();
        parentOpp4.Name = 'testOpportunity10';
        parentOpp4.StageName = 'Open';
        parentOpp4.CloseDate = system.today() + 30;
        parentOpp4.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp4.DFC_Release_Month_Master__c = 3;
        parentOpp4.Product_Type__c = 'Sponsorship';
        parentOpp4.Product_Sub_Type__c = 'Other Contribution';
        parentOpp4.rC_Giving__Hard_Credit_Contact__c = contact1.Id;
        parentOpp4.Paid_Through_Date__c = System.today().addDays(-160);
         parentOpp4.rC_Giving__Is_Sustainer__c=true;
   //     parentOpp.Number_Months_Delinquent__c=4;
        opp.add(parentOpp4);
       
        Opportunity parentOpp5 = new Opportunity();
        parentOpp5.Name = 'testOpportunity11';
        parentOpp5.StageName = 'Open';
        parentOpp5.CloseDate = system.today() + 30;
        parentOpp5.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        parentOpp5.DFC_Release_Month_Master__c = 3;
        parentOpp5.Product_Type__c = 'Sponsorship';
        parentOpp5.Product_Sub_Type__c = 'Other Contribution';
        parentOpp5.rC_Giving__Hard_Credit_Contact__c = contact1.Id;
        parentOpp5.Paid_Through_Date__c = System.today().addDays(-190);
        parentOpp5.rC_Giving__Is_Sustainer__c=true;
   //     parentOpp.Number_Months_Delinquent__c=4;
       opp.add(parentOpp5);
       insert opp;
        
    }
    
}