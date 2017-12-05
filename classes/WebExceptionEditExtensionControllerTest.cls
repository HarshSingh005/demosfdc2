/***********************************************************************************************************
 * Appirio, Inc
 * Name         : WebExceptionEditExtensionControllerTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the WebExceptionEditExtensionController
 * Created Date : 02/06/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/06/2016                   Munib Ur Rehman         Created
 **********************************************************************************************************/
@isTest
public class WebExceptionEditExtensionControllerTest {

    final static String ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    final static String ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    final static String ACC_COM_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    final static String ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    final static String CON_PR_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    final static String PM_EFT_RT = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
    static Account nationalOffice, localPartner, community, householdAcc;
    static Contact participant;
    static Contact kid, householdCon;
    static Web_Transaction__c wt, wt2;
    static rC_Connect__Batch_Upload__c upload;
    static rC_Giving__Payment_Method__c paymentMethod;
    /*
    @isTest
    public static void testWebExceptionEditExtensionController() {
       
        createTestData();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);
        //new WebExceptionEditExtensionController.LineItem().Title = 'test';
        WebExceptionEditExtensionController.lineItem li = new WebExceptionEditExtensionController.lineItem();
        li.Title = 'test';
        li.ItemId = upload.id;
        li.ItemNumber = 23;
        li.FinCode = '1234';
        li.MarketingId = '234';
        li.NationalOffice = nationalOffice.Id;
        li.ChildNumber = '78';
        li.followupEmail = 'test';
        li.Amount = 45.50;
        li.CommunityId = '987';
        li.PaymentFrequency = 'test';
        li.SponsorshipId = '345';
        li.TransactionType = 'test';
        li.EffectiveDate = 'test';
        li.AGPTransfer = false;
        li.DeactivateAGP = false;
        li.DFMessage = 'test';

    } // END public static void testUpdateLocalPartnerNationalOffice() {
    */
    
    @isTest
    public static void deleteRecordsTest() {

        createTestData();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);

        controller.deleteRecords();

