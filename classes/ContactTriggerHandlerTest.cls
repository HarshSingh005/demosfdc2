/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ContactTriggerHandlerTest
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Test class for the ContactTriggerHandler
 * Created Date : 12/11/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 12/11/2015                   Karl Houseknecht        Created
 * 20/01/2016                   Shailendra Singh        Added test method for ContactTriggerHandler.createMCSForSponsoredChild
 * 27/01/2016                   Munib Ur Rehman         Updated test methods for ContactTriggerHandler.createMCSForSponsoredChild
 * 30/03/2016                   Jagjeet Singh           Updated test methods and created new ones for the ContactTriggerHandler
 * 22/06/2016                   Ashu Gupta              Updated test methods as per Coding standards and increased the code coverage
 * 19/07/2016                   Kanika Mathur           Updated test methods for test class failure and increased the code coverage
 * 16/08/2016                   Vaibhav Goel            Updated test methods by optimizing test data creation and utilizing TestUtils class methods.
 * 17/08/2016                   Vaibhav Goel            Ramp-up of code coverage 
 * 20/08/2016                   Ashu Gupta              Added RSAChildUpdateLettersTest2 and RSAChildUpdateLettersTest method to increase code coverage
 * 05/Sep/2016                  Ashu Gupta              Added testContactOwnerId() for T-514023
 * 13/09/2016                   Sahil Rathore           Testclass failed as contactowner id should be equal to userid and Created new opportunity and increased code coverage to 92%.
 * 03/21/2017					Suminder Singh			Fixed for errors and code coverage
 * 03/Apr/2017					Suminder Singh			Fixed for errors and code coverage
 * 05/Apr/2017					Suminder Singh			Increased code coverage 
 **********************************************************************************************************/
@isTest(seeAllData=true) //because of NGOC custom settings
public class ContactTriggerHandlerTest 
{
    Final Static Id transactionRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    Final Static Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    Final Static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('0 - Master Case').getRecordTypeId();
    static Account  acc, acc2,nationalOffice,localPartner,community,communityTest;
    static Opportunity parentOpp, testOpp1;
    static Contact contact1,participant,participant1,participant2,HouseholdParticipant;
    static  rC_Giving__GAU__c testGAU;
    static List<contact> conList;
    static User u;
   
    private static testMethod void testUpdateLocalPartnerNationalOffice()
    {
       //create the test data
       createTestData(); 
       Test.startTest();
       
        //participant = [select id, AccountId, National_Office__c, Local_Partner__c, Community__c from Contact where id = : conList.get(0).Id limit 1];
        contact c  = [select id, AccountId, National_Office__c, Local_Partner__c, Community__c from Contact where id = : conList.get(0).Id limit 1];
        system.assertEquals(nationalOffice.id, c.National_Office__c, 'The National Office is not the expected value.');
        system.assertEquals(localPartner.id, c.Local_Partner__c, 'The Local Partner is not the expected value.');
        system.assertEquals(community.id, c.AccountId, 'The AccountId should be the same as Community when AccountId not supplied on create or update.');       
        c.Community__c = null;
        update c;
        System.debug('@@@Comm'+c.Community__c);
        c = [select id, AccountId, National_Office__c, Local_Partner__c, Community__c from Contact where id = : conList.get(0).Id limit 1];
        system.assertEquals(null, c.National_Office__c, 'The National Office should be null when no Community specified.');
        system.assertEquals(null, c.Local_Partner__c, 'The Local Partner should be null when no Community specified.');
        
        c.Community__c = community.id;
        update c;
        System.debug('@@@Comm2'+c.Community__c);
        c = [select id, National_Office__c, Local_Partner__c, Community__c from Contact where id = : conList.get(0).Id limit 1];
        system.assertEquals(nationalOffice.id, c.National_Office__c, 'The National Office is not the expected value.');
        system.assertEquals(localPartner.id, c.Local_Partner__c, 'The Local Partner is not the expected value.');
        
        test.stopTest();
    }
    
