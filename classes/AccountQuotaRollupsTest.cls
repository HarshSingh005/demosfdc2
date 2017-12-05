/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountQuotaRollupsTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the AccountQuotaRollups
 * Created Date : 27/01/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 27/01/2016                   Munib Ur Rehman       Created
 * 15/12/2016					Suminder Singh		  Fixed for errors and code coverage
 * 03/Apr/2016					Suminder Singh		  Fixed for errors and code coverage
 **********************************************************************************************************/
@isTest
public class AccountQuotaRollupsTest 
{
    public static Contact participant1, participant2, participant3, participant4;
    final static String CON_PR_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    final static String ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    final static String ACC_COM_RT=  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    public Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    final static String ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    
    
	public static testMethod void testUpdateLocalPartnerNationalOffice()
    {
        //create account and contact data
        rC_Giving__Contact_Setting__c con_cust_setting = rC_Giving__Contact_Setting__c.getOrgDefaults();
        con_cust_setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert con_cust_setting;
        
        
        List<Account> listAcc = new List<Account>();
        Account acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = ACC_HH_RT;
        listAcc.add(acc);
        //creating account record
        Account nationalOffice = TestUtils.createAccountWithRT('National Office', ACC_NO_RT, null, '899', '21245', false);
        nationalOffice.rC_Bios__Active__c  = true;
        listAcc.add(nationalOffice);
        
        insert listAcc;
        
        Account localPartner = TestUtils.createAccountWithRT('Local Partner', ACC_LP_RT, nationalOffice, '499', '21246', true);
        Account community = TestUtils.createAccountWithRT('Community', ACC_COM_RT, localPartner, '699', '2124', true);
		
        participant1 = testUtils.createContact(acc, 'Rajat', 'Bairathi', false);
        participant1.Community__c = community.id;
        participant1.RecordTypeId = CON_PR_RT;
        participant1.Participant_Case_Number__c = '87754';
        participant1.rC_Sponsorship__Sponsorship_Status__c = 'Available';
		participant1.rC_Giving__Track_Hard_Credits__c = true;
		participant1.DoNotUpdateReserve__c = true;
        insert participant1;
        
        participant2 = testUtils.createContact(acc, 'Rohit', 'Bhargava', false);
        participant2.Community__c = community.id;
        participant2.RecordTypeId = CON_PR_RT;
        participant2.Participant_Case_Number__c = '88654';
        participant2.rC_Sponsorship__Sponsorship_Status__c = 'Reinstateable';
		participant2.rC_Giving__Track_Hard_Credits__c = true;
		participant2.DoNotUpdateReserve__c = true;
        insert participant2;
        
        participant3 = testUtils.createContact(acc, 'Vaibhav', 'Goel', false);
        participant3.Community__c = community.id;
        participant3.RecordTypeId = CON_PR_RT;
        participant3.Participant_Case_Number__c = '87654';
        participant3.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
		participant3.rC_Giving__Track_Hard_Credits__c = true;
		participant3.DoNotUpdateReserve__c = true;
        insert participant3;
        
        participant4 = testUtils.createContact(acc, 'Vaibhav12', 'Goel23', false);
      //  participant4.Community__c = community.id;
        participant4.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId(); 
        participant4.Participant_Case_Number__c = '87554';
        participant4.rC_Sponsorship__Sponsorship_Status__c = 'Reserved';
        participant4.rC_Giving__Track_Hard_Credits__c = true;
        participant4.DoNotUpdateReserve__c = true; 
        participant4.Local_Partner__c = localPartner.id;
        insert participant4; 
        //Local Account
      Account  local_Part_Acc = TestUtils.createAccountWithRT('Test LP Account', ACC_LP_RT, nationalOffice, '904', '3467', false);
        local_Part_Acc.Local_Partner_ID__c = '1234567';
        insert local_Part_Acc;
       Contact  participant9 = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participant9.RecordTypeId = CON_PR_RT;
        participant9.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        participant9.Correspondence_Paused__c = false;
        participant9.Participant_Case_Number__c = '16485';
        participant9.Participant_Number__c = '54321';
        //participant.National_Office__c = national_Office_Acc.Id;
        participant9.Local_Partner__c = local_Part_Acc.id;
        //Local Accoutns
		insert participant9;
		System.debug('[RB] - AccountQuotaRollupsTest.createTestData_Account_Contact :: participant4.RecordTypeId => ' + participant4.RecordTypeId);
        System.assertEquals([Select ID, RecordType.Name FRoM contact where ID=: participant9.ID].RecordType.Name , 'Household');

        
        // Creating 
        Set<Id> accList = new Set<Id>();
        accList.add(community.Id);
        
        List<Contact> conList=[select id ,RecordType.Name
								from Contact
								where rC_Sponsorship__Sponsorship_Status__c = 'Reserved'
								 Limit 1];
								
		System.assertEquals(conList[0].RecordType.Name , 'Household');
        //test starts
        Test.startTest();
        AccountQuotaRollups rollupAccount = new AccountQuotaRollups(accList);
        rollupAccount.calcCommunityRollups();
        Test.stopTest();// test stops

        //asserting count for contact
       /* AggregateResult[] results8 = [select Community__c , count(id)mycount
								from Contact
								where
								RecordTypeId =: CON_PR_RT
								AND rC_Sponsorship__Sponsorship_Status__c = 'Reserved'
								//AND Community__c in :accList
								group by Community__c];
                List<Contact> conList=[select id ,RecordType.Name
								from Contact
								where rC_Sponsorship__Sponsorship_Status__c = 'Reserved'
								 Limit 1];
		System.assertEquals(conList[0].RecordType.Name , 'test');*/
        
    }
}