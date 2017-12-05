/***********************************************************************************************************
 * Appirio, Inc
 * Name         : WebTransactionProcessing
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Web Transaction Processing for Childfund.org website
 * Created Date : 02/24/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/24/2016                   Karl Houseknecht        Created
 * 10/27/2016					Karl Houseknecht		Work in progress - refactoring web transaction processing
 **********************************************************************************************************/
public class WebTransactionProcessing 
{
	//Deserializes the XML into a TransactionInfo object
    //This is called to reprocess a failed web transaction from the raw request
    //@param xml - The XML string representing a serialized TransactionInfo object
    //@return - TransactionInfo object
    public static TransactionInfo TransactionInfoFromXML(string xml)
    {
        TransactionInfo info;
        XMLSerializer serializer = new XMLSerializer();
        info = (TransactionInfo)serializer.deserialize(xml,TransactionInfo.class);
        return info;
    } 
    
    //create the web transaction header record
    //@param TransInfo - transaction information passed by web service call from web site
    //@return - Web_Transaction__c header record
    public static Web_Transaction__c CreateWebTransactionRecord(TransactionInfo TransInfo)
    {
        Web_Transaction__c order = new Web_Transaction__c();
        order.Status__c = 'New';
        
        try
        {
            //serialize the incoming TransInfo to XML and save in a custom field on Web_Transaction__c
            XMLSerializer serializer = new XMLSerializer();
            order.Transaction_XML__c = serializer.serialize(TransInfo);
            
            insert order;
            string orderName = [select name from Web_Transaction__c where id = :order.id limit 1].name;        
            TransInfo.TransactionId = integer.valueOf(orderName);

            //contact info on header record
            order.Contact_Can_Sponsor_Children__c = TransInfo.CanSponsorChildren;
            order.Contact_Care_Of__c = TransInfo.DonorCareOf;
            order.Contact_City__c = TransInfo.DonorCity;
            
            if(string.isNotBlank(TransInfo.DonorCountryCode))
                order.Contact_Country__c = LookupService.GetCountryAbbreviationFromCode(integer.valueOf(TransInfo.DonorCountryCode));
            
            //order.Contact_DF_Fee_Participant__c = ?
            order.Contact_Email__c = TransInfo.DonorEmail;
            order.Contact_First_Name__c = TransInfo.DonorFirstName;
            order.Contact_Last_Name__c = TransInfo.DonorLastName;
            //order.Contact_Marketing_ID__c = LookupService.GetCampaignId(TransInfo.DonorMarketingId); //this is the contact's campaign id
            //if(order.Contact_Marketing_ID__c == null)
            //    order.Status__c = 'Flagged';

            //order.Contact_Motivated_By__c = TransInfo.DonorMotivatedById; //TODO: translation to picklist value?
            order.Contact_Origin_Code__c = TransInfo.DonorOriginCode;
            order.Contact_Phone__c = TransInfo.DonorPhone;
            order.Contact_Postal_Code__c = TransInfo.DonorPostalCode;
            order.Contact_State_Prov_Terr__c = LookupService.GetStateAbbreviationFromCode(TransInfo.DonorState);
            order.Contact_Street_1__c = TransInfo.DonorStreet1;
            order.Contact_Street_2__c = TransInfo.DonorStreet2;
            order.Contact_Suffix__c = LookupService.GetSuffixFromCode(TransInfo.DonorSuffixId);
            order.Contact_Title__c = LookupService.GetTitleFromCode(TransInfo.DonorTitleId);
            order.Contact_Type__c = TransInfo.DonorContactType;
            order.Contact_Validate_For_Sponsorship__c = TransInfo.validateForSponsorship;
            
            //payment method on header record
            order.Card_Security_Code__c = TransInfo.CVV;
            order.ABA_Transit_Number__c = TransInfo.PaymentTransitNumber;
            order.Account_Number__c = TransInfo.PaymentAccountNumber;
            order.Cardholder_Name__c = TransInfo.PaymentCardholderFullName;
            order.Cardholder_Zip__c = TransInfo.PaymentCardholderZipcode;
            order.Card_Type__c = TransInfo.PaymentCardType;
            
            if(string.isNotBlank(TransInfo.PaymentDateExpiration))
                order.Expiration_Date__c = date.valueOf(TransInfo.PaymentDateExpiration);
            
            if(string.isNotBlank(TransInfo.PaymentDateDfTaken))
                order.Payment_DF_Taken_Date__c =  date.valueOf(TransInfo.PaymentDateDfTaken);
            
            order.Payment_Type__c = TransInfo.PaymentType;
            order.Create_Ektron_Account__c = TransInfo.CreateEktronAccount;
            order.Ektron_Password__c = TransInfo.EktronPassword;
            update order;
            
        }
        catch(exception ex)
        {
            order.Status__c = 'Flagged';
            update order;
        }

        return order;
    }
    
