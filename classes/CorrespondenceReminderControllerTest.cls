/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CorrespondenceReminderController
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Test class for Controller class of CorrespondenceReminder page
 * Created Date : 01/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/05/2016					Karl Houseknecht		Created
 * 09/Feb/2016					Rohit B.				Added method "test_processRemindersTest"
 **********************************************************************************************************/
@isTest
public class CorrespondenceReminderControllerTest 
{
	@isTest 
    static void test_processRemindersTest() {
		System.debug('[RB] - CorrespondenceReminderControllerTest.test_processRemindersTest :: Method Start..');
		
		String accNORTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
		Account NO_Acc = TestUtils.createAccountWithRT('Test NO Account', accNORTId, null, '163', '10345', true);

		Test.setCurrentPage(Page.CorrespondenceReminder);
    	ApexPages.currentPage().getParameters().put('id', NO_Acc.Id);
    	ApexPages.currentPage().getParameters().put('retURL', NO_Acc.Id);
    	CorrespondenceReminderController crc = new CorrespondenceReminderController();
    	Test.startTest();
    		crc.processReminders();
    		crc.returnToRecord();
    		crc.returnToListView();
    	Test.stopTest();
    	crc.refreshJobInfo();
    	ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.debug('[RB] - CorrespondenceReminderControllerTest.test_processRemindersTest :: PageMessage 0 = ' + pageMessages[0].getSummary()); 
        System.assertEquals(pageMessages[0].getSummary().contains('Correspondence Reminder batch job'), true);
		
		System.debug('[RB] - CorrespondenceReminderControllerTest.test_processRemindersTest :: Method End..');
	} // END static void test_processRemindersTest() {
} // END public class CorrespondenceReminderControllerTest