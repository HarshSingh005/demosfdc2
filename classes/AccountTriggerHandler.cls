/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountTriggerHandler
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Handler class of Account Trigger
 * Created Date : 12/Dec/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 4/July/2016                  Ravi Chauhan           T-514023 - Update the Account (Community) Owner
 * 05/Sep/2016                  Ashu Gupta             Modified updateAccountOwner() for T-514023
 * 06/Sep/2016                  Ravi Chauhan           Modified updateAccountOwner() for T-514023
 * 03/Mar/2017                  Simranjeet Singh       Modified updateAccountOwner() for T-581342
 **********************************************************************************************************/

public with sharing class AccountTriggerHandler {
    
    Final Static String accountCommunityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static String accountNationalOfficeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static String accountLocalPartnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();

    private boolean isExecuting = false;
    private integer batchSize = 0;
    
    public AccountTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    } // END public AccountTriggerHandler(
    
    public void OnBeforeInsert(List<Account> newAccounts){
        updateAccountOwner(newAccounts,null);
    }
    
    public void OnAfterInsert(List<Account> newAccounts){

    } // END public void OnAfterInsert
    
    // Method name : OnBeforeUpdate
    // Description : Check if the hold status field of the account has been updated to blank. If yes, then blank out the value
    //                  stored in the field Hold_Reason__c
    //
    // @param      : Account[] oldAccounts, Account[] newAccounts, Map<ID, Account> accountNewMap, Map<ID, Account> accountOldMap
    // @return     : Void
    // Modified By : vaibhav Goel 
    // Date        : Jan 14,2015
    // Reference   : Issue I-198360 ( updates suggested by Karl in field Solution of the mentioned issue)
    public void OnBeforeUpdate(Account[] oldAccounts, Account[] newAccounts, 
                                Map<ID, Account> accountNewMap, Map<ID, Account> accountOldMap){
        system.debug('---In BeforeUpdate--');
        for(Account acc : newAccounts) {
            system.debug('---acc.Hold_Reason__c--' + acc.Hold_Reason__c);
            if(accountOldMap.get(acc.Id).Hold_Status__c != acc.Hold_Status__c && acc.Hold_Status__c != 'Hold Assign' && acc.Hold_Status__c != 'Hold All Activity') {
                acc.Hold_Reason__c = '';
            }
        }
        //Added by Ravi Chauhan on 24/Jun/2016 for T-514023.  <<START>>
        updateAccountOwner(newAccounts,accountOldMap);
        //Added by Ravi Chauhan on 24/Jun/2016 for T-514023.  <<END>>
        
    } // END public void OnBeforeUpdate

    public void OnAfterUpdate(Account[] oldAccounts, Account[] newAccounts, 
                                Map<ID, Account> accountNewMap, Map<ID, Account> accountOldMap){
        Map<Id, Account> accMap = new Map<Id, Account>();
        for(Account acc : newAccounts) {
            System.debug('accountOldMap.get(acc.Id).Hold_Status__c =>' + accountOldMap.get(acc.Id).Hold_Status__c);
            System.debug('acc.Hold_Status__c =>' + acc.Hold_Status__c);
            if(accountOldMap.get(acc.Id).Hold_Status__c != acc.Hold_Status__c) {
                accMap.put(acc.Id, acc);
            }
        } // END for(Account acc : newAccounts) {
        
        if(!accMap.isEmpty()) {
            cascadeUpdateSponsorshipStatus(accMap);
        }
    } // END public void OnAfterUpdate(Account[] oldAccounts, Account[] newAccounts, 

    public void OnBeforeDelete(Account[] oldAccounts){
        List<Contact> lstContactToUpdate = new List<Contact>();
        for(Contact con : [SELECT Id, Local_Partner__c, Community__c FROM Contact WHERE Local_Partner__c in: oldAccounts 
                            OR Community__c in: oldAccounts]) {
            Contact new_con = new Contact();
            new_con.Id = con.Id;
            lstContactToUpdate.add(new_con);
        }
        if(lstContactToUpdate.size() > 0 )
            update lstContactToUpdate;
    } // END public void OnBeforeDelete

    /*
        @param accMap Map of accounts
        Update Local Partner, community and theirs contacts status based on Hold Status changged
    */
    private void cascadeUpdateSponsorshipStatus(Map<ID, Account> accMap) {
        System.debug('[RB] - AccountTriggerHandler.cascadeupdateSponsorshipStatus :: Method Start..');
        Set<Id> accLP = new Set<Id>();
        Set<Id> accAll = new Set<Id>();
        Set<String> sStatusVal = new Set<String> {'Enrolled', 'Available', 'Unavailable', 'On Hold'};
        List<sObject> sObjToUpdate = new List<sObject>();

        String accLPRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        String accCommunityRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        String conParticipantRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();

        for(Account acc : accMap.values()) {
            if(acc.RecordTypeId == accLPRTId || acc.RecordTypeId == accCommunityRTId){
                accAll.add(acc.Id);
                if(acc.RecordTypeId == accLPRTId) {
                    accLP.add(acc.Id);
                } // END if(acc.RecordTypeId = accLPRTId) {
            } // END if(acc.RecordTypeId = accLPRTId || acc.RecordTypeId = accCommunityRTId){
        } // END for(Account acc : newAccounts) {

        System.debug('[RB] - AccountTriggerHandler.cascadeupdateSponsorshipStatus :: accLP = ' + accLP);
        System.debug('[RB] - AccountTriggerHandler.cascadeupdateSponsorshipStatus :: accAll = ' + accAll);

        for(Account acc : [SELECT Id, Name, Hold_Status__c, ParentId FROM Account 
                            WHERE ParentId in: accLP]) {
            acc.Hold_Status__c = accMap.get(acc.ParentId).Hold_Status__c;
            acc.Hold_Reason__c = accMap.get(acc.ParentId).Hold_Reason__c; //Vaibhav Goel : Issue I-198360 ( updates suggested by Karl in field Solution of the mentioned issue)
            sObjToUpdate.add(acc);
        } // END for(Account acc : [SELECT Id, Name, Hold_Status__c, RecordType.Name FROM Account

        for(Contact con : [SELECT Id, RecordTypeId, Local_Partner__c, Community__c, rC_Sponsorship__Sponsorship_Status__c 
                            FROM Contact WHERE (Local_Partner__c in: accAll OR Community__c in: accAll) AND 
                            RecordTypeId =: conParticipantRTId AND ((rC_Sponsorship__Sponsorship_Status__c in :sStatusVal) OR (rC_Sponsorship__Sponsorship_Status__c = null))]) {
            //System.debug('[RB] - AccountTriggerHandler.cascadeupdateSponsorshipStatus :: con = ' + con);
            String accID = accMap.containsKey(con.Local_Partner__c) ? con.Local_Partner__c : con.Community__c;
            if(accMap.get(accID).Hold_Status__c != '' && accMap.get(accID).Hold_Status__c != Null) {
                con.rC_Sponsorship__Sponsorship_Status__c = 'On Hold';
            } else {
                con.rC_Sponsorship__Sponsorship_Status__c = 'Available';
            }
            sObjToUpdate.add(con);
        } // END for(Contact con : 
        System.debug('[RB] - AccountTriggerHandler.cascadeupdateSponsorshipStatus :: sObjToUpdate = ' + sObjToUpdate);

        if(!sObjToUpdate.isEmpty()) {
            update sObjToUpdate;
        }
        System.debug('[RB] - AccountTriggerHandler.cascadeupdateSponsorshipStatus :: Method End..');
    } // END void cascadeupdateSponsorshipStatus
    
    //Added by Ravi Chauhan on 24/Jun/2016 for T-514023.  <<START>>

    /**
     *  @Method      : updateAccountOwner
     *  @Param       : List<Account>
     *  @description : Method for updating the owner of Account.
     *  @return      : None
     */
    private void updateAccountOwner(List<Account> newAccounts,Map<Id,Account> accountOldMap){
        List<Account> filteredAccountList = new List<Account>();
        Set<Id> parentAccountIds = new Set<Id>();
        Map<Id, Account> accountParticipantContactMap = new Map<Id, Account>();
        Map<Id,Account> parentAccountMap = new Map<Id, Account>();
        
        List<Account> filteredLPAccountList = new List<Account>();
        Set<Id> setLpParentAccountIds = new Set<Id>();
        
        // Filtering the Account records during insertion OR updation 

        for(Account acc : newAccounts){
            if(acc.RecordTypeId == accountCommunityRecordTypeId){
                filteredAccountList.add(acc);
                if(accountOldMap == null){
                    if(acc.parentId != null)
                        parentAccountIds.add(acc.ParentId);
                }
                //Added by Ashu Gupta for T-514023--Start--   
                else{
                    if(acc.parentId != null && accountOldMap.get(acc.id).parentId != acc.parentId)
                        parentAccountIds.add(acc.ParentId);
                }
                 //Added by Ashu Gupta for T-514023--End--

            }else if(acc.RecordTypeId == accountNationalOfficeRecordTypeId){// Added by Simranjeet Singh to update owner for National Office Accounts- T-581342 - 03/03/2017
                if(accountOldMap == null){
                    if(acc.Participant_Contact_Owner__c != null)
                        acc.ownerid = acc.Participant_Contact_Owner__c;
                }else if(accountOldMap.get(acc.id).Participant_Contact_Owner__c != acc.Participant_Contact_Owner__c){ // If Participant Contact Owner is Changed.
                    if(acc.Participant_Contact_Owner__c != null)
                        acc.ownerid = acc.Participant_Contact_Owner__c;
                }
            }else if(acc.RecordTypeId == accountLocalPartnerRecordTypeId){
                if(accountOldMap == null){
                    if(acc.Participant_Contact_Owner__c != null)
                        acc.ownerid = acc.Participant_Contact_Owner__c;
                    else{
                        filteredLPAccountList.add(acc);
                        setLpParentAccountIds.add(acc.ParentId);
                    }
                }else if(accountOldMap.get(acc.id).Participant_Contact_Owner__c != acc.Participant_Contact_Owner__c){ // If Participant Contact Owner is Changed.
                    if(acc.Participant_Contact_Owner__c != null)
                        acc.ownerid = acc.Participant_Contact_Owner__c;
                    else{
                        filteredLPAccountList.add(acc);
                        setLpParentAccountIds.add(acc.ParentId);
                    }
                }
            }
        }
        //Changes end - by Simranjeet Singh to update owner for National Office Accounts- T-581342 - 03/03/2017
        
        if(parentAccountIds.size() > 0 || setLpParentAccountIds.size() > 0){//Condition updated Simranjeet Singh, T-581342 - 03/03/2017
            if(parentAccountIds.size() > 0){
                // Fetching the Parent Ids of the Parent of Inserted Account
                parentAccountMap = new Map<Id,Account>([SELECT Id, ParentId FROM Account WHERE id IN :parentAccountIds]);
                for(Account parentAccount : parentAccountMap.values()){
                    if(parentAccount.ParentId != null){
                        parentAccountIds.add(parentAccount.ParentId);
                    }
                }   
            }

            // Fetching the Participant_Contact_Owner__c of the Parent of Inserted Account
            accountParticipantContactMap = new Map<Id, Account>([SELECT Participant_Contact_Owner__c FROM Account WHERE id IN :parentAccountIds OR id in: setLpParentAccountIds]); // Query updated Simranjeet Singh, T-581342 - 03/03/2017
        }
        else
            return;
            
        if(filteredAccountList.size() > 0){// Condition added by Simranjeet Singh, T-581342 - 03/03/2017
            // Updation of Account Owner based on Business Logic
            for(Account acc : filteredAccountList){
                if(accountParticipantContactMap != null && accountParticipantContactMap.containsKey(acc.parentId) && 
                    accountParticipantContactMap.get(acc.parentId) != null && accountParticipantContactMap.get(acc.parentId).Participant_Contact_Owner__c != null){
                        acc.ownerid = accountParticipantContactMap.get(acc.parentId).Participant_Contact_Owner__c;
                }
                else if(accountParticipantContactMap != null && parentAccountMap.containsKey(acc.parentId) && 
                        parentAccountMap.get(acc.parentId).parentId != null && accountParticipantContactMap.containsKey(parentAccountMap.get(acc.parentId).parentId) && 
                        accountParticipantContactMap.get(parentAccountMap.get(acc.parentId).parentId) != null && 
                        accountParticipantContactMap.get(parentAccountMap.get(acc.parentId).parentId).Participant_Contact_Owner__c != null){
                        acc.ownerid = accountParticipantContactMap.get(parentAccountMap.get(acc.parentId).parentId).Participant_Contact_Owner__c;
                }
            }
        }else if(filteredLPAccountList.size() > 0){ // Condition and loop over LP Accounts added by Simranjeet Singh, T-581342 - 03/03/2017
            //Loop over LP account where Participant Contact Owner is Null and get Participant Contact Owner from Parent Account.
            for(Account acc : filteredLPAccountList){
                if(accountParticipantContactMap.containsKey(acc.ParentId) && accountParticipantContactMap.get(acc.parentId).Participant_Contact_Owner__c != null){
                    acc.OwnerId = accountParticipantContactMap.get(acc.parentId).Participant_Contact_Owner__c;
                }
            }
        }
        
    }

    //Added by Ravi Chauhan on 24/Jun/2016 for T-514023.  <<END>>
    
} // END public with sharing class AccountTriggerHandler {