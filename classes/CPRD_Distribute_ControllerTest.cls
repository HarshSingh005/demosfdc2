/***********************************************************************************************************
* Appirio, Inc
* Name         : CPRD_Distribute_ControllerTest
* Created By   : Munib Ur Rehman (Appirio)
* Purpose      : Test class for the CPRD_Distribute_Controller.
* Created Date : 03/06/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 03/06/2016                   Munib Ur Rehman         Created
* 06/27/2016                   Ashu Gupta              Increased code coverage and impemented coding standards
* 06/29/2016                   Vaibhav Goel            Ramp-up of code coverage
* 08/02/2016                   Ravi Chauhan            Ramp-up of code coverage
* 08/16/2016                   Ashu Gupta              Added asserts
* 10/03/2016                   Ravi Chauhan            Increased Code coverage
* 04/Nov/2016				   Rohit B				   Fixed failure and improve converage
* 07/Nov/2016				   Rohit B				   Made changes in data creation (createTestData1 method)
* 14/Nov/2016				   Rohit B				   Made some data creation changes (createTestData2 method).
* 12/Dec/2016				   Suminder Singh		   Fixed failure and improve coverage
* 14/Feb/2016				   Suminder Singh		   Fixed failure and improve coverage
**********************************************************************************************************/
@isTest 
private class CPRD_Distribute_ControllerTest {
    public static Contact con, kid, participant, con1;
    public static Account nationalOffice, localPartner, community , acc, acc1;
	public static Opportunity parentOpportunity, parentOpportunity1, parentOpportunity2, parentOpportunity3;
    public static Opportunity opportunity, donationOpportunity, OppDF;
    public static rC_Giving__GAU__c testGAU, testGAU600;
    public static rC_Giving__Batch__c batch;
    public static Campaign testCamp, testCampSpons, testCampDF;
    public static rC_Connect__Batch_Upload__c upload, upload1;
    public static Web_Transaction__c webTransaction;
    public static Batch_Upload_Distribution__c bud , budSet1;
    
	final static String ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    final static String ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    final static String ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    final static String ACC_COM_RT=  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    final static String CON_HH_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
	final static String CON_PR_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    final static String OPP_DN_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    final static String OPP_TN_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    
    Final Static Id PM_CashCheck = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Cash/Check').getRecordTypeId();
    static rC_Giving__Payment_Method__c paymentMethod;
    
	Final Static String SPONSORSHIP = 'Sponsorship';
	Final Static String CHILD_SPONSORSHIP = 'Child Sponsorship';
	Final Static String DESIGNATED_FUND = 'Designated Fund';
	Final Static String EASTER = 'Easter';
	Final Static String staticParticipantID = '00329000006hXhfAAE';
    
	@isTest
    public static void testOtherMethodsThanApply() {
        createTestData1();

		rC_Connect__Batch_Upload__c newUpload = new rC_Connect__Batch_Upload__c();
        newUpload = TestUtils.createBatchUpload('Test',false); 
        newUpload.Participant_Number__c = kid.Contact_Number__c;
        newUpload.rC_Connect__Giving_Giving_Amount__c = 500;
        newUpload.Web_Transaction__c = webTransaction.Id;
        newUpload.rC_Connect__Batch_Upload_Batch__c = batch.Id;
        newUpload.rC_Connect__HardCreditContact__c = con.Id;        
        insert newUpload;

		bud = TestUtils.createBatchUploadDistribution('test bud Other', newUpload.Id, null, null, parentOpportunity.Id, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 100;   
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		insert bud;

        ApexPages.Message[] pageMessages;
        Test.setCurrentPageReference(new PageReference('Page.CPRD_Distribute'));
        System.currentPageReference().getParameters().put('id', newUpload.Id);
        System.currentPageReference().getParameters().put('paymentIndex', '0');
        
        test.startTest();
			CPRD_Distribute_Controller controller = new CPRD_Distribute_Controller();
			controller.Opp = parentOpportunity;
			controller.updateFieldsOnOppChange();
			controller.updateFieldsOnCampaignSelect();
			//controller.updateFieldsOnGAUSelect();
			controller.autoSponsor();
			controller.autoDF();
			controller.saveAll();
			controller.recordNoToDelete = 0;
			controller.deleteRecord();
        test.stopTest();
    }    
    
    @isTest
    public static void testApplyWhenOpportunityOnBUDIsNotNull_1() {
        
        createTestData1();       
        
        Test.StartTest();
			Test.setCurrentPageReference(Page.CPRD_Distribute);
			System.currentPageReference().getParameters().put('id', upload.Id);
			CPRD_Distribute_Controller controller = new CPRD_Distribute_Controller();
			//controller.Opp = [SELECT id FROM Opportunity WHERE id = : bud.opportunity__c];
			controller.apply();
			//Query to check whether last open transaction for sponsorship opp, has been marked as 'Complete' or not
			List<Opportunity> lstOpp = [SELECT Id, StageName FROM Opportunity WHERE rC_Giving__Parent__c = :parentOpportunity.Id Order By CloseDate ASC];
			//System.assertEquals('Completed', lstOpp[0].StageName);
			//Query to check whether 'Complete' transaction has been created for the sponsorship opp which is not having any open transaction.
			lstOpp = [SELECT Id, StageName FROM Opportunity WHERE rC_Giving__Parent__c = :donationOpportunity.Id Order By CloseDate ASC];
			//System.assertEquals(0, lstOpp.size());
			//System.assertNotEquals(0, lstOpp.size());
			//System.assertEquals('Completed', lstOpp[0].StageName);
			//Query to check whether one time DF has been created for Designated Fund opportunity or not.
			lstOpp = [SELECT Id, StageName FROM Opportunity WHERE DFC_Related_Opportunity__c = :parentOpportunity.Id];
			//System.assertNotEquals(0, lstOpp.size());
        Test.StopTest();
    }

	@isTest
    public static void testApplyWhenOpportunityOnBUDIsNull_1() {
        
        createTestData2();       
        
        Test.StartTest();
			Test.setCurrentPageReference(Page.CPRD_Distribute);
			System.currentPageReference().getParameters().put('id', upload.Id);
			CPRD_Distribute_Controller controller = new CPRD_Distribute_Controller();
			//System.assert(false, controller.payments);
			controller.apply();
			//Query to check whether last open transaction for sponsorship opp, has been marked as 'Complete' or not
			List<Opportunity> lstOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunity.Id];
			//System.assertEquals('Completed', lstOpp[0].StageName);
			//Query to check whether 'Complete' transaction has been created for the sponsorship opp which is not having any open transaction.
			lstOpp = [SELECT Id, StageName FROM Opportunity WHERE rC_Giving__Parent__c = :parentOpportunity1.Id Order By CloseDate ASC];
			//System.assertNotEquals(0, lstOpp.size());
			//System.assertEquals('Completed', lstOpp[0].StageName);
			//Query to check whether one time DF has been created for Designated Fund opportunity or not.
			lstOpp = [SELECT Id, StageName FROM Opportunity WHERE rC_Giving__GAU__c = :testGAU600.Id];
			//System.assertNotEquals(0, lstOpp.size());
			//System.assertEquals(0, lstOpp.size());
        Test.StopTest();
    }
    
