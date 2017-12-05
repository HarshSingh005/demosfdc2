@isTest
private class TestSetPermissionSetForUserSchedulable {

    static testMethod void testSetPermissionSetForUser(){
		Test.startTest();
			String CRON_EXP = '0 0 0 3 9 ? 2022';
			SetPermissionSetForUserSchedulable schedulable = new SetPermissionSetForUserSchedulable();
			String jobId = System.schedule('SetPermissionSetForUserSchedulable', CRON_EXP, schedulable);
			CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

   			// Verify the expressions are the same
      		System.assertEquals(CRON_EXP, ct.CronExpression);

   			// Verify the job has not run
      		System.assertEquals(0, ct.TimesTriggered);

   			// Verify the next time the job will run
      		System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();
		
	}

}