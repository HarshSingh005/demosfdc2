/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ContactTriggerHandler
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Handler class of Contact Trigger
 * Created Date : 12/11/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 12/11/2015                   Karl Houseknecht        Support single trigger pattern and update of National Office / Local Partner fields
 * 12/14/2015                   Karl Houseknecht        Added UpdateParent Account to default the AccountId field to Community__c when null
 * 20/01/2016                   Shailendra Singh        Added createMCSForSponsoredChild() method that create 3 MCS records when child changes
                                                        from 'presponsored' -> 'sponsored'
 * 3/3/2016                     John Hecker             Modified UpdateLocalPartnerNationalOffice to not fire SOQL Query unless necessary
 * 10/03/2016                   Sudhir Kumar            Refactored code to optimize the iterations and SOQL (T-482408)
 * 29/03/2016                   Jagjeet Singh           I-208670 : Updated methods to solve the DML Problems.
 * 19/Apr/2016                  Rohit B.                Populated a field 'rC_Sponsorship__Reserve__c' on contact in 
 *                                                      method "PopulateLocalPartnerNationalOffice" for T-495590.
 * 24/Apr/2016                  Jagjeet Singh           Added method UpdateParticipantContactToReserved for Task - T-497160
 * 4/July/2016                  Ravi Chauhan            Modified PopulateLocalPartnerNationalOffice() for T-514023
 * 05/Sep/2016                  Ashu Gupta              Modified updateContactOwner() for T-514023
 * 06/Sep/2016                  Ravi Chauhan            Modified updateContactOwner() for T-514023
 * 21/Oct/2016                  Ravi Chauhan            I-224762 | Added one condition in the if clause in UpdateParticipantContactToReserved method
 * 10/Nov/2016                  Ravi Chauhan            I-243153 | Allowed the method createMCSForSponsoredChild to be called more than once
 **********************************************************************************************************/
public class ContactTriggerHandler{
    private static final Id participantRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    private static final String PRE_SPONSORED = 'Pre-Sponsored';
    private static final String SPONSORED = 'Sponsored';
    public static Map<Id, String> mapOfSponsorship = new Map<Id, String>();
    public static void OnBeforeInsert(List<Contact> newContacts) {
        //createContactSmartField(newContacts);
        PopulateLocalPartnerNationalOffice(newContacts);
        UpdateParentAccount(newContacts);
        //Added by Ravi Chauhan on 23/Jun/2016 for T-514023.  <<START>>
        updateContactOwner(newContacts,null);
        //Added by Ravi Chauhan on 23/Jun/2016 for T-514023.  <<END>>
    }

    public static void OnBeforeUpdate(List<Contact> newContacts, Map<Id, Contact> contactOldMap) {
        System.debug('======6666===='+newContacts.get(0).rC_Sponsorship__Sponsorship_Status__c);
        for(Contact cont : newContacts){
            if(cont.rC_Sponsorship__Sponsorship_Status__c != null){
                mapOfSponsorship.put(cont.Id, cont.rC_Sponsorship__Sponsorship_Status__c);
            }
        }
        UpdateLocalPartnerNationalOffice(newContacts, contactOldMap);
        UpdateParentAccount(newContacts);
        UpdateParticipantContactToReserved(newContacts,contactOldMap);
        //Added by Ravi Chauhan on 23/Jun/2016 for T-514023.  <<START>>
        updateContactOwner(newContacts,contactOldMap);
        //Added by Ravi Chauhan on 23/Jun/2016 for T-514023.  <<END>>
    }

    public static void OnAfterInsert(List<Contact> newContacts, Map<Id, Contact> contactNewMap) {
        updateAccountRollUpsInsert(contactNewMap);
    }
     