    @isTest
    public static void testAddPaymentMethod(){
        createTestData1();
        Test.StartTest();
        Test.setCurrentPageReference(Page.CPRD_Distribute);
		System.currentPageReference().getParameters().put('id', upload.Id);
		CPRD_Distribute_Controller controller = new CPRD_Distribute_Controller();
		controller.payments.clear();
		
		System.assertEquals(0,controller.payments.size());
		controller.addPayment();
		System.assertEquals(1,controller.payments.size());
		
		Test.StopTest();
    }
    
    @isTest
    public static void testupdateFieldsOnGAUSelect(){
        createTestData1();
        Test.StartTest();
        Test.setCurrentPageReference(Page.CPRD_Distribute);
		System.currentPageReference().getParameters().put('id', upload.Id);
		CPRD_Distribute_Controller controller = new CPRD_Distribute_Controller();
		System.currentPageReference().getParameters().put('paymentIndex', '0');
		
		controller.updateFieldsOnGAUSelect();
		
		Test.StopTest();
    }
    
    @isTest
    public static void testautoDFmethod(){
        createTestData_Campaign_GAU();
        createTestData1();
        upload.DF_Campaign__c = testCampSpons.Id;
        update upload;
        
        Opportunity oppForautoDF = TestUtils.createOpportunity(acc, 'Test Opportunity', 500, false);
        oppForautoDF.RecordTypeId = OPP_TN_RT;
        oppForautoDF.StageName = 'Open';
		oppForautoDF.Amount = 100;
        oppForautoDF.rC_Giving__Projected_Amount__c = 100;
        oppForautoDF.Product_Type__c = SPONSORSHIP;
        oppForautoDF.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        oppForautoDF.rC_Giving__Hard_Credit_Contact__c = con.Id;
        oppForautoDF.campaignId = testCampSpons.Id;
        oppForautoDF.rC_Giving__Parent__c = parentOpportunity.Id;
        oppForautoDF.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        oppForautoDF.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        oppForautoDF.rC_Giving__Is_Sustainer__c = true;
        insert oppForautoDF;
        
        Test.startTest();
        
        Test.setCurrentPageReference(Page.CPRD_Distribute);
		System.currentPageReference().getParameters().put('id', upload.Id);
		CPRD_Distribute_Controller controller = new CPRD_Distribute_Controller();
		System.currentPageReference().getParameters().put('paymentIndex', '0');
		controller.Opp = oppForautoDF;
		controller.autoDF();
		Test.StopTest();
        
    }
    
