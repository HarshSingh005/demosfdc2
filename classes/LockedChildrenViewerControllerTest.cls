/***********************************************************************************************************
 * Appirio, Inc
 * Name         : LockedChildrenViewerControllerTest
 * Created By   : Vaibhav Goel(Appirio)
 * Purpose      : Test Class for Controller class - 'LockedChildrenViewerController' of Locked Children Viewer console page
 * 				: 
 * Created Date : 09/May/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 12/Dec/2016					Suminder Singh			Fixed for errors
 **********************************************************************************************************/
@isTest
private class LockedChildrenViewerControllerTest {
    
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_CO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static Id ACC_CF_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
	
	//Declaring static variable for contact Record types
	Final Static Id CON_PT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
	
	Static Account HH_Acc, NO_Acc, localPartner, community, cfAcc;
    Static Contact participantCon;
    
	private static testMethod void testingLockedChildrenViewerController() {
	    
	    test.StartTest();
	    
	    LockedChildrenViewerController instance = new LockedChildrenViewerController();
	    instance.UnlockChildren();
        
	    createTestData();
	    LockedChildrenViewerController instance1 = new LockedChildrenViewerController();
	    system.assert(instance1.Children != null);
	    system.debug('----' + instance1.Children);
	    
	    for(LockedChildrenViewerController.ChildWrapper c : instance1.Children){
	        c.Selected = true;
	    }
	    instance1.UnlockChildren();
        ApexPages.CurrentPage().getParameters().put('hasError','true');  

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('No Children selected.')) b = true;
        }
        system.assert(b);
        
        test.StopTest();
	}
    
     //creates the test data
    static void createTestData() {
        
        NO_Acc = TestUtils.createAccountWithRT('1st National Account test', ACC_NO_RT, null, '209', '21245', false);
        insert NO_Acc;
        
        HH_Acc = TestUtils.createAccountWithRT('1st household Account test', ACC_HH_RT, null, '299', '22245', false);
        insert HH_Acc;
        Account acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = ACC_HH_RT;
        insert acc;
        cfAcc = TestUtils.createAccountWithRT('1st ChildFund Account test', ACC_CF_RT, null, '210', '21140', false);
        insert cfAcc;
        
        rC_Sponsorship__Reserve__c reserveObj = TestUtils.createSponsorshipReserve('Website Shopping Cart Reserve', false);
        reserveObj.rC_Sponsorship__Approval_Notes__c = 'testNotes';
        reserveObj.rC_Sponsorship__Expiration_Date__c = system.today().addDays(10);
        reserveObj.rC_Sponsorship__Start_Date__c = system.today();
        reserveObj.rC_Sponsorship__Status__c = 'Active';
       // reserveObj.Name = '';
        insert reserveObj;
        
        localPartner = TestUtils.createAccountWithRT('Local Partner', ACC_LP_RT, NO_Acc, '211', '21925', false);
        //localPartner.Name = '';
        //localPartner.RecordTypeId = ;
        //localPartner.ParentId = NO_Acc.Id;
        localPartner.Local_Partner_ID__c = '1121145'; 
        insert localPartner;
        
        community = TestUtils.createAccountWithRT('Community', ACC_CO_RT, localPartner, null, '3467', false);
        community.BillingStreet = 'test Street';
        community.BillingCity = 'test City';
        community.BillingState = 'test State';
        community.BillingPostalCode = '12311';
        community.BillingCountry = 'test country';
        insert community;
        
         //create the rC_Bios__Preferred_Mailing_Address__c test data 
        rC_Bios__Address__c prefMailingAddTemp = TestUtils.createAddress('test Street 1', 'test Street 2', 'test City', '12311', 'test country', false);
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        insert prefMailingAddTemp;
        
        rC_Bios__Address__c prefMailingAdd = [select id, Name, rC_Bios__Street_Line_1__c, rC_Bios__Street_Line_2__c,
                            rC_Bios__City__c, rC_Bios__State__c, rC_Bios__Postal_Code__c, rC_Bios__Country__c, rC_Bios__Unique_MD5__c
                            from rC_Bios__Address__c where id = :prefMailingAddTemp.Id limit 1];
        
        system.debug('---prefMailingAdd---' + prefMailingAdd);
        
        participantCon = TestUtils.createContact(null, 'test Participant first name', 'test Participant last name', false);        
        participantCon.National_Office__c = NO_Acc.Id; 
       // participantCon.Community__c = community.id;
        participantCon.Local_Partner__c = localPartner.Id;
        participantCon.Participant_Case_Number__c = '11211';
        participantCon.rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored';
        participantCon.rC_Bios__Birth_Month__c = '02';
        participantCon.rC_Bios__HOME_Email__c = 'testparticipanthomeemail@test.com';
        participantCon.Short_Name__c = 'testShortName';
     //   participantCon.rC_Bios__Preferred_Mailing_Address__c = prefMailingAdd.Id;
        participantCon.rC_Sponsorship__Reserve__c = reserveObj.Id;
            participantCon.recordTypeId = CON_PT_RT;
        insert participantCon;
        //  Contact con=[SELECT ID ,Name,recordType.Name from Contact where ID=:participantCon.ID];
   //     System.assertEquals(con.recordType.Name, null);
        
      
        
        
    }
}