    //create or update the donor contact record
    //@param TransInfo - transaction information passed by web service call from web site
    //@param order - Web_Transaction__c header record
    public static void ProcessDonorContact(Web_Transaction__c order, TransactionInfo TransInfo)
    {
        try
        {
            //use existing contact if specified
            TransInfo.isVerifiedDonor = true;

            if(TransInfo.DonorId != 0)
            {
                string contactNumber = string.valueOf(TransInfo.DonorId);
                Contact donor;
                List<Contact> donors = [select id, accountid
                                 from contact
                                 where Contact_Number__c = :contactNumber
                                 LIMIT 1];
                
                if(donors.size() > 0)
                    donor = donors[0];
                else
                {
                    TransInfo.isVerifiedDonor = false;
                }

                order.Contact__c = donor.id;
                order.Account__c = donor.accountid;

                ContactInfo donorInfo = DonorPortalService.GetContactByID(TransInfo.DonorId);

                //if contact is dirty, update
                if(TransInfo.isDirtyDonor)
                {
                    ContactUpdateInfo donorUpdateInfo;
                    donorUpdateInfo.id = TransInfo.DonorId;
                    donorUpdateInfo.cdesstatprovterrid = TransInfo.DonorState;
                    donorUpdateInfo.ctrycode = TransInfo.DonorCountryCode;
                    donorUpdateInfo.careof = TransInfo.DonorCareOf;
                    donorUpdateInfo.street1 = TransInfo.DonorStreet1;
                    donorUpdateInfo.street2 = TransInfo.DonorStreet2;
                    donorUpdateInfo.city = TransInfo.DonorCity; 
                    donorUpdateInfo.postalcode = TransInfo.DonorPostalCode;
                    donorUpdateInfo.name = TransInfo.DonorLastName;
                    donorUpdateInfo.firstname = TransInfo.DonorFirstName;
                    donorUpdateInfo.clstnmsuffixid = TransInfo.DonorSuffixId;
                    donorUpdateInfo.clstnmtitleid = TransInfo.DonorTitleId;
                    donorUpdateinfo.phoneareacode = TransInfo.DonorPhoneAreaCode;
                    donorUpdateInfo.phone = TransInfo.DonorPhone;
                    donorUpdateInfo.phoneextension = TransInfo.DonorPhoneExtension;
                    donorUpdateInfo.email = TransInfo.DonorEmail;

                    integer updateResult = DonorPortalService.UpdateContact(donorUpdateInfo);
                    if(updateResult == 0)
                        TransInfo.isVerifiedDonor = false;
                    else
                        TransInfo.isVerifiedDonor = true;
                }
            }
            else
            {
                //create contact
                ValidateContact(order, TransInfo);
            }
 
            if(order.Contact__c != null)
                update order;
        }
        catch(exception ex)
        {
            TransInfo.isVerifiedDonor = false;
            
            //if(ex instanceof ApplicationException)
            //    throw ex;
            //else
            //    throw new ApplicationException(ex.getMessage() + ' PROBLEM WITH DONOR VALIDATION');
        } 
    }
    
