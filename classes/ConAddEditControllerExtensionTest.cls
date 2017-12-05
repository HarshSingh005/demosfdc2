/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ConAddEditControllerExtensionTest
 * Created By   : Vaibhav Goel (Appirio)
 * Purpose      : Test class for ContactAddressEditControllerExtension
 * Created Date : 18/March/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/03/2016                   Vaibhav Goel            Created
 **********************************************************************************************************/
@isTest
private class ConAddEditControllerExtensionTest {
    
    // Declaring all static variable for Account Record types
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
	
	//Declaring static variable for contact Record types
	Final Static Id CON_HD_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
	Final Static Id CON_PT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
	
	private static Account nationalOffice, localPartner, community , acc;
    private static Contact con;
    private static rC_Bios__Contact_Address__c conAddress, conAddressInsert;
    private static rC_Bios__Address__c prefMailingAddTemp;
    private static List<AddressValidationComponentController> addValComConInstanceList;
	
	private static testMethod void test() {
        createTestData();
        test.startTest();
             
            PageReference pageRef = Page.ContactAddressEdit;
            //system.debug('---conId--------' + con.Id);
            //pageRef.getParameters().put('id', String.valueOf(con.Id));
            Test.setCurrentPage(pageRef);
        
            ApexPages.StandardController sc = new ApexPages.StandardController(conAddress);
            ContactAddressEditControllerExtension controllerInstance = new ContactAddressEditControllerExtension(sc);
            system.assertEquals(controllerInstance.AddressControllers.size(), 0);
            
            //Now, we the controller instance is created and we can use it's variable - 'address' of type ValidatedAddress and assign the value to the 
            //variable -'address' of class 'AddressValidationComponentController'
            addValComConInstanceList.get(0).address  = controllerInstance.address;
            
            //Now, the value of the variable - 'AddressControllers' of class 'AddressEditControllerExtension' is blank because that is going to be filled through VF page. 
            //So, explicitly assinging the value to this list. 
            controllerInstance.AddressControllers = addValComConInstanceList;
            system.assertEquals(controllerInstance.AddressControllers.size(), 1);
            system.debug('---controllerInstance.AddressControllers---' + controllerInstance.AddressControllers);
            
            controllerInstance.Save();
            controllerInstance.SaveAndNew();
            controllerInstance.Cancel();
            
            //testing for exceptions by setting NULL value of the varibale - "address.rcBiosContactAddress" of controllerInstance
            controllerInstance.address.rcBiosContactAddress = null;
            controllerInstance.Save();
            controllerInstance.SaveAndNew();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());
            
            ApexPages.StandardController sc1 = new ApexPages.StandardController(conAddressInsert);
            ContactAddressEditControllerExtension controllerInstance1 = new ContactAddressEditControllerExtension(sc1);
            
            system.assertEquals(controllerInstance1.AddressControllers.size(), 0);
            controllerInstance1.Save();
            controllerInstance1.SaveAndNew();
            
            
        test.stopTest();
            
	}
	
	private static void createTestData(){
	    //create account and contact data
        acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        insert acc;
        
        con = TestUtils.createContact(acc,'test','test',false);
        insert con;
        
        prefMailingAddTemp = TestUtils.createAddress('test Street 1', 'test Street 2', 'test City', '12311', 'test country', false);
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        insert prefMailingAddTemp;
        
        conAddress = TestUtils.createContactAddress(con, prefMailingAddTemp, false);
        conAddress.rC_Bios__Type__c = 'Work';
        conAddress.rC_Bios__Original_Street_Line_1__c = 'test Street 1';
        conAddress.rC_Bios__Original_Street_Line_2__c = 'test Street 2';
        conAddress.rC_Bios__Original_City__c = 'Texas';
        conAddress.rC_Bios__Original_Postal_Code__c = '12311';
        conAddress.rC_Bios__Original_Country__c = 'USA';
        conAddress.rC_Bios__Preferred_Mailing__c = false;
        conAddress.rC_Bios__Preferred_Other__c = false;
        conAddress.rC_Bios__Type__c = 'Home';
        conAddress.rC_Bios__Do_Not_Mail__c = true;
        conAddress.rC_Bios__Active__c = true;
        conAddress.rC_Bios__Verified__c = true;
        conAddress.rC_Bios__Seasonal_Start_Month__c = '02';
        conAddress.rC_Bios__Seasonal_End_Month__c = '11';
        conAddress.rC_Bios__Seasonal_Start_Day__c = '01';
        conAddress.rC_Bios__Seasonal_End_Day__c = '25';
        conAddress.Returned_Mail__c = true;
        conAddress.Informational__c = true;
        conAddress.Care_Of__c = con.Id;
        conAddress.rC_Bios__Start_Date__c = Date.Today();
        conAddress.rC_Bios__End_Date__c = Date.Today() + 5;
        insert conAddress;
        system.debug('---conAddressPostInsert---' + conAddress);
        
        
        conAddressInsert = TestUtils.createContactAddress(con, prefMailingAddTemp, false);
        conAddressInsert.rC_Bios__Type__c = 'Work';
        conAddressInsert.rC_Bios__Original_Street_Line_1__c = 'test Street 1';
        conAddressInsert.rC_Bios__Original_Street_Line_2__c = 'test Street 2';
        conAddressInsert.rC_Bios__Original_City__c = 'Texas';
        conAddressInsert.rC_Bios__Original_Postal_Code__c = '12311';
        conAddressInsert.rC_Bios__Original_Country__c = 'USA';
        conAddressInsert.rC_Bios__Preferred_Mailing__c = false;
        conAddressInsert.rC_Bios__Preferred_Other__c = false;
        conAddressInsert.rC_Bios__Type__c = 'Home';
        conAddressInsert.rC_Bios__Do_Not_Mail__c = true;
        conAddressInsert.rC_Bios__Active__c = true;
        conAddressInsert.rC_Bios__Verified__c = true;
        conAddressInsert.rC_Bios__Seasonal_Start_Month__c = '02';
        conAddressInsert.rC_Bios__Seasonal_End_Month__c = '11';
        conAddressInsert.rC_Bios__Seasonal_Start_Day__c = '01';
        conAddressInsert.rC_Bios__Seasonal_End_Day__c = '25';
        conAddressInsert.Returned_Mail__c = true;
        conAddressInsert.Informational__c = true;
        conAddressInsert.Care_Of__c = con.Id;
        conAddressInsert.rC_Bios__Start_Date__c = Date.Today();
        conAddressInsert.rC_Bios__End_Date__c = Date.Today() + 5;
        system.debug('---conAddressInsert---' + conAddressInsert);
       	
       	
       	addValComConInstanceList = new List<AddressValidationComponentController>();
        
        AddressValidationComponentController addValComConInstance = new AddressValidationComponentController();
        //addValComConInstance.address  - Assigning value of this variable once we instanitate the controller and then use the ValidatedAddress variable of controller. 
        addValComConInstance.IsLine1Required = true;
        addValComConInstance.IsLine2Required = true;
        addValComConInstance.IsCityRequired = true;
        addValComConInstance.IsStateProvRequired = true;
        addValComConInstance.IsCountryRequired = true;
        addValComConInstance.IsPostalCodeRequired = true;
        
        addValComConInstanceList.add(addValComConInstance);
        
	}

}