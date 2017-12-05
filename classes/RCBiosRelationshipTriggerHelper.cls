// 
// (c) 2015 Appirio, Inc.
//
// Helper Class for the RCBiosRelationshipTrigger trigger.
//
// 23rd Dec 2015     Sumit Tanwar       Original Ref - T-460324
// 18/Jan/2016       Rohit B            Original Ref - T-466983 [Created a function create_Receiver_Giver_Relationship]
// 25th Feb 2015     Jagjeet Singh      I-202708 (Updated the Opportunity Name In populate Participant Method)
public without sharing class RCBiosRelationshipTriggerHelper{
    
    //  deactivate Opportunity Preferences and create new records 
    //  argument.
    //  @param scope List Of rC_Bios__Relationship__c
    
    public static void updatePreferences(List<rC_Bios__Relationship__c> scope){
        
        Set<Id> opps = new Set<Id>();
        List<rC_Bios__Preference__c> listPrefs = new List<rC_Bios__Preference__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Id SponsorshipRecTypeId = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();
        for(rC_Bios__Relationship__c rcb :[SELECT Id, 
                                                  rC_Bios__Opportunity__c,
                                                  rC_Bios__Opportunity__r.Auto_Assign_Preference__c,
                                                  rC_Bios__Opportunity__r.rC_Giving__Primary_Contact__c,
                                                  rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__c,
                                                  rC_Bios__Opportunity__r.Participant__c,
                                                  rC_Bios__Contact_2__c,
                                                  rC_Bios__Contact_2__r.Community__c,
                                                  rC_Bios__Contact_2__r.Local_Partner__c,
                                                  rC_Bios__Contact_2__r.National_Office__c,
                                                  rC_Bios__Contact_2__r.Community__r.Name,
                                                  rC_Bios__Contact_2__r.Local_Partner__r.Name,
                                                  rC_Bios__Contact_2__r.National_Office__r.Name
                                                  FROM rC_Bios__Relationship__c
                                                  WHERE Id IN: scope
                                                  AND rC_Bios__Opportunity__c != null 
                                                  AND rC_Bios__Category__c = 'Sponsorship'
                                                  AND rC_Bios__Role_1__c = 'Participant'
                                                  AND rC_Bios__Role_2__c = 'Sponsorship Giving'
                                                  AND rC_Bios__Opportunity__r.Auto_Assign_Preference__c = true]){
            rC_Bios__Preference__c rec1 = new rC_Bios__Preference__c();
            rec1.RecordTypeId = SponsorshipRecTypeId;
            rec1.rC_Sponsorship__Opportunity__c = rcb.rC_Bios__Opportunity__c;
            rec1.rC_Bios__Category__c = 'Sponsorship';
            rec1.rC_Bios__Subcategory__c = 'Contact Search';
            rec1.rC_Bios__Type__c = 'National Office';
            //rec1.rC_Bios__Subtype__c= rcb.rC_Bios__Contact_2__r.National_Office__r.Name;//I-242967 | Commented this code as per the issue
            rec1.rC_Bios__Subtype__c= rcb.rC_Bios__Contact_2__r.National_Office__c; 
            rec1.National_Office__c = rcb.rC_Bios__Contact_2__r.National_Office__c;
            rec1.rC_Bios__Active__c = true;
            rec1.Created_from_Sponsorship__c = true;
            
            listPrefs.add(rec1);
            //listPrefs.add(rec2);
            //listPrefs.add(rec3);                                                        
            opps.add(rcb.rC_Bios__Opportunity__c);
        } // END for(rC_Bios__Relationship__c rcb :[SELECT Id,
        
        for(rC_Bios__Preference__c pref: [SELECT Id, 
                                                 rC_Bios__Active__c 
                                                 FROM rC_Bios__Preference__c 
                                                 WHERE rC_Sponsorship__Opportunity__c IN: opps 
                                                 AND rC_Bios__Active__c = true
                                                 AND rC_Bios__Type__c = 'Community']){
            pref.rC_Bios__Active__c = false;
            listPrefs.add(pref);
        }
        
        if(!listPrefs.isEmpty()){
            upsert listPrefs;
        }
        
    } // END public static void updatePreferences(List<rC_Bios__Relationship__c> scope){

    // This method is created by Rohit B on 18/Jan/2016 for task T-466983.
    // Creates two additional relationship records with receiver & giver
    // @param 'newRelationships' List Of rC_Bios__Relationship__c
    public static void create_Receiver_Giver_Relationship(List<rC_Bios__Relationship__c> newRelationships) {
      System.debug('[RB] - RCBiosRelationshipTriggerHelper.create_Receiver_Giver_Relationship :: Method Start..');
      List<rC_Bios__Relationship__c> lstRelationshipsToInsert = new List<rC_Bios__Relationship__c>();
      List<rC_Bios__Relationship__c> lstRelationshipsToDelPref = new List<rC_Bios__Relationship__c>();
      for(rC_Bios__Relationship__c rcbR :[SELECT Id, 
                                                  rC_Bios__Opportunity__c,
                                                  rC_Bios__Opportunity__r.rC_Giving__Primary_Contact__c,
                                                  rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__c,
                                          		  rC_Bios__Opportunity__r.Gift_Sponsorship__c
                                                  FROM rC_Bios__Relationship__c
                                                  WHERE Id IN: newRelationships
                                                  AND rC_Bios__Opportunity__c != null 
                                                  AND isCreatedFromTrigger__c != true]) {
            String pc = rcbR.rC_Bios__Opportunity__r.rC_Giving__Primary_Contact__c;
            String hcc = rcbR.rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__c;
            if(pc != hcc && rcbR.rC_Bios__Opportunity__r.Gift_Sponsorship__c) {
              rC_Bios__Relationship__c rel_receip = new rC_Bios__Relationship__c(
                rC_Bios__Opportunity__c = rcbR.rC_Bios__Opportunity__c,
                rC_Bios__Active__c = True,
                rC_Bios__Category__c = 'Sponsorship',
                rC_Bios__Role_1__c = 'Gift Sponsorship Recipient',
                rC_Bios__Role_2__c = 'Sponsorship Giving',
                rC_Bios__Contact_2__c = pc,
                RecordTypeId = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Giving').getRecordTypeId(),
                rC_Sponsorship__Start_Date_Time__c = System.now(),
                isCreatedFromTrigger__c = True
              );
              lstRelationshipsToInsert.add(rel_receip);

              rC_Bios__Relationship__c rel_giver = new rC_Bios__Relationship__c(
                rC_Bios__Active__c = True,
                rC_Bios__Category__c = 'Sponsorship',
                rC_Bios__Role_1__c = 'Gift Sponsorship Giver',
                rC_Bios__Role_2__c = 'Sponsorship Recipient',
                rC_Bios__Contact_1__c = hcc,
                rC_Bios__Contact_2__c = pc,
                RecordTypeId = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Contact').getRecordTypeId(),
                rC_Sponsorship__Start_Date_Time__c = System.now(),
                isCreatedFromTrigger__c = True
              );
              lstRelationshipsToInsert.add(rel_giver);
              //lstRelationshipsToDelPref.add(rcbR);
            } // END if(pc != hcc) {
            lstRelationshipsToDelPref.add(rcbR); // I-240460 | Ravi Chauhan | To resolve the issue of prefernce not getting deleted
        } // END for(rC_Bios__Relationship__c rcbR :[SELECT Id, 

        System.debug('[RB] - RCBiosRelationshipTriggerHelper.create_Receiver_Giver_Relationship :: lstRelationshipsToInsert.size() = ' + lstRelationshipsToInsert.size());
        if(!lstRelationshipsToInsert.isEmpty()) {
          insert lstRelationshipsToInsert;
          //deletePreferences(lstRelationshipsToDelPref);
        }
        // I-240460 | Ravi Chauhan | To resolve the issue of prefernce not getting deleted
        if(!lstRelationshipsToDelPref.isEmpty()){
            deletePreferences(lstRelationshipsToDelPref);
        }
        
        System.debug('[RB] - RCBiosRelationshipTriggerHelper.create_Receiver_Giver_Relationship :: Method End..');
    } // END public static void create_Receiver_Giver_Relationship(List<rC_Bios__Relationship__c> newRelationships) {
    
    //populate participants to opportunties.[Jagjeet Singh : I-202708]
    public static void populateParticipantToOpps(Set<ID> relationshipIds){
        List<Opportunity> oppToUpdate = new List<Opportunity>(); 
        for(rC_Bios__Relationship__c rcb : [Select ID, rC_Bios__Contact_2__c, rC_Bios__Opportunity__r.Product_Sub_Type__c,rC_Bios__Contact_2__r.FirstName,
                                            rC_Bios__Contact_2__r.LastName,rC_Bios__Account_2__r.RecordType.Name,rC_Bios__Account_2__r.ParentId, rC_Bios__Account_2__c,
                                            rC_Bios__Opportunity__c, rC_Bios__Category__c, rC_Bios__Role_1__c, rC_Bios__Role_2__c from rC_Bios__Relationship__c Where ID in :relationshipIds]) {
            if(rcb.rC_Bios__Opportunity__c != Null) {
                if(rcb.rC_Bios__Contact_2__c != null && rcb.rC_Bios__Opportunity__c != null && rcb.rC_Bios__Role_1__c == 'Participant' 
                    && rcb.rC_Bios__Role_2__c == 'Sponsorship Giving' && rcb.rC_Bios__Category__c == 'Sponsorship'){
                        Opportunity opp = new Opportunity(ID = rcb.rC_Bios__Opportunity__c);
                        opp.Participant__c = rcb.rC_Bios__Contact_2__c;
                        opp.Name = rcb.rC_Bios__Opportunity__r.Product_Sub_Type__c + ' - ' + rcb.rC_Bios__Contact_2__r.FirstName + ' ' + rcb.rC_Bios__Contact_2__r.LastName ;
                        oppToUpdate.add(opp);
                } else if(rcb.rC_Bios__Contact_2__c == null && rcb.rC_Bios__Account_2__c != null && rcb.rC_Bios__Category__c == 'Sponsorship'
                        && (rcb.rC_Bios__Account_2__r.RecordType.Name == 'Community' || rcb.rC_Bios__Account_2__r.RecordType.Name == 'National Office' || rcb.rC_Bios__Account_2__r.RecordType.Name == 'Local Partner'))
                {
                        Opportunity opp = new Opportunity(ID = rcb.rC_Bios__Opportunity__c);
                        opp.Sponsored_Account__c =  rcb.rC_Bios__Account_2__c;

                        // clear the participant, this is now a community sponsorship
                        opp.Participant__c = null;
                        
                        if(rcb.rC_Bios__Account_2__r.RecordType.Name == 'Community' || rcb.rC_Bios__Account_2__r.RecordType.Name == 'Local Partner') {
                            opp.rC_Sponsorship__Substitute_Account__c =  rcb.rC_Bios__Account_2__r.ParentId;
                        }
                        oppToUpdate.add(opp);
                }
            } // END if(rcb.rC_Bios__Opportunity__c != Null) {
        } // END for(rC_Bios__Relationship__c rcb : [
        System.debug('[RB] - RCBiosRelationshipTriggerHelper.populateParticipantToOpps :: oppToUpdate => ' + oppToUpdate);
        if(oppToUpdate.size() > 0)
            update oppToUpdate;
      } 
        /*
        system.debug('---insideMethodpopulateParticipantToOpps---');
        
        //Set of Opportunity Ids
        Set<Id> oppIds = new Set<Id>();
        Set<Id> participantIds = new Set<Id>();
        //Relation Opportunity Map
        Map<Id,rC_Bios__Relationship__c> relOppMap = new Map<Id,rC_Bios__Relationship__c>();
        
        //Vaibhav : March 7,2016 : Task T-481852 -Initiating new set of Opportunity IDs and Map of Opp & Relationship
        Set<Id> oppIdSet = new set<Id>();
        Map<Id,rC_Bios__Relationship__c> relOppMap2 = new Map<Id,rC_Bios__Relationship__c>();
        set<Id> acc2IdsSet = new Set<Id>();
        
        //Iterate over all the relationships and filter out the opportunities
        for(rC_Bios__Relationship__c rcb : scope) {
            system.debug('---rcbrC_Bios__Account_2__rRecordTypeName---' + rcb.rC_Bios__Account_2__r.RecordTypeId);
            system.debug('---rcbrC_Bios__Account_2__rRecordTypeName---' + rcb.rC_Bios__Account_2__r.RecordType.Id);
            system.debug('---rcbrC_Bios__Account_2__rRecordTypeName---' + rcb.rC_Bios__Account_2__c);
            acc2IdsSet.add(rcb.rC_Bios__Account_2__c);
            if(rcb.rC_Bios__Opportunity__c != null && rcb.rC_Bios__Role_1__c == 'Participant' 
            && rcb.rC_Bios__Role_2__c == 'Sponsorship Giving' && rcb.rC_Bios__Category__c == 'Sponsorship') {
                relOppMap.put(rcb.rC_Bios__Opportunity__c,rcb);
                participantIds.Add(rcb.rC_Bios__Contact_2__c);
            }
        }
        
        //Vaibhav Goel : Task T-481852 : Fetching all the Account2 records which are parent of new Relationship records
        Map<Id, map<Id, Account>> relAcc2Map = new map<Id, map<Id, Account>>();
        List<Account> relAcc2List = new List<Account>();
        if(acc2IdsSet != null && acc2IdsSet.size() > 0){
            relAcc2List = [Select Name , id , recordtypeid, recordType.Name from Account where Id IN: acc2IdsSet];
        }
        
        if(relAcc2List != null && relAcc2List.size() > 0){
            for(rC_Bios__Relationship__c rcb : scope) {
                map<Id, Account> tempAccMap = new Map<Id, Account>();
                for(Account acc : relAcc2List){
                    if(!tempAccMap.containsKey(acc.Id)){
                        tempAccMap.put(acc.Id, acc);
                    }
                }
                if(!relAcc2Map.containsKey(rcb.Id)){
                    relAcc2Map.put(rcb.Id, tempAccMap);
                }
            }
        }
        
        for(rC_Bios__Relationship__c rcb : scope) {
            if(rcb.rC_Bios__Contact_2__c == null && rcb.rC_Bios__Account_2__c != null && (relAcc2Map.get(rcb.Id).get(rcb.rC_Bios__Account_2__c).RecordType.Name == 'Local Partner' || relAcc2Map.get(rcb.Id).get(rcb.rC_Bios__Account_2__c).RecordType.Name == 'National Office' || relAcc2Map.get(rcb.Id).get(rcb.rC_Bios__Account_2__c).RecordType.Name == 'Community')){
                system.debug('----insideIFCondition---');
                oppIdSet.add(rcb.rC_Bios__Opportunity__c);
                system.debug('----oppIdSet---' + oppIdSet);
                relOppMap2.put(rcb.rC_Bios__Opportunity__c,rcb);
                system.debug('----relOppMap2---' + relOppMap2);
            }
        }
        
        
        
        //retrieve the opportunity data.
        List<Opportunity> oppList = [SELECT Id,RecordType.Name, Product_Type__c,Product_Sub_Type__c
                                     FROM Opportunity
                                     WHERE Id In : relOppMap.keySet() OR Id IN : relOppMap2.KeySet()]; 
        //create the participant Map
        Map<Id,Contact> partMap = new Map<Id,Contact>([Select Id,FirstName,LastName
                                         From Contact
                                         Where Id In : participantIds]);
        
        for(Opportunity tempOpp : oppList){
            rC_Bios__Relationship__c relObj = relOppMap.get(tempOpp.Id);
            
            if(relObj.rC_Bios__Contact_2__c != null){ 
                tempOpp.Participant__c = relObj.rC_Bios__Contact_2__c;    
                
            }
            
            //update the opp Namr based on conditions(Donation Record Typpe and sponsqorship type)
            if(tempOpp.RecordType.Name =='Donation' && tempOpp.Product_Type__c =='Sponsorship'){
                tempOpp.Name = tempOpp.Product_Sub_Type__c + ' - ' + partMap.get(relObj.rC_Bios__Contact_2__c).FirstName + ' ' + partMap.get(relObj.rC_Bios__Contact_2__c).LastName ;
            }
            if(relOppMap2 != null && relOppMap2.size() > 0 && relOppMap2.containsKey(tempOpp.id)){
                system.debug('---relOppMap2---' + relOppMap2.get(tempOpp.Id).rC_Bios__Account_2__c);
                if(relOppMap2.containsKey(tempOpp.Id)){
                    tempOpp.Sponsored_Account__c =  relOppMap2.get(tempOpp.Id).rC_Bios__Account_2__c;
                    if(relOppMap2.get(tempOpp.Id).rC_Bios__Account_2__r.RecordType.Name == 'Community' || relOppMap2.get(tempOpp.Id).rC_Bios__Account_2__r.RecordType.Name == 'Local Partner' ){
                        tempOpp.rC_Sponsorship__Substitute_Account__c =  relOppMap2.get(tempOpp.Id).rC_Bios__Account_2__r.ParentId ;
                    }
                }
                
            }
            
        }
        
        if(!oppList.isEmpty()) {
            system.debug('===>oppList' +oppList);
            update oppList;
        }
    } */
    
    // This method is created by Munib R on 4th May 2016 for task T-498437
    // Delete Preferences where Type is Participant Number
    public static void deletePreferences(List<rC_Bios__Relationship__c> scope) {
        System.debug('==beginning==');
        Set<Id> opps = new Set<Id>();
        //Set<Id> participantIds = new Set<Id>();
        Set<String> participantNumberSet = new Set<String>();//I-224762 | As per the latest updates on this issue
        List<rC_Bios__Preference__c> listPrefs = new List<rC_Bios__Preference__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Id SponsorshipRecTypeId = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();
        for(rC_Bios__Relationship__c rcb :[SELECT Id, 
                                                  rC_Bios__Opportunity__c, rC_Bios__Opportunity__r.participant__c,
                                                  rC_Bios__Opportunity__r.participant__r.Participant_Number__c
                                                  FROM rC_Bios__Relationship__c
                                                  WHERE Id IN: scope
                                                  AND rC_Bios__Opportunity__c != null 
                                                  AND rC_Bios__Category__c = 'Sponsorship']){
            opps.add(rcb.rC_Bios__Opportunity__c);
            if(rcb.rC_Bios__Opportunity__c != null && rcb.rC_Bios__Opportunity__r.participant__c != null)
                participantNumberSet.add(rcb.rC_Bios__Opportunity__r.participant__r.Participant_Number__c);//I-224762 | As per the latest updates on this issue
            //participantIds.add(rcb.rC_Bios__Opportunity__r.participant__c);
        } 
        System.debug('==opps.size=='+opps.size() + ' ' + opps);
            for(rC_Bios__Preference__c pref: [SELECT Id, 
                                                 rC_Bios__Active__c 
                                                 FROM rC_Bios__Preference__c 
                                                 WHERE rC_Sponsorship__Opportunity__c IN: opps
                                                 //AND rC_Bios__Type__c = 'Participant Number']){ // Commented for I-240460 and added condition for 'Name'
                                                 //AND rC_Bios__Type__c = 'ContactId'
                                                 AND rC_Bios__Type__c = 'Participant Number' //I-224762 | As per the latest updates on this issue
                                                 //AND rC_Bios__Subtype__c IN :participantIds
                                                 AND rC_Bios__Subtype__c IN :participantNumberSet]){//I-224762 | As per the latest updates on this issue
            listPrefs.add(pref);
        }
               
        if(!listPrefs.isEmpty()){
            delete listPrefs;
        }
        
    }
        
    //I-245585
    //Sets 15 day correspondence pause on new Participant
    public static void FifteenDayCorrespondencePause(List<rC_Bios__Relationship__c> newRelationships)
    {
        Set<id> relIds = new Set<id>();
                System.debug('SIZE>>>>>>>>>>>'+newRelationships.size());

        for(rC_Bios__Relationship__c rel : newRelationships)
        {
            if(rel.rC_Bios__Category__c == 'Sponsorship' && rel.rC_Bios__Contact_2__c != null && rel.rC_Bios__Contact_1__c == null && rel.rC_Bios__Opportunity__c != null)
                relIds.add(rel.id);
        }
        if(relIds.size() > 0)
        {
             List<rC_Bios__Relationship__c> rels = [select id, rC_Bios__Contact_2__c
                                               from rC_Bios__Relationship__c
                                               where rC_Bios__Opportunity__r.rC_Sponsorship__Sponsorship_Status_Reason__c = null and
                                                rC_Bios__Opportunity__r.Sponsorship_Change_Reason_Detail__c LIKE 'Child Departure -%' and
                                               id in :relIds];

            Set<id> contactIds = new Set<id>();

            for(rC_Bios__Relationship__c rel : rels)
                contactIds.add(rel.rC_Bios__Contact_2__c);

            if(contactIds.size() > 0)
            {
                List<Contact> contacts = [select id, Correspondence_Paused__c from contact where id in :contactIds];

                for(Contact con : contacts){
                    con.Correspondence_Paused__c = true;
                }           
                update contacts;
            }
        }
    }


} // END public without sharing class RCBiosRelationshipTriggerHelper{