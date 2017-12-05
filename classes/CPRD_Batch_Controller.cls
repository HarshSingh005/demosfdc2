/******************************************************************************************************************
* Appirio, Inc
* Name         : CPRD_Batch_Controller
* Created By   : 
* Purpose      : Controller class for page CPRD_Batch
* Created Date : 
*
* Date Modified					Modified By             Description of the update
-------------------------------------------------------------------------------------------------------------------
* 16/Nov/2016					Rohit B					Modified query of fecthing batch upload records for I-244230
*******************************************************************************************************************/

public with sharing class CPRD_Batch_Controller {
    public rC_Giving__Batch__c batch { get; set; }
    public List<rC_Connect__Batch_Upload__c> batchUploads { get; set; }
    public String batchUploadStatusFilter {
        get {
            String filter = '<select><option value=\"\">- All -</option>';
            Schema.DescribeFieldResult fieldResult = rC_Connect__Batch_Upload__c.rC_Connect__Batch_Upload_Status__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry f : ple)
                filter+='<option value=\"'+f.getLabel()+'\">'+f.getLabel()+'</option>';
            return filter+'</select>';
        }
    }

    public CPRD_Batch_Controller() {
        batch = [SELECT Batch_Number__c, FOC__c, rC_Connect__Distribution_End_Date__c, rC_Giving__Total_Value__c, rC_Giving__Remaining_Value__c FROM rC_Giving__Batch__c WHERE Id=:ApexPages.currentPage().getParameters().get('id')];
        batchUploads = [SELECT rC_Connect__HardCreditContact__r.Name, rC_Connect__HardCreditContact__r.Donor_Number__c, rC_Connect__Batch_Upload_Sequence_Number__c, rC_Connect__Giving_Giving_Amount__c, rC_Connect__Batch_Upload_Status__c FROM rC_Connect__Batch_Upload__c WHERE rC_Connect__Batch_Upload_Batch__r.Id = :batch.Id ORDER BY rC_Connect__Batch_Upload_Sequence_Number__c];
    }
}