    public static void OnAfterUpdate(Map<Id, Contact> contactOldMap, List<Contact> newContacts, Map<Id, Contact> contactNewMap) {
        System.debug('======CheckRecursive.runContactOnce0====');  
        System.debug('======CheckRecursive.runContactOnce====' + CheckRecursive.runContactOnce);
        //system.debug('----contactOldMap---' + contactOldMap);
        //system.debug('----newContacts---' + newContacts);
        //system.debug('----contactNewMap---' + contactNewMap); 
        //System.Assert(!CheckRecursive.runContactOnce);
        if(!CheckRecursive.runContactOnce) {
            System.debug('======1111===='+newContacts.get(0).rC_Sponsorship__Sponsorship_Status__c);
            CheckRecursive.runContactOnce = true;
        updateAccountRollUpsUpdate(contactOldMap, contactNewMap);
        System.debug('======2222===='+newContacts.get(0).rC_Sponsorship__Sponsorship_Status__c);
        UpdateCase(contactNewMap, contactOldMap);
        System.debug('======3333===='+newContacts.get(0).rC_Sponsorship__Sponsorship_Status__c);
        departChild(contactOldMap, contactNewMap);
        System.debug('======4444===='+newContacts.get(0).rC_Sponsorship__Sponsorship_Status__c);
        contactCancelDFCFee(contactOldMap, contactNewMap);
        System.debug('======5555===='+newContacts.get(0).rC_Sponsorship__Sponsorship_Status__c);
        //createMCSForSponsoredChild(newContacts, contactOldMap);

        RSAChildUpdateLetters(newContacts, contactOldMap);
        }
        //I-243153 | As part of this issue moved this method call from runContactOnce to here
        // Due to single call the MCS records were not getting created on Participant
        createMCSForSponsoredChild(newContacts, contactOldMap);
        
    }

    /**
    * Written method as per Dirk's email for smart field work.
    */
    /*public static void createContactSmartField(List<Contact> newContacts) {
        List<Contact_Smart_Fields__c> lstCSF = new List<Contact_Smart_Fields__c>();
        for(Contact con : newContacts) {
            if(con.RecordTypeId == Label.Household_Id) {
                Contact_Smart_Fields__c csf = new Contact_Smart_Fields__c();
                lstCSF.add(csf);
            }
        }

        if(lstCSF.size()>0) {
            insert lstCSF; 
        }

        Integer i=0;
        for(Contact con : newContacts) {
            if(con.RecordTypeId == Label.Household_Id && lstCSF.size() >= i ) {
                con.Contact_Smart_Field__c = lstCSF[i].Id;
                i = i+1;
            }
        }
    }*/

    //  If a participant has changed their: community or sponsorship status, recalculate rollups for that community
    public static void updateAccountRollUpsUpdate(Map<Id, Contact> contactOldMap, Map<Id, Contact> contactNewMap) {
        Set<Id> setCommunities = new Set<Id>();
        for( ID contactID : contactNewMap.keySet() )
        {
            if (
                   (
                    (contactOldMap.get( contactID ).Community__c != contactNewMap.get( contactID ).Community__c ) ||
                    (contactOldMap.get( contactID ).rC_Sponsorship__Sponsorship_Status__c != contactNewMap.get( contactID ).rC_Sponsorship__Sponsorship_Status__c )
                   )
               )
            {
                 if(contactNewMap.get( contactID ).Community__c != null) {
                     setCommunities.add( contactNewMap.get( contactID ).Community__c );
                 }
                 if(contactOldMap.get( contactID ).Community__c != null) {
                 setCommunities.add( contactOldMap.get( contactID ).Community__c );
               }
            }
        }


        if(!setCommunities.isEmpty() && Limits.getQueueableJobs() == 0){
            ID jobID = System.enqueueJob(new AccountQuotaRollups(setCommunities));
        }
    }
    
     public static void contactCancelDFCFee(Map<Id, Contact> contactOldMap, Map<Id, Contact> contactNewMap) {
        Id transactionRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Set<Id> contactIds = new Set<Id>();
        for( ID contactID : contactNewMap.keySet() ){
            if (
                   (
                    (contactOldMap.get( contactID ).Accept_DF_Fee__c != contactNewMap.get( contactID ).Accept_DF_Fee__c ) &&
                    (contactOldMap.get( contactID ).Accept_DF_Fee__c != false)
                   )
               )
            {
                contactIds.add(contactID);
            }
        }
        System.debug('----contIds---'+contactIds);
        if(!contactIds.isEmpty()){
            List<Opportunity> oppList = [select Id, StageName from Opportunity where rC_Giving__Hard_Credit_Contact__c in :contactIds
                                         AND RecordType.Id = :transactionRecordId AND DFC_Status__c = 'Auto Fee' AND StageName = 'Open'];
            System.debug('----oppList---'+oppList);
            if(!oppList.isEmpty()){
                for(Opportunity opp : oppList){
                    opp.StageName = 'Canceled';
                }
            }
            update oppList;
        }
     }

