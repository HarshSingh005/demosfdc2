/***********************************************************************************************************
 * Appirio, Inc
 * Name         : LookupService
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : LookupService web service for Childfund.org website
 * Created Date : 02/24/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/24/2016                   Karl Houseknecht        Created
 * 03/09/2016                   Jagjeet Singh           Modified
 * 09/08/2016                   Vaibhav Goel            Added code to cover exception blocks of methods where exceptions can't be thrown otherwise.
 **********************************************************************************************************/
global class LookupService 
{
    //Returns a list of refcodeinfo containing country codes and names
    //country list includes all countries minus IA countries sort alpha by name asc
    //@return - a List of RefCodeInfo
    
    @testVisible private static boolean shouldThrowException = false;
    
    webservice static List<RefCodeInfo> GetCountries()
    {
        List<RefCodeInfo> countryCodes = new List<RefCodeInfo>();
        
        try
        {
            //get all of the countries code values
            List<CountriesRefCodes__c> codesMap = CountriesRefCodes__c.getAll().values();
            Map<string,PartnerCountriesRefCodes__c> partnerCodesMap = PartnerCountriesRefCodes__c.getAll();
            
            //create a custom sorted list that sorts by description instead of name and sort the list
            List<CountriesRefCodesSortWrapper> sortList = new List<CountriesRefCodesSortWrapper>();
            
            for(CountriesRefCodes__c code : codesMap)
            {
                if(!partnerCodesMap.containsKey(code.Name))
                    sortList.add(new CountriesRefCodesSortWrapper(code));
            }
            
            sortList.sort();
            
            //add the sorted list items to the returned list
            for(CountriesRefCodesSortWrapper wrap : sortList)
            {
                RefCodeInfo info = new RefCodeInfo();
                info.rvlowvalue = wrap.CountriesRefCodes.Name;
                info.rvmeaning = wrap.CountriesRefCodes.Description__c;
                countryCodes.add(info);
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
            return countryCodes;
            
            
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetCountries','Exception');
            log.logException(ex);
            log.saveLogs();
            return countryCodes;
        }
    }
    
    //Returns country codes and names for all NO countries
    //where NO is in active status and used on web is true
    //@return List<RefCodeInfo> with 3 digit country code and description
    //looked up from country custom setting
    webservice static List<RefCodeInfo> GetWebCountries()
    {
        List<RefCodeInfo> countryCodes = new List<RefCodeInfo>();
        
        try
        {
            List<Account> noList = [select id,
                                           NO_Country__c
                                    from Account
                                    where Used_On_Web__c = true
                                    and rC_Bios__Active__c = true
                                    and recordtype.name = 'National Office'
                                    order by NO_Country__c asc];
            
            //get all of the countries code values
            Map<string,CountriesRefCodes__c> codesMap = CountriesRefCodes__c.getAll();
            
            //create a map by the country name for reverse lookup
            Map<string,CountriesRefCodes__c> codesByDescMap = new Map<string,CountriesRefCodes__c>();
            for(string key : codesMap.keySet())
            {
                CountriesRefCodes__c code = codesMap.get(key);
                codesByDescMap.put(code.Description__c, code);
            }
            
            //temporary map to exclude duplicate entries
            Map<string,RefCodeInfo> refCodeMap = new Map<string,RefCodeInfo>(); 
            for(Account no : noList)
            {
                //translate NO_Country__c to ref code
                if(codesByDescMap.containsKey(no.NO_Country__c))
                {
                    string refCode = codesByDescMap.get(no.NO_Country__c).Name;
                    if(!refCodeMap.containsKey(refCode))
                    {
                        RefCodeInfo info = new RefCodeInfo();
                        info.rvlowvalue = refCode;
                        info.rvmeaning = codesMap.get(refCode).Description__c;
                        refCodeMap.put(refCode, info);
                    }
                }
            }
            
            if(!refCodeMap.isEmpty())
                countryCodes.addAll(refCodeMap.values());
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
            return countryCodes;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetWebCountries','Exception');
            log.logException(ex);
            log.saveLogs();
            return countryCodes;
        }
    }
    
    //Gets a list of states and territories sorted alphabetically
    //@return - List of CodeInfo containing state and territory codes and descriptions
    //excluding Provinces
    webservice static List<Codeinfo> GetStates()
    {
        List<CodeInfo> stateCodes = new List<CodeInfo>();
        
        try
        {
            //get all of the countries code values
            List<StateTerrProvRefCodes__c> codesList = StateTerrProvRefCodes__c.getAll().values();
            
            //create a custom sorted list that sorts by description instead of name and sort the list
            List<StateTerrProvRefCodesSortWrapper> sortList = new List<StateTerrProvRefCodesSortWrapper>();
            
            for(StateTerrProvRefCodes__c code : codesList)
                if(code.Code_Type__c != 'PROV')
                    sortList.add(new StateTerrProvRefCodesSortWrapper(code));
            
            sortList.sort();
            
            //add the sorted list items to the returned list
            for(StateTerrProvRefCodesSortWrapper wrap : sortList)
            {
                CodeInfo info = new CodeInfo();
                info.code = wrap.StateRefCodes.Name;
                info.name = wrap.StateRefCodes.Description__c;
                stateCodes.add(info);
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
            return stateCodes;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetStates','Exception');
            log.logException(ex);
            log.saveLogs();
            return stateCodes;
        }
    }
    
    //finds a single household match
    //@param ContactInfo - the criteria to find the match
    //@return Envelope - newId (donor number), returnCode, and optional errormessage
    webservice static Envelope HouseHoldMatch(ContactInfo info)
    {
        Envelope returnValue = new Envelope();
        
        try
        {
            string state;
            string country;
            string salutation;
            boolean isFirstNameMatch = false;
            boolean isLastNameMatch = false;
            boolean isAddressMatch = false;
            
            Id householdRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            
            //TODO: suffix has no corresponding picklist implementation in NGOC or SFDC
            //Not including in code for now
            
            if(info.cdesstatprovterrid != null)
            {
                state = GetStateAbbreviationFromCode(info.cdesstatprovterrid);
            }
            
            if(info.ctrycode != null)
            {
                country = GetCountryAbbreviationFromCode(integer.valueOf(info.ctrycode));
            }
                        
            //create a hash of address for comparison

            //because NGOC will not store address fields as empty strings
            //we must compare nulls to nulls
            string street2;
            if(string.isNotBlank(info.street2))
                street2 = info.street2;

            string hashedInfoAddress = 
                LookupService.HashAddress(info.street1, street2, info.city, state, info.postalcode, country);

            if(info.clstnmtitleid != null && info.clstnmtitleid != 0)
            {
                WebTitlesRefCodes__c refCode = 
                    WebTitlesRefCodes__c.getValues(string.valueOf(info.clstnmtitleid));
                
                if(refCode != null)
                    salutation = refCode.Description__c;
            }
            
            List<Contact> householdList = null;
            
            //query by contact number first
            if(info.id != null && info.id != 0)
            {
                string donorNumber = string.valueOf(info.id);
                
                householdList = [select id,
                                 Contact_Number__c,
                                 firstname,
                                 lastname,
                                 rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c,
                                 rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_2__c,
                                 rC_Bios__Preferred_Mailing_Address__r.rC_Bios__City__c,
                                 rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Postal_Code__c,
                                 rC_Bios__Preferred_Mailing_Address__r.rC_Bios__State__c,
                                 rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c
                                 from Contact
                                 where Contact_Number__c = :donorNumber];
                
                //[jagjeet: Changed the Operator to '&&', ]
                if(householdList != null && !householdList.isEmpty())
                {
                    
                    Contact household = householdList[0];
                    returnValue.NewID = integer.valueOf(household.Contact_Number__c);
                    
                    //create a hash of returned address for comparison
                    string hashedFoundAddress = 
                        LookupService.HashAddress(household.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c,
                                                  household.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_2__c,
                                                  household.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__City__c, 
                                                  Household.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__State__c, 
                                                  household.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Postal_Code__c, 
                                                  household.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c);
                    
                    if(hashedFoundAddress == hashedInfoAddress)
                        isAddressMatch = true;
                    
                    string firstname;
                    if(string.IsNotBlank(info.firstname))
                        firstname = info.firstname;

                    if(household.FirstName == firstname)
                        isFirstNameMatch = true;
                    
                    if(household.LastName == info.name)
                        isLastNameMatch = true;
                    
                    //Contact ID matches,  the name and address does not match
                    if(!isAddressMatch && !isFirstNameMatch && !isLastNameMatch)
                    {
                        returnValue.ErrorMessage = 'There is no ES record matching the data - NO_SUCH_CONTACT';
                        returnValue.ReturnCode = 1;
                    }
                        
                    // 'Contact ID matches, first name matches, address does not match., ignore title suffix';
                    if(isFirstNameMatch && !isAddressMatch)
                    {
                        returnValue.ErrorMessage = 'Contact ID matches, first name matches, address does not match., ignore title suffix';
                        returnValue.ReturnCode = 3; 
                    }
                        
                    //5 'Contact ID matches, no first name matches, address does not match. suffix yes';
                    // TODO: not implemented because of question on suffix
                    
                    //'Match contact id, address does not match, name matches';
                    if(!isAddressMatch && isFirstNameMatch && isLastNameMatch)
                    {
                        returnValue.ErrorMessage = 'Match contact id, address does not match, name matches';
                        returnValue.ReturnCode = 7;
                    }
                        
                    // 'Match contact id, name does not match, address matches.';
                    if(!isFirstNameMatch && !isLastNameMatch && isAddressMatch)
                    {
                        returnValue.ErrorMessage = 'Match contact id, name does not match, address matches.';
                        returnValue.ReturnCode = 9;
                    }
                    
                    //'Match contact id, name does not match, address matches.';
                    //TODO: Case 11, 13, 15 is the same as 9
                    
                    //Absolute Match with Contact ID - send to user
                    if(isFirstNameMatch && isLastNameMatch && isAddressMatch)
                        returnValue.ReturnCode = 100;
                    
                }
                else
                {
                    //Contact ID not found in Salesforce - send to user
                    returnValue.ErrorMessage = 'Contact ID not found in Salesforce - send to user';
                    returnValue.ReturnCode = 106;
                }
                
            }
            else
            {
                householdList = [select id,
                             Contact_Number__c
                             from Contact
                             where firstname like :info.firstname
                                and lastname like :info.name
                                and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c like :info.street1
                                and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_2__c like :street2
                                and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__City__c like :info.city
                                and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Postal_Code__c like :info.postalcode
                                and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__State__c like :state
                                and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c like :country];
                
                if(householdList.isEmpty())
                {
                    //Contact ID not found in Salesforce - send to user
                    returnValue.ReturnCode = 0;
                    returnValue.ErrorMessage = 'There is not record matching this data';
                }
                else if(houseHoldList.size() > 1)
                {
                    returnValue.ReturnCode = 102;
                    returnValue.ErrorMessage = 'Multiple Absolute name and address matches - send to user';
                }
                else if(houseHoldList.size() == 1)
                {
                    returnValue.NewID = integer.valueOf(householdList[0].Contact_Number__c);
                    returnValue.ReturnCode = 101;
                }   
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','HouseHoldMatch','Exception');
            log.logException(ex);
            log.saveLogs();
            returnValue.ReturnMessage = Enums.ReturnMsg.Failure;
            returnValue.ErrorMessage = ex.getMessage();
            returnValue.StackTrace = ex.getStackTraceString();
        }
        
        return returnValue;
    }

    //generates a string hash value of an address for comparison purposes
    //all values are lower cased before conversion for case insensitive matching
    //this duplicates native NGOC address hash functionality
    //https://roundcorner.atlassian.net/wiki/display/roundCause/Address_UpdateUniqueMD5
    //@param street1 - the street line1
    //@param street2 - street line2
    //@param city - city portion of address
    //@param state - state portion of address - state abbreviation or name
    //@param zip - postal code
    //@param country - name or country abbreviation
    //@return - base64 string hashed value of concatenated address
    public static string HashAddress(string street1, string street2, string city, string state, string zip, string country)
    {
        if(string.isEmpty(street1))
            street1 = null;
        
        if(string.isEmpty(street2))
            street2 = null;

        if(string.isEmpty(city))
            city = null;

        if(string.isEmpty(state))
            state = null;

        if(string.isEmpty(zip))
            zip = null;

        if(string.isEmpty(country))
            country = null;

        string toHash = ':';
        toHash += street1; 
        toHash += ':';
        toHash += street2; 
        toHash += ':';
        toHash += city;
        toHash += ':';  
        toHash += state;    
        toHash += ':';    
        toHash += zip;      
        toHash += ':';
        toHash += country; 
        
        blob targetBlob = Blob.valueOf(toHash.toLowerCase());
        blob hashedBlob = Crypto.generateDigest('MD5', targetBlob);
        string hex = EncodingUtil.convertToHex(hashedBlob);   
        return hex;
    }
    
    //finds a list of household matches based on criter
    //@param Contactinfo - matching criteria
    //@return List<ContactInfo> - as list of matching households
    webservice static List<ContactInfo> HouseHoldMatchList(ContactInfo info)
    {
        List<ContactInfo> matches;
        
        try
        {
            string state;
            string country;
            string salutation;
            string firstname = info.firstname;
            string lastname = info.name;
            
            Id householdRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            
            //TODO: suffix has no corresponding picklist implementation in NGOC or SFDC
            //Not including in code for now
            
            if(info.cdesstatprovterrid != null)
            {
                StateTerrProvRefCodes__c stateRefCode = 
                    StateTerrProvRefCodes__c.getValues(string.valueOf(info.cdesstatprovterrid));
                if(stateRefCode != null)
                    state = stateRefCode.Code__c;
            }
            
            if(info.ctrycode != null)
            {
                CountriesRefCodes__c countryRefCode = 
                    CountriesRefCodes__c.getValues(string.valueOf(info.ctrycode));
                if(countryRefCode != null)
                    country = countryRefCode.Description__c;
            }
            
            if(info.clstnmtitleid != null && info.clstnmtitleid != 0)
            {
                WebTitlesRefCodes__c refCode = 
                    WebTitlesRefCodes__c.getValues(string.valueOf(info.clstnmtitleid));
                
                if(refCode != null)
                    salutation = refCode.Description__c;
            }
            
            string street1 = info.street1;
            if(string.isNotBlank(info.street2))
                street1 += '\n' + info.street2;

            string city = info.city;
            string postalcode = info.postalcode;
            //[jagjeet : Added Donor_number__c in the query field list.]
            //query using 'LIKE' keyword does case insensitive search
            string query = 'select id, firstname,Donor_Number__c from contact where recordtypeid = :householdRecordTypeId' +
                            ' AND firstname like :firstname' +
                            ' AND lastname like :lastname' +
                            ' AND mailingstreet like :street1 AND mailingcity like :city' +
                            ' AND mailingstate like :state AND mailingpostalcode like :postalcode' + 
                            ' AND mailingcountry like :country';
            
            if(string.isNotBlank(salutation))
                query += ' AND Salutation like :salutation';
            
            List<Contact> contacts = database.query(query);
            
            if(contacts != null && !contacts.isEmpty())
            {
                matches = new List<ContactInfo>();
                
                for(Contact match : contacts)
                {
                    ContactInfo contact = new ContactInfo();
                    contact.id = integer.valueOf(match.Donor_Number__c);
                    contact.firstname = match.firstname;
                    matches.add(contact);
                }
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
                
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','HouseHoldMatchList','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        if(matches == null)
            matches = new List<ContactInfo>();
        
        return matches;
    }
    
    //checks the Prank_Phone__c object to determine if a phone number exists
    //@phoneArea - area code portion of the phone number
    //@phonePortion - exchange and phone number portion of the phone number
    //@return - boolean indicating if the phone exists in the table
    webservice static boolean IsPrankPhone(string phoneArea, string phonePortion)
    {
        try
        {
            string phone = phoneArea + phonePortion;
            
            integer phoneCount = [select count()
                                 from Prank_Phone__c
                                 where Search_Phone__c = :phone];
            
            if(phoneCount > 0)
                return true;
            else
                return false;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','IsPrankPhone','Exception');
            log.logException(ex);
            log.saveLogs();
            return false;
        }
    }
    
    //For a given donor, get the number of sponsorships in a Presponsored status
    //@param ContactId - the Donor Number
    //@return - the number of sponsorships in Presponsored status
    webservice static integer GetCurrentPresponsors(integer ContactId)
    {
        try
        {
            string donorNumber = string.valueOf(ContactId);
            
            integer sponsorCount = [select count() 
                                    from opportunity 
                                    where rC_Giving__Primary_Contact__r.Contact_Number__c = :donorNumber 
                                    and Sponsorship_Status__c = 'Pre-Sponsored'
                                    and rC_Sponsorship__Sponsorship_Status__c = 'Active'];
            return sponsorCount;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetCurrentPresponsors','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;
        }
    }
    
    //Returns the org wide setting for the maximum number of pre-sponsors
    //@return - max number of pre-sponsors from a hierarchy custom setting
    webservice static integer GetMaxPresponsors()
    {
        try
        {
            SponsorshipSettings__c defaults = SponsorshipSettings__c.getOrgDefaults();
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
            return integer.valueOf(defaults.Max_Pre_Sponsors__c);
        }
        catch(Exception ex)
        {   
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetMaxPresponsors','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;
        }
    }
    
    //sprint 5
    //Gets a list of all active countries
    //@return - all active countries in list custom setting
    webservice static List<RefCodeInfo> GetAllCountries()
    {
        List<RefCodeInfo> infoList = new List<RefCodeInfo>();
        
        try
        {
            //get all of the countries code values
            List<CountriesRefCodes__c> codesMap = CountriesRefCodes__c.getAll().values();
            
            //create a custom sorted list that sorts by description instead of name and sort the list
            List<CountriesRefCodesSortWrapper> sortList = new List<CountriesRefCodesSortWrapper>();
            
            for(CountriesRefCodes__c code : codesMap)
                if(code.Active__c)
                    sortList.add(new CountriesRefCodesSortWrapper(code));
           
            sortList.sort();
            
            //add the sorted list items to the returned list
            for(CountriesRefCodesSortWrapper wrap : sortList)
            {
                RefCodeInfo info = new RefCodeInfo();
                info.rvlowvalue = wrap.CountriesRefCodes.Name;
                info.rvhighvalue = wrap.CountriesRefCodes.Description__c;
                info.rvmeaning = wrap.CountriesRefCodes.Description__c;
                infoList.add(info);
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetAllCountries','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return infoList;
    }
    
    //sprint 5
    //Get the active HearAboutUs refcodes from the custom setting
    //@return CodeInfo containing the numeric code and description of active codes
    webservice static List<CodeInfo> GetHearAboutUs()
    {
        List<CodeInfo> hearCodes = new List<CodeInfo>();
        
        try
        {
            //get all of the hearaboutus code values
            List<HearAboutUsRefCodes__c> codesList = HearAboutUsRefCodes__c.getAll().values();
           
            //add the list items to the returned list
            for(HearAboutUsRefCodes__c code : codesList)
            {
                if(code.Active__c)
                {
                    CodeInfo info = new CodeInfo();
                    info.code = code.Name;
                    info.name = code.Description__c;
                    hearCodes.add(info);
                }
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
            return hearCodes;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetHearAboutUs','Exception');
            log.logException(ex);
            log.saveLogs();
            return hearCodes;
        }
    }
    
    //sprint 5
    //@return Gets a list of all active national offices
    //that don't have a reciprocal alliance id, excluding Togo (161)
    webservice static List<NationalOfficeInfo> GetNationalOffices()
    {
        List<NationalOfficeInfo> infoList = new List<NationalOfficeInfo>();
        
        try
        {
            List<CountriesRefCodes__c> codes = CountriesRefCodes__c.getAll().values();
            Map<string,string> countriesMap = new Map<string,string>();
            for(CountriesRefCodes__c code : codes)
                countriesMap.put(code.Description__c, code.Name);
            
            List<Account> offices = [select id,
                                     Name,
                                     National_Office_ID__c,
                                     NO_Country__c 
                                    from account
                                    where RecordType.Name = 'National Office'
                                     and rC_Bios__Active__c = true
                                     and Reciprocal_Alliance__c = null
                                     and National_Office_ID__c != '161'
                                    order by name asc];
            
            for(Account office : offices)
            {
                NationalOfficeInfo info = new NationalOfficeInfo();
                
                if(string.isNotBlank(office.National_Office_ID__c))
                    info.id = integer.valueOf(office.National_Office_ID__c);
                
                info.name = office.name;
                
                if(string.isNotBlank(office.NO_Country__c))
                    info.ctrycode = countriesMap.get(office.NO_Country__c);
                
                infoList.add(info);
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetNationalOffices','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return infoList;
    }
    
    //sprint 5
    //Gets info about a National Office
    //@param NationalOfficeId - the national office number
    //@return NationalOfficeInfo - info about national office including name and country code
    webservice static NationalOfficeInfo GetNationalOfficeById(integer NationalOfficeID)
    {
        NationalOfficeInfo info;
        
        try
        {
            List<CountriesRefCodes__c> codes = CountriesRefCodes__c.getAll().values();
            Map<string,string> countriesMap = new Map<string,string>();
            for(CountriesRefCodes__c code : codes)
                countriesMap.put(code.Description__c, code.Name);
            
            string nationalOfficeNumber = string.valueOf(NationalOfficeID);
            
            Account office = [select id,
                              Name,
                              National_Office_ID__c,
                              NO_Country__c 
                              from account
                              where RecordType.Name = 'National Office'
                              and  National_Office_ID__c = :nationalOfficeNumber
                              LIMIT 1];
            
            info = new NationalOfficeInfo();
                
            if(string.isNotBlank(office.National_Office_ID__c))
                info.id = integer.valueOf(office.National_Office_ID__c);
            
            info.name = office.name;
            
            if(string.isNotBlank(office.NO_Country__c))
                info.ctrycode = countriesMap.get(office.NO_Country__c);
                
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetNationalOfficeById','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return info;
    }
    
    //sprint 5
    //@return All states, territories, and provinces
    webservice static List<CodeInfo> GetStatesAndProvinces()
    {
        List<CodeInfo> stateCodes = new List<CodeInfo>();
        
        try
        {
            //get all of the states/territories/provinces code values
            List<StateTerrProvRefCodes__c> codesList = StateTerrProvRefCodes__c.getAll().values();
            
            //create a custom sorted list that sorts by description instead of name and sort the list
            List<StateTerrProvRefCodesSortWrapper> sortList = new List<StateTerrProvRefCodesSortWrapper>();
            
            for(StateTerrProvRefCodes__c code : codesList)
                sortList.add(new StateTerrProvRefCodesSortWrapper(code));
            
            sortList.sort();
            
            //add the sorted list items to the returned list
            for(StateTerrProvRefCodesSortWrapper wrap : sortList)
            {
                CodeInfo info = new CodeInfo();
                info.code = wrap.StateRefCodes.Name;
                info.name = wrap.StateRefCodes.Description__c;
                stateCodes.add(info);
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
            return stateCodes;
        }
        catch(Exception ex)
        {
            system.debug('---ex---' + ex.getStackTraceString() + '----line---' + ex.getLineNumber());
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetStatesAndProvinces','Exception');
            log.logException(ex);
            log.saveLogs();
            return stateCodes;
        }
    }
    
    //sprint 5
    //@return - list of titles from custom settings, sorted alphabetically 
    webservice static List<CodeInfo> GetWebTitles()
    {
        List<CodeInfo> infoList = new List<CodeInfo>();
        
        try
        {
            //get all of the titles code values
            List<WebTitlesRefCodes__c> codesList = WebTitlesRefCodes__c.getAll().values();
            
            //create a custom sorted list that sorts by description instead of name and sort the list
            List<WebTitlesRefCodesSortWrapper> sortList = new List<WebTitlesRefCodesSortWrapper>();
            
            for(WebTitlesRefCodes__c code : codesList)
                sortList.add(new WebTitlesRefCodesSortWrapper(code));
            
            sortList.sort();
            
            //add the sorted list items to the returned list
            for(WebTitlesRefCodesSortWrapper wrap : sortList)
            {
                CodeInfo info = new CodeInfo();
                info.code = wrap.TitlesRefCodes.Name;
                info.name = wrap.TitlesRefCodes.Description__c;
                infoList.add(info);
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetWebTitles','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return infoList;
    }
    
    //sprint 5
    //@return - list of Web Suffix refcode info in custom settings,
    //sorted alphabetically by description
    webservice static List<CodeInfo> GetWebSuffixes()
    {
        List<CodeInfo> infoList = new List<CodeInfo>();
        
        try
        {
            //get all of the titles code values
            List<WebSuffixRefCodes__c> codesList = WebSuffixRefCodes__c.getAll().values();
            
            //create a custom sorted list that sorts by description instead of name and sort the list
            List<WebSuffixRefCodesSortWrapper> sortList = new List<WebSuffixRefCodesSortWrapper>();
            
            for(WebSuffixRefCodes__c code : codesList)
                sortList.add(new WebSuffixRefCodesSortWrapper(code));
            
            sortList.sort();
            
            //add the sorted list items to the returned list
            for(WebSuffixRefCodesSortWrapper wrap : sortList)
            {
                CodeInfo info = new CodeInfo();
                info.code = wrap.SuffixRefCodes.Name;
                info.name = wrap.SuffixRefCodes.Description__c;
                infoList.add(info);
            }
            
            //Appirio Inc. Vaibhav Goel Aug 9,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
            if(test.isRunningTest() && shouldThrowException){
                Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
            }
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('LookupService','GetWebSuffixes','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return infoList;
    }
    
    public static string GetStateAbbreviationFromCode(integer stateCode)
    {
        string stateAbbreviation;
        StateTerrProvRefCodes__c stateRefCode = 
            StateTerrProvRefCodes__c.getValues(string.valueOf(stateCode));                                   
        if(stateRefCode != null)
            stateAbbreviation = stateRefCode.Code__c;
        
        return stateAbbreviation;
    }
    
    public static integer GetStateCodeFromAbbreviation(string stateAbbreviation)
    {
        integer stateCode;
        List<StateTerrProvRefCodes__c> stateRefCodes = StateTerrProvRefCodes__c.getAll().values();
        for(StateTerrProvRefCodes__c code: stateRefCodes)
            if(code.Code__c.toLowerCase() == stateAbbreviation.toLowerCase())
                stateCode = integer.valueOf(code.Name);
        
        return stateCode;
    }
    
    public static string GetCountryAbbreviationFromCode(integer countryCode)
    {
        string countryAbbreviation;
        string countryCodeString = string.valueOf(CountryCode).leftPad(3).replaceAll(' ','0');
        CountriesRefCodes__c countryRefCode = 
            CountriesRefCodes__c.getValues(string.valueOf(countryCodeString));                                   
        if(countryRefCode != null)
            countryAbbreviation = countryRefCode.Code__c;
       
        return countryAbbreviation;
    }
    
    public static integer GetCountryCodeFromAbbreviation(string countryAbbreviation)
    {
        integer countryCode;
        List<CountriesRefCodes__c> countryCodes = CountriesRefCodes__c.getAll().values();
        for(CountriesRefCodes__c code : countryCodes)    
            if(countryAbbreviation.toLowerCase() == code.Description__c.toLowerCase())
                countryCode = integer.valueOf(code.Name);
        
        return countryCode;
    }
    
    public static string GetSuffixFromCode(integer suffixCode)
    {
        string suffix;
        WebSuffixRefCodes__c suffixRefCode = 
            WebSuffixRefCodes__c.getValues(string.valueOf(suffixCode));
        if(suffixRefCode != null)
            suffix  = suffixRefCode.Description__c;
        
        return suffix;
    }
    
    public static integer GetSuffixCodeFromSuffix(string suffix)
    {
        integer suffixCode;
        List<WebSuffixRefCodes__c> suffixCodes = WebSuffixRefCodes__c.getAll().values();
        for(WebSuffixRefCodes__c code : suffixCodes)
            if(suffix.toLowerCase() == code.Description__c.toLowerCase())
                suffixCode = integer.valueOf(code.Name);
        
        return suffixCode;
    }
    
    public static string GetTitleFromCode(integer titleCode)
    {
        string title;
        WebTitlesRefCodes__c titleRefCode = 
            WebTitlesRefCodes__c.getValues(string.valueOf(titleCode));
        if(titleRefCode != null)
            title = titleRefCode.Description__c;
        
        return title;
    }
    
    public static integer GetTitleCodeFromTitle(string title)
    {
        integer titleCode;
        List<WebTitlesRefCodes__c> titleCodes = WebTitlesRefCodes__c.getAll().values();
        for(WebTitlesRefCodes__c code : titleCodes)
            if(title.toLowerCase() == code.Description__c.toLowerCase())
                titleCode = integer.valueOf(code.Name);
        
        return titleCode;
    }

    public static string GetPaymentFrequencyFromCode(string code)
    {
        if(code == 'O')
            return 'One Payment';
        else if(code == 'M')
            return 'Monthly';
        else if(code == 'Q')
            return 'Quarterly';
        else if(code == 'S')
            return 'Semi-Annually';
        else if(code == 'A')
            return 'Annually';
        else
            return 'Monthly';
    }

    public static string GetPaymentFrequencyCodeFromFrequency(string code)
    {
        if(code == 'One Payment')
            return 'O';
        else if(code == 'Monthly')
            return 'M';
        else if(code == 'Quarterly')
            return 'Q';
        else if(code == 'Semi-Annually')
            return 'S';
        else if(code == 'Annually')
            return 'A';
        else
            return 'M';
    }

    public static id GetCampaignId(integer marketingId)
    {
        id campaignId;

        try
        {
            string campaignNumber = string.valueOf(marketingId).leftPad(7).replaceAll(' ','0');
        
            campaignId = [select id from campaign
                            where Source_Code_Autonumber__c = :campaignNumber
                            limit 1].id;
        }
        catch(exception ex)
        {
            //silently fail - will detect null values in calling functions.
        }

        return campaignId;
    }

    public static integer GetMarketingId(Id campaignId)
    {
        string campaignNumber = [select Source_Code_Autonumber__c from campaign where id = :campaignId limit 1].Source_Code_Autonumber__c;
        return integer.valueOf(campaignNumber);
    }

    public static integer GetDonorId(Id contactId)
    {
        string contactNumber = [select contact_number__c from contact where id = :contactId limit 1].contact_number__c;
        return integer.valueOf(contactNumber);
    }

    public static integer GetPaymentId(Id paymentMethodId)
    {
        string paymentNumber = [select Payment_Method_Number__c from rC_Giving__Payment_Method__c where id = :paymentMethodId limit 1].Payment_Method_Number__c;
        return integer.valueOf(paymentNumber);                                                
    }

    //gets all campaigns associated with the donations
    //key for the Map is campaign source code
    public static Map<integer, Campaign> GetCampaignsByDonations(TransactionInfo TransInfo)
    {
        Map<integer, Campaign> result = new Map<integer, Campaign>();
        set<string> campaignIds = new set<string>();
        set<string> finCodes = new set<string>();

        for(DonationInfo donation : TransInfo.PurchasedDonations)
        {
            if(donation.mktacid != null && donation.mktacid != 0)
                campaignIds.add(string.valueOf(donation.mktacid).leftPad(7).replaceAll(' ','0'));

            if(donation.fincode != null && donation.fincode != 0)
                finCodes.add(string.valueOf(donation.fincode).leftPad(4).replaceAll(' ','0'));
        }

        List<Campaign> campaigns = [select id, Source_Code_Autonumber__c, Product_Type__c, Product_Sub_Type__c, rC_Giving__GAU__c, rC_Giving__GAU__r.Receipt_Category__c
                                    from Campaign
                                    where (Source_Code_Autonumber__c in :campaignIds or rC_Giving__GAU__r.Receipt_Category__c in :finCodes)
                                    and rC_Giving__GAU__r.RecordType.Name = 'GAU'
                                    and rC_Giving__GAU__r.Funding_Source__r.Alliance__c = false 
                                    and rC_Giving__GAU__r.GAU_Type__c = 'Funding Source / Category'
                                    and rC_Giving__GAU__r.rC_Giving__Active__c = true
                                    and IsActive = true];

        for(Campaign campaign : campaigns)
            result.put(integer.valueOf(campaign.Source_Code_Autonumber__c), campaign);

        return result;
    }

    public static id GetOpportunityId(integer PaySchedId)
    {
        string opportunityNumber = string.valueOf(PaySchedId);

        id opportunityId = [select id from opportunity
                            where Salesforce_Opportunity_Code__c = :opportunityNumber
                            limit 1].id;

        return opportunityId;
    }

    public static string GetCountryISO2Code(string countryAbbreviation)
    {
        string result;
        List<CountriesRefCodes__c> countryCodes = CountriesRefCodes__c.getAll().values();
        for(CountriesRefCodes__c code : countryCodes)    
            if(countryAbbreviation.toLowerCase() == code.Code__c.toLowerCase())
                result = code.ISO2__c;

        return result;
    }

    public static id GetUSAllianceId()
    {
        id result;

        try
        {
            Account alliance = [select id from account
                                where recordtype.name = 'ChildFund' and
                                type = 'Alliance Partner' and
                                country__c = 'USA' and
                                IsUSBased__c = true limit 1];

            result = alliance.id;
        }
        catch(Exception ex)
        {
            throw new ApplicationException('US Alliance is not set up in system');
        }

        return result;
    }

    
}