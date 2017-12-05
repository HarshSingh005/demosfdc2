/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ValidateAddressTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the ValidateAddress
 * Created Date : 10/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 10/04/2016                   Munib Ur Rehman       Created
 **********************************************************************************************************/
@isTest
public with sharing class ValidateAddressTest
{
	//Static variables to be used throughout the test class
    Static rC_Bios__Account_Address__c acctAddress;
    Static rC_Bios__Contact_Address__c contAddress;
    Static rC_Bios__Address__c prefMailingAddTemp;
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Static ValidatedAddress validateAdd1;
    
    
	@isTest
	public static void testValidateAddress() {
    	//setting up of all data 
    	setUpTestData();
        Test.startTest();
    	rC_Bios__Address__c biosAddress = validateAdd1.rcBiosAddress;
    	
    	// Asserting the variable should contain the Country as the Validates Address's country
    	System.assertEquals(biosAddress.rC_Bios__Country__c , 'USA');
        rC_Bios__Contact_Address__c contactAddress1= validateAdd1.rcBiosContactAddress;
        rC_Bios__Account_Address__c acctAddress1 = validateAdd1.rcBiosAccountAddress;
        
        // Asserting the variable should contain the Country as the Validates Address's country
        System.assertEquals(acctAddress1.rC_Bios__Original_Country__c, 'USA'); 
        test.stopTest();
    } 
    
   
    public static void setUpTestData() {
    	//Creating Account
        Account acc = TestUtils.createAccount('Test Account',False);
        acc.RecordTypeId = ACC_HH_RT;
        insert acc;
        
        //Creating Contact
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
        
        // Creating AccountAddress from Bios Address
        acctAddress = TestUtils.createAccountAddress(acc, prefMailingAddTemp, true);
        
        //Creating Contact Address from Bios Address
        contAddress = TestUtils.createContactAddress(contact, prefMailingAddTemp, true);
        
        //Creating Validate Address Instances from diffrent constructors.
        validateAdd1 = new ValidatedAddress('line1','line2','line3','city','stateProv','100100','USA','111111',true, true);
        validateAdd1.IsChanged = true;
        validateAdd1.rcaddress = prefMailingAddTemp;
        validateAdd1.rcContactAddress = contAddress;
        validateAdd1.rcAccountAddress = acctAddress;
    	ValidatedAddress validateAdd2 = new ValidatedAddress(prefMailingAddTemp);
    	ValidatedAddress validateAdd3 = new ValidatedAddress(acctAddress);
    	ValidatedAddress validateAdd4 = new ValidatedAddress(contAddress);
        ValidatedAddress validateAdd5 = new ValidatedAddress(); 
    	
    } // END public static void setUpTestData() {
    
} // END public with sharing class AddressValidateResponseTest