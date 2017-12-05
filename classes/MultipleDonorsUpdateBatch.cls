/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MultipleDonorsUpdateBatch
 * Created By   : Vaibhav Goel (Appirio)
 * Purpose      : This batch is used to update multiple donors at a time.
 * Created Date : 02/25/2016
 *
 * Date Modified                Modified By             Description of the update
 * ----------------------------------------------------------------------------------------------------------
 *
 **********************************************************************************************************/
global class MultipleDonorsUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    public String query;
    public String objectType;
    public Contact conObj;
    public Opportunity oppObj;
    public rC_Bios__Preference__c prefObj;

    // Constructor to initialize the instance variables
    global MultipleDonorsUpdateBatch(String objectType, String query, Opportunity oppObj, rC_Bios__Preference__c prefObj, Contact conObj) {
        this.objectType = objectType;
        this.query = query;
        this.oppObj = oppObj;
        this.prefObj = prefObj;
        this.conObj = conObj;
    }
    
    // To fetch the Donor records based on the criteria selected by user
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    // The function adds new prefernce records on the Opportunity as well as updates the existing preferences.
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Contact> conList = new List<Contact>();
        Set<Contact> conSet = new Set<Contact>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<rC_Bios__Preference__c> newPrefListForInsert = new List<rC_Bios__Preference__c>();
        List<rC_Bios__Preference__c> oldPrefListForUpdate = new List<rC_Bios__Preference__c>();
        Map<Id, Contact> conMapToUpdate = new Map<Id, Contact>();
            
        if(objectType == 'Opportunity'){
            for(sObject s : scope){
                Opportunity opp = (Opportunity)s;
                set<String> createdPreferences = new set<String>();
                if(this.oppObj.CFI_Do_Not_Substitute__c != null){
                    opp.CFI_Do_Not_Substitute__c = this.oppObj.CFI_Do_Not_Substitute__c;    
                }
                if(this.oppObj.Do_Not_Sub_Reason__c != null){
                    opp.Do_Not_Sub_Reason__c = this.oppObj.Do_Not_Sub_Reason__c;    
                }
                if(this.oppObj.All_Child_Correspondence__c != null){
                    opp.All_Child_Correspondence__c = this.oppObj.All_Child_Correspondence__c;    
                }
                
                oppList.add(opp);
                
                Contact c = new Contact(Id= opp.rC_Giving__Hard_Credit_Contact__r.Id);
                if(this.conObj.Standard_Pay_Opt_Out__c != null){
                    c.Standard_Pay_Opt_Out__c = this.conObj.Standard_Pay_Opt_Out__c;    
                }
                if(this.conObj.MailingStreet != null){
                    c.MailingStreet = this.conObj.MailingStreet;    
                }
                if(this.conObj.MailingCity != null){
                    c.MailingCity = this.conObj.MailingCity;    
                }
                if(this.conObj.MailingState != null){
                    c.MailingState = this.conObj.MailingState;    
                }
                if(this.conObj.MailingPostalCode != null){
                    c.MailingPostalCode = this.conObj.MailingPostalCode;    
                }
                conMapToUpdate.put(c.id, c);
                //conSet.add(c);
                
                for(rC_Bios__Preference__c pObj : opp.rC_Sponsorship__Preferences__r){
                    createdPreferences.add(pObj.rC_Bios__Type__c);
                    system.debug('----createdPreferences---' + createdPreferences);
                    if(pObj.rC_Bios__Type__c == 'National Office' && this.prefObj.National_Office__c != null){
                        pObj.National_Office__c = this.prefObj.National_Office__c;
                        pObj.rC_Bios__Subtype__c = String.ValueOf(this.prefObj.National_Office__c);
                        oldPrefListForUpdate.add(pObj);
                    }else if(pObj.rC_Bios__Type__c == 'Local Partner' && this.prefObj.Local_Partner__c != null){
                        pObj.Local_Partner__c = this.prefObj.Local_Partner__c;
                        pObj.rC_Bios__Subtype__c = String.ValueOf(this.prefObj.Local_Partner__c);
                        oldPrefListForUpdate.add(pObj);
                    }else if(pObj.rC_Bios__Type__c == 'Community' && this.prefObj.Community__c != null){
                        pObj.Community__c = this.prefObj.Community__c;
                        pObj.rC_Bios__Subtype__c = String.ValueOf(this.prefObj.Community__c);
                        oldPrefListForUpdate.add(pObj);
                    }
                }
                
                if(!createdPreferences.contains('National Office') && this.prefObj.National_Office__c != null){
                    system.debug('----createdPreferences---' + createdPreferences);    
                    rC_Bios__Preference__c tempPrefObj = new rC_Bios__Preference__c();
                    
                    tempPrefObj.rC_Sponsorship__Opportunity__c = opp.Id;
                    tempPrefObj.rC_Bios__Category__c = 'Sponsorship';
                    tempPrefObj.rC_Bios__Subcategory__c = 'Contact Search';
                    tempPrefObj.rC_Bios__Active__c = true;
                    tempPrefObj.rC_Bios__Type__c = 'National Office';
                    tempPrefObj.Auto_Assign_Preference__c = true;
                    tempPrefObj.National_Office__c = this.prefObj.National_Office__c;
                    tempPrefObj.rC_Bios__Subtype__c = this.prefObj.National_Office__c;
                    newPrefListForInsert.add(tempPrefObj);
                }
                if(!createdPreferences.contains('Local Partner') && this.prefObj.Local_Partner__c != null){
                        
                    rC_Bios__Preference__c tempPrefObj = new rC_Bios__Preference__c();
                    
                    tempPrefObj.rC_Sponsorship__Opportunity__c = opp.Id;
                    tempPrefObj.rC_Bios__Category__c = 'Sponsorship';
                    tempPrefObj.rC_Bios__Subcategory__c = 'Contact Search';
                    tempPrefObj.rC_Bios__Active__c = true;
                    tempPrefObj.rC_Bios__Type__c = 'Local Partner';
                    tempPrefObj.Auto_Assign_Preference__c = true;
                    tempPrefObj.Local_Partner__c = this.prefObj.Local_Partner__c;
                    tempPrefObj.rC_Bios__Subtype__c = this.prefObj.Local_Partner__c;
                    newPrefListForInsert.add(tempPrefObj);
                }
                if(!createdPreferences.contains('Community') && this.prefObj.Community__c != null){
                        
                    rC_Bios__Preference__c tempPrefObj = new rC_Bios__Preference__c();
                    
                    tempPrefObj.rC_Sponsorship__Opportunity__c = opp.Id;
                    tempPrefObj.rC_Bios__Category__c = 'Sponsorship';
                    tempPrefObj.rC_Bios__Subcategory__c = 'Contact Search';
                    tempPrefObj.rC_Bios__Active__c = true;
                    tempPrefObj.rC_Bios__Type__c = 'Community';
                    tempPrefObj.Auto_Assign_Preference__c = true;
                    tempPrefObj.Community__c = this.prefObj.Community__c;
                    tempPrefObj.rC_Bios__Subtype__c = this.prefObj.Community__c;
                    newPrefListForInsert.add(tempPrefObj);
                }
                                
            } 
        } 
        if(conMapToUpdate != null && conMapToUpdate.size() > 0){
            system.debug('----conMapToUpdate---' + conMapToUpdate.size()  + '----'  + conMapToUpdate);
            Database.SaveResult[] conUpdateSR = Database.update(conMapToUpdate.Values(), false);
        }
        if(oppList != null && oppList.size() > 0){
            Database.SaveResult[] oppUpdateSR = Database.update(oppList, false);
        }
        if(oldPrefListForUpdate != null && oldPrefListForUpdate.size() > 0){
            system.debug('-----oldPrefListForUpdate---' + oldPrefListForUpdate);
            //update oldPrefListForUpdate;
            Database.SaveResult[] prefUpdateSR = Database.update(oldPrefListForUpdate, false);
        }
        if(newPrefListForInsert != null && newPrefListForInsert.size() > 0){
            //insert newPrefListForInsert;
            Database.SaveResult[] prefInsertSR = Database.insert(newPrefListForInsert, false);
            
        }
    }
        
    global void finish(Database.BatchableContext BC){
        
    }
}