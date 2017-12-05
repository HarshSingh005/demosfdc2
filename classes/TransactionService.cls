/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TransactionService
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Transaction web service for Childfund.org website
 * Created Date : 02/24/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/24/2016                   Karl Houseknecht        Created
 * 10/27/2016                   Karl Houseknecht        Work in progress - refactoring web transaction processing
 **********************************************************************************************************/
global class TransactionService 
{
    //Returns the community number (project id) for a child
    //@param integer noid - the national office number for the child
    //@param integer childNbr - the unique child number for the child
    //@return - boolean: true for locked, false if unlocked or error
    webservice static integer GetProjectID(integer NOID, integer childNbr)
    {
        try
        { 
            Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
            
            string nationalOfficeId = string.valueOf(noid);
            string childNumber = string.valueOf(childNbr);
            
            Contact child = [select id, 
                            Community_Number__c  
                            from Contact
                            where recordtypeid = :participantRecordTypeId
                            and National_Office_Number__c = :nationalOfficeId
                            and Child_Number__c = :childNumber
                            LIMIT 1];
            
            
            return integer.valueOf(child.Community_Number__c);
            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','GetProjectID','Exception');
            log.logException(ex);
            log.saveLogs();
            return 0;
        }
    }
    
    //find a bank name. Banks are Accounts of recordtype Bank
    //@param RoutingNumber - the routing transit number. 
    //@return string - the bank name
    webservice static string GetBankName(integer RoutingNumber)
    {
        try
        {
            //because parameter is integer and a routing number
            //is a 9 digit string with a potential leading zero,
            //left pad with zero to 9 characters
            string routing = string.valueOf(RoutingNumber);
            if(routing.length() != 9)
                routing = '0' + routing;
            
            Routing_Number__c route = [select id, 
                                         Bank__r.Name 
                                         from Routing_Number__c 
                                         where Routing_Number__c = :routing LIMIT 1];
            return route.Bank__r.Name;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','GetBankName','Exception');
            log.logException(ex);
            log.saveLogs();
            return null;
        }
    }
    
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
        TransInfo.ReturnMessage = Enums.ReturnMsg.Success;
        Web_Transaction__c order;
        
        try
        {
            //create and insert the web transaction record first in case further operations
            //error out, at least the raw transaction will be captured.
            order = WebTransactionProcessing.CreateWebTransactionRecord(TransInfo);
            returnValue.NewID = TransInfo.TransactionId;

            WebTransactionProcessing.ProcessDonorContact(order, TransInfo);
            WebTransactionProcessing.ProcessPaymentMethod(order, TransInfo);
            WebTransactionProcessing.ProcessDonations(order, TransInfo);


            
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','SubmitTransactionToQueue','Exception');
            log.logException(ex);
            log.saveLogs();
            
            /* - Error messages do not return to the web site.
            returnValue.ReturnMessage = Enums.ReturnMsg.Failure;
            returnValue.ErrorMessage = ex.getMessage();
            returnValue.StackTrace = ex.getStackTraceString();
            
            //flag the web transaction record
            TransInfo.ReturnMessage = Enums.ReturnMsg.Failure;
            TransInfo.TransactionExceptionSummary = new List<string>();
            TransInfo.TransactionExceptionSummary.Add(string.valueOf(Enums.FriendlyEnums.TransactionFailed));
            TransInfo.TransactionStatus = string.valueOf(Enums.TransactionType.EXCEPTIONTrans);
            */
            //updating the order sets all related batch upload records to Flagged if presentvTh
            
            if(order != null)
            {
                order.Status__c = 'Flagged';
                XMLSerializer serializer = new XMLSerializer();
                order.Transaction_XML__c = serializer.serialize(TransInfo);
                update order;
            }
            //throw ex;
                
        }

        //create Ektron account as long as everything is good
        if(order != null && 
            order.Status__c == 'New' && 
            order.Contact__c != null &&
            order.Create_Ektron_Account__c)
        {
            DonorPortalService.UpsertEktronAccount(order.Contact__c, order.Ektron_Password__c);
        }

        returnValue.TransOut = TransInfo; 

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
                                                          rC_Giving__Card_Number_Last_4__c,
                                                          CreatedDate,
                                                          RecordType.Name,
                                                          rC_Giving__Card_Issuer__c,
                                                          rC_Giving__Billing_Contact_Name__c,
                                                          rC_Giving__Card_Holder_Name__c,
                                                          rC_Giving__Billing_Postal_Code__c,
                                                          rC_Giving__Card_Expiration_Month__c,
                                                          rC_Giving__Card_Expiration_Year__c,
                                                          rC_Giving__Routing_Number__c,
                                                          rC_Giving__Bank_Name__c
                                                          from rC_Giving__Payment_Method__c
                                                          where recordtype.name in ('EFT','Charge Card')
                                                          and rC_Giving__Is_Active__c = true
                                                          and (rC_Giving__Account__c = :contact.accountid 
                                                              or rC_Giving__Contact__c = :contact.id)];
            
            for(rC_Giving__Payment_Method__c method : methods)
            {
                AgpInfo info = new AgpInfo();
                
                info.Id = integer.valueOf(method.Payment_Method_Number__c);
                
                //tranlate to refcode info.AgpType
                //Not using custom settings because descriptions do not match between agptype refcodes
                //and there are only two possible values.
                if(method.RecordType.Name == 'EFT')
                {
                    info.AgpType = 'CH';
                    info.AccountNumber = '*' + method.rC_Giving__Account_Number_Last_4__c;
                    info.FullName = method.rC_Giving__Billing_Contact_Name__c;
                } 
                else
                {
                    info.AgpType = 'CR';
                    info.AccountNumber = '*' + method.rC_Giving__Card_Number_Last_4__c;
                    info.FullName = method.rC_Giving__Card_Holder_Name__c;

                    info.DateExpiration = method.rC_Giving__Card_Expiration_Month__c + '/' +
                                      method.rC_Giving__Card_Expiration_Year__c;
                }
                                
                info.DateCreated = method.CreatedDate.format();
                info.Active = 'A'; //because we are only querying active records
                info.ContactId = ContactId;
                
                //translate to refcode info.CardType
                List<CreditTypeRefCodes__c> codes = CreditTypeRefCodes__c.getAll().values();
                    for(CreditTypeRefCodes__c code : codes)
                        if(code.Description__c == method.rC_Giving__Card_Issuer__c)
                            info.CardType = code.Code__c;
                
                info.CardholderZipcode = method.rC_Giving__Billing_Postal_Code__c;
                
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
    //Returns any pending transaction that has not yet been processed
    //@param info - 
    //@return - transaction id and transaction status
    webservice static List<TransactionInfo> GetTransactionsByID(TransactionInfo info)
    {
        List<TransactionInfo> infoList = new List<TransactionInfo>();
        
        try
        {
            string donorNumber = string.valueOf(info.DonorId);
            
            List<Web_Transaction__c> orders = [select id,
                                        name,
                                        Contact__c,
                                        Contact_Can_Sponsor_Children__c,
                                        Contact_Care_Of__c,
                                        Contact_City__c,
                                        Contact_Country__c,
                                        Contact_Email__c,
                                        Contact_First_Name__c,
                                        Contact_Last_Name__c,
                                        Campaign__c,
                                        Contact_Motivated_By__c,
                                        Contact_Origin_Code__c,
                                        Contact_Phone__c,
                                        Contact_Postal_Code__c,
                                        Contact_State_Prov_Terr__c,
                                        Contact_Street_1__c,
                                        Contact_Street_2__c,
                                        Contact_Suffix__c,
                                        Contact_Title__c,
                                        Contact_Type__c,
                                        Contact_Validate_For_Sponsorship__c,
                                        Card_Security_Code__c,
                                        ABA_Transit_Number__c,
                                        Account_Number__c,
                                        Cardholder_Name__c,
                                        Cardholder_Zip__c,
                                        Card_Type__c,
                                        Expiration_Date__c,
                                        Payment_DF_Taken_Date__c,
                                        Payment_Type__c,
                                        Payment_Method__c,
                                        Payment_Method__r.Payment_Method_Number__c,
                                        Payment_Method__r.rC_Giving__Account_Number_Last_4__c,
                                        Payment_Method__r.rC_Giving__Card_Number_Last_4__c,
                                        Status__c,
                                        CreatedDate
                                        from Web_Transaction__c
                                        where Contact__r.Contact_Number__c = :donorNumber
                                        and Status__c not in ('Processed','Committed')];  

            if(orders.size() > 0)
            {
                Set<id> orderids = new Set<id>();
                for(Web_Transaction__c order : orders)
                    orderids.add(order.id);

                List<rC_Connect__Batch_Upload__c> donations = [select id,
                                                                    name,
                                                                    Product_Type__c,
                                                                    Product_Sub_Type__c,
                                                                    rC_Connect__Batch_Upload_Giving_Matched__c,
                                                                    rC_Connect__Batch_Upload_Giving_Matched__r.Salesforce_Opportunity_Code__c,
                                                                    rC_Connect__Giving_Record_Amount__c,
                                                                    rC_Connect__Giving_Giving_Frequency__c,
                                                                    rC_Connect__Batch_Upload_Account_Matched__c,
                                                                    rC_Connect__Batch_Upload_Campaign_Matched__c,
                                                                    rC_Connect__Batch_Upload_Campaign_Matched__r.Source_Code_Autonumber__c,
                                                                    Participant__c,
                                                                    Participant__r.Contact_Number__c,                                                                    
                                                                    DFC_Related_Opportunity__c,
                                                                    DFC_Related_Opportunity__r.Salesforce_Opportunity_Code__c,
                                                                    Receipt_Category__c,
                                                                    Web_Transaction__c,
                                                                    rC_Connect__Batch_Upload_Status__c,
                                                                    CreatedDate
                                                                from rC_Connect__Batch_Upload__c
                                                                where Web_Transaction__c in :orderids
                                                                and rC_Connect__Batch_Upload_Status__c not in ('Processed','Committed')];
                
                Map<Id,List<rC_Connect__Batch_Upload__c>> donationsMap = new Map<Id,List<rC_Connect__Batch_Upload__c>>();
                for(rC_Connect__Batch_Upload__c donation : donations)
                {
                    if(donationsMap.containsKey(donation.Web_Transaction__c))
                        donationsMap.get(donation.Web_Transaction__c).add(donation);
                    else
                    {
                        List<rC_Connect__Batch_Upload__c> donationList = new List<rC_Connect__Batch_Upload__c>();
                        donationList.add(donation);
                        donationsMap.put(donation.Web_Transaction__c, donationList);
                    }
                }

                for(Web_Transaction__c order : orders)
                {
                    TransactionInfo transInfo = new TransactionInfo();

                    string status;
                    if(order.Status__c == 'New')
                        status = 'NEW';
                    else if(order.Status__c == 'To Process')
                        status = 'QUEUED';
                    else if(order.Status__c == 'Processed' || order.Status__c == 'Committed')
                        status = 'PROCESSED';
                    else if(order.Status__c == 'Flagged' || order.Status__c == 'Suspend')
                        status = 'EXCEPTION';

                    TransInfo.TransactionStatus = status;
                    TransInfo.TransactionCreateDate = string.valueOf(order.CreatedDate);
                    TransInfo.TransactionId = integer.valueOf(order.name);
                    TransInfo.CanSponsorChildren = order.Contact_Can_Sponsor_Children__c;
                    TransInfo.DonorCareOf = order.Contact_Care_Of__c;
                    TransInfo.DonorCity = order.Contact_City__c;

                    if(string.isNotBlank(order.Contact_Country__c))
                        TransInfo.DonorCountryCode = string.valueOf(LookupService.GetCountryCodeFromAbbreviation(order.Contact_Country__c));
                
                    //order.Contact_DF_Fee_Participant__c = ?
                    TransInfo.DonorId = LookupService.GetDonorId(order.Contact__c);
                    TransInfo.DonorEmail = order.Contact_Email__c;
                    TransInfo.DonorFirstName = order.Contact_First_Name__c;
                    TransInfo.DonorLastName = order.Contact_Last_Name__c;
                    //TransInfo.DonorMarketingId = //LookupService.GetMarketingId(order.Contact_Marketing_ID__c);//this is the contact's campaign id
                    //order.Contact_Motivated_By__c = TransInfo.DonorMotivatedById; //TODO: translation to picklist value?
                    TransInfo.DonorOriginCode = order.Contact_Origin_Code__c;
                    TransInfo.DonorPhone = order.Contact_Phone__c;
                    TransInfo.DonorPostalCode = order.Contact_Postal_Code__c;
                    
                    if(order.Contact_State_Prov_Terr__c != null)
                        TransInfo.DonorState = LookupService.GetStateCodeFromAbbreviation(order.Contact_State_Prov_Terr__c);
                    
                    TransInfo.DonorStreet1 = order.Contact_Street_1__c;
                    TransInfo.DonorStreet2 = order.Contact_Street_2__c;
                    
                    if(order.Contact_Suffix__c != null)
                        TransInfo.DonorSuffixId = LookupService.GetSuffixCodeFromSuffix(order.Contact_Suffix__c);
                    
                    if(order.Contact_Title__c != null)
                        TransInfo.DonorTitleId = LookupService.GetTitleCodeFromTitle(order.Contact_Title__c);
                    
                    TransInfo.DonorContactType = order.Contact_Type__c;
                    TransInfo.validateForSponsorship = order.Contact_Validate_For_Sponsorship__c;
                    
                    //payment method on header record
                    TransInfo.CVV = order.Card_Security_Code__c;
                    TransInfo.PaymentTransitNumber = order.ABA_Transit_Number__c;
                    TransInfo.PaymentAccountNumber = order.Account_Number__c;
                    TransInfo.PaymentCardholderFullName = order.Cardholder_Name__c;
                    TransInfo.PaymentCardholderZipcode = order.Cardholder_Zip__c;
                    TransInfo.PaymentCardType = order.Card_Type__c;
                    
                    if(order.Expiration_Date__c != null)
                        TransInfo.PaymentDateExpiration = string.valueOf(order.Expiration_Date__c);
                    
                    if(order.Payment_DF_Taken_Date__c != null)
                        TransInfo.PaymentDateDfTaken = string.valueOf(order.Payment_DF_Taken_Date__c);
                    
                    TransInfo.PaymentType = order.Payment_Type__c;
                    
                    if(order.Payment_Method__c != null)
                    {
                        TransInfo.PaymentId = integer.valueOf(order.Payment_Method__r.Payment_Method_Number__c);
                        
                        if(string.isNotBlank(order.Payment_Method__r.rC_Giving__Account_Number_Last_4__c))
                            TransInfo.MaskedAccountNum = '*' + order.Payment_Method__r.rC_Giving__Account_Number_Last_4__c;

                        if(string.isNotBlank(order.Payment_Method__r.rC_Giving__Card_Number_Last_4__c))
                            TransInfo.MaskedAccountNum = '*' + order.Payment_Method__r.rC_Giving__Card_Number_Last_4__c;
                    }

                    TransInfo.PurchasedDonations = new List<DonationInfo>();
                    
                    List<rC_Connect__Batch_Upload__c> donationList = donationsMap.get(order.id);
                    if(donationList == null)
                        donationList = new List<rC_Connect__Batch_Upload__c>();

                    for(rC_Connect__Batch_Upload__c donation : donationList)
                    {
                        DonationInfo donInfo = new DonationInfo();
                        donInfo.title = donation.name;
                        donInfo.fincode = integer.valueOf(donation.Receipt_Category__c);

                        if(donation.rC_Connect__Batch_Upload_Giving_Matched__c != null)
                            donInfo.PaySchedId = integer.valueOf(donation.rC_Connect__Batch_Upload_Giving_Matched__r.Salesforce_Opportunity_Code__c);
                        
                        donInfo.amount = donation.rC_Connect__Giving_Record_Amount__c;

                        if(donation.rC_Connect__Giving_Giving_Frequency__c != null)
                            donInfo.PaymentFrequency = LookupService.GetPaymentFrequencyCodeFromFrequency(donation.rC_Connect__Giving_Giving_Frequency__c);
                        
                        if(donation.rC_Connect__Batch_Upload_Campaign_Matched__c != null)
                            donInfo.mktacid = integer.valueOf(donation.rC_Connect__Batch_Upload_Campaign_Matched__r.Source_Code_Autonumber__c);
                        
                        if(donation.Participant__c != null)
                            donInfo.childNumber = integer.valueOf(donation.Participant__r.Contact_Number__c);                                                                    
                        
                        if(donation.DFC_Related_Opportunity__c != null)
                            donInfo.SponsorshipId = integer.valueOf(donation.DFC_Related_Opportunity__r.Salesforce_Opportunity_Code__c);

                        TransInfo.PurchasedDonations.add(donInfo);
                    }

                    infoList.add(transInfo);
                }
            }
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            system.debug(ex.getMessage());
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','GetTransactionsByID','Exception');
            log.logException(ex);
            System.debug('Exception ==> ' + ex);
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
                                                   rC_Giving__Card_Number_Last_4__c,
                                                   RecordType.Name,
                                                   CreatedDate,
                                                   rC_Giving__Card_Issuer__c,
                                                   rC_Giving__Billing_Contact_Name__c,
                                                   rC_Giving__Card_Holder_Name__c,
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
            
            
            info.Id = integer.valueOf(method.Payment_Method_Number__c);
            
            //tranlate to refcode info.AgpType
            //Not using custom settings because descriptions do not match between agptype refcodes
            //and there are only two possible values.
            if(method.RecordType.Name == 'EFT')
            {
                info.AgpType = 'CH';
                info.AccountNumber = '*' + method.rC_Giving__Account_Number_Last_4__c;
                info.FullName = method.rC_Giving__Billing_Contact_Name__c;
                info.TransitNumber = method.rC_Giving__Routing_Number__c;
                info.BankName = method.rC_Giving__Bank_Name__c;
            } 
            else
            {
                info.AgpType = 'CR';
                info.AccountNumber = '*' + method.rC_Giving__Card_Number_Last_4__c;
                info.FullName = method.rC_Giving__Card_Holder_Name__c;

                info.DateExpiration = method.rC_Giving__Card_Expiration_Month__c + '/' +
                method.rC_Giving__Card_Expiration_Year__c;
                

                //translate to refcode info.CardType
                List<CreditTypeRefCodes__c> codes = CreditTypeRefCodes__c.getAll().values();
                for(CreditTypeRefCodes__c code : codes)
                    if(code.Description__c == method.rC_Giving__Card_Issuer__c)
                        info.CardType = code.Code__c;
            }

            info.DateCreated = method.CreatedDate.format();
            info.CardholderZipcode = method.rC_Giving__Billing_Postal_Code__c;
            if(method.rC_Giving__Is_Active__c)
                info.Active = 'A';
            else
                info.Active = 'I';
            
            if(method.rC_Giving__Contact__r.Contact_Number__c != null)
                info.ContactId = integer.valueOf(method.rC_Giving__Contact__r.Contact_Number__c);
            
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
    //updates a field on Contact that initiates a workflow rule to send
    //password reset email
    //@param TransInfo - information about the contact to send email to
    webservice static void SendPasswordResetEmail(TransactionInfo TransInfo)
    {
        try
        {
            string contactNumber = string.valueOf(TransInfo.DonorId);
            
            Contact donor = [select id,
                            rC_Bios__Home_Email__c,
                            Password_Reset__c
                            from Contact
                            where Contact_Number__c = :contactNumber
                            and RecordType.Name in ('Household','Organization')
                            and rC_Bios__Active__c = true
                            limit 1];
            
            //updating the home email address because the workflow rule
            //needs the email to reside in a field
            donor.rC_Bios__Home_Email__c = TransInfo.DonorEmail;
            donor.Password_Reset__c = true;
            update donor;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','SendPasswordResetEmail','Exception');
            log.logException(ex);
            log.saveLogs();
        }
    }
    
    //sprint 4
    //updates a field on Contact that initiates a workflow rule to send
    //website registration email
    //@param TransInfo - information about the contact to send email to
    webservice static void SendRegistrationEmail(TransactionInfo TransInfo)
    {
        try
        {
            string contactNumber = string.valueOf(TransInfo.DonorId);
            
            Contact donor = [select id,
                            rC_Bios__Home_Email__c,
                            Successful_Registration__c
                            from Contact
                            where Contact_Number__c = :contactNumber
                            and RecordType.Name in ('Household','Organization')
                            and rC_Bios__Active__c = true
                            limit 1];
            
            //updating the home email address because the workflow rule
            //needs the email to reside in a field
            donor.rC_Bios__Home_Email__c = TransInfo.DonorEmail;
            donor.Successful_Registration__c = true;
            update donor;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','SendRegistrationEmail','Exception');
            log.logException(ex);
            log.saveLogs();
        }
    }
    
    //sprint 4
    //determine if the account number is a duplicate
    //@param ContactId - the contact number of the donor
    //@param agpId - the id number of the payment method
    //@param accountNumber - the account number to search for
    //@param transitNumber - the routing transit number of the account to search for if ACH
    //@param isActive - whether to search only active payment methods or all.  True for active only.
    //@param acctType - ACH or otherwise
    //@return AGPId or zero if not found
    webservice static integer IsDuplicateAccountNumber(integer ContactId, integer agpId, string accountNumber, 
                                                       string transitNumber, boolean isActive, string acctType)
    {
        try
        {
            string query;
            
            if(isActive)
            {
                query = 'select Id, Payment_Method_Number__c from rC_Giving__Payment_Method__c where' + 
                        ' rC_Giving__Is_Active__c = true'; 
            }
            else
            {
                query = 'select Id, Payment_Method_Number__c from rC_Giving__Payment_Method__c where' + 
                        ' (rC_Giving__Is_Active__c = true or rC_Giving__Is_Active__c = false)'; 
            }
            
            if(ContactId != 0)
            {
                string contactNumber = string.valueOf(ContactId);
            
                Contact donor = [select id, accountid
                                 from contact
                                 where Contact_Number__c = :contactNumber
                                 LIMIT 1];
                
                Id donorId = donor.id;
                Id accountId = donor.AccountId;
                
                query += ' and (rC_Giving__Account__c = :accountId and rC_Giving__Contact__c = :donorId)';
            }
            
            if(agpId != 0)
            {
                string agpNumber = string.valueOf(agpId);
                query += ' and Payment_Method_Number__c = :agpNumber';
            }
            
            if((acctType == 'CH' || acctType == 'SS' || acctType == 'SA') && accountNumber != null)
            {
                string accountLast4 = accountNumber.right(4);
                query += ' and rC_Giving__Routing_Number__c = :transitNumber' + 
                         ' and rC_Giving__Account_Number_Last_4__c = :accountLast4';
            }
            else if((acctType == 'CR' || acctType == 'DB') && accountNumber != null)
            {
                string cardLast4 = accountNumber.right(4);
                query += ' and rC_Giving__Card_Number_Last_4__c = :cardLast4';
            }
            system.debug('query: ' + query);
            

            List<rC_Giving__Payment_Method__c> results = database.query(query);
                
            if(results.size() > 0)
                return integer.valueOf(results[0].Payment_Method_Number__c);
            else
                return 0;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','IsDuplicateAccountNumber','Exception');
            log.logException(ex);
            System.debug('Exception ==> ' + ex);
            log.saveLogs();
            //throw ex;
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
            id chargeCardRecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Charge Card').getRecordTypeId();
            id eftRecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();

            if(info.AgpType == 'CH' || info.AgpType == 'SS' || info.AgpType == 'SA')
            {
                agp.recordtypeid = eftRecordTypeId;
                agp.rC_Giving__Payment_Type__c = 'ACH';
                agp.rC_Giving__Account_Number__c = info.AccountNumber;
                
                if(agp.rC_Giving__Account_Number__c != null)
                    agp.rC_Giving__Account_Number_Last_4__c = agp.rC_Giving__Account_Number__c.right(4);
                
                agp.rC_Giving__Routing_Number__c = info.TransitNumber;
            }
            else if(info.AgpType == 'CR' || info.AgpType == 'DB')
            {
                agp.recordtypeid = chargeCardRecordTypeId;
                agp.rC_Giving__Payment_Type__c = 'Charge Card';
                agp.rC_Giving__Card_Number__c = info.AccountNumber;
                
                if(agp.rC_Giving__Card_Number__c != null)
                    agp.rC_Giving__Card_Number_Last_4__c = agp.rC_Giving__Card_Number__c.right(4);
                
                //rC_Giving__Card_Security_Code__c
                agp.rC_Giving__Card_Holder_Name__c = info.FullName;
                
                date expireDate = date.parse(info.DateExpiration);
                agp.rC_Giving__Card_Expiration_Month__c = string.valueOf(expireDate.month());
                agp.rC_Giving__Card_Expiration_Year__c = string.valueOf(expireDate.year());
                
                List<CreditTypeRefCodes__c> codes = CreditTypeRefCodes__c.getAll().values();
                for(CreditTypeRefCodes__c code : codes)
                    if(code.Code__c == info.CardType)
                        agp.rC_Giving__Card_Issuer__c  = code.Description__c;
            }
            else
            {
                throw new ApplicationException('Incorrect AgpType: ' + info.AgpType);
            }
            
            string contactNumber = string.valueOf(info.ContactId);
            
            Contact donor = [select id, accountid, rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c
                             from contact
                             where Contact_Number__c = :contactNumber
                             LIMIT 1];
            
            agp.rC_Giving__Account__c = donor.AccountId;
            agp.rC_Giving__Contact__c = donor.id;       
            //agp.rC_Giving__Billing_Postal_Code__c = info.CardholderZipcode;

            if(info.Active.toLowerCase() == 'a')
                agp.rC_Giving__Is_Active__c = true;
            else
                agp.rC_Giving__Is_Active__c = false;
            
            if(donor.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c == 'USA')
                agp.Send_Confirmation_Email__c = true;
            
            //address on payment method is handled on a before insert trigger

            //check to see if this payment method exists and return existing instead of inserting
            //TODO: should this be activated if inactive?
            List<rC_Giving__Payment_Method__c> existingMethods = [select id, Payment_Method_Number__c, rC_Giving__Is_Active__c from rC_Giving__Payment_Method__c where
                                                                rC_Giving__Payment_Type__c = :agp.rC_Giving__Payment_Type__c and
                                                                ((rC_Giving__Account_Number_Last_4__c != null and rC_Giving__Account_Number_Last_4__c = :agp.rC_Giving__Account_Number_Last_4__c) or
                                                                (rC_Giving__Card_Number_Last_4__c != null and rC_Giving__Card_Number_Last_4__c = :agp.rC_Giving__Card_Number_Last_4__c)) and
                                                                rC_Giving__Account__c = :donor.AccountId and
                                                                rC_Giving__Contact__c = :donor.id];
            
            if(existingMethods.size() > 0)
            {
                agp = existingMethods[0];
                agp.rC_Giving__Is_Active__c = true;
                update agp;
            }
            else
            {
                insert agp;
                agp = [select id, Payment_Method_Number__c from rC_Giving__Payment_Method__c where id = :agp.id];
            }

            info.Id = integer.valueof(agp.Payment_Method_Number__c);
            returnValue.NewID = info.id;
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
                                                rC_Giving__Is_Active__c,
                                                rC_Giving__Is_Default__c,
                                                 rC_Giving__Contact__r.MailingCountry
                                               from rC_Giving__Payment_Method__c
                                               where Payment_Method_Number__c = :paymentMethodNumber];
            
            if(info.Active == 'A')
                agp.rC_Giving__Is_Active__c = true;
            else
            {
                agp.rC_Giving__Is_Active__c = false;
                agp.rC_Giving__Is_Default__c = false;
            }
                
            if(agp.rC_Giving__Contact__r.mailingcountry == 'USA')
                agp.Send_Confirmation_Email__c = true;
            
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
    
    //sprint 4
    //updates a payment method
    //@param info - contains payment method information
    webservice static boolean UpdateAgp(AgpInfo info)
    {
        try
        {
            string paymentMethodNumber = string.valueOf(info.id);
            
            rC_Giving__Payment_Method__c agp = [select id,
                                                rC_Giving__Billing_Postal_Code__c,
                                                rC_Giving__Card_Expiration_Month__c,
                                                rC_Giving__Card_Expiration_Year__c,
                                                rC_Giving__Is_Active__c,
                                                rC_Giving__Billing_Contact_Name__c,
                                                Send_Confirmation_Email__c
                                               from rC_Giving__Payment_Method__c
                                               where Payment_Method_Number__c = :paymentMethodNumber limit 1];
            
            if(info.AgpType == 'CH')
            {
                agp.rC_Giving__Card_Holder_Name__c = info.FullName;
            }
            else if(info.AgpType == 'CR')
            {          
                date expireDate = date.parse(info.DateExpiration);
                agp.rC_Giving__Card_Expiration_Month__c = string.valueOf(expireDate.month());
                agp.rC_Giving__Card_Expiration_Year__c = string.valueOf(expireDate.year());
                agp.rC_Giving__Billing_Postal_Code__c = info.CardholderZipcode;
            }

            if(info.Active.toLowerCase() == 'a')
                agp.rC_Giving__Is_Active__c = true;
            else
                agp.rC_Giving__Is_Active__c = false;
            
            string contactNumber = string.valueOf(info.ContactId);
            Contact donor = [select id, Alliance_Donor__c from contact where Contact_Number__c = :contactNumber limit 1];

            if(!donor.Alliance_Donor__c)
                agp.Send_Confirmation_Email__c = true;
            
            update agp;
            return true;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','UpdateAgp','Exception');
            log.logException(ex);
            log.saveLogs();
            return false;
        }
    }
    
    //sprint 5 - May not be needed.  Part of transaction processing
    //webservice static SponsorshipInfo GetSponsorshipByID(integer SponsorshipID)
    //{
    //    return null;
    //}
    
    //sprint 5
    //inserts an email address and epub code into an exclusion table
    //which a batch job will later match to a contact and update
    //the contact's email subscription preferences
    //@param email - the email address
    //@param epubAbbrv - the epub code as defined in EmailPublicationRefCodes
    //@return true on success, false on failure
    webservice static boolean UnsubscribeEmail(string email, string epubAbbrv)
    {
        try
        {
            Email_Exclusion__c exclusion = new Email_Exclusion__c();
            exclusion.Email__c = email;
            exclusion.EPub_Code__c = epubAbbrv.toUpperCase();
            insert exclusion;
            return true;
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','UnsubscribeEmail','Exception');
            log.logException(ex);
            log.saveLogs();
            return false;
        }
    }
    
    //sprint 5
    webservice static boolean VerifyPrimaryContactID(integer ContactId)
    {
        return false;
    }
    
    //sprint 5
    //Queries Campaign for the expected giving amounts for a project
    //@param MarketingId - the campaign identifier
    //@return FundProjectInfo - the amount raised, goal, and amount remaining for a project
    webservice static FundProjectInfo GetFundaProjectByID(integer MarketingId)
    {
        FundProjectInfo info = new FundProjectInfo();
        
        try
        {
            //campaign source code must be 7 digits, left padded with zeroes
            string campaignNumber = string.valueOf(MarketingId);
            campaignNumber = campaignNumber.leftPad(7).replaceAll(' ','0');
            
            Campaign project = [select id,
                               ExpectedRevenue,
                                rC_Giving__Expected_Giving_Amount__c,
                                rC_Giving__Remaining_Goal__c
                               from Campaign
                               where Source_Code_Autonumber__c = :campaignNumber limit 1];
            
            if(project.ExpectedRevenue != null)
                info.Goal = integer.valueOf(project.ExpectedRevenue);
            
            //rC_Giving__Expected_Giving_Amount__c is Currency(16,2), so round the decimal places off
            if(project.rC_Giving__Expected_Giving_Amount__c != null)
                info.Raised = integer.valueOf(math.rint(project.rC_Giving__Expected_Giving_Amount__c));
            
            if(project.rC_Giving__Remaining_Goal__c != null)
                info.Remaining = integer.valueOf(math.rint(project.rC_Giving__Remaining_Goal__c));
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','GetFundaProjectByID','Exception');
            log.logException(ex);
            log.saveLogs();
        }
        
        return info;
    }
    
    //Sprint 5
    //Sends an email containing a link to reset the website users password
    //@param TransInfo - transaction info containing donor data
    //@param PassInfo - password reset info containing email address and password hash
    webservice static void SendPasswordLinkEmail(TransactionInfo TransInfo, PasswordResetInfo PassInfo)
    {
        try
        {
            EmailTemplate template = [SELECT Id, Subject, HtmlValue 
                                     from emailtemplate 
                                     where developername = 'Password_LInk_Email'
                                    limit 1];
            
            if(template != null)
            {
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<Messaging.Email> emails = new List<Messaging.Email>();
                emails.add(mail);
                List<String> sendTo = new List<String>();
                sendTo.add(PassInfo.Email);
                mail.setToAddresses(sendTo);
                mail.setReplyTo('noreply@childfund.org');
                mail.setSenderDisplayName('Do Not Reply');
                mail.setSubject(template.Subject);
                
                string body = template.HtmlValue;
                body = body.replace('<<cont_name>>', TransInfo.DonorFirstName + ' ' + TransInfo.DonorLastName);
                body = body.replace('<<hash>>', PassInfo.LinkHash);
                mail.setHtmlBody(body);
                
                Messaging.sendEmail(emails);
            }
        }
        catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('TransactionService','SendPasswordLinkEmail','Exception');
            log.logException(ex);
            log.saveLogs();
        }
    }
    
}