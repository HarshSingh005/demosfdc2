/***********************************************************************************************************
 * Appirio, Inc
 * Name         : DonorPortalService
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : DonorPortal web service for Childfund.org website
 * Created Date : 02/24/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/24/2016                   Karl Houseknecht        Created
 * 04/22/2016                   Jagjeet Singh           Added Method formatTaxAmount
 **********************************************************************************************************/
global class DonorPortalService 
{
    //find household or organization contacts by number
    //@param ContactId - the childfund contact number
    //@return - ContactInfo of the contact
    webservice static ContactInfo GetContactByID(integer ContactId)
    {
        try
        {
            string contactNumber = string.valueOf(ContactId);
            List<Id> recordTypeIds = new List<Id>();
            recordTypeIds.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId());
            recordTypeIds.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Organizational').getRecordTypeId());
            
            //todo: fields
            Contact contact = [select id,
                               Contact_Number__c,
                               recordtype.Name,
                               LastName,
                               rC_Bios__Preferred_Mailing_Address__c,
                               CreatedDate,
                               rC_Bios__Deceased__c,
                               Preferred_Communication_Method__c,
                               VIP__c,
                               FirstName,
                               rC_Bios__Middle_Name__c,
                               Salutation,
                               Custom_Salutation__c,
                               Envelope_Salutation__c, 
                               rC_Bios__Preferred_Phone__c,
                               Phone,
                               MobilePhone,
                               HomePhone,
                               OtherPhone,
                               AssistantPhone,
                               Fax,
                               email,
                               rC_Bios__Preferred_Email__c,
                               rC_Bios__Home_Email__c,
                               rC_Bios__Work_Email__c,
                               rC_Bios__Assistant_Email__c,
                               rC_Bios__Other_Email__c, 
                               Board_Member__c,
                               LastModifiedDate,
                               LastModifiedBy.Name,
                               Donor_Flag__c,
                               Contact_Flag_Formula__c,
                               Delinquency_Cancelled_Spns__c,
                               Campaign__c,
                               Campaign__r.Source_Code_Autonumber__c,
                               rC_Bios__Suffix__c,
                               Donor_Alliance__r.Alliance_Partner_Id__c 
                              from Contact
                              where RecordTypeId in :recordTypeIds 
                               AND Contact_Number__c = :contactNumber LIMIT 1];
            
            
            rC_Bios__Contact_Address__c contactAddress;

            if(contact.rC_Bios__Preferred_Mailing_Address__c != null)
            {
                contactAddress = [select id,
                                  rC_Bios__Attention_Line__c,
                                  rC_Bios__Street_Line_1__c,
                                  rC_Bios__Street_Line_2__c,
                                  rC_Bios__Additional_Line_1__c,
                                  rC_Bios__City__c,
                                  rC_Bios__State__c,
                                  rC_Bios__Postal_Code__c,
                                  rC_Bios__Country__c
                                  from rC_Bios__Contact_Address__c
                                  where rC_Bios__Contact__c = :contact.id and
                                  rC_Bios__Address__c = :contact.rC_Bios__Preferred_Mailing_Address__c and
                                  rC_Bios__Preferred_Mailing__c = true
                                  limit 1];
            }

            ContactInfo info = new ContactInfo(); 
            
            MapContactInfo(contact, info, contactAddress);
            
            return info;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            system.debug('---ex----' + ex);
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('DonorPortalService','GetContactByID','Exception');
            log.logException(ex);
            log.saveLogs();
            return null;   
        }
    }
    
    private static void MapContactInfo(Contact contact, ContactInfo info, rC_Bios__Contact_Address__c contactAddress)
    {
        info.id = integer.valueof(contact.Contact_Number__c);
        
        if(contact.recordtype.name == 'Household')
          info.conttype = 'INDV';
        else
          info.conttype = 'ORG';
        
        if(contactAddress != null)
        {
            info.careof = contactAddress.rC_Bios__Attention_Line__c;
            info.street1 = contactAddress.rC_Bios__Street_Line_1__c;
            info.street2 = contactAddress.rC_Bios__Street_Line_2__c;
            info.extraaddress1 = contactAddress.rC_Bios__Additional_Line_1__c;
            info.city = contactAddress.rC_Bios__City__c;

            if(contactAddress.rC_Bios__State__c != null)
              info.cdesstatprovterrid = LookupService.GetStateCodeFromAbbreviation(contactAddress.rC_Bios__State__c);
            
            info.state = contactAddress.rC_Bios__State__c;

            info.postalcode = contactAddress.rC_Bios__Postal_Code__c;
            
            if(contactAddress.rC_Bios__Country__c != null)
              info.ctrycode = string.valueOf(LookupService.GetCountryCodeFromAbbreviation(contactAddress.rC_Bios__Country__c));
        }

        info.datecreated = 
            date.newInstance(contact.CreatedDate.year(), 
                             contact.CreatedDate.month(), 
                             contact.CreatedDate.day());
        
        if(contact.rC_Bios__Deceased__c)
            info.inddeceased = 'Y';
        else
            info.inddeceased = 'N';
        
        info.prefcorrmethod = contact.Preferred_Communication_Method__c;

        
        if(contact.Contact_Flag_Formula__c)
            info.indundesirable = 'Y';
        else
            info.indundesirable = 'N';
        
        if(contact.VIP__c)
            info.indvip = 'Y';
        else
            info.indvip = 'N';
        
        if(contact.campaign__c != null)
            info.mktacid = integer.valueOf(contact.Campaign__r.Source_Code_Autonumber__c);
        

        info.firstname = contact.FirstName;
        info.middlename = contact.rC_Bios__Middle_Name__c;
        info.name = contact.LastName;

        if(contact.rC_Bios__Suffix__c != null)
          info.clstnmsuffixid = LookupService.GetSuffixCodeFromSuffix(contact.rC_Bios__Suffix__c);
        
        List<WebTitlesRefCodes__c> titleRefCodes = WebTitlesRefCodes__c.getAll().values();
        for(WebTitlesRefCodes__c code: titleRefCodes)
            if(contact.Salutation != null)
                if(code.Description__c.toLowerCase() == contact.Salutation.toLowerCase())
                    info.clstnmtitleid = integer.valueOf(code.Name);
        
        info.salutation = contact.Custom_Salutation__c;
        info.envelopeline = contact.Envelope_Salutation__c; 
        
        //determine phone to return
        string phone;
        if(contact.rC_Bios__Preferred_Phone__c == 'Home')
            phone = contact.HomePhone;
        else if (contact.rC_Bios__Preferred_Phone__c == 'Work')
            phone = contact.Phone;
        else if (contact.rC_Bios__Preferred_Phone__c == 'Mobile')
            phone = contact.MobilePhone;
        else if (contact.rC_Bios__Preferred_Phone__c == 'Assistant')
            phone = contact.AssistantPhone;
        else if (contact.rC_Bios__Preferred_Phone__c == 'Other')
            phone = contact.OtherPhone;
        
        if(phone != null)
        {
            info.phoneareacode = GetPhoneAreaCode(phone);
            info.phone = GetPhoneNumber(phone);

            string extension = GetPhoneExtension(phone);
            if(string.isnotblank(extension) && extension.isnumeric())
                info.phoneextension = integer.valueOf(extension);
        }
        
        if(contact.fax != null)
        {
            info.faxareacode = GetPhoneAreaCode(contact.Fax);
            info.phonefax = GetPhoneNumber(contact.Fax);
        }
        
        info.email = contact.email;
        
        if(contact.Board_Member__c)
            info.indboardmember = 'Y';
        else
            info.indboardmember = 'N';
        
        info.qtyactiveprespns = LookupService.GetCurrentPresponsors(info.id);    
        
        //black for block, red for contact must be spoken with.  Any value means false.
        if(string.isBlank(contact.Donor_Flag__c))
            info.indallowsponsorship = 'Y';
        else
            info.indallowsponsorship = 'N';
        
        if(string.isNotBlank(contact.Donor_Alliance__r.Alliance_Partner_Id__c) && contact.Donor_Alliance__r.Alliance_Partner_Id__c.isnumeric()) 
            info.iaid = integer.valueOf(contact.Donor_Alliance__r.Alliance_Partner_Id__c);
        
        info.datemodified = date.newInstance(contact.LastModifiedDate.year(), 
                                             contact.LastModifiedDate.month(), 
                                             contact.LastModifiedDate.day());
        info.lastmodifiedby = contact.LastModifiedBy.Name;
        //info.iaacctno = same as iaid?
       
        info.qtydelinquencycanceledspns = integer.valueOf(contact.Delinquency_Cancelled_Spns__c); 
    }
    
    private static string GetPhoneAreaCode(string phone)
    {
        string areaCode;

        if(string.isNotBlank(phone))
        {
            areaCode = phone.substringBetween('(', ')');
            if(string.isBlank(areaCode))
              if(phone.length() >= 3)
                areaCode = phone.substring(0,3);
        }

        return areaCode;
    }

    private static string GetPhoneNumber(string phone)
    {
        string phoneNumber;

        if(string.isNotBlank(phone))
        {
            phoneNumber = phone.substringAfter(') ').replace('-','');
            if(string.isBlank(phoneNumber))
              if(phoneNumber.length() >= 3)
                phoneNumber = phone.substring(3);
            
            if(phoneNumber != null && phoneNumber.containsIgnoreCase('x'))
            {
                integer xindex = phoneNumber.indexofignorecase('x');
                phoneNumber = phoneNumber.substring(0, xindex);
            }
        }

        return phoneNumber;
    }

    private static string GetPhoneExtension(string phone)
    {
        string extension;

        if(string.isNotBlank(phone))
        {
            extension = phone.substringafter('x');
        }

        return extension;
    }
    
    //Returns the childfund contact number
    //@param email - of the contact
    //@return - childfund contact number
    webservice static integer GetContactIdByEmail(string email)
    {
        try
        {    
            //LIKE clauses does case-insensitive match on email, with no wildcards
            Contact contact = [select Id, Contact_Number__c
                              from Contact
                              where (recordtype.name = 'Household' or recordtype.name = 'Organizational')
                              AND (email like :email)
                              LIMIT 1];
            
            if(contact == null)
                return 0;
            else
                return integer.valueOf(contact.Contact_Number__c);
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('DonorPortalService','GetContactIdByEmail','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;   
        }
    }
    
    //creates a new household contact, account, and address
    //@param ContactInfo - contact related data
    //@return Envelope - with the new contact number
    webservice static Envelope AddContact(ContactInfo info)
    {
        Envelope returnValue = new Envelope();
        System.Savepoint trans;
        
        try
        {
            Contact contact = new Contact();
            Account account = new Account();
            rC_Bios__Address__c address;
            rC_Bios__Contact_Address__c contactAddress = new rC_Bios__Contact_Address__c();
            
            account.UseDuplicateRules__c = false;
            account.name = String.valueOf(System.now());

            contact.UseDuplicateRules__c = false;
            contact.rC_Bios__Active__c = true;
            contact.rC_Bios__Preferred_Contact__c = true;
            
            string contactType;
            if(info.conttype == 'ORG')
                contactType = 'Organizational';
            else
                contactType = 'Household';
 
            contact.RecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get(contactType).getRecordTypeId();
            contact.LastName = info.name;

            //must check to see if address exists first by comparing hash
            string state;
            if(info.cdesstatprovterrid != null)
                state = LookupService.GetStateAbbreviationFromCode(info.cdesstatprovterrid);

            string country;
            if(info.ctrycode != null)
                country = LookupService.GetCountryAbbreviationFromCode(integer.valueOf(info.ctrycode));

            
            //because NGOC will not store address fields as empty strings
            //we must compare nulls to nulls
            string street2;
            if(string.isNotBlank(info.street2))
                street2 = info.street2;

            string hashedAddress = LookupService.HashAddress(info.street1,
                                                             street2, 
                                                             info.city, 
                                                             state, 
                                                             info.postalcode, 
                                                             country);
            
            List<rC_Bios__Address__c> addressList = [select id, 
                                                     rC_Bios__Street_Line_1__c,
                                                     rC_Bios__Street_Line_2__c,
                                                     Extra_Address_1__c,
                                                     rC_Bios__City__c,
                                                     rC_Bios__State__c,
                                                     rC_Bios__Postal_Code__c,
                                                     rC_Bios__Country__c
                                                     from rc_Bios__Address__c
                                                     where rC_Bios__Unique_MD5__c = :hashedAddress];
            
            if(addressList.size() > 0)
            {
                address = addressList[0];
            }
            else
            {
                address = new rC_Bios__Address__c();
                address.rC_Bios__Street_Line_1__c = info.street1;
                address.rC_Bios__Street_Line_2__c = street2;
                address.Extra_Address_1__c = info.extraaddress1;
                address.rC_Bios__City__c = info.city;
                address.rC_Bios__State__c = state;
                address.rC_Bios__Postal_Code__c = info.postalcode;
                address.rC_Bios__Country__c = country;
            }
            
            contactAddress.rC_Bios__Additional_Line_1__c = info.extraaddress1;
            contactAddress.rC_Bios__Type__c = 'Home'; //defaulting to home
            contactAddress.rC_Bios__Preferred_Mailing__c = true;
            contactAddress.rC_Bios__Preferred_Other__c = true;
            
            if(string.isNotBlank(info.careof))
                contactAddress.rC_Bios__Attention_Line__c = info.careof;

            
            //info.freqgrpid 

            //info.origincode
            if(info.inddeceased == 'Y')
                contact.rC_Bios__Deceased__c = true;
            else
                contact.rC_Bios__Deceased__c = false;
            
            //info.inddonotcall = many fields in NGOC.  home, mobile, etc
            //info.namesoundx = 
            contact.Preferred_Communication_Method__c = info.prefcorrmethod;
            //info.indreturnedmail
            //info.indsupervisorhandling
            //info.indundesirable
            if(info.indvip == 'Y')
                contact.VIP__c = true;
            else
                contact.VIP__c = false;
            
            if(info.mktacid != null && info.mktacid != 0)
                contact.campaign__c = LookupService.GetCampaignId(info.mktacid);
     
            contact.FirstName = info.firstname;
            contact.rC_Bios__Middle_Name__c = info.middlename;
            
            if(info.clstnmsuffixid != null)
                contact.rC_Bios__Suffix__c  = LookupService.GetSuffixFromCode(info.clstnmsuffixid);                
            
            if(info.clstnmtitleid != null)
                contact.Salutation = LookupService.GetTitleFromCode(info.clstnmtitleid);
                       
            if((string.isNotBlank(info.phoneareacode)) && (string.isNotBlank(info.phone)))
            {
                contact.rC_Bios__Preferred_Phone__c = 'Home'; //defaulting to Home
                contact.HomePhone = info.phoneareacode + info.phone; 
                if(info.phoneextension != null)
                    contact.HomePhone += ' x' + info.phoneextension;
            }
            
            if((string.isNotBlank(info.faxareacode)) && (string.isNotBlank(info.phonefax)))
                contact.Fax = info.faxareacode + info.phonefax;
            
            if(info.email != null)
            {
                contact.rC_Bios__Preferred_Email__c = 'Home'; //defaulting to Home
                contact.rC_Bios__Home_Email__c = info.email.toLowerCase();
                contact.Successful_Registration__c = true;
            }

            //default to US alliance regardless of address.
            contact.Donor_Alliance__c = LookupService.GetUSAllianceId();

            //DML
            trans = database.setSavepoint();
            insert account;
            contact.AccountId = account.id;
            insert contact;
            upsert address;
            contactAddress.rC_Bios__Contact__c = contact.id;
            contactAddress.rC_Bios__Address__c = address.id;
            insert contactAddress;
            
            contact = [select id, Contact_Number__c from Contact where id = :contact.id limit 1];
            returnValue.NewID = integer.valueOf(contact.Contact_Number__c);
        }
        catch(Exception ex)
        {
            if(trans != null)
                database.rollback(trans);
           
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('DonorPortalService','AddContact','Exception');
            log.logException(ex);
            log.saveLogs();
            returnValue.ReturnMessage = Enums.ReturnMsg.Failure;
            returnValue.ErrorMessage = ex.getMessage();
            returnValue.StackTrace = ex.getStackTraceString();
        }
        
        return returnValue;
    }
    
    //Not sure why this is a separate function since
    //contact type seems to be only difference
    webservice static Envelope AddOrgContact(ContactInfo info)
    {
        return DonorPortalService.AddContact(info);
    }
    
    //update contact
    //@param ContactUpdateInfo - data about contact and address
    //@return Integer - 1 on success, zero on error
    webservice static integer UpdateContact(ContactUpdateInfo info)
    {
        
        System.Savepoint trans = database.setSavepoint();
        
        try
        {
            string contactNumber = string.valueOf(info.id);
            
            Contact contact = [select Id,
                               lastname,
                               FirstName,
                               rC_Bios__Middle_Name__c,
                               rC_Bios__Deceased__c,
                               Preferred_Communication_Method__c,
                               VIP__c,
                               campaign__c,
                               rC_Bios__Suffix__c,
                               Salutation,
                               rC_Bios__Preferred_Phone__c,
                               HomePhone,
                               Fax,
                               rC_Bios__Preferred_Email__c,
                               rC_Bios__Home_Email__c,
                               rC_Bios__Preferred_Mailing_Address__c
                              from Contact
                              where Contact_Number__c = :contactNumber
                              LIMIT 1];
            
            
            if(string.isNotBlank(info.firstname))
                contact.FirstName = info.firstname;
            
            if(string.isNotBlank(info.middlename))
                contact.rC_Bios__Middle_Name__c = info.middlename;
            
            if(string.isNotBlank(info.name))
                contact.lastname = info.name;
            
            if(info.clstnmsuffixid != null)
                contact.rC_Bios__Suffix__c  = LookupService.GetSuffixFromCode(info.clstnmsuffixid);                
            
            if(info.clstnmtitleid != null)
                contact.Salutation = LookupService.GetTitleFromCode(info.clstnmtitleid);
                       
            if((string.isNotBlank(info.phoneareacode)) && (string.isNotBlank(info.phone)))
            {
                contact.rC_Bios__Preferred_Phone__c = 'Home'; //defaulting to Home
                contact.HomePhone = info.phoneareacode + info.phone; 
                if(info.phoneextension != null)
                    contact.HomePhone += ' x' + info.phoneextension;
            }
            
            if(info.email != null)
            {
                contact.rC_Bios__Preferred_Email__c = 'Home'; //defaulting to Home
                contact.rC_Bios__Home_Email__c = info.email.toLowerCase();
            }

            update contact;


            rC_Bios__Contact_Address__c contactAddress;
            
            string state;
            if(info.cdesstatprovterrid != null)
                state = LookupService.GetStateAbbreviationFromCode(info.cdesstatprovterrid);

            string country;
            if(info.ctrycode != null)
                country = LookupService.GetCountryAbbreviationFromCode(integer.valueOf(info.ctrycode));

            //because NGOC will not store address fields as empty strings
            //we must compare nulls to nulls
            string street2;
            if(string.isNotBlank(info.street2))
                street2 = info.street2;

            if(contact.rC_Bios__Preferred_Mailing_Address__c != null)
            {
                system.debug('contact.rC_Bios__Preferred_Mailing_Address__c: ' + string.valueof(contact.rC_Bios__Preferred_Mailing_Address__c));
                system.debug('contact.id: ' + string.valueof(contact.id));
                contactAddress = [select id,
                                  rC_Bios__Attention_Line__c,
                                  rC_Bios__Original_City__c,
                                  rC_Bios__Original_Country__c,
                                  rC_Bios__Original_Postal_Code__c,
                                  rC_Bios__Original_State__c,
                                  rC_Bios__Original_Street_Line_1__c,
                                  rC_Bios__Original_Street_Line_2__c,
                                  rC_Bios__Additional_Line_1__c,
                                  rC_Bios__Preferred_Mailing__c,
                                  rC_Bios__Preferred_Other__c
                                  from rC_Bios__Contact_Address__c
                                  where rC_Bios__Contact__c = :contact.id and
                                  rC_Bios__Address__c = :contact.rC_Bios__Preferred_Mailing_Address__c and
                                  rC_Bios__Preferred_Mailing__c = true
                                  limit 1];


                system.debug('contactAddress.id: ' + string.valueof(contactAddress.id));

                if(string.isNotBlank(info.careof))
                    contactAddress.rC_Bios__Attention_Line__c = info.careof;

                contactAddress.rC_Bios__Original_Street_Line_1__c = info.street1;
                contactAddress.rC_Bios__Original_Street_Line_2__c = street2;
                contactAddress.rC_Bios__Additional_Line_1__c = info.extraaddress1;
                contactAddress.rC_Bios__Original_City__c = info.city;
                contactAddress.rC_Bios__Original_State__c = state;
                contactAddress.rC_Bios__Original_Postal_Code__c = info.postalcode;
                contactAddress.rC_Bios__Original_Country__c = country;
                contactAddress.rC_Bios__Preferred_Mailing__c = true;
                contactAddress.rC_Bios__Preferred_Other__c = true;
                update contactAddress;
            }
            else
            {
                contactAddress = new rC_Bios__Contact_Address__c();

                string hashedAddress = LookupService.HashAddress(info.street1,
                                                             street2, 
                                                             info.city, 
                                                             state, 
                                                             info.postalcode, 
                                                             country);
            
                List<rC_Bios__Address__c> addressList = [select id, 
                                                         rC_Bios__Street_Line_1__c,
                                                         rC_Bios__Street_Line_2__c,
                                                         Extra_Address_1__c,
                                                         rC_Bios__City__c,
                                                         rC_Bios__State__c,
                                                         rC_Bios__Postal_Code__c,
                                                         rC_Bios__Country__c
                                                         from rc_Bios__Address__c
                                                         where rC_Bios__Unique_MD5__c = :hashedAddress];
                
                rC_Bios__Address__c address;

                if(addressList.size() > 0)
                {
                    address = addressList[0];
                }
                else
                {
                    address = new rC_Bios__Address__c();
                    address.rC_Bios__Street_Line_1__c = info.street1;
                    address.rC_Bios__Street_Line_2__c = street2;
                    address.Extra_Address_1__c = info.extraaddress1;
                    address.rC_Bios__City__c = info.city;
                    address.rC_Bios__State__c = state;
                    address.rC_Bios__Postal_Code__c = info.postalcode;
                    address.rC_Bios__Country__c = country;
                    insert address;
                }
                
                contactAddress.rC_Bios__Additional_Line_1__c = info.extraaddress1;
                contactAddress.rC_Bios__Type__c = 'Home'; //defaulting to home
                contactAddress.rC_Bios__Preferred_Mailing__c = true;
                contactAddress.rC_Bios__Preferred_Other__c = true;
                contactAddress.rC_Bios__Contact__c = contact.id;
                contactAddress.rC_Bios__Address__c = address.id;
                insert contactAddress;
            }

            return 1;
        }
        catch(Exception ex)
        {
            if(trans != null)
                database.rollback(trans);
            
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('DonorPortalService','UpdateContact','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;
        }
        
    }
    //For a contactId, query sponsorship and DF opportunities to get data about children 
    //and associated sponsorship-DF data
    //@param ContactId - the contact number of the donor or organization
    //@return List<SponsoredChildreninfo> - Child and DF info
    webservice static List<SponsoredChildrenInfo> GetSponsoredChildren(integer ContactId)
    {
        List<string> productTypes = new List<string>();
        productTypes.add('Sponsorship');
        productTypes.add('Designated Fund');
        return GetSponsoredChildren(ContactId, productTypes);
    }
   
    //method called by GetSponsoredChildren and PaySetup
    private static List<SponsoredChildrenInfo> GetSponsoredChildren(integer ContactId, List<string> productTypes)
    {
        List<SponsoredChildrenInfo> infoList = new List<SponsoredChildrenInfo>();
        System.debug('===ooo==contNumber='+contactId);
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            List<Opportunity> opps = [select id,
                                      rC_Giving__Primary_Contact__c,
                                      rC_Giving__Hard_Credit_Contact__c, 
                                      rC_Giving__Hard_Credit_Contact__r.Contact_Number__c,
                                      rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Issuer__c,
                                      rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,
                                      rC_Giving__Payment_Method_Selected__r.Payment_Method_Number__c,
                                      Product_Type__c,
                                      Product_Sub_Type__c,
                                      rC_Giving__GAU__r.Receipt_Category__c,
                                      Description__c,
                                      rC_Giving__Giving_Amount__c,
                                      rC_Giving__Giving_Frequency__c,
                                      rC_Sponsorship__Opportunity_Group_Id__c,
                                      Participant__r.National_Office_Number__c,
                                      Participant__r.Child_Number__c,
                                      Participant__r.Participant_Case_Number__c,
                                      Participant__r.Name,
                                      Participant__r.Birthdate,
                                      Participant__r.rC_Bios__Age__c,
                                      Participant__r.National_Office__r.NO_Country__c,
                                      Participant__r.Community_Number__c,
                                      Participant__r.Community__r.Name,
                                      Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__c,
                                      Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Street_Line_1__c,
                                      Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Street_Line_2__c,
                                      Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.Extra_Address_1__c,
                                      Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Country_Name__c, 
                                      Participant__r.rC_Sponsorship__Sponsorship_Status__c,
                                      Paid_Through_Date__c,
                                      Amount_Owed__c,
                                      Participant__r.rC_Bios__Birth_Month__c,
                                      Participant__r.Short_Name__c,
                                      Campaign_Source_Number__c,
                                      Electronic_Correspondence_Opt_In__c ,
                                      AGP_Method__c,
                                      Participant__r.Age_Months_Additional__c,
                                      Participant__r.Child_Address__c,
                                      rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number_Last_4__c,
                                      rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Number_Last_4__c,
                                      Legacy_Type__c
                                     from Opportunity
                                     where RecordType.Name = 'Donation'
                                     and rC_Giving__Hard_Credit_Contact__r.Contact_Number__c = :contactNumber
                                     and Product_Type__c in :productTypes
                                     and rC_Sponsorship__Sponsorship_Status__c = 'Active'];
                                     
            for(Opportunity opp : opps)
            {
                 System.debug('==rC_Giving__Hard_Credit_Contact__r.Contact_Number__c=='+opp.rC_Giving__Hard_Credit_Contact__r.Contact_Number__c);
                SponsoredChildrenInfo info;
                
                if(opp.AGP_Method__c)
                {
                    //is an Automated Giving Plan
                    //Payment staus must be active - transactions in an active status - ???
                    //Payment frequency (rC_Giving__Giving_Frequency__c != One Payment) is not one time. If it is, last payment date (?) is not null
                    
                    info = new SponsoredChildrenInfo();
                }
                else
                {
                    //not automated giving plan
                    //No active payment schedule - ???
                    
                    
                    info = new SponsoredChildrenInfo();
                }
                
                if(info != null)
                {
                    if(string.isNotBlank(opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number_Last_4__c))
                        info.AccountNum = '*' + opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number_Last_4__c;

                    if(string.isNotBlank(opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Number_Last_4__c))
                        info.AccountNum = '*' + opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Number_Last_4__c;
                    
                    List<CreditTypeRefCodes__c> cardTypeCodes = CreditTypeRefCodes__c.getAll().values();
                    for(CreditTypeRefCodes__c code : cardTypeCodes)
                        if(code.Description__c == opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Issuer__c)
                            info.CardType = code.Code__c;
                    
                    //TODO: info.conttype - standard accounts or gift account
                    // 2 character code value from ContactAcctType refcode
                    //No single field on opportunity that contains this info
                        
                    info.ContId = integer.valueOf(opp.rC_Giving__Hard_Credit_Contact__r.Contact_Number__c);
                    //TODO: info.AgpType = opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c translated
                    //if(opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c == )
                    //These values do not seem to line up with AgpType completely
                    
                    if(opp.rC_Giving__Payment_Method_Selected__r.Payment_Method_Number__c != null)
                        info.AgpId = integer.valueOf(opp.rC_Giving__Payment_Method_Selected__r.Payment_Method_Number__c);
                    
                    List<DonationTypeRefCodes__c> acctTypeCodes = DonationTypeRefCodes__c.getAll().values();
                    for(DonationTypeRefCodes__c code : acctTypeCodes)
                        if(code.Description__c == opp.Product_Type__c)
                            info.AcctType = code.Code__c;
                    
                    if(opp.rC_Giving__GAU__r.Receipt_Category__c != null)
                        info.FinCode = integer.valueOf(opp.rC_Giving__GAU__r.Receipt_Category__c);
                    
                    info.Description = opp.Product_Sub_Type__c;
                    info.Amount = opp.rC_Giving__Giving_Amount__c;
                   
                    info.Freq = LookupService.GetPaymentFrequencyCodeFromFrequency(opp.rC_Giving__Giving_Frequency__c);                 
                    
                    if(opp.rC_Sponsorship__Opportunity_Group_Id__c != null)
                        info.sponsorshipId = integer.valueOf(opp.rC_Sponsorship__Opportunity_Group_Id__c);
                    
                    info.NoId = integer.valueOf(opp.Participant__r.National_Office_Number__c);
                    
                    if(opp.Participant__r.Child_Number__c != null)
                      info.ChildNbr = integer.valueOf(opp.Participant__r.Child_Number__c);
                    
                    if(opp.Participant__r.Participant_Case_Number__c != null)
                        info.CaseNbr = integer.valueOf(opp.Participant__r.Participant_Case_Number__c);
                    
                    info.ChildName = opp.Participant__r.Name;
                    
                    if(opp.Participant__r.Birthdate != null)
                        info.Birthday = opp.Participant__r.Birthdate.format();
                    
                    if(opp.Participant__r.rC_Bios__Age__c != null)
                        info.AgeYear = integer.valueOf(opp.Participant__r.rC_Bios__Age__c);
                    
                    if(opp.Participant__r.Age_Months_Additional__c != null)
                        info.AgeMonth = integer.valueOf(opp.Participant__r.Age_Months_Additional__c); 
                    
                    List<CountriesRefCodes__c> countryCodes = CountriesRefCodes__c.getAll().values();
                    for(CountriesRefCodes__c  code : countryCodes)
                        if(code.Description__c == opp.Participant__r.National_Office__r.NO_Country__c)
                            info.CtryCode = code.Name;  
                    
                    info.CtryDesc = opp.Participant__r.National_Office__r.NO_Country__c;
                    info.ProjId = integer.valueOf(opp.Participant__r.Community_Number__c);
                    info.ProjDesc = opp.Participant__r.Community__r.Name;
                    //info.Address = opp.Participant__r.Community__r.BillingStreet + '\n'
                    //    + opp.Participant__r.Community__r.Billingcity + ', '
                    //    + opp.Participant__r.Community__r.BillingState + '  '
                    //    + opp.Participant__r.Community__r.BillingPostalCode + '\n'
                    //    + opp.Participant__r.Community__r.BillingCountry;
                    
                    /*
                    if(opp.Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__c != null)
                    {
                        string address = '';

                        if(string.isNotBlank(opp.Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Street_Line_1__c))
                            address += opp.Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Street_Line_1__c + '\n';

                        if(string.isNotBlank(opp.Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Street_Line_2__c))
                            address += opp.Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Street_Line_2__c + '\n';

                        if(string.isNotBlank(opp.Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.Extra_Address_1__c))
                            address += opp.Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.Extra_Address_1__c + '\n';

                        if(string.isNotBlank(opp.Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Country_Name__c))
                            address += opp.Participant__r.Community__r.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Country_Name__c;

                        if(string.isNotBlank(address))
                            info.Address = address;
                    }
                    */

                    info.address = opp.Participant__r.Child_Address__c;

                    List<ChildStatusRefCodes__c> statusCodes = ChildStatusRefCodes__c.getAll().values();
                    for(ChildStatusRefCodes__c  code : statusCodes)
                        if(code.Description__c == opp.Participant__r.rC_Sponsorship__Sponsorship_Status__c)
                            info.Status = code.Code__c;
                    
                    //info.DueDate = Paid_Through_Date__c (last date of month + 1 day)
                    if(opp.Paid_Through_Date__c != null)
                    {
                        Integer numberOfDays = Date.daysInMonth(opp.Paid_Through_Date__c.year(), opp.Paid_Through_Date__c.month());
                        Date dueDate = Date.newInstance(opp.Paid_Through_Date__c.year(), opp.Paid_Through_Date__c.month(), numberOfDays).addDays(1);
                        info.DueDate = dueDate.format();
                        
                        info.PaidThru = opp.Paid_Through_Date__c.format();
                    }
                    
                    info.AmtDue = opp.Amount_Owed__c;
                    
                    if(opp.Participant__r.rC_Bios__Birth_Month__c != null)
                        info.birthdayMonth = integer.valueOf(opp.Participant__r.rC_Bios__Birth_Month__c);
                    
                    //TODO: info.SponsorshipType - may be refcode, heath to check
                    info.ShortName = opp.Participant__r.Short_Name__c;
                    
                    if(opp.Campaign_Source_Number__c != null && opp.Campaign_Source_Number__c.isnumeric())
                        info.MktacId = integer.valueOf(opp.Campaign_Source_Number__c);
                    
                    //info.ChildPhoto - not in new system
                    info.LTEOptIn = opp.Electronic_Correspondence_Opt_In__c;
                    
                    if(string.isNotBlank(opp.Legacy_Type__c) && opp.Product_Type__c == 'Sponsorship')
                        info.SponsorshipType = opp.Legacy_Type__c;
                    else if(string.isBlank(opp.Legacy_Type__c) && opp.Product_Type__c == 'Sponsorship')
                        info.SponsorshipType = 'Standard';
                    else
                        info.SponsorshipType = '';

                    infoList.add(info);
                }
                    
            }
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('DonorPortalService','GetSponsoredChildren','Exception');
            log.logException(ex);
            log.saveLogs();
            //throw ex;
        }
        
        return infoList;
    }
    
    //sprint 4
    //Method Name                   : GetOptInsBySponsor
    //@param ContactId              : Contact_Number__c field at Contact Object
    //@return List<LTEOptInInfo>    : List of instances of class LTEOptInInfo on success, empty list on no result
    //Developer name                : Vaibhav Goel
    //Reference                     : T-485189
    //Date                          : March 17,2016
    webservice static List<LTEOptInInfo> GetOptInsBySponsor(integer ContactId)
    {
        
        List<LTEOptInInfo> LTEOptInInfoList = new List<LTEOptInInfo>();
        
        //Making SOQL on Opportynity to fetch fields of Opportunity and related Parent Primary Contact and Participant fields
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            List<Opportunity> oppObj = [Select Id, Name, rC_Giving__Hard_Credit_Contact__r.Contact_Number__c,
                                    Participant__r.National_Office_Number__c, Participant__r.Child_Number__c, 
                                    Electronic_Correspondence_Opt_In__c, Child_Correspondence_Opt_In_Date__c, 
                                    Salesforce_Opportunity_Code__c, rC_Sponsorship__Sponsorship_Status__c
                                    FROM Opportunity WHERE rC_Sponsorship__Sponsorship_Status__c = 'Active' 
                                    AND rC_Giving__Primary_Contact__r.Contact_Number__c = :contactNumber  
                                    AND recordtype.Name = 'Donation' AND Product_Type__c = 'Sponsorship' 
                                    AND Product_Sub_Type__c = 'Child Sponsorship' ];
            
            for(Opportunity opp : oppObj)
            {
                LTEOptInInfo LTEOptInInfoInstance = new LTEOptInInfo();
                
                if(opp.rC_Giving__Hard_Credit_Contact__r.Contact_Number__c != null)
                    LTEOptInInfoInstance.Contactid = Integer.ValueOf(opp.rC_Giving__Hard_Credit_Contact__r.Contact_Number__c);
                
                if(opp.Salesforce_Opportunity_Code__c != null)
                {
                    string oppCode = opp.Salesforce_Opportunity_Code__c.replace('OP','');
                    LTEOptInInfoInstance.Sponsorshipid = Integer.ValueOf(oppCode);
                }
                    
                
                LTEOptInInfoInstance.Noid = Integer.ValueOf(opp.Participant__r.National_Office_Number__c);
                LTEOptInInfoInstance.Childnumber = Integer.ValueOf(opp.Participant__r.Child_Number__c);
                
                
                if(opp.Electronic_Correspondence_Opt_In__c)
                    LTEOptInInfoInstance.Isoptedin = false;
                else
                    LTEOptInInfoInstance.Isoptedin = true;
                
                if(opp.Child_Correspondence_Opt_In_Date__c != null)
                    LTEOptInInfoInstance.Optindate = opp.Child_Correspondence_Opt_In_Date__c.format();
                
                LTEOptInInfoInstance.Status = opp.rC_Sponsorship__Sponsorship_Status__c;
                LTEOptInInfoList.add(LTEOptInInfoInstance);
            }
            
            
            return LTEOptInInfoList;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','GetOptInsBySponsor','Exception');
            log.logException(ex);
            log.saveLogs();
            //throw ex;
            return LTEOptInInfoList;
        }
    }
    
    //sprint 4
    //Method Name                   : UpdateOptInByChild
    //@param ContactId              : Contact_Number__c field at Contact Object.
    //@param NoID                   : national office number associated with child(Contact Object).
    //@param ChildNumber            : Child_Number__c field at Contact Object.
    //@param OptIn                  : Boolean field - Electronic_Correspondence_Opt_In__c  at Opportunity (whether to opt in for correspondence).
    //@return Boolean               : Returns true if update is success else False.
    //Developer name                : Vaibhav Goel
    //Reference                     : T-485190
    //Date                          : March 17,2016
    webservice static boolean UpdateOptInByChild(integer ContactId, integer NoID, integer ChildNumber, boolean OptIn)
    {
        
        try
        {
            Opportunity oppObj = [Select Id, Electronic_Correspondence_Opt_In__c FROM Opportunity 
                                    WHERE rC_Sponsorship__Sponsorship_Status__c = 'Active' 
                                    AND rC_Giving__Hard_Credit_Contact__r.Contact_Number__c = :String.ValueOf(ContactId)  
                                    AND recordtype.Name = 'Donation' AND Participant__r.National_Office_Number__c = :String.ValueOf(NoID) 
                                    AND Participant__r.Child_Number__c = :String.ValueOf(ChildNumber) limit 1];
            
            oppObj.Electronic_Correspondence_Opt_In__c = OptIn;
            
            update oppObj;
            return true;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','UpdateOptInByChild','Exception');
            log.logException(ex);
            log.saveLogs();
            return false;
        }
    }
    
    //sprint 4
    //Return a list of active payment schedules for DF, Sponsorships, and Contributions
    //@param ContactId - the contact number of the donor
    //@return a list of sponsoredchildreninfo
    webservice static List<SponsoredChildrenInfo> PaySetup(integer ContactId)
    {
        List<string> productTypes = new List<string>();
        productTypes.add('Sponsorship');
        productTypes.add('Designated Fund');
        productTypes.add('Recurring Gift');
        productTypes.add('One Time Gift');
        productTypes.add('Third Party');
        return GetSponsoredChildren(ContactId, productTypes);
    }
    
    //sprint 4
    //Returns all posted transactions for the last year
    //@param ContactId - the contact number of the donor
    //@return DonationHistoryInfo - information about posted transactions
    webservice static List<DonationHistoryInfo> GetPaymentInfo(integer ContactId)
    {
        List<DonationHistoryInfo> infoList = new List<DonationHistoryInfo>();
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            List<Opportunity> opps = [select id,
                                      CloseDate,
                                      Amount,
                                      Parent_Product_Sub_Type__c,
                                      Participant_Name__c
                                     from opportunity
                                     where RecordType.Name = 'Transaction'
                                     and StageName <> 'Open'
                                     and rC_Giving__Hard_Credit_Contact__r.Contact_Number__c = :contactNumber
                                     and CloseDate = LAST_N_DAYS:365
                                     order by CloseDate desc];
            
            for(Opportunity trans : opps)
            {
                DonationHistoryInfo info = new DonationHistoryInfo();
                info.TransDate = trans.CloseDate;
                info.TransAmount = trans.Amount;
                
                string description = trans.Parent_Product_Sub_Type__c + ' payment';
                if(!string.isBlank(trans.Participant_Name__c))
                    description += ' for ' + trans.Participant_Name__c;
                
                info.description = description;
                infoList.add(info);
            } 
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','GetPaymentInfo','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return infoList;
    }
    
    //sprint 4
    //get the sums of the year to date and previous year amounts 
    //when the donor type is Sponsorship, Designated Fund, Contribution, or Suspense
    //@param Contactid - the contact number of the donor
    //@return TaxTotalInfo - previous and current year totals
    webservice static TaxTotalInfo GetContactTaxTotals(integer ContactId)
    {
        TaxTotalInfo info;
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            //current Product Type implementation in NGOC is:
            //Sponsorship, Designated Fund, Recurring Gift, One Time Gift, Third Party
            //The last three could be considered Contribution types
            //There is currently no concept of "Suspense", so including all Product types in sum
            
            decimal currentYear = (decimal)[select sum(Amount) amt
                                          from opportunity
                                          where RecordType.Name = 'Transaction'
                                          and StageName <> 'Open'
                                          and rC_Giving__Hard_Credit_Contact__r.Contact_Number__c = :contactNumber
                                          and CloseDate = THIS_YEAR][0].get('amt');
            
            decimal previousYear = (decimal)[select sum(Amount) amt
                                          from opportunity
                                          where RecordType.Name = 'Transaction'
                                          and StageName <> 'Open'
                                          and rC_Giving__Hard_Credit_Contact__r.Contact_Number__c = :contactNumber
                                          and CloseDate = LAST_YEAR][0].get('amt');
        
            info = new TaxTotalInfo();
            
            if(previousYear == null)
                info.PreviousYearTotal = '0';
            else
                info.PreviousYearTotal = formatTaxAmount(previousYear);
            
            if(currentYear == null)
                info.CurrentYearTotal = '0';
            else
                info.CurrentYearTotal = formatTaxAmount(currentYear);
            //Jagjeet
            system.debug('TaxInfo ' +info);
        
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','GetContactTaxTotals','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return info;
    }
    
    //formats the tax amount 
    global static String formatTaxAmount(Decimal taxAmount){
        string formattedAmount = '';
        if(taxAmount != null){
            if(taxAmount.setScale(2) == taxAmount.setScale(0)){
              formattedAmount += taxAmount.setScale(0);
            }else {
              formattedAmount += taxAmount.setScale(2);
            }
        }
       return formattedAmount;
     }
    
    //sprint 4
    //Determines if the donor has accepted the DF handling fee
    //@param ContactId - the contact number of the donor
    //@return 'Y' or 'N' if the donor accepts the fee.
    webservice static string GetHandlingFee(integer ContactId)
    {
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            Contact donor = [select id,
                             Accept_DF_Fee__c 
                             from Contact
                             where Contact_Number__c = :contactNumber 
                             and RecordType.Name in ('Household','Organizational') limit 1];
            
            if(donor.Accept_DF_Fee__c)
                return 'Y';
            else
                return 'N';
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','GetHandlingFee','Exception');
            log.logException(ex);
            log.saveLogs();
            return 'N';
        }
    }
    
    //sprint 4
    //Updates the accept DF handling fee field
    //@param ContactId - the contact number of the donor
    //@param AcceptDfFee - string value of boolean 'Y' or 'N'
    webservice static boolean UpdateHandlingFee(integer ContactId, string AcceptDfFee)
    {
        boolean success = false;
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            Contact donor = [select id,
                             Accept_DF_Fee__c 
                             from Contact
                             where Contact_Number__c = :contactNumber 
                             and RecordType.Name in ('Household','Organizational') limit 1];
            
            if(AcceptDfFee.toLowerCase() == 'y')
                donor.Accept_DF_Fee__c = true;
            else
                donor.Accept_DF_Fee__c = false;
            
            update donor;
            success = true;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','UpdateHandlingFee','Exception');
            log.logException(ex);
            log.saveLogs();
            success = false;
        }
        
        return success;
    }
    
    //sprint 4
    //Updates the donor's email address in rC_Bios__Home_Email__c
    //@param ContactId - the contact number of the donor
    //@param Email - the email address
    //@return integer - 1 for success, 0 for failure
    webservice static integer UpdateContactEmail(integer ContactId, string Email)
    {
        integer success = 0;
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            Contact donor = [select id,
                             rC_Bios__Home_Email__c 
                             from Contact
                             where Contact_Number__c = :contactNumber 
                             and RecordType.Name in ('Household','Organizational') limit 1];
            
            donor.rC_Bios__Home_Email__c = Email;
            
            update donor;
            success = 1;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','UpdateContactEmail','Exception');
            log.logException(ex);
            log.saveLogs();
            success = 0;
        }
        
        return success;
    }
    
    //sprint 4
    //Determines the count of matching email addresses for donors
    //@param emailAddress - the email address to search for
    //@return integer - count of email addresses or zero for failure
    webservice static integer GetEmailAddressCount(string emailAddress)
    {
        integer emailCount = 0;
        
        try
        {
             emailcount = [select count()
                           from Contact
                           where (Email like :emailAddress)
                           and (recordtype.name = 'Household' or recordtype.name = 'Organizational')];
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','UpdateContactEmail','Exception');
            log.logException(ex);
            log.saveLogs();
            emailCount = 0;
        }
        
        return emailCount;
    }
    
    //sprint 4
    //Gets a list of email publications which the donor is opted in for
    //@param ContactId - the contact number of the donor
    //@return - a list of email publications that are subscribed to, translated to refcodes
    webservice static List<EmailSubscriptionsInfo> GetEmailPublications(integer ContactId)
    {
        List<EmailSubscriptionsInfo> infoList = new List<EmailSubscriptionsInfo>();
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            Contact donor = [select id,
                             No_Email_Birthday_Communications__c,
                             No_Email_Newsletters__c,
                             No_Email_Statement_Communications__c
                             from Contact
                             where Contact_Number__c = :contactNumber 
                             and RecordType.Name in ('Household','Organizational') limit 1];
            
            if(!donor.No_Email_Birthday_Communications__c)
                AddEmailSubscriptionToInfoList(infoList, 'BDAY', ContactId);
            else
                AddEmailSubscriptionToInfoList(infoList, 'BDAY', 0);
            
            if(!donor.No_Email_Newsletters__c)
                AddEmailSubscriptionToInfoList(infoList, 'EC', ContactId);
            else
                AddEmailSubscriptionToInfoList(infoList, 'EC', 0);
            
            if(!donor.No_Email_Statement_Communications__c)
                AddEmailSubscriptionToInfoList(infoList, 'SA', ContactId);
            else
                AddEmailSubscriptionToInfoList(infoList, 'SA', 0);
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','GetEmailPublications','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return infoList;
    }
    
    //adds the email subscription info to a list
    //@param infoList - the list to add to
    //@param code - the alpha character code for the publication
    //@param ContactId - the contact number of the donor
    //@return - void
    private static void AddEmailSubscriptionToInfoList(List<EmailSubscriptionsInfo> infoList, string code, integer ContactId)
    {
        EmailPublicationRefCodes__c returnCode;
        List<EmailPublicationRefCodes__c> refCodes = EmailPublicationRefCodes__c.getAll().values();
        for(EmailPublicationRefCodes__c refCode : refCodes)
            if(refCode.Code__c.toLowerCase() == code.toLowerCase())
                returnCode = refCode;
            
        EmailSubscriptionsInfo info = new EmailSubscriptionsInfo();
        info.ContId = ContactId;
        info.EpubId = integer.valueOf(returnCode.Name);
        info.Abbreviation = returnCode.Code__c;
        info.Description = returnCode.Description__c;
        infoList.add(info);
    }
    
    //sprint 4
    //Deletes all email subscriptions for a donor
    //@param Contact id - the contact number for the donor
    //@return Envelope - empty on success
    webservice static Envelope DeleteEmailSubscription(integer ContactId)
    {
        Envelope returnValue = new Envelope();
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            Contact donor = [select id,
                             No_Email_Birthday_Communications__c,
                             No_Email_Newsletters__c,
                             No_Email_Statement_Communications__c
                             from Contact
                             where Contact_Number__c = :contactNumber 
                             and RecordType.Name in ('Household','Organizational') limit 1];
            
            donor.No_Email_Birthday_Communications__c = true;
            donor.No_Email_Newsletters__c = true;
            donor.No_Email_Statement_Communications__c = true;
            update donor;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','DeleteEmailSubscription','Exception');
            log.logException(ex);
            log.saveLogs();
            returnValue.ReturnMessage = Enums.ReturnMsg.Failure;
            returnValue.ErrorMessage = ex.getMessage();
            returnValue.StackTrace = ex.getStackTraceString();
        }
        
        return returnValue;
    }
    
    //sprint 4
    //Adds an email subscription to the donor
    //@param ContactId - the contact number of the donor
    //@param epubId - the id of the email publication
    //@return Envelope - empty on success
    webservice static Envelope AddEmailSubscription(integer ContactId, integer epubId)
    {
        Envelope returnValue = new Envelope();
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            Contact donor = [select id,
                             No_Email_Birthday_Communications__c,
                             No_Email_Newsletters__c,
                             No_Email_Statement_Communications__c
                             from Contact
                             where Contact_Number__c = :contactNumber 
                             and RecordType.Name in ('Household','Organizational') limit 1];
            
            //using hard coded id values here
            //the code required to query the settings object
            //would still require a hard coded value or some sort, code or id, so doing this
            //instead of writing unnecessary code
            if(epubId == 2)
                donor.No_Email_Birthday_Communications__c = false;
            else if (epubId == 3)
                donor.No_Email_Newsletters__c = false;
            else if (epubId == 4)
                donor.No_Email_Statement_Communications__c = false;
            
            update donor;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','AddEmailSubscription','Exception');
            log.logException(ex);
            log.saveLogs();
            returnValue.ReturnMessage = Enums.ReturnMsg.Failure;
            returnValue.ErrorMessage = ex.getMessage();
            returnValue.StackTrace = ex.getStackTraceString();
        }
        
        return returnValue;
    }
    
    //sprint 4
    //Will be implemented as field history on the Contact object, not as a service
    webservice static Envelope AddEmailSubscriptionHist(integer ContactId, integer epubId, string optInOrOut)
    {
        return null;
    }
    
    //sprint 4
    //determines if the donor is opted in globally for LTE correspondence
    //@param ContactId - the contact number of the donor
    //@return LTEOptInGlobalInfo - structure containin the opt in status and date
    webservice static LTEOptInGlobalInfo GetLTEOptInGlobal(integer ContactId)
    {
        LTEOptInGlobalInfo info;
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            Contact donor = [select id,
                            LTE_Global_Is_Opted_In__c,
                            LTE_Global_Opt_In_Date__c
                            from Contact
                            where Contact_Number__c = :contactNumber
                            and RecordType.Name in ('Household','Organizational')
                            and rC_Bios__Active__c = true
                            limit 1];
            
            info = new LTEOptInGlobalInfo();
            info.Status = 'Active';
            info.ContactId = ContactId;
            info.Isoptedin = donor.LTE_Global_Is_Opted_In__c;
            info.Optindate = donor.LTE_Global_Opt_In_Date__c.format();
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','GetLTEOptInGlobal','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return info;
    } 
    
    //Validates the address through Experian API        
    webservice static ContactInfo StandardizeStreet(ContactInfo info)
    {
        ContactInfo result = info;
        
        try
        {
            //convert info.state to state abbreviation
            string stateAbbreviation = LookupService.GetStateAbbreviationFromCode(info.cdesstatprovterrid);
            
            string street = '';
            if(info.street1 != null)
                street = info.street1;

            if(info.street2 != null)
                street = street + ' ' + info.street2;

            ValidatedAddress address = 
                new ValidatedAddress(street,null,null,info.city,stateAbbreviation,info.postalcode,'USA',null,false,false);
            
            AddressValidateRestResponse response = 
                AddressValidateRestApi.VerifyAddress(address);
            
            
            if(response.verifyLevel == 'Verified')
            {
                result.IsValidAddress = true;
                result.street1 = response.fields[0].content;
                result.street2 = response.fields[1].content;
                result.city = response.fields[3].content;
                result.postalcode = response.fields[5].content;
                
                //convert state abbreviation to ref code
                result.cdesstatprovterrid = lookupservice.GetStateCodeFromAbbreviation(response.fields[4].content.toLowerCase());
            }
            else
            {
                result.IsValidAddress = false;
                result.errormessage = response.prompt;
                result.street1 = info.street1;
                result.street2 = info.street2;
                result.city = info.city;
                result.cdesstatprovterrid = info.cdesstatprovterrid;
                result.postalcode = info.postalcode;
            }
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','StandardizeStreet','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return result;
    }
    
    //sprint 5
    //Finds contacts based on dynamic criteria
    //@param info - contact info
    //@return - a list of ContactInfo - same mapping as GetContactByID
    webservice static List<ContactInfo> FindContacts(ContactInfo info)
    {
        List<ContactInfo> infoList = new List<ContactInfo>();
        
        try
        {
            List<Id> recordTypeIds = new List<Id>();
            recordTypeIds.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId());
            recordTypeIds.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Organizational').getRecordTypeId());
            string query = 'select id,Contact_Number__c,recordtype.Name,LastName,MailingCountry,CreatedDate,' + 
                           'rC_Bios__Deceased__c,Preferred_Communication_Method__c,VIP__c,FirstName,' +
                           'rC_Bios__Middle_Name__c,Salutation,Custom_Salutation__c,Envelope_Salutation__c,rC_Bios__Suffix__c, Campaign__r.Source_Code_Autonumber__c,' +
                           'rC_Bios__Preferred_Phone__c,Phone,MobilePhone,HomePhone,OtherPhone,AssistantPhone,Fax,Contact_Flag_Formula__c,' +
                           'email, rC_Bios__Preferred_Email__c,rC_Bios__Home_Email__c,rC_Bios__Work_Email__c,campaign__c,Donor_Flag__c,Delinquency_Cancelled_Spns__c,' +
                           'rC_Bios__Assistant_Email__c,rC_Bios__Other_Email__c, Board_Member__c,LastModifiedDate,LastModifiedBy.Name, ' +
                           'rC_Bios__Preferred_Mailing_Address__c, rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c, ' +
                           'rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_2__c, rC_Bios__Preferred_Mailing_Address__r.Extra_Address_1__c, ' +
                           'rC_Bios__Preferred_Mailing_Address__r.rC_Bios__City__c, rC_Bios__Preferred_Mailing_Address__r.rC_Bios__State__c, ' +
                           'rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Postal_Code__c, rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c, ' +
                           'Donor_Alliance__r.Alliance_Partner_Id__c ' +
                           'from contact where recordtypeid in :recordTypeIds';
            
            if(info.id != null && info.id > 0)
            {
                string contactNumber = string.valueOf(info.id);
                query += ' and contact_number__c = :contactNumber';
            }
            else
            {
                if(string.isNotBlank(info.firstname))
                {
                    string firstName = info.firstname;
                    query += ' and firstname like :firstName';
                }
                
                if(string.isNotBlank(info.name))
                {
                    string name = info.name;
                    query += ' and lastname like :name';
                }
                
                if(string.isNotBlank(info.email))
                {
                    string email = info.email;

                    query += ' and (rC_Bios__Home_Email__c like :email' +
                        ' or rC_Bios__Work_Email__c like :email' +
                        ' or rC_Bios__Assistant_Email__c like :email' +
                        ' or rC_Bios__Other_Email__c like :email)';
                }
                
                if(string.isNotBlank(info.street1))
                {
                    string street1 = info.street1;
                    query += ' and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c like :street1';
                }
                
                if(string.isNotBlank(info.city))
                {
                    string city = info.city;
                    query += ' and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__City__c like :city';
                }
                
                if(string.isNotBlank(info.postalcode))
                {
                    string postalcode = info.postalcode;
                    query += ' and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Postal_Code__c like :postalcode';
                }
                
                if(info.state != null)
                {
                    StateTerrProvRefCodes__c stateRefCode = 
                        StateTerrProvRefCodes__c.getValues(info.state);                                   
                    if(stateRefCode != null)
                    {
                        string state = stateRefCode.Code__c;
                        query += ' and rC_Bios__Preferred_Mailing_Address__r.rC_Bios__State__c like :state';
                    }
                }
            }
            
            system.debug('query: ' + query);
            List<Contact> donors = database.query(query);

            Map<id,rC_Bios__Contact_Address__c> contactAddressMap = new Map<id,rC_Bios__Contact_Address__c>();

            if(donors != null && donors.size() > 0)
            {
                set<id> contactIds = new set<id>();
                for(Contact donor : donors)
                    contactIds.add(donor.id);

                List<rC_Bios__Contact_Address__c> contactAddresses = [select id,
                                                                       rC_Bios__Attention_Line__c,
                                                                       rC_Bios__Street_Line_1__c,
                                                                       rC_Bios__Street_Line_2__c,
                                                                       rC_Bios__Additional_Line_1__c,
                                                                       rC_Bios__City__c,
                                                                       rC_Bios__State__c,
                                                                       rC_Bios__Postal_Code__c,
                                                                       rC_Bios__Country__c,
                                                                       rC_Bios__Address__c,
                                                                       rC_Bios__Contact__c
                                                                       from rC_Bios__Contact_Address__c
                                                                       where rC_Bios__Contact__c in :contactIds and
                                                                       rC_Bios__Preferred_Mailing__c = true];

                for(rC_Bios__Contact_Address__c address : contactAddresses)
                    contactAddressMap.put(address.rC_Bios__Contact__c, address);
                
            }
            
             
            for(Contact donor : donors)
            {
                ContactInfo donorInfo = new ContactInfo();
                rC_Bios__Contact_Address__c contactAddress = contactAddressMap.get(donor.id);
                MapContactInfo(donor, donorInfo, contactAddress);
                infoList.add(donorInfo);
            }
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','FindContacts','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return infoList;
    }
    
    //sprint 5
    //Returns the tribute contacts associated with giving opportunities
    //@param Contactid - the primary or hard credit contact on the opportunity
    //@return List<ContactInfo> - a list of Contacts that are tribute contacts
    webservice static List<ContactInfo> GetWebGiftRecipients(integer ContactId)
    {
        List<ContactInfo> infoList = new List<ContactInfo>();
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            //first get a list of opportunities for the given contact 
            //where there is a tribute contact
            List<Opportunity> opps = [select id, rC_Giving__Tribute_Contact__c
                                     from Opportunity
                                     where rC_Giving__Tribute_Contact__c != null
                                     and (rC_Giving__Primary_Contact__r.Contact_Number__c = :contactNumber or
                                         rC_Giving__Hard_Credit_Contact__r.Contact_Number__c = :contactNumber)];
            
            //create a list of contact ids to query for the list of tribute contacts
            Set<Id> contactIds = new Set<Id>();
            for(Opportunity opp : opps)
                contactIds.add(opp.rC_Giving__Tribute_Contact__c);
            
            if(contactIds.size() > 0)
            {
                List<Contact> recipients = [select id, contact_number__c, lastname, mailingcountry, mailingstreet, mailingcity,
                                           firstname, rC_Bios__Middle_Name__c, mailingstate, salutation, rC_Bios__Suffix__c
                                           from contact
                                           where id in :contactIds
                                           order by lastname asc];
                
                system.debug('----recipients---' + recipients);
                
                for(Contact recip : recipients)
                {
                    ContactInfo info = new ContactInfo();
                    
                    info.id = integer.valueOf(recip.Contact_Number__c);
                    info.name = recip.LastName;
                    
                    List<CountriesRefCodes__c> countryCodes = CountriesRefCodes__c.getAll().values();
                    for(CountriesRefCodes__c code : countryCodes)
                        if(recip.MailingCountry.toLowerCase() == code.Description__c.toLowerCase())
                            info.ctrycode = code.Name;
                    
                    info.street1 = recip.MailingStreet;
                    //info.street2, 3, 4
                    
                    info.city = recip.MailingCity;
                    info.firstname = recip.FirstName;
                    info.middlename = recip.rC_Bios__Middle_Name__c;
                    
                    List<StateTerrProvRefCodes__c> stateRefCodes = StateTerrProvRefCodes__c.getAll().values();
                    for(StateTerrProvRefCodes__c code: stateRefCodes)
                        if(code.Description__c.toLowerCase() == recip.MailingState.toLowerCase())
                            info.cdesstatprovterrid = integer.valueOf(code.Name);

                    List<WebSuffixRefCodes__c> suffixRefCodes = WebSuffixRefCodes__c.getAll().values();
                    for(WebSuffixRefCodes__c code: suffixRefCodes)
                        if(code.Description__c.toLowerCase() == recip.rC_Bios__Suffix__c.toLowerCase())
                            info.clstnmsuffixid = integer.valueOf(code.Name);
                    
                    List<WebTitlesRefCodes__c> titleRefCodes = WebTitlesRefCodes__c.getAll().values();
                    for(WebTitlesRefCodes__c code: titleRefCodes)
                        if(code.Description__c.toLowerCase() == recip.Salutation.toLowerCase())
                            info.clstnmtitleid = integer.valueOf(code.Name);
                    
                    infoList.add(info);
                }
            }
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','GetWebGiftRecipients','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return infoList;
    }
    
    //sprint 5
    //Web gift recipients are contacts so mirror call to AddContact
    //@param Info - contact information
    //@return integer - the new ContactId
    webservice static integer AddWebGiftRecipient(ContactInfo info)
    {
        try
        {
            Envelope result = DonorPortalService.AddContact(info);
            return result.NewId;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','AddWebGiftRecipient','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;
        }
    }
    
    //sprint 5
    //Web gift recipients are contacts so mirror call to UpdateContact
    //@param Info - contact information
    //@return boolean - true on success, false on failure
    webservice static boolean UpdateWebGiftRecipient(ContactInfo info)
    {
        try
        {
            ContactUpdateInfo uinfo = new ContactUpdateInfo();
            uinfo.firstname = info.firstname;
            uinfo.name = info.name;
            uinfo.middlename = info.middlename;
            uinfo.street1 = info.street1;
            uinfo.city = info.city;
            uinfo.cdesstatprovterrid = info.cdesstatprovterrid;
            uinfo.postalcode = info.postalcode;
            uinfo.ctrycode = info.ctrycode;
            uinfo.clstnmsuffixid = info.clstnmsuffixid;
            uinfo.clstnmtitleid = info.clstnmtitleid;
            
            integer result = DonorPortalService.UpdateContact(uinfo);
            if(result == 1)
                return true;
            else
                return false;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','UpdateWebGiftRecipient','Exception');
            log.logException(ex);
            log.saveLogs();
            return false;
        }
    }
    
    //sprint #5
    webservice static boolean DeleteWebGiftRecipient(integer ContactId, integer GiftRecipientId)
    {
        return false;
    }

    //updates Ektron info for a donor
    public static EktronService.EktronUpdateInfo UpsertEktronAccount(id donorId, string password)
    {
        EktronService.EktronUpdateInfo result = new EktronService.EktronUpdateInfo();

        try
        {
            EktronServiceSettings__c settings = EktronServiceSettings__c.getOrgDefaults();
            EktronService.UpdateServiceSoap service = new EktronService.UpdateServiceSoap();
            service.endpoint_x = settings.Endpoint__c;

            EktronService.EktronUpdateInfo info = new EktronService.EktronUpdateInfo();

            Contact contact = [select id, contact_number__c, email, firstname, lastname, 
                               recordtype.name 
                               from contact where id = :donorid limit 1];

            info.DonorId = integer.valueOf(contact.contact_number__c);
            info.DonorEmail = contact.email;
            info.DonorFirstName = contact.firstname;
            info.DonorLastName = contact.lastname;
            
            if(contact.recordtype.name == 'Household')
                info.DonorContactType = 'INDV';
            else
                info.DonorContactType = 'ORG';

            //if(contact.rC_Bios__Preferred_Mailing_Address__c != null && contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Attention_Line__c != null)
             //   info.DonorCareOf = contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Attention_Line__c;
            
            if(string.isNotBlank(password))
                info.EktronPassword = password;
            
            result = service.UpsertEktronAccount(settings.Username__c, settings.Password__c, info);
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = new apexLogHandler.apexLog('DonorPortalService','UpsertEktronAccount','Exception');
            log.logException(ex);
            log.saveLogs();
            result.ErrorMessage = ex.getMessage();
            result.StackTrace = ex.getStackTraceString();
        }

        return result;
    }

}