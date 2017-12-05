/***********************************************************************************************************
 * Appirio, Inc
 * Name         : LteServiceTest
 * Created By   : Vaibhav Goel (Appirio)
 * Purpose      : Test class for LteService
 * Created Date : 18/March/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/03/2016                   Vaibhav Goel            Handling test failures and test coverage ramp-up
 **********************************************************************************************************/
@isTest
private class LteServiceTest {
    
    // Declaring all static variable for Account Record types
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
	
	//Declaring static variable for contact Record types
	Final Static Id CON_HD_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
	Final Static Id CON_PT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
	
	//Declaring static variable for test class
	Static Account hhAccount, nationalOffice, localPartner, community;
	Static Contact con, hhCOn;
	Static Mail_Control_Slip__c mcs1, mcs2, mcs3; 
    Static List<Mail_Control_Slip__c> mcsList;
    Static Opportunity parentOpp, opp;
    
    
	private static testMethod void testingLteServiceMethods() {
        createTestData();
        system.debug('----mcs1---' + mcsList.get(0).Name);
        McsDetailInfo info = LteService.GetMcsDetailByID(mcsList.get(0).Name);
        system.assert(info != null);
        system.assertEquals(info.LetterTypeName, 'Child Progress Report');
        
        
        Boolean updated = LteService.CloseMcs(mcsList.get(0).Name);
        system.assertEquals(true, updated);
        
        Boolean updated1 = LteService.CloseMcs('random');
        system.assertEquals(false, updated1);

		LteService.GetMcsDetailByID('dgfg');
	}
	
	
	
	/* Method Name  :       testingCreateMcs
	*  Purpose      :       Test method for the method - CreateMcs() of class LteService
	*  Date Created :       April 29,2016
	*  Return Type  :       None
	*  
	*/
	private static testMethod void testingCreateMcs() {
	    
        createTestData();
        Contact partContact = [Select Id, Child_Number__c, Contact_Number__c from Contact where id =: con.Id];
        system.debug('---partContact---' + partContact);
        
        test.StartTest();

        McsDetailInfo info1 = LteService.CreateMcs(Enums.MCSLetterType.ChildWelcome, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info1 != null);
        
        McsDetailInfo info2 = LteService.CreateMcs(Enums.MCSLetterType.ChildBonding, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info2 != null);
        
        McsDetailInfo info3 = LteService.CreateMcs(Enums.MCSLetterType.ThankYou, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info3 != null);
        
        McsDetailInfo info4 = LteService.CreateMcs(Enums.MCSLetterType.Sponsor, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info4 != null);
        
        McsDetailInfo info5 = LteService.CreateMcs(Enums.MCSLetterType.ChildReply, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info5 != null);
        
        McsDetailInfo info6 = LteService.CreateMcs(Enums.MCSLetterType.ChildInitiated, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info6 != null);
        
        McsDetailInfo info7 = LteService.CreateMcs(Enums.MCSLetterType.ChildProgress, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info7 != null);
        
        McsDetailInfo info8 = LteService.CreateMcs(Enums.MCSLetterType.NationalDirectorWelcome, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info8 != null);
        
        McsDetailInfo info9 = LteService.CreateMcs(Enums.MCSLetterType.SubShiftNationalDirectorWelcome, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info9 != null);
        
        McsDetailInfo info10 = LteService.CreateMcs(Enums.MCSLetterType.ChildSpontaneous, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info10 != null);
        
        McsDetailInfo info11 = LteService.CreateMcs(Enums.MCSLetterType.ChildFarewell, Integer.ValueOf(partContact.Child_Number__c));
        system.assert(info11 != null);
        
        //Negative test result to get exception
        McsDetailInfo infoException = LteService.CreateMcs(Enums.MCSLetterType.ChildFarewell, 202020);
        system.assert(infoException != null);
        test.StopTest();
	}
    
