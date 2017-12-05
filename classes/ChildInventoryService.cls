/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ChildInventoryService
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Child Inventory web service for Childfund.org website
 * Created Date : 02/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/08/2016                   Karl Houseknecht        Created
 * 03/01/2016					Karl Houseknecht		Updated logic for web pool maintenance
 **********************************************************************************************************/
global class ChildInventoryService
{
	//Returns a list of children to the website search
	//@param filter - a class containing search filter critera
	//@return - a List of WebChildInfo objects containing Available children to sponsor
    webservice static List<WebChildInfo> GetKidsForWeb(ChildFilter filter)
    {
        List<WebChildInfo> infoList = new List<WebChildInfo>();
        
        try
        {
        	infoList = GetKidsForWebInternal(filter);

            if(infoList.size() == 0)
            {
                ChildFilter emptyFilter = new ChildFilter();
                emptyFilter.CountryCode = 0;
                emptyFilter.KidsReturned = 1;
                emptyFilter.NoId = 0;
                emptyFilter.ProjectId = 0;
                emptyFilter.FromAge = 0;
                emptyFilter.ToAge = 12;

                infoList = GetKidsForWebInternal(emptyFilter);
            }
        }
        catch(Exception ex)
        {
        	//log exception to the apex logger
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('ChildInventoryService','GetKidsForWeb','Exception');
            log.logException(ex);
            log.saveLogs(); 
            //throw ex;
        }
        
        return infoList;
    }

    //Internal method so logic can be called again if no results on a more restrictive filter
    //@param filter - a class containing search filter critera
    //@return - a List of WebChildInfo objects containing Available children to sponsor
    private static List<WebChildInfo> GetKidsForWebInternal(ChildFilter filter)
    {
        List<WebChildInfo> infoList = new List<WebChildInfo>();
        
        try
        {
            // fields created to use in query as variables.
            String birthDay;
            String birthMonth;
            String projectId;
            Integer toAge;
            Integer fromAge;

            Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
            
            //get the date thirteen years ago because we shouldn't be querying children older than 12
            date thirteenYearsAgo = date.today().addYears(-13);

            string query = 'select id, National_Office__c, Child_Number__c, Short_Name__c, ' +
                'Community_Number__c, rC_Sponsorship__Sponsorship_Status__c, ' +
                'rC_Bios__Gender__c, rC_Bios__Age__c, Description, National_Office_Number__c, ' +
                'rC_Bios__Birth_Day__c, rC_Bios__Birth_Month__c, rC_Bios__Birth_Year__c, ' +
                'National_Office__r.NO_Country__c, Enterprise_Legacy_Id__c, ' +
                'National_Office__r.Male_0_2__c, National_Office__r.Male_3_5__c, National_Office__r.Male_6_8__c, ' +
                'National_Office__r.Male_9_10__c, National_Office__r.Male_11_12__c, ' +
                'National_Office__r.Female_0_2__c, National_Office__r.Female_3_5__c, National_Office__r.Female_6_8__c, ' +
                'National_Office__r.Female_9_10__c, National_Office__r.Female_11_12__c, ' +
                'National_Office__r.Web_Threshold__c, National_Office__r.Used_On_Web__c, Community__r.Used_On_Web__c, rC_Sponsorship__Narrative__c ' +
                'FROM contact WHERE recordtypeid = :participantRecordTypeId ' +
                'AND National_Office__r.Used_On_Web__c = true ' +
                'AND Local_Partner__r.Used_On_Web__c = true ' +
                'AND Community__r.Used_On_Web__c = true ' +
                'AND National_Office__r.rC_Bios__Active__c = true ' +
                'AND Local_Partner__r.rC_Bios__Active__c = true ' +
                'AND Community__r.rC_Bios__Active__c = true ' +
                'AND National_Office__r.Web_Threshold_OK__c = true ' +
                'AND Local_Partner__r.Web_Threshold_OK__c = true ' +
                'AND Community__r.Web_Threshold_OK__c = true ' +
                'AND rC_Sponsorship__Reserve__c = null ' +
                'AND rC_Sponsorship__Sponsorship_Status__c = \'Available\' ' +
                'AND BirthDate > :thirteenYearsAgo';
                
            
            //replace with numeric countrycode lookup from custom setting
            //the custom setting key is the numeric country code
            //description is the country name, which will match National Office Account.NO_Country__c
            if(filter.CountryCode != null && filter.CountryCode != 0)
            {
                string countryCode = string.valueOf(filter.CountryCode).leftPad(3).replaceAll(' ','0');
                CountriesRefCodes__c countryRefCode = 
                    CountriesRefCodes__c.getValues(string.valueOf(countryCode));
                                               
                if(countryRefCode != null)
                {
                    string noCountry = countryRefCode.Description__c;
                    query += ' AND (National_Office__r.NO_Country__c = :noCountry)';
                }
                                                     
            }
            else
            {
                //if no countrycode is specified, select a random country with children
                //so that a selective index on country can be applied to the query
                List<AggregateResult> countriesWithKids = [select Parent.Parent.NO_Country__c country
                                                        from Account where Used_On_Web__c = true and parent.Used_On_Web__c = true and 
                                                        parent.parent.Used_On_Web__c = true and rC_Bios__Active__c = true and 
                                                        parent.rC_Bios__Active__c = true and parent.parent.rC_Bios__Active__c = true and 
                                                        Web_Threshold_OK__c = true and parent.Web_Threshold_OK__c = true and 
                                                        parent.parent.Web_Threshold_OK__c = true and 
                                                        recordtype.name = 'Community' and PC_Available__c > 0 
                                                        group by Parent.Parent.NO_Country__c];

                Double countryRandom = math.random() * countriesWithKids.size();
                string countryName = string.valueOf(countriesWithKids[countryRandom.intValue()].get('country'));
                system.debug('*** countryName = ' + countryName);
                query += ' AND (National_Office__r.NO_Country__c = :countryName)';
            }
            
            if(string.isNotBlank(filter.Birthday) && string.isNotBlank(filter.BirthMonth)) 
            {
                birthDay = filter.Birthday;
                birthMonth = filter.BirthMonth;
                query += ' AND (rC_Bios__Birth_Day__c = :birthDay AND rC_Bios__Birth_Month__c = :birthMonth)';
            }
            
            if(filter.ProjectId != null && filter.ProjectId != 0)
            {
                projectId = String.valueOf(filter.ProjectId);
                query += ' AND (Community_Number__c = :projectId)';
            }
            
            if(filter.ToAge != null && filter.ToAge !=0)
            {
                date dateToAge = date.today().addYears(-filter.ToAge - 1);
                date dateFromAge = date.today().addYears(-filter.FromAge);

                //query += ' AND ((rC_Bios__Age__c <= :filter.ToAge) AND (rC_Bios__Age__c >= :filter.FromAge))';
                query += ' AND ((BirthDate > :dateToAge) AND (BirthDate <= :dateFromAge))';
            }
            
            if(string.isNotBlank(filter.Gender))
            {
                string gender;
                if (filter.Gender == '' || filter.Gender == 'M')
                    gender = 'Male';
                else if (filter.Gender == 'F')
                    gender = 'Female';
                
                query += ' AND rC_Bios__Gender__c = :gender';
            }
            
            if(filter.KidsReturned == null || filter.KidsReturned == 0) 
                filter.KidsReturned = 5; //TODO: make into custom setting
                
            integer limitVar = filter.KidsReturned;
            
            //query += ' LIMIT ' + string.valueOf(limitVar);
            query += ' LIMIT 1000 ';
            system.debug('===>query' +query);
            //List<Contact> kids = database.query(query);
            
            for(Contact kid : database.query(query))
            {
                if(ChildInventoryService.IsChildAvailableForWeb(kid))
                {
                    WebChildInfo info = new WebChildInfo();
                    info.noid = integer.valueOf(kid.National_Office_Number__c);
                    info.childnbr = integer.valueOf(kid.Child_Number__c);
                    info.shortname = kid.Short_Name__c;
                    info.projid = integer.valueOf(kid.Community_Number__c);
                    

                    List<ChildStatusRefCodes__c> statusCodes = ChildStatusRefCodes__c.getAll().values();
                    for(ChildStatusRefCodes__c code : statusCodes)
                        if(kid.rC_Sponsorship__Sponsorship_Status__c.toLowerCase() == code.Description__c.toLowerCase())
                            info.chstaid = integer.valueOf(code.Name); 
                    
                    //translate to M or F or U
                    string gender;
                    if(kid.rC_Bios__Gender__c == 'Male')
                        gender = 'M';
                    else if(kid.rC_Bios__Gender__c == 'Female')
                        gender = 'F';
                    else
                        gender = '';
                    
                    info.gender = gender;
                    
                    info.age = integer.valueof(kid.rC_Bios__Age__c);
                    info.cifinfo = kid.rC_Sponsorship__Narrative__c;
                    
                    if(kid.National_Office__r.Used_On_Web__c)
                        info.NatOfficeUsed = 'Y';
                    else
                        info.NatOfficeUsed = 'N';
                    
                    info.NatOfficeThreshold = integer.valueof(kid.National_Office__r.Web_Threshold__c);
                    info.ChildUsed = ChildInventoryService.IsChildUsed(kid);
                    
                    if(kid.Community__r.Used_On_Web__c)
                        info.ProjectUsed = 'Y';
                    else
                        info.ProjectUsed = 'N';
                    
                    info.DOB = string.valueOf(kid.rC_Bios__Birth_Month__c) + '/' +
                        string.valueOf(kid.rC_Bios__Birth_Day__c) + '/' +
                        string.valueOf(kid.rC_Bios__Birth_Year__c);
                    
                    info.CountryName = kid.National_Office__r.NO_Country__c;
                    info.MonthlySponsorship = 33; //TODO: query for default campaign product amount
                    info.EnterpriseLegacyId = kid.Enterprise_Legacy_Id__c;
                    
                    infolist.add(info);
                }

                if(infoList.size() == limitVar)
                    break;
            }
            
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('ChildInventoryService','GetKidsForWeb','Exception');
            log.logException(ex);
            log.saveLogs(); 
            //throw ex;
        }
        
        return infoList;
    }
    
    //Determines the value for the ChildUsed field of WebChildInfo
    //@param Contact kid - a Contact representing a child
    //@return - string literal 'Y' or 'N'
    private static string IsChildUsed(Contact kid)
    {
        if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 0 && kid.rC_Bios__Age__c <= 2)
            return (kid.National_Office__r.Male_0_2__c ? 'Y' : 'N');
        else if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 3 && kid.rC_Bios__Age__c <= 5)
            return (kid.National_Office__r.Male_3_5__c ? 'Y' : 'N');       
        else if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 6 && kid.rC_Bios__Age__c <= 8)
            return (kid.National_Office__r.Male_6_8__c ? 'Y' : 'N');
        else if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 9 && kid.rC_Bios__Age__c <= 10)
            return (kid.National_Office__r.Male_9_10__c ? 'Y' : 'N'); 
        else if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 11 && kid.rC_Bios__Age__c <= 12)
            return (kid.National_Office__r.Male_11_12__c ? 'Y' : 'N');
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 0 && kid.rC_Bios__Age__c <= 2)
            return (kid.National_Office__r.Female_0_2__c ? 'Y' : 'N');
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 3 && kid.rC_Bios__Age__c <= 5)
            return (kid.National_Office__r.Female_3_5__c ? 'Y' : 'N');
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 6 && kid.rC_Bios__Age__c <= 8)
            return (kid.National_Office__r.Female_6_8__c ? 'Y' : 'N');
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 9 && kid.rC_Bios__Age__c <= 10)
            return (kid.National_Office__r.Female_9_10__c ? 'Y' : 'N'); 
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 11 && kid.rC_Bios__Age__c <= 12)
            return (kid.National_Office__r.Female_11_12__c ? 'Y' : 'N');
        else
            return 'N';
    }
    
    //Determines if a child is available for a web search based on age and gender
	//@param Contact kid - a Contact representing a child
	//@return - boolean
    
    private static boolean IsChildAvailableForWeb(Contact kid)
    {
        if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 0 && kid.rC_Bios__Age__c <= 2 && kid.National_Office__r.Male_0_2__c)
            return true;
        else if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 3 && kid.rC_Bios__Age__c <= 5 && kid.National_Office__r.Male_3_5__c)
            return true;        
        else if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 6 && kid.rC_Bios__Age__c <= 8 && kid.National_Office__r.Male_6_8__c)
            return true;
        else if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 9 && kid.rC_Bios__Age__c <= 10 && kid.National_Office__r.Male_9_10__c)
            return true; 
        else if(kid.rC_Bios__Gender__c == 'Male' && kid.rC_Bios__Age__c >= 11 && kid.rC_Bios__Age__c <= 12 && kid.National_Office__r.Male_11_12__c)
            return true;
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 0 && kid.rC_Bios__Age__c <= 2 && kid.National_Office__r.Female_0_2__c)
            return true;
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 3 && kid.rC_Bios__Age__c <= 5 && kid.National_Office__r.Female_3_5__c)
            return true;
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 6 && kid.rC_Bios__Age__c <= 8 && kid.National_Office__r.Female_6_8__c)
            return true;
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 9 && kid.rC_Bios__Age__c <= 10 && kid.National_Office__r.Female_9_10__c)
            return true;
        else if(kid.rC_Bios__Gender__c == 'Female' && kid.rC_Bios__Age__c >= 11 && kid.rC_Bios__Age__c <= 12 && kid.National_Office__r.Female_11_12__c)
            return true;
        else
            return false;
    }
    
    
    //Locks a child when the website user places them in their shopping cart for sponsorship
    //so that nobody else can sponsor them while in cart.
    //Lock expires at end of day via nightly batch job.
	//@param integer noid - the national office number for the child
	//@param integer childnum - the unique child number for the child
	//@return - integer: 1 for success, 0 for failure
    webservice static integer LockChild(integer noid, integer childnum)
    {
        try
        {
            Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
            
            string nationalOfficeId = string.valueOf(noid);
            string childNumber = string.valueOf(childnum);
            
            Contact child = [select id, 
                            rC_Sponsorship__Sponsorship_Status__c, 
                            rC_Sponsorship__Reserve__c
                            from Contact
                            where recordtypeid = :participantRecordTypeId
                            and National_Office_Number__c = :nationalOfficeId
                            and Contact_Number__c = :childNumber
                            and rC_Sponsorship__Sponsorship_Status__c = 'Available'
                            and rC_Sponsorship__Reserve__c = null
                            LIMIT 1];
            
            if(child == null)
            	return 0;
            else
            {
                //search for the current reserve record
                List<rC_Sponsorship__Reserve__c> lstReserve = [select id 
                                                      from rC_Sponsorship__Reserve__c
                                                      where name = 'Website Shopping Cart Reserve'
                                                      AND rC_Sponsorship__Start_Date__c = :date.today()
                                                      AND rC_Sponsorship__Expiration_Date__c = :date.today()
                                                      AND rC_Sponsorship__Status__c = 'Active'
                                                      LIMIT 1];
                
                //if not found, create current reserve record
                rC_Sponsorship__Reserve__c reserve;
                if(lstReserve.size() > 0) {
                    reserve = lstReserve[0];
                } else {
                    reserve = new rC_Sponsorship__Reserve__c();
                    reserve.Name = 'Website Shopping Cart Reserve';
                    reserve.rC_Sponsorship__Start_Date__c = date.today();
                    reserve.rC_Sponsorship__Expiration_Date__c = date.today();
                    reserve.rC_Sponsorship__Status__c = 'Active';
                    
                    insert reserve;
                }
                //update the child's reserve record.  This sets the sponsorship status to reserved
                //a nightly batch clears out the reserves: Reserve_CloseReserveSchedulable
                child.rC_Sponsorship__Reserve__c = reserve.Id;
                Database.SaveResult result = Database.update(child);
                if(result.isSuccess())
                	return 1;
                else
                    return 0;
            }
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('ChildInventoryService','LockChild','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;
        }
        
    }
    
    //Unlocks a child when the website user removes from cart via sponsorship or removal
	//@param integer noid - the national office number for the child
	//@param integer childnum - the unique child number for the child
	//@return - integer: 1 for success, 0 for failure
    webservice static integer UnLockChild(integer noid, integer childnum)
    {
        //find a child by noid and childnum that has as reserve record
        //clear out the reserve record field and update
        //return success if new status is now Available
        try
        {
            Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
            
            string nationalOfficeId = string.valueOf(noid);
            string childNumber = string.valueOf(childnum);
            System.debug('[RB] - ChildInventoryDB.UnLockChild :: participantRecordTypeId => ' + participantRecordTypeId + '; nationalOfficeId => ' + nationalOfficeId + '; childNumber => ' + childNumber);
            List<Contact> lstChild = [select id, 
                            rC_Sponsorship__Sponsorship_Status__c, 
                            rC_Sponsorship__Reserve__c
                            from Contact 
                            where recordtypeid = :participantRecordTypeId 
                            and National_Office_Number__c = :nationalOfficeId 
                            and Contact_Number__c = :childNumber 
                            and rC_Sponsorship__Sponsorship_Status__c = 'Reserved' 
                            and rC_Sponsorship__Reserve__c != null 
                            and rC_Sponsorship__Reserve__r.Name = 'Website Shopping Cart Reserve'];
            System.debug('[RB] - ChildInventoryDB.UnLockChild :: lstChild => ' + lstChild);
            //if the child is found clear out the reserve record
            //this will set the sponsorship status automatically to the appropriate status
            //must check to see if the resulting status is "Available" for the unlock to be 
            //considered successful
            if(lstChild.size() > 0) {
                Contact child = lstChild[0];
                child.rC_Sponsorship__Reserve__c = null;
                Database.SaveResult result = Database.update(child);
                if(!result.isSuccess())
                    return 0;
                else
                {
                    child = [select id, 
                             rC_Sponsorship__Sponsorship_Status__c
                            from contact
                            where id = :child.Id];
                    
                    if(child.rC_Sponsorship__Sponsorship_Status__c == 'Available')
                        return 1;
                    else //some other condition made the status a non-available status
                        return 0;
                }
            } else {
                return 0;
            }
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('ChildInventoryService','UnLockChild','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;
        }
        
    }
    
    //Checks to see if a child is in a locked status
	//@param integer noid - the national office number for the child
	//@param integer childnum - the unique child number for the child
	//@return - boolean: true for locked, false if unlocked or error
    webservice static boolean IsChildLocked(integer noid, integer childnum)
    {
        try
        {
            Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
            
            string nationalOfficeId = string.valueOf(noid);
            string childNumber = string.valueOf(childnum);
            
            Contact child = [select id, 
                            rC_Sponsorship__Sponsorship_Status__c 
                            from Contact
                            where recordtypeid = :participantRecordTypeId
                            and National_Office_Number__c = :nationalOfficeId
                            and Contact_Number__c = :childNumber
                            LIMIT 1];
            
            if(child == null)
                return false;
            else
            {
                if(child.rC_Sponsorship__Sponsorship_Status__c == 'Available')
                    return false;
                else 
                    return true;
            }
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('ChildInventoryService','IsChildLocked','Exception');
            log.logException(ex);
            log.saveLogs();
            return false;
        }
        
    }
    
    //Checks to see if a child is obtainable
	//@param integer noid - the national office number for the child
	//@param integer childNbr - the unique child number for the child
	//@return - boolean: true for locked, false if unlocked or error
    webservice static boolean IsChildObtainable(integer NOID, integer childNbr)
    {
        try
        {
            Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
            
            string nationalOfficeId = string.valueOf(noid);
            string childNumber = string.valueOf(childNbr);
            
            Contact child = [select id, 
                            rC_Sponsorship__Sponsorship_Status__c 
                            from Contact
                            where recordtypeid = :participantRecordTypeId
                            and National_Office_Number__c = :nationalOfficeId
                            and Contact_Number__c = :childNumber
                            LIMIT 1];
            

            if((child.rC_Sponsorship__Sponsorship_Status__c == 'Departed') ||
               (child.rC_Sponsorship__Sponsorship_Status__c == 'Pre-Sponsored') ||
               (child.rC_Sponsorship__Sponsorship_Status__c == 'Sponsored') ||
               ((child.rC_Sponsorship__Sponsorship_Status__c == 'Unavailable') && (child.Alliance_ID__c == null)))
                return false;
            else 
                return true;
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
        	apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('ChildInventoryService','IsChildObtainable','Exception');
            log.logException(ex);
            log.saveLogs();
            return false;
        }
    }
    
    //sprint 5 - May not be needed.  Part of transaction processing
    //webservice static ChildInfo GetChildByID(integer ChildNumber, integer NationalOfficeID)
    //{
    //    return null;
    //}
    
    
    
    
}