    private static testMethod void testCreateMCSForSponsoredChild() {
        createTestData();
        Test.startTest();
        
        checkRecursive.runContactOnce = false;
        System.debug('Contact sponsership status 1 @@@ '+conList.get(1).rC_Sponsorship__Sponsorship_Status__c);
        //System.assert(participant1.rC_Sponsorship__Sponsorship_Status__c == 'Pre-Sponsored');
        conList.get(1).rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        conList.get(1).Correspondence_Paused__c = false;
        update conList.get(1);
        
        System.debug('Contact sponsership status 2 @@@@ '+conList.get(1).rC_Sponsorship__Sponsorship_Status__c);
        
        List<Mail_Control_Slip__c> mcsList = [Select ID from Mail_Control_Slip__c Where Participant__c =: conList.get(1).Id];
        System.debug('mcsList@@@'+mcsList);
        
        List<Opportunity> testOppList = [select Id, StageName from Opportunity where rC_Giving__Hard_Credit_Contact__c = : conList.get(1).Id limit 1];
        System.assertEquals(0, testOppList.size());
        
        Test.stopTest();
        
    }
    
    private static testMethod void departChildTest() {
       
        createTestData();
        
        Test.startTest();
        System.debug('=========participant2.Departed__c========='+ participant2.Departed__c + '=====' + participant2.Id);
        System.debug('=========conList.get(2).Departed__c======='+ conList.get(2).Departed__c + + '=====' + conList.get(2).Id);
        
        /*
        participant2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant2.Correspondence_Paused__c = true;
        participant2.Departed__c = true;
        //added the below statement to bypass the check of onAfterUpdate method.
        checkRecursive.runContactOnce = false;
        update participant2;
        */
        
        checkRecursive.runContactOnce = false;
        contact c = [select id, name, rC_Sponsorship__Sponsorship_Status__c, Correspondence_Paused__c, Departed__c from contact where id = :conList.get(2).Id limit 1];
        System.debug('=========c.Departed__c========='+ c.Departed__c + + '=====' + c.Id);
        c.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        c.Correspondence_Paused__c = true;
        c.Departed__c = true;
        update c;
        
        Opportunity op = [Select id, rC_Sponsorship__Sponsorship_Status_Reason__c from Opportunity where Participant__c =:  conList.get(2).Id limit 1];
        
        system.assertNotEquals('Participant Change', op.rC_Sponsorship__Sponsorship_Status_Reason__c );
        
        Test.stopTest();
        
        
    }
    
    private static testMethod void RSAChildUpdateLettersTest() {
       
        createTestData();
        
        Test.startTest();
        checkRecursive.runContactOnce = false;
        contact c = [select id, name, FirstName from contact where id = :conList.get(2).Id limit 1];
        
        c.FirstName = 'Ana';
        
        update c;
        List<Print_Queue__c> listPq = [SELECT id,Letter_ID__c,Prior_Participant_ID__c FROM Print_Queue__c]; 
        System.assertEquals(listPq.size()>0, true);
       Test.stopTest();
        
        
    }
    private static testMethod void RSAChildUpdateLettersTest2() {
       
        createTestData();
        
        Test.startTest();
        
       
        
        checkRecursive.runContactOnce = false;
        contact c = [select id,Birthdate,rC_Bios__Gender__c  from contact where id = :conList.get(2).Id limit 1];
        
        c.rC_Bios__Birth_Day__c  = '12';
        c.rC_Bios__Birth_Month__c = '04';
        c.rC_Bios__Birth_Year__c='2012';
        update c;
        
        checkRecursive.runContactOnce = false;
        c.rC_Bios__Gender__c = 'Male';
        update c;
        List<Print_Queue__c> listPq = [SELECT id,Letter_ID__c,Prior_Participant_ID__c FROM Print_Queue__c]; 
        System.assertEquals(listPq.size()>0, true);
       Test.stopTest();
        
        
    }
    
    private static testMethod void updateParticipantContactToReservedTest() {

        createTestData();

        Test.startTest();
        
        contact c = conList.get(1);
        c.Community__c = community.Id;
        c.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        update c;
        
        Contact testConAfterUpdate = [select id, name, rC_Sponsorship__Sponsorship_Status__c from contact where id = : conList.get(1).Id limit 1];
        system.assertEquals('Reserved', testConAfterUpdate.rC_Sponsorship__Sponsorship_Status__c);
        
        Test.stopTest();

   }

