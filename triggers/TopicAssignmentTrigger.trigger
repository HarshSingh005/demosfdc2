/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TopicAssignmentTrigger
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Trigger on TopicAssignment Object T-522892
 * Created Date : 08/31/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/31/2016                   Munib Ur Rehman         Created
 **********************************************************************************************************/
trigger TopicAssignmentTrigger on TopicAssignment (after insert) {

    if(TriggerState.isActive('TopicAssignmentTrigger')) {
        // Call Service(Helper) methods for After Save
        if (Trigger.isAfter && Trigger.isInsert) {
                TopicAssignmentService.OnAfterInsert(Trigger.New, Trigger.newMap);
        }
    }
}