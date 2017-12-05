/***********************************************************************************************************
 * Appirio, Inc
 * Name         : BatchUploadTriggerHandler
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Handler class for BatchUploadTrigger
 * Created Date : 04/Feb/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 05/Feb/2016                  Rohit B.                Added AggregateResult query with other conditions
 * 31/Mar/2016                  Rohit B.                Added condition 'if(ufGAU != Null)' in create_GL_Allocation
 * 11/Apr/2016                  Jagjeet Singh           Added Condition  'If giving Amount != null' in createGLA  I-212202
 * 10/May/2016                  Rohit B.                commented Opportunity update code in "create_GL_Allocation" method
 * 30/Jan/2017                  John Hecker             Adding exemption for Web Transactions in "createFinanceOriginCodeAllocations" I-255828
 **********************************************************************************************************/

public with sharing class BatchUploadTriggerHandler {
    static final string OPP_RT_TRANSACTION = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    public static void onAfterUpdate(Map<Id, rC_Connect__Batch_Upload__c> oldMap, List<rC_Connect__Batch_Upload__c> newList, Map<Id, rC_Connect__Batch_Upload__c> newMap) {
        // T-521545 MR method to insert Allocation Records on the basis of FOC Custom Setting match
        createFinanceOriginCodeAllocations(newMap, oldMap);
        
    // Created By Munib Ur Rehman on 09/06/2016 for T-521545
    //Purpose : When the batch's giving amount is updated , need to create additional records based on new amount and negate the old records.
        createGLAllocationsFortheUpdatedGivingAmount(newMap, oldMap);

        updateWebTransactionToFlagged(oldMap, newList);
    } // END public static void onAfterUpdate(

    public static void onBeforeInsert(List<rC_Connect__Batch_Upload__c> uploads)
    {
        lookupParticipantFromNumber(uploads);
    }
    
    public static void onAfterInsert(List<rC_Connect__Batch_Upload__c> newList, Map<Id, rC_Connect__Batch_Upload__c> newMap)
    {
        // T-521545 MR method to insert Allocation Records on the basis of FOC Custom Setting match
        createFinanceOriginCodeAllocations(newMap, null);
    }
    
    public static void OnBeforeUpdate(List<rC_Connect__Batch_Upload__c> newBatches, Map<Id, rC_Connect__Batch_Upload__c> batchOldMap)
    {
        lookupParticipantFromNumber(newBatches);
    }

    private static void updateWebTransactionToFlagged(Map<Id, rC_Connect__Batch_Upload__c> oldMap, List<rC_Connect__Batch_Upload__c> newList)
    {
        Set<Id> webTransactionids = new Set<Id>();

        for(rC_Connect__Batch_Upload__c batch : newList)
            if(batch.rC_Connect__Batch_Upload_Status__c == 'Flagged' && 
                oldMap.get(batch.id).rC_Connect__Batch_Upload_Status__c != 'Flagged' &&
                batch.Web_Transaction__c != null)
                    webTransactionids.add(batch.Web_Transaction__c);

        if(webTransactionids.size() > 0)
        {
            List<Web_Transaction__c> webTransactions = [select id, Status__c from Web_Transaction__c where id in :webTransactionids];

            for(Web_Transaction__c trans : webTransactions)
                trans.Status__c = 'Flagged';

            update webTransactions;
        }

    }
    
    //updates the participant field on batch upload if the participant number is specified
    //and the participant field is blank
    static void lookupParticipantFromNumber(List<rC_Connect__Batch_Upload__c> uploads)
    {
        //create a list of child numbers for query
        Set<string> childNumbers = new Set<string>();
        
        for(rC_Connect__Batch_Upload__c upload : uploads)
            if(upload.Participant__c == null && upload.Participant_Number__c != null)
                childNumbers.add(upload.Participant_Number__c);
       
        if(!childNumbers.isEmpty())
        {
            Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        
            List<Contact> kids = [select id, 
                                  Contact_Number__c 
                                  from contact 
                                  where recordtypeid = :participantRecordTypeId 
                                  and Contact_Number__c in :childNumbers];
            System.debug('Upload @@@'+uploads);
            System.debug('Contact@@@'+kids);
            for(rC_Connect__Batch_Upload__c upload : uploads)
                for(Contact kid : kids)
                    if(kid.Contact_Number__c == upload.Participant_Number__c)
                        upload.Participant__c = kid.id;
        }
    }
    
    // Created By Munib Ur Rehman on 09/06/2016 for T-521545
    //Purpose : Create GL Allocation Records on the basis of FOC Picklist Value which matches with FOC Custom Setting Record.
    static void createFinanceOriginCodeAllocations(Map <Id, rC_Connect__Batch_Upload__c> newMap, Map<Id, rC_Connect__Batch_Upload__c> oldMap){
        
        List<rC_Giving__GAU__c> gauList = new List<rC_Giving__GAU__c>(); // To Store GAU records
        Map <Id, rC_Giving__GAU__c> mapGAU = new Map <Id, rC_Giving__GAU__c> ();// Map GAU Id vs GAU Record
        Map <Id, List<rC_Connect__Batch_Upload__c>> mapGAUBatch = new Map <Id, List<rC_Connect__Batch_Upload__c>> ();// Map GAU Id vs Opportunity Record
        List <GL_Allocation__c> lstGLAToInsert = new List <GL_Allocation__c> ();// To Store Allocation Records for Insertion
        Map <Id, rC_Connect__Batch_Upload__c> batchMap = new Map <Id, rC_Connect__Batch_Upload__c> ();
        
        // Fetching only thsose records which have no gl allocations recods. This is only for update trigger
        if(Trigger.isUpdate) {
            for (rC_Connect__Batch_Upload__c bu: [SELECT Id, (select Id, Amount__c from GL_Allocation__r) , FOC__c, rC_Connect__Batch_Upload_Status__c, Web_Transaction__c
                    FROM rC_Connect__Batch_Upload__c WHERE Id in : newMap.keySet()
                ]){
                        batchMap.put(bu.Id, bu);
            }
        }
        
        // Check for the GAU Values when Opportunity FOC field matches with any custom Setting Record
        List<FOC__c> focSettings = FOC__c.getall().values();
        boolean notAllocated = false;
        //Iterating through the Opportunities
        for(rC_Connect__Batch_Upload__c batch : newMap.Values()){
            
            //exempting any Web Orders
            if(batch.Web_Transaction__c == NULL){
        
            // Iterating through FOC custom setting
            // Proccessing only those BU records which have BU Status as 'Flagged' or 'Committed' for Update Call
            if((Trigger.isInsert && batch.rC_Connect__Batch_Upload_Status__c != null && batch.rC_Connect__Batch_Upload_Status__c == 'Flagged') || 
            (Trigger.isUpdate && batchMap.get(batch.Id).rC_Connect__Batch_Upload_Status__c !=null && batchMap.get(batch.Id).rC_Connect__Batch_Upload_Status__c =='Flagged' && 
            ((batchMap.get(batch.Id).rC_Connect__Batch_Upload_Status__c != oldMap.get(batch.Id).rC_Connect__Batch_Upload_Status__c) || (batchMap.get(batch.Id).FOC__c != oldMap.get(batch.Id).FOC__c)) && batchMap.get(batch.Id).GL_Allocation__r.size() == 0)) { 
                for(FOC__c focSetting : focSettings){
                    if(batch.FOC__c!= null && String.valueOf(batch.FOC__c).subString(0,3) == focSetting.Name){
                        if(!mapGAUBatch.containsKey(focSetting.GAU_Id__c)){// Checking if map contains the gauId from Custom setting
                            List<rC_Connect__Batch_Upload__c> subBatchList = new List<rC_Connect__Batch_Upload__c>(); // creating a listof Opp to fill the map against GAU Ids
                            subBatchList.add(batch);
                            mapGAUBatch.put(focSetting.GAU_Id__c, subBatchList);
                        } else {
                            mapGAUBatch.get(focSetting.GAU_Id__c).add(batch);
                        }
                        break;
                    }// END if(batch.FOC__c!= null && String.valueOf(batch.FOC__c).subString(0,3) == focSetting.Name)
                } //END for(FOC__c focSetting : focSettings)
            } // END if(batch.rC_Connect__Batch_Upload_Status__c == 'Flagged')
            else if(Trigger.isUpdate && batchMap.get(batch.Id).rC_Connect__Batch_Upload_Status__c !=null && 
            batchMap.get(batch.Id).rC_Connect__Batch_Upload_Status__c =='Committed'
            && batchMap.get(batch.Id).rC_Connect__Batch_Upload_Status__c != oldMap.get(batch.Id).rC_Connect__Batch_Upload_Status__c && batchMap.get(batch.Id).GL_Allocation__r.size() > 0){
                /*notAllocated = true;
                List<GL_Allocation__c> allocationList = batchMap.get(batch.Id).GL_Allocation__r;
                for(GL_Allocation__c gla : allocationList){
                    if(gla.Amount__c < 0){
                        notAllocated = false;
                    }
                }*/
                //if(notAllocated){
                    for(FOC__c focSetting : focSettings){
                        if(batch.FOC__c!= null && String.valueOf(batch.FOC__c).subString(0,3) == focSetting.Name){
                            if(!mapGAUBatch.containsKey(focSetting.GAU_Id__c)){// Checking if map contains the gauId from Custom setting
                                List<rC_Connect__Batch_Upload__c> subBatchList = new List<rC_Connect__Batch_Upload__c>(); // creating a listof Opp to fill the map against GAU Ids
                                subBatchList.add(batch);
                                mapGAUBatch.put(focSetting.GAU_Id__c, subBatchList);
                            } else {
                                mapGAUBatch.get(focSetting.GAU_Id__c).add(batch);
                            }
                            break;
                        }// END if(batch.FOC__c!= null && String.valueOf(batch.FOC__c).subString(0,3) == focSetting.Name)
                    } //END for(FOC__c focSetting : focSettings)
                //}
            }
        } // END for(rC_Connect__Batch_Upload__c batch : newMap.Values();
        
        //Checking if map is not empty , then oly process the results
        if(!mapGAUBatch.keyset().isEmpty()){
            gauList = [select Id, Funding_Source__c,Receipt_Type__c  from rC_Giving__GAU__c where Id in :mapGAUBatch.keyset()];
            // Creating a mp of GAU Id vs GAUs
            for(rC_Giving__GAU__c gau: gauList){ 
                mapGAU.put(gau.Id, gau);
            }
            //Fetching All standard Allocations for the GAUs got from above 
            for (Standard_Allocation__c sa: [SELECT Id, Credit__c, Debit__c, GAU__c, GL_Account__c, IsObligation__c, GL_Account__r.Account_Type__c
                    FROM Standard_Allocation__c WHERE GAU__c in : mapGAU.keySet()
                ]) {
                if (mapGAUBatch.containsKey(sa.GAU__c)) {
                    // Creating GL Allocation Records based on the SA , List Of Batches and the GAU.
                    lstGLAToInsert.addAll(createGLA(sa, mapGAUBatch.get(sa.GAU__c), mapGAU.get(sa.GAU__c), false));
                }
            }
            if (lstGLAToInsert.size()> 0) {
                //insertion of Records
                System.debug('-------------lstGLAToInsert'+lstGLAToInsert);
                upsert lstGLAToInsert; // Ravi Chauhan | changed from insert to upsert to resolve issue during data loading
            }
        }
        //return mapGAUOpp;
        }
    }
    
    
    // T-542376 Modify GL Allocation Creation Method for Batch Upload
    //Purpose : When the batch's giving amount is updated , need to create additional records based on new amount and negate the old accounts.
    static void createGLAllocationsFortheUpdatedGivingAmount(Map <Id, rC_Connect__Batch_Upload__c> newMap, Map<Id, rC_Connect__Batch_Upload__c> oldMap){
        List<rC_Giving__GAU__c> gauList = new List<rC_Giving__GAU__c>(); // To Store GAU records
        Map <Id, rC_Giving__GAU__c> mapGAU = new Map <Id, rC_Giving__GAU__c> ();// Map GAU Id vs GAU Record
        Map <Id, List<rC_Connect__Batch_Upload__c>> mapGAUBatch = new Map <Id, List<rC_Connect__Batch_Upload__c>> ();// Map GAU Id vs Batch Record
        Map <Id, List<rC_Connect__Batch_Upload__c>> oldMapGAUBatch = new Map <Id, List<rC_Connect__Batch_Upload__c>> ();// Map Old GAU Id vs Old batch  Record
        List <GL_Allocation__c> lstGLAToInsert = new List <GL_Allocation__c> ();// To Store Allocation Records for Insertion
        
        // Getting the custom setting values 
        List<FOC__c> focSettings = FOC__c.getall().values();
        
        // looping through new giving values of batch upload
        for(rC_Connect__Batch_Upload__c batch : newMap.Values()){
            //exempting any Web Orders
            if(batch.Web_Transaction__c == NULL){
                    
            if(batch.rC_Connect__Giving_Giving_Amount__c != null && oldMap.get(batch.Id).rC_Connect__Giving_Giving_Amount__c != null 
            && batch.rC_Connect__Giving_Giving_Amount__c != oldMap.get(batch.Id).rC_Connect__Giving_Giving_Amount__c 
            && batch.FOC__c == oldMap.get(batch.Id).FOC__c && batch.rC_Connect__Batch_Upload_Status__c == 'Flagged'){
                for(FOC__c focSetting : focSettings){
                    if(batch.FOC__c!= null && String.valueOf(batch.FOC__c).subString(0,3) == focSetting.Name){
                        System.debug('inside.................');
                        if(!mapGAUBatch.containsKey(focSetting.GAU_Id__c)){// Checking if map contains the gauId from Custom setting
                            List<rC_Connect__Batch_Upload__c> subBatchList = new List<rC_Connect__Batch_Upload__c>(); // creating a listof Opp to fill the map against GAU Ids
                            subBatchList.add(batch);
                            mapGAUBatch.put(focSetting.GAU_Id__c, subBatchList);
                        } else {
                            mapGAUBatch.get(focSetting.GAU_Id__c).add(batch);
                        }
                        if(!oldMapGAUBatch.containsKey(focSetting.GAU_Id__c)){// Checking if map contains the gauId from Custom setting
                            List<rC_Connect__Batch_Upload__c> subBatchList = new List<rC_Connect__Batch_Upload__c>(); // creating a listof Opp to fill the map against GAU Ids
                            subBatchList.add(oldMap.get(batch.Id));
                            oldMapGAUBatch.put(focSetting.GAU_Id__c, subBatchList);
                        } else {
                            oldMapGAUBatch.get(focSetting.GAU_Id__c).add(oldMap.get(batch.Id));
                        }
                        break;
                    }// END if(batch.FOC__c!= null && String.valueOf(batch.FOC__c).subString(0,3) == focSetting.Name)
                } //END for(FOC__c focSetting : focSettings)
            }
            } //END Exempt any Web Orders
        }
        
        System.debug('mapGAUBatch.....'+mapGAUBatch);
        System.debug('oldMapGAUBatch.....'+oldMapGAUBatch);
        
        // Checking old value map and new value map if these are not empty
        if(!mapGAUBatch.keyset().isEmpty() && !oldMapGAUBatch.keyset().isEmpty()){
            gauList = [select Id, Funding_Source__c,Receipt_Type__c  from rC_Giving__GAU__c where Id in :mapGAUBatch.keyset()];
            // Creating a map of GAU Id vs GAUs
            for(rC_Giving__GAU__c gau: gauList){ 
                mapGAU.put(gau.Id, gau);
            }
            //Fetching All standard Allocations for the GAUs got from above 
            for (Standard_Allocation__c sa: [SELECT Id, Credit__c, Debit__c, GAU__c, GL_Account__c, IsObligation__c, GL_Account__r.Account_Type__c
                    FROM Standard_Allocation__c WHERE GAU__c in : mapGAU.keySet()
                ]) {
                if (mapGAUBatch.containsKey(sa.GAU__c)) {
                    // Creating GL Allocation Records based on the SA , List Of Batches and the GAU.
                    lstGLAToInsert.addAll(createGLA(sa, mapGAUBatch.get(sa.GAU__c), mapGAU.get(sa.GAU__c), false) );
                    lstGLAToInsert.addAll(createGLA(sa, oldMapGAUBatch.get(sa.GAU__c), mapGAU.get(sa.GAU__c), true));
                }
            }
            if (lstGLAToInsert.size()> 0) {
                //insertion of Records
                System.debug('-------------lstGLAToInsert'+lstGLAToInsert);
                insert lstGLAToInsert;
            }
        }
    }
    
     //static GL_Allocation__c createGLA(Standard_Allocation__c sa, Opportunity Opp) {
    static List <GL_Allocation__c> createGLA(Standard_Allocation__c sa, List <rC_Connect__Batch_Upload__c> batchUploadList, rC_Giving__GAU__c gau, Boolean isAddingNegations) {
        System.debug('[RB] - OpportunityService.createGLA :: Method Start..');
        List <GL_Allocation__c> glAllocationList = new List <GL_Allocation__c> ();
        for (rC_Connect__Batch_Upload__c batchUpload: batchUploadList) {
                GL_Allocation__c gla = new GL_Allocation__c();
            Integer amtSign = (batchUpload.rC_Connect__Batch_Upload_Status__c=='Flagged') ? 1 : -1;
            
            if(isAddingNegations){
                amtSign = -1;
            }
    
            if(sa.Credit__c != Null)
                gla.Percentage__c = amtSign * sa.Credit__c;
            else if(sa.Debit__c != Null)
                gla.Percentage__c = (-amtSign) * sa.Debit__c;
                
            gla.Batch_Upload__c = batchUpload.Id;
            gla.GL_Account__c = sa.GL_Account__c;
            //I-212202 - Added Null Check Condition - Jagjeet Singh
            if(batchUpload.rC_Connect__Giving_Giving_Amount__c != null){
                if(Trigger.isInsert) {
                    gla.Amount__c = (gla.Percentage__c * batchUpload.rC_Connect__Giving_Giving_Amount__c) / 100;
                } else {
                    //if(batchUpload.rC_Connect__Batch_Upload_Status__c =='Flagged') {
                        gla.Amount__c = (gla.Percentage__c * batchUpload.rC_Connect__Giving_Giving_Amount__c) / 100;
                    //} else if(batchUpload.rC_Connect__Batch_Upload_Status__c =='Committed') {
                        //gla.Amount__c = ((-1)*gla.Percentage__c * batchUpload.rC_Connect__Giving_Giving_Amount__c) / 100;
                    //}
                }
            }
            glAllocationList.add(gla);
        }
        return glAllocationList;
    } // END static GL_Allocation__c createGLA(Standard_Allocation__c sa, String OppId) {
    
    // commented Opportunity update code as per discussed with Shailendra on 10/May/2016 as it is causing the following error
    // This Transaction has already been Summarized to the General Ledger and cannot be modified. Please follow the process for backing out Transactions from the General Ledger.
    /*Munib static void create_GL_Allocation(Map<Id, rC_Connect__Batch_Upload__c> oldMap, List<rC_Connect__Batch_Upload__c> newList, Map<Id, rC_Connect__Batch_Upload__c> newMap) {
        System.debug('[RB] - BatchUploadTriggerHandler.create_GL_Allocation :: Method Start..');
        List<GL_Allocation__c> lstGLAToInsert = new List<GL_Allocation__c>();
        Undistributed_Funds_GAU__c ufGAU = Undistributed_Funds_GAU__c.getValues('GAU 1111');
        
        List<Id> gauIdList = new List<Id>();
        // Check for the GAU Values when Batch Upload FOC field matches with any custom Setting Record
        List<FOC__c> focSettings = FOC__c.getall().values();
        //Iterating through the Batch Upload
        for(rC_Connect__Batch_Upload__c batchUpload : newMap.Values()){
            // Iterating through FOC custom setting
            for(FOC__c focSetting : focSettings){
                if(batchUpload.FOC__c == focSetting.Name){
                    gauIdList.add(focSetting.GAU_Id__c);
                    break;
                }
            }
        }
        
        gauIdList.add(ufGAU.SFDC_Id__c);
        
        if(!gauIdList.isEmpty()) {
            List<Standard_Allocation__c> lstSA = [SELECT Id, Credit__c, Debit__c, GAU__c, GL_Account__c 
                                                FROM Standard_Allocation__c WHERE GAU__c in :gauIdList];munib */
            
            /*List<Opportunity> lstOpptoUpdate = new List<Opportunity>([SELECT Id, Name, rC_Giving__GAU__c, Date_of_Distribution__c 
                                                FROM Opportunity WHERE rC_Giving__GAU__c = :ufGAU.SFDC_Id__c AND 
                                                                    StageName = 'Completed' AND RecordTypeId=:OPP_RT_TRANSACTION]);*/
    
            /*munib Map<String, AggregateResult> mapGLA = new Map<String, AggregateResult>();
            for(AggregateResult ar : [Select Batch_Upload__c id, Count(Id)cnt, Sum(Amount__c)sum, 
                                        Batch_Upload__r.rC_Connect__Batch_Upload_Status__c status FROM GL_Allocation__c 
                                        WHERE Batch_Upload__c in: newList  
                                        GROUP BY Batch_Upload__c, Batch_Upload__r.rC_Connect__Batch_Upload_Status__c]) {
                mapGLA.put(String.valueOf(ar.get('id')), ar);
            }
            System.debug('[RB] - BatchUploadTriggerHandler.create_GL_Allocation :: mapGLA = ' + mapGLA);
            
            for(rC_Connect__Batch_Upload__c bu : newList) {
                System.debug('[RB] - BatchUploadTriggerHandler.create_GL_Allocation :: mapGLA.get(bu.Id) = ' + mapGLA.get(bu.Id));
                String flag = bu.rC_Connect__Batch_Upload_Status__c;
                System.debug('flag--------= ' + flag+'---'+oldMap);
                if((flag=='Flagged' || flag=='Committed') && (oldMap==null || flag != oldMap.get(bu.Id).rC_Connect__Batch_Upload_Status__c)) {
                    System.debug('innnnnnnnn' + flag);
                    if(mapGLA.get(bu.Id) == Null || (mapGLA.get(bu.Id)!= Null && mapGLA.get(bu.Id).get('status') == flag && mapGLA.get(bu.Id).get('sum') != 0)) {
                        for(Standard_Allocation__c sa : lstSA) 
                            lstGLAToInsert.add(createGLA(sa, bu, flag));munib*/
                        /*for(Opportunity opp : lstOpptoUpdate)
                            opp.Date_of_Distribution__c = System.today();*/
                    /*munib} // END if(mapGLA.get(bu.Id) == Null || (mapGLA.get(bu.Id)!= Null && mapGLA.get(bu.Id).get('status') == flag && mapGLA.get(bu.Id).get('sum') != 0)) {
                } // END if((flag=='Flagged' || flag=='Committed') && flag != oldMap.get(bu.Id).rC_Connect__Batch_Upload_Status__c) {
            } // END for(rC_Connect__Batch_Upload__c bu : newList) {
            System.debug('[RB] - BatchUploadTriggerHandler.create_GL_Allocation :: lstGLAToInsert = ' + lstGLAToInsert);
            //System.debug('[RB] - BatchUploadTriggerHandler.create_GL_Allocation :: lstOpptoUpdate = ' + lstOpptoUpdate);
            
            if(lstGLAToInsert.size() > 0)
                insert lstGLAToInsert;munib*/
            /*if(lstOpptoUpdate.size() > 0)
                update lstOpptoUpdate;*/
       /*munib } // END if(ufGAU != Null) {
        System.debug('[RB] - BatchUploadTriggerHandler.create_GL_Allocation :: Method End..');
    } // END public static void create_GL_Allocation(list<Opportunity> oppList) {

    static GL_Allocation__c createGLA(Standard_Allocation__c sa, rC_Connect__Batch_Upload__c bu, String flag) {
        System.debug('[RB] - BatchUploadTriggerHandler.createGLA :: Method Start..');
        GL_Allocation__c gla = new GL_Allocation__c();
        Integer amtSign = (flag=='Flagged') ? 1 : -1;

        if(sa.Credit__c != Null)
            gla.Percentage__c = amtSign * sa.Credit__c;
        else if(sa.Debit__c != Null)
            gla.Percentage__c = (-amtSign) * sa.Debit__c;

        gla.Batch_Upload__c = bu.Id;
        gla.GL_Account__c = sa.GL_Account__c;
        //I-212202 - Added Null Check Condition - Jagjeet Singh
        if(bu.rC_Connect__Giving_Giving_Amount__c != null){
            gla.Amount__c = (gla.Percentage__c * bu.rC_Connect__Giving_Giving_Amount__c) / 100;
        }
        System.debug('[RB] - BatchUploadTriggerHandler.createGLA :: Method End..');
        return gla;
    } // END static GL_Allocation__c createGLA(Standard_Allocation__c sa, String OppId) {munib*/
} // END public with sharing class BatchUploadTriggerHandler {