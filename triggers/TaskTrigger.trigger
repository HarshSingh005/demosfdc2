trigger TaskTrigger on Task (before insert, before update) {
    
    if(TriggerState.isActive('TaskTrigger')) {
        TaskService.copyDueDateToCustomField(Trigger.New);
    }
    
}