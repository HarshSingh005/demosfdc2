/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressValidateRestApiTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the AddressValidateRestApi
 * Created Date : 10/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 10/04/2016                   Munib Ur Rehman       Created
 **********************************************************************************************************/
@isTest
public with sharing class AddressValidateRestApiTest
{
    //Static variable to be used throught the test class
    Static rC_Bios__Account_Address__c acctAddress;
    Static rC_Bios__Contact_Address__c contAddress;
    Static rC_Bios__Address__c prefMailingAddTemp;
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    
    @isTest
    public static void testSearchAddress() {
        //setting up of all data 
        setUpTestData();
        Test.startTest();
        ValidatedAddress validateAdd1 = new ValidatedAddress('line1','line2','line3','city','stateProv','100100','Country','111111',true, false);
        validateAdd1.IsChanged = true;
        validateAdd1.rcaddress = prefMailingAddTemp;
        validateAdd1.rcContactAddress = contAddress;
        validateAdd1.rcAccountAddress = acctAddress;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        AddressValidateRestResponse res = AddressValidateRestApi.SearchAddress(validateAdd1);
        System.assertEquals(res.VerifyLevel , 'Multiple');
        test.stopTest();
    } 
    
    @isTest
    public static void testVerifyAddress() {
        //setting up of all data 
        setUpTestData();
        Test.startTest();
        ValidatedAddress validateAdd1 = new ValidatedAddress('line1','line2','line3','city','stateProv','100100','Country','111111',true, false);
        validateAdd1.IsChanged = true;
        validateAdd1.rcaddress = prefMailingAddTemp;
        validateAdd1.rcContactAddress = contAddress;
        validateAdd1.rcAccountAddress = acctAddress;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        AddressValidateRestResponse res = AddressValidateRestApi.VerifyAddress(validateAdd1);
        System.assertEquals(res.VerifyLevel , 'Multiple');
        test.stopTest();
    } 
    
     @isTest
    public static void testRefineAddress() {
        //setting up of all data 
        setUpTestData();
        Test.startTest();
        ValidatedAddress validateAdd1 = new ValidatedAddress('line1','line2','line3','city','stateProv','100100','Country','111111',true, false);
        validateAdd1.IsChanged = true;
        validateAdd1.rcaddress = prefMailingAddTemp;
        validateAdd1.rcContactAddress = contAddress;
        validateAdd1.rcAccountAddress = acctAddress;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        AddressValidateRestResponse res = AddressValidateRestApi.RefineAddress('11111','refinement','USA');
        System.assertEquals(res.VerifyLevel , 'Multiple');
        test.stopTest();
    } 
    
     @isTest
    public static void testAddressLayout() {
        //setting up of all data 
        setUpTestData();
        Test.startTest();
        ValidatedAddress validateAdd1 = new ValidatedAddress('line1','line2','line3','city','stateProv','100100','Country','111111',true,false);
        validateAdd1.IsChanged = true;
        validateAdd1.rcaddress = prefMailingAddTemp;
        validateAdd1.rcContactAddress = contAddress;
        validateAdd1.rcAccountAddress = acctAddress;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        AddressValidateRestResponse res = AddressValidateRestApi.AddressLayout('111111');
        System.assertEquals(res.VerifyLevel , 'Multiple');
        test.stopTest();
    } 
    
   
   public static void setUpTestData() {
    
    //Creating heirarchichal custom setting records
        Experian_REST_API_Settings__c settings = Experian_REST_API_Settings__c.getOrgDefaults();
        settings.Search_Address_Endpoint__c = 'capture/v1/search-address/text/';
        settings.Address_Layout_Endpoint__c = 'capture/v1/address-layout/';
        settings.Refine_Address_Endpoint__c = 'capture/v1/verify-address/text';
        settings.Base_URL__C = 'https://api.experianmarketingservices.com';
        settings.Verify_Address_Endpoint__c = 'capture/v1/verify-address/text/';
        settings.Auth_Token__c = '46b7599c-57e9-46e7-9556-9009b378ce5f';
        upsert settings;
        
        Account acc = TestUtils.createAccount('Test Account',False);
        acc.RecordTypeId = ACC_HH_RT;
        insert acc;
        
        Contact contact = TestUtils.createContact(acc,'Test First Name','Test Last Name',False);
        insert contact; 
        
        //create the rC_Bios__Preferred_Mailing_Address__c test data 
        prefMailingAddTemp = new rC_Bios__Address__c();
        prefMailingAddTemp.rC_Bios__Street_Line_1__c = 'test Street 1';
        prefMailingAddTemp.rC_Bios__Street_Line_2__c = 'test Street 2';
        prefMailingAddTemp.rC_Bios__City__c = 'test City';
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        prefMailingAddTemp.rC_Bios__Postal_Code__c = '12311';
        prefMailingAddTemp.rC_Bios__Country__c = 'test country';
        insert prefMailingAddTemp;
        
        acctAddress = TestUtils.createAccountAddress(acc, prefMailingAddTemp, true);
        contAddress = TestUtils.createContactAddress(contact, prefMailingAddTemp, true);
        
    } // END public static void setUpTestData() {
    
    
} // END public with sharing class AddressValidateResponseTest