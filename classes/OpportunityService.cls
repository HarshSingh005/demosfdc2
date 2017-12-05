/*
 * Class        : OpportunityService
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Sep 24, 2013
 * Objective    : This class contains static methods for the Opportunity object
 * Modified By                   Modified On                      Description
 * Jagjeet Singh                  03/14/2016                      I-207218 - Added conditions before creating the GLA
 * Jagjeet Singh                  03/14/2016                      I-207625 - GL Allocation: default to Transaction GAU, if set
 * Jagjeet Singh                  03/1/2016                       I-207239 - GL Allocation, delete and recreated conditionally
 * Jagjeet Singh                  04/28/2016                      T-498288 - Added method populateProductTypeFromCampaign() on AfterInsert.
 * John Hecker                    4/28/2016                       T-498473 - Add logic to GL Allocation creation method in OpportunityTriggerService class to multiply Amount by (-1) when Account Type is "Cash Balance'
 * John Hecker                    4/28/2016                       T-498465 - Extend method on GL Allocation creation method in OpportunityTriggerService to map IsObligation from Standard Allocation to GL Allocation on creation of GL Allocation
 * Jagjeet Singh                  4/29/2016                       T-498260 - Create Preference Records to prevent Auto Assign logic from selecting a Recriprocol Alliance participant
 * Jagjeet Singh                  5/5/2016                        T-498260 - updateAutoAssignParticipant on after and before Insert.
 * Jagjeet Singh                  5/12/2016                       updated the updateAutoAssignParticipant method as per shailendra's suggestions.
 * Rohit B.                       13/May/2016                     Updated logic in "populateProductTypeFromCampaign" method.
 * Munib Ur Rehman                03/06/2016                      Updated logic for Preference Records Creation and Sponsorship creation
 * Ashu Gupta                     15/Jun/2016                     I-222431-Updated logic in updateOppAutoAssignParticipant method for Auto_Assign_Participant__c
 * Ravi Chauhan                   4/July/2016                     T-514023 - Updated logic to set the opportunity (Donation) owner
 * Ravi Chauhan                   8/Aug/2016                      Updated logic for updating the opportunity owner
 * Ashu Gupta                     02/Sep/2016                     T-525408- Added logic in updateOpportunityOwner to update GAU on Opportunity when rC_Sponsorship__Sponsorship_Status__c is changed to Active  
 * Ashu Gupta                     19/Sep/2016                     I-233215 - Added a check to see that records are created only once.
 * Rohit B                        07/Oct/2016                     I-238776 - Modified updateSubstituteContRecords method as per Dirk's with communication.
 * Ravi Chauhan                   12/Oct/2016                     I-239475 - Update the Payment_Hard_Credit_Contact__c field with rC_Giving__Hard_Credit_Contact__c field's value
 * Ravi Chauhan                   21/Oct/2016                     I-224762 - Update the DoNotUpdateReserve__c flag to True
 * Rohit B                        27/Oct/2016                     I-241394 - Update in "updateOpportunityNameBasedOnConditions" method.
 * Ravi Chauhan                   11/Nov/2016                     I-243344 && I-243345 | Updated updateTheTransactionOppNameafter_Future() and a condition in updateOpportunityNameBasedOnConditions()
 * Suminder Singh                 5/12/2016                       I-246685 - Fixed code for validation error
 * Ravi Chauhan                   7/12/2016                       I-247093 | I-247095 | Hard Credit contact and Primary Contact should be same (Later removed  by Dirk)
 * Ravi Chauhan                   9/12/2016                       I-247107 | Commented the code to populate PT and PST on opp as per the GAU as its not valid for the new model
 * Suminder Singh                 14/12/2016                      I-247336 - Fixed code for this issue
 * Ravi Chauhan                   23/01/2017                      I-253808 | Put the vendor check for markOpportunityForClawBack in query itself
 * John Hecker                    25/01/2017                      I-253697: Verify: gl allocations are calculated always as appropriate +/- amounts
 * Suminder Singh                 01/02/2017                      I-252203 - Added logic to update transaction opportunity owner
 * Ravi Chauhan                   02/16/2017                      I-258680 -  Added setNoFiedCorrespondanceFlag() method
 * Ravi Chauhan                   02/28/2017                      I-260691 - update the updateOpportunityOwner to update owner of designated fund
 * Suminder Singh                 03/09/2017                      update the populateTransactionFields method as a fix to Issue I-262105
 * Ravi Chauhan                   03/31/2017                      I-262538 - Update the logic to set the name of opportunities when product type if 'Third Party'
*/
public without sharing class OpportunityService { 

    public static Set <Id> partiallyCompleteOppIds;
    public static final string SPONSORED = 'Sponsored';
    private static final String REINSTATEABLE = 'Reinstateable';
    static final string RT_TRANSACTION = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    static final String RT_PLEDGE_PAYMENT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge Payment').getRecordTypeId();
    static final string RT_DONATION = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    static final String RT_National_Office = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    static final String RT_Local_Partner = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    static final String RT_Community = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    public static boolean paidTDateUpdated = false;
    static Map <Id, String> autoAssignMap = new Map <Id, String> ();
    static Boolean isGLACreated = false;
    static Set<Id> setOpp_GLACreated = new Set<Id>();
    static Boolean isMCSCancelled = false;
    static Boolean isPreferenceCreated = false;
    static Boolean isBatchLetters_CIFProcessed = false;
    @TestVisible static Boolean isBatchLettersCanceledProcessed = false;
    @TestVisible static Boolean isBatchLetters_SuspenseProcessed = false;
    // T-543434 | String leteral for product sub type | 'Gift for Former Sponsored Child'
    //final static String GIFT_FOR_FORMER_SPONSORED_CHILD = 'Gift for Former Sponsored Child';

    public static void onBeforeInsert(list <Opportunity> oppList) {
        OpportunityTriggerSettings__c setting = OpportunityTriggerSettings__c.getInstance(UserInfo.getUserId());

        if(!setting.Disable_for_Lockbox_Integration__c)
        {
            StaticConstants.counter =0;
            //system.debug('[RB] - OpportunityService.onBeforeInsert :: Method Start..');
            validateDonorFlag(oppList);
            updateApprovalPathExempt(oppList);
            tempOppName(oppList);
            trnsctnsDistributionDateUpdate(oppList, null, null);
            setReleaseDateforDFCTransaction(oppList);
            //updateOppAutoAssignParticipant(oppList, null, Trigger.isBefore);
            // populates the product type from Camapign
            populateProductTypeFromCampaign(oppList);
            populateTransactionFields(oppList);
            //Added by Ravi Chauhan on 24/Jun/2016 for T-514023.  <<START>>
            if (CheckRecursive.runUpdateOppOwnerOnce()){
                    updateOpportunityOwner(oppList,null,null);
            }
            //updateOpportunityOwner(oppList,null,null); 
            //Added by Ravi Chauhan on 12/Oct/2016 for I-239475.  <<START>>
            updateHardCreditContactOnTransaction(oppList);
            updateOppForReserve(oppList);//I-246979
            //Added by Ravi Chauhan on 12/Oct/2016 for I-239475.  <<END>>
            //system.debug('[RB] - OpportunityService.onBeforeInsert :: Method End..');
        }
    } // END public static onBeforeInsert(list<Opportunity> oppList) {
     

    public static void onAfterInsert(list <Opportunity> oppList, Map <Id, Opportunity> newMap) {

        OpportunityTriggerSettings__c setting = OpportunityTriggerSettings__c.getInstance(UserInfo.getUserId());

        //system.debug('[RB] - OpportunityService.onAfterInsert :: Method Start..');
        //system.debug('[RB] - OpportunityService.onAfterInsert :: oppList => ' + oppList);
        //updateSubstituteContactRecord(oppList);
        /*
        list<Opportunity> oppWithVendor = new list<Opportunity>();
        for(Opportunity opp : oppList){
            if(!String.isBlank(opp.Vendor_Name__c)){
                oppWithVendor.add(opp);
            }
        }
        if(oppWithVendor.size()>0){
            markOpportunityForClawBack(oppWithVendor, null); 
        }
        */
        if(!setting.Disable_for_Lockbox_Integration__c)
        {

            markOpportunityForClawBack(oppList, null);//I-253808 | Commented the above condition of vendor check as it was not working when Transaction Opp was updated
           
            updateSubstituteContRecords(oppList, null, newMap);
            // Ravi Chauhan | I-224762 | Changes >> Start
            updateParticipantContRecords(oppList, null, newMap);
            // Ravi Chauhan | I-224762 | Changes >> End
            createDFCFee(oppList);
            if (!isPreferenceCreated) {
                createPreferenceRecordsForNewAssignments(oppList, null, newMap);
            }
            
            //create Preference Records - Jagjeet Singh - T-498260
            /*if (CheckRecursive.runOpportunityOnce()) {
                //system.debug('[RB] - OpportunityService.onAfterInsert :: runOpportunityOnce Start..');
                updateOppAutoAssignParticipant(oppList, null, Trigger.isBefore); // code commented for  I-246679 (see chatter)
            }*/

        }

        List<Opportunity> opportunitiesForGLACreationList = new List<Opportunity>();
        //system.debug('[RB] - OpportunityService.onAfterUpdate :: setOpp_GLACreated => ' + setOpp_GLACreated);
        for (Opportunity opp : oppList) {
            if(!setOpp_GLACreated.contains(opp.Id) && opp.RecordTypeId == RT_TRANSACTION && opp.StageName != 'Open')
                opportunitiesForGLACreationList.add(opp);
        }
        
        if(opportunitiesForGLACreationList.size()>0){
            create_GL_Allocation(opportunitiesForGLACreationList, null, newMap);
        }

        if(!setting.Disable_for_Lockbox_Integration__c)
        {

            if (!isBatchLetters_CIFProcessed)
                BatchLetters_CIF(oppList, null);

            if (!isBatchLetters_SuspenseProcessed)
                BatchLetters_Suspense(oppList);
                
            updateOpportunityNameBasedOnConditions(oppList);
            //updateFinalOpportunityStatus(oppList, null, newMap);
            //updateOpportunityOwnerId(oppList, null);
            //system.debug('[RB] - OpportunityService.onAfterInsert :: Method End..');
            //staticConstants.isFromInsert = false;//resetting the varible
        }
        
    } // END public static onAfterInsert(list<Opportunity> oppList) {
    
    public static void onBeforeUpdate(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
            
        OpportunityTriggerSettings__c setting = OpportunityTriggerSettings__c.getInstance(UserInfo.getUserId());
        if(!setting.Disable_for_Lockbox_Integration__c)
        {
            //if(!StaticConstants.isFromInsert){ // //variable to stop unnecessary updation of Opportunities
            //system.debug('[RB] - OpportunityService.onBeforeUpdate :: Method Start..');
            incrementPaymentAttemptCounter(oppList, oldMap);
            validateDonorFlag(oppList);
            //verifyGLA(oppList, oldMap, newMap); // We have validation rule to validate locked down fields
        
            updatePaidThroughDate(oppList, oldMap, newMap);
        
            trnsctnsDistributionDateUpdate(oppList, oldMap, newMap);
            //updateTheTransactionOppNameBefore(oppList, oldMap, newMap); // This is happenning in Workflow field update
            populateTransactionFields(oppList);
            //Suminder - Updated for Issue - I-251717
            populateProductTypeFromCampaign(oppList);
        
            //update owner of Opportunity
            //Added by Ravi Chauhan on 24/Jun/2016 for T-514023.  <<START>>
            /*if (CheckRecursive.runUpdateOppOwnerOnce()){
                //updatePaidThroughDate(oppList, oldMap, newMap);
                updateOpportunityOwner(oppList,oldMap,newMap);
            }*/ // I-255794 | Removed the runUpdateOppOwnerOnce as part of this issue
            
            updateOpportunityOwner(oppList,oldMap,newMap);
        
            //Added by Ravi Chauhan on 12/Oct/2016 for I-239475.  <<START>>
            updateHardCreditContactOnTransaction(oppList);
            //Added by Ravi Chauhan on 12/Oct/2016 for I-239475.  <<END>>
            //Added by Ravi Chauhan on 16/Feb/2017 for I-258680.  <<START>>
            setNoFiedCorrespondanceFlag(oppList);
            //Added by Ravi Chauhan on 16/Feb/2017 for I-258680.  <<END>>
            //system.debug('===isFromInsert3==='+StaticConstants.isFromInsert);
            //updateOppAutoAssignParticipant(oppList, oldMap, Trigger.isBefore);
            //system.debug('[RB] - OpportunityService.onBeforeUpdate :: Method End..');
        //}
        }
    } // END public static void onBeforeUpdate(list<Opportunity> oppList) {

    public static void onAfterUpdate(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
        
        OpportunityTriggerSettings__c setting = OpportunityTriggerSettings__c.getInstance(UserInfo.getUserId());
        
        //if(!StaticConstants.isFromInsert){ ////variable to stop unnecessary updation of Opportunities
        //system.debug('[RB] - OpportunityService.onAfterUpdate :: Method Start..');
               
        //set exchange rate for related funding records
        if(!setting.Disable_for_Lockbox_Integration__c)
            setExchangeRateForRelatedFundings(oppList, oldMap);
        
        updateParticipantsOnPaymentReceived(oppList, oldMap);
        //deleteGLA(oppList, oldMap, newMap);       
        
        if(!setting.Disable_for_Lockbox_Integration__c)
        {

            updateSubstituteContRecords(oppList, oldMap, newMap);
            // Ravi Chauhan | I-224762 | Changes >> Start
            updateParticipantContRecords(oppList, oldMap, newMap);
            // Ravi Chauhan | I-224762 | Changes >> End
            //update the transaction Opps where the GAU on the parent Opp is changed.
            //updateRelatedTransOnDonation(oppList, oldMap, newMap);
            //[I-207218 : Jagjeet Singh]
            //create Preference Records - Jagjeet Singh - T-498260
            //createPreferenceRecords(oppList,oldMap);
            if (!isPreferenceCreated) {
                createPreferenceRecordsForNewAssignments(oppList, null, newMap);
            }
            
            if (CheckRecursive.ifClawbackRunningRecursively()) {
                ////system.debug('### Sahil ' + oldMap + ' oppList' + oppList);
                /*
                list<Opportunity> oppWithVendor = new list<Opportunity>();
                for(Opportunity opp : oppList){
                    if(!String.isBlank(opp.Vendor_Name__c)){
                        oppWithVendor.add(opp);
                    }
                }
                if(oppWithVendor.size()>0){
                    markOpportunityForClawBack(oppWithVendor, oldMap); //I-235200 The Clawback needs to be run at least one more time so as to set the values properly
                }*/
                markOpportunityForClawBack(oppList, oldMap); //I-253808 | Commented the above condition of vendor check as it was not working when Transaction Opp was updated
            }
             
            
            //I-243345 | Got this code out of CheckRecursive.runOpportunityOnce() as due to this the Name of the Transaction Opportunities available on Donation Opportunity
            // was not getting updated as per the Worklow defined for updating opportunity names (i.e Opportunity.Donation Name workflow rule)
            updateTheTransactionOppNameAfter(oppList, oldMap, newMap);
        }
        
        // I-235203 | Changes >> Start
        /*
        if(CheckRecursive.checkCounter() <2){
            markOpportunityForClawBack(oppList, oldMap);// Method Call check for Recursion ie. put into check Recursive call for Issue I-234356 MR
        }*/
        // I-235203 | Changes >> End
        List<Opportunity> opportunitiesForGLACreationList = new List<Opportunity>();
        //system.debug('[RB] - OpportunityService.onAfterUpdate :: setOpp_GLACreated => ' + setOpp_GLACreated);
        for (Opportunity opp : oppList) {
            if(!setOpp_GLACreated.contains(opp.Id) && opp.RecordTypeId == RT_TRANSACTION && opp.StageName != 'Open')
                opportunitiesForGLACreationList.add(opp);
        }
        
        if(opportunitiesForGLACreationList.size()>0){
            create_GL_Allocation(opportunitiesForGLACreationList, null, newMap);
        }
        
        if(!setting.Disable_for_Lockbox_Integration__c)
        {

            // this condition/call is added by Rohit B as if we insert an opportunity with 'Closed' status,
            // it never gonna be cancel its MCS(although I'm not sure whether we meet this suitation ever or not).
            if (!isMCSCancelled) {
                cancelMCSFromOpp(oppList, oldMap, newMap);
            }

            if (!isBatchLetters_CIFProcessed)
                BatchLetters_CIF(oppList, oldMap);

            if (!isBatchLettersCanceledProcessed)
                BatchLetters_Cancelation(oppList, oldMap);
            
            BatchLetters_SuspenseKeptbyLP_ACHReturn(oppList, oldMap);
            
            List<Opportunity> tmpOppListToRename = new List<Opportunity>();
            for(Opportunity opp : oppList) {
                if(oldMap == null  || (oldMap != null && (opp.RecordTypeId != oldMap.get(opp.Id).RecordTypeId || 
                    opp.Participant__c != oldMap.get(opp.Id).Participant__c || opp.Product_Type__c != oldMap.get(opp.Id).Product_Type__c || 
                    opp.Product_Sub_Type__c != oldMap.get(opp.Id).Product_Sub_Type__c || opp.rC_Giving__Parent__c != oldMap.get(opp.Id).rC_Giving__Parent__c || 
                    opp.AccountId != oldMap.get(opp.Id).AccountId || opp.CampaignId != oldMap.get(opp.Id).CampaignId || 
                    opp.GAU_Description__c != oldMap.get(opp.Id).GAU_Description__c))) {
                    tmpOppListToRename.add(opp);
                }
            }
            if(tmpOppListToRename.size() > 0)
                updateOpportunityNameBasedOnConditions(tmpOppListToRename);

            //updateOpportunityOwnerId(oppList, oldMap);
            //system.debug('[RB] - OpportunityService.onAfterUpdate :: Method End..');
            //}
        }
    } // END public static onAfterInsert(list<Opportunity> oppList) {

    //MR T-543436 Need to update opportunity Name Based on following criteria (from 'Donation Name' workflow Rule)
    public static void updateOpportunityNameBasedOnConditions(List<Opportunity> opportList){
        List<Opportunity> oppsList = [select Id , Product_Type__c,Parent_Product_Type__c, Parent_Product_Sub_Type__c, Product_Sub_Type__c, Sponsored_Account__c, Sponsored_Account__r.Name , RecordType.Name, RecordTypeId 
                                        ,Sponsored_Account__r.RecordType.Name,Participant__c, Participant__r.FirstName, Participant__r.LastName, GAU_Description__c, Campaign.Name, rC_Giving__Parent__r.Participant__r.FirstName,
                                        rC_Giving__Parent__r.Participant__r.LastName, AccountId, Account.Name,rC_Giving__Parent__c, rC_Giving__Parent__r.Participant__c,CloseDate from Opportunity
                                        where Id in :opportList];
        

        for(Opportunity opp : oppsList){
            // 1. If Product_Type__c = "Designated Fund" and Product_Sub_Type__c in ('Gift for National Office', 'Gift for Local Partner' ,'Gift for Community', 'Gift for Former Sponsored Child')
            // then Name = Product_Sub_Type__c & Sponsored Account__r.Name
            if(opp.Product_Type__c == 'Designated Fund' && (opp.Product_Sub_Type__c == 'Gift for National Office' || opp.Product_Sub_Type__c == 'Gift for Local Partner' ||
            opp.Product_Sub_Type__c == 'Gift for Community' || opp.Product_Sub_Type__c == 'Gift for Former Sponsored Child') && opp.Sponsored_Account__c != null) {
                opp.Name = opp.Product_Sub_Type__c+' - '+opp.Sponsored_Account__r.Name;
                //  opp.Name = opp.Sponsored_Account__r.RecordType.Name +' - '+opp.Sponsored_Account__r.Name;
                //criteria : If Opportunity Record Type name equals 'Donation' or 'Pledge' or 'Payment' or 'Transaction'
                // How the field needs to be updated 
            } else if(opp.RecordType.Name == 'Donation' || opp.RecordType.Name == 'Pledge' || opp.RecordType.Name == 'Pledge Payment' || opp.RecordType.Name == 'Transaction') {
                
                // 2. IF RecordType.Name="Donation" and Product_Type__c = "Sponsorship" then Name = Product_Sub_Type__c & Participant__r.FirstName & Participant__r.LastName
                    if(opp.RecordType.Name =='Donation' && opp.Product_Type__c == 'Sponsorship'){
                        opp.Name = opp.Product_Sub_Type__c+' - ';
                        if(opp.Participant__c != null) {
                            //RB - Put condition "(opp.Participant__r.FirstName!=null ? opp.Participant__r.FirstName : '')" in the below statement for issue I-241394  on 27/Oct/2016.
                            opp.Name += (opp.Participant__r.FirstName!=null ? opp.Participant__r.FirstName : '') +' '+ opp.Participant__r.LastName;
                        }
                    } 
                    // 3. If RecordType.Name="Donation" and Product_Type__c = "Recurring Gift" then Name = Product_Sub_Type__c
                    else if(opp.RecordType.Name=='Donation' && opp.Product_Type__c == 'Recurring Gift'){
                        opp.Name = opp.Product_Sub_Type__c;
                    }
                    // 4. If RecordType.Name="Donation" and Product_Type__c = "Designated Fund" then Name = Product_Sub_Type__c & Participant__r.FirstName & Participant__r.LastName
                     else if(opp.RecordType.Name=='Donation' && opp.Product_Type__c == 'Designated Fund'){
                        //RB - Put condition "(opp.Participant__r.FirstName!=null ? opp.Participant__r.FirstName : '')" in the below statement for issue I-241394  on 27/Oct/2016.
                        opp.Name = opp.Product_Sub_Type__c + ' - ' ;
                        if(opp.Participant__c != null) 
                            opp.Name += (opp.Participant__r.FirstName!=null ? opp.Participant__r.FirstName : '') +' '+opp.Participant__r.LastName;

                    }
                    
                     // 5. If RecordType.Name="Donation" and Product_Type__c = "One Time Gift" and Product_Sub_Type__c = "Gift Catalog" then Name = GAU_Description__c & - & Campaign.Name
                     else if(opp.RecordType.Name=='Donation' && opp.Product_Type__c == 'One Time Gift' && opp.Product_Sub_Type__c == 'Gift Catalog'){
                        if(opp.GAU_Description__c!=null){
                            opp.Name = opp.GAU_Description__c+' - '+opp.Campaign.Name;
                        }
                    } 
                    // 6. If RecordType.Name="Donation" and Product_Type__c = "One Time Gift" and Product_Sub_Type__c != "Gift Catalog" then Name = Product_Sub_Type__c & -  & GAU_Description__c
                    else if(opp.RecordType.Name=='Donation' && opp.Product_Type__c == 'One Time Gift' && opp.Product_Sub_Type__c != 'Gift Catalog'){
                        if(opp.GAU_Description__c!=null) {
                            opp.Name = opp.Product_Sub_Type__c+' - '+opp.GAU_Description__c;
                        } else {
                            opp.Name = opp.Product_Sub_Type__c+' - ';
                        }
                    } 
                    // 7. If RecordType.Name="Donation" and Product_Type__c = "Third Party" then Name = Product_Type__c & - & Product_Sub_Type__c + ' ' + CloseDate | Close Date has been added as per I-262538
                    else if(opp.RecordType.Name=='Donation' && opp.Product_Type__c == 'Third Party'){
                        //opp.Name = opp.Product_Type__c+' - '+opp.Product_Sub_Type__c; // Commented the earlier name as per I-262538
                        //I-262538 | Ravi Chauhan | Added the close date in name of opportunity if product type is Third Party | Changes >> Start
                        opp.Name = opp.Product_Type__c + ' ' + opp.Product_Sub_Type__c + ' ' + formatDate(opp.CloseDate);
                        //I-262538 | Ravi Chauhan | Added the close date in name of opportunity if product type is Third Party | Changes >> End
                    } 
                    // 8. If RecordType.Name="Pledge" and Product_Type__c = "Pledge Payment" then  Name = RecordType.Name & - & GAU_Description__c
    
                    //else if(opp.RecordType.Name=='Pledge' && opp.Product_Type__c == 'Pledge Payment'){
                    else if(opp.RecordType.Name=='Pledge' || opp.RecordType.Name == 'Pledge Payment'){//I-243344 | Updated the condition as per Donation Name workflow on Opportunity
                        if(opp.GAU_Description__c!=null) {
                            opp.Name = opp.RecordType.Name+' - '+opp.GAU_Description__c;
                        } else {
                            opp.Name = opp.RecordType.Name+' - ';
                        }
                    } 
                    // 9. If RecordType.Name="Transaction" and Parent_Product_Type__c = "Sponsorship" Then Name = "TXN:" & Parent_Product_Sub_Type__c & - & rC_Giving__Parent__r.Participant__r.FirstName & rC_Giving__Parent__r.Participant__r.LastName
    
                    else if(opp.RecordType.Name=='Transaction' && opp.Parent_Product_Type__c == 'Sponsorship'){
                        opp.Name = 'TXN:'+ opp.Parent_Product_Sub_Type__c+' - ';
                        //if(opp.rC_Giving__Parent__c !=null && opp.rC_Giving__Parent__r.Participant__r !=null) {
                        if(opp.rC_Giving__Parent__c !=null && opp.rC_Giving__Parent__r.Participant__c !=null) {
                            //RB - Put condition "(opp.rC_Giving__Parent__r.Participant__r.FirstName!=null ? opp.rC_Giving__Parent__r.Participant__r.FirstName : '')" in the below statement for issue I-241394  on 27/Oct/2016.
                            opp.Name += (opp.rC_Giving__Parent__r.Participant__r.FirstName!=null ? opp.rC_Giving__Parent__r.Participant__r.FirstName : '') +' '+opp.rC_Giving__Parent__r.Participant__r.LastName;
                        }
                    }
                    // 10. If RecordType.Name="Transaction" and Parent_Product_Type__c = "Third Party" Then Name 'TXN:'+ opp.Parent_Product_Type__c + ' ' + opp.Parent_Product_Sub_Type__c + CloseDate as per I-262538 | e.g TXN:Third Party Foundation 02-23-17
                    //I-262538 | Ravi Chauhan | Added the close date in name of opportunity if product type is Third Party | Changes >> Start
                    else if(opp.RecordType.Name == 'Transaction' && opp.Parent_Product_Type__c == 'Third Party'){
                        opp.Name = 'TXN:'+ opp.Parent_Product_Type__c + ' ' + opp.Parent_Product_Sub_Type__c + ' ' + formatDate(opp.CloseDate);
                    }
                    //I-262538 | Ravi Chauhan | Added the close date in name of opportunity if product type is Third Party | Changes >> End
                    
                    //11. If RecordType.Name="Transaction" and Parent_Product_Type__c != "Sponsorship" && Parent_Product_Type__c != 'Third Party' Then Name = "TXN:" &   Campaign.Name & - &  Account.Name
   
                    else if(opp.RecordType.Name =='Transaction' && opp.Parent_Product_Type__c != 'Sponsorship' && opp.Parent_Product_Type__c != 'Third Party'){
                        opp.Name = 'TXN:'+ opp.Campaign.Name+' - '+opp.Account.Name;
                    } 
                    
                     // 12. Else Name = Campaign.Name & - & Account.Name
                    else {
                        opp.Name = opp.Campaign.Name+' - '+opp.Account.Name;
                    }
                }
        }
        if(!oppsList.isEmpty())
            update oppsList;
    }
    
    //before update, For Transaction recordtype, this counter is updated in a before trigger 
    //if rC_Connect__Response_Date_Time__c has changed due to credit card recycler process. 
    //This field is used for sending the appropriate automated email for each failed attempt.
    static void incrementPaymentAttemptCounter(List <Opportunity> oppList, Map <Id, Opportunity> oldMap){
        Id transactionRecordTypeId =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        
        for(Opportunity opp : oppList){
            if(opp.RecordTypeId == transactionRecordTypeId){
                Opportunity oldOpp = oldMap.get(opp.id);
                
                if(opp.rC_Connect__Response_Date_Time__c != oldOpp.rC_Connect__Response_Date_Time__c){
                    if(opp.Payment_Processing_Attempt_Count__c == null)
                        opp.Payment_Processing_Attempt_Count__c = 0;
                    
                    opp.Payment_Processing_Attempt_Count__c += 1;
                }
            }
        }
    }
    
    //if the contact donor flag is black, do not allow child sponsorship
    static void validateDonorFlag(List <Opportunity> oppList) {
        Id donationRecordTypeId =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Set <Id> contactIds = new Set <Id> ();

        for (Opportunity opp: oppList) {
            if (opp.RecordTypeId == donationRecordTypeId &&
                opp.Product_Type__c == 'Sponsorship' &&
                opp.Product_Sub_Type__c == 'Child Sponsorship') {
                if (opp.rC_Giving__Primary_Contact__c != null)
                    contactIds.add(opp.rC_Giving__Primary_Contact__c);

                if (opp.rC_Giving__Hard_Credit_Contact__c != null)
                    contactIds.add(opp.rC_Giving__Hard_Credit_Contact__c);
            }
        }

        if (contactIds.size()> 0) {
            Map <Id, Contact> contacts =
                new Map <Id, Contact> ([select id, Donor_Flag__c from Contact where id in :contactIds and Donor_Flag__c = 'Black']);

            if (contacts.size() == 0)
                return;

            for (Opportunity opp: oppList) {
                if (opp.RecordTypeId == donationRecordTypeId &&
                    opp.Product_Type__c == 'Sponsorship' &&
                    opp.Product_Sub_Type__c == 'Child Sponsorship') {
                    if (opp.rC_Giving__Primary_Contact__c != null) {
                        Contact primary = contacts.get(opp.rC_Giving__Primary_Contact__c);
                        if (primary != null && primary.Donor_Flag__c!=null && primary.Donor_Flag__c == 'Black')
                            opp.rC_Giving__Primary_Contact__c.addError('Primary Contact has Black Donor Flag.  Child Sponsorship not permitted.');
                    }

                    if (opp.rC_Giving__Hard_Credit_Contact__c != null) {
                        Contact hard = contacts.get(opp.rC_Giving__Hard_Credit_Contact__c);
                        if (hard != null && hard.Donor_Flag__c!=null && hard.Donor_Flag__c == 'Black')
                            opp.rC_Giving__Hard_Credit_Contact__c.addError('Hard Credit Contact has Black Donor Flag.  Child Sponsorship not permitted.');
                    }
                }
            }
        }
    }

    static void setExchangeRateForRelatedFundings(List <Opportunity> oppList, Map <Id, Opportunity> oldMap) {
        //system.debug('[RB] - OpportunityService.setExchangeRateForRelatedFundings :: Method Start..');
        //Only consider opportunities whose exchange rate has changed
        Set <Id> oppIds = new Set <Id> ();
        for (Opportunity opp: oppList) {
            if (opp.Exchange_Rate__c != oldMap.get(opp.Id).Exchange_Rate__c) {
                oppIds.add(opp.Id);
            }
        }
        if (!oppIds.isEmpty()) { // no need to process further
            //system.debug('inside if setExchange...............................1');
            List <Funding__c> fundingList = new List <Funding__c> ();

            //Added by John Hecker 3/2/2016 a condition to only enter for loop if oppIds set has size> 0
            //condition added to resolve I-206037

            if (oppIds.size()> 0) {
                //Get the related funding records
                for (Opportunity opp: [SELECT Id, Exchange_Rate__c, Convert_From__c, Exchange_Rate_Date__c, Local_Currency__c, (SELECT Id, Exchange_Rate__c, Convert_From__c, Exchange_Rate_Date__c, Local_Currency__c FROM Fundings__r)
                        FROM Opportunity WHERE Id IN: oppIds
                    ]) {
                    for (Funding__c funding: opp.fundings__r) {
                        fundingList.add(copyExchangeRateInfoToFunding(opp, funding));
                    }
                }
            } //END if (oppIds.size()> 0)
            //Update the funding records
            //system.debug('inside if setExchange...............................2');
            try {
                if (fundingList.size()> 0)
                    update fundingList;
            } catch (DMLException dmlEx) {
                //system.debug('Error updating Funding: ' + dmlEx.getMessage());
                throw new ChildFundException.CustomDMLException('There was an error updating the funding records with Exchange Rate. Please contact your System Administrator');
            }
        }
        //logic for  T-465343 ends 
        //system.debug('[RB] - OpportunityService.setExchangeRateForRelatedFundings :: Method End..');
    }

    static Funding__c copyExchangeRateInfoToFunding(Opportunity opp, Funding__c funding) {
        funding.Exchange_Rate__c = opp.Exchange_Rate__c;
        funding.Convert_From__c = opp.Convert_From__c;
        funding.Exchange_Rate_Date__c = opp.Exchange_Rate_Date__c;
        funding.Local_Currency__c = opp.Local_Currency__c;
        return funding;
    }

    //update ApprovalPathExempt field on cloned Opportunity Records
    static void updateApprovalPathExempt(list <Opportunity> oppList) {
        for (Opportunity opp: oppList) {
            if (opp.Cost_Extension__c == true) {
                opp.Approval_Path_Exempt__c = true;
            }
        }
    }

    //Reference : T-465343
    // When Opportunity.Sponsorship_Status__c = "Sponsored" then Update the Contact.rC_Sponsorship__Sponsorship_Status__c field of the participant contact 
    // listed in the Participant__c field of the Opportunity to "Sponsored"
    // When Opportunity.Sponsorship_Status__c = "Reinstateable" Update the Contact.rC_Sponsorship__Sponsorship_Status__c field of the participant contact 
    // listed in the Participant__c field of the Opportunity to "Reinstateable"
    public static void updateParticipantsOnPaymentReceived(List <Opportunity> oppList, Map <Id, Opportunity> oldMap) {
        //system.debug('[RB] - OpportunityService.updateParticipantsOnPaymentReceived :: Method Start..');
        List <Contact> lstContactList = new List <Contact> ();
        Set <Contact> setContactList = new Set <Contact> ();
        String oppDonationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        for (Opportunity opp: oppList) {
            if (opp.Participant__c != NULL && opp.Sponsorship_Status__c != oldMap.get(opp.Id).Sponsorship_Status__c && opp.recordTypeId == oppDonationRecordTypeId &&
                (opp.Sponsorship_Status__c == SPONSORED || opp.Sponsorship_Status__c == REINSTATEABLE)) {
                Contact c = new Contact(id = OPP.Participant__c, rC_Sponsorship__Sponsorship_Status__c = OPP.Sponsorship_Status__c);
                setContactList.add(c);
            }
        } // END for(Opportunity opp : oppList){ 
        if (setContactList.size()> 0) {
            try {
                lstContactList.addAll(setContactList);
                update lstContactList;
            } catch (DMLException dmlEx) {
                //system.debug('Error updating Contacts: ' + dmlEx.getMessage());
                throw new ChildFundException.CustomDMLException('There was an error updating the Conatct records. Please contact your System Administrator');
            }
        } // END if(setContactList.size()> 0){
        //system.debug('[RB] - OpportunityService.updateParticipantsOnPaymentReceived :: Method End..');
    } // END public static void updateParticipantsOnPaymentReceived(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){

    //Added by Rohit B. on 02/Feb/2016 for task T-470144                --START--
    static void create_GL_Allocation(list <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
        //system.debug('[RB] - OpportunityService.create_GL_Allocation :: Method Start..');
        Set <String> glOppStages = new Set <String> {
            'Completed', 'Adj From', 'Adj To', 'Returned', 'Refunded'
        };
        Set <String> setOppIDs = new Set <String> ();
        // T-521545 MR 09/08/2016 Set to Contatin Opportunities for Creating Allocations from FOC CustomSetting match.
        Set <Opportunity> oppsForOtherAllocations = new Set<Opportunity>();
        
        //Filling out set initialised above for After Insert
        //Commented by Suminder Singh(Appirio) to improve performance as per Issue I-267598
        /*
        if(Trigger.isInsert) {
            for (Opportunity opp: [SELECT Id, StageName, RecordTypeId, rC_Giving__Parent__c, FOC__c, rC_Giving__Parent__r.Participant__r.National_Office__c, rC_Giving__Parent__r.rC_Giving__GAU__c,
                rC_Giving__Parent__r.rC_Giving__GAU__r.Funding_Source__c, rC_Giving__Parent__r.rC_Giving__GAU__r.Receipt_Type__c,
                Amount, rC_Giving__GAU__c, rC_Giving__GAU__r.Funding_Source__c, rC_Giving__GAU__r.Receipt_Type__c,
                Participant__c, Participant__r.National_Office__c, Sponsored_Account__c, Sponsored_Account__r.RecordTypeId,
                Sponsored_Account__r.ParentId,Sponsored_Account__r.Parent.ParentId, Product_Sub_Type__c
                    FROM Opportunity WHERE Id in : oppList AND RecordTypeId = : RT_TRANSACTION AND StageName != 'Open'
                    //AND (rC_Giving__Parent__r.rC_Giving__GAU__c != Null) //Commented as per Issue I-267598
                ]){
                    oppsForOtherAllocations.add(opp);
            }
        }*/
        //system.debug('[RB] - OpportunityService.create_GL_Allocation :: oppList => ' + oppList);
        //We are querying again because we needed some other fields as well like parent's NO and GAU's funding source & receipt type.  for T-481136
        for (Opportunity opp: [SELECT Id, StageName, RecordTypeId, rC_Giving__Parent__c, FOC__c, rC_Giving__Parent__r.Participant__r.National_Office__c, rC_Giving__Parent__r.rC_Giving__GAU__c,
                rC_Giving__Parent__r.rC_Giving__GAU__r.Funding_Source__c, rC_Giving__Parent__r.rC_Giving__GAU__r.Receipt_Type__c,
                Amount, rC_Giving__GAU__c, rC_Giving__GAU__r.Funding_Source__c, rC_Giving__GAU__r.Receipt_Type__c,
                Participant__c, Participant__r.National_Office__c, Sponsored_Account__c, Sponsored_Account__r.RecordTypeId,
                Sponsored_Account__r.ParentId,Sponsored_Account__r.Parent.ParentId, Product_Sub_Type__c
                FROM Opportunity WHERE Id in : oppList AND RecordTypeId = : RT_TRANSACTION AND StageName != 'Open' 
                //Commented by Suminder Singh(Appirio) to improve performance as per Issue I-267598
                //AND (rC_Giving__GAU__c != Null OR rC_Giving__Parent__r.rC_Giving__GAU__c != Null)
            ]) {
            	//Added by Suminder Singh(Appirio) to improve performance as per Issue I-267598
            	if(Trigger.isInsert) {
            		oppsForOtherAllocations.add(opp);
            	}
            //[I-207218 : Jagjeet Singh : Added Condition to create GLA only for Completed Transactions]
            //These below conditions are added by Rohit B on 24/Mar/2015 for I-207625 with discussion of Dirk
            Boolean isStageChange = (oldMap != Null && oldMap.get(opp.Id).StageName != opp.StageName && !glOppStages.contains(oldMap.get(opp.Id).StageName));
            Boolean isAmountChange = (oldMap != Null && oldMap.get(opp.Id).Amount != Null && opp.Amount != Null && oldMap.get(opp.Id).Amount != opp.Amount && !glOppStages.contains(oldMap.get(opp.Id).StageName));
            //system.debug('[RB] - OpportunityService.create_GL_Allocation :: isStageChange => ' + isStageChange);
            //system.debug('[RB] - OpportunityService.create_GL_Allocation :: isAmountChange => ' + isAmountChange);
            If(oldMap == null){
                //system.debug('[RB] - OpportunityService.create_GL_Allocation :: oldMap is null..');
            }
            else {
                //system.debug('[RB] - OpportunityService.create_GL_Allocation :: oldMap is not null..');
            }
            if (oldMap == null || isStageChange || isAmountChange) {
                setOppIDs.add(opp.Id);
            } // END if((opp.rC_Giving__GAU__c != Null || opp.rC_Giving__Parent__r.rC_Giving__GAU__c != Null) && (oldMap == null || isStageChange || isAmountChange)) {
        } // END for(Opportunity opp : [SELECT Id, StageName,.....)
        //system.debug('[RB] - OpportunityService.create_GL_Allocation :: setOppIDs => ' + setOppIDs);
        if (setOppIDs.size()> 0) { //&& !System.isFuture()) {
        	//Commented by Suminder Singh(Appirio) to improve performance as per Issue I-267598
            //create_GL_Allocation_Future(setOppIDs , oppsForOtherAllocations);
            
            //Added by Suminder Singh(Appirio) to improve performance as per Issue I-267598
            create_GL_Allocation_Future(oppsForOtherAllocations);
            
            //isGLACreated = true; // if above method is in future call then uncomment this flag.
        }
        //system.debug('[RB] - OpportunityService.create_GL_Allocation :: Method End..');
    } // END public static void create_GL_Allocation(list<Opportunity> oppList) {
    
    // Created By Munib Ur Rehman on 09/06/2016 for T-521545
    //Purpose : Create GL Allocation Records on the basis of Picklist Value which matches with FOC Custom Setting Record.
    static Map<Id, List<Opportunity>> createFinanceOriginCodeAllocations(Set<Opportunity> opportsList){
        Map <Id, List<Opportunity>> mapGAUOpp = new Map <Id, List<Opportunity>> ();// Map GAU Id vs Opportunity Record
        
        // Check for the GAU Values when Opportunity FOC field matches with any custom Setting Record
        List<FOC__c> focSettings = FOC__c.getall().values();
        //Iterating through the Opportunities
        for(Opportunity opp : opportsList){
            // Iterating through FOC custom setting
            for(FOC__c focSetting : focSettings){
                
                if(opp.FOC__c!= null && String.valueOf(opp.FOC__c).subString(0,3) == focSetting.Name){
                    
                    if(!mapGAUOpp.containsKey(focSetting.GAU_Id__c)){// Checking if map contains the gauId from Custom setting
                        List<Opportunity> subOppList = new List<Opportunity>(); // creating a listof Opp to fill the map against GAU Ids
                        subOppList.add(opp);
                        mapGAUOpp.put(focSetting.GAU_Id__c, subOppList);
                    } else {
                        mapGAUOpp.get(focSetting.GAU_Id__c).add(opp);
                    }
                    break;
                }
            }
        }
        
        //Checking if map is not empty , then oly process the results
        /*if(!mapGAUOpp.keyset().isEmpty()){
            
            
            /*gauList = [select Id from rC_Giving__GAU__c where Id in :mapGAUOpp.keyset()];
            // Creating a mp of GAU Id vs GAUs
            for(rC_Giving__GAU__c gau: gauList){ 
                mapGAU.put(gau.Id, gau);
            }
            //Fetching All standard Allocations for the GAUs got from above 
           /* for (Standard_Allocation__c sa: [SELECT Id, Credit__c, Debit__c, GAU__c, GL_Account__c, IsObligation__c, GL_Account__r.Account_Type__c
                    FROM Standard_Allocation__c WHERE GAU__c in : mapGAU.keySet()
                ]) {
                if (mapGAUOpp.containsKey(sa.GAU__c)) {
                    // Creating GL Allocation Records based on the SA , List Of Opportunities and the GAU.
                    lstGLAToInsert.addAll(createGLA(sa, mapGAUOpp.get(sa.GAU__c), mapGAU.get(sa.GAU__c)));
                }
            }
            
            if (lstGLAToInsert.size()> 0) {
                //insertion of Records
                //system.debug('-------------lstGLAToInsert'+lstGLAToInsert);
                insert lstGLAToInsert;
            }
        }*/
        
        return mapGAUOpp;
        
    }
    
    //@future
    static void create_GL_Allocation_Future(Set<Opportunity> opportsList) {//Updated by Suminder Singh(Appirio) to improve performance as per Issue I-267598
        //system.debug('[RB] - OpportunityService.create_GL_Allocation_Future :: Method Start..');
        Map <Id, rC_Giving__GAU__c> mapGAU = new Map <Id, rC_Giving__GAU__c> ();
        Map <String, List <Opportunity>> mapGAUOpp = new Map <String, List <Opportunity>> ();
		//Updated by Suminder Singh(Appirio) to improve performance as per Issue I-267598
        for (Opportunity opp: opportsList) {
            if (opp.rC_Giving__GAU__c != Null || opp.rC_Giving__Parent__r.rC_Giving__GAU__c != Null) {
                String gauID = '';
                if (opp.rC_Giving__GAU__c == null) {
                    gauID = opp.rC_Giving__Parent__r.rC_Giving__GAU__c;
                    rC_Giving__GAU__c gau = new rC_Giving__GAU__c(Id = gauID);
                    gau.Funding_Source__c = opp.rC_Giving__Parent__r.rC_Giving__GAU__r.Funding_Source__c;
                    gau.Receipt_Type__c = opp.rC_Giving__Parent__r.rC_Giving__GAU__r.Receipt_Type__c;
                    mapGAU.put(gauID, gau);
                } else {
                    gauID = opp.rC_Giving__GAU__c;
                    rC_Giving__GAU__c gau = new rC_Giving__GAU__c(Id = gauID);
                    gau.Funding_Source__c = opp.rC_Giving__GAU__r.Funding_Source__c;
                    gau.Receipt_Type__c = opp.rC_Giving__GAU__r.Receipt_Type__c;
                    mapGAU.put(gauID, gau);
                }

                if (!mapGAUOpp.containsKey(gauID)) {
                    List <Opportunity> tempMapOppList = new List <Opportunity> ();
                    tempMapOppList.add(opp);
                    mapGAUOpp.put(gauID, tempMapOppList);
                } else {
                    mapGAUOpp.get(gauID).add(opp);
                }
            } // END if((opp.rC_Giving__GAU__c != Null || opp.rC_Giving__Parent__r.rC_Giving__GAU__c != Null) && !isGLACreated) {
        } // END for(Opportunity opp : [SELECT Id, StageName,.....)
        
        
        // MR T-521545 Fetching for GAUs From Finance Origin Code Allocation Custom Setting match
        Map<Id, List<Opportunity>> mapGAUToOppFromFOC = createFinanceOriginCodeAllocations(opportsList);
        
        //system.debug('--------------mapGAUToOppFromFOC'+mapGAUToOppFromFOC);
        if(!mapGAUToOppFromFOC.isEmpty()){
            //Filling out the maps for additional GAUs which comes as a result of matching the CustomSetting FOC
            List<rC_Giving__GAU__c> gauListFromFOC = [select Id, Funding_Source__c,Receipt_Type__c  from rC_Giving__GAU__c where Id in: mapGAUToOppFromFOC.keySet()];
            for(rC_Giving__GAU__c gauFromFOC :gauListFromFOC){
                if(!mapGAU.containsKey(gauFromFOC.Id)){
                    mapGAU.put(gauFromFOC.Id, gauFromFOC);
                }
                if(!mapGAUOpp.containsKey(gauFromFOC.Id)){
                    mapGAUOpp.put(gauFromFOC.Id, mapGAUToOppFromFOC.get(gauFromFOC.Id));
                }
            }
        } // End of the Logic to add the values in the maps for creating additional GL Allocations.
        
        //system.debug('[RB] - OpportunityService.create_GL_Allocation_Future :: mapGAU => ' + mapGAU);
        //system.debug('[RB] - OpportunityService.create_GL_Allocation_Future :: mapGAUOpp => ' + mapGAUOpp);
        if (!mapGAU.isEmpty()) {
            List <GL_Allocation__c> lstGLAToInsert = new List <GL_Allocation__c> ();
            for (Standard_Allocation__c sa: [SELECT Id, Credit__c, Debit__c, GAU__c, GL_Account__c, IsObligation__c, GL_Account__r.Account_Type__c
                    FROM Standard_Allocation__c WHERE GAU__c in : mapGAU.keySet()
                ]) {
                if (mapGAUOpp.get(sa.GAU__c) != null) {
                    lstGLAToInsert.addAll(createGLA(sa, mapGAUOpp.get(sa.GAU__c), mapGAU.get(sa.GAU__c)));
                }
            }
            //system.debug('[RB] - OpportunityService.create_GL_Allocation_Future :: lstGLAToInsert = ' + lstGLAToInsert);

            if (lstGLAToInsert.size()> 0) {
                insert lstGLAToInsert;
                for (GL_Allocation__c gla : lstGLAToInsert) {
                    setOpp_GLACreated.add(gla.Transaction__c);
                }
                isGLACreated = true; // if this method is in future call then this flag doesn't make any sense.
            }
        }
        //system.debug('[RB] - OpportunityService.create_GL_Allocation_Future :: Method End..');
    } // END public static void create_GL_Allocation_Future(Set<String> oppIDs) {

    //static GL_Allocation__c createGLA(Standard_Allocation__c sa, Opportunity Opp) {
    static List <GL_Allocation__c> createGLA(Standard_Allocation__c sa, List <Opportunity> oppList, rC_Giving__GAU__c gau) {
        //system.debug('[RB] - OpportunityService.createGLA :: Method Start..');
        List <GL_Allocation__c> glAllocationList = new List <GL_Allocation__c> ();
        for (Opportunity opp: oppList) {
            GL_Allocation__c gla = new GL_Allocation__c();

            if (sa.Credit__c != Null)
                gla.Percentage__c = (-1) * sa.Credit__c;
            else if (sa.Debit__c != Null)
                gla.Percentage__c = sa.Debit__c;
            else
                gla.Percentage__c = 0;
                
            /* Commented by John Hecker (Appirio) - I-253697
            if (sa.GL_Account__r.Account_Type__c == 'Cash Balance') {
                gla.Percentage__c = (-1) * gla.Percentage__c;
            }
            */
            
            gla.Transaction__c = opp.Id;
            gla.GL_Account__c = sa.GL_Account__c;
            gla.IsObligation__c = sa.IsObligation__c;
            if (Opp.Amount != Null){
                if(sa.Debit__c != null){
                    gla.Amount__c = (gla.Percentage__c * Opp.Amount) / 100; //  T-521545
                }
                if(sa.credit__c != null){
                    gla.Amount__c = (gla.Percentage__c * Opp.Amount) / 100; // T-521545
                }
            }

            gla.Funding_Source__c = gau.Funding_Source__c;
            gla.Receipt_Type__c = gau.Receipt_Type__c;
            /*if (opp.rC_Giving__Parent__r.Participant__r.National_Office__c != Null)
                gla.National_Office__c = opp.rC_Giving__Parent__r.Participant__r.National_Office__c;*/
            // T-533187 |  Changes >> Start     
                
            if(opp.Participant__c != null && opp.Participant__r.National_Office__c != null){
                gla.National_Office__c = opp.Participant__r.National_Office__c;
            }
            else if(opp.Sponsored_Account__c != null){
                    if(opp.Sponsored_Account__r.RecordTypeId == RT_National_Office)
                        gla.National_Office__c = opp.Sponsored_Account__c;
                    else if(opp.Sponsored_Account__r.RecordTypeId == RT_Local_Partner && opp.Sponsored_Account__r.ParentId != null)
                        gla.National_Office__c = opp.Sponsored_Account__r.ParentId;
                    else if(opp.Sponsored_Account__r.RecordTypeId == RT_Community && opp.Sponsored_Account__r.ParentId != null && 
                            opp.Sponsored_Account__r.Parent.ParentId != null)
                        gla.National_Office__c = opp.Sponsored_Account__r.Parent.ParentId;
            }
            // T-533187 |  Changes >> End   
            glAllocationList.add(gla);
        } // END for(Opportunity opp: oppList){
        //system.debug('[RB] - OpportunityService.createGLA :: Method End..');
        return glAllocationList;
    } // END static GL_Allocation__c createGLA(Standard_Allocation__c sa, String OppId) {

    /*static void verifyGLA(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
            //system.debug('[RB] - OpportunityService.verifyGLA :: Method Start..');
            Set <String> setGLAIDsWithSummary = new Set <String> ();

            //Iterates over oppList to create a list of Transactions so that the Query for the FOR Loop is not executed if there are no Transactions in the List
            //Added by John Hecker 3/2/2016 to mitigate Too Many SOQL Queries error on Opportunity when updating participant.
            List <Opportunity> transList = new List <Opportunity> ();
            for (Opportunity opp: oppList) {
                if (opp.RecordTypeId == RT_TRANSACTION) {
                    transList.add(opp);
                }
            }

            if (transList.size()> 0) {
                for (GL_Allocation__c gla: [SELECT Id, GL_Summary__c, Transaction__c FROM GL_Allocation__c
                        WHERE Transaction__c in : transList
                    ]) {
                    if (newMap.get(gla.Transaction__c).recordTypeId == RT_TRANSACTION && gla.GL_Summary__c != Null) {
                        //Opportunity op = gla.Transaction__c;
                        newMap.get(gla.Transaction__c).addError(Label.Error_GL_Allocation_Exists_on_Opportunity);
                        //system.debug('[RB] - OpportunityService.verifyGLA :: op.addError = ' + Label.Error_GL_Allocation_Exists_on_Opportunity);
                    }
                } // END for(GL_Allocation__c gla :
            } // END if(transList.size()> 0)
            //system.debug('[RB] - OpportunityService.verifyGLA :: Method End..');
    } // END static void verifyGLA(List<Opportunity> oppList, Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
    */
    //Method created by John Hecker 2/8/2016 to resolve I-201566
    //Method iterates off all inserted Opps to check if Name is Null and applies a TempName to allow insert
    //Workflow rule will apply real name immediately following insert
    static void tempOppName(List <Opportunity> oppList) {
            //List<Opportunity> NoNameOpp = new List<Opportunity>();
            for (Opportunity opp: oppList) {
                if (opp.Name == NULL) {
                    opp.Name = 'TempName';
                    //NoNameOpp.add(opp);
                }
            }
            //if(oppList.size()> 0){
            //    insert oppList;
            //}
    } //END tempOppName

    /*  Name : 
        Parameters : List Of Opportunities
        Refrence : I-202961
        Developer : Vaibhav Goel
        Date : Feb 23,2016 
        Purpose : Method iterates off all inserted  or updated Opps to check if they are Transaction and Completed, then put Today's date to Date_of_Distribution__c field
        Return : Void
    */
    static void trnsctnsDistributionDateUpdate(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
            for (Opportunity opp: oppList) {
                if (oldMap != null && newMap != null) {
                    if (opp.RecordTypeId == RT_TRANSACTION && opp.rC_Giving__Parent__c != Null && newMap.get(opp.Id).StageName != oldMap.get(opp.Id).StageName && newMap.get(opp.Id).StageName == 'Completed') {
                        opp.Date_of_Distribution__c = System.Today(); //puuting Date_of_Distribution__c as TODAY.
                        opp.Remaining_Non_Adjusted__c = opp.Amount; //DK: set remaining non-adjust to same as amt for all completed trans
                    }
                    
                } else {
                    if (opp.RecordTypeId == RT_TRANSACTION && opp.StageName == 'Completed') {
                        opp.Date_of_Distribution__c = System.Today(); //puuting Date_of_Distribution__c as TODAY.
                        opp.Remaining_Non_Adjusted__c = opp.Amount; //DK: set remaining non-adjust to same as amt for all completed trans                    
                    }
                    
                }
            }

     } //END trnsctnsDistributionDateUpdate


    // If closed amount has changed on a Donation (if a payment is received): update Paid Through Date on the Donation Opportunity
    static void updatePaidThroughDate(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {

        Decimal newPaymentAmount;
        Decimal remainder;
        Integer monthsPaidOut;

        for (Opportunity opp: oppList) {

            //if( opp.RecordType.Name != 'Donation' )
            //    continue;

            //system.debug('>>>>>>> opp.rC_Giving__Closed_Amount__c:' + opp.rC_Giving__Closed_Amount__c);
            //system.debug('>>>>>>> opp.Paid_Through_Date__c:' + opp.Paid_Through_Date__c);

            if (opp.rC_Giving__Closed_Amount__c == null ||
                opp.rC_Giving__Closed_Amount__c == 0 ||
                opp.Monthly_Standard_Pay__c == null ||
                opp.Monthly_Standard_Pay__c == 0)
                continue;

            if (oldMap.get(opp.id).rC_Giving__Closed_Amount__c == null)
                newPaymentAmount = opp.rC_Giving__Closed_Amount__c;
            else
                newPaymentAmount = opp.rC_Giving__Closed_Amount__c - oldMap.get(opp.id).rC_Giving__Closed_Amount__c;

            //system.debug('>>>>>>> newPaymentAmount:' + newPaymentAmount);

            // only update Paid Through Date if there was a + payment
            if (newPaymentAmount == 0)
                continue;

            // Donor has paid 'something'

            //system.debug('>>>>>>> updatePaidThroughDate.  paidTDateUpdated:' + paidTDateUpdated);

            if (paidTDateUpdated == true)
                return;
            else
                paidTDateUpdated = true;


            if (opp.Remainder_Last_Payment__c != null)
                newPaymentAmount += opp.Remainder_Last_Payment__c;

            monthsPaidOut = (Integer)(newPaymentAmount / opp.Monthly_Standard_Pay__c).setScale(0, System.RoundingMode.DOWN);
            remainder = newPaymentAmount - (monthsPaidOut * opp.Monthly_Standard_Pay__c);

            if (newMap.get(opp.id).Paid_Through_Date__c == null)
                newMap.get(opp.id).Paid_Through_Date__c = date.today().addMonths(monthsPaidOut);
            else
                newMap.get(opp.id).Paid_Through_Date__c = newMap.get(opp.id).Paid_Through_Date__c.addMonths(monthsPaidOut);

            // Forgiveness Rules
            // If either: 1) payment amount <one month giving amount, or
            //   2) payment amount not enough to cover 'amount owed'
            //   THEN: set donor as 'current' (eg. forgive outstanding amount)

            Date todayFirstofMonth = Date.newInstance(date.today().year(), date.today().month(), 1);
            if (newMap.get(opp.id).Paid_Through_Date__c <todayFirstofMonth) {
                newMap.get(opp.id).Paid_Through_Date__c = date.today();
                remainder = 0;
            }

            if (remainder> 0)
                newMap.get(opp.id).Remainder_Last_Payment__c = remainder;
            else
                newMap.get(opp.id).Remainder_Last_Payment__c = 0;

            // Clear any holds (if they exist)
            newMap.get(opp.id).rC_Giving__Suspended_Start_Date__c = null;
            newMap.get(opp.id).rC_Giving__Suspended_End_Date__c = null;

        }
    }
    
    /**
     * On before update of Transaction opportunity and opportunity Stage has become Completed', 'Adj From', 'Adj To', 'Returned', 'Refunded' then
     * Populating some of Key fields from Parent Opportunity if value's are blank
     * @param oppList list of opportunites that are being updated.
     * @param oldMap map of old opp's
     * @param newMap map of new opp's
     */    
   /* static void populateTransactionFields(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
        set <id> transOppIds = new set <id> ();
        Set <String> glOppStages = new Set <String> {
            'Completed', 'Adj From', 'Adj To', 'Returned', 'Refunded'
        };
        for (Opportunity opp: oppList) {
            if (opp.RecordTypeId == RT_TRANSACTION && newMap.get(opp.id).StageName != oldMap.get(opp.id).StageName && glOppStages.contains(newMap.get(opp.id).StageName))
                transOppIds.add(opp.rC_Giving__Parent__c);
        }

        if (transOppIds.size() < 1) {
            return;
        }

        Map <ID, Opportunity> parentOpps = new Map <ID, Opportunity> ([SELECT Id, Campaignid, rC_Giving__GAU__c, 
                                                                      Participant__c, rC_Giving__Hard_Credit_Contact__c FROM Opportunity
                                                                      WHERE id in : transOppIds]);

        for (Opportunity opp: oppList) {
            if (opp.RecordTypeId == RT_TRANSACTION && newMap.get(opp.id).StageName != oldMap.get(opp.id).StageName && glOppStages.contains(newMap.get(opp.id).StageName)) {
                if (opp.Campaignid == null)
                    opp.Campaignid = parentOpps.get(opp.rC_Giving__Parent__c).Campaignid;
                if (opp.rC_Giving__GAU__c == null)
                    opp.rC_Giving__GAU__c = parentOpps.get(opp.rC_Giving__Parent__c).rC_Giving__GAU__c;
                if (opp.Participant__c == null)
                    opp.Participant__c = parentOpps.get(opp.rC_Giving__Parent__c).Participant__c;
                opp.Payment_Hard_Credit_Contact__c = parentOpps.get(opp.rC_Giving__Parent__c).rC_Giving__Hard_Credit_Contact__c;
            }
        }
    }*/ 

    // Purpose: Before Insert: if a new DFC Transaction is inserted:
    //   - Calculate the release date
    //   - Set DF Status
    static void setReleaseDateforDFCTransaction(List <Opportunity> oppList) {

        Integer oppCloseMonth;
        Integer oppCloseYear;

        for (Opportunity opp: oppList) {

            ////system.debug('>>>> Update Release Date on DF');
            ////system.debug('opp.Parent_Product_Type__c:'+opp.Parent_Product_Type__c);
            ////system.debug('opp.DFC_Release_Month__c:'+opp.DFC_Release_Month__c);
            ////system.debug('opp.CloseDate:'+opp.CloseDate);

            // note: on beofe insert: id, record type = null
            if (opp.Parent_Product_Type__c == 'Designated Fund' && opp.DFC_Status__c != 'Auto Fee')
            {

                if (opp.DFC_Release_Month__c> 0)
                {
                    oppCloseMonth = opp.CloseDate.month();
                    oppCloseYear = opp.CloseDate.year();

                    // IF DF is closed in Jan or Feb and Release Mo. at end of year, release for previous year
                    // IF DF is Close Date>2 months AFTER the release month: schedule DF release for following year
                    // OTHERWISE: release same year as Close date
                    if (oppCloseMonth - opp.DFC_Release_Month__c <= -8)
                        opp.DFC_Release_Date__c = date.newInstance((Integer) oppCloseYear - 1, (Integer) opp.DFC_Release_Month__c, 1);
                    else if (oppCloseMonth> opp.DFC_Release_Month__c + 2)
                        opp.DFC_Release_Date__c = date.newInstance((Integer) oppCloseYear + 1, (Integer) opp.DFC_Release_Month__c, 1);
                    else
                        opp.DFC_Release_Date__c = date.newInstance((Integer) oppCloseYear, (Integer) opp.DFC_Release_Month__c, 1);
                } else if (opp.DFC_Release_Date__c == null) {
                    opp.DFC_Release_Date__c = opp.CloseDate;
                }

                opp.DFC_Status__c = 'Pending';
            }
        }
    }


    /**
     * // Purpose: After Insert: Create DFC Fee Opportunity
     * Create DFC's when opp is inserted with Parent_Product_Type__c == 'Designated Fund' and DFC_Status__c != 'Auto Fee'
     * @param oppIDs set of all opp's that are inserted
     */
    static void createDFCFee(List<Opportunity> oppList) {
        //system.debug('>>>> createDFCFee 1');
        set <id> setdonorID1 = new set <id> ();
        List <Opportunity> newDFCFeeOpps = new List <Opportunity> ();
        Map<String, integer> mapDonor_numFeesByMonth = new MAP<String, integer>();        
        Set<ID> oppIDs = new Set<ID>();
        for (Opportunity opp: oppList) {
            if (opp.Parent_Product_Type__c == 'Designated Fund' && opp.DFC_Status__c != 'Auto Fee') {
                setdonorID1.add(opp.rC_Giving__Hard_Credit_Contact__c);
                oppIDs.add(opp.Id);
            }
        }

        if(setDonorID1.size() < 1) {
            return;
        }
        //system.debug('>>>> createDFCFee 2');
        set <id> setdonorID2 = new set <id> ();
        for (Contact con: [SELECT id FROM Contact WHERE
                            Accept_DF_Fee__c = true AND Alliance_Donor__c = false
                            AND id in : setDonorID1]) {
            setdonorID2.add(con.id);
        }

        if (setdonorID2.size() <1)
            return;

        //system.debug('>>>> createDFCFee 3');


        AggregateResult[] results1 = [SELECT rC_Giving__Hard_Credit_Contact__c,
            CALENDAR_MONTH(closedate) themonth,
            count(id)
            FROM Opportunity
            WHERE
            parent_product_type__c = 'Designated Fund'
            and dfc_status__c = 'Auto Fee'
            and rC_Giving__Hard_Credit_Contact__c in : setDonorID2
            and closedate> LAST_MONTH
            and StageName != 'Canceled'
            group by rC_Giving__Hard_Credit_Contact__c, CALENDAR_MONTH(closedate)
        ];

        for (AggregateResult ar: results1) {
            String composite = '' + ar.get('rC_Giving__Hard_Credit_Contact__c') + ar.get('themonth');
            mapDonor_numFeesByMonth.put((String) composite, 1);
        }

        // Get DFC Fee Campaign and GAU
        Campaign feeCampaign = [select id, rC_Giving__GAU__c from Campaign where Product_Sub_Type__c = 'DFC Fee'][0];


        for (Opportunity opp: [SELECT Id, AccountId, Parent_Product_Type__c, DFC_Status__c, rC_Giving__Hard_Credit_Contact__c, CloseDate,
                rC_Giving__Primary_Contact__c, rC_Giving__Parent__c, rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,
                rC_Giving__GL_Batch_Number__c, Sequence_Number__c, AGP_Method__c
                FROM Opportunity WHERE Id in : oppIDs
            ]) {

            // IF new DF transaction AND no other auto fee for this month, create a fee
            if (opp.Parent_Product_Type__c == 'Designated Fund' && opp.DFC_Status__c != 'Auto Fee'
                && (opp.AGP_Method__c == true)
                && !mapDonor_numFeesByMonth.containsKey((string) opp.rC_Giving__Hard_Credit_Contact__c + opp.CloseDate.month()) && setDonorID2.contains(opp.rC_Giving__Hard_Credit_Contact__c)
            ) {

                //system.debug('>>>> Insert DFC Fee');
                //system.debug('>>>> opp.rC_Giving__Hard_Credit_Contact__c:' + opp.rC_Giving__Hard_Credit_Contact__c);
                ////system.debug('>>>> (string) opp.rC_Giving__Hard_Credit_Contact__c + opp.CloseDate.month():'+(string) opp.rC_Giving__Hard_Credit_Contact__c + opp.CloseDate.month());
                ////system.debug('>>>> mapDonor_numFeesByMonth.containsKey((string) opp.rC_Giving__Hard_Credit_Contact__c + opp.CloseDate.month()):'+mapDonor_numFeesByMonth.containsKey((string) opp.rC_Giving__Hard_Credit_Contact__c + opp.CloseDate.month()));
                ////system.debug('>>>> opp.rC_Giving__Hard_Credit_Contact__r.Name:'+opp.rC_Giving__Hard_Credit_Contact__c);
                ////system.debug('>>>> setDonorID2.contains(opp.rC_Giving__Hard_Credit_Contact__r.Name):'+setDonorID2.contains(opp.rC_Giving__Hard_Credit_Contact__c));


                // Insert new DFC Fee - Prototype - IN PROGRESS
                //

                Opportunity newDFCFee = new Opportunity();
                //newDFCFee.AccountId = opp.AccountId;
                newDFCFee.Amount = Decimal.valueOf(System.Label.ChildFund_DFC_Fee);
                
                // set DFC Fee Campaign + GAU
                newDFCFee.Campaignid = feeCampaign.id;
                newDFCFee.rC_Giving__GAU__c = feeCampaign.rC_Giving__GAU__c;

                newDFCFee.rC_Giving__Primary_Contact__c = opp.rC_Giving__Primary_Contact__c;
                newDFCFee.rC_Giving__Hard_Credit_Contact__c = opp.rC_Giving__Hard_Credit_Contact__c;
                newDFCFee.Payment_Hard_Credit_Contact__c = opp.rC_Giving__Hard_Credit_Contact__c;

                newDFCFee.rC_Giving__Parent__c = opp.rC_Giving__Parent__c;
                newDFCFee.rC_Giving__Payment_Method_Selected__c = opp.rC_Giving__Payment_Method_Selected__c;

                //This condition is added by Rohit B on 08/Aug/2016 because if account is specified on the payment method 
                //and we don't populate account on new DFC opp then it will through an validation error.
                if(opp.AccountId != null)
                    newDFCFee.AccountId = opp.AccountId;

                newDFCFee.StageName = 'Open';
                newDFCFee.rC_Giving__Transaction_Type__c = 'Payment';
                newDFCFee.CloseDate = opp.CloseDate;

                newDFCFee.RecordTypeId = (Id) Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
                //newDFCFee.Adjusted_Transaction__c = opp.id;

                newDFCFee.DFC_Status__c = 'Auto Fee';

                newDFCFee.rC_Giving__GL_Batch_Number__c = opp.rC_Giving__GL_Batch_Number__c;
                //newDFCFee.Batch_Number__c = opp.Batch_Number__c;
                newDFCFee.Sequence_Number__c = opp.Sequence_Number__c;

                newDFCFeeOpps.add(newDFCFee);

            }

        }

        if (newDFCFeeOpps.size()> 0) {
            insert newDFCFeeOpps;
        }        
    }
    
    
    // Check for Canceled Sponsorship (after Update)
    // Purpose: cancel all active MCS slips for the participants in these opportunities
    public static void cancelMCSFromOpp(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
        //system.debug('[RB] - OpportunityService.cancelMCSFromOpp :: Method Start..');
        Set <ID> setparID = new Set <ID> ();
        for (Opportunity thisOpp: oppList) {
            if (newMap.get(thisOpp.id).Sponsorship_Status__c == 'Closed' && oldMap.get(thisOpp.id).Sponsorship_Status__c != 'Closed')
                setparID.add(thisOpp.participant__c);
        }

        if (!setparID.isEmpty()) { //&& !System.isFuture()) {
            cancelMCS(setparID);
            isMCSCancelled = true;
        }
        //system.debug('[RB] - OpportunityService.cancelMCSFromOpp :: Method End..');
    } // END public static void cancelMCSFromOpp(List<Opportunity> oppList, Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {

    //@future
    public static void cancelMCS(Set <ID> parIDSet) {
            List <Mail_Control_Slip__c> listMCS = new List <Mail_Control_Slip__c> ();
            listMCS = [Select id
                FROM Mail_Control_Slip__c WHERE
                Participant__c IN: parIDSet
                AND MCS_Status__c = 'Active'
            ];
            // Donor__c = :opp.rC_Giving__Hard_Credit_Account__c

            for (Mail_Control_Slip__c thisMCS: listMCS) {
                thisMCS.MCS_Status__c = 'Cancel';
            }

            if (listMCS.size()> 0)
                update listMCS;
        } // END public static void cancelMCS(Set<ID> parIDSet) {
     /*  // Workflow is populating Name 
    //method to update the opporuntiy name.   
    static void updateTheTransactionOppNamebefore(List <Opportunity> oppsList, Map <Id, Opportunity> oldOppMap, Map <Id, Opportunity> newOppMap) {
            Set <Id> oppIds = new Set <Id> ();
            for (Opportunity tempOpp: oppsList) {
                if (tempOpp.RecordTypeId == RT_TRANSACTION && tempOpp.Product_Sub_Type__c != null && tempOpp.Participant__c != null) {
                    tempOpp.Name = 'TXN: ' + tempOpp.Product_Sub_Type__c + ' - ' + tempOpp.Participant__r.Name;
                }
            }
    }
    */
    //method to update the opporuntiy name.   
    static void updateTheTransactionOppNameafter(List <Opportunity> oppsList, Map <Id, Opportunity> oldOppMap, Map <Id, Opportunity> newOppMap) {
        Set <Id> oppIds = new Set <Id> ();
        for (Opportunity tempOpp: oppsList) {
            if (tempOpp.RecordTypeId == RT_DONATION && tempOpp.Product_Sub_Type__c != null && tempOpp.Participant__c != null && oldOppMap.get(tempOpp.Id).Participant__c != tempOpp.Participant__c) {
                oppIds.Add(tempOpp.Id);
            }
        }
        if (!oppIds.isEmpty()) { //&& !System.isFuture()) { // no need to process further
            updateTheTransactionOppNameafter_Future(oppIds);
        }
    }

    //@future
    static void updateTheTransactionOppNameafter_Future(Set <Id> oppIds) {
            // dummy update all transactions of updated opportunities.
            //List <Opportunity> oppsToUpdate = [select Id from Opportunity where rC_Giving__Parent__c = :oppIds and RecordType.Name = 'Transaction'];
            //I-243345 | To update the name of Transaction Opportunities available on Donation Opportunity >> Start
            List <Opportunity> oppsToUpdate = [select Id, Name, rC_Giving__Parent__c, rC_Giving__Parent__r.Participant__c,
                                               Parent_Product_Sub_Type__c, rC_Giving__Parent__r.Participant__r.FirstName,
                                               rC_Giving__Parent__r.Participant__r.LastName
                                               from Opportunity where rC_Giving__Parent__c = :oppIds and RecordType.Name = 'Transaction'];
            for(Opportunity opp : oppsToUpdate){
                opp.Name = 'TXN:'+ opp.Parent_Product_Sub_Type__c+' - ';
                if(opp.rC_Giving__Parent__c !=null && opp.rC_Giving__Parent__r.Participant__c !=null) {
                    opp.Name += (opp.rC_Giving__Parent__r.Participant__r.FirstName!=null ? opp.rC_Giving__Parent__r.Participant__r.FirstName : '') +' '+opp.rC_Giving__Parent__r.Participant__r.LastName;
                }
            }
            //I-243345 | To update the name of Transaction Opportunities available on Donation Opportunity >> End
            //system.debug('===> oppsToUpdate ' + oppsToUpdate);
            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;
            }
    } // END updateTheTransactionOppNameafter_Future

    //This method is modified by Rohit B on 07/Oct/2016 as per communication with Dirk's & under issue I-238776
    public static void updateSubstituteContRecords(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
        //system.debug('[RB] - OpportunityService.updateSubstituteContRecords :: Method Start..');
        Set <Id> contactIds = new Set <Id> ();
        List <Contact> contactList = new List <Contact> ();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        for (Opportunity opp : oppList) {
            if (opp.Auto_Assign_Participant__c == 'Request for Participant Change' && opp.rC_Sponsorship__Substitute_Contact__c != null && (oldMap == null || oldMap.get(opp.Id).Auto_Assign_Participant__c != newMap.get(opp.Id).Auto_Assign_Participant__c)) {
                contactIds.add(opp.rC_Sponsorship__Substitute_Contact__c);
            }
        }
        //system.debug('[RB] - OpportunityService.updateSubstituteContRecords :: contactIds => ' + contactIds);
        if (!contactIds.isEmpty()) {
            for (Contact con : [select Id, rC_Sponsorship__Sponsorship_Status__c, rC_Sponsorship__Reserve__c, rC_Sponsorship__Reserve_Date__c from Contact where Id in : contactIds]) {
                for(Opportunity opp : oppList) {
                    if(contactIds.contains(opp.rC_Sponsorship__Substitute_Contact__c)) {
                        Opportunity opp_new = new Opportunity(Id = opp.Id);
                        if(con.rC_Sponsorship__Sponsorship_Status__c == 'Reserved' && con.rC_Sponsorship__Reserve__c != null){
                            opp_new.Created_from_Reserve__c = true; 
                        }
                        opp_new.Participant_Reserve__c = con.rC_Sponsorship__Reserve__c;
                        lstOppToUpdate.add(opp_new);
                    }
                }
                con.rC_Sponsorship__Reserve__c = null;
                con.rC_Sponsorship__Reserve_Date__c = null;
                contactList.add(con);
            }
        }
        //system.debug('[RB] - OpportunityService.updateSubstituteContRecords :: lstOppToUpdate => ' + lstOppToUpdate);
        if(lstOppToUpdate.size()>0) {
            update lstOppToUpdate;
        }
        //system.debug('[RB] - OpportunityService.updateSubstituteContRecords :: contactList => ' + contactList);
        if (!contactList.isEmpty()) {
            update contactList;
            for (Contact con : contactList) {
                con.rC_Sponsorship__Sponsorship_Status__c = 'Available';
            }
            update contactList; // Making update again as per issue I-207862
        }
        //system.debug('[RB] - OpportunityService.updateSubstituteContRecords :: Method End..');
    } // END public static void updateSubstituteContRecords(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
    
    
     
    
    
    //Added by Suminder Singh on 9/Dec/2016 for I-246979.
    /**
     *  @Method : updateOppForReserve
     *  @Param : List<Opportunity>
     *  @description :  Method to add logic for Reserve participant.
     *  @return : None
     */
    public static void updateOppForReserve(List <Opportunity> oppList){
         Set <Id> contactIds = new Set <Id> ();
         for(Opportunity opp : oppList){
            if (opp.Auto_Assign_Participant__c == 'Direct Sponsorship' && opp.Participant__c != null) {
                contactIds.add(opp.Participant__c);
             }
         }
         if (!contactIds.isEmpty()) {
            for (Contact contact: [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, rC_Sponsorship__Reserve__c FROM Contact WHERE Id IN : contactIds]) {
                 for(Opportunity opp : oppList) {
                    if(contact.rC_Sponsorship__Sponsorship_Status__c == 'Reserved' && contact.rC_Sponsorship__Reserve__c != null){
                       opp.Created_from_Reserve__c = true; 
                     }
                 }
            }
        }
    }
    
    // Ravi Chauhan | I-224762 | Changes >> Start
    
    public static void updateParticipantContRecords(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
        Set <Id> contactIds = new Set <Id> ();
        List <Contact> contactList = new List <Contact> ();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
        List<rC_Bios__Relationship__c> relationshipList = new List<rC_Bios__Relationship__c>();
        Map<Id,Id> mapOppToParticipant = new Map<Id,Id>();
        
        for (Opportunity opp: oppList) {
            if(opp.Participant__c != null)
                mapOppToParticipant.put(opp.Id,opp.Participant__c);
            oppIds.add(opp.Id);
            if (oldMap != null && newMap != null) {
                if (oldMap.get(opp.Id).Auto_Assign_Participant__c != newMap.get(opp.Id).Auto_Assign_Participant__c && newMap.get(opp.Id).Auto_Assign_Participant__c == 'Direct Sponsorship' && opp.Participant__c != null) {
                    contactIds.add(opp.Participant__c);
                }
            } else if (oldMap == null) { // Insert class
                if (opp.Auto_Assign_Participant__c == 'Direct Sponsorship' && opp.Participant__c != null) {
                    contactIds.add(opp.Participant__c);
                }
            }
        }
        
        if (!contactIds.isEmpty()) {
            for (Contact contact: [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, rC_Sponsorship__Reserve__c, rC_Sponsorship__Reserve_Date__c FROM Contact WHERE Id IN : contactIds]) {
               for(Opportunity opp : oppList) {
                    if(contactIds.contains(opp.Participant__c)) {
                        Opportunity op1 = new Opportunity(id=opp.id);
                        if(contact.rC_Sponsorship__Sponsorship_Status__c == 'Reserved' && contact.rC_Sponsorship__Reserve__c != null){
                          op1.Created_from_Reserve__c = true; 
                        }
                        op1.Participant_Reserve__c = contact.rC_Sponsorship__Reserve__c;
                        lstOppToUpdate.add(op1);
                    }
                }
                contact.rC_Sponsorship__Reserve__c = null;
                contact.rC_Sponsorship__Reserve_Date__c = null;
                contactList.add(contact);
            }
        }
        if(lstOppToUpdate.size()>0) {
            update lstOppToUpdate;
        }
        if (!contactList.isEmpty()) {
            update contactList;
            for (Contact contact: contactList) {
                contact.rC_Sponsorship__Sponsorship_Status__c = 'Available';
            }
            update contactList; // Making update again as per issue I-207862
        }
        // Updation of Relationship Record

        /*for(rC_Bios__Relationship__c relationship : [SELECT id,rC_Bios__Contact_1__c,rC_Bios__Contact_2__c,rC_Bios__Opportunity__c 
                                                     FROM rC_Bios__Relationship__c 
                                                     WHERE rC_Bios__Opportunity__c IN :oppIds
                                                     AND rC_Bios__Category__c = 'Sponsorship'
                                                     AND rC_Bios__Active__c = true]){
            if(relationship.rC_Bios__Contact_2__c != mapOppToParticipant.get(relationship.rC_Bios__Opportunity__c)){
                relationship.rC_Bios__Contact_2__c = mapOppToParticipant.get(relationship.rC_Bios__Opportunity__c);
                relationshipList.add(relationship);
            }
        }
        
        if(relationshipList.size() > 0)
            update relationshipList;*/
    }
    // Ravi Chauhan | I-224762 | Changes >> End

    // This method is created by Rohit B on 02/Mar/2016 under task T-481136 [Clone DFCs from Departed Child, Create for New Child]
    public static void createNewDFCforDepartedChild(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) 
    {
        //on update of opp, for opps that the sponsorship change reason detail contains 'Child Departure',
        //and the participant is not null, status reason is null, and sponsorship status is active.  
        //(The newly created opp retains the 'Child Departure' value because the NGOC code copies it over)
        // - look for most recent closed sponsorship opps that contain the same opp group id
        // - clone DFC related to those closed opportunities
        //  
        
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        
        List<decimal> opportunityGroupIds = new List<decimal>();
        Map<decimal,Opportunity> newOppGroupIdMap = new Map<decimal,Opportunity>();
        
        for(Opportunity opp : oppList)
        {
            //newly created sponsorship opportunities
            if(opp.Sponsorship_Change_Reason_Detail__c != null && 
               opp.Sponsorship_Change_Reason_Detail__c.startsWith('Child Departure -') &&
               opp.Participant__c != null &&
               opp.rC_Sponsorship__Sponsorship_Status_Reason__c == null &&
               opp.rC_Sponsorship__Sponsorship_Status__c == 'Active' &&
               opp.RecordTypeId == donationRecordTypeId &&
               opp.Product_Type__c == 'Sponsorship')
            {
                //if(opp.rC_Sponsorship__Opportunity_Group_Id__c != null)
                //{
                    opportunityGroupIds.add(opp.rC_Sponsorship__Opportunity_Group_Id__c);
                    newOppGroupIdMap.put(opp.rC_Sponsorship__Opportunity_Group_Id__c, opp);
                //}
            } 
        }
        
        //system.debug('**** newOppGroupIdMap.size: ' + string.valueOf(newOppGroupIdMap.size()));

        if(opportunityGroupIds.size() == 0)
            return;
        
        Set<string> closedStatuses = new Set<string>();
        closedStatuses.add('Closed');
        closedStatuses.add('Closed - Participant Change Failed');
        closedStatuses.add('Closed - Participant Changed');
                
        Set<Opportunity> closedSponsorships = new Set<Opportunity>();
        for(Opportunity opp : [SELECT id, isDFCCloned__c, rC_Sponsorship__Opportunity_Group_Id__c
                                    FROM Opportunity
                                    WHERE rC_Sponsorship__Opportunity_Group_Id__c IN :opportunityGroupIds
                                    AND rC_Sponsorship__Sponsorship_Status__c IN :closedStatuses
                                    AND RecordTypeId = :donationRecordTypeId
                                    AND Product_Type__c = 'Sponsorship'
                                    AND isDFCCloned__c = false])
            closedSponsorships.add(opp);
        
        //system.debug('**** closedSponsorships.size: ' + string.valueOf(closedSponsorships.size()));
        
        //bail to cut down on processing time or query
        if(closedSponsorships.size() == 0)
            return;
        
        //TODO: need criteria for active DFC
        string query = 'select id, DFC_Related_Opportunity__r.rC_Sponsorship__Opportunity_Group_Id__c, ' + queryAllFields('Opportunity') + ' from Opportunity where DFC_Related_Opportunity__c in :closedSponsorships';
        //List<Opportunity> oldDFCOpportunities = database.query(query);
        List<Opportunity> newDFCs = new List<Opportunity>();
        
        //clone all the old dfcs and parent them to appropriate new sponsorship opportunity
        for(Opportunity oldDFC : database.query(query))
        {
            Opportunity newDFC = oldDFC.clone(false, false, false, false);
            //newDFC.All_Child_Correspondence__c = true; //I-258680 | Checked in case of Child Departure
            newDFC.DFC_Related_Opportunity__c = newOppGroupIdMap.get(oldDFC.DFC_Related_Opportunity__r.rC_Sponsorship__Opportunity_Group_Id__c).Id;
            newDFC.Participant__c = newOppGroupIdMap.get(oldDFC.DFC_Related_Opportunity__r.rC_Sponsorship__Opportunity_Group_Id__c).Participant__c;
            newDFCs.add(newDFC);
        }
        
        //system.debug('**** newDFCs.size: ' + string.valueOf(closedSponsorships.size()));
        
        if(newDFCs.size() > 0)
            insert newDFCs;
        
        for(Opportunity opp : closedSponsorships)
            opp.isDFCCloned__c = true;
        
        List<Opportunity> sponOppsToUpdate = new List<Opportunity>();
        if(closedSponsorships.size() > 0) {
            sponOppsToUpdate.addAll(closedSponsorships);
            update sponOppsToUpdate;
        }
    } 

    //Method to query all editables fields, so you can clone/edit record of particular object
    static String queryAllFields(String objectName) {
            Map <String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
            list <string> selectFields = new list <string> ();
            String selects = '';

            if (fMap != null) {
                for (Schema.SObjectField ft: fMap.values()) { // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    if (fd.isCreateable()) { // field is creatable
                        selectFields.add(fd.getName());
                    }
                }
            } // END if (fMap != null){

            if (!selectFields.isEmpty()) {
                for (string s: selectFields) {
                    selects += s + ',';
                }

                if (selects.endsWith(',')) {
                    selects = selects.substring(0, selects.lastIndexOf(','));
                }
            } // END if (!selectFields.isEmpty()){
            return selects;
        } // END static String queryAllFields(String objectName) {

    //populate the product type and sub type from the related campaigns GAU - Jagjeet Singh - T-498288
    public static void populateProductTypeFromCampaign(List <Opportunity> oppList) {
        Set<ID> campIDs = new Set<ID>();
        //I-247107 | Commented the code to populate PT and PST on opp as per the GAU as its not valid for the new model
        //Set<ID> giveingIds = new Set<ID>();
        for(Opportunity opp : oppList) {
            if(opp.CampaignId != null && opp.RecordTypeID != RT_TRANSACTION) {
                campIDs.add(opp.CampaignId);
            }   
            /*if(opp.rC_Giving__GAU__c != null && opp.RecordTypeID != RT_TRANSACTION) {
                giveingIds.add(opp.rC_Giving__GAU__c);
            }*/           
        }
        if(campIDs.isEmpty() /*&& giveingIds.isEmpty()*/) {
            return;
        }
        Map<ID, Campaign> campaignMap = new Map<ID, Campaign>([Select ID, rC_Giving__GAU__c,Product_Type__c, Product_Sub_Type__c From Campaign Where ID IN :campIDs]);
        //Map<ID, rC_Giving__GAU__c> givingMap = new Map<ID, rC_Giving__GAU__c>([Select ID,Product_Type__c, Product_Sub_Type__c From rC_Giving__GAU__c Where ID IN :giveingIds]);
        for (Opportunity opp : oppList) { // Need to query again to refer ref fields as they are not  availabe inside trigger   
            if(opp.RecordTypeID == RT_TRANSACTION) {//if(opp.RecordTypeID != RT_TRANSACTION) {
                continue;
            }       
            if (opp.CampaignId != null) {
                if (opp.rC_Giving__GAU__c == null && campaignMap.get(opp.CampaignID) != null && campaignMap.get(opp.CampaignID).rC_Giving__GAU__c != null) {
                    opp.rC_Giving__GAU__c = opp.Campaign.rC_Giving__GAU__c;
                }
                if (opp.Product_Type__c == null && campaignMap.get(opp.CampaignID) != null) {
                    opp.Product_Type__c = campaignMap.get(opp.CampaignID).Product_Type__c;
                    if(campaignMap.get(opp.CampaignID).Product_Type__c == 'Sponsorship'){
                        opp.rC_Giving__Is_Sustainer__c = true;
                    }
                    opp.Product_Sub_Type__c = campaignMap.get(opp.CampaignID).Product_Sub_Type__c;
                }
            }/*else if (opp.rC_Giving__GAU__c != null && givingMap.get(opp.rC_Giving__GAU__c) != null && opp.Product_Type__c == null) {
                    opp.Product_Type__c = givingMap.get(opp.rC_Giving__GAU__c).Product_Type__c;
                    if(opp.Product_Type__c == 'Sponsorship'){
                        opp.rC_Giving__Is_Sustainer__c = true;
                    }
                    opp.Product_Sub_Type__c = givingMap.get(opp.rC_Giving__GAU__c).Product_Sub_Type__c;
            }*/ 
            // If Opp type is Transaction
            //if (opp.RecordTypeId == RT_TRANSACTION && opp.CampaignId == null) { // Transaction has campaign on it's Parent
            //    opp.rC_Giving__GAU__c = opp.rC_Giving__Parent__r.rC_Giving__GAU__c;
            //    opp.CampaignId = opp.rC_Giving__Parent__r.CampaignId;
            //}
        }
    }


    //creates the preference records to prevent the Auto Assign logic from selecting a Recriprocol Alliance participant
    public static void createPreferenceRecordsForNewAssignments(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
        
        Id SponsorshipRecTypeId = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();
        //get the list of opportunities from DB.
        ////system.debug('================inside1==============='+newMap.keySet()+'======='+Trigger.isBefore +'==='+Trigger.isInsert); 
        // process each opp for both conditions
        List<Id> participantIds = createPreferences(oldMap, newMap);
        //performing DML is before event to prevent Auto Assign logic from selecting a Recriprocol Alliance participant)
       if(!participantIds.isEmpty()) {
        //system.debug('==participantIds==' + participantIds.size());
        updateParticipantAvailability(participantIds);
       }
    }
    
    // @Dheeraj: Commented method "updateOppAutoAssignParticipant" as we don't need to populate Auto_Assign_Participant__c field in change of product type and sub type I-246679
    //update AutoAssign Participant
   /* public static void updateOppAutoAssignParticipant(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Boolean isBeforeTrigger) {
        List <Opportunity> oppListToUpdate = new List <Opportunity> ();
        for (Opportunity opp: oppList) {
            //Jagjeet Singh : Updated filter conditions to check for Primary Contact or Child Number before updating Auto Assign
            if (opp.Product_Type__c == 'Sponsorship' &&
                (opp.Auto_Assign_Participant__c == 'Direct Sponsorship' || oldMap == null || oldMap.get(opp.Id).Product_Type__c != opp.Product_Type__c)) {
                Opportunity oppInst = new Opportunity(ID = opp.id);
                //fetch the value from the autoAssignMap
                //oppInst.Auto_Assign_Participant__c = 'New Assignment';
                oppInst.Auto_Assign_Participant__c = 'New Assignment';
                oppListToUpdate.add(oppInst);
            }
        }
        // if list is not empty
        if (!oppListToUpdate.isEmpty() && !Test.isRunningTest()) {
            update oppListToUpdate;
        }
    }*/
    
    
    public static List<Id> createPreferences(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        List <rC_Bios__Preference__c> prefRecList = new List <rC_Bios__Preference__c> ();
        List <Id> participantIds = new List <Id> ();
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        for (Opportunity opp: [select Id, Product_Type__c, rC_Giving__Primary_Contact__r.Alliance_Donor__c, Participant__c, Participant__r.Participant_Number__c, Participant__r.Name, Auto_Assign_Participant__c, rC_Giving__Primary_Contact__r.National_Office__c, rC_Giving__Primary_Contact__r.National_Office__r.Name
                from Opportunity
                where Id In: newMap.keySet()
            ]) {
            
            if (opp.Product_Type__c == 'Sponsorship' && (oldMap == null || oldMap.get(opp.Id).Product_Type__c != opp.Product_Type__c)) { // JS
                // create pre inst
                //system.debug('OpportunityService.createPreferences ----inside----');
                //system.debug('OpportunityService.createPreferences ===>opp.rC_Giving__Primary_Contact__r.Alliance_Donor__c' + opp.rC_Giving__Primary_Contact__r.Alliance_Donor__c);
                rC_Bios__Preference__c prefObj; // = new rC_Bios__Preference__c();
                //Jagjeet : Updated the filter to check fot the Primary Contact Id in Place of alliance donor.
                /*if (opp.rC_Giving__Primary_Contact__r.Alliance_Donor__c && (oldMap == null || opp.rC_Giving__Primary_Contact__r.Alliance_Donor__c != oldMap.get(opp.Id).rC_Giving__Primary_Contact__r.Alliance_Donor__c)) {
                    prefObj = new rC_Bios__Preference__c(); 
                    prefObj.rC_Sponsorship__Opportunity__c = opp.Id;
                    prefObj.rC_Bios__Category__c = 'Sponsorship';
                    prefObj.rC_Bios__Subcategory__c = 'Contact Search';
                    prefObj.rC_Bios__Type__c = 'NO Reciprocal Alliance?';
                    prefObj.rC_Bios__Subtype__c = 'FALSE';
                    prefObj.rC_Bios__Active__c = true;
                    prefObj.Auto_Assign_Preference__c = true;
                    prefRecList.Add(prefObj);
                }*/
                //system.debug('OpportunityService.createPreferences ---inside2---'+opp.Participant__r.Name+'===='+'==='+Trigger.isAfter+'==='+Trigger.isInsert+'==='+opp.Auto_Assign_Participant__c);
                //Jagjeet Singh : Added a check for New Assignment because we are updating the preserved static value
                    if (opp.Auto_Assign_Participant__c == 'Direct Sponsorship' /*StaticConstants.checkPrevRun == false*/ && (oldMap == null || (oldMap.get(opp.Id).Auto_Assign_Participant__c != opp.Auto_Assign_Participant__c))) { // opp.Auto_Assign_Participant__c == 'New Assignment' &&
                         //system.debug('inside1'+opp.Participant__r.Name); 
                        StaticConstants.checkPrevRun = true;                        
                        if (opp.Participant__c != null && opp.Participant__r.Name != null) {                            
                            //system.debug('inside2'+opp.Participant__r.Name); 
                            prefObj = new rC_Bios__Preference__c();
                            prefObj.rC_Sponsorship__Opportunity__c = opp.Id;
                            prefObj.rC_Bios__Category__c = 'Sponsorship';
                            prefObj.rC_Bios__Subcategory__c = 'Contact Search';
                            //prefObj.rC_Bios__Type__c = 'Participant Number';  Needed for Go-Live
                            //prefObj.rC_Bios__Subtype__c = opp.Participant__r.Participant_Number__c;  Needed for Go-Live
                            //For Testing purposes we need to replace the 2 lines above with the following. But for Go-live these needs to be replaced back. T-498437
                            // Instead of full name we need to pass Name (I-240460)
                            //prefObj.rC_Bios__Type__c = 'Full Name';
                            prefObj.rC_Bios__Type__c = 'Participant Number';
                            //prefObj.rC_Bios__Subtype__c = opp.Participant__r.Name;
                            //prefObj.rC_Bios__Subtype__c = opp.Participant__r.Id;
                            prefObj.rC_Bios__Subtype__c = opp.Participant__r.Participant_Number__c;
                            prefObj.rC_Bios__Active__c = true;
                            prefObj.Auto_Assign_Preference__c = true;
                            participantIds.add(opp.Participant__c);
                            //opp.Auto_Assign_Participant__c = 'New Assignment';
                            Opportunity newOpp = new Opportunity(Id = opp.Id, Auto_Assign_Participant__c = 'New Assignment');// I-247336
                            prefRecList.Add(prefObj); 
                            oppToUpdateList.add(newOpp);
                        }
                    }

            }
        }
        
        if(prefRecList.size() > 0) {
            insert prefRecList;
            //I-233215 - Added by Ashu Gupta 
            isPreferenceCreated = true;
        }
        if(oppToUpdateList.size() > 0){
            update oppToUpdateList;
        }
        //system.debug('==PreferenceListSize==' + prefRecList.size());
        //system.debug('==PreferenceList==' + prefRecList);
        return participantIds;
    }
   
   // updating contacts , making it available and  reserve as null
    public static void updateParticipantAvailability(List<Id> participantIds){
        List<Contact> contactList = new List<Contact>();
        if (!participantIds.isEmpty()) {
                for (Contact contact: [select Id, rC_Sponsorship__Sponsorship_Status__c, rC_Sponsorship__Reserve__c, rC_Sponsorship__Reserve_Date__c from Contact where Id in : participantIds]) {
                    contact.rC_Sponsorship__Reserve__c = null;
                    contact.rC_Sponsorship__Reserve_Date__c = null;
                    contact.rC_Sponsorship__Sponsorship_Status__c = 'Available';
                    // I-224762 | Updated the DoNotUpdateReserve__c falg to True
                    contact.DoNotUpdateReserve__c = True;
                    contactList.add(contact);
                    //system.debug('************* WE GOT HERE ***************');
                }
            }
            if (!contactList.isEmpty()) {
                if(!Test.isRunningTest()){
                    update contactList;
                }
                ////system.debug('Ravi Chauhan >> contactList' + [SELECT rC_Sponsorship__Sponsorship_Status__c FROM Contact WHERE id in : participantIds]);
                //for (Contact contact: contactList) {
                    //contact.rC_Sponsorship__Sponsorship_Status__c = 'Available';
                //}
                //update contactList;
            }
    }
    
    /**
     * On Insert of Transaction opportunity and opportunity Stage is Completed', 'Adj From', 'Adj To', 'Returned', 'Refunded' then
     * Populating some of Key fields from Parent Opportunity.
     * @param oppList list of opportunites that are being inserted.
     */
    static void populateTransactionFields(List<Opportunity> oppList) {
        set<id> transOppIds = new set <id> ();
        Set <String> glOppStages = new Set <String> {'Completed', 'Adj From', 'Adj To', 'Returned', 'Refunded'};
        for(Opportunity opp: oppList) {
            if(opp.RecordTypeId == RT_TRANSACTION && glOppStages.contains(opp.StageName)) { // Only for Transaction Opp
                transOppIds.add(opp.rC_Giving__Parent__c);
            }
        }
        if (transOppIds.size() < 1) {
            return;
        }
        Map<ID, Opportunity> parentOpps = new Map<ID,Opportunity>([SELECT Id, Campaignid, rC_Giving__GAU__c, Participant__c,FOC__c, 
            rC_Giving__Hard_Credit_Contact__c, Adjustment_Reason__c, Adjustment_Comments__c, Adjusted_Transaction__c, Sponsored_Account__c, Batch_Number__c, Sequence_Number__c
            FROM Opportunity WHERE id in : transOppIds]);
        if (parentOpps.size()>0) {
            for (Opportunity opp: oppList) {
                if(opp.RecordTypeId == RT_TRANSACTION && glOppStages.contains(opp.StageName)) {
                    if (opp.Campaignid == null)
                        opp.Campaignid = parentOpps.get(opp.rC_Giving__Parent__c).Campaignid;
                    if (opp.rC_Giving__GAU__c == null)
                        opp.rC_Giving__GAU__c = parentOpps.get(opp.rC_Giving__Parent__c).rC_Giving__GAU__c;
                    if (opp.Participant__c == null)
                        opp.Participant__c = parentOpps.get(opp.rC_Giving__Parent__c).Participant__c;
                    if (opp.Adjustment_Reason__c == null)
                        opp.Adjustment_Reason__c = parentOpps.get(opp.rC_Giving__Parent__c).Adjustment_Reason__c;
                    if (opp.Adjustment_Comments__c == null)
                        opp.Adjustment_Comments__c = parentOpps.get(opp.rC_Giving__Parent__c).Adjustment_Comments__c;
                    if (opp.Adjusted_Transaction__c == null && parentOpps.get(opp.rC_Giving__Parent__c).Adjusted_Transaction__c != null)
                        opp.Adjusted_Transaction__c = parentOpps.get(opp.rC_Giving__Parent__c).Adjusted_Transaction__c;
                    if (opp.Sponsored_Account__c == null && parentOpps.get(opp.rC_Giving__Parent__c).Sponsored_Account__c != null)
                        opp.Sponsored_Account__c = parentOpps.get(opp.rC_Giving__Parent__c).Sponsored_Account__c;
                    if (opp.rC_Giving__Hard_Credit_Contact__c == null && parentOpps.get(opp.rC_Giving__Parent__c).rC_Giving__Hard_Credit_Contact__c != null)
                        opp.rC_Giving__Hard_Credit_Contact__c = parentOpps.get(opp.rC_Giving__Parent__c).rC_Giving__Hard_Credit_Contact__c;
                    if (opp.Batch_Number__c == null && parentOpps.get(opp.rC_Giving__Parent__c).Batch_Number__c != null)
                        opp.Batch_Number__c = parentOpps.get(opp.rC_Giving__Parent__c).Batch_Number__c;
                    if (opp.Sequence_Number__c == null && parentOpps.get(opp.rC_Giving__Parent__c).Sequence_Number__c != null)
                        opp.Sequence_Number__c = parentOpps.get(opp.rC_Giving__Parent__c).Sequence_Number__c;    
                    
                    //Added as a fix to Issue I-262105. 
                    //It will update FOC on transaction opportunity from parent opportunity.
                    if (opp.FOC__c == null && parentOpps.get(opp.rC_Giving__Parent__c).FOC__c != null)
                        opp.FOC__c = parentOpps.get(opp.rC_Giving__Parent__c).FOC__c;    
                         
                    // not really needed, this is done by NGOC:
                    opp.Payment_Hard_Credit_Contact__c = parentOpps.get(opp.rC_Giving__Parent__c).rC_Giving__Hard_Credit_Contact__c;
                }
            }
        }
    }     
    //updating the opportunity to 'new Assignment' againt to create sponsorships from NGOC logic. This will be done only in case of opportunity creation.
    /*public static void updateFinalOpportunityStatus(List <Opportunity> oppList, Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap) {
        staticConstants.isFromInsert = true; //variable to stop unnecessary updation of Opportunities 
        List<Opportunity> opporList =  [select Id, Product_Type__c,  Auto_Assign_Participant__c from Opportunity where Id in :oppList];
        List<Opportunity> oppors = new List<Opportunity>();
        /*for(Opportunity opp : opporList){
            if(opp.Product_Type__c == 'Sponsorship'){
                opp.Auto_Assign_Participant__c = 'False';
                oppors.add(opp);
            }
        }
        if(!oppors.isEmpty()){
            update oppors;
        }
        oppors = new List<Opportunity>();
        for(Opportunity opp : opporList){
            if(opp.Product_Type__c == 'Sponsorship'){
                opp.Auto_Assign_Participant__c = 'New Assignment';
                oppors.add(opp);
            }
        }
        if(!oppors.isEmpty()){
            update oppors;
        }
        staticConstants.isFromInsert = false; // variable to stop unnecessary updation of Opportunities reset
        //system.debug('===getting Insert Value==='+staticConstants.isFromInsert);
    }*/
    
    public static void BatchLetters_CIF(List <Opportunity> oppList, Map <Id, Opportunity> oldOppMap)
    {
        ////system.debug('#### BatchLetters_CIF :: Method Start..'+oppList +'OldOppMap is :'+oldOppMap);
        /**/
            // CIF printed only for newly created/assigned child sponsorships
        List<ID> CIFOppIDs = new List<ID>();

        for (Opportunity opp : oppList)
        {
                // only process child sponoships
            if (opp.Product_Type__c != 'Sponsorship' || opp.Product_Sub_Type__c != 'Child Sponsorship')
                continue;

                // child must be tied to Opp
            if (opp.Participant__c == null)
                continue;

                // this is a child sponsorship record being updated
            if (oldOppMap != null)
            {

                // if an update, only process if participant is newly populated
                if (oldOppMap.get(opp.id).Participant__c != null)
                    continue;
            }

            CIFOppIDs.add(opp.id);
        }

            //
            // process CIF Batch Letters
            //

        if (CIFOppIDs.size() < 1)
            return;

        List<Opportunity> myOppList = new List<Opportunity>();
        myOppList = [select id,
            rC_Giving__Primary_Contact__c,
            rC_Giving__Hard_Credit_Contact__c,
            rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,
            Sponsorship_Change_Reason_Detail__c,
            Paid_Through_Date__c,
            Sponsorship_Status_Reason_Copy__c,
            rC_Sponsorship__Opportunity_Group_Id__c,
            rC_Giving__Primary_Contact__r.Active_Sponsorships__c,
            rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c,
            rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__c,
            rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__r.Alliance_CIF_Format__c,
            Participant__r.rC_Sponsorship__Reserve__r.Alliance__c,
            Participant_Reserve__r.Alliance__c,
            AGP_Method__c,
            Gift_Sponsorship__c
            From Opportunity
            Where id in :CIFOppIDs];

        Set<Integer> setOppGrpIDs = new Set<Integer>();
        for (Opportunity myopp : myOppList ){
            if (myopp.rC_Sponsorship__Opportunity_Group_Id__c != NULL){  //Added by JH 12.29.2016 for I-250377
            setOppGrpIDs.add( (Integer) myopp.rC_Sponsorship__Opportunity_Group_Id__c);
            }
            }


            // Note: at this point, old sponsorship status NOT yet Closed, so, getting most recent created
        List<Opportunity> listAllDeparted = new List<Opportunity>();
        listAllDeparted = [select id, participant__c, rC_Sponsorship__Opportunity_Group_Id__c, Sponsorship_Status__c
        From Opportunity
        Where
        rC_Sponsorship__Opportunity_Group_Id__c IN :setOppGrpIDs
        ORDER BY CreatedDate DESC];

        //        AND Sponsorship_Status__c = 'Closed'

        Map<Integer, ID> mapGrpID_mostRecentDeparted = new Map<Integer, ID>();
        for (Opportunity myopp1 : listAllDeparted ) {
            if (!mapGrpID_mostRecentDeparted.containsKey( (Integer) myopp1.rC_Sponsorship__Opportunity_Group_Id__c))
                mapGrpID_mostRecentDeparted.put( (Integer) myopp1.rC_Sponsorship__Opportunity_Group_Id__c, myopp1.participant__c);
        }


        List<Print_Queue__c> listPrintQueue = new List<Print_Queue__c>();
        for (Opportunity opp : myOppList)
        {
            Print_Queue__c pq = new Print_Queue__c();
            pq.Opportunity__c = opp.id;

            boolean isAGP = false;
            if (opp.AGP_Method__c == true )
                    isAGP = true;

            //system.debug('#### opp.rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c:'+ opp.rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c);
            //system.debug('#### opp.Sponsorship_Change_Reason_Detail__c:'+ opp.Sponsorship_Change_Reason_Detail__c);
            //system.debug('#### opp.Sponsorship_Status_Reason_Copy__c:'+ opp.Sponsorship_Status_Reason_Copy__c);
            //system.debug('#### opp.Gift_Sponsorship__c:'+ opp.Gift_Sponsorship__c);
            //system.debug('#### isAGP:'+ isAGP);
            //system.debug('#### opp.rC_Giving__Primary_Contact__r.Active_Sponsorships__c:'+ opp.rC_Giving__Primary_Contact__r.Active_Sponsorships__c);

                    // If this Opp is for an Alliance Donor, check for Alliance specific CIFs
                ////system.debug('----opp.rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c---' + opp.rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c);
            if (opp.rC_Giving__Hard_Credit_Contact__c !=null && opp.rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c !=null && opp.rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c == TRUE)
            {   
                // note: opp.Participant_Reserve__r.Alliance__c is null, not getting populated so we can't use
                //system.debug('----opp.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__c---' + opp.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__c);
                //system.debug('----opp.Participant_Reserve__r.Alliance__c---' + opp.Participant_Reserve__r.Alliance__c);
                //system.debug('----opp.Participant__r.rC_Sponsorship__Reserve__r.Alliance__c---' + opp.Participant__r.rC_Sponsorship__Reserve__r.Alliance__c);
                //system.debug('----opp.Sponsorship_Change_Reason_Detail__c---' + opp.Sponsorship_Change_Reason_Detail__c);
                //system.debug('----opp.Sponsorship_Status_Reason_Copy__c---' + opp.Sponsorship_Status_Reason_Copy__c);
                //Vaibhav - july 7,2016 Adding //system.debug to check where the changes made by Dirk are causing test class - DonorPortalServiceTest to fail
                
                // Check if child is assigned from an Alliance reserve that belongs to the donor's Alliance
                //  If yes: exit; alliance already has materials, don't create letter. If no: need to send new materials

                // TBD: check Participant_Reserve__c
                if (opp.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__c ==
                    opp.Participant_Reserve__r.Alliance__c)
                    //opp.Participant__r.rC_Sponsorship__Reserve__r.Alliance__c)
                    return;

                if (opp.Sponsorship_Change_Reason_Detail__c != null && opp.Sponsorship_Change_Reason_Detail__c.contains('Child Departure'))
                {
                        // Letter: Child Departure
                        pq.Prior_Participant_ID__c = mapGrpID_mostRecentDeparted.get( (Integer) opp.rC_Sponsorship__Opportunity_Group_Id__c);
                        //pq.Letter_ID__c = 'Alliance - out of pool child departure';     // 1358? Alliance Child Departure, outside of Alliance pool
                        pq.Letter_ID__c = opp.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__r.Alliance_CIF_Format__c;
                }
                else if (opp.Sponsorship_Status_Reason_Copy__c == 'Participant Change')
                {
                    // Letter: Change of Child
                    pq.Prior_Participant_ID__c = mapGrpID_mostRecentDeparted.get( (Integer) opp.rC_Sponsorship__Opportunity_Group_Id__c);
                    //pq.Letter_ID__c = 'Alliance - out of pool participant change';     // 2306? Alliance Change of Child, outside of Alliance pool
                    pq.Letter_ID__c = opp.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__r.Alliance_CIF_Format__c;
                }
                else if (opp.Sponsorship_Status_Reason_Copy__c == null)
                {
                    // New Alliance Sponsorship outside of Alliance pool
                    //pq.Letter_ID__c = 'Alliance - out of pool new sponsorship';     // Alliance new sponsorship, outside of Alliance pool
                    pq.Letter_ID__c = opp.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__r.Alliance_CIF_Format__c;
                }

            }       // For all US Based donors ...
            else if (opp.Sponsorship_Change_Reason_Detail__c != null
                && opp.Sponsorship_Change_Reason_Detail__c.contains('Child Departure'))
            {
           
                // Letter: Child Departure
                pq.Prior_Participant_ID__c = mapGrpID_mostRecentDeparted.get( (Integer) opp.rC_Sponsorship__Opportunity_Group_Id__c);
                
                //if(opp.rC_Giving__Primary_Contact__c == opp.rC_Giving__Hard_Credit_Contact__c){//I-247095 | Only create PrintQueue when Primary and Hard Credit Contact are same
                    if (!isAGP)
                        pq.Letter_ID__c = '41';     // Child Departure - not on AGP
                    else
                        pq.Letter_ID__c = '42';     // Child Departure, Adv PTD
                //}
                
            }
            else if (opp.Sponsorship_Status_Reason_Copy__c == 'Participant Change')
            {

                // Letter: Change of Child
                pq.Prior_Participant_ID__c = mapGrpID_mostRecentDeparted.get( (Integer) opp.rC_Sponsorship__Opportunity_Group_Id__c);

                //if (opp.Paid_Through_Date__c > Date.today())
                //if(opp.rC_Giving__Primary_Contact__c == opp.rC_Giving__Hard_Credit_Contact__c){//I-247093 | Only create PrintQueue when Primary and Hard Credit Contact are same
                    if (!isAGP)
                        pq.Letter_ID__c = '49';     // Change of Child Sponsor
                    else
                        pq.Letter_ID__c = '48';     // Change of Child Presponsor
                //}
            }
            else if (opp.Sponsorship_Status_Reason_Copy__c == 'Sponsors Transfer')
            {
                // Letter: Sponsor Transfer
                pq.Letter_ID__c = '51';     // Sponsor Transfer

            }
            else if (opp.Sponsorship_Status_Reason_Copy__c == null)
            {
                // GIFT FLAG
                if (opp.Gift_Sponsorship__c == false)
                //if (opp.rC_Giving__Primary_Contact__c == opp.rC_Giving__Hard_Credit_Contact__c)
                {
                    // Letter: New Sponsor
                    
                    if (opp.rC_Giving__Primary_Contact__r.Active_Sponsorships__c == null)
                        opp.rC_Giving__Primary_Contact__r.Active_Sponsorships__c = 0;

                    if (isAGP && opp.rC_Giving__Primary_Contact__r.Active_Sponsorships__c == 0)
                        pq.Letter_ID__c = '30';     // Money Assign Single Child, also: 31, 31_multi
                    else if (isAGP && opp.rC_Giving__Primary_Contact__r.Active_Sponsorships__c > 0)
                        pq.Letter_ID__c = '32';     // Money Assign Additional Single, also: 33, 33_multi
                    else if (!isAGP && opp.rC_Giving__Primary_Contact__r.Active_Sponsorships__c == 0)
                        pq.Letter_ID__c = '34';     // No Money Assign Single, also: 35, 35_multi
                    else if (!isAGP && opp.rC_Giving__Primary_Contact__r.Active_Sponsorships__c > 0)
                        pq.Letter_ID__c = '36';     // No Money Assign Additional Single, also: 37, 37_multi

                }
                else
                {
                    // Letter: Gift Recipient
                    pq.Letter_ID__c = '39';     // Gift Recipient

                }
            }

            if (pq.Letter_ID__c != null)
                listPrintQueue.add(pq);
        }

        if (listPrintQueue.size() > 0) {
            insert(listPrintQueue);
            isBatchLetters_CIFProcessed = true; 
        }

        /**/
        //system.debug('>>> BatchLetters_CIF :: Method End..');
    }

        // Process Cancellations and Child Departure Batch Letters
    public static void BatchLetters_Cancelation(List <Opportunity> oppList, Map <Id, Opportunity> oldOppMap)
    {
        Date firstDayNextMonth = system.today().addMonths(1).toStartofMonth();
        //system.debug('>>> BatchLetters_Cancelation :: Method Start..  ');
        List<Print_Queue__c> listPrintQueue = new List<Print_Queue__c>();

        List<ID> listDonors = new List<ID>();
        for (Opportunity opp : oppList)
        {
            listDonors.add(opp.rC_Giving__Hard_Credit_Contact__c);
        }

        for (Opportunity opp : oppList)
        {
            Print_Queue__c pq = new Print_Queue__c();
            pq.Opportunity__c = opp.id;

                // only process child sponoships
            if (opp.Product_Type__c != 'Sponsorship' || opp.Product_Sub_Type__c != 'Child Sponsorship')
                continue;

                // child must be tied to Opp
            if (opp.Participant__c == null)
                continue;

            isBatchLettersCanceledProcessed = true;
                //system.debug ('Opportunity $$$'+opp);
                // Process Child Departure No Sub Cancelations
           //     System.AssertEquals(opp.rC_Sponsorship__Sponsorship_Status_Reason__c ,'Cancellation');
            if (opp.rC_Sponsorship__Sponsorship_Status_Reason__c == 'Cancellation' &&
                oldOppMap.get(opp.id).rC_Sponsorship__Sponsorship_Status_Reason__c == null &&
                opp.Sponsorship_Change_Reason_Detail__c != null &&
                opp.Sponsorship_Change_Reason_Detail__c.contains('Child Departure') &&
                opp.rC_Sponsorship__Do_Not_Substitute__c == TRUE &&
                opp.CFI_Do_Not_Substitute__c != null)
            {
                if (opp.CFI_Do_Not_Substitute__c == 'Do Not Substitute - Contact Donor')
                {
                    if ( opp.Paid_Through_Date__c >= firstDayNextMonth)
                    {
                        // Child Departure - Do not sub - Contact Sponsor - Paid in adv
                        pq.Letter_ID__c = '1353';
                    }
                    else
                    {
                        // Child Departure - Do not sub - Contact Sponsor - NOT Paid in adv
                        pq.Letter_ID__c = '1352';
                    }
                }
                else
                {
                    // Do not contact Donor

                    if ( opp.Paid_Through_Date__c >= firstDayNextMonth)
                    {
                        // Child Departure - Do not sub - Do not Contact Sponsor - Paid in adv
                        pq.Letter_ID__c = '1351';
                    }
                    else
                    {
                        // Child Departure - Do not sub - Do not Contact Sponsor - NOT Paid in adv
                        pq.Letter_ID__c = '1350';
                    }
                }
            }

                // Process new 'immediate Cancel' opportunities
                // rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation'
                // Cancel_Sponsorship__c = Cancel - No Reinstate, Cancel - Reinstateable, Future Cancel
            else if (opp.rC_Sponsorship__Sponsorship_Status_Reason__c == 'Cancellation' &&
                opp.Cancel_Sponsorship__c != null &&
                oldOppMap.get(opp.id).rC_Sponsorship__Sponsorship_Status_Reason__c == null)
            {
                if (opp.rC_Sponsorship__Future_Cancellation_Date__c == null)
                {
                    if (opp.Sponsorship_Change_Reason_Detail__c != null &&
                        opp.Sponsorship_Change_Reason_Detail__c.contains('Replacement Child Declined'))
                    {
                        // Immediate Cancel - Sub Decline 
                        pq.Letter_ID__c = '1500';                    
                    }
                    else if (opp.Sponsorship_Change_Reason_Detail__c != null &&
                        !opp.Sponsorship_Change_Reason_Detail__c.contains('Delinquency'))
                    {
                        // Immediate Cancel - Generic - Single Child
                        pq.Letter_ID__c = '1501';
                    }
                }
                else
                {
                    // Future cancelation date is set

                    ////system.debug('******** opp.Paid_Through_Date__c  '+ (Date) opp.Paid_Through_Date__c);
                    ////system.debug('******** firstDayNextMonth  '+firstDayNextMonth);

                    if ( (Date) opp.Paid_Through_Date__c >= (Date) firstDayNextMonth)
                    {
                        // Future Cancel - Single Child - Adv PTD
                        pq.Letter_ID__c = '1450';
                    }
                    else
                    {
                        // Future Cancel - Single Child - Current PTD
                        pq.Letter_ID__c = '1451';
                    }
                }

            }

            // Opportunity.CFI_Do_Not_Substitute__c = 'Do Not Substitute' 'Do Not Substitute - Contact Donor'
            // Opportunity.rC_Sponsorship__Do_Not_Substitute__c = TRUE

            if (pq.Letter_ID__c != null) {
                listPrintQueue.add(pq);
            }
        }

        if (listPrintQueue.size() > 0)
            insert(listPrintQueue);

    }

    public static void BatchLetters_Suspense(List <Opportunity> oppList)
    {
        List<Print_Queue__c> listPrintQueue = new List<Print_Queue__c>();
        
        Id suspenseID;
            // get IDs of all 'adjusted transactions'
        
        List<rC_Giving__GAU__c> suspenseIDList = [select id from rC_Giving__GAU__c where Receipt_Category__c = '0600'];
        if(!suspenseIDList.isEmpty()){
            suspenseID = suspenseIDList[0].id;
        }
    
    
            // get IDs of all 'adjusted transactions'
        //ID suspenseID = [select id from rC_Giving__GAU__c where Name = '600'][0].id;

        List<ID> listAdjOppIds = new List<ID>();
        for (Opportunity opp : oppList) {
            
            //system.debug('###### opp.rC_Giving__GAU__c:'+opp.rC_Giving__GAU__c);
            //system.debug('###### opp.GAU_Description__c:'+opp.GAU_Description__c);
            //system.debug('###### opp.RecordTypeId:'+opp.RecordTypeId);

            if (/*suspenseID != null && */ opp.rC_Giving__GAU__c == suspenseID && opp.RecordTypeId == RT_TRANSACTION)
                listAdjOppIds.add(opp.Adjusted_Transaction__c);
        }

        //system.debug('###### listAdjOppIds.size():'+listAdjOppIds.size());
        if (listAdjOppIds.size() < 1)
            return;
        
        isBatchLetters_SuspenseProcessed = true;

            // get the product type of those adjusted transactions, and put into map
        List<Opportunity> listAdjOpps = new List<Opportunity>();
        listAdjOpps = [select Parent_Product_Type__c, DFC_Status__c
            from opportunity where
            id IN :listAdjOppIds ];

        Map<ID, Opportunity> mapID_adjOpp = new Map<ID, Opportunity>();
        for (Opportunity myopp1 : listAdjOpps ) 
                mapID_adjOpp.put( (ID) myopp1.id, (Opportunity) myopp1 );

            // process all new 'GAU = 600' transactions
        for (Opportunity opp : oppList)
        {
            if (/*suspenseID !=null && */opp.rC_Giving__GAU__c != suspenseID || opp.RecordTypeId != RT_TRANSACTION)
                continue;
            
            Print_Queue__c pq = new Print_Queue__c();
            //system.debug('====================M'+opp);
            if (mapID_adjOpp.containsKey(opp.Adjusted_Transaction__c) && 
                mapID_adjOpp.get(opp.Adjusted_Transaction__c).Parent_Product_Type__c != null &&
                mapID_adjOpp.get(opp.Adjusted_Transaction__c).Parent_Product_Type__c == 'Designated Fund')
            {
                //System.assertEquals(mapID_adjOpp.get(opp.Adjusted_Transaction__c).DFC_Status__c, 'Undeliverable - Over $100');
                if (mapID_adjOpp.get(opp.Adjusted_Transaction__c).DFC_Status__c == 'Undeliverable - Over $100')
                {
                    pq.Opportunity__c = opp.id;
                    pq.Letter_ID__c = '58';
                }
                else if (mapID_adjOpp.get(opp.Adjusted_Transaction__c).DFC_Status__c == 'Undeliverable - Project Closed')
                {
                    pq.Opportunity__c = opp.id;
                    pq.Letter_ID__c = '59';
                }
            }
            else
            {
                pq.Opportunity__c = opp.id;
                pq.Letter_ID__c = '56';
            }
            
            if (pq.Letter_ID__c != null)
                listPrintQueue.add(pq);
        }

        if (listPrintQueue.size() > 0)
            insert(listPrintQueue);
    }

    public static void BatchLetters_SuspenseKeptbyLP_ACHReturn(List <Opportunity> oppList, Map <Id, Opportunity> oldOppMap)
    {
        List<Print_Queue__c> listPrintQueue = new List<Print_Queue__c>();

        for (Opportunity opp : oppList)
        {
            // if dfc status has changed on the transaction to: Kept by LP/Community
            if (
                (opp.RecordTypeId == RT_TRANSACTION) &&
                (opp.dfc_status__c != oldOppMap.get(opp.id).dfc_status__c) &&
                (opp.dfc_status__c == 'Kept by LP/Community')
            )
            {
                Print_Queue__c pq = new Print_Queue__c();
                pq.Opportunity__c = opp.id;
                pq.Letter_ID__c = '57';

                listPrintQueue.add(pq);
            }
            // if the return code is set on an opportunity -> ACH return 
            // NOTE: 683 is replaced by 'ACH Automated Return' image code
            /*
            else if (
                (opp.RecordTypeId == RT_TRANSACTION) &&
                (opp.Return_Code__c != oldOppMap.get(opp.id).Return_Code__c)
            )
            {
                Print_Queue__c pq = new Print_Queue__c();
                pq.Opportunity__c = opp.id;
                pq.Letter_ID__c = '683';

                listPrintQueue.add(pq);
            }
            */
        }

        if (listPrintQueue.size() > 0)
            insert(listPrintQueue);
    }

    //Added by Ravi Chauhan on 24/Jun/2016 for T-514023.  <<START>>
    /**
     *  @Method : updateOpportunityOwner
     *  @Param : List<Opportunity>
     *  @description :  Method for updating the owner of Opportunity.
     *  @return : None
     */
    /* 
    static void updateOpportunityOwner(List<Opportunity> oppList,Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap){
        
        List<Opportunity> filteredOpportunitiesList = new List<Opportunity>();
        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Set<Id> participantIds = new Set<Id>();
        Set<Id> participantNewIds = new Set<Id>();
        Set<Id> localPartnerNationalOfficeIds = new Set<Id>();
        Set<Id> nationalOfficeIds = new Set<Id>();
        Map<Id,Contact> participantToLocalPartnerMap = new Map<Id,Contact>();
        Map<Id,Contact> participantToNationalOfficeMap = new Map<Id,Contact>();
        Map<Id, Account> localPartnerNationalOfficeMap = new Map<Id, Account>();
        Map<Id, Account> nationalOfficeMapNew = new Map<Id, Account>();
        Map<Id,Contact> participantToNationalOfficeMapNew = new Map<Id,Contact>();
        Map<Id, Opportunity> transOppMap = new Map<Id, Opportunity>();
        List<Opportunity> transOpportunitiesList = new List<Opportunity>();
        set <id> transOppParentIds = new set <id> ();
        // Filtering the Opportunity records during insertion OR updation 
        
        for(Opportunity opp : oppList){
            if(oldMap == null && opp.RecordTypeId == RT_DONATION && (opp.rC_Sponsorship__Sponsorship_Status__c == 'Active' || opp.Product_Type__c == 'Designated Fund')//I-260691 - updated for Designated Fund
                && opp.Participant__c != null){
                filteredOpportunitiesList.add(opp);
                participantIds.add(opp.Participant__c);
                transOppParentIds.add(opp.Id);                
            }

            else if(oldMap != null && newMap != null && opp.RecordTypeId == RT_DONATION
                    && (opp.rC_Sponsorship__Sponsorship_Status__c == 'Active' || opp.Product_Type__c == 'Designated Fund') && opp.Participant__c != null){
                filteredOpportunitiesList.add(opp);
                participantIds.add(opp.Participant__c);
                transOppParentIds.add(opp.Id);
            }
            
            //Added by Ashu Gupta for T-525408--Start
            if(OldMap == null && opp.rC_Sponsorship__Sponsorship_Status__c == 'Active'){
                    opportunitiesList.add(opp);
                    //system.debug('Inside @@@');
                        participantNewIds.add(opp.Participant__c);
       
            }
            else if(OldMap != null && newMap != null && newMap.get(opp.Id).rC_Sponsorship__Sponsorship_Status__c != oldMap.get(opp.Id).rC_Sponsorship__Sponsorship_Status__c && newMap.get(opp.Id).rC_Sponsorship__Sponsorship_Status__c == 'Active'){
                    opportunitiesList.add(opp);
                    //system.debug('Inside Update case @@@');
                    participantNewIds.add(opp.Participant__c);
            }
            //Added by Ashu Gupta for T-525408--End
        }
        
        //Added as per issue I-252203
        if(transOppParentIds.size() > 0){
            transOppMap = new Map<Id, Opportunity>([SELECT Id, OwnerId, rC_Giving__Parent__c FROM Opportunity
                                                    WHERE rC_Giving__Parent__c !=  null AND rC_Giving__Parent__c IN : transOppParentIds 
                                                    AND RecordTypeId = :RT_TRANSACTION ]);
        }

        //Added by Ashu Gupta for T-525408--Start
        if(participantNewIds.size() > 0){
                List<Contact> participantLst =[SELECT Id, National_Office__c 
                                            FROM Contact WHERE id IN :participantNewIds
                                            ];
            for(Contact con : participantLst){
                    if(con.National_Office__c != null){
                    nationalOfficeIds.add(con.National_Office__c);
                    //localPartnerNationalOfficeIds.add(con.National_Office__c);
                    participantToNationalOfficeMapNew.put(con.id, con);
                }

            }
        }

        if(nationalOfficeIds.size() > 0){
            nationalOfficeMapNew = new Map<Id, Account>([SELECT Id, Reciprocal_GAU__c FROM Account WHERE id IN :nationalOfficeIds]);
        }
         //Updating the Gau field on Opportunity When rC_Sponsorship__Sponsorship_Status__c is changed to Active 
        for(Opportunity opp : opportunitiesList){
            if(participantToNationalOfficeMapNew.containsKey(opp.Participant__c) && participantToNationalOfficeMapNew.get(opp.Participant__c) != null 
                        && nationalOfficeMapNew.containsKey(participantToNationalOfficeMapNew.get(opp.Participant__c).National_Office__c) 
                        && nationalOfficeMapNew.get(participantToNationalOfficeMapNew.get(opp.Participant__c).National_Office__c) != null
                        && nationalOfficeMapNew.get(participantToNationalOfficeMapNew.get(opp.Participant__c).National_Office__c).Reciprocal_GAU__c != null){
                //system.debug('@@@ inside further');
                //update gau with the Reciprocal_GAU__c of the Participant's National Office 
                opp.rC_Giving__GAU__c = nationalOfficeMapNew.get(participantToNationalOfficeMapNew.get(opp.Participant__c).National_Office__c).Reciprocal_GAU__c;
            }
        }//Added by Ashu Gupta for T-525408--End
        
        
        // Fetching the Local Partner and National Office of the Participant of Mail Control Slip
        if(participantIds.size() > 0){
            List<Contact> participantList =[SELECT Id, Local_Partner__c, National_Office__c 
                                            FROM Contact WHERE id IN :participantIds
                                            ];
            for(Contact con : participantList){
                //system.debug('Participants => '+participantList+ 'Local Partner => '+con.Local_Partner__c+ '; National Office => '+con.National_Office__c);
                if(con.Local_Partner__c != null){
                    localPartnerNationalOfficeIds.add(con.Local_Partner__c);
                    participantToLocalPartnerMap.put(con.id, con);
                }
                if(con.National_Office__c != null){
                    localPartnerNationalOfficeIds.add(con.National_Office__c);
                    participantToNationalOfficeMap.put(con.id, con);
                }
            }
        }

        if(localPartnerNationalOfficeIds.size() > 0){
            localPartnerNationalOfficeMap = new Map<Id, Account>([SELECT Id, Participant_Contact_Owner__c FROM Account WHERE id IN :localPartnerNationalOfficeIds]);
        }
        
        // Update Opportunity Owner based on business logic
        for (Opportunity opp: filteredOpportunitiesList){
                if(participantToLocalPartnerMap.containsKey(opp.Participant__c) && participantToLocalPartnerMap.get(opp.Participant__c) != null 
                   && localPartnerNationalOfficeMap.containsKey(participantToLocalPartnerMap.get(opp.Participant__c).Local_Partner__c) 
                   && localPartnerNationalOfficeMap.get(participantToLocalPartnerMap.get(opp.Participant__c).Local_Partner__c) != null
                   && localPartnerNationalOfficeMap.get(participantToLocalPartnerMap.get(opp.Participant__c).Local_Partner__c).Participant_Contact_Owner__c != null){
                    opp.ownerid = localPartnerNationalOfficeMap.get(participantToLocalPartnerMap.get(opp.Participant__c).Local_Partner__c).Participant_Contact_Owner__c;
                    //Logic to update transaction opportuntiy owner as per issue I-252203
                    if(transOppMap != null){
                        for(Opportunity transOpp : transOppMap.values()){
                            if(transOpp.rC_Giving__Parent__c == opp.Id){
                                transOpp.OwnerId = opp.ownerid;
                                transOpportunitiesList.add(transOpp);
                            }
                        }
                    }
                }
                else if(participantToNationalOfficeMap.containsKey(opp.Participant__c) && participantToNationalOfficeMap.get(opp.Participant__c) != null 
                        && localPartnerNationalOfficeMap.containsKey(participantToNationalOfficeMap.get(opp.Participant__c).National_Office__c) 
                        && localPartnerNationalOfficeMap.get(participantToNationalOfficeMap.get(opp.Participant__c).National_Office__c) != null
                        && localPartnerNationalOfficeMap.get(participantToNationalOfficeMap.get(opp.Participant__c).National_Office__c).Participant_Contact_Owner__c != null){
                        opp.ownerid = localPartnerNationalOfficeMap.get(participantToNationalOfficeMap.get(opp.Participant__c).National_Office__c).Participant_Contact_Owner__c;
                         //Logic to update transaction opportuntiy owner as per issue I-252203
                        if(transOppMap != null){
                            for(Opportunity transOpp : transOppMap.values()){
                                if(transOpp.rC_Giving__Parent__c == opp.Id){
                                    transOpp.OwnerId = opp.ownerid;
                                    transOpportunitiesList.add(transOpp);
                                }
                            }
                        }
                }
        }
        //Update transaction opportunity owner - Added as per issue I-252203
        if(transOpportunitiesList.size() > 0){
            update transOpportunitiesList;
        }
       
    }*/
    
    /**
     *  @Method : updateOpportunityOwner
     *  @Param : List<Opportunity>
     *  @description :  Method for updating the owner of Opportunity.
     *  @return : None
     */
    static void updateOpportunityOwner(List<Opportunity> oppList,Map <Id, Opportunity> oldMap, Map <Id, Opportunity> newMap){
        
        List<Opportunity> filteredOpportunitiesList = new List<Opportunity>();
        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Set<Id> participantIds = new Set<Id>();
        Set<Id> participantNewIds = new Set<Id>();
        Set<Id> localPartnerNationalOfficeIds = new Set<Id>();
        Set<Id> nationalOfficeIds = new Set<Id>();
        Map<Id,Contact> participantToLocalPartnerMap = new Map<Id,Contact>();
        Map<Id,Contact> participantToNationalOfficeMap = new Map<Id,Contact>();
        Map<Id, Account> localPartnerNationalOfficeMap = new Map<Id, Account>();
        Map<Id, Account> nationalOfficeMapNew = new Map<Id, Account>();
        Map<Id,Contact> participantToNationalOfficeMapNew = new Map<Id,Contact>();
        Map<Id, Opportunity> transOppMap = new Map<Id, Opportunity>();
        List<Opportunity> transOpportunitiesList = new List<Opportunity>();
        //cumulative List of Participants
        Set<Id> cumulativeParticipantIds = new Set<Id>();
        List<Contact> ParticipantListForOwnerUpdate = new List<Contact>();
        List<Contact> ParticipantListForGAUUpdate = new List<Contact>();
        set <id> transOppParentIds = new set <id> ();
        // Filtering the Opportunity records during insertion OR updation 
        
        for(Opportunity opp : oppList){
            if(oldMap == null && opp.RecordTypeId == RT_DONATION && (opp.rC_Sponsorship__Sponsorship_Status__c == 'Active' || opp.Product_Type__c == 'Designated Fund')//I-260691 - updated for Designated Fund
                && opp.Participant__c != null){
                filteredOpportunitiesList.add(opp);
                participantIds.add(opp.Participant__c);
                transOppParentIds.add(opp.Id);                
            }

            else if(oldMap != null && newMap != null && opp.RecordTypeId == RT_DONATION
                    && (opp.rC_Sponsorship__Sponsorship_Status__c == 'Active' || opp.Product_Type__c == 'Designated Fund') && opp.Participant__c != null){
                filteredOpportunitiesList.add(opp);
                participantIds.add(opp.Participant__c);
                transOppParentIds.add(opp.Id);
            }
            
            //Added by Ashu Gupta for T-525408--Start
            if(OldMap == null && opp.rC_Sponsorship__Sponsorship_Status__c == 'Active'){
                    opportunitiesList.add(opp);
                    //system.debug('Inside @@@');
                        participantNewIds.add(opp.Participant__c);
       
            }
            else if(OldMap != null && newMap != null && newMap.get(opp.Id).rC_Sponsorship__Sponsorship_Status__c != oldMap.get(opp.Id).rC_Sponsorship__Sponsorship_Status__c && newMap.get(opp.Id).rC_Sponsorship__Sponsorship_Status__c == 'Active'){
                    opportunitiesList.add(opp);
                    //system.debug('Inside Update case @@@');
                    participantNewIds.add(opp.Participant__c);
            }
            //Added by Ashu Gupta for T-525408--End
        }
        
        //Added as per issue I-252203
        if(transOppParentIds.size() > 0){
                transOppMap = new Map<Id, Opportunity>([SELECT Id, OwnerId, rC_Giving__Parent__c FROM Opportunity
                                                            WHERE rC_Giving__Parent__c !=  null AND rC_Giving__Parent__c IN : transOppParentIds 
                                                            AND RecordTypeId = :RT_TRANSACTION
                                                            AND id not in :transOppParentIds ]);
        }

        cumulativeParticipantIds.addAll(participantIds);// Participants set filetered for owner update
        cumulativeParticipantIds.addAll(participantNewIds);// Participants set filetered for GAU update
        if(cumulativeParticipantIds.size() > 0){
            List<Contact> cumulativeParticipantLst =[SELECT Id, Local_Partner__c, National_Office__c 
                                                     FROM Contact WHERE id IN :cumulativeParticipantIds
                                                    ];
                                                    
            for(Contact con:cumulativeParticipantLst){
                if(participantNewIds.size() > 0 && participantNewIds.contains(con.Id)){
                    ParticipantListForGAUUpdate.add(con);// Participants List filetered for GAU update
                }
                if(participantIds.size() > 0 && participantIds.contains(con.id)){
                    ParticipantListForOwnerUpdate.add(con);// Participants List filetered for GAU update
                }
            }                                        
        }
        else
            return;
        
        //Added by Ashu Gupta for T-525408--Start
        if(participantNewIds.size() > 0){
            for(Contact con : ParticipantListForGAUUpdate){
                    if(con.National_Office__c != null){
                    //nationalOfficeIds.add(con.National_Office__c);
                    localPartnerNationalOfficeIds.add(con.National_Office__c);
                    participantToNationalOfficeMapNew.put(con.id, con);
                }
            }
        }
        
        if(participantIds.size() > 0){
            for(Contact con : ParticipantListForOwnerUpdate){
                ////system.debug('Participants => '+participantList+ 'Local Partner => '+con.Local_Partner__c+ '; National Office => '+con.National_Office__c);
                if(con.Local_Partner__c != null){
                    localPartnerNationalOfficeIds.add(con.Local_Partner__c);
                    participantToLocalPartnerMap.put(con.id, con);
                }
                if(con.National_Office__c != null){
                    localPartnerNationalOfficeIds.add(con.National_Office__c);
                    participantToNationalOfficeMap.put(con.id, con);
                }
            }
        }

        if(localPartnerNationalOfficeIds.size() > 0){
            localPartnerNationalOfficeMap = new Map<Id, Account>([SELECT Id, Reciprocal_GAU__c,Participant_Contact_Owner__c FROM Account WHERE id IN :localPartnerNationalOfficeIds]);
        }  
        
        // Updating the GAU field on opportunity based on business logic  
        for(Opportunity opp : opportunitiesList){
            if(participantToNationalOfficeMapNew.containsKey(opp.Participant__c) && participantToNationalOfficeMapNew.get(opp.Participant__c) != null 
                        && localPartnerNationalOfficeMap.containsKey(participantToNationalOfficeMapNew.get(opp.Participant__c).National_Office__c) 
                        && localPartnerNationalOfficeMap.get(participantToNationalOfficeMapNew.get(opp.Participant__c).National_Office__c) != null
                        && localPartnerNationalOfficeMap.get(participantToNationalOfficeMapNew.get(opp.Participant__c).National_Office__c).Reciprocal_GAU__c != null){
                //system.debug('@@@ inside further');
                //update gau with the Reciprocal_GAU__c of the Participant's National Office 
                opp.rC_Giving__GAU__c = localPartnerNationalOfficeMap.get(participantToNationalOfficeMapNew.get(opp.Participant__c).National_Office__c).Reciprocal_GAU__c;
            }
        }  

        // Update Opportunity Owner based on business logic
        for (Opportunity opp: filteredOpportunitiesList){
                if(participantToLocalPartnerMap.containsKey(opp.Participant__c) && participantToLocalPartnerMap.get(opp.Participant__c) != null 
                   && localPartnerNationalOfficeMap.containsKey(participantToLocalPartnerMap.get(opp.Participant__c).Local_Partner__c) 
                   && localPartnerNationalOfficeMap.get(participantToLocalPartnerMap.get(opp.Participant__c).Local_Partner__c) != null
                   && localPartnerNationalOfficeMap.get(participantToLocalPartnerMap.get(opp.Participant__c).Local_Partner__c).Participant_Contact_Owner__c != null){
                    opp.ownerid = localPartnerNationalOfficeMap.get(participantToLocalPartnerMap.get(opp.Participant__c).Local_Partner__c).Participant_Contact_Owner__c;
                    //Logic to update transaction opportuntiy owner as per issue I-252203
                    if(transOppMap != null){
                        for(Opportunity transOpp : transOppMap.values()){
                            if(transOpp.rC_Giving__Parent__c == opp.Id){
                                transOpp.OwnerId = opp.ownerid;
                                transOpportunitiesList.add(transOpp);
                            }
                        }
                    }
                }
                else if(participantToNationalOfficeMap.containsKey(opp.Participant__c) && participantToNationalOfficeMap.get(opp.Participant__c) != null 
                        && localPartnerNationalOfficeMap.containsKey(participantToNationalOfficeMap.get(opp.Participant__c).National_Office__c) 
                        && localPartnerNationalOfficeMap.get(participantToNationalOfficeMap.get(opp.Participant__c).National_Office__c) != null
                        && localPartnerNationalOfficeMap.get(participantToNationalOfficeMap.get(opp.Participant__c).National_Office__c).Participant_Contact_Owner__c != null){
                        opp.ownerid = localPartnerNationalOfficeMap.get(participantToNationalOfficeMap.get(opp.Participant__c).National_Office__c).Participant_Contact_Owner__c;
                         //Logic to update transaction opportuntiy owner as per issue I-252203
                        if(transOppMap != null){
                            for(Opportunity transOpp : transOppMap.values()){
                                if(transOpp.rC_Giving__Parent__c == opp.Id){
                                    transOpp.OwnerId = opp.ownerid;
                                    transOpportunitiesList.add(transOpp);
                                }
                            }
                        }
                }
        }
        //Update transaction opportunity owner - Added as per issue I-252203
        if(transOpportunitiesList.size() > 0){
            update transOpportunitiesList;
        }
       
    }
    //Added by Ravi Chauhan on 24/Jun/2016 for T-514023.  <<END>>
    
    //Added by Rohit B on Aug 04, 2016 for T-523973.            --START--
    /**
     *  @Method : markOpportunityForClawBack
     *  @Param : List<Opportunity>
     *  @description :  to mark opportunity claw back if certain condition meets.
     *  @return : None
     */
    static void markOpportunityForClawBack(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        Set<Opportunity> setOppToUpdate = new Set<Opportunity>();
        //system.debug('[OpportunityService.markOpportunityForClawBack :: Method Start..');
        for(Opportunity opp : [SELECT Id, Vendor_Name__c, RecordTypeId, rC_Sponsorship__Sponsorship_Status__c, Start_Date__c, 
                             Product_Type__c, Parent_Product_Type__c, Identified_for_Clawback__c, StageName, AGP_Method__c, 
                             Cancelled_Date__c, Date_Presponsorship_Started__c, rC_Giving__Parent__c, rC_Giving__Parent__r.Vendor_Name__c,
                             rC_Giving__Parent__r.Date_Presponsorship_Started__c, rC_Giving__Parent__r.Identified_for_Clawback__c, 
                             rC_Giving__Parent__r.Start_Date__c 
                             FROM Opportunity WHERE Id in :oppList
                             AND (Vendor_Name__c != null OR rC_Giving__Parent__r.Vendor_Name__c != null)]) {  //I-253808 | Put the vendor check in Query
                          
            Boolean selfFirstCondition = ( oldMap != null && !String.isBlank(opp.Vendor_Name__c) && opp.RecordTypeId == RT_DONATION && opp.Product_Type__c == 'Sponsorship' && 
                                    (opp.rC_Sponsorship__Sponsorship_Status__c != null && opp.rC_Sponsorship__Sponsorship_Status__c.containsIgnoreCase('Closed')) && 
                                    (opp.Date_Presponsorship_Started__c != null && opp.Date_Presponsorship_Started__c.daysBetween(System.today()) < 140)  && 
                                    opp.Identified_for_Clawback__c == false);
////system.debug('###'+oldmap+'  opp' + opp);
            Boolean selfSecondCondition = (oldMap != null && !String.isBlank(opp.Vendor_Name__c) && opp.RecordTypeId == RT_DONATION && opp.Product_Type__c == 'Recurring Gift' && 
                                    (opp.Cancelled_Date__c != null || opp.StageName == 'Partially Collected') && 
                                    (opp.Start_Date__c != null && opp.Start_Date__c.daysBetween(System.today()) < 140)  && 
                                    opp.Identified_for_Clawback__c == false);
                     
            Boolean selfThirdCondition = (oldMap != null && !String.isBlank(opp.Vendor_Name__c) && opp.RecordTypeId == RT_DONATION && opp.Product_Type__c == 'Sponsorship' && 
                                    oldMap.get(opp.Id).AGP_Method__c == true && opp.AGP_Method__c == false && 
                                    (opp.Date_Presponsorship_Started__c != null && opp.Date_Presponsorship_Started__c.daysBetween(System.today()) < 140) && 
                                    opp.Identified_for_Clawback__c == false);
                     
            Boolean selfForthCondition = (oldMap != null && !String.isBlank(opp.Vendor_Name__c) && opp.RecordTypeId == RT_DONATION && opp.Product_Type__c == 'Recurring Gift' && 
                                    oldMap.get(opp.Id).AGP_Method__c == true && opp.AGP_Method__c == false && 
                                    (opp.Start_Date__c != null && opp.Start_Date__c.daysBetween(System.today()) < 140) && 
                                    opp.Identified_for_Clawback__c == false);
                       
            if (selfFirstCondition || selfSecondCondition || selfThirdCondition || selfForthCondition) {
                //system.debug('Inside clawback @@@ 4 conditions');
                //System.assert(false,'test');
                opp.Identified_for_Clawback__c = true;
                opp.Identified_for_Clawback_Date__c = DateTime.now();// MR I-239154 Identified for Clawback Date not populated when Identified for Clawback? is set to True
                //lstOppToUpdate.add(opp);

                setOppToUpdate.add(opp);
            }

            Boolean parentFirstCondition = (oldMap != null && opp.RecordTypeId == RT_TRANSACTION && opp.StageName != 'Completed' && 
                                            opp.StageName != 'Open' && opp.StageName != 'Pending' && opp.Parent_Product_Type__c == 'Sponsorship' && 
                                            (opp.rC_Giving__Parent__c != null &&  !String.isBlank(opp.rC_Giving__Parent__r.Vendor_Name__c ) && opp.rC_Giving__Parent__r.Date_Presponsorship_Started__c != null && 
                                            opp.rC_Giving__Parent__r.Date_Presponsorship_Started__c.daysBetween(System.today()) < 140 && 
                                            opp.rC_Giving__Parent__r.Identified_for_Clawback__c == false));
                               
            Boolean parentSecondCondition = (oldMap != null && opp.RecordTypeId == RT_TRANSACTION && opp.StageName != 'Completed' && 
                                            opp.StageName != 'Open' && opp.StageName != 'Pending' && opp.Parent_Product_Type__c == 'Recurring Gift' && 
                                            (opp.rC_Giving__Parent__c != null &&  !String.isBlank(opp.rC_Giving__Parent__r.Vendor_Name__c) && opp.rC_Giving__Parent__r.Start_Date__c != null && 
                                            opp.rC_Giving__Parent__r.Start_Date__c.daysBetween(System.today()) < 140 && 
                                            opp.rC_Giving__Parent__r.Identified_for_Clawback__c == false));
                              
            if (parentFirstCondition || parentSecondCondition) {
                Opportunity parentOpp = new Opportunity(Id=opp.rC_Giving__Parent__c);
                //system.debug('Inside clawback @@@ 2 conditions');
                parentOpp.Identified_for_Clawback__c = true;
                parentOpp.Identified_for_Clawback_Date__c = DateTime.now();//MR I-239154 Identified for Clawback Date not populated when Identified for Clawback? is set to True
                //lstOppToUpdate.add(opp);
                //setOppToUpdate.add(opp);
                setOppToUpdate.add(parentOpp); // I-235203 | Changes | Added ParentOpp in the list rather than opp
            }

        }

        if(setOppToUpdate.size()>0) {
            lstOppToUpdate.addAll(setOppToUpdate);
            update lstOppToUpdate;
        } 

        //system.debug('[OpportunityService.markOpportunityForClawBack :: Method End..');
    }
    //Added by Rohit B on Aug 04, 2016 for T-523973.            --END--


