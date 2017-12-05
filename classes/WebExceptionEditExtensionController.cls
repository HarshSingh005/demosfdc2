/***********************************************************************************************************
 * Appirio, Inc
 * Name         : WebExceptionEditExtensionController
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Web Exception controller extension
 * Created Date : 04/26/2016
 * 
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 04/26/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class WebExceptionEditExtensionController implements AddressComponentHostController 
{
    public Web_Transaction__c record{get;set;}
    public boolean invalidContValues{get; set;}
    public List<Contact> lstContacts {get; set;}
    public List<rC_Giving__Payment_Method__c> paymentMethodList {get;set;}
    public ValidatedAddress address {get; set;}
    public List<AddressValidationComponentController> addressControllers {get;set;}
    public List<rC_Connect__Batch_Upload__c> Donations{get;set;}
    public string DonationCount{get;set;}
    public List<SelectOption> NationalOfficeOptions{get;set;}
    public Id DonationId{get;set;}
    public boolean IsAddressReadOnly
    {
        get
        {
            if(record != null)
                return record.Contact__c != null;
            else
                return false;
        }
        set;
    }
    
    public AddressComponentHostController host
    {
        get{return this;}
        set;
    }

    //redirect to standard detail page if record is not flagged
    public PageReference redirect()
    {
        PageReference ref;

        if(Apexpages.currentPage().getParameters().get('id') != null)
        {
            Id recordId = Id.valueOf(Apexpages.currentPage().getParameters().get('id'));
            Web_Transaction__c trans = [select id, Status__c from Web_Transaction__c where id = :recordId limit 1];
            if(trans.Status__c != 'Flagged')
            {
                string url = '/' + recordId;
                ref = new PageReference(url);
            }
        }

        return ref;
    }

    public WebExceptionEditExtensionController(ApexPages.StandardController controller) 
    {
        if (!Test.isRunningTest()){// Added for test class as "addFields" cannot be used in test class
        controller.addFields(new List<String>{'Name','Status__c','CreatedDate','LastModifiedDate','LastModifiedBy','Contact__c',
                                              'Contact_Street_1__c','Contact_Street_2__c','Contact_Extra_Address_1__c','Contact_City__c','Contact_State_Prov_Terr__c',
                                              'Contact_Postal_Code__c','Contact_Country__c','Contact_Type__c','Contact_Title__c',
                                              'Contact_First_Name__c','Contact_Last_Name__c','Contact_Suffix__c','Contact_Care_Of__c',
                                              'Contact_Email__c','Contact_Phone__c','Contact_DF_Fee_Participant__c','Contact_Origin_Code__c',
                                              'Contact_Can_Sponsor_Children__c','Campaign__c','Contact_Validate_For_Sponsorship__c',
                                              'Contact_Motivated_By__c','Transaction_Type__c','Payment_Type__c','Expiration_Date__c',
                                              'Card_Type__c','Cardholder_Name__c','ABA_Transit_Number__c','Cardholder_Zip__c',
                                              'Account_Number__c','Payment_DF_Taken_Date__c','Card_Security_Code__c','Payment_Method__c',
                                              'Bank_Name__c','Billing_Contact_Name__c','Card_Number__c','Card_Number_Last_4__c'});
        }

        this.record = (Web_Transaction__c)controller.getRecord();
        lstContacts = new List<Contact>();
        this.CreateLineItemList();
        this.PopulatePaymentMethodList();
        this.PopulateAddressRecord();
        this.addressControllers = new List<AddressValidationComponentController>();
        this.ValidateTransaction();
    }

    public boolean ValidateTransaction()
    {
        boolean result = true;

        //no contact
        if(this.record.Contact__c == null)
        {
            this.record.contact__c.addError('Contact not specified');
            result = false;
        }
            
        //no payment method
        if(this.record.Payment_Method__c == null)
        {
            this.record.Payment_Method__c.addError('Payment method not specified');
            result = false;
        }

        for(rC_Connect__Batch_Upload__c donation : this.donations)
        {
            //campaign
            if(donation.rC_Connect__Batch_Upload_Campaign_Matched__c == null)
            {
                donation.rC_Connect__Batch_Upload_Campaign_Matched__c.addError('Campaign not specified for donation: ' + donation.name);
                result = false;
            }

            //giving frequency
            if(donation.rC_Connect__Giving_Giving_Frequency__c == null)
            {
                donation.rC_Connect__Giving_Giving_Frequency__c.addError('Giving frequency not specified for donation: ' + donation.name);
                result = false;
            }
            
            //giving amount
            if(donation.rC_Connect__Giving_Giving_Amount__c == null)
            {
                donation.rC_Connect__Giving_Giving_Amount__c.addError('Giving amount not specified for donation: ' + donation.name);
                result = false;
            }

            //participant - only for sponsorship
            if(donation.Participant__c == null && donation.Product_Type__c == 'Sponsorship')
            {
                donation.Participant__c.addError('Participant not specified for donation: ' + donation.name);
                result = false;
            }
            
            //start date
            
            //dfc related opportunity - only for dfc
            if(donation.DFC_Related_Opportunity__c == null && donation.Product_Type__c == 'Designated Fund')
            {
                donation.DFC_Related_Opportunity__c.addError('DFC Related Opportunity not specified for donation: ' + donation.name);
                result = false;
            }
        }

        return result;

    }

    public void OnContactChanged()
    {
        this.PopulateAddressRecord();

        if(record.Contact__c != null)
        {
            //reload contact info on WT record
            Contact contact = [select id, 
                               recordtype.name,
                               accountid,
                               FirstName,
                               LastName,
                               Salutation,
                               rC_Bios__Suffix__c,
                               Email,
                               Phone,
                               Campaign__c,
                               Origin__c
                               from contact where id = :record.Contact__c limit 1];

            record.Contact_Type__c = contact.recordtype.name;
            record.Contact_First_Name__c = contact.FirstName;
            record.Contact_Last_Name__c = contact.LastName;
            record.Contact_Title__c = contact.Salutation;
            record.Contact_Suffix__c = contact.rc_Bios__Suffix__c;
            record.Contact_Email__c = contact.email;
            record.Contact_Phone__c = contact.Phone;
            record.Campaign__c = contact.Campaign__c;
            record.Contact_Origin_Code__c = contact.Origin__c;

            //update the Payment Method list
            this.PopulatePaymentMethodList();

            //update batch uploads with contact and save
            for(rC_Connect__Batch_Upload__c donation : this.donations)
            {
                donation.rC_Connect__Batch_Upload_Contact_1_Matched__c = contact.id;
                donation.rC_Connect__Batch_Upload_Contact_2_Matched__c = contact.id;
                donation.rC_Connect__Batch_Upload_Account_Matched__c = contact.accountid;
                donation.rC_Connect__Batch_Upload_Payment_Method_Matched__c = null; //because contact has changed, remove payment method
            }

            this.IsAddressReadOnly = true;

        }
        else
        {
            //update the Payment Method list
            this.PopulatePaymentMethodList();
            this.IsAddressReadOnly = false;
            this.record.Payment_Method__c = null;
            
            for(rC_Connect__Batch_Upload__c donation : this.donations)
            {
                donation.rC_Connect__Batch_Upload_Contact_1_Matched__c = null;
                donation.rC_Connect__Batch_Upload_Contact_2_Matched__c = null;
                donation.rC_Connect__Batch_Upload_Account_Matched__c = null;
                donation.rC_Connect__Batch_Upload_Payment_Method_Matched__c = null; //because contact has changed, remove payment method
            }
        }

        update this.donations;
        update this.record;
        
        this.ValidateTransaction();
    }

    public void PopulatePaymentMethodList()
    { 
        if(record.Contact__c != null)
        {
            this.paymentMethodList = [select id, name
                                      from rC_Giving__Payment_Method__c
                                      where rC_Giving__Contact__c = :record.Contact__c]; 
        }
    }

    public List<SelectOption> AGPValues
    {
        get
        {
            List<SelectOption> AGPValues = new List<SelectOption>();
            AGPValues.add(new SelectOption('','--- Select ---'));
            
            if(this.paymentMethodList != null)
                for (rC_Giving__Payment_Method__c pm : paymentMethodList) 
                    AGPValues.add(new SelectOption(pm.id, pm.Name));
            
            return AGPValues;
        }
        set;
    }

    public void PopulateAddressRecord()
    {
        if(this.record.Contact__c == null)
        {
            this.address = new ValidatedAddress(record.Contact_Street_1__c, 
                                                record.Contact_Street_2__c, 
                                                record.Contact_Extra_Address_1__c, 
                                                record.Contact_City__c, 
                                                record.Contact_State_Prov_Terr__c, 
                                                record.Contact_Postal_Code__c, 
                                                record.Contact_Country__c, null, false, false);
        }
        else
        {
            id contactAddressId = [select rC_Bios__Preferred_Mailing_Address__c from Contact where id = :this.record.Contact__c limit 1].rC_Bios__Preferred_Mailing_Address__c;

            rc_Bios__Address__c contactAddress = [select Id,
                                rC_Bios__Street_Line_1__c,
                                rC_Bios__Street_Line_2__c,
                                Extra_Address_1__c,
                                rC_Bios__City__c,
                                rC_Bios__State__c,
                                rC_Bios__Postal_Code__c,
                                rC_Bios__Country__c,
                                Validated__c,
                                Overridden__c
                                from rc_Bios__Address__c
                                where id = :contactAddressId];

            this.address = new ValidatedAddress(contactAddress);
        }

        //populate underlying record address info
        record.Contact_Street_1__c = this.address.Line1;
        record.Contact_Street_2__c = this.address.Line2;
        record.Contact_Extra_Address_1__c = this.address.Line3;
        record.Contact_City__c = this.address.City;
        record.Contact_State_Prov_Terr__c = this.address.StateProv;
        record.Contact_Postal_Code__c = this.address.PostalCode;
        record.Contact_Country__c = this.address.Country; 

    }

    public void OnPaymentMethodChanged()
    {
        if(this.record.Payment_Method__c != null)
        {
            rC_Giving__Payment_Method__c method = [select id,
                                                   rC_Giving__Payment_Type__c,
                                                   rC_Giving__Card_Issuer__c,
                                                   rC_Giving__Routing_Number__c,
                                                   rC_Giving__Bank_Name__c,
                                                   rC_Giving__Account_Number__c,
                                                   rC_Giving__Billing_Contact_Name__c,
                                                   rC_Giving__Card_Number__c,
                                                   rC_Giving__Card_Number_Last_4__c,
                                                   rC_Giving__Card_Security_Code__c,
                                                   rC_Giving__Card_Expiration_Month__c,
                                                   rC_Giving__Card_Expiration_Year__c,
                                                   rC_Giving__Card_Holder_Name__c
                                                   from rC_Giving__Payment_Method__c
                                                   where id = :this.record.Payment_Method__c limit 1];
            
            this.record.Transaction_Type__c = method.rC_Giving__Payment_Type__c;
            this.record.Card_Type__c = method.rC_Giving__Card_Issuer__c;
            this.record.ABA_Transit_Number__c = method.rC_Giving__Routing_Number__c;
            this.record.Bank_Name__c = method.rC_Giving__Bank_Name__c;
            this.record.Account_Number__c = method.rC_Giving__Account_Number__c;
            this.record.Billing_Contact_Name__c = method.rC_Giving__Billing_Contact_Name__c; 
            this.record.Card_Number__c = method.rC_Giving__Card_Number__c;
            this.record.Card_Number_Last_4__c = method.rC_Giving__Card_Number_Last_4__c;    
            this.record.Card_Security_Code__c = method.rC_Giving__Card_Security_Code__c; 
            
            if(method.rC_Giving__Card_Expiration_Year__c != null && method.rC_Giving__Card_Expiration_Month__c != null)
                this.record.Expiration_Date__c = date.newinstance(integer.valueOf('20' + method.rC_Giving__Card_Expiration_Year__c), integer.valueOf(method.rC_Giving__Card_Expiration_Month__c), 1);          
            else
                this.record.Expiration_Date__c = null;

            this.record.Cardholder_Name__c = method.rC_Giving__Card_Holder_Name__c;

            for(rC_Connect__Batch_Upload__c donation : this.donations)       
                donation.rC_Connect__Batch_Upload_Payment_Method_Matched__c = method.id;

            update this.donations;
            update this.record;
        }

        this.ValidateTransaction();
    }

    //get the product type, sub type, GAU for a selected campaign when it changes within a donation line item
    public void OnDonationDataChanged()
    {
        if(this.DonationId != null)
        {
            for(rC_Connect__Batch_Upload__c donation : this.donations)
            {
                if(donation.id == this.DonationId)
                {
                    Id campaignId = donation.rC_Connect__Batch_Upload_Campaign_Matched__c;

                    if(campaignId != null)
                    {
                        Campaign campaign = [select id, rC_Giving__GAU__c, Product_Type__c, Product_Sub_Type__c
                                            from campaign where id = :campaignId limit 1];

                        donation.Product_Type__c = campaign.Product_Type__c;
                        donation.Product_Sub_Type__c = campaign.Product_Sub_Type__c;
                        donation.General_Accounting_Unit__c = campaign.rC_Giving__GAU__c;
                    }   
                    
                    update donation;

                    this.DonationId = null;
                }
            }
        }

        this.ValidateTransaction();
    }

    //set WT record and all batch uploads 'To Process'
    public PageReference PostTransaction()
    {
        PageReference pr;

        if(this.ValidateTransaction())
        {
            this.record.Status__c = 'To Process';
            update this.record;

            for(rC_Connect__Batch_Upload__c donation : this.donations)       
                    donation.rC_Connect__Batch_Upload_Status__c = 'To Process';

            update this.donations;

            pr = (new ApexPages.StandardController(this.record)).View();
        }

        return pr;
    }
    
    private void CreateLineItemList()
    {
        
        
        List<rC_Connect__Batch_Upload__c> lines = [select id, name, General_Accounting_Unit__c, Product_Type__c, Product_Sub_Type__c,
                                                    rC_Connect__Batch_Upload_Giving_Matched__c, rC_Connect__Giving_Giving_Amount__c,
                                                    rC_Connect__Giving_Giving_Frequency__c, rC_Connect__Batch_Upload_Payment_Method_Matched__c,
                                                    rC_Connect__Giving_Close_Date__c, rC_Connect__Batch_Upload_Account_Matched__c, rC_Connect__Batch_Upload_Campaign_Matched__c,
                                                    Participant__c, rC_Connect__Batch_Upload_Contact_1_Matched__c, rC_Connect__Batch_Upload_Contact_2_Matched__c,
                                                    DFC_Related_Opportunity__c, rC_Connect__Batch_Upload_Status__c
                                                  from rC_Connect__Batch_Upload__c
                                                  where Web_Transaction__c = :this.record.id
                                                  and rC_Connect__Batch_Upload_Status__c not in ('Processed','Committed') Limit 1000];
        
        this.donations = lines;
        
        this.DonationCount = string.valueOf(this.Donations.size());
    }

    //interface function for events from AddressValidationComponent
    public void AddressEvent(AddressValidationComponentController addressController)
    {
        //if(addressController.Response.verifyLevel == 'Verified')
        //{
            //save to the WT record on accept of validated address
            record.Contact_Street_1__c = this.address.Line1;
            record.Contact_Street_2__c = this.address.Line2;
            record.Contact_Extra_Address_1__c = this.address.Line3;
            record.Contact_City__c = this.address.City;
            record.Contact_State_Prov_Terr__c = this.address.StateProv;
            record.Contact_Postal_Code__c = this.address.PostalCode;
            record.Contact_Country__c = this.address.Country;

            update record;

            this.ValidateTransaction();
        //}
    }

    
    public PageReference deleteRecords(){
        if(this.record != null) {
            if(this.record.id != null) {
                List<rC_Connect__Batch_Upload__c> lstBUToDelete = [select id, name
                                                  from rC_Connect__Batch_Upload__c
                                                  where Web_Transaction__c = :this.record.id];
                if(lstBUToDelete.size()>0) {
                    delete lstBUToDelete;
                }
                delete this.record;
                return (new PageReference('/a5A/l'));
            }
        }
        return null;
    }
    
    public void sendFollowupEmail(){
        Web_Transaction__c trans = [select Id, Contact__c, Contact__r.Email, Contact__r.Name from Web_Transaction__c where Id =:record.Id];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName('Salesforce Support');
        mail.setUseSignature(false);
        mail.setBccSender(false);
        mail.setSaveAsActivity(false);
        if(this.record.Contact__c != null) {
            Contact con = [SELECT Id, Name, Email, Contact_Number__c FROM Contact WHERE Id = :this.record.Contact__c];
            if(con.Email != null && con.Email != '') {
                //System.debug(trans.Contact__r.Name);
                //String[] toAddresses = new String[] {'munib.rehman@appirio.com'}; 
                mail.setTargetObjectId(this.record.Contact__c);
                //mail.setToAddresses(toAddresses);
                EmailTemplate et=[Select id from EmailTemplate where DeveloperName=:'FollowUp_Email'];
                mail.setTemplateId(et.id);
                Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'An email has been sent to mail Id : '+con.Email));
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Email address is not populated on the specified contact..'));
            }
        }
        else if(this.record.Contact_Email__c != null && this.record.Contact_Email__c != '') {
            invalidContValues = false;
            //do something.
                //mail.setTargetObjectId(this.record.Id);
                String[] toAddresses = new String[] {record.Contact_Email__c}; 
                String fname = '';
                String lname='';
                String emailBody = '';
                List<Contact> contList = [SELECT Id, Name, Email, Contact_Number__c FROM Contact WHERE Email =:this.record.Contact_Email__c];
                EmailTemplate et=[Select id, Body from EmailTemplate where DeveloperName=:'FollowUp_Email'];
                if(contList.size()>0){
                    emailBody = et.Body.replace('{!Contact.Name}', contList.get(0).Name);
                    emailBody = emailBody.replace('{!Contact.Contact_Number__c}', contList.get(0).Contact_Number__c);
                } else {
                    if(record.Contact_First_Name__c != null){
                        fname = record.Contact_First_Name__c;
                    } 
                    if(record.Contact_Last_Name__c != null){
                         lname = record.Contact_Last_Name__c;
                    } 
                    emailBody = et.Body.replace('{!Contact.Name}', fname+' '+lname);
                    emailBody = emailBody.replace('{!Contact.Contact_Number__c}', '');
                }
				mail.setToAddresses(toAddresses);
                mail.setHTMLBody(emailBody);
                Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'An email has been sent to mail Id : '+record.Contact_Email__c));
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please select valid contact or specify valid email addess..'));
        }
    }
   
    public PageReference getContacts() {
		

		
        lstContacts = [select Id, Contact_Number__c, Title, FirstName, LastName, rC_Bios__Suffix__c, Email, Phone from Contact 
                        WHERE RecordType.Name = 'Household' 
                            AND FirstName like :this.record.Contact_First_Name__c AND LastName like :this.record.Contact_Last_Name__c
                            AND rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c like :this.address.line1 
                            AND rC_Bios__Preferred_Mailing_Address__r.rC_Bios__City__c like :this.record.Contact_City__c
                			AND rC_Bios__Preferred_Mailing_Address__r.rC_Bios__State__c like :this.address.stateprov 
                            AND rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Postal_Code__c like :this.record.Contact_Postal_Code__c
                			AND rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c like :this.address.country];
        return null;
    }
}