    //create or update the donor payment method record
    //@param TransInfo - transaction information passed by web service call from web site
    //@param order - Web_Transaction__c header record
    public static void ProcessPaymentMethod(Web_Transaction__c order, TransactionInfo TransInfo)
    {
        try
        {
            //Payment Method info
            //if the payment method number specified, query for payment method
            //and update the matched payment method field
            //otherwise, fill in data for new payment method

            TransInfo.isVerifiedPayment = true;

            if(TransInfo.PaymentId != 0)
            {
                string paymentMethodNumber = string.valueOf(TransInfo.PaymentId);
                List<rC_Giving__Payment_Method__c> methods = [select id
                                                       from rC_Giving__Payment_Method__c
                                                       where Payment_Method_Number__c = :paymentMethodNumber limit 1];
                
                if(methods.size() == 1)
                    order.Payment_Method__c = methods[0].id;
                else
                    TransInfo.isVerifiedPayment = false;
                
                /*
                //update the payment method if dirty
                if(TransInfo.isDirtyPayment)
                {
                    AgpInfo paymentInfo = TransactionService.GetAgpByID(TransInfo.PaymentId);
                    paymentInfo.Id = TransInfo.PaymentId;
                    paymentInfo.AgpType = TransInfo.PaymentType;
                    paymentInfo.AccountNumber = TransInfo.PaymentAccountNumber;
                    paymentInfo.ContactId = TransInfo.PaymentDonorId;
                    paymentInfo.CardType = TransInfo.PaymentCardType;
                    paymentInfo.FullName = TransInfo.PaymentCardholderFullName;
                    paymentInfo.CardholderZipcode = TransInfo.PaymentCardholderZipcode;
                    paymentInfo.DateExpiration = TransInfo.PaymentDateExpiration;
                    paymentInfo.DateDfTaken = TransInfo.PaymentDateDfTaken;
                    paymentInfo.TransitNumber = TransInfo.PaymentTransitNumber;
                    
                    TransInfo.isVerifiedPayment = TransactionService.UpdateAgp(paymentInfo);
                }
                */

            }
            else
            {
                //add new payment method
                AgpInfo newAgpInfo = new AgpInfo();
                newAgpInfo.AgpType = TransInfo.PaymentType;
                newAgpInfo.AccountNumber = TransInfo.PaymentAccountNumber;
                newAgpInfo.ContactId = TransInfo.PaymentDonorId;
                newAgpInfo.CardType = TransInfo.PaymentCardType;
                newAgpInfo.FullName = TransInfo.PaymentCardholderFullName;
                newAgpInfo.CardholderZipcode = TransInfo.PaymentCardholderZipcode;
                newAgpInfo.DateExpiration = TransInfo.PaymentDateExpiration;
                newAgpInfo.DateDfTaken = TransInfo.PaymentDateDfTaken;
                newAgpInfo.TransitNumber = TransInfo.PaymentTransitNumber;
                newAgpInfo.Active = 'A';
                
                Envelope agpResult = TransactionService.AddAgp(newAgpInfo);
                if(agpresult.ReturnMessage != Enums.ReturnMsg.Failure)
                {
                    string paymentMethodNumber = string.valueOf(agpResult.NewID);
                    List<rC_Giving__Payment_Method__c> methods = [select id
                                                           from rC_Giving__Payment_Method__c
                                                           where Payment_Method_Number__c = :paymentMethodNumber limit 1];
                    
                    if(methods.size() == 1)
                    {
                        order.Payment_Method__c = methods[0].id;
                        TransInfo.isVerifiedPayment = true;
                    }
                    else
                        TransInfo.isVerifiedPayment = false;
 
                }
                else
                    TransInfo.isVerifiedPayment = false;
                
            }
            
            if(!TransInfo.isVerifiedPayment)
                throw new ApplicationException('PROBLEM WITH PAYMENT VALIDATION');

            update order;
        }
        catch(exception ex)
        {
            TransInfo.isVerifiedPayment = false;
            //if(ex instanceof ApplicationException)
            //    throw ex;
            //else
            //    throw new ApplicationException(ex.getMessage() + ' PROBLEM WITH PAYMENT VALIDATION');
        }
        
    }
    
