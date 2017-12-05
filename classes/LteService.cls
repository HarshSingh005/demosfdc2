/***********************************************************************************************************
 * Appirio, Inc
 * Name         : LookupService
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : LteService web service for LTE integration
 * Created Date : 03/16/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/16/2016                   Karl Houseknecht        Created
 * 07/14/2016                   Karl Houseknecht        Added GetNewMcsID, Modified GetMcsDetailByID to return
 * 														sponsorship language preference
 **********************************************************************************************************/
global class LteService 
{
    //retrieves details of an MCS record
    //@param McsSlipId - the MCS record autonumber id
    //@return McsDetailInfo - details of the MCS record
	webservice static McsDetailInfo GetMcsDetailByID(string McsSlipId)
    {
        McsDetailInfo info = new McsDetailInfo();
        string slipId = McsSlipId.leftPad(10).replaceAll(' ','0');
        try
        {
            Mail_Control_Slip__c slip = [select id,
                                         name,
                                         Donor__c,
                                         Participant__c,
                                         Participant__r.National_Office_Number__c,
                                         MCS_Letter_Code__c,
                                         MCS_Letter_Type__c,
                                         NO_Lookup__r.Name,
                                         Donor_Number__c,
                                         Child_Number1__c,
                                         Donor_Name__c,
                                         Participant_Name__c,
                                         Donor__r.Email,
                                         Due_Date__c,
                                         Participant__r.Local_Partner__r.Local_Partner_ID__c,
                                         LP_Lookup__r.Name,
                                         Community_ID__c,
                                         MCS_Status__c,
                                         Case_Nbr__c,
                                         Gender__c,
                                         Village__c,
                                         Sponsor_Country__c,
                                         DFC_Number__c,
                                         DFC_Amount__c,
                                         DFC_Message__c,
                                         Birthdate__c,
                                         Donor__r.Alliance_ID__c,
                                         CreatedDate
                                        from Mail_Control_Slip__c
                                        where name = :slipId limit 1];
            
            if(slip.Participant__r.National_Office_Number__c != null)
            	info.NoId = integer.valueOf(slip.Participant__r.National_Office_Number__c);
            
            info.McsSlip = integer.valueOf(slip.Name);
            
            if(slip.MCS_Letter_Code__c != null)
            	info.LetterTypeId = integer.valueOf(slip.MCS_Letter_Code__c);
            
            info.LetterTypeName = slip.MCS_Letter_Type__c;
            info.NationalOfficeName = slip.NO_Lookup__r.Name;
            
            if(slip.Donor_Number__c != null)
            	info.ContactId = integer.valueOf(slip.Donor_Number__c);
            
            if(slip.Child_Number1__c != null)
            	info.ChildNbr = integer.valueOf(slip.Child_Number1__c);
            
            info.ContactName = slip.Donor_Name__c;
            info.ChildName = slip.Participant_Name__c;
            info.ContactEmail = slip.Donor__r.Email;
            info.RequestDate = slip.CreatedDate.format();
            
            if(slip.Due_Date__c != null)
            	info.DueDate = slip.Due_Date__c.format();
            
            if(slip.Donor__r.Alliance_ID__c != null)
            	info.IaId = integer.valueOf(slip.Donor__r.Alliance_ID__c); 
            
            info.PartnerName = slip.LP_Lookup__r.Name;
            
            if(slip.Community_ID__c != null)
            	info.ProjId = integer.valueOf(slip.Community_ID__c);
            
            info.McsStatus = slip.MCS_Status__c;
            
            if(slip.Case_Nbr__c != null)
            	info.CaseNbr = integer.valueOf(slip.Case_Nbr__c);
            
            info.Gender = slip.Gender__c;
            //info.VillageId = ?
            info.VillageName = slip.Village__c;
            info.ContactCountry = slip.Sponsor_Country__c;
            
            if(slip.DFC_Number__c != null)
            	info.DfId = integer.valueOf(slip.DFC_Number__c);
            
            if(slip.DFC_Amount__c != null)
            	info.DfAmount = double.valueOf(slip.DFC_Amount__c);
            
            info.DfAddlMsg = slip.DFC_Message__c;
            //info.McsCategory
            //info.McsCategoryDesc
            //info.McsAddlMessage
            
            if(slip.Birthdate__c != null)
            	info.BirthDate = slip.Birthdate__c.format();
            
            //get the preferred language from the sponsorship, if one exists
            if(slip.Participant__c != null && slip.Donor__c != null)
            {
                List<Opportunity> opps = [select id, Preferred_Language__c
                                         from Opportunity
                                         where rC_Giving__Primary_Contact__c = :slip.Donor__c
                                         and Participant__c = :slip.Participant__c
                                         and RecordType.Name = 'Donation'
                                         and Product_Type__c = 'Sponsorship'
                                         and Product_Sub_Type__c = 'Child Sponsorship'
                                         and rC_Sponsorship__Sponsorship_Status__c = 'Active'
                                         limit 1];
                
                if(opps.size() == 1)
                {
                    info.PreferredLanguage = opps[0].Preferred_Language__c;
                }
            }
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LteService','GetMcsDetailByID','Exception');
            log.logException(ex);
            log.saveLogs();
            info.ErrorCode = 1; 
            info.ErrorMessage = ex.getMessage(); 
        }
        return info;
    }
    
    //closes an MCS record by setting status to Closed
    //and date closed to today
    //@param McsSlipId - the MCS record autonumber id
    //@return boolean - true on success, false on exception
    webservice static boolean CloseMcs(string McsSlipId)
    {
        try
        {
            string slipId = McsSlipId.leftPad(10).replaceAll(' ','0');
            Mail_Control_Slip__c slip = [select id,
                                        MCS_Status__c,
                                        Date_Closed__c
                                        from Mail_Control_Slip__c
                                        where name = :slipId
                                        and MCS_Status__c = 'Active' limit 1];
            
            slip.MCS_Status__c = 'Closed';
            slip.Date_Closed__c = date.today();
            update slip;
            
            return true;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LteService','CloseMcs','Exception');
            log.logException(ex);
            log.saveLogs();
            return false;
        }
    }
    
    //Creates an MCS record
    //@param type - enum of letter type
    //@param ChildNumber - the child number for this letter
    //@return McsDetailInfo - information about the created slip
    webservice static McsDetailInfo CreateMcs(Enums.McsLetterType type, Integer ChildNumber)
    {
        McsDetailInfo info;
        
        try
        {
            string childNum = string.valueOf(ChildNumber);
            Contact child = [select id
                            from Contact
                            where Contact_Number__c = :childNum
                            limit 1];
            
            
            Mail_Control_Slip__c slip = new Mail_Control_Slip__c();
            slip.Participant__c = child.id;
            slip.MCS_Status__c = 'Active';
            
            if(type == enums.MCSLetterType.ChildWelcome)
                slip.MCS_Letter_Type__c = 'Child Welcome Letter';
            else if(type == enums.MCSLetterType.ChildBonding)
                slip.MCS_Letter_Type__c = 'Child Bonding Letter';
            else if(type == enums.MCSLetterType.ThankYou)
                slip.MCS_Letter_Type__c = 'Thank You Letter for DF';
            else if(type == enums.MCSLetterType.Sponsor)
                slip.MCS_Letter_Type__c = 'Sponsor Letter';
            else if(type == enums.MCSLetterType.ChildReply)
                slip.MCS_Letter_Type__c = 'Child Reply Letter';
            else if(type == enums.MCSLetterType.ChildInitiated)
                slip.MCS_Letter_Type__c = 'Child Initiated Letter';
            else if(type == enums.MCSLetterType.ChildProgress)
                slip.MCS_Letter_Type__c = 'Child Progress Report';
            else if(type == enums.MCSLetterType.NationalDirectorWelcome)
                slip.MCS_Letter_Type__c = 'National Director Welcome Letter';
            else if(type == enums.MCSLetterType.SubShiftNationalDirectorWelcome)
                slip.MCS_Letter_Type__c = 'Sub/Shift National Director Welcome Letter';
            else if(type == enums.MCSLetterType.ChildSpontaneous)
                slip.MCS_Letter_Type__c = 'Child Spontaneous Letter';
            else if(type == enums.MCSLetterType.ChildFarewell)
                slip.MCS_Letter_Type__c = 'Child Farewell Letter';

            insert slip;
            
            
            slip = [select id, 
                    name 
                    from Mail_Control_Slip__c 
                    where id = :slip.id limit 1];
                    
            
            info = GetMcsDetailByID(slip.name);
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LteService','CreateMcs','Exception');
            log.logException(ex);
            log.saveLogs();
            info = new McsDetailInfo();
            info.ErrorCode = 1; //TODO: get actual code
            info.ErrorMessage = ex.getMessage(); //TODO: get actual message
        }
        
        return info;
    }
    
    //send an email notification when a child sends a letter to the donor
    //@McsSlipId - the id of the MCS slip associated with this letter
    webservice static void SendChildLetterNotificationEmail(string McsSlipId)
    {
        try
        {
            string slipId = McsSlipId.leftPad(10).replaceAll(' ','0');
            Mail_Control_Slip__c slip = [select id,
                                       	donor__c,
                                        donor__r.US_Donor__c, 
                                        participant__c,
                                        MCS_Letter_Type__c,
                                        MCS_Status__c, 
                                        Send_Your_Child_Sent_You_A_Letter_Email__c 
                                         from Mail_Control_Slip__c
                                         where name = :slipId limit 1];
            
            //find sponsorship opportunity where the donor is primary contact
            //and the child is the participant and the sponsorship is active
            
            Opportunity opp = [select id, Electronic_Correspondence_Opt_In__c 
                              from Opportunity
                              where rC_Giving__Primary_Contact__c = :slip.Donor__c
                              and Participant__c = :slip.Participant__c
                              and rC_Sponsorship__Sponsorship_Status__c = 'Active'];
                              

            if(opp.Electronic_Correspondence_Opt_In__c  && 
              (slip.MCS_Letter_Type__c == 'Child Reply Letter' || slip.MCS_Letter_Type__c == 'Child Initiated Letter' || slip.MCS_Letter_Type__c == 'Child Spontaneous Letter') &&
              slip.MCS_Status__c == 'Active' &&
              slip.Donor__c != null &&
              slip.Participant__c != null &&
              slip.donor__r.US_Donor__c)
            {
				slip.Send_Your_Child_Sent_You_A_Letter_Email__c = true;
                update slip; //updating the slip kicks off workflow to send email and uncheck the above field
            }
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            system.debug('-----Exception----' + ex);
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LteService','SendChildLetterNotificationEmail','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
    }
    
    //Gets the new MCS Id (autonumber field) given the legacy id
    //@param legacyExternalId - the legacy MCS Id
    //@return integer - the autonumber field converted to integer
    webservice static integer GetNewMcsID(string legacyExternalId)
    {
        integer mcsId;
        
        try
        {
            Mail_Control_Slip__c slip = [select id, name
                                        from Mail_Control_Slip__c
                                        where Legacy_External_ID__c = :legacyExternalId
                                        limit 1];
            
            mcsId = integer.valueOf(slip.name);
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LteService','GetNewMcsID','Exception');
            log.logException(ex);
            log.saveLogs();
            mcsId = 0;
        }
        
        return mcsId;
    }
}