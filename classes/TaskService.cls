public with sharing class TaskService {
	
	public static void copyDueDateToCustomField(List<Task> tasks){
		for(Task tsk : tasks){
			tsk.Due_Date_Copy__c = tsk.ActivityDate;
		}
	}
	
}