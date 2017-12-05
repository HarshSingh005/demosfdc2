/******************************************************************************************************************
* Appirio, Inc
* Name         : CPRD_Home_Controller
* Created By   : 
* Purpose      : Controller class for page CPRD_Home
* Created Date : 
*
* Date Modified					Modified By             Description of the update
-------------------------------------------------------------------------------------------------------------------
* 15/Nov/2016					Rohit B					Added a method "getRecentlyViewedItems" and 
														called this method in constructor for I-243580
*******************************************************************************************************************/

public with sharing class CPRD_Home_Controller {
    public List<rC_Giving__Batch__c> batches { get; set; }
    public List<rC_Connect__Batch_Upload__c> batchUploads { get; set; }

    public CPRD_Home_Controller() {
        batches = [SELECT Batch_Number__c, FOC__c, rC_Connect__Distribution_End_Date__c, rC_Giving__Total_Value__c, rC_Giving__Remaining_Value__c, rC_Giving__Current_Number__c, rC_Giving__Total_Number__c FROM rC_Giving__Batch__c WHERE rC_Giving__Remaining_Number__c > 0 ORDER BY Id DESC];
        //batchUploads = [SELECT rC_Connect__HardCreditContact__r.Donor_Number__c, rC_Connect__HardCreditContact__r.Name, rC_Connect__Batch_Upload_Batch__r.Batch_Number__c, rC_Connect__Giving_Close_Date__c FROM rC_Connect__Batch_Upload__c ORDER BY Id DESC LIMIT 40];
		String batchUploadField = 'rC_Connect__HardCreditContact__r.Donor_Number__c, rC_Connect__HardCreditContact__r.Name, rC_Connect__Batch_Upload_Batch__r.Batch_Number__c, rC_Connect__Giving_Close_Date__c ';
		batchUploads = getRecentlyViewedItems('rC_Connect__Batch_Upload__c', batchUploadField, 40);
    }

	//Added by Rohit B on 15/Nov/2016 for issue I-243580
	private List<sObject> getRecentlyViewedItems(String objectName, String fieldsToFetch, Integer lmt) {
		List<sObject> recentItems = new List<sObject>();
		/*String recentItemsString = 'SELECT Id FROM RecentlyViewed WHERE Type = \''+objectName+'\' ORDER BY LastViewedDate DESC';
		recentItems = Database.query(recentItemsString);
		List<Id> objectIdList = new List<Id>();
		for(sObject recentObj : recentItems) {
			objectIdList.add(recentObj.Id);
		}*/

		String recentItemsQuery = 'Select Id, ' + fieldsToFetch + ' From ' + objectName +' WHERE LastViewedDate != null ORDER BY LastViewedDate DESC LIMIT ' + lmt;
		recentItems = Database.query(recentItemsQuery);
		return recentItems;
	}
}