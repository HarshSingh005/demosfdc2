// Purpose: For each MCS record created:
//   - set mcs date to today
//   - set Due date to future date, calculated based on letter type
//   - create an additional MCS record for letter type = Sponsor Letter
// Developer: Dirk K. - Dec/15

/* Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 05/09/2016                   Munib Ur Rehman         Created After Insert After Update Trigger methods
 * 09/06/2016                   Ravi Chauhan            T-514023 | Changes as per new description
 **********************************************************************************************************/

public with sharing class MCSTriggerHandler {

    list<Mail_Control_Slip__c> listCRL = new list<Mail_Control_Slip__c>();

    public MCSTriggerHandler (boolean isExecuting, integer size) {
    }
    
    public void OnBeforeInsert(list<Mail_Control_Slip__c> listMCS){
        System.debug('[RB] - MCSTriggerHandler.OnBeforeInsert :: Method Start..');

        List<ID> ParticipantList = new List<ID>();
        for(Mail_Control_Slip__c MCS: listMCS) {
            ParticipantList.add(MCS.Participant__c);
        }
              System.debug('Ashu>>>Participant list before insert @@@'+ParticipantList);  
        List<rC_Bios__Relationship__c> relationshipList = new List<rC_Bios__Relationship__c>();
        relationshipList = [select rC_Bios__Contact_1__c, rC_Bios__Contact_2__c
            from rC_Bios__Relationship__c
            where
            rC_Bios__Category__c = 'Sponsorship' AND
            rC_Bios__Role_1__c = 'Sponsor' AND
            rC_Bios__Role_2__c = 'Participant' AND
            rC_Bios__Active__c = true AND
            rC_Bios__Contact_2__c in :ParticipantList];
            System.debug('Ashu >>>relationship List before insert @@@'+relationshipList);
        Map<ID,ID> participantDonorMap = new Map<ID,ID>();
        for(rC_Bios__Relationship__c Rela: relationshipList ) {
            participantDonorMap.put(Rela.rC_Bios__Contact_2__c, Rela.rC_Bios__Contact_1__c);
        }

        // get no field corr flag
        List<rC_Bios__Relationship__c> relationshipList2 = new List<rC_Bios__Relationship__c>();
        relationshipList2 = [select rC_Bios__Contact_2__c,
            rC_Bios__Contact_2__r.National_Office__c,
            rC_Bios__Contact_2__r.Local_Partner__c,
            rC_Bios__Contact_2__r.Community__c,
            rC_Bios__Opportunity__c, 
            rC_Bios__Opportunity__r.All_Child_Correspondence__c
            from rC_Bios__Relationship__c
            where
            rC_Bios__Category__c = 'Sponsorship' AND
            rC_Bios__Role_2__c = 'Sponsorship Giving' AND
            rC_Bios__Role_1__c = 'Participant' AND
            rC_Bios__Active__c = true AND
            rC_Bios__Contact_2__c  in :ParticipantList];
            System.debug('Ashu >>>Relationship list 2 before insert : @@@'+relationshipList2);
        Map<ID,boolean> participant_corrFlagMap2 = new Map<ID,boolean>();
        Map<ID,ID> participant_NO_Map = new Map<ID,ID>();
        Map<ID,ID> participant_LP_Map = new Map<ID,ID>();
        Map<ID,ID> participant_Community_Map = new Map<ID,ID>();
        for(rC_Bios__Relationship__c Rela: relationshipList2 ) {
            participant_corrFlagMap2.put(Rela.rC_Bios__Contact_2__c, Rela.rC_Bios__Opportunity__r.All_Child_Correspondence__c);
            participant_NO_Map.put(Rela.rC_Bios__Contact_2__c, Rela.rC_Bios__Contact_2__r.National_Office__c);
            participant_LP_Map.put(Rela.rC_Bios__Contact_2__c, Rela.rC_Bios__Contact_2__r.Local_Partner__c);
            participant_Community_Map.put(Rela.rC_Bios__Contact_2__c, Rela.rC_Bios__Contact_2__r.Community__c);
        }

        
        for(Mail_Control_Slip__c MCS: listMCS) {
        
            IF (MCS.MCS_Date__c == NULL){
            MCS.MCS_Date__c = date.today();
            }

            // IF Opportunity__r.All_Child_Correspondence__c == true, CANCEL MCS, except for CPRs and TYLs
            if (participant_corrFlagMap2.containsKey(MCS.Participant__c)) {

              if(participant_corrFlagMap2.get(MCS.Participant__c) == true
               && MCS.MCS_Letter_Type__c != 'Child Progress Report' && MCS.MCS_Letter_Type__c!=null) {

               if (MCS.MCS_Letter_Type__c != 'Thank You Letter for DF' && MCS.MCS_Letter_Type__c!=null)
                MCS.MCS_Status__c = 'Cancel';

               MCS.Comments__c = 'No field correspondence requested';

              }
              else
                MCS.MCS_Status__c = 'Active';

            }

        
            // Only populate Donor ID if null (there should always only be 1-1 donor to child)
            if (participantDonorMap.containsKey(MCS.Participant__c) && MCS.Donor__c == null)
                MCS.Donor__c = participantDonorMap.get(MCS.Participant__c);
            //else
            //    MCS.Donor__c = null;

            if (participant_NO_Map.containsKey(MCS.Participant__c) )
                MCS.NO_Lookup__c = participant_NO_Map.get(MCS.Participant__c);
            if (participant_LP_Map.containsKey(MCS.Participant__c) )
                MCS.LP_Lookup__c = participant_LP_Map.get(MCS.Participant__c);
            if (participant_Community_Map.containsKey(MCS.Participant__c) )
                MCS.Community_Lookup__c = participant_Community_Map.get(MCS.Participant__c);

        
            if(MCS.MCS_Letter_Type__c == 'Child Welcome Letter') {
              MCS.Due_Date__c = date.today().addDays(20);
            }
            if(MCS.MCS_Letter_Type__c == 'Child Bonding Letter') {
              MCS.Due_Date__c = date.today().addDays(90);
            }
            if(MCS.MCS_Letter_Type__c == 'Thank You Letter for DF') {
              MCS.Due_Date__c = date.today().addDays(45);
            }
            if(MCS.MCS_Letter_Type__c == 'Sponsor Letter') {
              MCS.Due_Date__c = date.today().addDays(5);
              
              // Sponsor Letter type creates an additional MCS record: Child Reply Letter
              // 
              
              Mail_Control_Slip__c CRL = new Mail_Control_Slip__c();
              CRL.MCS_Letter_Type__c = 'Child Reply Letter';
              CRL.Donor__c = MCS.Donor__c;
              CRL.Participant__c = MCS.Participant__c;
              listCRL.add(CRL);
              
            }
            if(MCS.MCS_Letter_Type__c == 'Child Reply Letter') {
              MCS.Due_Date__c = date.today().addDays(45);
            }
            if(MCS.MCS_Letter_Type__c == 'Child Initiated Letter') {
              MCS.Due_Date__c = date.today().addDays(30);
            }
            if(MCS.MCS_Letter_Type__c == 'Child Progress Report') {
              
              if(MCS.Child_Sponsorship_Status__c == 'Sponsored')
                MCS.Due_Date__c = date.today().addDays(60);
              else
                MCS.Due_Date__c = date.today().addDays(90);

            }
            if(MCS.MCS_Letter_Type__c == 'National Director Welcome Letter') {
              MCS.Due_Date__c = date.today().addDays(15);
            }
            if(MCS.MCS_Letter_Type__c == 'Sub/Shift National Director Welcome Letter') {
              MCS.Due_Date__c = date.today().addDays(15);
            }
            if(MCS.MCS_Letter_Type__c == 'Child Spontaneous Letter') {
              MCS.Due_Date__c = date.today().addDays(5);
            }
            if(MCS.MCS_Letter_Type__c == 'Child Farewell Letter') {
              MCS.Due_Date__c = date.today().addDays(60);
            }

        }
        
        // insert Child Response Letter MCSs (for each Sponsor Letter)
        // this will recursively call this trigger one more time
        insert listCRL;
        
        updateMCSOwner(listMCS);
        System.debug('[RB] - MCSTriggerHandler.OnBeforeInsert :: Method End..');
    }

    //Added by Ravi Chauhan on 04/July/2016 for T-514023.  <<START>>
    
    /**
     *  @Method      : OnBeforeUpdate
     *  @Param       : List<Mail_Control_Slip__c> , Map<Id,Mail_Control_Slip__c>
     *  @description : Method to be called from trigger before update of Mail Control Slip.
     *  @return      : None
     */ 
    public void OnBeforeUpdate(List<Mail_Control_Slip__c> listMCS, Map<Id,Mail_Control_Slip__c> newMap){
            updateMCSOwner(listMCS);
    }
    
    /**
     *  @Method      : OnAfterUpdate
     *  @Param       : List<Mail_Control_Slip__c> , Map<Id,Mail_Control_Slip__c>
     *  @description : Method to be called from trigger after update of Mail Control Slip.
     *  @purpose     : Used to update Opportunity Owner
     *  @return      : None
     */ 
    public void OnAfterUpdate(List<Mail_Control_Slip__c> listMCS, Map<Id,Mail_Control_Slip__c> newMap){
            //updateOpportunityOwner(listMCS, newMap);
    }
    
    /**
     *  @Method      : OnAfterInsert
     *  @Param       : List<Mail_Control_Slip__c> , Map<Id,Mail_Control_Slip__c>
     *  @description : Method to be called from trigger after Insert of Mail Control Slip.
     *  @purpose     : Used to update Opportunity Owner
     *  @return      : None
     */ 
    public void OnAfterInsert(List<Mail_Control_Slip__c> listMCS, Map<Id,Mail_Control_Slip__c> newMap){
            //updateOpportunityOwner(listMCS, newMap);
    }
    /*
    // Update the Owner of DFC Opportunity of mail Control slip record depending on the participants related fields.
    public void updateOpportunityOwner(List<Mail_Control_Slip__c> listMCS, Map<Id,Mail_Control_Slip__c> newMap){
        
        List<Id> oppList = new List<Id>();
        Map<Id, Id> OppToOwnerMap = new Map<Id, Id>();
        
        //Querying out related Items list for Mail Control Slip Records
        List<Mail_Control_Slip__c> mailSlips = [select Id, Participant__c, Participant__r.Local_Partner__c, Participant__r.National_Office__c, 
                                                Participant__r.National_Office__r.Participant_Contact_Owner__c,
                                                Participant__r.Local_Partner__r.Participant_Contact_Owner__c, DFC_Opportunity__c 
                                                from Mail_Control_Slip__c 
                                                where Id in :newMap.keySet()];
        
        //Traversing through the mailSlip records and checking if the opportunity owner exists or not
        for(Mail_Control_Slip__c mailSlip : mailSlips){
            if(mailSlip.DFC_Opportunity__c != null ){
                if(mailSlip.Participant__c != null && mailSlip.Participant__r.Local_Partner__c !=null 
                    && mailSlip.Participant__r.Local_Partner__r.Participant_Contact_Owner__c !=null ){
                    oppList.add(mailSlip.DFC_Opportunity__c);
                    OppToOwnerMap.put(mailSlip.DFC_Opportunity__c, mailSlip.Participant__r.Local_Partner__r.Participant_Contact_Owner__c);
                } else if(mailSlip.Participant__c !=null && mailSlip.Participant__r.National_Office__c !=null 
                            && mailSlip.Participant__r.National_Office__r.Participant_Contact_Owner__c != null){
                    oppList.add(mailSlip.DFC_Opportunity__c);
                    OppToOwnerMap.put(mailSlip.DFC_Opportunity__c, mailSlip.Participant__r.National_Office__r.Participant_Contact_Owner__c);
                }
            }
        }
        
        // Checking if the Elligible Opportunity List is empty or not
        if(!oppList.isEmpty()){
            List<Opportunity> opportunityList = [Select Id , OwnerId from Opportunity where Id in :oppList];
            for(Opportunity opp : opportunityList){
                if(OppToOwnerMap.containsKey(opp.Id)){
                    opp.OwnerId = OppToOwnerMap.get(opp.Id);
                }
            }
            // updating opportunity list
            System.debug('----------------elligible Opps');
            System.debug('----------------'+opportunityList);
            update opportunityList;
        }
        
    }*/
    
    /**
     *  @Method      : updateMCSOwner
     *  @Param       : List<Mail_Control_Slip__c>
     *  @description : Method for updating the owner of Mail Control Slip.
     *  @return      : None
     */
    private void updateMCSOwner(List<Mail_Control_Slip__c> MCSList){
        List<Mail_Control_Slip__c> filteredListMCS = new List<Mail_Control_Slip__c>();
        Set<Id> participantIds = new Set<Id>();
        Set<Id> localPartnerNationalOfficeIds = new Set<Id>();
        Map<Id,Contact> participantToLocalPartnerMap = new Map<Id,Contact>();
        Map<Id,Contact> participantToNationalOfficeMap = new Map<Id,Contact>();
        Map<Id, Account> localPartnerNationalOfficeMap = new Map<Id, Account>();
        
        // Filtering the MailControlSlip records during insertion OR updation 

        for(Mail_Control_Slip__c mcs : MCSList){
            filteredListMCS.add(mcs);
            if(mcs.Participant__c != null)
                participantIds.add(mcs.Participant__c);
        }
        
        // Fetching the Local Partner and National Office of the Participant of Mail Control Slip
        if(participantIds.size() > 0){
            List<Contact> participantList =[SELECT Id, Local_Partner__c, National_Office__c 
                                            FROM Contact WHERE id IN :participantIds
                                            ];
            for(Contact con : participantList){
                // Adding the Local Partner Id to a Set and mapping Participant id to corresponding Participant record in participantToLocalPartnerMap map
                if(con.Local_Partner__c != null){
                    localPartnerNationalOfficeIds.add(con.Local_Partner__c);
                    participantToLocalPartnerMap.put(con.id, con);
                }
                // Adding the Nation Office Id to a Set and mapping Participant id to corresponding Participant record in participantToNationalOfficeMap map
                if(con.National_Office__c != null){
                    localPartnerNationalOfficeIds.add(con.National_Office__c);
                    participantToNationalOfficeMap.put(con.id, con);
                }
            }
        }
        else 
            return;

        if(localPartnerNationalOfficeIds.size() > 0){
            localPartnerNationalOfficeMap = new Map<Id, Account>([SELECT Id, Participant_Contact_Owner__c FROM Account WHERE id IN :localPartnerNationalOfficeIds]);
        }
        
        // Business Logic to update the owner of the Mail Control Slip record
        for(Mail_Control_Slip__c mcs: filteredListMCS){
            if(participantToLocalPartnerMap.containsKey(mcs.Participant__c) && participantToLocalPartnerMap.get(mcs.Participant__c) != null 
                   && localPartnerNationalOfficeMap.containsKey(participantToLocalPartnerMap.get(mcs.Participant__c).Local_Partner__c) 
                   && localPartnerNationalOfficeMap.get(participantToLocalPartnerMap.get(mcs.Participant__c).Local_Partner__c) != null
                   && localPartnerNationalOfficeMap.get(participantToLocalPartnerMap.get(mcs.Participant__c).Local_Partner__c).Participant_Contact_Owner__c != null){
                    mcs.ownerid = localPartnerNationalOfficeMap.get(participantToLocalPartnerMap.get(mcs.Participant__c).Local_Partner__c).Participant_Contact_Owner__c;
            }
            else if(participantToNationalOfficeMap.containsKey(mcs.Participant__c) && participantToNationalOfficeMap.get(mcs.Participant__c) != null 
                    && localPartnerNationalOfficeMap.containsKey(participantToNationalOfficeMap.get(mcs.Participant__c).National_Office__c) 
                    && localPartnerNationalOfficeMap.get(participantToNationalOfficeMap.get(mcs.Participant__c).National_Office__c) != null
                    && localPartnerNationalOfficeMap.get(participantToNationalOfficeMap.get(mcs.Participant__c).National_Office__c).Participant_Contact_Owner__c != null){
                    mcs.ownerid = localPartnerNationalOfficeMap.get(participantToNationalOfficeMap.get(mcs.Participant__c).National_Office__c).Participant_Contact_Owner__c;
            }
        }
            
    }
    //Added by Ravi Chauhan on 04/July/2016 for T-514023.  <<START>>
}