    //iterate through donations in TransInfo and insert
    //new Batch Upload records for each donation, tying back to Web Transaction order record
    //@param Order - the Web Transaction object to which the donations will belong
    //@param TransInfo - transaction information passed by web service call from web site
    public static void ProcessDonations(Web_Transaction__c order, TransactionInfo TransInfo)
    {
        //exception handling in calling method
        List<rC_Connect__Batch_Upload__c> donations = new List<rC_Connect__Batch_Upload__c>();
        
        Map<integer, Campaign> CampaignMap = LookupService.GetCampaignsByDonations(TransInfo);
        Map<string, Campaign> CampaignMapByFincode = new Map<string, Campaign>();

        for(Campaign campaign : CampaignMap.values())
            CampaignMapByFincode.put(campaign.rC_Giving__GAU__r.Receipt_Category__c, campaign);

        try
        {
            //create each donation as a batch upload record 
            for(DonationInfo purchase : TransInfo.PurchasedDonations)
            {
                rC_Connect__Batch_Upload__c donation = new rC_Connect__Batch_Upload__c();
                donation.rC_Connect__Batch_Upload_Status__c = 'Flagged'; //set to new if insert goes okay
                donation.Web_Transaction__c = order.id;
                donation.rC_Connect__Giving_Record_Type__c = 'Donation';

                donation.Receipt_Category__c = string.valueOf(string.valueOf(purchase.fincode).leftPad(4).replaceAll(' ','0'));
                
                Campaign campaign;

                if(purchase.mktacid != null && purchase.mktacid != 0)
                    campaign = CampaignMap.get(purchase.mktacid);
                else if(purchase.fincode != null && purchase.fincode != 0)
                    campaign = CampaignMapByFincode.get(donation.Receipt_Category__c); //these are DF campaigns

                if(campaign == null)
                {
                    system.debug('purchase.mktacid = ' + string.valueOf(purchase.mktacid));
                    throw new ApplicationException('PROBLEM WITH DONATION VALIDATION - COULD NOT FIND A MATCHING CAMPAIGN');
                }
                else
                {
                    donation.General_Accounting_Unit__c = campaign.rC_Giving__GAU__c; 
                    donation.Product_Type__c = campaign.Product_Type__c;
                    donation.Product_Sub_Type__c = campaign.Product_Sub_Type__c;
                    
                    if(donation.Product_Type__c == 'Sponsorship')           
                        CreateSponsorship(order, TransInfo, purchase, donation);
                    else if(donation.Product_Type__c == 'Designated Fund')
                        CreateDF(order, TransInfo, purchase, donation);
                    else
                        CreateOtherDonation(order, TransInfo, purchase, donation);
                    
                    donations.add(donation);
                }
            }
            
            if(donations.size() > 0)
                insert donations;

            TransInfo.isVerifiedDonations = true;
        }
        catch(exception ex)
        {
            TransInfo.isVerifiedDonations = false;
            
            //if(ex instanceof ApplicationException)
            //    throw ex;
            //else
            //    throw new ApplicationException(ex.getMessage() + ' PROBLEM WITH DONATION VALIDATION');
        }
        
    }

    private static void CreateSponsorship(Web_Transaction__c order, TransactionInfo TransInfo, DonationInfo purchase, rC_Connect__Batch_Upload__c donation)
    {
        //sponsorship
        //Run contact through Sponsorship validation 
        //(Contact.IsValidForSponsorship). This method will update 
        //the CanSponsorChildren field of the TransactionInfo object
        IsContactValidForSponsorship(order,TransInfo);
        
        
        if(!TransInfo.CanSponsorChildren)
        {
            TransInfo.isVerifiedDonations = false;
            //Send transaction to exceptions with SponsorshipCreationError message
            throw new ApplicationException('ERROR CREATING SPONSORSHIP - CONTACT CANNOT SPONSOR CHILDREN');
        }
        else
        { 
            if(purchase.PaySchedId != 0)
            {
                //update sponsorship
                donation.rC_Connect__Batch_Upload_Giving_Matched__c = LookupService.GetOpportunityId(purchase.PaySchedId);
                donation.rC_Connect__Giving_Giving_Amount__c = purchase.amount;
                donation.rC_Connect__Giving_Giving_Frequency__c = LookupService.GetPaymentFrequencyFromCode(purchase.PaymentFrequency);
                donation.rC_Connect__Batch_Upload_Payment_Method_Matched__c = order.Payment_Method__c; 
            }
            else
            {
                //setup the sponsorship, based on the information in the DonationInfo object 
                //(noid, childnumber, amount, frequency, payment method) and the appropriate effective date
                //Emails #1 and #4 are sent. #1 is sent once the money is confirmed. #4 is sent immediately. - verify that workflow is already sending these

                donation.name = purchase.title;
                donation.rC_Connect__Giving_Giving_Amount__c = purchase.amount;
                donation.rC_Connect__Giving_Giving_Frequency__c = LookupService.GetPaymentFrequencyFromCode(purchase.PaymentFrequency);
                donation.rC_Connect__Giving_Is_Sustainer__c = true;
                //donation.Start_Date__c = GetStartDate(TransInfo, purchase, donation);
                donation.rC_Connect__Giving_Close_Date__c = GetStartDate(TransInfo, purchase, donation);
                donation.rC_Connect__Batch_Upload_Account_Matched__c = order.Account__c;
                
                //set marketing id to default if not set in donation
                donation.rC_Connect__Batch_Upload_Campaign_Matched__c = LookupService.GetCampaignId(purchase.mktacid);

                donation.Auto_Assign_Participant__c = 'Direct Sponsorship';
                donation.Participant__c = GetParticipantContactId(purchase.ChildNumber);
                donation.rC_Connect__Batch_Upload_Payment_Method_Matched__c = order.Payment_Method__c;
                
                //primary contact
                donation.rC_Connect__Batch_Upload_Contact_1_Matched__c = order.Contact__c;
                //hard credit contact
                donation.rC_Connect__Batch_Upload_Contact_2_Matched__c = order.Contact__c;

                //activity type = Donation - no field in batch upload
                //auto assign preference = true - no field in batch upload

                //NOTE: Gift Sponsorship is out of scope for web site for the initial release
            }
            
            donation.rC_Connect__Batch_Upload_Status__c = 'New';
        }
    }

