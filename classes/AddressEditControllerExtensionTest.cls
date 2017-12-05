/***********************************************************************************************************
* Appirio, Inc
* Name         : AddressEditControllerExtensionTest
* Created By   : Vaibhav Goel (Appirio)
* Purpose      : Test class for the AddressEditControllerExtension
* Created Date : 27/07/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 27/07/2016                   Vaibhav Goel             Created
**********************************************************************************************************/
@isTest
private class AddressEditControllerExtensionTest {
    
    private static rC_Bios__Address__c address1;
    private static List<AddressValidationComponentController> addValComConInstanceList;
    
	private static testMethod void testingControllerExtension() {
        createTestData1();
        test.startTest();
            
            
            PageReference pageRef = Page.AddressEdit;
            //system.debug('---conId---' + con.Id);
            pageRef.getParameters().put('retURL', null);
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(address1);
            
            AddressEditControllerExtension controllerInstance = new AddressEditControllerExtension(sc);  
            
            system.assertEquals(controllerInstance.AddressControllers.size(), 0);
            
            //Now, we the controller instance is created and we can use it's variable - 'address' of type ValidatedAddress and assign the value to the 
            //variable -'address' of class 'AddressValidationComponentController'
            addValComConInstanceList.get(0).address  = controllerInstance.address;
            
            
            //Now, the value of the variable - 'AddressControllers' of class 'AddressEditControllerExtension' is blank because that is going to be filled through VF page. 
            //So, explicitly assinging the value to this list. 
            controllerInstance.AddressControllers = addValComConInstanceList;
            system.assertEquals(controllerInstance.AddressControllers.size(), 1);
        
            //calling save method 
            PageReference savePageRefResult = controllerInstance.Save();
            system.assertNotEquals(savePageRefResult, null);
            
            PageReference saveAndNewPageRefResult = controllerInstance.SaveAndNew();
            system.assertNotEquals(saveAndNewPageRefResult, null);
            
            PageReference cancelPageRefResult = controllerInstance.Cancel();
            system.assertNotEquals(cancelPageRefResult, null);
            
        test.stopTest();
	}
    
    private static testMethod void testingControllerExtension1() {
        createTestData();
        test.startTest();
            
            
            PageReference pageRef = Page.AddressEdit;
            //system.debug('---conId---' + con.Id);
            pageRef.getParameters().put('retURL', null);
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(address1);
            
            AddressEditControllerExtension controllerInstance = new AddressEditControllerExtension(sc);  
            
            system.assertEquals(controllerInstance.AddressControllers.size(), 0);
            
            //Now, we the controller instance is created and we can use it's variable - 'address' of type ValidatedAddress and assign the value to the 
            //variable -'address' of class 'AddressValidationComponentController'
            addValComConInstanceList.get(0).address  = controllerInstance.address;
            
            
            //Now, the value of the variable - 'AddressControllers' of class 'AddressEditControllerExtension' is blank because that is going to be filled through VF page. 
            //So, explicitly assinging the value to this list. 
            controllerInstance.AddressControllers = addValComConInstanceList;
            system.assertEquals(controllerInstance.AddressControllers.size(), 1);
        
            //calling save method 
            PageReference savePageRefResult = controllerInstance.Save();
            system.assertNotEquals(savePageRefResult, null);
            
            PageReference saveAndNewPageRefResult = controllerInstance.SaveAndNew();
            system.assertNotEquals(saveAndNewPageRefResult, null);
            
            PageReference cancelPageRefResult = controllerInstance.Cancel();
            system.assertNotEquals(cancelPageRefResult, null);
            
        test.stopTest();
	}
	
	private static void createTestData(){
	    
	    address1 = testUtils.createBiosAddress('TestAddressName', 'SUITE 5A-1204', '799 E DRAGRAM', 'TUSCON', 'Test Extra Address', 
	                                           'AZ', '85705', 'USA', 'testCareOf', 'testEnvelopeLine', true, true, false);
	    insert address1;
	    /*
	    address1.name = 'TestAddressName';
	    address1.rC_Bios__Street_Line_1__c = 'SUITE 5A-1204';
	    address1.rC_Bios__Street_Line_2__c = '799 E DRAGRAM';
	    address1.rC_Bios__City__c = 'TUSCON';
	    address1.Extra_Address_1__c = 'Test Extra Address';
        address1.rC_Bios__State__c = 'AZ';
        address1.rC_Bios__Postal_Code__c = '85705';
        address1.rC_Bios__Country__c = 'USA';
        address1.Care_of__c = 'testCareOf';
        address1.Envelope_Line__c = 'testEnvelopeLine';
        address1.Ind_Returned_Mail__c = true;
        address1.Validated__c = true;
        */
        
        
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
    
    private static void createTestData1(){
	    
	    address1 = testUtils.createBiosAddress('TestAddressName', 'SUITE 5A-1204', '799 E DRAGRAM', 'TUSCON', 'Test Extra Address', 
	                                           'AZ', '85705', 'USA', 'testCareOf', 'testEnvelopeLine', true, true, false);
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