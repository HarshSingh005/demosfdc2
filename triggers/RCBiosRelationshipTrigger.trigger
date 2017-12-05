// 
// (c) 2015 Appirio, Inc.
//
// After Insert, After Update Trigger for rC_Bios__Relationship__c custom object.
//
// 23rd Dec 2015     Sumit Tanwar       Original Ref - T-460324
// 18/Jan/2016       Rohit B            Original Ref - T-466983 [Called a function create_Receiver_Giver_Relationship]
//March/8/2016       Vaibhav Goel       Original Ref-  T-481852 [Adding some system debug to verify runnning status of trigger]
trigger RCBiosRelationshipTrigger on rC_Bios__Relationship__c (after insert /*, after update*/) {
    
    if(TriggerState.isActive('RCBiosRelationshipTrigger')) {
        
        if(Trigger.isAfter && Trigger.isinsert) {
            system.debug('---triggerLogicStarted-----');
            RCBiosRelationshipTriggerHelper.updatePreferences(Trigger.new);
            RCBiosRelationshipTriggerHelper.populateParticipantToOpps(Trigger.newMap.keySet()); 
            RCBiosRelationshipTriggerHelper.create_Receiver_Giver_Relationship(Trigger.new); //Added by Rohit B on 18/Jan/2016
            //RCBiosRelationshipTriggerHelper.deletePreferences(Trigger.new); //Added By Munib on 4th May 2016
            RCBiosRelationshipTriggerHelper.FifteenDayCorrespondencePause(trigger.new);
        }
    }
}