    private static void CreateDF(Web_Transaction__c order, TransactionInfo TransInfo, DonationInfo purchase, rC_Connect__Batch_Upload__c donation)
    {
        //o Determine the effective date based on the DFEffectiveDateType
        //▪   NOW: Effective date from today
        //▪   WAIT: Future effective date
        //o   Add schedule if PaySchedId is 0, update values if there is a PaySchedId
        //o   Send Email #20 if successful
        //DF's use SponsorshipId instead of child number - DFC Related Opportunity
        
        if(purchase.PaySchedId != 0)
        {
            donation.rC_Connect__Batch_Upload_Giving_Matched__c = LookupService.GetOpportunityId(purchase.PaySchedId);
            donation.rC_Connect__Giving_Giving_Amount__c = purchase.amount;
            donation.rC_Connect__Giving_Giving_Frequency__c = LookupService.GetPaymentFrequencyFromCode(purchase.PaymentFrequency);
            donation.rC_Connect__Batch_Upload_Payment_Method_Matched__c = order.Payment_Method__c; 
        }
        else
        {
            donation.name = purchase.title;
            donation.rC_Connect__Giving_Giving_Amount__c = purchase.amount;
            donation.rC_Connect__Giving_Giving_Frequency__c = LookupService.GetPaymentFrequencyFromCode(purchase.PaymentFrequency);
            donation.rC_Connect__Giving_Is_Sustainer__c = false;
            //donation.Start_Date__c = GetStartDate(TransInfo, purchase, donation);
            donation.rC_Connect__Giving_Close_Date__c = GetStartDate(TransInfo, purchase, donation);
            donation.rC_Connect__Batch_Upload_Account_Matched__c = order.Account__c;
            donation.rC_Connect__Batch_Upload_Payment_Method_Matched__c = order.Payment_Method__c;
            donation.rC_Connect__Batch_Upload_Contact_1_Matched__c = order.Contact__c;
            donation.rC_Connect__Batch_Upload_Contact_2_Matched__c = order.Contact__c;
            donation.DFC_Related_Opportunity__c = LookupService.GetOpportunityId(purchase.SponsorshipId);
        }

        donation.rC_Connect__Batch_Upload_Status__c = 'New';

    }