        List<Web_Transaction__c> rec = new List<Web_Transaction__c>([SELECT Id, Name
                                                                        FROM Web_Transaction__c
                                                                            WHERE Id =: wt.Id LIMIT 1]);
        System.assertEquals(0,rec.size());
    }

    @isTest
    public static void sendFollowupEmailTest() {

        createTestData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);

        controller.sendFollowupEmail();

        ApexPages.StandardController stdController1 = new ApexPages.StandardController(wt2);
        WebExceptionEditExtensionController controller1 = new WebExceptionEditExtensionController(stdController1);

        controller1.sendFollowupEmail();
    }

    @isTest
    public static void populatePaymentMethodFieldsTest() {

        createTestData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);

        controller.PopulatePaymentMethodList();
    }
    /*
    @isTest
    public static void populateAVCWhenContactSelectedTest() {

        createTestData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);

        controller.populateAVCWhenContactSelected();
    }
    
    @isTest
    public static void populate
    WhenContactNotSelectedTest() {

        createTestData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);

        controller.populateAVCWhenContactNotSelected();

    }
    */
    @isTest
    public static void getContactsTest() {

        createTestData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);

        controller.getContacts();
    }

    @isTest
    public static void getAGPValuesTest() {

        createTestData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);

        List<SelectOption> AGPList = controller.AGPValues;
    }
    /*
    @isTest
    public static void createPaymentMethodTest() {

        createTestData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);

        //controller.paymentMethodRecordType = 'ChargeCard';
        controller.createPaymentMethod();

    }
    */
    
    @isTest
    public static void TestRedirect() {

        createTestData();

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);
        ApexPages.currentPage().getParameters().put('id', wt.Id);

        PageReference pageRef = controller.redirect();
        
        System.assert(pageRef != null);
    }
    
    @isTest
    public static void TestOnPaymentMethodChanged() {

        createTestData();
        
        wt.Payment_Method__c = paymentMethod.Id;
        update wt;

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);
        
        controller.OnPaymentMethodChanged();
        
    }
    
    @isTest
    public static void TestOnDonationDataChanged() {

        createTestData();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);
        
        controller.DonationId = upload.Id;
        
        controller.OnDonationDataChanged();
        
    }
    
    @isTest
    public static void TestOnContactChangedWhenContactIsNotNull() {

        createTestData();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);
        
        controller.OnContactChanged();
        
    }
    
    @isTest
    public static void TestOnContactChangedWhenContactIsNull() {

        createTestData();
        
        wt.Contact__c = null;
        update wt;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);
        
        controller.OnContactChanged();
        
    }
    
    @isTest
    public static void TestPostTransaction() {

        createTestData();
        
        wt.Payment_Method__c = paymentMethod.Id;
        update wt;
        delete [SELECT Id FROM rC_Connect__Batch_Upload__c WHERE rC_Connect__Giving_Giving_Frequency__c = null OR rC_Connect__Giving_Giving_Frequency__c = ''];

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);
        
        PageReference pageRef = controller.PostTransaction();
        
    }
    
    @isTest
    public static void TestAddressEvent() {

        createTestData();
        
        ValidatedAddress valAddress = new ValidatedAddress();
        valAddress.Line1 = 'Line 1';
        valAddress.Line2 = 'Line 2';
        valAddress.Line3 = 'Line 3';
        valAddress.City = 'City';
        valAddress.StateProv = 'StateProv';
        valAddress.PostalCode = 'PostalCode';

        ApexPages.StandardController stdController = new ApexPages.StandardController(wt);
        WebExceptionEditExtensionController controller = new WebExceptionEditExtensionController(stdController);
        controller.address = valAddress;
        
        controller.AddressEvent(new AddressValidationComponentController());
        
    }
    
    //create account and contact data
    public static void createTestData(){

         //creating account record
        nationalOffice = TestUtils.createAccountWithRT('National Office', ACC_NO_RT, null, '899', '21245', false);
        nationalOffice.rC_Bios__Active__c  = true;
        insert nationalOffice;
        localPartner = TestUtils.createAccountWithRT('Local Partner', ACC_LP_RT, nationalOffice, '499', '21246', true);
        community = TestUtils.createAccountWithRT('Community', ACC_COM_RT, localPartner, '699', '2124', true);
        
        householdAcc = TestUtils.createAccount('householdacc', false);
        householdAcc.RecordTypeId = ACC_HH_RT;
        insert householdAcc;
 
         Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        participant = new Contact();
        participant.FirstName = 'Joe';
        participant.LastName = 'Kid';
        participant.RecordTypeId = participantRecordTypeId;
        participant.Participant_Case_Number__c = '87654';
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        insert participant;
        
        
        kid = new Contact();
        kid.RecordTypeId = participantRecordTypeId;
        kid.FirstName = 'Good';
        kid.LastName = 'Kid';
        kid.Participant_Case_Number__c = '12345';
        kid.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        insert kid;
        
        rC_Bios__Address__c address = TestUtils.createAddress('Street test', 'Street Test Line 2', 'Test City', '123456', 'IND' , false);
        insert address;

        householdCon = TestUtils.createContact(householdAcc, 'Test', 'Contact1', false);
        householdCon.Email = 'test_appirio@gmail.com';
        householdCon.rC_Bios__Preferred_Mailing_Address__c = address.Id;
        insert householdCon;

        wt = TestUtils.createWebTransaction(false);
        wt.Contact__c = householdCon.Id;
        wt.Contact_State_Prov_Terr__c = 'AK';
        wt.Contact_Country__c  = 'USA';
        wt.Contact_Street_1__c = 'test street 1';
        wt.Contact_Street_2__c = 'test street 2';
        insert wt;

        wt2 = TestUtils.createWebTransaction(false);
        wt2.Contact_Email__c = 'test_appirio@gmail.com';
        insert wt2;

        upload = TestUtils.createBatchUpload('Test', false);
        //upload.Name = 'Test';
        upload.Participant_Number__c = kid.Contact_Number__c;
        upload.rC_Connect__Giving_Giving_Amount__c = 100;
        upload.Web_Transaction__c = wt.Id;
        insert upload;

        //paymentMethod = TestUtils.createPaymentMethod('Test Payment', householdAcc, 'Test Holder', 'Visa', '03', '12345', '15', true);
        rC_Connect__Payment_Method_Setting__c setting = rC_Connect__Payment_Method_Setting__c.getInstance();
        system.debug('---setting--' + setting);
        setting.rC_Connect__Disable_All__c = true;
        insert setting;
            
        rC_Giving__Payment_Method__c paymentMethodToInsert = TestUtils.createPaymentMethod('testPaymentMethod', 'EFT', true, null, false);
        //new rC_Giving__Payment_Method__c();
        //paymentMethodToInsert.rC_Giving__Is_Active__c = true;
        paymentMethodToInsert.RecordTypeId = PM_EFT_RT;
        //paymentMethodToInsert.Name = 'testPaymentMethod';
        paymentMethodToInsert.rC_Giving__Contact__c = participant.Id;
        paymentMethodToInsert.rC_Connect__Payment_Processor__c = 'Sage'; 
        paymentMethodToInsert.rC_Connect__Merchant_Name__c = 'testMerchantName';
        //paymentMethodToInsert.rC_Giving__Payment_Type__c = 'EFT';
        //paymentMethod.rC_Giving__Account__c = con.AccountId;
        insert paymentMethodToInsert;
        system.debug('---paymentMethod---' + paymentMethod);
        System.debug('---paymentMethodInserted-----'+ [select id from rC_Giving__Payment_Method__c where id =: paymentMethodToInsert.Id]);
        
        paymentMethod = [select Id, RecordTypeId, rC_Connect__Merchant_Name__c, Account_Number_E__c, rC_Connect__Payment_Processor__c,  Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where id =: paymentMethodToInsert.Id  limit 1];
        
        
        Campaign testCamp = TestUtils.createCampaign('Test Campaign', true);
        
        upload = TestUtils.createBatchUpload('Test Batch Upload', false);
        upload.Web_Transaction__c = wt.Id;
        upload.rC_Connect__Batch_Upload_Status__c = 'New';
        upload.rC_Connect__Batch_Upload_Campaign_Matched__c = testCamp.Id;
        upload.rC_Connect__Giving_Giving_Frequency__c = 'Annually';
        upload.rC_Connect__Giving_Giving_Amount__c = 100;
        upload.Product_Type__c = 'Designated Fund';
        
        insert upload;

    }
    
} // END public with sharing class MCSCPRRequestTest