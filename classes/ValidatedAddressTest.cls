/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ValidatedAddressTest 
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class of ValidatedAddress class
 * Created Date : July 27, 2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/


@isTest
private class ValidatedAddressTest {

    private static testMethod void test() {
    ValidatedAddress validate = new ValidatedAddress();
    ValidatedAddress validateWithParam = new ValidatedAddress('line1','line2',' line3', 'city', 
                            'stateProv','302018','USA', 'addressId', true, false);
                            
    rC_Bios__Address__c address = new rC_Bios__Address__c();
    address.rC_Bios__Street_Line_1__c = '1';
    insert address;
    
    ValidatedAddress validateWithAddress = new ValidatedAddress(address);
    
    rC_Bios__Contact_Address__c contactAddress = new rC_Bios__Contact_Address__c();
    ValidatedAddress validateContactAddress = new ValidatedAddress(contactAddress);
    validateContactAddress.rcBiosContactAddress = contactAddress;
    
     rC_Bios__Account_Address__c accountAddress = new rC_Bios__Account_Address__c();
     ValidatedAddress validateAccountAddress = new ValidatedAddress(accountAddress);
     validateAccountAddress.rcBiosAccountAddress = accountAddress;
     
     
                            
    
    }

}