    private static void CreateOtherDonation(Web_Transaction__c order, TransactionInfo TransInfo, DonationInfo purchase, rC_Connect__Batch_Upload__c donation)
    {
        //o Set marketing id to default if it is not set in the donation.
        //o   If PaySched = 0, this is a create:
        //▪   If donation is a recurring product, create the anchor, and if created successfully update the anchor’s status.
        //▪   Create new payment schedule using information in DonationInfo object.
        //o   If PaySched != 0 then update the payment schedule with the information in the DonationInfo object.
        //o   If ContactInfo inside of DonationInfo object is not null, this is an In Honor Of or In Memory Of donation. Recipient information should be saved/updated and any messaging should be saved for card generation.
        //o   Successful gift catalog transactions (FinCode 728) are sent email #8 once the money is received. Successful monetary donations are sent email #2 once the money is received.
    
        if(purchase.PaySchedId != 0)
        {
            donation.rC_Connect__Batch_Upload_Giving_Matched__c = LookupService.GetOpportunityId(purchase.PaySchedId);
            donation.rC_Connect__Giving_Giving_Amount__c = purchase.amount;
            donation.rC_Connect__Giving_Giving_Frequency__c = LookupService.GetPaymentFrequencyFromCode(purchase.PaymentFrequency);
            donation.rC_Connect__Batch_Upload_Payment_Method_Matched__c = order.Payment_Method__c; 
        }
        else
        {
            donation.name = purchase.title;
            donation.rC_Connect__Giving_Giving_Amount__c = purchase.amount;
            donation.rC_Connect__Giving_Giving_Frequency__c = LookupService.GetPaymentFrequencyFromCode(purchase.PaymentFrequency);
            donation.rC_Connect__Giving_Is_Sustainer__c = false;
            //donation.Start_Date__c = GetStartDate(TransInfo, purchase, donation);
            donation.rC_Connect__Giving_Close_Date__c = GetStartDate(TransInfo, purchase, donation);
            donation.rC_Connect__Batch_Upload_Account_Matched__c = order.Account__c;
            donation.rC_Connect__Batch_Upload_Payment_Method_Matched__c = order.Payment_Method__c;
            donation.rC_Connect__Batch_Upload_Contact_1_Matched__c = order.Contact__c;
            donation.rC_Connect__Batch_Upload_Contact_2_Matched__c = order.Contact__c;
            //NOTE: in memory or in honor of (tribute) functionality is currently out of scope for initial release
        }

        donation.rC_Connect__Batch_Upload_Status__c = 'New';

    }
    
    private static void ValidateContact(Web_Transaction__c order, TransactionInfo TransInfo)
    { 
        //address validation if USA address
    	if(TransInfo.DonorCountryCode == '840')
        {
            ContactInfo addressInfo = new ContactInfo();
            addressInfo.street1 = TransInfo.DonorStreet1;
            addressInfo.street2 = TransInfo.DonorStreet2;
            addressInfo.city = TransInfo.DonorCity;
            addressInfo.cdesstatprovterrid = TransInfo.DonorState;
            addressInfo.postalcode = TransInfo.DonorPostalCode;
            
            ContactInfo addressResult = DonorPortalService.StandardizeStreet(addressInfo);
            if(addressResult.IsValidAddress)
            {
                TransInfo.DonorStreet1 = addressResult.street1;
                TransInfo.DonorStreet2 = addressResult.street2;
                TransInfo.DonorCity = addressInfo.city;
                TransInfo.DonorState = addressInfo.cdesstatprovterrid;
                TransInfo.DonorPostalCode = addressInfo.postalcode;
                
            }
            else
            {
                //TODO:invalid address, flag transaction as exception
                TransInfo.isVerifiedDonor = false;
            }
        }
              
        //household match
        ContactInfo donorInfo = new ContactInfo();
        string contactNumber;
        
        //populate contact info
        donorInfo.conttype = TransInfo.DonorContactType;
        donorInfo.cdesstatprovterrid = TransInfo.DonorState;
        donorInfo.ctrycode = TransInfo.DonorCountryCode;
        donorInfo.careof = TransInfo.DonorCareOf;
        donorInfo.street1 = TransInfo.DonorStreet1;
        donorInfo.street2 = TransInfo.DonorStreet2;
        donorInfo.city = TransInfo.DonorCity; 
        donorInfo.postalcode = TransInfo.DonorPostalCode;
        donorInfo.name = TransInfo.DonorLastName;
        donorInfo.firstname = TransInfo.DonorFirstName;
        donorInfo.clstnmsuffixid = TransInfo.DonorSuffixId;
        donorInfo.clstnmtitleid = TransInfo.DonorTitleId;
        donorInfo.phoneareacode = TransInfo.DonorPhoneAreaCode;
        donorInfo.phoneextension = TransInfo.DonorPhoneExtension;
        donorInfo.phone = TransInfo.DonorPhone;
        donorInfo.email = TransInfo.DonorEmail;
        donorInfo.mktacid = TransInfo.DonorMarketingId;
        //TransInfo.DonorMotivatedById;
        
        //check for household match.  If absolute match, use that and query/update
        Envelope matchResult = LookupService.HouseHoldMatch(donorInfo);
        if(matchResult.ReturnCode == 106)
        {
            //no match, create
            Envelope donorResult = DonorPortalService.AddContact(donorInfo);
            contactNumber = string.valueOf(donorResult.NewID);
        }
        else if(matchResult.ReturnCode == 102)
        {
            //TODO: multiple matches
            //some kind of error
            
        }
        else if(matchResult.ReturnCode == 101)
        {
            //exact match
            donorInfo = DonorPortalService.GetContactByID(matchResult.NewID);
            contactNumber = string.valueOf(matchResult.NewID);
        }
        else
        {
            //TODO: some kind of error
        }
        
        if(contactNumber != '0')
        {
            Contact donor = [select id, accountid
                             from contact
                             where Contact_Number__c = :contactNumber
                             LIMIT 1];
            
            order.Contact__c = donor.id;
            order.Account__c = donor.accountid;
            TransInfo.DonorId = integer.valueOf(contactNumber);
            TransInfo.PaymentDonorId = integer.valueOf(contactNumber);
        }
        
        //prank phone number
        if(LookupService.IsPrankPhone(TransInfo.DonorPhoneAreaCode, TransInfo.DonorPhone))
        {
        	//TODO: exception for prank phone    
        }
        
        //name doesn't match any predefined values
        //TODO: don't have any requirements on this
        
        //contact type is not recipient - do not need to validate because
        //gift sponsorship is out of scope for go live.  Gift sponsorship
        //code removed from web site code.
        
          
        //validate for sponsorship
        if(TransInfo.validateForSponsorship)
        	IsContactValidForSponsorship(order, TransInfo);
    }
    
