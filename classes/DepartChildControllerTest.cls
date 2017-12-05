@isTest
private class DepartChildControllerTest {
    
    // Declaring all static variable for Account Record types
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id ACC_CO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    
    //Declaring static variable for contact Record types
    Final Static Id CON_PT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    
    Static Account HH_Acc, NO_Acc, NO_Acc2, localPartner, community;
    Static Contact participantCon;
    
    private static testMethod void testingDepartChild() {
        
        test.startTest();
            createTestData();
            ApexPages.StandardController sc = new ApexPages.StandardController(participantCon);
            DepartChildController controllerInstance = new DepartChildController(sc);
            controllerInstance.departChild();
            system.assertEquals(controllerInstance.conObj.Departed__c, true);
            
            participantCon.Community__c = null;
            participantCon.Local_Partner__c = null;
            update participantCon;
            sc = new ApexPages.StandardController(participantCon);
            DepartChildController controllerInstance1 = new DepartChildController(sc);
            controllerInstance1.departChild();
            String rtDeparted = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Departed Participant').getRecordTypeId();
            System.assert(controllerInstance1.conObj.RecordTypeId == rtDeparted);
        test.stopTest();
    }
    
    //creates the test data
    static void createTestData() {
        rC_Giving__Contact_Setting__c con_cust_setting = rC_Giving__Contact_Setting__c.getOrgDefaults();
        con_cust_setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert con_cust_setting;
        NO_Acc = TestUtils.createAccountWithRT('1st National Account test', ACC_NO_RT, null, '209', '21245', false);
        insert NO_Acc;
        
        //NO_Acc2 = TestUtils.createAccountWithRT('2nd National Account test',ACC_HH_RT, null, '300', '22246', false);
        //insert NO_Acc2;
        
        HH_Acc = TestUtils.createAccountWithRT('1st household Account test', ACC_HH_RT, null, '399', '22245', false);
        insert HH_Acc;
        
        Account acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = ACC_HH_RT;
        insert acc;
        
        localPartner = TestUtils.createAccountWithRT('Local Partner',ACC_LP_RT, NO_Acc, '10', '22247',false);
        localPartner.Local_Partner_ID__c = '1121134'; 
        insert localPartner;
        
        community = TestUtils.createAccountWithRT('Maheshwari Community Services', ACC_CO_RT, localPartner, '159', '1247', false);
        community.BillingStreet = 'test Street';
        community.BillingCity = 'test City';
        community.BillingState = 'test State';
        community.BillingPostalCode = '12311';
        community.BillingCountry = 'test country';
        insert community;
        
        rC_Bios__Address__c prefMailingAddTemp = TestUtils.createAddress('test Street 1', 'test Street 2', 'test City', '12311', 'test country', false);
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        insert prefMailingAddTemp;
        
        rC_Bios__Address__c prefMailingAdd = [select id, Name, rC_Bios__Street_Line_1__c, rC_Bios__Street_Line_2__c,
                            rC_Bios__City__c, rC_Bios__State__c, rC_Bios__Postal_Code__c, rC_Bios__Country__c, rC_Bios__Unique_MD5__c
                            from rC_Bios__Address__c where id = :prefMailingAddTemp.Id limit 1];
        
        system.debug('---prefMailingAdd---' + prefMailingAdd);
        
        participantCon = TestUtils.createContact(acc, 'test Participant first name', 'test Participant last name', false);
        participantCon.Community__c = community.id;
        participantCon.Participant_Case_Number__c = '11211';
        participantCon.rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored';
        participantCon.rC_Bios__Birth_Month__c = '02';
        participantCon.rC_Bios__Gender__c = 'Male';
        participantCon.rC_Bios__HOME_Email__c = 'testparticipanthomeemail@test.com';
        participantCon.Short_Name__c = 'testShortName';
        participantCon.rC_Bios__Preferred_Mailing_Address__c = prefMailingAdd.Id;
        System.debug('RSC >> participantCon ' + participantCon);
        participantCon.recordTypeId = CON_PT_RT; 
        insert participantCon;
        
    }  
}