    @isTest
    public static void testSaveAll(){
        createTestData1();
        
        Test.StartTest();
        Test.setCurrentPageReference(Page.CPRD_Distribute);
		System.currentPageReference().getParameters().put('id', upload.Id);
		CPRD_Distribute_Controller controller = new CPRD_Distribute_Controller();
		System.currentPageReference().getParameters().put('paymentIndex', '0');
		
		// Updating the batch upload in controller to satisfy a condition in SaveAll method
		controller.batchUpload.rC_Connect__HardCreditContact__c = null;
		
		controller.saveAll();
		
		Test.StopTest();
    }
    
    @isTest
    public static void testIncreaseCoverage(){
        createTestData1();
        Batch_Upload_Distribution__c bud1 = [SELECT id,Campaign__c,GAU__c,Product_Type__c,Product_Sub_Type__c,Opportunity__c,GAU__r.Receipt_Category__c,Campaign__r.Name FROM Batch_Upload_Distribution__c WHERE name = 'test bud Spons 1'];
        Test.StartTest();
        Test.setCurrentPageReference(Page.CPRD_Distribute);
		System.currentPageReference().getParameters().put('id', upload.Id);
		CPRD_Distribute_Controller controller = new CPRD_Distribute_Controller();
		System.currentPageReference().getParameters().put('paymentIndex', '0');
		
		controller.payments.clear();
		
		List<CPRD_Distribute_Controller.Payment> paymentList = new List<CPRD_Distribute_Controller.Payment>();
		CPRD_Distribute_Controller.Payment paymentObj = new CPRD_Distribute_Controller.Payment(opportunity,bud1);
		paymentObj.bud.Product_Type__c = null;
		paymentObj.bud.Product_Sub_Type__c = null;
		paymentObj.bud.Campaign__c = testCampSpons.Id;
		paymentList.add(paymentObj);
		
		controller.payments = paymentList;
		
		controller.updateFieldsOnOppChange();
		controller.updateFieldsOnCampaignSelect();

		Test.StopTest();
    }

	public static void createTestData_Account_Contact() {
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Account_Contact :: Method Starts..');

		rC_Giving__Contact_Setting__c con_cust_setting = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        con_cust_setting.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert con_cust_setting; 
        
        List<Account> listAcc = new List<Account>();
        acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = ACC_HH_RT;
        listAcc.add(acc);
        
        acc1 = TestUtils.createAccount('test 1',false);
        acc1.RecordTypeId = ACC_HH_RT;
        listAcc.add(acc1);
        //creating account record
        nationalOffice = TestUtils.createAccountWithRT('National Office', ACC_NO_RT, null, '899', '21245', false);
        nationalOffice.rC_Bios__Active__c  = true;
        listAcc.add(nationalOffice);
        
        insert listAcc;
        
        localPartner = TestUtils.createAccountWithRT('Local Partner', ACC_LP_RT, nationalOffice, '499', '21246', true);
        community = TestUtils.createAccountWithRT('Community', ACC_COM_RT, localPartner, '699', '2124', true);
        
        List<Contact> listContactsToBeInserted = new List<Contact>();
        con = TestUtils.createContact(acc, 'test', 'test', false);
        con.Community__c = community.id;
        con.Participant_Case_Number__c = '76452';
		con.RecordTypeId = CON_HH_RT;
		listContactsToBeInserted.add(con);
		
		con1 = TestUtils.createContact(acc1, 'test 1', 'test 1', false);
        con1.Community__c = community.id;
        con1.Participant_Case_Number__c = '76453';
		con1.RecordTypeId = CON_HH_RT;
		listContactsToBeInserted.add(con1);
		
		insert listContactsToBeInserted;

        participant = testUtils.createContact(acc, 'Joe', 'Kid', false);
        participant.Community__c = community.id;
        participant.RecordTypeId = CON_PR_RT;
        participant.Participant_Case_Number__c = '87654';
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
		participant.rC_Giving__Track_Hard_Credits__c = true;
		participant.DoNotUpdateReserve__c = true;
        insert participant;
        
        kid = new Contact();
		kid.AccountId = acc.Id;
        kid.RecordTypeId = CON_PR_RT;
        kid.FirstName = 'Good';
        kid.LastName = 'Kid';
        kid.Participant_Case_Number__c = '12345';
        kid.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        kid.rC_Giving__Track_Hard_Credits__c = true;
        kid.Accept_DF_Fee__c = true;
		kid.DoNotUpdateReserve__c = true;
        insert kid;
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Account_Contact :: kid => ' + kid);
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Account_Contact :: kid.RecordTypeId => ' + kid.RecordTypeId);

		rC_Connect__Payment_Method_Setting__c payMethodsetting = rC_Connect__Payment_Method_Setting__c.getInstance();
        payMethodsetting.rC_Connect__Disable_All__c = true;
        insert payMethodsetting;
        
		rC_Giving__Payment_Method__c paymentMethodToInsert = TestUtils.createPaymentMethod('testPaymentMethod', 'Cash/Check', true, acc, false);
        paymentMethodToInsert.RecordTypeId = PM_CashCheck;
        paymentMethodToInsert.rC_Giving__Contact__c = con.Id;
        paymentMethodToInsert.rC_Connect__Payment_Processor__c = 'Sage'; 
        paymentMethodToInsert.rC_Connect__Merchant_Name__c = 'testMerchantName';
        paymentMethodToInsert.rC_Giving__Payment_Type__c = 'Cash/Check' ;
        insert paymentMethodToInsert;
        
        paymentMethod = [SELECT Id, RecordTypeId, rC_Connect__Merchant_Name__c, Account_Number_E__c, rC_Connect__Payment_Processor__c, 
                         Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c 
                         FROM rC_Giving__Payment_Method__c 
                         WHERE id =: paymentMethodToInsert.Id  LIMIT 1];
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Account_Contact :: Method Ends..');
	}