    private static void IsContactValidForSponsorship(Web_Transaction__c order, TransactionInfo TransInfo)
    { 
        
		ContactInfo contactInfo = DonorPortalService.GetContactByID(TransInfo.DonorId);
        
        //1.    indundesirable field
        if(contactInfo.indundesirable == 'Y')
        {
            TransInfo.CanSponsorChildren = false;
        }
        //2.     indallowsponsorship field
        if(contactInfo.indallowsponsorship == 'N')
        {
            TransInfo.CanSponsorChildren = false;
        }
        //3.    Compares # of presponsorships on account with set limit
        if(contactInfo.qtyactiveprespns >= LookupService.GetMaxPresponsors())
        {
            TransInfo.CanSponsorChildren = false;
        }
        //4.    Deceased flag
        if(contactInfo.inddeceased == 'Y')
        {
            TransInfo.CanSponsorChildren = false;
        }
        //5.    qtydelinquencycanceledspns flag is <= 3, and 
        if(contactInfo.qtydelinquencycanceledspns <= 3 )
        {
            TransInfo.CanSponsorChildren = false;
        }
        //6.    contact ID is not one of the internal contact ID’s
         
    }
    
    private static id GetParticipantContactId(integer childNumber)
    {
        string childId = string.valueOf(childNumber);

        id participantId = [select id from contact
                            where recordtype.name = 'Participant'
                            and Child_Number__c = :childId
                            limit 1].id;

        return participantId;
    }


    private static date GetChildBirthdayBySponsorship(integer sponsorshipId)
    {
        string opportunityNumber = string.valueOf(sponsorshipId);

        date birthDate = [select Participant__r.BirthDate from opportunity
                            where Salesforce_Opportunity_Code__c = :opportunityNumber
                            limit 1].Participant__r.BirthDate;

        return birthDate;
    }