	/* Method Name  :       testSendChildLetterNotificationEmail
	*  Purpose      :       Test method for the method - SendChildLetterNotificationEmail() of class LteService
	*  Date Created :       June 21,2016
	*  Return Type  :       None
	*  
	*/    
    private static testMethod void testSendChildLetterNotificationEmail(){
        
        test.StartTest();
        // Creating Test Data
        createTestData();
        
        
        // Fetching the Mail_Control_Slip__c record created during Test Data Creation
        Mail_Control_Slip__c testDataSlip = [SELECT id, name, donor__c, donor__r.Alliance_Donor__c, participant__c,Send_Your_Child_Sent_You_A_Letter_Email__c 
                                             FROM Mail_Control_Slip__c where MCS_Letter_Type__c = 'Child Reply Letter' LIMIT 1];        
        
        
        // Fetching the Opportunity record created during Test Data Creation
        Opportunity testDataOpportunity = [SELECT id, All_Child_Correspondence__c,rC_Giving__Primary_Contact__c,
                                           Participant__c,rC_Sponsorship__Sponsorship_Status__c
                                           FROM Opportunity 
                                           WHERE Name = 'Test Child Opp' LIMIT 1];
        
        // Setting the values of Opportunity as required in SendChildLetterNotificationEmail() method
        testDataOpportunity.rC_Giving__Primary_Contact__c = testDataSlip.Donor__c;
        testDataOpportunity.Participant__c = testDataSlip.Participant__c ;
        testDataOpportunity.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        testDataOpportunity.All_Child_Correspondence__c = false;
        update(testDataOpportunity);
        system.debug('---testDataSlip---' + testDataSlip);
        system.debug('---testDataOpportunityPostUpdate---' + testDataOpportunity);
        
        // Calling the SendChildLetterNotificationEmail() method with null argument to test exception scenario
        LteService.SendChildLetterNotificationEmail(null);
        System.assert(!testDataSlip.Send_Your_Child_Sent_You_A_Letter_Email__c);
        
        // Calling the SendChildLetterNotificationEmail() method with correct argument to test positive scenario
        LteService.SendChildLetterNotificationEmail(testDataSlip.Name);  
        test.StopTest();
        
        testDataSlip = [SELECT Send_Your_Child_Sent_You_A_Letter_Email__c 
                        FROM Mail_Control_Slip__c 
                        WHERE id = :testDataSlip.Id LIMIT 1];        
        // Assertion to check the value of Send_Your_Child_Sent_You_A_Letter_Email__c
        //the value will be false only even though it is being set as 'true' by code is beacuse of the WF rule - 'Your Child Sent You A Letter' on object 'Mail_Control_Slip__c'
        system.assertEquals(false, testDataSlip.Send_Your_Child_Sent_You_A_Letter_Email__c);
        
    }
    
    
    
    /* Method Name  :       testGetNewMcsID
	*  Purpose      :       Test method for the method - GetNewMcsID() of class LteService
	*  Date Created :       July 15,2016
	*  Return Type  :       None
	*  
	*/ 
	
	@isTest
    private static void testGetNewMcsID(){
        // Creating Test Data
        createTestData();
		Integer id = LteService.GetNewMcsID('ABC123');
		System.assertNotEquals(id, 0);

		id = LteService.GetNewMcsID('ABC1234');
		System.assertEquals(id, 0);
    }
    