//Added by Ashu Gupta on Sep 05, 2016 for T-T-514023.            --START--
    /**
     *  @Method : updateOpportunityOwnerId
     *  @Param : List<Opportunity>
     *  @description : To update the Owner of Opportunity depending on the participants related fields.
     *  @return : None
     */

   /* static void updateOpportunityOwnerId(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){
        
        List<Id> opportunityList = new List<Id>();
        Map<Id, Id> OppToOwnerMap = new Map<Id, Id>();
        
        List<Opportunity> opportunities = [select Id, Participant__c, Participant__r.Local_Partner__c, Participant__r.National_Office__c, 
        Participant__r.National_Office__r.Participant_Contact_Owner__c,
        Participant__r.Local_Partner__r.Participant_Contact_Owner__c,recordTypeId,rC_Sponsorship__Sponsorship_Status__c
        FROM Opportunity WHERE Id in :oppList];
        
        //Traversing and checking if the opportunity owner exists or not
        for(Opportunity op : opportunities){
            if(oldMap != null && op.recordTypeId == RT_DONATION && op.rC_Sponsorship__Sponsorship_Status__c == 'Active'){
                if(op.Participant__c != null && op.Participant__r.Local_Partner__c!=null && op.Participant__r.Local_Partner__r.Participant_Contact_Owner__c != null){
                    opportunityList.add(op.id);
                    OppToOwnerMap.put(op.id, op.Participant__r.Local_Partner__r.Participant_Contact_Owner__c);
                } else if(op.Participant__c != null && op.Participant__r.National_Office__c != null && op.Participant__r.National_Office__r.Participant_Contact_Owner__c != null){
                    opportunityList.add(op.id);
                    OppToOwnerMap.put(op.id, op.Participant__r.National_Office__r.Participant_Contact_Owner__c);
                }
            }
        }
        
        // Checking if the Elligible Opportunity List is empty or not
        if(opportunityList.size()>0){
            List<Opportunity> opporList = [Select Id , OwnerId from Opportunity where Id in :opportunityList];
            for(Opportunity opp : opporList){
                if(OppToOwnerMap.containsKey(opp.Id)!=null){
                    opp.OwnerId = OppToOwnerMap.get(opp.Id);
                }
            }
            
            update opporList;
        }
        
    }*/
    
    // I-239475 | Ravi Chauhan | Replacing the Process builder (Update_Hard_Credit_Contact_on_Transaction) logic with trigger | Changes > Start
    /**
     *  @Method      : updateHardCreditContactOnTransaction
     *  
     *  @description :  To update the Payment_Hard_Credit_Contact__c field with rC_Giving__Hard_Credit_Contact__c fields value
     *                  This functionility has been moved from the Update_Hard_Credit_Contact_on_Transaction process to trigger
     * 
     *  @Reference   : I-239475
     *  @CreatedDate : 12/10/2016
     *  @CreatedBy   : Ravi Chauhan
     *  @Param       : List<Opportunity>
     *  @return      : None
     */
    static void updateHardCreditContactOnTransaction(List<Opportunity> oppList){

        for(Opportunity opp : oppList){
            if((opp.RecordTypeID == RT_TRANSACTION || opp.RecordTypeID == RT_PLEDGE_PAYMENT) && opp.StageName == 'Completed' && opp.rC_Giving__Hard_Credit_Contact__c != null)
                opp.Payment_Hard_Credit_Contact__c = opp.rC_Giving__Hard_Credit_Contact__c;
        }
        
    }
    // I-239475 | Ravi Chauhan | Replacing the Process builder logic with trigger | Changes > End
    
    // I-258680 | Ravi Chauhan | Setting the No Field Correspondance flag in the replacement opportunity created on Child departure | Changes > Start
    
    /**
     *  @Method      : setNoFiedCorrespondanceFlag
     *  
     *  @description :  To set All_Child_Correspondence__c flag to True when a new sponsorship opportunity is created when
     *                  child is departed or participant is changed
     * 
     *  @Reference   : I-258680
     *  @CreatedDate : 02/16/2017
     *  @CreatedBy   : Ravi Chauhan
     *  @Param       : List<Opportunity>
     *  @return      : None
     */
    static void setNoFiedCorrespondanceFlag(List<Opportunity> oppList){
        for(Opportunity opp : oppList){
            if(opp.RecordTypeID == RT_DONATION && opp.Sponsorship_Change_Reason_Detail__c != null && opp.rC_Sponsorship__Sponsorship_Status_Reason__c == null 
                && (opp.Sponsorship_Change_Reason_Detail__c.startsWith('Child Departure -') || opp.Sponsorship_Status_Reason_Copy__c == 'Participant Change')){
                opp.All_Child_Correspondence__c = true;
            }
        }
    }
    
    /**
     *  @Method      : formatDate
     *  
     *  @description :  To change the format of Date in MM-dd-yy format
     * 
     *  @Reference   : I-262538
     *  @CreatedDate : 03/31/2017
     *  @CreatedBy   : Ravi Chauhan
     *  @Param       : Date
     *  @return      : String
     */
    static private String formatDate(Date dateToBeFormatted){
       String formattedDate = '';    
       if(dateToBeFormatted != null){
           Datetime dt = Datetime.newInstance(dateToBeFormatted.year(),dateToBeFormatted.month(),dateToBeFormatted.day());
            if(dt != null)
                formattedDate = dt.format('MM-dd-yy');
       }
       
       return formattedDate;
    }

    // I-258680 | Ravi Chauhan | Setting the No Field Correspondance flag in the replacement opportunity created on Child departure | Changes > End
}