    private static date GetStartDate(TransactionInfo TransInfo, DonationInfo purchase, rC_Connect__Batch_Upload__c donation)
    {
        /*
        Effective Dates:  purchase.DFEffectiveDateType NOW or WAIT - TODO:how does this come into play?
        */

        date result;
        integer resultMonth;
        integer resultDay;
        integer resultYear;
        integer currentMonth = date.today().month();
        integer currentYear = date.today().year();
        integer currentDay = date.today().day();

        if(donation.Product_Type__c == 'Sponsorship')
        {
            resultMonth = currentMonth;
            resultDay = currentDay;
            resultYear = currentYear;
        }
        else if(donation.Product_Type__c == 'Designated Fund')
        {
            if(donation.Product_Sub_Type__c == 'Birthday' || donation.Product_Sub_Type__c == 'Belated Birthday')
            {
                /* 30 – Birthday, setup 2 months prior to the child’s birthday. 
                If birthdate is greater than 28 setup on the 28th of the month. 
                January birthdays are setup with November as month, February birthdays are setup with December as month. All others are 2 months prior to birth month.
                Setup for current year if current month is before setup month, next year if past setup month. */

                Date birthdate = GetChildBirthdayBySponsorship(purchase.SponsorshipId);
                integer month = birthdate.month();
                integer day = birthdate.day();
                

                if(month == 1)
                    resultMonth = 11;
                else if(month == 2)
                    resultMonth = 12;
                else
                    resultMonth = month - 2;

                if(day >= 29)
                    resultDay = 28;
                else
                    resultDay = day;

                if(currentMonth < resultMonth)
                    resultYear = currentYear;
                else
                    resultYear = month + 1;
            }
            else if(donation.Product_Sub_Type__c == 'Christmas' || donation.Product_Sub_Type__c == 'Christmas Child & Family')
            {
                //31, 36 – Christmas DF’s, setup 10/28, current year if current month is before October, next year if November or December
                resultMonth = 10;
                resultDay = 28;

                if(currentMonth < 10)
                    resultYear = currentYear;
                else
                    resultYear = currentYear + 1;
            }
            else if(donation.Product_Sub_Type__c == 'Easter')
            {
                //32 – Easter, setup 2/28, this year if before February, next year if February or later.
                resultMonth = 2;
                resultDay = 28;

                if(currentMonth < 2)
                    resultYear = currentYear;
                else
                    resultYear = currentYear + 1;
            }
            else if(donation.Product_Sub_Type__c == 'Thanksgiving')
            {
                //74 – Thanksgiving, setup 9/28, current year if current month is before September, next year if past September.
                resultMonth = 9;
                resultDay = 28;

                if(currentMonth < 9)
                    resultYear = currentYear;
                else
                    resultYear = currentYear + 1;
            }
            else
            {
                   /*
                    Effective Dates:  purchase.DFEffectiveDateType NOW or WAIT
                    if NOW: set up for immediate
                    if WAIT: 
                    Most effective dates are the day the payment schedule is setup. 
                    
                    Donations set up past the 28th of the month are setup for the first day of the next month, UNLESS it is December, the receipt category is 2, 4, or 9, and the donation has a one-time frequency
                    
                    Donations with ACH payment types follow the same rules and then 3 days are added.
                    
                    Future Effective Dates for Annual DF’s (Validation.GetFutureDateEffective) 
                    
                    All other DF’s are setup with the current month and date of 28th.
                    */

                if(currentDay >= 29 && currentMonth == 12 && (purchase.FinCode == 2 || purchase.FinCode == 4 || purchase.FinCode == 9) && purchase.PaymentFrequency == 'O')
                {
                    resultMonth = currentMonth;
                    resultDay = currentDay;
                    resultYear = currentYear; 
                }
                else if(currentDay >= 29)
                {
                    if(currentMonth == 12)
                    {
                        resultMonth = 1;
                        resultYear = currentYear + 1;
                    }
                    else
                    {
                        resultMonth = currentMonth + 1;
                        resultYear = currentYear;
                    }

                    resultDay = 1;
                }
                else
                {
                    resultMonth = currentMonth;
                    resultDay = currentDay;
                    resultYear = currentYear; 
                }


            }
        }
        else //all other donations
        {
            if(currentday >= 29)
            {
                if(currentMonth == 12)
                {
                    resultMonth = 1;
                    resultYear = currentYear + 1;
                }
                else
                {
                    resultMonth = currentMonth + 1;
                    resultYear = currentYear;
                }

                resultDay = 1;
            }
            else
            {
                resultMonth = currentMonth;
                resultDay = currentDay;
                resultYear = currentYear;
            }
            
        }

        result = date.newinstance(resultYear, resultMonth, resultDay);

        if(TransInfo.PaymentType == 'DB')
            result = result.addDays(3); //TODO: what if the month is February?

        return result;
    }

    

}