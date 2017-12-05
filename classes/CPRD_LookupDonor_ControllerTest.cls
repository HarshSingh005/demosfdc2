/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CPRD_LookupDonor_ControllerTest
 * Created By   : Vaibhav Goel (Appirio)
 * Purpose      : Test class for CPRD_LookupDonor_Controller
 * Created Date : 29/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 27/09/2016                   Vaibhav Goel            Created
 **********************************************************************************************************/
@isTest
private class CPRD_LookupDonor_ControllerTest {
    
    Static Account HH_Acc;
    Static Contact householdCon;
    
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id CON_HD_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    
    private static testMethod void test() {
        
        test.startTest();
        
        createTestData();
        
        CPRD_LookupDonor_Controller controllerInstance = new CPRD_LookupDonor_Controller();
        controllerInstance.runQuery();
        system.assertEquals(controllerInstance.contacts, null);
        
        controllerInstance.query = 'Test';
        
        system.debug('---controllerInstance.query---' + controllerInstance.query );
        controllerInstance.runQuery();
        // Please put some more meaningfull asserts
        system.assertNotEquals(controllerInstance.contacts, null);
        system.debug('---controllerInstance.contacts---' + controllerInstance.contacts );
        
        test.StopTest();
    }
    
    private static void createTestData(){
        
        HH_Acc = TestUtils.createAccountWithRT('1st household Account test', ACC_HH_RT, null, '299', '22245', false);
        insert HH_Acc;
        
        //create the rC_Bios__Preferred_Mailing_Address__c test data 
        rC_Bios__Address__c prefMailingAddTemp = TestUtils.createAddress('test Street 1', 'test Street 2', 'test City', '12311', 'test country', false);
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        insert prefMailingAddTemp;
        
        rC_Bios__Address__c prefMailingAdd = [select id, Name, rC_Bios__Street_Line_1__c, rC_Bios__Street_Line_2__c,
                            rC_Bios__City__c, rC_Bios__State__c, rC_Bios__Postal_Code__c, rC_Bios__Country__c, rC_Bios__Unique_MD5__c
                            from rC_Bios__Address__c where id = :prefMailingAddTemp.Id limit 1];
                            
        householdCon = TestUtils.createContact(HH_Acc,'Test First Name','Test Last Name',false);
        householdCon.RecordTypeId = Contact_SnapshotController.CONTACT_RECORDTYPE_HOUSEHOLD;
        insert householdCon;
         system.debug('---householdCon.query---' + householdCon );
    }

}