   private static testMethod void updateAccountRollUpsUpdateTest() {

        createTestData();

        Test.startTest();
        
        //participant1.Community__c = community.Id;
        conList.get(1).Community__c = community.Id;
        
        //participant1.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        //added the below statement to bypass the check of onAfterUpdate method.
        checkRecursive.runContactOnce = false;
        update participant1;

        Test.stopTest();
   }
    
    public static testMethod void UpdateCaseTest() {
       
        createTestData();
        Test.startTest();
        HouseholdParticipant.AccountId = acc2.Id;
        //
        checkRecursive.runContactOnce = false;
        update HouseholdParticipant;
        
        Test.stopTest();
        Case cse = [SELECT id,AccountID FROM Case WHERE Contactid =:HouseholdParticipant.id LIMIT 1];
        system.assertEquals(cse.AccountID,HouseholdParticipant.AccountID);
    }
    
    private static testMethod void testContactCancelDFCFee() {
    
    
        //create the test data
        createTestData();
        //start Test
        Test.startTest();
        checkRecursive.runContactOnce = false;
        contact1.Accept_DF_Fee__c = false;
        update contact1;
       
        Opportunity opp = [select Id, StageName from Opportunity where Id = :parentOpp.Id];
        System.assertEquals(opp.StageName, 'Canceled');
        Test.stopTest();
        
    }
    
    
    
    //Vaibhav Goel 08/01/2016 test method to cover the createMCSForSponsoredChild Method coverage 
   private static testMethod void testcreateMCSForSponsoredChild1() {
    
        //create the test data
        //start Test
        Test.startTest();
        
        //creating test data locally for this test-method 
        acc = TestUtils.createAccount('My Unit test', true);
        
        Contact testCon = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        testCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        testCon.rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored';
        testCon.Participant_Case_Number__c = '12345';
        testCon.Correspondence_Paused__c = true;
        testCon.Accept_DF_Fee__c = true;
        insert testCon;
        
        Opportunity testOpp = TestUtils.createOpportunity(acc,'testOpportunity3',100,false);
        testOpp.recordTypeId  = transactionRecordId;
        testOpp.Participant__c = testCon.Id;
        testOpp.rC_Giving__Hard_Credit_Contact__c =  testCon.Id; 
        testOpp.rC_Giving__Giving_Amount__c = 100;
        testOpp.Legacy_Type__c = null;
        testOpp.DFC_Status__c = 'Auto Fee';
        testOpp.StageName = 'Open';
        insert testOpp;
        system.debug('----testOpp---' + [select Id, StageName from Opportunity where rC_Giving__Hard_Credit_Contact__c = :testCon.id
                                         AND RecordType.Id = :transactionRecordId AND DFC_Status__c = 'Auto Fee' AND StageName = 'Open' limit 1]);
        
        
        system.debug('---testCon---' + testCon);
        
        
        testCon.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        testCon.Correspondence_Paused__c = false;
        testCon.Accept_DF_Fee__c = false;
        testCon.FirstName = 'Ana';
        update testCon;
        system.debug('---testConAfterupdate---' + testCon);
        system.debug('---testConAfterupdateSOQL---' + [Select Id, name,Accept_DF_Fee__c, rC_Sponsorship__Sponsorship_Status__c, Correspondence_Paused__c from contact where id =: testCon.Id limit 1]);
        
        Opportunity opp = [select Id, StageName from Opportunity where Id = :testOpp.Id];
        System.assertNotEquals(opp.StageName, 'Canceled');
        Test.stopTest();
        
    }
 
 
    private static testMethod void testContactOwnerId() {
            createTestData();
            localPartner.Participant_Contact_Owner__c = u.id;
            update localPartner;
            participant.Local_Partner__c = localPartner.id;
            participant.National_Office__c = nationalOffice.id;
            update participant;
            
            
            participant.Community__c = communityTest.id;
            update participant;
            
            Contact con = [SELECT id,ownerId FROM Contact WHERE id =: participant.id];
            
            System.assertEquals(con.ownerId,localPartner.Participant_Contact_Owner__c);
 
     
 }
    
