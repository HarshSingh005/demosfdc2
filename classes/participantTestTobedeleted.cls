@isTest
public class participantTestTobedeleted {
 public Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
 public Final Static Id ACC_COM_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
 public Final Static Id CON_PART_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId(); 
 public Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
 public Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    
@isTest
static void createTestData() {
Account acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = ACC_HH_RT;
        insert acc;
 Account NO_Acc1 = TestUtils.createAccountWithRT('1st National Account', ACC_NO_RT, null, '199', '1245', false);
        NO_Acc1.BillingCountry = 'IN';
        NO_Acc1.NO_Country__c = 'India';
        NO_Acc1.Used_On_Web__c = true;
        NO_Acc1.rC_Bios__Active__c = true;
        //NO_Acc1.Web_Threshold_OK__c = true;       //Field is not writeable
        NO_Acc1.PC_Available__c = 2;
        NO_Acc1.Web_Threshold__c = 1;
        NO_Acc1.Male_0_2__c = true;
        NO_Acc1.Male_3_5__c = true;
        NO_Acc1.Male_6_8__c = true;
        NO_Acc1.Male_9_10__c = true;
        NO_Acc1.Male_11_12__c = true;
        NO_Acc1.Female_0_2__c = true;
        NO_Acc1.Female_3_5__c = true;
        NO_Acc1.Female_6_8__c = true;
        NO_Acc1.Female_9_10__c = true;
        NO_Acc1.Female_11_12__c = true;
       insert NO_Acc1;
Account LP_Acc2 = TestUtils.createAccountWithRT('Amazon Services', ACC_LP_RT, NO_Acc1, '150', '3347', false);
insert LP_Acc2;

Account Com_Acc2 = TestUtils.createAccountWithRT('Bhargava Young', ACC_COM_RT, LP_Acc2, '160', '1448', false);
        insert Com_Acc2; 
rC_Sponsorship__Reserve__c reserve = TestUtils.createSponsorshipReserve('Website Shopping Cart Reserve', false);
        reserve.rC_Sponsorship__Status__c = 'Active';
        reserve.rC_Sponsorship__Start_Date__c = System.now().date().addDays(-365);
        reserve.rC_Sponsorship__Expiration_Date__c = System.now().date().addDays(365);
        insert reserve;
Contact cont2 = TestUtils.createContact(acc,'16th','December',False);
        cont2.Community__c = Com_Acc2.id;	
        cont2.Participant_Case_Number__c = '45665';
        cont2.rC_Sponsorship__Sponsorship_Status__c = 'Reserved';
        cont2.rC_Sponsorship__Reserve__c = reserve.Id;
        cont2.rC_Bios__Gender__c = 'Male';
        cont2.rC_Bios__Birth_Day__c = '07';
        cont2.rC_Bios__Birth_Month__c = '07';
        cont2.RecordTypeId = CON_PART_RT;
 insert cont2;
    
//  System.assertEquals([Select recordtype.Name from contact where Id=:cont2.ID].recordtype.Name, 'dummy');  
System.debug('Id of contact=====>'+cont2.ID);
}
}