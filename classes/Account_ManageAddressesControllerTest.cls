/***********************************************************************************************************
 * Appirio, Inc
 * Name         : Account_ManageAddressesControllerTest
 * Created By   : Ravi Chauhan (Appirio)
 * Purpose      : Test class for the Account_ManageAddressesController
 * Created Date : 07/19/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 07/19/2016                   Ravi Chauhan           Created
 * 07/19/2016                   vaibhav Goel           updated to ramp-up code coverage
 * 07/26/2016                   Ravi Chauhan           Increased Code Coverage
 **********************************************************************************************************/
@isTest
public class Account_ManageAddressesControllerTest {
    
    private static Account nationalOffice, localPartner, community , acc;
    private static rC_Bios__Account_Address__c accAddress;
    private static ValidatedAddress newAddress;
    private static List<rC_Bios__Account_Address__c> relatedAddressList;
    
    // Method to test successfull insertion of Address
    @isTest
    public static void testUpsertAccountAddressList(){
        
        createTestData();
        test.startTest();
        
        Test.setCurrentPageReference(Page.Account_ManageAddresses);
        System.currentPageReference().getParameters().put('id', acc.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Account_ManageAddressesController controllerInstance = new Account_ManageAddressesController(sc);
        controllerInstance.initialize();
        controllerInstance.address = newAddress;
        controllerInstance.accountAddressInsert.rC_Bios__Type__c = 'Home';
        PageReference saveOnly = controllerInstance.upsertAccountAddressList();
        test.stopTest();
        
        // Asssertion to check if the Pagereference is null
        System.AssertEquals(null,saveOnly);
    }
    
    // Method to test successfull insertion of Address and return Page Reference
    @isTest
    public static void testUpsertAccountAddressListAndReturn(){
        
        createTestData();
        test.startTest();
        
        Test.setCurrentPageReference(Page.Account_ManageAddresses);
        System.currentPageReference().getParameters().put('id', acc.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Account_ManageAddressesController controllerInstance = new Account_ManageAddressesController(sc);
        controllerInstance.initialize();
        controllerInstance.address = newAddress;
        controllerInstance.accountAddressInsert.rC_Bios__Type__c = 'Home';
        PageReference saveAndReturn = controllerInstance.upsertAccountAddressListAndReturn();
        test.stopTest();
    }
    /*Commented as no deleteRecord Method on Account_ManageAddressesController
    // Method to test deletion of selected address
    @isTest
    public static void testDeleteRecord(){
        
        createTestData();
        test.startTest();
        
        Test.setCurrentPageReference(Page.Account_ManageAddresses);
        System.currentPageReference().getParameters().put('id', acc.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Account_ManageAddressesController controllerInstance = new Account_ManageAddressesController(sc);
        controllerInstance.initialize();
        controllerInstance.delRecordId = accAddress.Id;
        PageReference deletion = controllerInstance.deleteRecord();
        test.stopTest();
        
        // Assertion that the address has been deleted
        Integer count = [SELECT count() FROM rC_Bios__Account_Address__c WHERE id = :controllerInstance.delRecordId ];
        System.AssertEquals(0,count);
    }
    */
    // Method to test successful insertion of related address
    @isTest
    public static void testInsertRelatedAddress(){
        
        createTestData();
        relatedAddressList = new List<rC_Bios__Account_Address__c>();
        relatedAddressList.add(accAddress);
        
        test.startTest();
        
        Test.setCurrentPageReference(Page.Account_ManageAddresses);
        System.currentPageReference().getParameters().put('id', acc.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Account_ManageAddressesController controllerInstance = new Account_ManageAddressesController(sc);
        controllerInstance.initialize();
        controllerInstance.relatedAddressList = relatedAddressList;
        PageReference insertRelated = controllerInstance.insertRelatedAddress();
        test.stopTest();
    }
    
    // Method to test Exception scenarios when insertion is done
    @isTest
    public static void testUpsertAccountAddressListExceptionScenario(){
        
        createTestData();
        test.startTest();
        
        Test.setCurrentPageReference(Page.Account_ManageAddresses);
        System.currentPageReference().getParameters().put('id', acc.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Account_ManageAddressesController controllerInstance = new Account_ManageAddressesController(sc);
        controllerInstance.initialize();
        newAddress.IsValid = False;
        controllerInstance.address = newAddress;
        controllerInstance.accountAddressInsert.rC_Bios__Type__c = 'Home';
        PageReference saveOnly = controllerInstance.upsertAccountAddressList();
        
        // Assertion that an exception message has been generated
        System.assert(ApexPages.getMessages().size() > 0);
        
        controllerInstance.accountAddressInsert.rC_Bios__Type__c = '';
        saveOnly = controllerInstance.upsertAccountAddressList();
        
        test.stopTest();
    }
    /*Commented as no deleteRecord Method on Account_ManageAddressesController
    // Method to test Exception scenarios when address id deleted
    @isTest
    public static void testDeletionExceptionScenario(){
        
        createTestData();
        test.startTest();
        
        Test.setCurrentPageReference(Page.Account_ManageAddresses);
        System.currentPageReference().getParameters().put('id', acc.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Account_ManageAddressesController controllerInstance = new Account_ManageAddressesController(sc);
        controllerInstance.initialize();
        controllerInstance.delRecordId = 'Invalid ID';
        PageReference deletion = controllerInstance.deleteRecord();
        test.stopTest();
        // Assertion that an exception message has been generated
        System.assert(ApexPages.getMessages().size() > 0);
    }
    */
    // Method to test Exception scenarios when controller is initialized
    @isTest
    public static void testInitializationExceptionScenario(){
        
        createTestData();
        test.startTest();
        
        Test.setCurrentPageReference(Page.Account_ManageAddresses);
        System.currentPageReference().getParameters().put('id', '');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Account_ManageAddressesController controllerInstance = new Account_ManageAddressesController(sc);
        controllerInstance.initialize();
        test.stopTest();
        
        // Assertion that an exception message has been generated
        System.assert(ApexPages.getMessages().size() > 0);
    }
    
    @isTest
    public static void testValidateFields(){
        
        createTestData();
        test.startTest();
        
        Test.setCurrentPageReference(Page.Account_ManageAddresses);
        System.currentPageReference().getParameters().put('id', acc.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Account_ManageAddressesController controllerInstance = new Account_ManageAddressesController(sc);
        controllerInstance.initialize();
        controllerInstance.AddressList = new List<ValidatedAddress>();
        newAddress.IsValid = True;
        newAddress.IsChanged = False;
        controllerInstance.address = newAddress;
        controllerInstance.accountAddressInsert.rC_Bios__Type__c = 'Home';
        PageReference saveOnly = controllerInstance.upsertAccountAddressList();
        
        newAddress.rcAccountAddress = null;
        newAddress.IsChanged = True;
        saveOnly = controllerInstance.upsertAccountAddressList();
        
        test.stopTest();
    }
    
    // Creation of test data
    private static void createTestData(){
        rC_Giving__Contact_Setting__c setting = new rC_Giving__Contact_Setting__c();
        setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert setting; 
        
        acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        insert acc;
        
        rC_Bios__Address__c prefMailingAddTemp = TestUtils.createAddress('test Street 1', 'test Street 2', 'test City', '12311', 'test country', false);
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        insert prefMailingAddTemp;
        
        accAddress = TestUtils.createAccountAddress(acc, prefMailingAddTemp, false);
        insert accAddress;
        
        newAddress = new ValidatedAddress();
        newAddress.Line1 = 'Street Line One';
        newAddress.Line2 = 'Street Line Two';
        newAddress.city = 'Gilbert';
        newAddress.stateProv = 'Arizona';
        newAddress.country = 'USA';
        newAddress.postalCode = '223344';
        newAddress.IsValid = True;
        
    }

}