	public static void createTestData_Campaign_GAU() {
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Campaign_GAU :: Method Starts..');
        testGAU = TestUtils.createGeneralAccountingUnit('test-1',false);
        testGAU.Product_Type__c = 'Sponsorship';
        testGAU.Product_Sub_Type__c ='Child Sponsorship';
        insert testGAU;
        
        testGAU600 = TestUtils.createGeneralAccountingUnit('600',false);
        testGAU600.Product_Type__c = 'Sponsorship';
        testGAU600.Product_Sub_Type__c ='Child Sponsorship';
		testGAU600.Receipt_Category__c = '0600';
        insert testGAU600;
        
		testCampSpons = TestUtils.createCampaign('Test Camp Spons',false);
        testCampSpons.Product_Type__c = SPONSORSHIP;
        testCampSpons.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        testCampSpons.rC_Giving__GAU__c = testGAU600.Id;
        insert testCampSpons;

        testCampDF = TestUtils.createCampaign('test camp',false);
        testCampDF.Product_Type__c = 'Designated Fund';
        testCampDF.Product_Sub_Type__c = 'Belated Christmas';
        insert testCampDF;
		
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Campaign_GAU :: Method Ends..');
	}
    
	//create opportunity test data for BUD when Opportunity on BUD is not null.
    public static void createTestData_Opportunity_1() {
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Opportunity :: Method Starts..');

		List<Opportunity> oppsToBeInserted = new List<Opportunity>();
		parentOpportunity = TestUtils.createOpportunity(acc, 'Test Parent Sponsorship Donation Opportunity', 100, false);
        parentOpportunity.RecordTypeId = OPP_DN_RT;
		parentOpportunity.Amount = 100;
        parentOpportunity.rC_Giving__Projected_Amount__c = 100;
        parentOpportunity.Product_Type__c = SPONSORSHIP;
        parentOpportunity.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        parentOpportunity.rC_Giving__Hard_Credit_Contact__c = con.Id;
        parentOpportunity.rC_Giving__Primary_Contact__c = con.Id;
        parentOpportunity.Participant__c = kid.Id;
        parentOpportunity.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        parentOpportunity.Core_Program_Infants__c = true;
        parentOpportunity.campaignId = testCampSpons.Id;
		parentOpportunity.rC_Sponsorship__Sponsorship_Status__c = 'Active';
		parentOpportunity.rC_Giving__Is_Sustainer__c = true;
		//insert parentOpportunity;
		oppsToBeInserted.add(parentOpportunity);

		donationOpportunity = TestUtils.createOpportunity(acc, 'Test Parent Sponsorship Donation Opportunity', 100, false);
        donationOpportunity.RecordTypeId = OPP_DN_RT;
		donationOpportunity.Amount = 50;
        donationOpportunity.rC_Giving__Projected_Amount__c = 50;
        donationOpportunity.Product_Type__c = SPONSORSHIP;
        donationOpportunity.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        donationOpportunity.rC_Giving__Hard_Credit_Contact__c = con.Id;
        donationOpportunity.rC_Giving__Primary_Contact__c = con.Id;
        donationOpportunity.Participant__c = kid.Id;
        donationOpportunity.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        donationOpportunity.Core_Program_Infants__c = true;
        donationOpportunity.campaignId = testCampSpons.Id;
		donationOpportunity.rC_Sponsorship__Sponsorship_Status__c = 'Active';
		donationOpportunity.rC_Giving__Is_Sustainer__c = true;
		//insert donationOpportunity;
		oppsToBeInserted.add(donationOpportunity);

		opportunity = TestUtils.createOpportunity(acc, 'Test Opportunity', 500, false);
        opportunity.RecordTypeId = OPP_TN_RT;
        opportunity.StageName = 'Open';
		opportunity.Amount = 100;
        opportunity.rC_Giving__Projected_Amount__c = 100;
        opportunity.Product_Type__c = SPONSORSHIP;
        opportunity.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opportunity.rC_Giving__Hard_Credit_Contact__c = con.Id;
        opportunity.campaignId = testCampSpons.Id;
        Opportunity.rC_Giving__Parent__c = parentOpportunity.Id;
        Opportunity.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        Opportunity.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        Opportunity.rC_Giving__Is_Sustainer__c = true;
        //insert Opportunity; 
		oppsToBeInserted.add(Opportunity);

		OppDF = TestUtils.createOpportunity(acc, 'Test Parent DF Donation Opportunity', 100, false);
        OppDF.RecordTypeId = OPP_DN_RT;
		OppDF.Amount = 100;
        OppDF.rC_Giving__Projected_Amount__c = 100;
        OppDF.Product_Type__c = 'Designated Fund';
        OppDF.Product_Sub_Type__c = 'Easter';
        OppDF.rC_Giving__Hard_Credit_Contact__c = con.Id;
        OppDF.rC_Giving__Primary_Contact__c = con.Id;
        OppDF.Participant__c = kid.Id;
        OppDF.campaignId = testCampDF.Id;
        //insert OppDF;
		oppsToBeInserted.add(OppDF);

		insert oppsToBeInserted;

		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Opportunity :: Method End..');
	}

