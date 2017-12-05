/***********************************************************************************************************
* Appirio, Inc
* Name         : AGPReminderEmailDonationsControllerTest
* Created By   : Ravi Chauhan (Appirio)
* Purpose      : Test class for AGPReminderEmailDonationsListController
* Created Date : 22/June/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 06/22/2016                   Ravi Chauhan            Created
* 08/11/2016                   Ravi Chauhan            Improved creation of data
* 16/1/2016					   Suminder Singh		   Fixed for errors and code coverage
**********************************************************************************************************/

@isTest
private class AGPReminderEmailDonationsControllerTest {
    
    // Declaring all static variable for Account Record types
    Final Static Id nationalAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id localAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id commAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static String childFundRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
    
    // Declaring static variable for contact Record types
    Final Static Id conParticipantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    
    // Declaring static variable for Payment Method Record types
    Final Static Id paypalPaymentMethodRecordType = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Paypal').getRecordTypeId();
    
    // Declaring static variable for Opportunity Record types
    Final Static Id transactionOpportunityRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    Final Static Id oppDonationRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    
    //Declaring static variable for test class
    Static Account acc, acNat, acLoc, acCom, acc1;
    Static Contact con3, con4;
    Static Campaign testCamp;
    Static Opportunity parentOpp, opportunity;
    Static rC_Giving__Payment_Method__c testPaymentMethod;
    
    private static testMethod void testAGPReminderEmailDonationsControllerCreation(){
        // Creation of Test Data
        setUpTestData(); 
        
        // Creation of controller object
        Test.StartTest();
        AGPReminderEmailDonationsListController testObj = new AGPReminderEmailDonationsListController();
        testObj.hardCreditContactId = con3.id;        
        Test.StopTest();        
        
		// Assertion of the field set in donations and hardCreditContactId field
        System.assertEquals(null, testObj.hardCreditContactId);
        System.assertEquals(opportunity.Id, testObj.donations.get(0).Id);        
    }
    
    static void setUpTestData(){        
        
        rC_Giving__Contact_Setting__c settings = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        settings.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert settings ;


        // Creation of Account Records
        
        List<Account> accountsToBeInsertedList = new List<Account>();
        
        acNat = TestUtils.createAccountWithRT('Test National', nationalAccRecId, null,'909', '1321', false );
        accountsToBeInsertedList.add(acNat);
        
        acc = TestUtils.createAccount('test', false);
        accountsToBeInsertedList.add(acc);
        
        acc1 = TestUtils.createAccountWithRT('Test Account', childFundRT, null, '666','1221', false);
        accountsToBeInsertedList.add(acc1);
        
        insert accountsToBeInsertedList;
        
        acLoc = TestUtils.createAccountWithRT('Test Local', localAccRecId, acNat, '908', '1331', false);
        acLoc.Local_Partner_ID__c = '1234567';
        insert acLoc;
        
        acCom = TestUtils.createAccountWithRT('Test Comm', commAccRecId, acLoc ,'321','9099' , true);
        
        // Creation of Contact Records
        List<Contact> contactsToBeInsertedList = new List<Contact>();
        con3 = TestUtils.createContact(acc ,'Test First Name', 'Test Last Name', false);
        con3.National_Office__c = acNat.Id;
        con3.RecordTypeId = conParticipantRecId;
        con3.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        con3.rC_Bios__Preferred_Phone__c = 'Home';
        con3.HomePhone = '020-2656768';
        con3.rC_Bios__Preferred_Email__c = 'Home';
        con3.rC_Bios__Home_Email__c = 'test@gmail.com';
        con3.Lifetime_Amount__c = 1000;
        con3.Last_Gift_Amount__c = 100;
        con3.Largest_Gift_Amount__c = 500;
        con3.Largest_Gift_Date__c = date.today();
        con3.rC_Giving__Track_Hard_Credits__c = true;
        con3.Accept_DF_Fee__c = true;
        con3.Donor_Alliance__c = acc1.Id;
        con3.Participant_Case_Number__c = '90999';
        contactsToBeInsertedList.add(con3);

        con4 = TestUtils.createContact(acc ,'Test First Name', 'Test Last Name', false);
        con4.National_Office__c = acNat.Id;
        con4.RecordTypeId = conParticipantRecId;
        con4.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        con4.rC_Bios__Preferred_Phone__c = 'Home';
        con4.HomePhone = '020-2656768';
        con4.rC_Bios__Preferred_Email__c = 'Home';
        con4.rC_Bios__Home_Email__c = 'test@gmail.com';
        con4.Lifetime_Amount__c = 1000;
        con4.Last_Gift_Amount__c = 100;
        con4.Largest_Gift_Amount__c = 500;
        con4.Largest_Gift_Date__c = date.today();
        con4.rC_Giving__Track_Hard_Credits__c = true;
        con4.Accept_DF_Fee__c = true;
        con4.Donor_Alliance__c = acc1.Id;
        con4.Participant_Case_Number__c = '90998';
        contactsToBeInsertedList.add(con4);
        
        // Insertion of List<Contact>
        insert contactsToBeInsertedList;
        
        // Creation of Campaign Record
        
        testCamp = TestUtils.createCampaign('718 - DFC Fee' , false);
        testCamp.IsActive = true;
        testCamp.ActualCost = 100;
        testCamp.Product_Type__c = 'One Time Gift';
        testCamp.Product_Sub_Type__c = 'DFC Fee';
        insert testCamp;
        
        rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('600',true);
        
        // Creating Payment Method
        testPaymentMethod = TestUtils.createPaymentMethod('Test Payment','Paypal',true,acc,false);
        testPaymentMethod.RecordTypeId = paypalPaymentMethodRecordType;
        insert testPaymentMethod;
        
        // Creation of Opportunity Records
        parentOpp = TestUtils.createOpportunity(acc,'testOpportunity',100, false);
        //parentOpp.StageName = 'Open';
        //parentOpp.CloseDate = system.today() + 30;
        parentOpp.recordTypeId  = oppDonationRecType;
        parentOpp.Participant__c = con3.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        parentOpp.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        parentOpp.rC_Giving__Hard_Credit_Contact__c = con4.Id;
        parentOpp.rC_Giving__Giving_Amount__c = 100;
        parentOpp.Legacy_Type__c = 'Term';
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.Product_Type__c = 'Designated Fund';
        parentOpp.rC_Giving__Giving_Frequency__c = 'Annually';
        parentOpp.rC_Giving__Payment_Method__c ='Paypal';
        parentOpp.rC_Giving__Payment_Method_Selected__c = testPaymentMethod.Id;        
        insert parentOpp;
        
        opportunity = TestUtils.createOpportunity(acc,'testOpportunity',100, false);
        opportunity.RecordTypeId = transactionOpportunityRecordType;
        opportunity.StageName = 'Cultivation';
        opportunity.rC_Giving__Projected_Amount__c = 100;
        opportunity.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opportunity.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opportunity.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opportunity.rC_Giving__Hard_Credit_Contact__c = con3.Id;
        opportunity.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opportunity.Core_Program_Infants__c = true;
        opportunity.rC_Giving__Parent__c = parentOpp.Id;
        opportunity.rC_Giving__Primary_Contact__c = con4.Id;
        opportunity.CloseDate = Date.today().addDays(5);
        opportunity.Auto_Assign_Preference__c = true;
        insert opportunity;

    }    
    
}