    public static void updateAccountRollUpsInsert(Map<Id, Contact> contactNewMap) {
        Set<Id> setCommunities = new Set<Id>();
        for( ID contactID : contactNewMap.keySet() )
        {
            if(contactNewMap.get( contactID ).Community__c != null) {
                setCommunities.add( contactNewMap.get( contactID ).Community__c );
            }
        }


        if(!setCommunities.isEmpty() && Limits.getQueueableJobs() == 0){
            ID jobID = System.enqueueJob(new AccountQuotaRollups(setCommunities));
        }
    }

    //Updates the Local Partner and National Office fields on Contact
    //based upon the Community Account lookup field
    private static void PopulateLocalPartnerNationalOffice(List<Contact> newContacts) {
        //get a set of community account ids to retrieve the parent accountids
        //for Local Partner and National Office
        Set<Id> communityIds = new Set<Id>();
        for(Contact contact : newContacts) {
            if(contact.Community__c != null) {
                communityIds.add(contact.Community__c);
            }
            else {
                contact.Local_Partner__c = null;
            contact.National_Office__c = null;
            }
        }

        if(communityIds.size() > 0) {
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, ParentId, Parent.ParentId, Dedicated_Reserve__c FROM Account where id in :communityIds]);
            //update the Local Partner and National Office lookup fields based on the Community lookup field
            for(Contact contact : newContacts) {
                if(contact.Community__c != null) {
                    Account community = accountMap.get(contact.Community__c);
                    contact.Local_Partner__c = community.ParentId;
                    contact.National_Office__c = community.Parent.ParentId;
                
                // Addede by Rohit B on 19/Apr/2016 for task T-495590.          --START--
                if(community.Dedicated_Reserve__c != Null) {
                    contact.rC_Sponsorship__Reserve__c = community.Dedicated_Reserve__c;
                    contact.rC_Sponsorship__Reserve_Date__c = System.now();
                    contact.rC_Sponsorship__Sponsorship_Status__c = 'Reserved';
                }
                    // Addede by Rohit B on 19/Apr/2016 for task T-495590.          --END--
                }
            } // END for(Contact contact : newContacts) {
        }
    }
    //Refactored by Jagjeet Singh on 29/03/2016 to remove the DML in BeforeUpdate event.
    //Refactored by John Hecker 3/3/2016 to only enter business logic if Community ISCHANGED
    //Updates the Local Partner and National Office fields on Contact
    //based upon the Community Account lookup field
    private static void UpdateLocalPartnerNationalOffice(List<Contact> newContacts, Map<Id, Contact> contactOldMap) {

        //get a set of community account ids to retrieve the parent accountids
        //for Local Partner and National Office
        Set<Id> communityIds = new Set<Id>();
        List<Contact> commContacts = new List<Contact>();
        for(Contact contact : newContacts) {
            if (contact.Community__c != contactOldMap.get(contact.Id).Community__c) {
                communityIds.add(contact.Community__c);
                commContacts.add(contact);
            }
        } // END for(Contact contact : newContacts) {

        if(communityIds.size() > 0){
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, ParentId, Parent.ParentId FROM Account where id in :communityIds]);
            //update the Local Partner and National Office lookup fields based on the Community lookup field
            for(Contact contact : commContacts) {
                if(contact.Community__c != null) {
                    Account community = accountMap.get(contact.Community__c);
                    contact.Local_Partner__c = community.ParentId;
                    contact.National_Office__c = community.Parent.ParentId;
                } else {
                    contact.Local_Partner__c = null;
                    contact.National_Office__c = null;
                }
            }
            //Jagjeet Singh : I-208670 : Removed DML from Before Update event as this is not needed.
            //update commContacts;
        } //END if(communityIds.size() > 0)
    }

    //END Refactor by John Hecker 3/3/2016

    //Updates standard Account Name field on Contact only when it is null on insert or update
    //The standard Account Name field, if null, makes the Contact Private
    //Normally it will contain a reference to a Household Account representing the Participant's family
    //But if a family does not exist, default it to be the same as Community.
    private static void UpdateParentAccount(List<Contact> newContacts) {
        for(Contact contact : newContacts)
            if(contact.RecordTypeId == participantRecordTypeId && contact.Community__c != null && contact.AccountId == null)
                contact.AccountId = contact.Community__c;
    } // END private static void UpdateParentAccount(List<Contact> newContacts) {

    // creating 3 MCS records when child changes from 'presponsored' -> 'sponsored'
    public static void createMCSForSponsoredChild(List<Contact> newContacts, Map<Id, Contact> contactOldMap) {
        List<Mail_Control_Slip__c> mcsList = new List<Mail_Control_Slip__c>();
        for(Contact cnt : newContacts) {
            if( cnt.RecordTypeId == participantRecordTypeId && ( (mapOfSponsorship.get(cnt.Id) == SPONSORED
                && contactOldMap.get(cnt.id).rC_Sponsorship__Sponsorship_Status__c == PRE_SPONSORED && cnt.Correspondence_Paused__c == false) || (cnt.rC_Sponsorship__Sponsorship_Status__c == SPONSORED &&
                cnt.Correspondence_Paused__c == false && contactOldMap.get(cnt.id).Correspondence_Paused__c == true) ) ) {
                // note: this is a non-existant letter type, no needed:
                //mcsList.add(new Mail_Control_Slip__c(MCS_Letter_Type__c = 'Child Status Slip', Participant__c = cnt.id));

                mcsList.add(new Mail_Control_Slip__c(MCS_Letter_Type__c = 'National Director Welcome Letter', Participant__c = cnt.id));
                mcsList.add(new Mail_Control_Slip__c(MCS_Letter_Type__c = 'Child Bonding Letter', Participant__c = cnt.id));
                mcsList.add(new Mail_Control_Slip__c(MCS_Letter_Type__c = 'Child Welcome Letter', Participant__c = cnt.id));
            }
        }
        if(!mcsList.isEmpty()) {
            insert mcsList;
        }

    }

    public static void departChild(Map<Id, Contact> contactOldMap, Map<Id, Contact> contactNewMap) {
        Set<Id> listContacts = new Set<Id>();
        for(Id cont : contactNewMap.keySet())
        {
          if(contactOldMap.get(cont).Departed__c != contactNewMap.get(cont).Departed__c && contactNewMap.get(cont).Departed__c == true)
          {
            System.debug('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
            listContacts.add(cont);

          }
        }
        if(!listContacts.isEmpty()){
            departChildsForContacts(listContacts);
        }
    } // END public void departChild(
    
    public static void departChildsForContacts(Set<Id> contList) 
    {
        //update the sponsorship status on the active sponsorship opportunities 
        //based on whether they are legacy or not.
        //in order for the NGOC code to close the sponsorship
        System.debug('[RB] - ContactTriggerHandler.departChildsForContacts :: Method Start..');
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        //find a list of active sponsorship opportunities where the departed contact is the particpant
        for(Opportunity opp : [SELECT Id, Legacy_Type__c, rC_Sponsorship__Sponsorship_Status__c, Sponsorship_Status__c, Legacy_End_Date__c, 
                                    rC_Sponsorship__Sponsorship_Status_Reason__c, Participant__r.Birthdate, rC_Sponsorship__Substitute_Account__c, 
                                    rC_Sponsorship__Substitute_Contact__c, Participant__r.Community__c, Participant__r.Departure_Reason__c,
                                    rC_Giving__Primary_Contact__r.rC_Bios__Active__c, CFI_Do_Not_Substitute__c, Participant__c,
                                    rC_Giving__Primary_Contact__r.rC_Bios__Deceased__c,
                                    (SELECT Id, Name FROM DFC_Related_Opportunity__r WHERE StageName NOT IN ('Completed', 'Cancelled') AND 
                                    RecordType.Name = 'Donation' AND Product_Type__c = 'Designated Fund') 
                                    FROM Opportunity where Participant__c in :contList
                                    AND rC_Sponsorship__Sponsorship_Status__c = 'Active'
                                    AND RecordType.Name = 'Donation'
                                    AND Product_Type__c = 'Sponsorship']) {
            //String newDepartReason = 'Child Departure - ';
            System.debug('[RB] - ContactTriggerHandler.departChildsForContacts :: Inside For..');
            if(opp.Participant__r.Departure_Reason__c != null) {
                //newDepartReason += '[' + opp.Participant__r.Departure_Reason__c + ']';
                opp.Sponsorship_Change_Reason_Detail__c = 'Child Departure - [' + opp.Participant__r.Departure_Reason__c + ']';
            }
            
            if(opp.Legacy_Type__c == 'Term')
            {
                
                opp.Cancel_Sponsorship__c = 'Cancel - No Reinstate';              
                //opp.rC_Sponsorship__Sponsorship_Status__c = 'Closed';
                //opp.Sponsorship_Status__c = 'Closed';
                opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
                opp.Legacy_End_Date__c = System.today();             
                //opp.Sponsorship_Change_Reason_Detail__c = newDepartReason;                
                oppListToUpdate.add(opp);
                
            }
            else if(opp.Legacy_Type__c == 'Perpetual')
            {
                //Updated as per Issue I-251295
                if(opp.rC_Giving__Primary_Contact__r.rC_Bios__Deceased__c){
                    if(opp.rC_Sponsorship__Substitute_Account__c == null) 
                    {
                        opp.rC_Sponsorship__Substitute_Contact__c = null;
                        opp.rC_Sponsorship__Substitute_Account__c = opp.Participant__r.Community__c;
                    } 
                }
                opp.rC_Sponsorship__Sponsorship_Status__c = 'Request for Participant Change';
                opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Participant Change';
                opp.Sponsorship_Status_Reason_Copy__c = 'Participant Change';
                //opp.Sponsorship_Change_Reason_Detail__c = newDepartReason;
                oppListToUpdate.add(opp);
            }
            else if((opp.Legacy_Type__c == null && opp.CFI_Do_Not_Substitute__c == null) || (opp.Legacy_Type__c == 'Perpetual' && opp.rC_Giving__Primary_Contact__r.rC_Bios__Active__c))
            { 
                opp.rC_Sponsorship__Sponsorship_Status__c = 'Request for Participant Change'; 
                opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Participant Change'; 
                opp.Sponsorship_Status_Reason_Copy__c = 'Participant Change';
                //opp.Sponsorship_Change_Reason_Detail__c = newDepartReason;
                oppListToUpdate.add(opp);
            }
            else if(opp.Legacy_Type__c == null && opp.CFI_Do_Not_Substitute__c != null) 
            {
                opp.Cancel_Sponsorship__c = 'Cancel - No Reinstate'; 
                opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation'; 
                //opp.Sponsorship_Change_Reason_Detail__c = newDepartReason;
                oppListToUpdate.add(opp);
            }
            
            //When Departed Child's Sponsorship Closed, cancelled related DFCs under I-240149
            for(Opportunity dfcOpp : opp.DFC_Related_Opportunity__r) {
                System.debug('[RB] - ContactTriggerHandler.departChildsForContacts :: Inside For (DFC Opportunity)..');
                dfcOpp.rC_Giving__Is_Canceled__c = true;
                oppListToUpdate.add(dfcOpp);
            }
            
        } // END for(Opportunity opp : [SELECT Id, Legacy_Type__c...
        
        if(oppListToUpdate.size() > 0)
            update oppListToUpdate;
        System.debug('[RB] - ContactTriggerHandler.departChildsForContacts :: Method End..');
    } // END public static void departChildsForContacts(Set<Id> contList) 

    static void UpdateCase(Map<Id, Contact> contactNewMap, map<Id, Contact> oldMap) {
        List<Contact> contactNeedToBeProcessed = new List<Contact>();
        for(Contact con : contactNewMap.values()) {
            if((con.AccountId != oldMap.get(con.Id).AccountId)) {
                contactNeedToBeProcessed.add(con);
            }
        }
      if(contactNeedToBeProcessed.size() > 0) {
              list<Case> caseToUpdate = new list<Case>();
              for(Case cs : [SELECT Id, AccountId, ContactId FROM Case WHERE ContactId IN: contactNeedToBeProcessed]) {
                if(contactNewMap.containsKey(cs.ContactId)) {
                    cs.AccountId = contactNewMap.get(cs.ContactId).AccountId;
                    caseToUpdate.add(cs);
                }
              }
            update caseToUpdate;
      }
    } // END public static void UpdateCase(list<Contact> conList, map<Id, Contact> oldMap) {
    //Commenting out as not used anywhere : Jagjeet Singh : 03/30/2016 //
    /*static map<Id, list<Case>> casesToContact(list<Contact> conList) {
        map<Id, list<Case>> mapToReturn = new map<Id, list<Case>>();
        for(Case cs : [SELECT Id, AccountId, ContactId FROM Case WHERE ContactId IN: conList]) {
            if(!mapToReturn.containsKey(cs.ContactId)) {
                mapToReturn.put(cs.ContactId, new List<Case>());
            }
            mapToReturn.get(cs.ContactId).add(cs);
        }
        return mapToReturn;
    } // END public static map<Id, list<Case>> casesToContact(list<Contact> conList)    {*/
    
    //Updates the Participant Contact status to reserved.
    private static void UpdateParticipantContactToReserved(List<Contact> newContacts, Map<Id, Contact> contactOldMap) {
 
        Set<Id> communityIds = new Set<Id>();
        List<Contact> commContacts = new List<Contact>();
        for(Contact contact : newContacts) {
            // I-224762 | Updated the if condition by adding && !DoNotUpdateReserve__c condition as per issue
            if (((contact.rC_Sponsorship__Sponsorship_Status__c == 'Available' || contact.rC_Sponsorship__Sponsorship_Status__c == 'Unavailable') && !contact.DoNotUpdateReserve__c)
                 && contact.rC_Sponsorship__Sponsorship_Status__c != contactOldMap.get(contact.Id).rC_Sponsorship__Sponsorship_Status__c) {
                communityIds.add(contact.Community__c);
                commContacts.add(contact);
            }
        } // END for(Contact contact : newContacts) {

        if(communityIds.size() > 0){
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, ParentId, Dedicated_to_Alliance__c,Dedicated_Reserve__c FROM Account where id in :communityIds]);
            for(Contact contact : commContacts) {
                if(contact.Community__c != null) {
                    Account community = accountMap.get(contact.Community__c);
                    if(community.Dedicated_Reserve__c != null && community.Dedicated_to_Alliance__c != null){
                        contact.rC_Sponsorship__Reserve__c = community.Dedicated_Reserve__c;
                        contact.rC_Sponsorship__Reserve_Date__c = system.today();
                        contact.rC_Sponsorship__Sponsorship_Status__c = 'Reserved';
                    }
                } 
            }
        } //END if(communityIds.size() > 0)
    }
    
    //Added by Ravi Chauhan on 23/Jun/2016 for T-514023.  --START--
    /**
     *  @Method      : updateContactOwner
     *  @Param       : List<Contact>
     *  @description : Method for updating the owner of Contact.
     *  @return      : None
     */    
    private static void updateContactOwner(List<Contact> newContacts,Map<Id,Contact> contactOldMap){
        Map<Id, Account> localPartnerNationalOfficeMap = new Map<Id, Account>();
        Set<Id> localPartnerNationalOfficeIds = new Set<Id>();
        List<Contact> filteredContacts = new List<Contact>();
        
        // Filtering the Contact records during insertion OR updation
        
        for(Contact con : newContacts){
            if(con.RecordTypeId == participantRecordTypeId){
                filteredContacts.add(con);
                if(contactOldMap == null){
                    if(con.Local_Partner__c != null)
                        localPartnerNationalOfficeIds.add(con.Local_Partner__c);
                    if(con.National_Office__c != null)
                        localPartnerNationalOfficeIds.add(con.National_Office__c);
                }
                
                //Added by Ashu Gupta for T-514023--Start--
                else{
                    if(con.Community__c != null && con.Community__c != contactOldMap.get(con.Id).Community__c){
                        localPartnerNationalOfficeIds.add(con.Community__c);
                        System.debug('Inside update community @@@');
                    }
                    if(con.Local_Partner__c != null && con.Local_Partner__c != contactOldMap.get(con.Id).Local_Partner__c)
                        localPartnerNationalOfficeIds.add(con.Local_Partner__c);
                    if(con.National_Office__c != null && con.National_Office__c != contactOldMap.get(con.Id).National_Office__c)
                        localPartnerNationalOfficeIds.add(con.National_Office__c);
                }
            //Added by Ashu Gupta for T-514023--End--
            }

        }
        
        if(localPartnerNationalOfficeIds.size() > 0)
            localPartnerNationalOfficeMap = new Map<Id, Account>([SELECT Id, Participant_Contact_Owner__c FROM Account WHERE id IN :localPartnerNationalOfficeIds]);
        else
            return;
            
        // Update the Contact Owner based on Business Logic    
        for(Contact contact : filteredContacts){
                if(contact.Local_Partner__c != null && localPartnerNationalOfficeMap != null 
                && localPartnerNationalOfficeMap.containsKey(contact.Local_Partner__c) 
                && localPartnerNationalOfficeMap.get(contact.Local_Partner__c) != null 
                && localPartnerNationalOfficeMap.get(contact.Local_Partner__c).Participant_Contact_Owner__c != null){
                    
                    contact.ownerId = localPartnerNationalOfficeMap.get(contact.Local_Partner__c).Participant_Contact_Owner__c;
                }
                else if(contact.Local_Partner__c == null && localPartnerNationalOfficeMap != null 
                && contact.National_Office__c != null && localPartnerNationalOfficeMap.containsKey(contact.National_Office__c)  
                && localPartnerNationalOfficeMap.get(contact.National_Office__c) != null 
                && localPartnerNationalOfficeMap.get(contact.National_Office__c).Participant_Contact_Owner__c != null){
                    
                    contact.ownerId = localPartnerNationalOfficeMap.get(contact.National_Office__c).Participant_Contact_Owner__c;
                }
        }    
    }
    //Added by Ravi Chauhan on 23/Jun/2016 for T-514023.  --END--
    

    public static void RSAChildUpdateLetters(List<Contact> listContacts, Map<Id, Contact> mapContactOld)
    {

        ID parRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();

        List<Print_Queue__c> listPrintQueue = new List<Print_Queue__c>();

        List<rC_Bios__Relationship__c> listRelations = [select rC_Bios__Contact_2__c, rC_Bios__Opportunity__c
            from rC_Bios__Relationship__c
            where rC_Bios__Contact_2__c in :mapContactOld.keySet()
            and rC_Bios__Active__c = true
            and rC_Bios__Role_2__c = 'Sponsorship Giving'];

        Map<ID, ID> mapParID_currOppID = new Map<ID, ID>();
        for (rC_Bios__Relationship__c relationship : listRelations)
            mapParID_currOppID.put(relationship.rC_Bios__Contact_2__c, relationship.rC_Bios__Opportunity__c);  // 2=participant, 1=current active opp
        for (Contact thisContact : listContacts)
        {
            if (thisContact.recordTypeId != parRTID)
                continue;

            Print_Queue__c pq = new Print_Queue__c();

            if (thisContact.FirstName != mapContactOld.get(thisContact.id).FirstName ||
                thisContact.LastName != mapContactOld.get(thisContact.id).LastName ||
                thisContact.Short_Name__c != mapContactOld.get(thisContact.id).Short_Name__c)
            {
                pq.Letter_ID__c = '2101';
                pq.Prior_Participant_ID__c = thisContact.id;
            }
            else if (thisContact.rC_Bios__Gender__c != mapContactOld.get(thisContact.id).rC_Bios__Gender__c )
            {
                pq.Letter_ID__c = '2103';
                pq.Prior_Participant_ID__c = thisContact.id;
            }
            else if (thisContact.Birthdate != mapContactOld.get(thisContact.id).Birthdate )
            {
                pq.Letter_ID__c = '2102';
                pq.Prior_Participant_ID__c = thisContact.id;
            }

            if (pq.Letter_ID__c != null)
            {
                if (mapParID_currOppID.containsKey(thisContact.id))
                {
                    pq.Opportunity__c = mapParID_currOppID.get(thisContact.id);
                    listPrintQueue.add(pq);
                }
            }
        }

        if (listPrintQueue.size() > 0)
            insert listPrintQueue;

    }

}