global class PaymentMethodServices {
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
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            List<Opportunity> opps = [select id,
                                      rC_Giving__Primary_Contact__c,
                                      rC_Giving__Hard_Credit_Contact__c, 
                                      rC_Giving__Primary_Contact__r.Contact_Number__c,
                                      rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Issuer__c,
                                      rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,
                                      rC_Giving__Payment_Method_Selected__r.Payment_Method_Number__c,
                                      Product_Type__c,
                                      rC_Giving__GAU__r.Name,
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
                                      Participant__r.Community__r.BillingStreet, 
                                      Participant__r.Community__r.BillingCity, 
                                      Participant__r.Community__r.BillingState, 
                                      Participant__r.Community__r.BillingPostalCode, 
                                      Participant__r.Community__r.BillingCountry,
                                      Participant__r.rC_Sponsorship__Sponsorship_Status__c,
                                      Paid_Through_Date__c,
                                      Amount_Owed__c,
                                      Participant__r.rC_Bios__Birth_Month__c,
                                      Participant__r.Short_Name__c,
                                      Campaign_Source_Number__c,
                                      All_Child_Correspondence__c,
                                      AGP_Method__c 
                                     from Opportunity
                                     where RecordType.Name = 'Donation'
                                     and rC_Giving__Primary_Contact__r.Contact_Number__c = :contactNumber
                                     and Product_Type__c in :productTypes
                                     and Participant__r.rC_Sponsorship__Sponsorship_Status__c in ('Sponsored', 'Pre-Sponsored', 'Unavailable')];
            
            for(Opportunity opp : opps)
            {
                
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
                    info.AccountNum = opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number_Last_4__c;
                    
                    List<CreditTypeRefCodes__c> cardTypeCodes = CreditTypeRefCodes__c.getAll().values();
                    for(CreditTypeRefCodes__c code : cardTypeCodes)
                        if(code.Description__c == opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Issuer__c)
                            info.CardType = code.Code__c;
                    
                    //TODO: info.conttype - standard accounts or gift account
                    // 2 character code value from ContactAcctType refcode
                    //No single field on opportunity that contains this info
                        
                    info.ContId = integer.valueOf(opp.rC_Giving__Primary_Contact__r.Contact_Number__c);
                    //TODO: info.AgpType = opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c translated
                    //if(opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c == )
                    //These values do not seem to line up with AgpType completely
                    
                    info.AgpId = integer.valueOf(opp.rC_Giving__Payment_Method_Selected__r.Payment_Method_Number__c);
                    
                    List<DonationTypeRefCodes__c> acctTypeCodes = DonationTypeRefCodes__c.getAll().values();
                    for(DonationTypeRefCodes__c code : acctTypeCodes)
                        if(code.Description__c == opp.Product_Type__c)
                            info.AcctType = code.Code__c;
                    
                    info.FinCode = integer.valueOf(opp.rC_Giving__GAU__r.Name);
                    info.Description = opp.Description__c;
                    info.Amount = opp.rC_Giving__Giving_Amount__c;
                   
                    List<PaymentFrequencyRefCodes__c> payFreqCodes = PaymentFrequencyRefCodes__c.getAll().values();
                    for(PaymentFrequencyRefCodes__c code : payFreqCodes)
                        if(code.Description__c == opp.rC_Giving__Giving_Frequency__c)
                            info.Freq = code.Code__c;                   
                    
                    info.sponsorshipId = integer.valueOf(opp.rC_Sponsorship__Opportunity_Group_Id__c);
                    info.NoId = integer.valueOf(opp.Participant__r.National_Office_Number__c);
                    info.ChildNbr = integer.valueOf(opp.Participant__r.Child_Number__c);
                    info.CaseNbr = integer.valueOf(opp.Participant__r.Participant_Case_Number__c);
                    info.ChildName = opp.Participant__r.Name;
                    info.Birthday = opp.Participant__r.Birthdate.format();
                    info.AgeYear = integer.valueOf(opp.Participant__r.rC_Bios__Age__c);
                    info.AgeMonth = integer.valueOf(opp.Participant__r.Age_Months_Additional__c); 
                    
                    List<CountriesRefCodes__c> countryCodes = CountriesRefCodes__c.getAll().values();
                    for(CountriesRefCodes__c  code : countryCodes)
                        if(code.Description__c == opp.Participant__r.National_Office__r.NO_Country__c)
                            info.CtryCode = code.Name;  
                    
                    info.CtryDesc = opp.Participant__r.National_Office__r.NO_Country__c;
                    info.ProjId = integer.valueOf(opp.Participant__r.Community_Number__c);
                    info.ProjDesc = opp.Participant__r.Community__r.Name;
                    info.Address = opp.Participant__r.Community__r.BillingStreet + '\n'
                        + opp.Participant__r.Community__r.Billingcity + ', '
                        + opp.Participant__r.Community__r.BillingState + '  '
                        + opp.Participant__r.Community__r.BillingPostalCode + '\n'
                        + opp.Participant__r.Community__r.BillingCountry;
                    
                    
                    List<ChildStatusRefCodes__c> statusCodes = ChildStatusRefCodes__c.getAll().values();
                    for(ChildStatusRefCodes__c  code : statusCodes)
                        if(code.Description__c == opp.Participant__r.rC_Sponsorship__Sponsorship_Status__c)
                            info.Status = code.Code__c;
                    
                    //info.DueDate = Paid_Through_Date__c (last date of month + 1 day)
                    Integer numberOfDays = Date.daysInMonth(opp.Paid_Through_Date__c.year(), opp.Paid_Through_Date__c.month());
                    Date dueDate = Date.newInstance(opp.Paid_Through_Date__c.year(), opp.Paid_Through_Date__c.month(), numberOfDays).addDays(1);
                    info.DueDate = dueDate.format();
                    
                    info.PaidThru = opp.Paid_Through_Date__c.format();
                    info.AmtDue = opp.Amount_Owed__c;
                    info.birthdayMonth = integer.valueOf(opp.Participant__r.rC_Bios__Birth_Month__c);
                    //TODO: info.SponsorshipType - may be refcode, heath to check
                    info.ShortName = opp.Participant__r.Short_Name__c;
                    info.MktacId = integer.valueOf(opp.Campaign_Source_Number__c);
                    //info.ChildPhoto - not in new system
                    info.LTEOptIn = opp.All_Child_Correspondence__c;
                    
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
        }
        
        return infoList;
    }
    
    //-----------------------------------------from transactionService---------------
    
    //Determines if an AGP (payment method) is active
    //@param - agpid - the salesforce opportunity code
    //@param - contact id - contact number which may also look up to account
    //@return boolean - if the payment method is active
    webservice static boolean IsAGPActive(integer agpid, integer ContactId)
    {
        try
        {
            string contactNumber = string.valueOf(ContactId);
            string paymentMethodNumber = string.valueOf(agpid);
            
            Contact contact = [select id, accountid
                              from contact
                              where Contact_Number__c = :contactNumber
                              LIMIT 1];
            
            rC_Giving__Payment_Method__c method = [select id,
                                                   rC_Giving__Is_Active__c
                                                  from rC_Giving__Payment_Method__c
                                                  where Payment_Method_Number__c = :paymentMethodNumber
                                                   and rC_Giving__Payment_Type__c in ('EFT','Charge Card')
                                                   and (rC_Giving__Account__c = :contact.accountid 
                                                        or rC_Giving__Contact__c = :contact.id)
                                                  LIMIT 1];
            
            return method.rC_Giving__Is_Active__c;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','IsAGPActive','Exception');
            log.logException(ex);
            log.saveLogs();
            return false;
        }
    }
    
    //submits a transaction to the batch upload object in NGOC
    //@param TransactionInfo - data about the transaction.  If the contact exists,
    //it will have a non-zero ContactId.
    //@return Envelope - non-zero for transaction id on success, zero on error
    webservice static Envelope SubmitTransactionToQueue(TransactionInfo TransInfo)
    {
        Envelope returnValue = new Envelope();
        TransInfo.CVV = '';
        TransInfo.ReturnMessage = Enums.ReturnMsg.Success;
        
        try
        {
            rC_Connect__Batch_Upload__c queue = new rC_Connect__Batch_Upload__c();
            
            //TransInfo.TransactionExceptionSummary;
            //TransInfo.TransactionCreateDate;
            //TransInfo.TransactionModifiedDate;
            //TransInfo.TransactionUserCreate;
            //TransInfo.TransactionUserModified;
            //TransInfo.TransactionBetweenDate;
            //TransInfo.TransactionUserComments;
            //TransInfo.TransactionStatus;
            //TransInfo.MessageId;
            //TransInfo.Errors;
            //TransInfo.ContactErrorList;
            
            
            //map donor info.
            //if the donorid exists, query for donor and put SFDC id in fields
            //if no donor number, map to fields for new donor
            if(TransInfo.DonorId != 0)
            {
                string contactNumber = string.valueOf(TransInfo.DonorId);
                Contact donor = [select id, AccountId
                                 from contact
                                 where Contact_Number__c = :contactNumber
                                 LIMIT 1];
                
                queue.rC_Connect__HardCreditContact__c = donor.id;
                queue.rC_Connect__HardCreditAccount__c = donor.AccountId;
                queue.rC_Connect__Batch_Upload_Contact_1_Matched__c = donor.id;
                queue.rC_Connect__Batch_Upload_Account_Matched__c = donor.AccountId;
            }
            else
            {
                //TransInfo.DonorContactType;?
                //TransInfo.DonorOriginCode;?
                //TransInfo.DonorMarketingId;?
                
                queue.rC_Connect__Contact_1_First_Name__c = TransInfo.DonorFirstName;
                queue.rC_Connect__Contact_1_Last_Name__c = TransInfo.DonorLastName;
                
                //TransInfo.DonorSuffixId; rC_Connect__Contact_1_Suffix__c 
                
                if(TransInfo.DonorTitleId != null)
                {
                    WebTitlesRefCodes__c titleRefCode = 
                    WebTitlesRefCodes__c.getValues(string.valueOf(TransInfo.DonorTitleId));                                   
                    if(titleRefCode != null)
                        queue.rC_Connect__Contact_1_Title__c = titleRefCode.Description__c;
                }
                
                
                queue.rC_Connect__Address_Type__c = 'Home';
                queue.rC_Connect__Address_Preferred_Billing__c = true;
                queue.rC_Connect__Address_Preferred_Mailing__c = true;
                //TransInfo.DonorCareOf; ?
                queue.rC_Connect__Address_Street_Line_1__c = TransInfo.DonorStreet1;
                queue.rC_Connect__Address_Street_Line_2__c = TransInfo.DonorStreet2;
                //TransInfo.DonorExtraAddress1;?
                //TransInfo.DonorExtraAddress2;?
                //TransInfo.DonorExtraAddress3;?
                queue.rC_Connect__Address_ZIP__c = TransInfo.DonorPostalCode;
                queue.rC_Connect__Address_City__c = TransInfo.DonorCity;
               
                queue.rC_Connect__Address_State_Number__c = string.valueOf(TransInfo.DonorState);
                
                if(TransInfo.DonorState != null)
                {
                    StateTerrProvRefCodes__c stateRefCode = 
                        StateTerrProvRefCodes__c.getValues(string.valueOf(TransInfo.DonorState));                                   
                    if(stateRefCode != null)
                        queue.rC_Connect__Address_State__c = stateRefCode.Code__c;
                }
                
                
                queue.rC_Connect__Address_Country__c = TransInfo.DonorCountryCode;
                
                if(TransInfo.DonorCountryCode != null)
                {
                    CountriesRefCodes__c countryRefCode = 
                        CountriesRefCodes__c.getValues(string.valueOf(TransInfo.DonorCountryCode));                                   
                    if(countryRefCode != null)
                        queue.rC_Connect__Address_Country_Name__c = countryRefCode.Description__c;
                }
                
                
                queue.rC_Connect__Contact_1_Preferred_Phone__c = 'Home';
                queue.rC_Connect__Contact_1_Phone_1_Type__c = 'Home';
                queue.rC_Connect__Contact_1_Phone_1__c = TransInfo.DonorPhoneAreaCode + TransInfo.DonorPhone;
                
                if(TransInfo.DonorPhoneExtension != 0)
                   queue.rC_Connect__Contact_1_Phone_1__c += ' x' + string.valueOf(TransInfo.DonorPhoneExtension);
                   
                queue.rC_Connect__Contact_1_Email_Type__c = 'Home';
                queue.rC_Connect__Contact_1_Email__c = TransInfo.DonorEmail;
                //TransInfo.DonorMotivatedById; ?
            }
            
            //Payment Method info
            //if the payment method number specified, query for payment method
            //and update the matched payment method field
            //otherwise, fill in data for new payment method
            if(TransInfo.PaymentId != 0)
            {
                string paymentMethodNumber = string.valueOf(TransInfo.PaymentId);
                rC_Giving__Payment_Method__c method = [select id
                                                       from rC_Giving__Payment_Method__c
                                                       where Payment_Method_Number__c = :paymentMethodNumber];
                
                queue.rC_Connect__Batch_Upload_Payment_Method_Matched__c = method.id;
            }
            else
            {
                //TransInfo.PaymentType;
                queue.rC_Connect__Payment_Method_Account_Number__c = TransInfo.PaymentAccountNumber;
                //TransInfo.PaymentDonorId;
                //TransInfo.PaymentCardType; rC_Connect__Payment_Method_Card_Issuer__c translated
                queue.rC_Connect__Payment_Method_Card_Holder_Name__c = TransInfo.PaymentCardholderFullName; 
                //TransInfo.PaymentCardholderZipcode;
                //TransInfo.PaymentDateExpiration;
                //TransInfo.PaymentDateDfTaken;
                //TransInfo.TransactionType;
                //TransInfo.PaymentErrorList;
                //TransInfo.CVV;
                //TransInfo.BankName;
                //TransInfo.MaskedAccountNum;
                //TransInfo.PaymentTransitNumber;
            }
            
            //TODO: refactor to create multiple batch upload
            //records: 1 for each purchased donation
            //may need to discuss that contacts and payment methods
            //will always be created first before submitting transaction
            for(DonationInfo purchase : TransInfo.PurchasedDonations)
            {
                //purchase.PaySchedId;?
                //purchase.HasAnchor;?
                //purchase.EmailSubscriptions;?
                //purchase.isVerified;?
                queue.rC_Connect__Giving_Giving_Amount__c = purchase.Amount;
                //purchase.FinCode;?
                //purchase.NationalOffice; - need custom field and mapping
                queue.Participant_Number__c = string.valueOf(purchase.ChildNumber);
                purchase.Contact.Id = TransInfo.DonorId;
                //purchase.SponsorshipId;?
                //purchase.mktacid; rC_Connect__Batch_Upload_Campaign_Matched__c query for id
                //purchase.PaymentFrequency; rC_Connect__Giving_Giving_Frequency__c - need input format
                //purchase.ProjectId; - need custom field for community and mapping
                //purchase.TransType; - need input format
                //purchase.Title; ?
                //purchase.ErrorList; ?
                //purchase.DFMessage; ?
                //purchase.DFEffectiveDateType; ?
                //purchase.DeactivatePaySched; ?
                //purchase.TransferAGP; ?
                //purchase.CartQuantity;
            }
            
            //TransInfo.TransInfoID;
            //TransInfo.AdminContactId;
            //TransInfo.doesAcceptTerms;
            //TransInfo.doesAcceptACHTerms;
            //TransInfo.isReactivating;
            //TransInfo.isVerifiedDonor;
            //TransInfo.isVerifiedPayment;
            //TransInfo.isVerifiedDonations;
            //TransInfo.isDirtyDonor;
            //TransInfo.isDirtyPayment;
            //TransInfo.doesAcceptDfFee;
            //TransInfo.validateForSponsorship;
            //TransInfo.BypassHouseHoldMatch;
            //TransInfo.CanSponsorChildren;
            //TransInfo.IsEncrypted;
            //TransInfo.IsAgpTransferred;
            //TransInfo.IsDeactivatePaySched;
            //TransInfo.ContactMatchType;
            //TransInfo.IsGuest;
            //TransInfo.IsAdmin;
            //TransInfo.IsImpersonate;
            //TransInfo.HasAGPs;
            //TransInfo.TransactionSuccessful;
            //TransInfo.CreateEktronAccount;
            //TransInfo.EktronPassword;
            
            
            
            insert queue;
            
            queue = [select Transaction_Number__c from rC_Connect__Batch_Upload__c
                    where id = :queue.id limit 1];
            
            TransInfo.TransactionId = integer.valueOf(queue.Transaction_Number__c);
            returnValue.NewID = TransInfo.TransactionId;
            returnValue.TransOut = TransInfo;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','SubmitTransactionToQueue','Exception');
            log.logException(ex);
            log.saveLogs();
            returnValue.ReturnMessage = Enums.ReturnMsg.Failure;
            returnValue.ErrorMessage = ex.getMessage();
            returnValue.StackTrace = ex.getStackTraceString();
        }
        
        return returnValue;
    }
    
    //sprint 4
    //All active payment methods of type ACH or CC for a given contact
    //@param ContactId - the contact number of the donor
    //@return List<AgpInfo> - a list of payment method information
    webservice static List<AgpInfo> GetAGPByContactId(integer ContactId)
    {
        List<AgpInfo> infoList = new List<AgpInfo>();
        
        try
        {
            string contactNumber = string.valueOf(ContactId);
            
            Contact contact = [select id, accountid
                              from contact
                              where Contact_Number__c = :contactNumber
                              LIMIT 1];
            
            List<rC_Giving__Payment_Method__c> methods = [select id,
                                                          Account_Number_E__c,
                                                          Payment_Method_Number__c,
                                                          rC_Giving__Payment_Type__c,
                                                          rC_Giving__Account_Number_Last_4__c,
                                                          CreatedDate,
                                                          rC_Giving__Card_Issuer__c,
                                                          rC_Giving__Billing_Contact_Name__c,
                                                          rC_Giving__Billing_Postal_Code__c,
                                                          rC_Giving__Card_Expiration_Month__c,
                                                          rC_Giving__Card_Expiration_Year__c,
                                                          rC_Giving__Routing_Number__c,
                                                          rC_Giving__Bank_Name__c
                                                          from rC_Giving__Payment_Method__c
                                                          where rC_Giving__Payment_Type__c in ('EFT','Charge Card')
                                                          and rC_Giving__Is_Active__c = true
                                                          and (rC_Giving__Account__c = :contact.accountid 
                                                              or rC_Giving__Contact__c = :contact.id)];
            
            for(rC_Giving__Payment_Method__c method : methods)
            {
                AgpInfo info = new AgpInfo();
                info.AccountNumberE = method.Account_Number_E__c;
                info.Id = integer.valueOf(method.Payment_Method_Number__c);
                
                //tranlate to refcode info.AgpType
                //Not using custom settings because descriptions do not match between agptype refcodes
                //and there are only two possible values.
                if(method.rC_Giving__Payment_Type__c == 'EFT')
                    info.AgpType = 'DB';
                else
                    info.AgpType = 'CR';
                                
                info.AccountNumber = method.rC_Giving__Account_Number_Last_4__c;
                info.DateCreated = method.CreatedDate.format();
                info.Active = 'A'; //because we are only querying active records
                info.ContactId = ContactId;
                
                //translate to refcode info.CardType
                List<CreditTypeRefCodes__c> codes = CreditTypeRefCodes__c.getAll().values();
                    for(CreditTypeRefCodes__c code : codes)
                        if(code.Description__c == method.rC_Giving__Payment_Type__c)
                            info.CardType = code.Code__c;
                
                info.FullName = method.rC_Giving__Billing_Contact_Name__c;
                info.CardholderZipcode = method.rC_Giving__Billing_Postal_Code__c;
                info.DateExpiration = method.rC_Giving__Card_Expiration_Month__c + '/' +
                                      method.rC_Giving__Card_Expiration_Year__c;
                info.TransitNumber = method.rC_Giving__Routing_Number__c;
                info.BankName = method.rC_Giving__Bank_Name__c;
                
                infoList.add(info);
            }
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','GetAGPByContactId','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return infoList;
    }
    
      //sprint 4
    //Get a payment method based on the id number
    //@param id - the id number of the payment
    //@return AgpInfo - info about the payment method.  Returns null on error.
    webservice static AgpInfo GetAgpByID(integer id)
    {
        try
        {
            string paymentMethodNumber = string.valueOf(id);
            
            rC_Giving__Payment_Method__c method = [select id,
                                                   Account_Number_E__c,
                                                   Payment_Method_Number__c,
                                                   rC_Giving__Payment_Type__c,
                                                   rC_Giving__Account_Number_Last_4__c,
                                                   CreatedDate,
                                                   rC_Giving__Card_Issuer__c,
                                                   rC_Giving__Billing_Contact_Name__c,
                                                   rC_Giving__Billing_Postal_Code__c,
                                                   rC_Giving__Card_Expiration_Month__c,
                                                   rC_Giving__Card_Expiration_Year__c,
                                                   rC_Giving__Routing_Number__c,
                                                   rC_Giving__Bank_Name__c,
                                                   rC_Giving__Is_Active__c,
                                                   rC_Giving__Contact__r.Contact_Number__c
                                                   from rC_Giving__Payment_Method__c
                                                   where Payment_Method_Number__c = :paymentMethodNumber
                                                   LIMIT 1];
            
            AgpInfo info = new AgpInfo();
            
            info.AccountNumberE = method.Account_Number_E__c;
            info.Id = integer.valueOf(method.Payment_Method_Number__c);
            
            //tranlate to refcode info.AgpType
            //Not using custom settings because descriptions do not match between agptype refcodes
            //and there are only two possible values.
            if(method.rC_Giving__Payment_Type__c == 'EFT')
                info.AgpType = 'DB';
            else
                info.AgpType = 'CR';
            
            info.AccountNumber = method.rC_Giving__Account_Number_Last_4__c;
            info.DateCreated = method.CreatedDate.format();
            
            if(method.rC_Giving__Is_Active__c)
                info.Active = 'A';
            else
                info.Active = 'I';
            
            if(method.rC_Giving__Contact__r.Contact_Number__c != null)
                info.ContactId = integer.valueOf(method.rC_Giving__Contact__r.Contact_Number__c);
            
            //translate to refcode info.CardType
            List<CreditTypeRefCodes__c> codes = CreditTypeRefCodes__c.getAll().values();
            for(CreditTypeRefCodes__c code : codes)
                if(code.Description__c == method.rC_Giving__Payment_Type__c)
                    info.CardType = code.Code__c;
            
            info.FullName = method.rC_Giving__Billing_Contact_Name__c;
            info.CardholderZipcode = method.rC_Giving__Billing_Postal_Code__c;
            info.DateExpiration = method.rC_Giving__Card_Expiration_Month__c + '/' +
                method.rC_Giving__Card_Expiration_Year__c;
            info.TransitNumber = method.rC_Giving__Routing_Number__c;
            info.BankName = method.rC_Giving__Bank_Name__c;
            
            return info;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','GetAgpByID','Exception');
            log.logException(ex);
            log.saveLogs();
            return null;
        }
    }
    
     //sprint 4
    //determine if the account number is a duplicate
    //@param ContactId - the contact number of the donor
    //@param agpId - the id number of the payment method
    //@param accountNumber - the account number to search for
    //@param transitNumber - the routing transit number of the account to search for if ACH
    //@param isActive - whether the payment method is active or not
    //@param acctType - ACH or otherwise
    //@return 0 for no results or exception, 1 for duplicate
    webservice static integer IsDuplicateAccountNumber(integer ContactId, integer agpId, string accountNumber, 
                                                       string transitNumber, boolean isActive, string acctType)
    {
        try
        {
            string query = 'select count() as "AccountCount" from rC_Giving__Payment_Method__c where ' +
                           'Account_Number_E__c = :accountNumber and ' +
                           'rC_Giving__Is_Active__c = :isActive';
            
            if(ContactId != 0)
            {
                string contactNumber = string.valueOf(ContactId);
            
                Contact donor = [select id, accountid
                                 from contact
                                 where Contact_Number__c = :contactNumber
                                 LIMIT 1];
                
                Id donorId = donor.id;
                Id accountId = donor.AccountId;
                
                query += ' and (rC_Giving__Account__c = :accountId or rC_Giving__Contact__c = :donorId)';
            }
            
            if(agpId != 0)
            {
                string agpNumber = string.valueOf(agpId);
                query += ' and Payment_Method_Number__c = :agpNumber';
            }
            
            if(acctType == 'ACH')
            {
                query += ' and rC_Giving__Routing_Number__c = :transitNumber';
            }
            
            integer accountCount = 0;
            
            List<AggregateResult> results = database.query(query);
            
            if(results.size() != 0)
                accountCount = integer.valueOf(results[0].get('AccountCount'));
                
            if(accountCount > 0)
                return 1;
            else
                return 0;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','IsDuplicateAccountNumber','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;
        }
    }
     //sprint 4
    //adds a new payment method
    //@param info - information about the payment method
    //@return envelope - contains NewId on success, error info on failure
    webservice static Envelope AddAgp(AgpInfo info)
    {
        Envelope returnValue = new Envelope();
        
        try
        {
            rC_Giving__Payment_Method__c agp = new rC_Giving__Payment_Method__c();
            
            if(info.AgpType == 'DB')
                agp.rC_Giving__Payment_Type__c = 'ACH';
            else if(info.AgpType == 'CR')
                agp.rC_Giving__Payment_Type__c = 'Charge Card';
            
            agp.Account_Number__c = info.AccountNumber;
            
            string contactNumber = string.valueOf(info.ContactId);
            
            Contact donor = [select id, accountid
                             from contact
                             where Contact_Number__c = :contactNumber
                             LIMIT 1];
            
            agp.rC_Giving__Account__c = donor.AccountId;
            agp.rC_Giving__Contact__c = donor.id;
            
            List<CreditTypeRefCodes__c> codes = CreditTypeRefCodes__c.getAll().values();
            for(CreditTypeRefCodes__c code : codes)
                if(code.Code__c == info.CardType)
                    agp.rC_Giving__Card_Issuer__c  = code.Description__c;
            
            agp.rC_Giving__Card_Holder_Name__c = info.FullName;
            agp.rC_Giving__Billing_Postal_Code__c = info.CardholderZipcode;
            
            string[] expireDate = info.DateExpiration.split('/');
            agp.rC_Giving__Card_Expiration_Month__c = expireDate[0];
            agp.rC_Giving__Card_Expiration_Year__c = expireDate[1];
            
            agp.rC_Giving__Routing_Number__c = info.TransitNumber;
            
            insert agp;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','AddAgp','Exception');
            log.logException(ex);
            log.saveLogs();
            returnValue.ReturnMessage = Enums.ReturnMsg.Failure;
            returnValue.ErrorMessage = ex.getMessage();
            returnValue.StackTrace = ex.getStackTraceString();
        }
        
        return returnValue;
    }
    //sprint 4
    //updates the status of a payment method to active or inactive
    //@param info - the number and status of the payment method
    webservice static integer UpdateAgpStatus(AgpInfo info)
    {
        try
        {
            string paymentMethodNumber = string.valueOf(info.id);
            
            rC_Giving__Payment_Method__c agp = [select id,
                                                rC_Giving__Is_Active__c
                                               from rC_Giving__Payment_Method__c
                                               where Payment_Method_Number__c = :paymentMethodNumber];
            
            if(info.Active == 'A')
                agp.rC_Giving__Is_Active__c = true;
            else
                agp.rC_Giving__Is_Active__c = false;
            
            update agp;
            return 1;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','UpdateAgpStatus','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;
        }
    }
}