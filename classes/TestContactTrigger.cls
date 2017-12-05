@IsTest
private with sharing class TestContactTrigger {

    static testmethod void testContactTriggerViaDML()
    {
        Account testAccount1 	= TestUtils.createAccount('Test Account1', true);
        Account testAccount2 	= TestUtils.createAccount('Test Account2', true);
		Contact testContact 	= TestUtils.createContact(testAccount1, 'fName', 'lName', true);        

		Id masterRtId 			= TestUtils.getRecordTypeId('X0_Master_Case','Case');    
		Case testCase1 			= TestUtils.createCase(masterRtId, 'Open', 'Standard', 'CS1', true, testAccount1.Id, testContact.Id);
		Case testCase2 			= TestUtils.createCase(masterRtId, 'Open', 'Standard', 'CS1', true, testAccount1.Id, testContact.Id);

		CheckRecursive.runContactOnce = false;
		testContact.AccountId 	= testAccount2.Id;
		update testContact;

        Case caseResult1 = [select Id, AccountId from Case where Id =: testCase1.Id];
        Case caseResult2 = [select Id, AccountId from Case where Id =: testCase2.Id];
        
        System.assertEquals(caseResult1.AccountId, testAccount2.Id);
        System.assertEquals(caseResult2.AccountId, testAccount2.Id);    
    }
}