	//create opportunity test data for BUD records when Opportunity is specified
    public static void createTestData1() {    
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData1 :: Method Starts..'); 
		createTestData_Account_Contact();
		createTestData_Campaign_GAU();
		createTestData_Opportunity_1();
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData1 :: kid (302) => ' + kid);
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData1 :: kid.RecordTypeId (303) => ' + kid.RecordTypeId);

        
        batch = TestUtils.createBatch('testBatch', 100.0, 1000, true);
        
        webTransaction = TestUtils.createWebTransaction(true);
        
        List<rC_Connect__Batch_Upload__c> listUploads = new List<rC_Connect__Batch_Upload__c>();
        upload = TestUtils.createBatchUpload('Test',false); 
        upload.Participant_Number__c = kid.Contact_Number__c;
        upload.rC_Connect__Giving_Giving_Amount__c = 400;
        upload.Web_Transaction__c = webTransaction.Id;
        upload.rC_Connect__Batch_Upload_Batch__c = batch.Id;
        upload.rC_Connect__HardCreditContact__c = con.Id;
        upload.rC_Connect__Batch_Upload_Sequence_Number__c = '12345';
        listUploads.add(upload);
        
        insert listUploads;
        
        // INsert Child Batch Upload
        rC_Connect__Batch_Upload__c childUpload = TestUtils.createBatchUpload('Test Child',false);
        childUpload.Participant_Number__c = kid.Contact_Number__c;
        childUpload.rC_Connect__Giving_Giving_Amount__c = 400;
        childUpload.Web_Transaction__c = webTransaction.Id;
        childUpload.rC_Connect__Batch_Upload_Batch__c = batch.Id;
        childUpload.rC_Connect__HardCreditContact__c = con.Id;
        childUpload.rC_Connect__Batch_Upload_Status__c = 'New';
        childUpload.rC_Connect__Batch_Upload_Sequence_Number__c = '12345';
        
        insert childUpload;

		Contact participant1 = new Contact();
		participant1.AccountId = acc.Id;
        participant1.RecordTypeId = CON_PR_RT;
        participant1.FirstName = 'Test';
        participant1.LastName = 'Test';
        participant1.Participant_Case_Number__c = '14596';
        participant1.rC_Sponsorship__Sponsorship_Status__c = 'Unavailable';
        participant1.rC_Giving__Track_Hard_Credits__c = true;
		participant1.DoNotUpdateReserve__c = true;
        insert participant1;

        System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData1 :: upload (322) => ' + upload);
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData1 :: kid (323) => ' + kid);
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData1 :: kid.RecordTypeId (324) => ' + kid.RecordTypeId);

		List<Batch_Upload_Distribution__c> lstBUD = new List<Batch_Upload_Distribution__c>();
        bud = TestUtils.createBatchUploadDistribution('test bud Spons 1', upload.Id, testCampSpons.Id, testGAU.Id, parentOpportunity.Id, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 100;   
        bud.Product_Type__c = SPONSORSHIP;
        bud.Product_Sub_Type__c = CHILD_SPONSORSHIP;
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		//insert bud; 
		lstBUD.add(bud);

		bud = TestUtils.createBatchUploadDistribution('test bud Spons 2', upload.Id, testCampDF.Id, testGAU.Id, donationOpportunity.Id, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 100;   
        bud.Product_Type__c = SPONSORSHIP;
        bud.Product_Sub_Type__c = CHILD_SPONSORSHIP;
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		lstBUD.add(bud);

		bud = TestUtils.createBatchUploadDistribution('test bud DF 1', upload.Id, testCampDF.Id, testGAU.Id, parentOpportunity.Id, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 100;   
        bud.Product_Type__c = DESIGNATED_FUND;
        bud.Product_Sub_Type__c = EASTER;
		bud.DF_Message__c = 'test DF msg';
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		lstBUD.add(bud);
        
		bud = TestUtils.createBatchUploadDistribution('test bud Other', upload.Id, testCampDF.Id, testGAU.Id, parentOpportunity.Id, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 100;   
        bud.Product_Type__c = 'One Time Gift';
        bud.Product_Sub_Type__c = 'Standard';
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		lstBUD.add(bud);

		insert lstBUD;
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData1 :: Method Ends..');
    }

	//create opportunity test data for BUD when Opportunity on BUD is null.
    public static void createTestData_Opportunity_2() {
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Opportunity :: Method Starts..');

		Contact participant1 = new Contact();
		participant1.AccountId = acc.Id;
        participant1.RecordTypeId = CON_PR_RT;
        participant1.FirstName = 'Test';
        participant1.LastName = 'Test';
        participant1.Participant_Case_Number__c = '14596';
        participant1.rC_Sponsorship__Sponsorship_Status__c = 'Unavailable';
        participant1.rC_Giving__Track_Hard_Credits__c = true;
		participant1.DoNotUpdateReserve__c = true;
        insert participant1;

		List<Opportunity> oppsToBeInserted = new List<Opportunity>();
		parentOpportunity = TestUtils.createOpportunity(acc, 'Test Parent Sponsorship Donation Opportunity 1', 100, false);
        parentOpportunity.RecordTypeId = OPP_DN_RT;
		parentOpportunity.Amount = 100;
        parentOpportunity.rC_Giving__Projected_Amount__c = 100;
        parentOpportunity.Product_Type__c = SPONSORSHIP;
        parentOpportunity.Product_Sub_Type__c = 'Mother Sponsorship';
        parentOpportunity.rC_Giving__Hard_Credit_Contact__c = con.Id;
        parentOpportunity.rC_Giving__Primary_Contact__c = con.Id;
        parentOpportunity.Participant__c = staticParticipantID;
        parentOpportunity.rC_Sponsorship__Opportunity_Group_Id__c = 23566;
        parentOpportunity.Core_Program_Infants__c = true;
        parentOpportunity.campaignId = testCampSpons.Id;
		parentOpportunity.rC_Sponsorship__Sponsorship_Status__c = 'Active';
		parentOpportunity.rC_Giving__Is_Sustainer__c = true;
		//insert parentOpportunity;
		oppsToBeInserted.add(parentOpportunity);

		//Transaction opportunity of parentOpportunity.
		opportunity = TestUtils.createOpportunity(acc, 'Test Opportunity', 500, false);
        opportunity.RecordTypeId = OPP_TN_RT;
        opportunity.StageName = 'Open';
		opportunity.Amount = 100;
        opportunity.rC_Giving__Projected_Amount__c = 100;
        opportunity.Product_Type__c = SPONSORSHIP;
        opportunity.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opportunity.rC_Giving__Hard_Credit_Contact__c = con.Id;
        opportunity.campaignId = testCampSpons.Id;
        Opportunity.rC_Giving__Parent__c = parentOpportunity.Id;
        Opportunity.rC_Sponsorship__Opportunity_Group_Id__c = 23467;
        Opportunity.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        Opportunity.rC_Giving__Is_Sustainer__c = true;
        //insert Opportunity; 
		oppsToBeInserted.add(Opportunity);

		parentOpportunity1 = TestUtils.createOpportunity(acc, 'Test Parent Sponsorship Donation Opportunity 2', 100, false);
        parentOpportunity1.RecordTypeId = OPP_DN_RT;
		parentOpportunity1.Amount = 100;
        parentOpportunity1.rC_Giving__Projected_Amount__c = 100;
        parentOpportunity1.Product_Type__c = SPONSORSHIP;
        parentOpportunity1.Product_Sub_Type__c = 'Legacy Child';
        parentOpportunity1.rC_Giving__Hard_Credit_Contact__c = con.Id;
        parentOpportunity1.rC_Giving__Primary_Contact__c = con.Id;
        parentOpportunity1.Participant__c = staticParticipantID;
        parentOpportunity1.rC_Sponsorship__Opportunity_Group_Id__c = 23568;
        parentOpportunity1.Core_Program_Infants__c = true;
        parentOpportunity1.campaignId = testCampSpons.Id;
		parentOpportunity1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
		parentOpportunity1.rC_Giving__Is_Sustainer__c = true;
		parentOpportunity1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
		//insert parentOpportunity1;
		oppsToBeInserted.add(parentOpportunity1);

		parentOpportunity2 = TestUtils.createOpportunity(acc, 'Test Parent Sponsorship Donation Opportunity 3', 100, false);
        parentOpportunity2.RecordTypeId = OPP_DN_RT;
		parentOpportunity2.Amount = 100;
        parentOpportunity2.rC_Giving__Projected_Amount__c = 100;
        parentOpportunity2.Product_Type__c = SPONSORSHIP;
        parentOpportunity2.Product_Sub_Type__c = 'Gift';
        parentOpportunity2.rC_Giving__Hard_Credit_Contact__c = con.Id;
        parentOpportunity2.rC_Giving__Primary_Contact__c = con.Id;
        parentOpportunity2.Participant__c = staticParticipantID;
        parentOpportunity2.rC_Sponsorship__Opportunity_Group_Id__c = 22456;
        parentOpportunity2.Core_Program_Infants__c = true;
        parentOpportunity2.campaignId = testCampSpons.Id;
        parentOpportunity2.rC_Giving__Is_Sustainer__c = true;
        //parentOpportunity2.rC_Sponsorship__Sponsorship_Status__c = 'Active';
		//insert parentOpportunity2;
		oppsToBeInserted.add(parentOpportunity2);

		parentOpportunity3 = TestUtils.createOpportunity(acc, 'Test Parent Sponsorship Donation Opportunity 3', 100, false);
        parentOpportunity3.RecordTypeId = OPP_DN_RT;
		parentOpportunity3.Amount = 100;
        parentOpportunity3.rC_Giving__Projected_Amount__c = 100;
        parentOpportunity3.Product_Type__c = SPONSORSHIP;
        parentOpportunity3.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        parentOpportunity3.rC_Giving__Hard_Credit_Contact__c = con.Id;
        parentOpportunity3.rC_Giving__Primary_Contact__c = con.Id;
        parentOpportunity3.Participant__c = staticParticipantID;
        parentOpportunity3.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        parentOpportunity3.Core_Program_Infants__c = true;
        parentOpportunity3.campaignId = testCampSpons.Id;
        parentOpportunity3.rC_Giving__Is_Sustainer__c = true;
        parentOpportunity3.rC_Sponsorship__Sponsorship_Status__c = 'Active';
		//insert parentOpportunity3;
		oppsToBeInserted.add(parentOpportunity3);

		donationOpportunity = TestUtils.createOpportunity(acc, 'Test Parent Sponsorship Donation Opportunity', 100, false);
        donationOpportunity.RecordTypeId = OPP_DN_RT;
		donationOpportunity.Amount = 50;
        donationOpportunity.rC_Giving__Projected_Amount__c = 50;
        donationOpportunity.Product_Type__c = SPONSORSHIP;
        donationOpportunity.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        donationOpportunity.rC_Giving__Hard_Credit_Contact__c = con.Id;
        donationOpportunity.rC_Giving__Primary_Contact__c = con.Id;
        donationOpportunity.Participant__c = kid.Id;
        donationOpportunity.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        donationOpportunity.Core_Program_Infants__c = true;
        donationOpportunity.campaignId = testCampSpons.Id;
		donationOpportunity.rC_Sponsorship__Sponsorship_Status__c = 'Active';
		donationOpportunity.rC_Giving__Is_Sustainer__c = true;
		//insert donationOpportunity;
		oppsToBeInserted.add(donationOpportunity);
		
		//Transaction opportunity of parentOpportunity.
		Opportunity opportunity1 = TestUtils.createOpportunity(acc, 'Test Opportunity', 500, false);
        opportunity1.RecordTypeId = OPP_TN_RT;
        opportunity1.StageName = 'Open';
		opportunity1.Amount = 100;
        opportunity1.rC_Giving__Projected_Amount__c = 100;
        opportunity1.Product_Type__c = SPONSORSHIP;
        opportunity1.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opportunity1.rC_Giving__Hard_Credit_Contact__c = con.Id;
        opportunity1.campaignId = testCampSpons.Id;
        opportunity1.rC_Giving__Parent__c = donationOpportunity.Id;
        opportunity1.rC_Sponsorship__Opportunity_Group_Id__c = 23467;
        opportunity1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        opportunity1.rC_Giving__Is_Sustainer__c = true;
        //insert opportunity1; 
		oppsToBeInserted.add(opportunity1);

		OppDF = TestUtils.createOpportunity(acc, 'Test Parent DF Donation Opportunity', 100, false);
        OppDF.RecordTypeId = OPP_DN_RT;
		OppDF.Amount = 100;
        OppDF.rC_Giving__Projected_Amount__c = 100;
        OppDF.Product_Type__c = 'Designated Fund';
        OppDF.Product_Sub_Type__c = 'Easter';
        OppDF.rC_Giving__Hard_Credit_Contact__c = con.Id;
        OppDF.rC_Giving__Primary_Contact__c = con.Id;
        OppDF.Participant__c = staticParticipantID;
        OppDF.campaignId = testCampDF.Id;
        //insert OppDF;
		oppsToBeInserted.add(OppDF);
		
		Opportunity OppDFNew = TestUtils.createOpportunity(acc, 'Test New Opp', 100, false);
        OppDFNew.RecordTypeId = OPP_DN_RT;
		OppDFNew.Amount = 100;
        OppDFNew.rC_Giving__Projected_Amount__c = 100;
        OppDFNew.Product_Type__c = SPONSORSHIP;
        OppDFNew.Product_Sub_Type__c = 'Gift';
        OppDFNew.rC_Giving__Hard_Credit_Contact__c = con.Id;
        OppDFNew.rC_Giving__Primary_Contact__c = con.Id;
        OppDFNew.Participant__c = staticParticipantID;
        OppDFNew.rC_Sponsorship__Opportunity_Group_Id__c = 22456;
        OppDFNew.Core_Program_Infants__c = true;
        OppDFNew.campaignId = testCampSpons.Id;
        OppDFNew.rC_Giving__Is_Sustainer__c = true;
        OppDFNew.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        //insert OppDF;
		oppsToBeInserted.add(OppDFNew);

		insert oppsToBeInserted;

		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData_Opportunity :: Method End..');
	}
	//create opportunity test data for BUD records when Opportunity is NOT specified
    public static void createTestData2() {     
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData2 :: Method Starts..');

		createTestData_Account_Contact();
		createTestData_Campaign_GAU();
		createTestData_Opportunity_2();
		
        batch = TestUtils.createBatch('testBatch', 100.0, 1000, true);
        
        webTransaction = TestUtils.createWebTransaction(true);
        
        List<rC_Connect__Batch_Upload__c> listUploads = new List<rC_Connect__Batch_Upload__c>();
        upload = TestUtils.createBatchUpload('Test',false); 
        upload.Participant_Number__c = kid.Contact_Number__c;
        upload.rC_Connect__Giving_Giving_Amount__c = 400;
        upload.Web_Transaction__c = webTransaction.Id;
        upload.rC_Connect__Batch_Upload_Batch__c = batch.Id;
        upload.rC_Connect__HardCreditContact__c = con.Id;
        upload.rC_Connect__Batch_Upload_Sequence_Number__c = '12345';
        listUploads.add(upload);
        
        insert listUploads;
        
        // INsert Child Batch Upload
        rC_Connect__Batch_Upload__c childUpload = TestUtils.createBatchUpload('Test Child',false);
        childUpload.Participant_Number__c = kid.Contact_Number__c;
        childUpload.rC_Connect__Giving_Giving_Amount__c = 400;
        childUpload.Web_Transaction__c = webTransaction.Id;
        childUpload.rC_Connect__Batch_Upload_Batch__c = batch.Id;
        childUpload.rC_Connect__HardCreditContact__c = con.Id;
        childUpload.rC_Connect__Batch_Upload_Status__c = 'New';
        childUpload.rC_Connect__Batch_Upload_Sequence_Number__c = '12345';
        
        insert childUpload;

		/*Contact participant1 = new Contact();
		participant1.AccountId = acc.Id;
        participant1.RecordTypeId = CON_PR_RT;
        participant1.FirstName = 'Test';
        participant1.LastName = 'Test';
        participant1.Participant_Case_Number__c = '14596';
        participant1.rC_Sponsorship__Sponsorship_Status__c = 'Unavailable';
        participant1.rC_Giving__Track_Hard_Credits__c = true;
		participant1.DoNotUpdateReserve__c = true;
        insert participant1;*/


		List<Batch_Upload_Distribution__c> lstBUD = new List<Batch_Upload_Distribution__c>();
        bud = TestUtils.createBatchUploadDistribution('test bud Spons 1', upload.Id, testCampSpons.Id, testGAU.Id, null, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 50;   
        bud.Product_Type__c = SPONSORSHIP;
        bud.Product_Sub_Type__c = CHILD_SPONSORSHIP;
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		//insert bud; 
		lstBUD.add(bud);

		bud = TestUtils.createBatchUploadDistribution('test bud Spons 2', upload.Id, testCampSpons.Id, testGAU.Id, null, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 50;   
        bud.Product_Type__c = SPONSORSHIP;
        bud.Product_Sub_Type__c = 'Legacy Child';
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		//insert bud; 
		lstBUD.add(bud);

		bud = TestUtils.createBatchUploadDistribution('test bud Spons 3', upload.Id, testCampSpons.Id, testGAU.Id, null, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 50;   
        bud.Product_Type__c = SPONSORSHIP;
        bud.Product_Sub_Type__c = 'Gift';
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		//insert bud; 
		lstBUD.add(bud);

		bud = TestUtils.createBatchUploadDistribution('test bud Spons 4', upload.Id, testCampDF.Id, testGAU.Id, null, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 50;   
        bud.Product_Type__c = SPONSORSHIP;
        bud.Product_Sub_Type__c = CHILD_SPONSORSHIP;
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		lstBUD.add(bud);

		bud = TestUtils.createBatchUploadDistribution('test bud DF 1', upload.Id, testCampDF.Id, testGAU.Id, null, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 150;   
        bud.Product_Type__c = DESIGNATED_FUND;
        bud.Product_Sub_Type__c = EASTER;
		bud.DF_Message__c = 'test DF msg';
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		lstBUD.add(bud);
		
		bud = TestUtils.createBatchUploadDistribution('test bud Other', upload.Id, testCampDF.Id, testGAU.Id, null, false);
		bud.Hard_Credit_Contact__c = con.Id;
		bud.Giving_Amount__c = 50;   
        bud.Product_Type__c = 'One Time Gift';
        bud.Product_Sub_Type__c = 'Standard';
		bud.Participant__c = staticParticipantID;
        bud.Close_Date__c = System.today();
		bud.Status__c = 'Open';
		bud.Verification_Status__c = 'Verified';
		bud.Credit__c = true;
		lstBUD.add(bud);

		insert lstBUD;
		System.debug('[RB] - CPRD_Distribute_ControllerTest.createTestData2 :: Method Ends..');
    }    
} // END public with sharing class MCSCPRRequestTest