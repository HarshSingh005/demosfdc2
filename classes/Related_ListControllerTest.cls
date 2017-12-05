/***********************************************************************************************************
 * Appirio, Inc
 * Name         : Related_ListControllerTest 
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class for "Related_ListController" class
 * Created Date : 06/Apr/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 *   08/03/2015                     Munib Ur Rehman             Put appropriate assertions
 *   08/08/2015                     Munib Ur Rehman             Increased Code Coverage
 *  Aug 11, 2016                    Ashu Gupta                  Added asserts and taken care of coding conventions
 **********************************************************************************************************/
@isTest
private class Related_ListControllerTest {
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
	Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
	Final Static Id ACC_COM_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
	Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
	Final Static Id CON_PART_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
	
    @isTest
	private static void test_getRecords() {
	    Test.startTest();
	    ApexPages.Message[] pageMessages;
        Related_ListController rlc = new Related_ListController();
        List<sObject> lstSobj = rlc.getRecords();
        System.assert(lstSobj == null); // when there are no fields specified asserting the returned list as null
        pageMessages = ApexPages.getMessages();
        system.debug('message @@@'+pageMessages[0].getSummary());
        System.assertEquals(pageMessages[0].getSummary().contains('fieldList or fieldsCSV attribute must be defined.'), true);
        
        rlc.objectName = 'Account';
        List<String> fieldNames = new List<String>();
        fieldNames.add('Id');
        fieldNames.add('Name');
        rlc.fieldsList = fieldNames;
        rlc.sortDirection = 'abc';
        lstSobj = rlc.getRecords();
        System.assert(lstSobj == null);// when the sort Direction is not 'asc' or 'desc' but something else then list value returned is null
        pageMessages = ApexPages.getMessages();
        system.debug('message @@@'+pageMessages[1].getSummary());
        System.assertEquals(pageMessages[1].getSummary().contains('sortDirection attribute must have value of "asc" or "desc"'), true);
        
        rlc.sortDirection = 'asc';
        lstSobj = rlc.getRecords();
        System.assert(rlc.nameLabelMap.size()>0);// When there are 
        
        rlc.orderByFieldName = 'Name';
        rlc.sortDirection = 'desc';
        lstSobj = rlc.getRecords();
        System.assert(rlc.nameLabelMap.size()>0); // The map to fill labels is also filled
        
        Related_ListController rlc1 = new Related_ListController();
        rlc1.objectName = 'Contact';
        rlc1.sortDirection = 'asc';
        rlc1.fieldsCSV = 'Id, Name, Account.Name, Account.Owner.Name';
        rlc1.searchFieldValue = 'Brickbounce limited';
        rlc1.searchFieldName = 'Name';
        rlc1.filter = 'Name=\'Amazon Services\'';
        rlc1.sortByField = 'Name';
        rlc1.pageSize = 10;
        rlc1.deleteRecordId = '00329000002ymDD';
        rlc1.pageNumber = 1;
        rlc1.title = 'Contact Related List';
        rlc1.returnUrl = '003/o';
        rlc1.moreLink = 'Y';
        rlc1.showAsStandardRelatedList = true;
        lstSobj = rlc1.getRecords();
        System.assert(rlc.nameLabelMap.size()>0); //The map to fill labels is also filled
        System.assert(rlc.fieldAlignMap.size()>0);// The field Align Map is also filled when all proper values are sent for query
        rlc1.showMore();
        
        Boolean res = rlc1.getShowNewButton();
        System.assertEquals(res,true);
        
        Contact contactReturned = [SELECT id FROM Contact ];
        System.debug('Contcat before del @@@'+contactReturned);
        rlc1.deleteRecord();
        rlc1.sortByFieldAction();
         contactReturned = [SELECT id FROM Contact];
        System.debug('Contact after del @@@'+contactReturned);
        test.stopTest();
	} // END private static void test_getRecords() {
	