    static void createTestData(){
        
        String childFundRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
        Campaign testCamp = TestUtils.createCampaign('test camp',false);
        testCamp.Product_Type__c='Designated Fund';
        insert testCamp;
        List<Account> accList = new List<Account>();
        acc = TestUtils.createAccount('My Unit test', false);
        accList.add(acc);
        acc2 = TestUtils.createAccount('My Unit test2', false);
        accList.add(acc2);
        
        
        
        Account acc3 = TestUtils.createAccountWithRT('Test NO Account CF', childFundRT, null, null, '1345', false);
        accList.add(acc3);
        
        insert accList;
        
        nationalOffice = TestUtils.createAccount('National Office',false);
        nationalOffice.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        nationalOffice.National_Office_Id__c = '898';//added as 3 digit national office  Id necessary
        insert nationalOffice;
        
        localPartner = TestUtils.createAccount('Local Partner',false);
        localPartner.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        localPartner.ParentId = nationalOffice.Id;
        insert localPartner;
        
        rC_Sponsorship__Reserve__c reserve = TestUtils.createSponsorshipReserve('Website Shopping Cart Reserve', false);
        reserve.rC_Sponsorship__Status__c = 'Draft';//Updated on 03/21/17 - Suminder Singh
        reserve.rC_Sponsorship__Start_Date__c = System.now().date().addDays(-365);
        reserve.rC_Sponsorship__Expiration_Date__c = System.now().date().addDays(365);
        insert reserve;
        
        List<Account> listAcc = new List<Account>();
        community = TestUtils.createAccount('Community',false);
        community.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community.ParentId = localPartner.Id;
        community.Community_Id__c = '3456'; // added as 4 digit community Id necessary
        community.Dedicated_Reserve__c = reserve.Id;
        community.Dedicated_to_Alliance__c = acc3.Id;
        listAcc.add(community);
        
        communityTest = TestUtils.createAccount('CommunityTest',false);
        communityTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        communityTest.ParentId = localPartner.Id;
        communityTest.Community_Id__c = '9567'; // added as 4 digit community Id necessary
        communityTest.Dedicated_Reserve__c = reserve.Id;
        communityTest.Dedicated_to_Alliance__c = acc3.Id;
        listAcc.add(communityTest);
        insert listAcc;
        
        contact1 = TestUtils.createContact(acc,'Test First Name','Test Last Name',false);
        contact1.RecordTypeId = Contact_SnapshotController.CONTACT_RECORDTYPE_HOUSEHOLD;
        contact1.Accept_DF_Fee__c = true;
        insert contact1;
        
        conList = new List<contact>();
        
        participant = TestUtils.createContact(null, 'Joe', 'Kid', false);new Contact();
        participant.Community__c = community.id;
        participant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        participant.Participant_Case_Number__c = '87654'; // added as 5 digit participant case number necessary
        conList.add(participant);
        //insert participant;
        
        participant1 = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participant1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        participant1.rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored';
        participant1.Participant_Case_Number__c = '12345';
        participant1.Correspondence_Paused__c = true;
        conList.add(participant1);
        //insert participant1;
        
        participant2 = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participant2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        participant2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant2.Correspondence_Paused__c = false;
        participant2.Participant_Case_Number__c = '12335';
        participant2.Departed__c = false;
        //participant2.Birthdate = System.today().addDays(10);
        conList.add(participant2);
        insert conList;
        
        conList.sort();
        
        system.debug('@@@conList---' + conList.get(0));
        
        //insert participant2; 
        
        HouseholdParticipant = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        HouseholdParticipant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        HouseholdParticipant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        HouseholdParticipant.Correspondence_Paused__c = false;
        HouseholdParticipant.Participant_Case_Number__c = '12345';
        insert HouseholdParticipant;  
        
        testGAU = TestUtils.createGeneralAccountingUnit('718',true);
        
        parentOpp = TestUtils.createOpportunity(acc,'testOpportunity',1000,false);
        parentOpp.recordTypeId = transactionRecordId;
        parentOpp.rC_Giving__Hard_Credit_Contact__c = contact1.Id;
        parentOpp.rC_Giving__GAU__c = testGAU.Id;
        parentOpp.CloseDate = system.today() + 30;
        parentOpp.DFC_Status__c = 'Auto Fee';
        //parentOpp.StageName = 'Open';
        insert parentOpp; 
        
       /* testOpp1 = TestUtils.createOpportunity(acc,'testOpportunity',1000,false);
        testOpp1.recordTypeId = transactionRecordId;
        insert testOpp1;*/
        
        List<Opportunity> listOfOpp = new List<Opportunity>();
        
        Opportunity testOpp = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        testOpp.recordTypeId  = oppDonationRecTypeId;
        //testOpp.Participant__c = participant2.Id;
        testOpp.Participant__c = conList.get(2).Id;
        testOpp.CampaignId = testCamp.Id;
        testOpp.rC_Giving__Giving_Amount__c = 100;
        testOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        testOpp.Product_Type__c = 'Sponsorship';
        testOpp.rC_Giving__Is_Sustainer__c = true;
        listOfOpp.add(testOpp);
        
        Opportunity testOpp2 = TestUtils.createOpportunity(acc,'testOpportunity2',100,false);
       
        testOpp2.recordTypeId  = oppDonationRecTypeId;
        //testOpp2.Participant__c =  participant2.Id;
        testOpp2.Participant__c =  conList.get(2).Id;
        testOpp2.CampaignId = testCamp.Id;
        testOpp2.rC_Giving__Giving_Amount__c = 100;
        testOpp2.Legacy_Type__c = 'Perpetual';
        testOpp2.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        testOpp2.Product_Type__c = 'Sponsorship';
        testOpp2.rC_Giving__Is_Sustainer__c = true;
        listOfOpp.add(testOpp2);
        
        
        Opportunity testOpp3 = TestUtils.createOpportunity(acc,'testOpportunity3',100,false);
        testOpp3.recordTypeId  = oppDonationRecTypeId;
        //testOpp3.Participant__c =  participant2.Id;
        testOpp3.Participant__c =  conList.get(2).Id;
        testOpp3.CampaignId = testCamp.Id;
        testOpp3.rC_Giving__Giving_Amount__c = 100;
        testOpp3.Legacy_Type__c = null;
        testOpp3.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        testOpp3.Product_Type__c = 'Sponsorship';
        testOpp3.rC_Giving__Is_Sustainer__c = true;
        listOfOpp.add(testOpp3);
        
        //insert listOfOpp;
        Opportunity testOpp4 = TestUtils.createOpportunity(acc,'testOpportunity4',100,false);
        testOpp4.recordTypeId  = oppDonationRecTypeId;
        //testOpp3.Participant__c =  participant2.Id;
        testOpp4.Participant__c =  conList.get(2).Id;
        testOpp4.CampaignId = testCamp.Id;
        testOpp4.rC_Giving__Giving_Amount__c = 100;
        testOpp4.Legacy_Type__c = null;
        testOpp4.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        testOpp4.Product_Type__c = 'Sponsorship';
        testOpp4.rC_Giving__Is_Sustainer__c = true;
        testOpp4.CFI_Do_Not_Substitute__c='Do Not Substitute - Contact Donor';
        testOpp4.Do_Not_Sub_Reason__c='Rebranding';
       
         listOfOpp.add(testOpp4);
        
        insert listOfOpp;
      
        Case caseInstance = TestUtils.createCase(caseRecordTypeId,'Open','High','Temp',false);
        caseInstance.contactId = HouseholdParticipant.id;
        insert caseInstance;   
        
        //Added by Ashu Gupta for testContactOwnerId
        Profile p = TestUtils.getProfile('System Administrator');    
        u = TestUtils.createUser('TestAG','Gupta',p.id,true);   
   //Added by Sahil as contactowner id should be equal to userid     
        for (contact con : conList)
        {
            con.ownerId=u.id;
            
        }
        contact1.ownerId=u.id;
        
        update conList;
        update contact1;
        
            
    }
     
    
    
}