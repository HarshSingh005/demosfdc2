/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AdjustSuspenseToCGNBatchTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the AdjustSuspenseToCGNBatch
 * Created Date : 03/06/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/06/2016                   Munib Ur Rehman         Created
 * 07/21/2016                   Ravi Chauhan            Modified | used TestUtil for Data Creation
 * 17/01/2017					Suminder Singh			Fixed for errors
 **********************************************************************************************************/
@isTest
public with sharing class AdjustSuspenseToCGNBatchTest {

 	final static String ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
  	final static String ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    final static String ACC_COM_RT=  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    final static String CON_PR_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    final static String oppDonationRecTypIde = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    static Account nationalOffice, localPartner, community;
    static Contact participant;

   
    
    //create account and contact data
    @isTest
    public static void testUpdateLocalPartnerNationalOffice()
    {
           rC_Giving__Contact_Setting__c settings = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
       settings.rC_Giving__Disable_RollupHardCredits__c = true; 
       upsert settings ;
        
        Account acc = TestUtils.createAccount('Test Account',False);
        acc.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        insert acc;
        
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
        insert contact;
        
         rC_Giving__GAU__c testGAU = TestUtils.createGeneralAccountingUnit('600',false);
        testGAU.Receipt_Category__c='0600';
        insert testGAU;
      
        Opportunity opportunity = TestUtils.createOpportunity(acc,'Test Opportunity',null,False);
        opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        opportunity.AccountId = acc.Id;
        opportunity.Name = 'Test Opportunity';
        opportunity.StageName = 'Cultivation';
        opportunity.rC_Giving__Projected_Amount__c = 100;
        opportunity.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opportunity.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opportunity.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opportunity.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        opportunity.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opportunity.Core_Program_Infants__c = true;
        opportunity.rC_Giving__GAU__c = testGAU.Id;        
        opportunity.rC_Giving__Is_Sustainer__c = true;
        opportunity.rC_Giving__Anniversary_Date__c = system.today();
        insert opportunity;
        
        Opportunity opp = TestUtils.createOpportunity(acc,'Test Opportunity1',null,False);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        opp.StageName = 'Cultivation';
        opp.rC_Giving__Projected_Amount__c = 100;
        opp.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opp.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opp.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opp.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        opp.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opp.Core_Program_Infants__c = true;
        opp.Date_of_Distribution__c = system.today().addDays(-150);
        opp.rC_Giving__Parent__c = opportunity.Id;
        opp.Remaining_Non_Adjusted__c = 10;        
        opp.rC_Giving__Is_Sustainer__c = true;
        opp.rC_Giving__Anniversary_Date__c = system.today();
        insert opp;
        
        String RT_TRANSACTION = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        
        List<Opportunity> oppList = [select Id, rC_Giving__GAU__r.Name, Date_of_Distribution__c , Remaining_Non_Adjusted__c, RecordTypeId from Opportunity 
            WHERE
            Date_of_Distribution__c < LAST_N_DAYS:90
            AND rC_Giving__Parent__r.rC_Giving__GAU__c = :testGAU.Id
            AND Remaining_Non_Adjusted__c > 0
            AND RecordTypeId = :RT_TRANSACTION];            
            System.assertEquals(oppList.size(),1);
            system.assertNotEquals([SELECT Receipt_Category__c, Id FROM rC_Giving__GAU__c where Receipt_Category__c IN ('0600', '0302') ].ID,null);
        //test starts
        Test.startTest();
        Database.executebatch(new AdjustSuspenseToCGNBatch());
		//test stops        
        Test.stopTest();
         
    }
    
} // END public with sharing class MCSCPRRequestTest