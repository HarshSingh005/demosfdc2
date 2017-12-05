/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MCSSlipPrintTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the MCSCPRRequestBatch
 * Created Date : 28/01/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 28/01/2016                   Munib Ur Rehman       Created
 * 09/04/2016                   Vaibhav Goel          Modified
 * 27/12/2016					Suminder Singh		  Increased code coverage
 * 03/04/2017                   Ravi Chauhan          Increased code coverage
 **********************************************************************************************************/
@isTest
public with sharing class MCSSlipPrintTest
{
	// Declaring all static variables in the beginning
	Static Account hhAccount, nationalOffice, localPartner, community1, community2;
	Static Contact con1, con2, con3;
	Static Mail_Control_Slip__c mcs1, mcs2; 
	Static Opportunity donationOpp, transactionOpp, opp;
	Final Static Id ACC_CF_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();

	//Declaring static variable for Opportunity Record types
	Final Static Id OPP_DON_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
	Final Static Id OPP_TRAN_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    
    
	@isTest
	public static void testMCSSlipPrint1() {
    	//setting up of all data 
    	setUpTestData();
    	
        // creating page reference for the page and mark it as current page
        PageReference pageRef = Page.MCSSlipPrint;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getHeaders().put('Host', 'visual.force');
        
        // calling standard controller 
        ApexPages.StandardController sc = new ApexPages.StandardController(mcs1);
        MCSSlipPrint cont = new MCSSlipPrint(sc);
        cont.NationOfficeName = nationalOffice.Name;
        cont.LocalPartnerName = localPartner.Name;
        cont.CommunityName = community1.Name;
        cont.selectedLetterType = 'Child Progress Report';
        
        
        // beginning Test
		Test.startTest(); // Test Starts
		
		Mail_Control_Slip__c mcsObj = new Mail_Control_Slip__c();
        mcsObj.Participant__c = con1.id;	
        mcsObj.MCS_Status__c = 'Active';
        mcsObj.MCS_Letter_Type__c = 'Child Progress Report';
        mcsObj.MCS_Date__c = system.today().addDays(-15);
        mcsObj.NO_Lookup__c = nationalOffice.Id;
        mcsObj.LP_Lookup__c = localPartner.Id;
        insert mcsObj;
        
        //System.assert(false,'RSC  ------ ' + [SELECT MCS_Letter_Type__c,MCS_Status__c,NO_Lookup__c,LP_Lookup__c,MCS_Date__c FROM Mail_Control_Slip__c WHERE ID = :mcsObj.ID]);
        
		// 1. Initially Test is done with Empty Filter
		//cont.isValidate = true;
		//cont.launchConga();
		//cont.showURL();
		//cont.buildURL_Report();
		
		//2. Filter is assigned the corresponding participant and mail control slip record
		cont.getletterTypes();
		cont.filter.mcs = mcs1;
		cont.filter.participant = con1;
		cont.launchConga();
		//system.assertEquals(1, cont.mcsListSize);
		//cont.showURL();
		system.assertEquals(mcs1.MCS_Letter_Type__c, cont.selectedLetterType);
		//system.assertNotEquals(null, cont.url1Token);
		//cont.buildURL_Report();
		
		//delete mcs2;
		//cont.filter.mcs = mcs1;
		//cont.filter.participant = con;
		//cont.launchConga();
		//cont.showURL();
		
		Test.stopTest();       // Test Stops
    } // END public static void testMCSSlipPrint() {
    
    @isTest
	public static void testMCSSlipPrintForDFRegister() {
    	
    	test.startTest();
    	//setting up of all data 
    	setUpTestData();
    	Campaign camp = TestUtils.createCampaign('TestCamp',false);
        camp.Product_Type__c = 'Designated Fund';
        camp.Product_Sub_Type__c = 'Child Sponsorship';
        insert camp;
        //Account acc = TestUtils.createAccount('Test', true);
    	//Contact con = TestUtils.createContact(acc, 'firstName','lastName', true);
    	donationOpp = TestUtils.createOpportunity(nationalOffice, 'Test Donation Opp ', 100000, false);
        //donationOpp.RecordTypeId = OPP_DON_RT;
        donationOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        donationOpp.Campaign = camp;
        donationOpp.Product_Type__c = 'Designated Fund';
        donationOpp.Product_Sub_Type__c = 'Graduation';
        donationOpp.Description__c = 'test Description';
        //donationOpp.rC_Giving__Hard_Credit_Contact__c = con1.id;
        insert donationOpp;
        system.debug('----donationOpp---' + donationOpp);
        
        transactionOpp = TestUtils.createOpportunity(nationalOffice, 'Test transaction Opp ', 100000, false);
        transactionOpp.RecordTypeId = OPP_TRAN_RT;
        transactionOpp.rC_Giving__Parent__c = donationOpp.Id;
        transactionOpp.CloseDate = system.today();
        insert transactionOpp;
        system.debug('----transactionOpp---' + transactionOpp);
        
    	//Test.startTest();
    	Test.stopTest();
        	List<Mail_Control_Slip__c> massList = new List<Mail_Control_Slip__c>();
            //for(Integer i = 0 ; i < 9001; i++){
            for(Integer i = 0 ; i < 2001; i++){
                Mail_Control_Slip__c mcsObj = new Mail_Control_Slip__c();
                //if(i < 3000){
                if(i < 1000){
                    mcsObj.Participant__c = con1.id;	    
                }else{
                    mcsObj.Participant__c = con2.id;	
                }
                mcsObj.MCS_Status__c = 'Active';
                mcsObj.DFC_Opportunity__c = transactionOpp.Id;
                mcsObj.MCS_Letter_Type__c = 'Thank You Letter For DF';
                mcsObj.MCS_Date__c = system.today().addDays(-20);
                mcsObj.Due_Date__c = system.today();
                mcsObj.NO_Lookup__c = nationalOffice.Id;
                mcsObj.LP_Lookup__c = localPartner.Id;
                massList.add(mcsObj);
            }
            insert massList;
            system.debug('----massList---' + massList.size());
            
            // creating page reference for the page and mark it as current page
            PageReference pageRef = Page.MCSSlipPrint;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getHeaders().put('Host', 'visual.force');
            ApexPages.currentPage().getParameters().put('sessionId', UserInfo.getSessionId());
    
            // calling standard controller 
            ApexPages.StandardController sc = new ApexPages.StandardController(mcs1);
            MCSSlipPrint cont = new MCSSlipPrint(sc);
            cont.NationOfficeName = nationalOffice.Name;
            cont.LocalPartnerName = '';
            cont.CommunityName = '';
            cont.selectedLetterType = 'Report - DF Register';
            
            mcs1.MCS_Letter_Type__c = 'Thank You Letter For DF';
    		update mcs1;
    		
            // beginning Test
    		 // Test Starts
    		
    		cont.getletterTypes();
    		cont.filter.mcs = mcs1;
    		cont.filter.participant = con3;
    		cont.launchConga();
    		//cont.showURL();
		//Test.stopTest();
		//system.assertEquals(2001, cont.mcsListSize);
		system.assertNotEquals(mcs1.MCS_Letter_Type__c, cont.selectedLetterType); //here - mcs has letter type = 'Thank You Letter For DF' but actual selection at UI would be = 'DF Register'
		//system.assertNotEquals(null, cont.url1Token);
		//system.assertNotEquals(null, cont.url2Token);
		//system.assertNotEquals(null, cont.url3Token);
		//system.assertNotEquals(null, cont.url4Token);
		//system.assertNotEquals(null, cont.url5Token);
		//system.assertNotEquals(null, cont.url6Token);
    } 
    
    // Below method covers the conditions for various months
    //test for private method monthName() of class MCSSlipPrint
    @isTest
	public static void testMCSSlipPrintForDFRegisterPart2() {
    	
    	//setting up of all data 
    	setUpTestData();
    	
    	donationOpp = TestUtils.createOpportunity(nationalOffice, 'Test Donation Opp ', 100000, false);
        donationOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        donationOpp.Product_Type__c = 'Designated Fund';
        donationOpp.Product_Sub_Type__c = 'Graduation';
        //donationOpp.rC_Giving__Hard_Credit_Contact__c = con1.id;
        //donationOpp.RecordTypeId = OPP_DON_RT;
        donationOpp.Description__c = 'test Description';
        insert donationOpp;
        system.debug('----donationOpp---' + donationOpp);
        
        transactionOpp = TestUtils.createOpportunity(nationalOffice, 'Test transaction Opp ', 100000, false);
        transactionOpp.RecordTypeId = OPP_TRAN_RT;
        transactionOpp.rC_Giving__Parent__c = donationOpp.Id;
        transactionOpp.CloseDate = system.today();
        insert transactionOpp;
        system.debug('----transactionOpp---' + transactionOpp);
        
    	Test.startTest();
        	List<Mail_Control_Slip__c> massList = new List<Mail_Control_Slip__c>();
            for(Integer i = 1 ; i <= 12; i++){
                Mail_Control_Slip__c mcsObj = new Mail_Control_Slip__c();
                mcsObj.Participant__c = con1.id;	    
                mcsObj.MCS_Status__c = 'Active';
                mcsObj.DFC_Opportunity__c = transactionOpp.Id;
                mcsObj.MCS_Letter_Type__c = 'Thank You Letter For DF';
                mcsObj.MCS_Date__c = system.today().addMonths(-i);
                mcsObj.Due_Date__c = system.today();
                mcsObj.NO_Lookup__c = nationalOffice.Id;
                mcsObj.LP_Lookup__c = localPartner.Id;
                system.debug('----mcsObj---' + mcsObj);
                massList.add(mcsObj);
            }
            insert massList;
            system.debug('----massList---' + massList.size());
            
            // creating page reference for the page and mark it as current page
            PageReference pageRef = Page.MCSSlipPrint;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getHeaders().put('Host', 'visual.force');
            ApexPages.currentPage().getParameters().put('sessionId', UserInfo.getSessionId());
    
            // calling standard controller 
            ApexPages.StandardController sc = new ApexPages.StandardController(mcs1);
            MCSSlipPrint cont = new MCSSlipPrint(sc);
            cont.NationOfficeName = nationalOffice.Name;
            cont.LocalPartnerName = '';
            cont.CommunityName = '';
            cont.selectedLetterType = 'Report - DF Register';
            
            mcs1.MCS_Letter_Type__c = 'Thank You Letter For DF';
            mcs1.MCS_Date__c = system.today().addYears(-4);
            mcs1.Due_Date__c = system.today();
            mcs1.MCS_Status__c = 'Active';
    		update mcs1;
    		system.debug('----mcs1---' + mcs1);
    		
            // beginning Test
    		 // Test Starts
    		
    		cont.getletterTypes();
    		cont.filter.mcs = mcs1;
    		cont.filter.participant = con3;
    		cont.launchConga();
    		//cont.showURL();
    		//cont.buildURL_Report();
    		
    		//testing for previous months
    		for(Integer i = 1 ; i <= 12; i++){
        		mcs1.MCS_Date__c = system.today().addMonths(-i);
        		update mcs1;
        		cont.filter.mcs = mcs1;
    		    cont.launchConga();
    		}
    		
		
		Test.stopTest();
		system.assertNotEquals(mcs1.MCS_Letter_Type__c, cont.selectedLetterType); //here - mcs has letter type = 'Thank You Letter For DF' but actual selection at UI would be = 'DF Register'
		//system.assertNotEquals(null, cont.url1Token);
    } 
    
    @isTest
	public static void testMCSSlipPrintForChildWelcomeLetter() {
    	
    	//setting up of all data 
    	setUpTestData();
    	Test.startTest();
            Mail_Control_Slip__c mcsObj = new Mail_Control_Slip__c();
            mcsObj.Participant__c = con1.id;	
            mcsObj.MCS_Status__c = 'Active';
            mcsObj.MCS_Letter_Type__c = 'Child Welcome Letter';
            mcsObj.MCS_Date__c = system.today().addDays(-20);
            mcsObj.Due_Date__c = system.today();
            mcsObj.NO_Lookup__c = nationalOffice.Id;
            mcsObj.LP_Lookup__c = localPartner.Id;
            insert mcsObj;
            system.debug('----mcsObj---' + mcsObj);
            
            // creating page reference for the page and mark it as current page
            PageReference pageRef = Page.MCSSlipPrint;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getHeaders().put('Host', 'visual.force');
            ApexPages.currentPage().getParameters().put('sessionId', UserInfo.getSessionId());
    
            // calling standard controller 
            ApexPages.StandardController sc = new ApexPages.StandardController(mcs1);
            MCSSlipPrint cont = new MCSSlipPrint(sc);
            cont.NationOfficeName = nationalOffice.Name;
            cont.LocalPartnerName = '';
            cont.CommunityName = '';
            cont.selectedLetterType = 'Child Welcome and Child Bonding Letters';
            
    		cont.getletterTypes();
    		cont.filter.mcs = mcsObj;
    		cont.filter.participant = con3;
    		cont.launchConga();
    		//cont.showURL();
		Test.stopTest();
		system.assertNotEquals(mcs1.MCS_Letter_Type__c, cont.selectedLetterType); //here - mcs has letter type = 'Child Welcome Letter' but actual selection at UI would be = 'Child Welcome and Child Bonding Letters'
		//system.assertNotEquals(null, cont.url1Token);
    }
    
    @isTest
	public static void testMCSSlipPrintForChildReplyLettersAndSponsorLetters() {
    	
    	//setting up of all data 
    	setUpTestData();
    	
    	Test.startTest();
    	
    	    List<Mail_Control_Slip__c> massList = new List<Mail_Control_Slip__c>();
            
            Mail_Control_Slip__c mcsObj1 = new Mail_Control_Slip__c();
            mcsObj1.Participant__c = con1.id;	
            mcsObj1.MCS_Status__c = 'Active';
            mcsObj1.MCS_Letter_Type__c = 'Sponsor Letter';
            mcsObj1.MCS_Date__c = system.today().addDays(-20);
            mcsObj1.Due_Date__c = system.today().Addmonths(3);
            mcsObj1.NO_Lookup__c = nationalOffice.Id;
            mcsObj1.LP_Lookup__c = localPartner.Id;
            massList.add(mcsObj1);
            
            Mail_Control_Slip__c mcsObj2 = new Mail_Control_Slip__c();
            mcsObj2.Participant__c = con1.id;	
            mcsObj2.MCS_Status__c = 'Active';
            mcsObj2.MCS_Letter_Type__c = 'Child Reply Letters';
            mcsObj2.MCS_Date__c = Date.newInstance(system.today().year(), system.today().Addmonths(1).month(), system.today().day());
            mcsObj2.Due_Date__c = system.today().Addmonths(2);
            mcsObj2.NO_Lookup__c = nationalOffice.Id;
            mcsObj2.LP_Lookup__c = localPartner.Id;
            massList.add(mcsObj2);
            
            insert massList;
            
            system.debug('----massList---' + massList);
        
            // creating page reference for the page and mark it as current page
            PageReference pageRef = Page.MCSSlipPrint;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getHeaders().put('Host', 'visual.force');
            ApexPages.currentPage().getParameters().put('sessionId', UserInfo.getSessionId());
    
            // calling standard controller 
            ApexPages.StandardController sc = new ApexPages.StandardController(mcs1);
            MCSSlipPrint cont = new MCSSlipPrint(sc);
            cont.NationOfficeName = nationalOffice.Name;
            cont.LocalPartnerName = '';
            cont.CommunityName = '';
            cont.selectedLetterType = 'Sponsor and Child Reply Letters';
            
    		cont.getletterTypes();
    		cont.filter.mcs = mcsObj1;
    		cont.filter.participant = con3;
    		cont.launchConga();
    		//cont.showURL();
		Test.stopTest();
		system.assertNotEquals(mcsObj1.MCS_Letter_Type__c, cont.selectedLetterType); //here - mcs has letter type = 'Sponsor Letter' but actual selection at UI would be = 'Sponsor and Child Reply Letters'
		system.assertNotEquals(mcsObj2.MCS_Letter_Type__c, cont.selectedLetterType); //here - mcs has letter type = 'Child Reply Letters' but actual selection at UI would be = 'Sponsor and Child Reply Letters'
	    //system.assertNotEquals(null, cont.url1Token);  
    }
    
    @isTest
	public static void testMCSSlipPrintForMCSAddressLabels() {
    	
    	//setting up of all data 
    	setUpTestData();
    	Test.startTest();
            Mail_Control_Slip__c mcsObj = new Mail_Control_Slip__c();
            mcsObj.Participant__c = con1.id;	
            mcsObj.MCS_Status__c = 'Active';
            mcsObj.MCS_Letter_Type__c = 'Child Welcome Letter';
            mcsObj.MCS_Date__c = system.today().addDays(-20);
            mcsObj.Due_Date__c = system.today();
            mcsObj.LastModifiedById = UserInfo.getUserId();
            insert mcsObj;
            system.debug('----mcsObj---' + mcsObj);
            
            // creating page reference for the page and mark it as current page
            PageReference pageRef = Page.MCSSlipPrint;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getHeaders().put('Host', 'visual.force');
            ApexPages.currentPage().getParameters().put('sessionId', UserInfo.getSessionId());
    
            // calling standard controller 
            ApexPages.StandardController sc = new ApexPages.StandardController(mcs1);
            MCSSlipPrint cont = new MCSSlipPrint(sc);
            cont.NationOfficeName = nationalOffice.Name;
            cont.LocalPartnerName = '';
            cont.CommunityName = '';
            cont.selectedLetterType = 'MCS Address Labels';
            
    		cont.getletterTypes();
    		cont.filter.mcs = mcsObj;
    		cont.filter.participant = con3;
    		cont.launchConga();
    		//cont.childStatusSlipSponsorTransfers();
    	//	cont.showURL();
		Test.stopTest();
		system.assertNotEquals(mcs1.MCS_Letter_Type__c, cont.selectedLetterType); //here - mcs has letter type = 'Child Welcome Letter' but actual selection at UI would be = 'Child Welcome and Child Bonding Letters'
		//system.assertNotEquals(null, cont.url1Token); 
    }

    @isTest
	public static void testChildStatusSlip() {
    	//setting up of all data 
    	setUpTestData();
    	
        // creating page reference for the page and mark it as current page
        PageReference pageRef = Page.MCSSlipPrint;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getHeaders().put('Host', 'visual.force');
        
        // calling standard controller 
        ApexPages.StandardController sc = new ApexPages.StandardController(mcs1);
        MCSSlipPrint cont = new MCSSlipPrint(sc);
        cont.NationOfficeName = nationalOffice.Name;
        cont.LocalPartnerName = localPartner.Name;
        cont.CommunityName = community1.Name;
        cont.selectedLetterType = 'Report - Child Status Slip';
        
        // beginning Test
		Test.startTest(); // Test Starts
		//2. Filter is assigned the corresponding participant and mail control slip record
		cont.getletterTypes();
		cont.filter.mcs = mcs1;
		cont.filter.participant = con1;
		cont.launchConga();

		Test.stopTest();       // Test Stops
    }
    
    @isTest
	public static void testDFRegister() {
    	//setting up of all data 
    	setUpTestData();
    	
    	Mail_Control_Slip__c mcsObj = new Mail_Control_Slip__c();
        mcsObj.Participant__c = con1.id;	
        mcsObj.MCS_Status__c = 'Active';
        mcsObj.MCS_Letter_Type__c = 'Thank You Letter For DF';
        mcsObj.MCS_Date__c = system.today().addDays(-15);
        mcsObj.NO_Lookup__c = nationalOffice.Id;
        mcsObj.LP_Lookup__c = localPartner.Id;
        insert mcsObj;
    	
        // creating page reference for the page and mark it as current page
        PageReference pageRef = Page.MCSSlipPrint;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getHeaders().put('Host', 'visual.force');
        
        // calling standard controller 
        ApexPages.StandardController sc = new ApexPages.StandardController(mcs1);
        MCSSlipPrint cont = new MCSSlipPrint(sc);
        cont.NationOfficeName = nationalOffice.Name;
        cont.LocalPartnerName = localPartner.Name;
        cont.CommunityName = community1.Name;
        cont.selectedLetterType = 'Report - DF Register';
        
        // beginning Test
		Test.startTest(); // Test Starts
		//2. Filter is assigned the corresponding participant and mail control slip record
		cont.getletterTypes();
		cont.filter.mcs = mcs1;
		cont.filter.participant = con1;
		cont.launchConga();

		Test.stopTest();       // Test Stops
    }
    //Setting up of Data
    public static void setUpTestData() {
    	
		rC_Giving__Contact_Setting__c setting = new rC_Giving__Contact_Setting__c();
        setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert setting;
        
        List<Account> accountList = new List<Account>();
		List<Contact> contactForInsertionList = new List<Contact>();
		List<Contact> updateParticipantList = new List<Contact>();
		List<Opportunity> opportunityForInsertionList = new List<Opportunity>();
		List<rC_Bios__Relationship__c> relationshipList = new List<rC_Bios__Relationship__c>();
		
    	//create account and contact data
        nationalOffice = TestUtils.createAccount('National Office', false);
        nationalOffice.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        nationalOffice.National_Office_Id__c = '899';
        insert nationalOffice;
        
        localPartner = TestUtils.createAccount('Local Partner', false);
        localPartner.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        localPartner.ParentId = nationalOffice.Id;
        localPartner.Local_Partner_ID__c = '1234567';
        insert localPartner;
        
        Account acc = TestUtils.createAccount('Test Account',False);
        acc.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        accountList.add(acc);
        
        community1 = TestUtils.createAccount('Community', false);
        community1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community1.ParentId = localPartner.Id;
        community1.Community_Id__c = '3567';
        accountList.add(community1);
        
        community2 = TestUtils.createAccount('Community2', false);
        community2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community2.ParentId = localPartner.Id;
        community2.Community_Id__c = '3560';
        accountList.add(community2);
        
        insert accountList;
        
        String accHHRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        //hhAccount = TestUtils.createAccountWithRT('Test Household Account', accHHRTId, community1, '565', '21343', true);
        
        
         // creating contact record
        con1 = TestUtils.createContact(null,'Joe','Kid',false);
        //con.AccountId = hhAccount.Id;
        Account CF_Acc = TestUtils.createAccountWithRT('Test Household Account', ACC_CF_RT, community1, '560', '2030', true);
        //con1.Community__c = community1.id;
        con1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        con1.Participant_Case_Number__c = '87654';
        con1.Local_Partner__c = localPartner.Id;
        con1.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con1.National_Office__c = nationalOffice.Id;
        con1.Village__c = 'villageTest';
        con1.Donor_Alliance__c = CF_Acc.Id;
        contactForInsertionList.add(con1);
        
        // creating contact record
        con2 = TestUtils.createContact(null,'Joe','Kid2',false);
        //con.AccountId = hhAccount.Id;
        //con2.Community__c = community2.id;
        con2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        con2.Participant_Case_Number__c = '87655';
        con2.Local_Partner__c = localPartner.Id;
        con2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con2.National_Office__c = nationalOffice.Id;
        con2.Village__c = 'villageTest2';
        contactForInsertionList.add(con2);
        
        // creating Blank contact record
        con3 = TestUtils.createContact(null,'Joe','Kid blank contact',false);
        con3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        con3.Participant_Case_Number__c = '87656';
        con3.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con3.National_Office__c = nationalOffice.Id;
        con3.Village__c = 'villageTest3';
        contactForInsertionList.add(con3);
        
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
        contactForInsertionList.add(contact);
        
        insert contactForInsertionList;
        
        // Updating two participant records
        con1.National_Office__c = nationalOffice.Id;
        con1.Local_Partner__c = localPartner.Id;
        updateParticipantList.add(con1);
        
        con2.National_Office__c = nationalOffice.Id;
        con2.Local_Partner__c = localPartner.Id;
        updateParticipantList.add(con2);
        
        update updateParticipantList;
        
        // creating Mail Control Slip record
        mcs1 = new Mail_Control_Slip__c();
        mcs1.Participant__c = con1.id;	
        mcs1.MCS_Letter_Type__c = 'Child Progress Report';
        mcs1.MCS_Date__c = system.today().addDays(-20);
        mcs1.Due_Date__c = system.today();
        insert mcs1;
        
        rC_Giving__GAU__c testGAU = TestUtils.createGeneralAccountingUnit('600',true);
        
        // Insertion of Opportunity records
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
        insert opportunity;
        
        Opportunity opp1 = TestUtils.createOpportunity(acc,'Test Opportunity1',null,False);
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        opp1.StageName = 'Cultivation';
        opp1.rC_Giving__Projected_Amount__c = 100;
        opp1.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opp1.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opp1.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opp1.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        opp1.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opp1.Core_Program_Infants__c = true;
        opp1.Date_of_Distribution__c = system.today().addDays(-150);
        opp1.rC_Giving__Parent__c = opportunity.Id;
        opp1.Remaining_Non_Adjusted__c = 10;
        opp1.rC_Giving__Is_Sustainer__c = true;
        opportunityForInsertionList.add(opp1);
        
        opp = TestUtils.createOpportunity(nationalOffice,'test',100,false);
        opp.rC_Giving__Giving_Amount__c = 100;
    	opp.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    	opp.Participant__c = contact.Id;
        opp.Product_Type__c = 'Designated Fund';
        opp.Product_Sub_Type__c = 'As Instructed';
        opp.rC_Giving__Primary_Contact__c = contact.Id;
        opp.rC_Giving__Hard_Credit_Contact__c = contact.Id;
        opportunityForInsertionList.add(opp);
        
        insert opportunityForInsertionList;
        
        // Insertion of Relationship records
        Id RecordTypeId = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Contact').getRecordTypeId();
        Id RecordTypeId2 = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Account - Account').getRecordTypeId();
        
        rC_Bios__Relationship__c rel = Testutils.createRelation(opp1,con1,RecordTypeId,false);
        rel.rC_Bios__Active__c = true;
        rel.rC_Bios__Role_2__c = 'Sponsorship Giving';
        rel.rC_Bios__Category__c = 'Sponsorship';
        rel.rC_Sponsorship__Start_Date_Time__c = system.today().addDays(-10);
        relationshipList.add(rel);
        
        rC_Bios__Relationship__c rel1 = Testutils.createRelation(opp1,con2,RecordTypeId2,false);
        rel1.rC_Bios__Active__c = true;
        rel1.rC_Bios__Role_2__c = 'Sponsorship Giving';
        rel1.rC_Bios__Category__c = 'Sponsorship';
        rel1.rC_Sponsorship__Start_Date_Time__c = system.today().addDays(-10);
        relationshipList.add(rel1);
        
        insert relationshipList;

    } // END public static void setUpTestData() {
    
} // END public with sharing class MCSSlipPrintTest