@isTest
private class TestTaskTrigger {

    static testMethod void testCopyDueDate() {
		List<Task> tasks = new List<Task>();
        for(Integer i=0; i<200; i++){
        	tasks.add(TestUtils.createTask(Date.today().addDays(10), 'Desc', 'High', 'Not Started', 'Subj', false));
        }
        insert tasks;
        
        for(Task task : [SELECT Due_Date_Copy__c FROM Task WHERE Id IN: tasks]){
        	System.assertEquals(Date.today().addDays(10), task.Due_Date_Copy__c);
        }
        
        for(Task task :tasks){
        	task.ActivityDate = Date.today().addDays(2);
        }
        
        update tasks;
        
        for(Task task : [SELECT Due_Date_Copy__c FROM Task WHERE Id IN: tasks]){
        	System.assertEquals(Date.today().addDays(2), task.Due_Date_Copy__c);
        }
    }
}