    //creates the test data
    static void createTestData(){        

        //create account and contact data
        nationalOffice = TestUtils.createAccount('National Office', false);
        //nationalOffice.Name = 'National Office';
        nationalOffice.RecordTypeId = ACC_NO_RT;
        nationalOffice.National_Office_Id__c = '899';
        insert nationalOffice;
        system.debug('----nationalOffice----' + nationalOffice);
        
        localPartner = TestUtils.createAccount('Local Partner', false);
        //localPartner.Name = 'Local Partner';
        localPartner.RecordTypeId = ACC_LP_RT;
        localPartner.ParentId = nationalOffice.Id;
        localPartner.Local_Partner_ID__c = '1121145';
        insert localPartner;
        system.debug('----localPartner----' + localPartner);
        
        community = TestUtils.createAccount('Community', false);
        //community.Name = 'Community';
        community.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community.ParentId = localPartner.Id;
        community.Community_Id__c = '3457';
        insert community;
        system.debug('----community----' + community);
        
        hhAccount = TestUtils.createAccountWithRT('Test Household Account', ACC_HH_RT, community, '565', '21343', true);
        
        parentOpp = TestUtils.createOpportunity(nationalOffice, 'Test Parent Opp ' , 100000, false);
        parentOpp.rC_Giving__Current_Giving_Amount__c = 100;
        parentOpp.DFC_Description__c = 'testDescription';
        parentOpp.Product_Type__c = 'Designated Fund';
        insert parentOpp;
        system.debug('----parentOpp----' + parentOpp.Salesforce_Opportunity_Code__c);
        system.debug('----parentOpp----' + parentOpp.DFC_Description__c);
        system.debug('----parentOpp----' + parentOpp);
        
        opp = TestUtils.createOpportunity(nationalOffice, 'Test Child Opp ' , 100000, false);
        opp.rC_Giving__Current_Giving_Amount__c = 10;
        opp.rC_Giving__Parent__c = parentOpp.Id;
        opp.DFC_Description__c = 'testDescription';
        insert opp;
        system.debug('----opp----' + opp.Salesforce_Opportunity_Code__c);
        system.debug('----opp----' + opp.DFC_Description__c);
        system.debug('----opp----' + opp);
        
        List<Contact> conList = new List<Contact>();
         // creating contact record
        con = TestUtils.createContact(null, 'Joe', 'Kid', false);
        //con.FirstName = 'Joe';
        //con.LastName = 'Kid';
       // con.Community__c = community.id;
        con.RecordTypeId = CON_PT_RT;
        con.Participant_Case_Number__c = '87654';
        con.Local_Partner__c = localPartner.Id;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.National_Office__c = nationalOffice.Id;
        con.Village__c = 'villageTest';
        conList.add(con);
       // insert con;
        //system.debug('----con----' + con);
       	
       	
       	hhCOn = TestUtils.createContact(null, 'Joe', 'Household', false);
        //hhCOn.FirstName = 'Joe';
        //hhCOn.LastName = 'Household';
        //hhCOn.Community__c = community.id;
        hhCOn.RecordTypeId = CON_PT_RT;
        //hhCOn.Participant_Case_Number__c = '87655';
        //hhCOn.Local_Partner__c = localPartner.Id;
        //hhCOn.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        //hhCOn.National_Office__c = nationalOffice.Id;
        hhCOn.Village__c = 'villageTest1';
        hhCOn.mailingCity = 'testCity';
        hhCOn.mailingState = 'testState';
        hhCOn.mailingCountry = 'testCountry';
        hhCOn.mailingStreet = 'testStreet';
        hhCOn.mailingPostalCode = '12311';
        conList.add(hhCOn);
        //insert con1;
        system.debug('----hhCOn---' + hhCOn);
       	insert conList;
       	
       	//Fetching recently created Contact
       	Contact conn =  [select Id , rC_Volunteers__FullName__c , National_Office__r.Name , Community__r.Name, Local_Partner__r.Name from Contact where Participant_Case_Number__c = '87654' limit 1];
        system.debug('----conn----' + conn);
        
        List<Mail_Control_Slip__c> mailControlSlipList = new List<Mail_Control_Slip__c>();
        // creating Mail Control Slip record
        
        mcs1 = testUtils.createMailControlSlip(String.valueOf(hhCOn.Id), 'Child Progress Report', 'Active', conn.id, null, false);
        //mcs1.Participant__c = conn.id;	
        //cs1.MCS_Letter_Type__c = 'Child Progress Report';
        mcs1.MCS_Date__c = system.today().addDays(-20);
        mcs1.Due_Date__c = system.today();
        mcs1.Due_Date__c = system.today();
        mcs1.MCS_Letter_Code__c = '30';
        mcs1.Donor__c = hhCOn.Id;
        mcs1.DFC_Opportunity__c  = opp.Id;
        mcs1.MCS_Status__c = 'Active';
        mailControlSlipList.add(mcs1);
        //insert mcs1;
        
        mcs2 = testUtils.createMailControlSlip(String.valueOf(hhCOn.Id), 'Child Progress Report', 'Active', conn.id, null, false);
        //mcs2.Participant__c = conn.id;	
        //mcs2.MCS_Letter_Type__c = 'Child Progress Report';
        mcs2.MCS_Date__c = system.today().addDays(-20);
        mcs2.Due_Date__c = system.today();
        mcs2.MCS_Letter_Code__c = '30';        
        mcs2.Donor__c = hhCOn.Id;
        mcs2.DFC_Opportunity__c  = opp.Id;
        mcs2.Legacy_External_ID__c = 'ABC123';
        mcs2.MCS_Status__c = 'Active';
        mailControlSlipList.add(mcs2);
        //insert mcs2;
        
        // creating Mail Control Slip record
        mcs3 = testUtils.createMailControlSlip(String.valueOf(hhCOn.Id), 'Child Reply Letter', 'Active', conn.id, null, false);
        //mcs3.Participant__c = conn.id;	
        //mcs3.MCS_Letter_Type__c = 'Child Reply Letter';
        mcs3.MCS_Date__c = system.today().addDays(-20);
        mcs3.Due_Date__c = system.today();
        mcs3.Due_Date__c = system.today();
        mcs3.MCS_Letter_Code__c = '30';
        mcs3.Donor__c = hhCOn.Id;
        mcs3.DFC_Opportunity__c  = opp.Id;
        mcs3.MCS_Status__c = 'Active';
        mailControlSlipList.add(mcs3);
        //insert mcs3;
        insert mailControlSlipList;
        //mcsList = [select id, name, DFC_Opportunity__c, Participant__r.National_Office_Number__c, MCS_Letter_Code__c, MCS_Letter_Type__c, Child_NO__c, Donor_Number__c,
                    //Child_Number1__c, Donor_Name__c, Participant_Name__c, Donor__r.Email, Due_Date__c, Participant__r.Local_Partner__r.Local_Partner_ID__c,
                    //Local_Partner__c, Community_ID__c, MCS_Status__c, Case_Nbr__c, Gender__c, Village__c, Sponsor_Country__c, DFC_Number__c, DFC_Amount__c,
                    //DFC_Message__c, Birthdate__c from Mail_Control_Slip__c limit 2];
       mcsList = [select id, name, DFC_Opportunity__c, DFC_Number__c, DFC_Amount__c from Mail_Control_Slip__c limit 2];
       system.debug('---mcsList---' + mcsList);
    }
}