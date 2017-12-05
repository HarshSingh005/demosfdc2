/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PreferenceTriggerHandler
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Trigger Handler class of PreferenceTrigger, Trigger on Preference object
 * Created Date : 07/June/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
public class PreferenceTriggerHandler { 
	public static void onBeforeUpdate(Map <Id, rC_Bios__Preference__c> oldMap, List <rC_Bios__Preference__c> newList) {
        System.debug('[RB] - PreferenceTriggerHandler.onBeforeUpdate :: Method Start..');
		restrictUpdateDeleteAllianceUser(oldMap, newList);
        System.debug('[RB] - PreferenceTriggerHandler.onBeforeUpdate :: Method End..');
    } // END public static void onBeforeDelete(list <rC_Bios__Preference__c> prefList) {

	public static void onBeforeDelete(List <rC_Bios__Preference__c> oldList, Map <Id, rC_Bios__Preference__c> oldMap) {
        System.debug('[RB] - PreferenceTriggerHandler.onBeforeDelete :: Method Start..');
        restrictUpdateDeleteAllianceUser(oldMap, oldList);
		System.debug('[RB] - PreferenceTriggerHandler.onBeforeDelete :: Method End..');
    } // END public static void onBeforeDelete(list <rC_Bios__Preference__c> prefList) {

	// Reference : T-501352
    // This method is used to prevent delete/update the record if user is "Alliance Partner User" and preference is auto assigned.
    public static void restrictUpdateDeleteAllianceUser(Map <Id, rC_Bios__Preference__c> oldMap, List <rC_Bios__Preference__c> prefList) {
		String allianceUserProfileID = [SELECT Id FROM Profile WHERE Name='Alliance Partner User' LIMIT 1].Id;
		for (rC_Bios__Preference__c pref : prefList) {
			if (userinfo.getProfileId() == allianceUserProfileID && pref.Auto_Assign_Preference__c == true) {
				pref.addError('You cannot update or delete a preference record created automatically by the system.');
			}
		}
    } // END public static void updateParticipantsOnPaymentReceived(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){

} // END public class PreferenceTriggerHandler {