	@isTest
	private static void test_getRecords2() {
        Related_ListController rlc = new Related_ListController();
        List<sObject> lstSobj = rlc.getRecords();
        System.assert(lstSobj == null); // when there are no foelds specified asserting the returned list as null
        
        rlc.objectName = 'Account';
        List<String> fieldNames = new List<String>();
        fieldNames.add('Id');
        fieldNames.add('Name');
        rlc.fieldsList = fieldNames;
        rlc.sortDirection = 'abc';
        lstSobj = rlc.getRecords();
        System.assert(lstSobj == null);// when the sort Direction is not 'asc' or 'desc' but something else then list value returned is null
        rlc.sortDirection = 'asc';
        lstSobj = rlc.getRecords();
        System.assert(rlc.nameLabelMap.size()>0);// When there are 
        
        rlc.orderByFieldName = 'Name';
        rlc.sortDirection = 'desc';
        lstSobj = rlc.getRecords();
        System.assert(rlc.nameLabelMap.size()>0); // The map to fill labels is also filled
        
        Related_ListController rlc1 = new Related_ListController();
        rlc1.objectName = 'Account';
        rlc1.sortDirection = 'asc';
        rlc1.fieldsCSV = 'Id, Name';
        rlc1.searchFieldValue = 'Brickbounce limited';
        rlc1.searchFieldName = 'Name';
        //rlc1.filter = 'Name=\'Amazon Services\'';
        rlc1.orderByFieldName = 'Name';
        rlc1.pageSize = 1;
        //rlc1.deleteRecordId = '00329000002ymDD';
        rlc1.pageNumber = 1;
        rlc1.title = 'Account Related List';
        //rlc1.moreLink = 'Y';
        rlc1.showAsStandardRelatedList = true;
        lstSobj = rlc1.getRecords();
        System.assert(rlc.nameLabelMap.size()>0); //The map to fill labels is also filled
        System.assert(rlc.fieldAlignMap.size()>0);// The field Align Map is also filled when all proper values are sent for query
        rlc1.showMore();
        Boolean res = rlc1.getShowNewButton();
        rlc1.deleteRecord();
        rlc1.sortByFieldAction();
	} // END private static void test_getRecords() {
	
	@testSetup
	static void createTestData() {
	    List<Account> NO_Acc_List = new List<Account>();
	    
    	Account NO_Acc1 = TestUtils.createAccountWithRT('1st National Account', ACC_NO_RT, null, '199', '1245', false);
    	NO_Acc1.BillingCountry = 'IN';
    	NO_Acc1.NO_Country__c = 'India';
    	NO_Acc_List.add(NO_Acc1);
    	
    	Account NO_Acc2 = TestUtils.createAccountWithRT('Brickbounce limited', ACC_NO_RT, null, '200', '1246', false);
    	NO_Acc_List.add(NO_Acc2);
    	
    	insert NO_Acc_List;
    	
    	List<Account> LP_Acc_List = new List<Account>();
        Account LP_Acc1 = TestUtils.createAccountWithRT('Google Retail Partner', ACC_LP_RT, NO_Acc1, '149', '1346', false);
        LP_Acc_List.add(LP_Acc1);
        Account LP_Acc2 = TestUtils.createAccountWithRT('Amazon Services', ACC_LP_RT, NO_Acc2, '150', '3347', false);
         LP_Acc_List.add(LP_Acc2);
         
         insert LP_Acc_List;
        Account Com_Acc1 = TestUtils.createAccountWithRT('Maheshwari Community Services', ACC_COM_RT, LP_Acc1, '159', '1247', true);
        Account HH_Acc = TestUtils.createAccountWithRT('Test Household Account', ACC_HH_RT, Com_Acc1, '565', '2134', true);
        
        integer colId = 0;
        Integer colNo = 0;
        integer j = 1;
        //for(integer j=0;j<20;j++){
        	colId = 3348+j;
        	colNo = 155+j;
        	TestUtils.createAccountWithRT('Brickbounce limited', ACC_LP_RT, NO_Acc2, String.valueOf(colNo), String.valueOf(colId), true);
        //}
        
        Contact con = TestUtils.createContact(HH_Acc, 'test fName', 'test lName', false);
        con.RecordTypeId = CON_PART_RT;
        //con.Community__c = Com_Acc1.id;
		//con.rC_Sponsorship__Sponsorship_Status__c = 'Available';
		//con.Participant_Case_Number__c = '34218';
        insert con;
	} // END static void createTestData() {
} // END private class Related_ListControllerTest {