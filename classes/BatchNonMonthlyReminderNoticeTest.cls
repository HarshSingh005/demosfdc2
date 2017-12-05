/***********************************************************************************************************
* Appirio, Inc
* Name         : BatchNonMonthlyReminderNoticeTest
* Created By   : Ravi Chauhan (Appirio)
* Purpose      : Test class for the BatchNonMonthlyReminderNotice
* Created Date : 01/12/2017
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 01/12/2017                  	Ravi Chauhan            Created 
**********************************************************************************************************/
@isTest
public class BatchNonMonthlyReminderNoticeTest {
    
    @isTest
    public static void testBatchMethod(){
        // Creation of Test Data
        createTestData();

        Test.startTest();
        
        // Assertion before exceution of the batch that there are no records of PrintQueue
        List<Print_Queue__c> printQueueList = [SELECT id,Letter_ID__c FROM Print_Queue__c];
        System.assertEquals(0, printQueueList.size());
        
        // Execution of the batch BatchNonMonthlyReminderNotice to pick the opoortunity as per criteria mentioned in start method
        Database.executebatch(new BatchNonMonthlyReminderNotice());
        
        Test.stopTest();
    }
    
    private static void createTestData(){
        rC_Giving__Contact_Setting__c settings = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        settings.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert settings ;
        
        Account acc = TestUtils.createAccount('Test Account',False);
        acc.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        insert acc;
        
        Account childfundAcc = TestUtils.createAccount('Alliance Account',False);
        childfundAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
        childfundAcc.Type = 'Alliance Partner';
        insert childfundAcc;
        
        Contact contact = TestUtils.createContact(acc,'Test First Name','Test Last Name',False);
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
        contact.Donor_Alliance__c = childfundAcc.Id;
        insert contact;
        
        rC_Giving__GAU__c testGAU = TestUtils.createGeneralAccountingUnit('600',false);
        testGAU.Receipt_Category__c='0600';
        insert testGAU;
        
        Opportunity opportunity = TestUtils.createOpportunity(acc,'Test Opportunity',null,False);
        opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        opportunity.AccountId = acc.Id;
        opportunity.Name = 'Test Opportunity';
        opportunity.StageName = 'Open';
        opportunity.rC_Giving__Projected_Amount__c = 100;
        opportunity.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opportunity.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opportunity.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opportunity.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        opportunity.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opportunity.Core_Program_Infants__c = true;
        opportunity.rC_Giving__GAU__c = testGAU.Id;
        opportunity.rC_Giving__Giving_Frequency__c = 'Annually';
        opportunity.rC_Giving__Hard_Credit_Account__c = acc.Id;
        opportunity.rC_Giving__Is_Sustainer__c = true;
        opportunity.Paid_Through_Date__c = System.today().addMonths(1);
        
        insert opportunity;

    }
    
}