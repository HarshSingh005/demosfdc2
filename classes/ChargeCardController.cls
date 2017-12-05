/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ChargeCardController 
 * Created By   : Ashu Gupta(Original T-517360)
 * Purpose      : to insert new payment mehtod for Charge Card Record Type
 * Created Date : July 07, 2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * July 29, 2016                Ashu Gupta              Increased code coverage
 * Dec 19, 2016                 Ravi Chauhan            I-248489 | commented a piece of code
 **********************************************************************************************************/

public with sharing class ChargeCardController {
    // Public variables used on VF page.
    public rC_Giving__Payment_Method__c PaymentMethod{get; set;}
    public ValidatedAddress address {get; set;}
    public String retURL{get; set;}
    public String URL{get; set;}
    public boolean isNew = true;
    public boolean isChargeRecordType{get;set;}
    public boolean isEFTRecordType{get;set;}
    public static final String CHARGECARD = 'Charge Card';
    public static final String EFT = 'EFT';
    public List<AddressValidationComponentController> AddressControllers{get;set;}
    
    public string pageTitle
    {
        get
        {
            if(this.isChargeRecordType)
            {
                if(isNew)
                    return 'New Charge Card Payment Method';
                else
                    return 'Edit Charge Card Payment Method';
            }
            else
            {
                if(isNew)
                    return 'New EFT Payment Method';
                else
                    return 'Edit EFT Payment Method';
            }   
        }
        set;
    }
    
    public string accountInfoTitle
    {
        get
        {
            if(this.isChargeRecordType)
                return 'Charge Card Information';
            else
                return 'Bank Account Information';
        }
        set;
    }
    
    public pagereference Redirect()
    {
        PageReference standardEditPage = null;
        string url;
        Map<Id, schema.recordtypeinfo> recordTypeMap = rC_Giving__Payment_Method__c.sObjectType.getDescribe().getRecordTypeInfosById();
        
        if(Apexpages.currentPage().getParameters().get('id') == null)
        {
            Id recordTypeId = Id.valueOf(Apexpages.currentPage().getParameters().get('RecordType'));
        	String recordTypeName = recordTypeMap.get(recordTypeId).getName();
            
            if(recordTypeName != CHARGECARD && recordTypeName != EFT)
            {
                url = '/'+rC_Giving__Payment_Method__c.sobjecttype.getDescribe().getKeyPrefix()+'/e?RecordType='+recordTypeId+'&retURL='+retURL+'&nooverride=1';
                standardEditPage = new PageReference(url);
                //standardEditPage.setRedirect(true);
            }
        }
        else
        {
            Id recordId = id.valueof(Apexpages.currentPage().getParameters().get('id'));
            
            string recordTypeName = [select recordtype.name from rC_Giving__Payment_Method__c where id = :recordId limit 1].recordtype.name;
            
            if(recordTypeName != CHARGECARD && recordTypeName != EFT)
            {
                url = '/'+recordId+'/e?nooverride=1';
                standardEditPage = new PageReference(url);
                //standardEditPage.setRedirect(true);
            }
        }
        
        return standardEditPage;
    }
    
    public ChargeCardController(ApexPages.StandardController controller) {
        isChargeRecordType = false;
        isEFTRecordType = false;
        this.AddressControllers = new List<AddressValidationComponentController>();
        
        Map<Id, schema.recordtypeinfo> recordTypeMap = rC_Giving__Payment_Method__c.sObjectType.getDescribe().getRecordTypeInfosById();
        if(controller.getId()!= null){
            isNew = false;
        }
        
        if(isNew){
            Id recordTypeId = Id.valueOf(Apexpages.currentPage().getParameters().get('RecordType'));
            PaymentMethod = (rC_Giving__Payment_Method__c)controller.getRecord();

            if(Apexpages.currentPage().getParameters().get('contactid') != null)
                PaymentMethod.rC_Giving__Contact__c = Id.valueOf(Apexpages.currentPage().getParameters().get('contactid'));

            this.address= new ValidatedAddress();
            PopulateAccountContactInfo();
            retURL = Apexpages.currentPage().getParameters().get('retURL');
            String recordTypeName = recordTypeMap.get(recordTypeId).getName();
            if(recordTypeName == CHARGECARD){
                isChargeRecordType = true;
            }
            else if(recordTypeName == EFT){
                isEFTRecordType = true;
            }
            else {
                URL = '/'+rC_Giving__Payment_Method__c.sobjecttype.getDescribe().getKeyPrefix()+'/e?RecordType='+recordTypeId+'&retURL='+retURL+'&nooverride=1';
            }
        }
        else {
            PaymentMethod = (rC_Giving__Payment_Method__c)controller.getRecord();
            this.address= new ValidatedAddress();
            PaymentMethod = [SELECT Name,rC_Giving__Billing_Contact_Name__c, rC_Giving__Is_Active__c,rC_Giving__Account__c,rC_Giving__Is_Default__c,rC_Giving__Contact__c,
                             RecordTypeId,rC_Connect__Billing_Phone__c, rC_Giving__Billing_Street__c,rC_Giving__Billing_State__c,
                             rC_Giving__Billing_City__c,rC_Giving__Billing_Country__c, Billing_Country_ISO3__c, rC_Giving__Billing_Postal_Code__c,rC_Giving__Card_Holder_Name__c,
                             rC_Giving__Card_Number_Last_4__c,rC_Giving__Card_Issuer__c,rC_Giving__Card_Security_Code__c,rC_Giving__Card_Number__c,
                             rC_Giving__Card_Expiration_Month__c,rC_Giving__Card_Expiration_Year__c,SEQID__c,
                             rC_Giving__Account_Number_Last_4__c,Integrated_Date__c,Payment_Method_External_ID__c,
                             Legacy_Created_Date__c,Payment_Method_Number__c,rC_Giving__Routing_Number__c,rC_Giving__Account_Number__c,
                             rC_Giving__Account_Type__c,rC_Giving__Bank_Name__c,Validated_Address__c,Overridden_Address__c
                             
                             FROM rC_Giving__Payment_Method__c 
                             WHERE Id = :PaymentMethod.Id];

            String recordTypeName = recordTypeMap.get(PaymentMethod.RecordTypeId).getName();

            if(recordTypeName == CHARGECARD || recordTypeName == EFT){
                if(recordTypeName == CHARGECARD)
                    isChargeRecordType = true;
                if(recordTypeName == EFT)
                    isEFTRecordType = true;
                
                address.Line1 = PaymentMethod.rC_Giving__Billing_Street__c;
                address.city = PaymentMethod.rC_Giving__Billing_City__c;
                address.PostalCode = PaymentMethod.rC_Giving__Billing_Postal_Code__c;
                address.StateProv = PaymentMethod.rC_Giving__Billing_State__c;
                address.Country = PaymentMethod.Billing_Country_ISO3__c;
                address.IsValid = PaymentMethod.Validated_Address__c;
                address.IsOverridden = PaymentMethod.Overridden_Address__c;
            }
            else {
                isChargeRecordType = false;
                isEFTRecordType = false;
                URL = '/'+PaymentMethod.Id+'/e?nooverride=1';
            }
        }   
        
    }
    
    //if the account or contact is specified on create or changes on edit
    //populate the address and other info for either
    public pageReference PopulateAccountContactInfo()
    {
        if(this.PaymentMethod.rC_Giving__Account__c != null &&
           this.PaymentMethod.rC_Giving__Contact__c == null)
        {
            //the contact is not specified so get the address from the account
            Account account = [select rC_Bios__Preferred_Billing_Address__c,
                                rC_Bios__Preferred_Contact__r.name
                               from Account
                               where id = :this.PaymentMethod.rC_Giving__Account__c limit 1];
            
            PaymentMethod.rC_Giving__Card_Holder_Name__c = account.rC_Bios__Preferred_Contact__r.name;
            
            if(account.rC_Bios__Preferred_Billing_Address__c != null)
            {
                rC_Bios__Address__c billing = [select rC_Bios__Street_Line_1__c,
                                               rC_Bios__Street_Line_2__c,
                                               Extra_Address_1__c,
                                               rC_Bios__City__c,
                                               rC_Bios__State__c,
                                               rC_Bios__Postal_Code__c,
                                               rC_Bios__Country__c,
                                               Validated__c,
                                               Overridden__c
                                               from rC_Bios__Address__c 
                                               where id = :account.rC_Bios__Preferred_Billing_Address__c
                                               limit 1];
                
                this.address = new ValidatedAddress(billing);
            }
        }
        else if(this.PaymentMethod.rC_Giving__Account__c == null &&
           this.PaymentMethod.rC_Giving__Contact__c == null)
        {
            this.address = new ValidatedAddress();
        }
        else if(this.PaymentMethod.rC_Giving__Contact__c != null)
        {
            //contact is specified so always get address from contact 
            //even if the account is specified
            Contact contact = [select name, accountid, rC_Bios__Preferred_Mailing_Address__c, Phone
                               from Contact
                               where id = :this.PaymentMethod.rC_Giving__Contact__c limit 1];
            

            PaymentMethod.rC_Giving__Card_Holder_Name__c = contact.name;
            PaymentMethod.rC_Giving__Billing_Contact_Name__c = contact.name;
            PaymentMethod.rC_Connect__Billing_Phone__c = contact.Phone;
            PaymentMethod.rC_Giving__Account__c = contact.accountid;
            

            if(contact.rC_Bios__Preferred_Mailing_Address__c != null)
            {
                rC_Bios__Address__c mailing = [select rC_Bios__Street_Line_1__c,
                                               rC_Bios__Street_Line_2__c,
                                               Extra_Address_1__c,
                                               rC_Bios__City__c,
                                               rC_Bios__State__c,
                                               rC_Bios__Postal_Code__c,
                                               rC_Bios__Country__c,
                                               Validated__c,
                                               Overridden__c
                                               from rC_Bios__Address__c 
                                               where id = :contact.rC_Bios__Preferred_Mailing_Address__c
                                               limit 1];
                
                this.address = new ValidatedAddress(mailing); 
            }
        }
        
        return null;
    }
    
    //  To save the Payment method in database.
    //  @param null
    //  @return a new PageReferencewith inserted PaymentMethodID as parameter.
    public PageReference save() {
        PageReference ref = null;
        
        for(AddressValidationComponentController comp : AddressControllers)
            comp.ValidateFields();
        System.debug('RSC >> address ' + this.address + ' PaymentMethod ' + PaymentMethod );
        try
        {
            if(this.address.IsOverridden || this.address.IsValid)
            {
                PaymentMethod.rC_Giving__Billing_Street__c = address.Line1;
                PaymentMethod.rC_Giving__Billing_City__c = address.city;
                PaymentMethod.rC_Giving__Billing_Postal_Code__c= address.PostalCode;
                PaymentMethod.rC_Giving__Billing_State__c = address.StateProv;
                PaymentMethod.rC_Giving__Billing_Country__c = LookupService.GetCountryISO2Code(address.Country);
                PaymentMethod.Billing_Country_ISO3__c = address.Country;
                PaymentMethod.Validated_Address__c = address.IsValid;
                PaymentMethod.Overridden_Address__c = address.IsOverridden;
                upsert PaymentMethod;
                
                ref = new PageReference('/' + this.PaymentMethod.id);
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error in validating address. Please correct the address first..'));
            }
        }catch(Exception dmlEx){
            //I-248489 | commented the throw keyword
            //throw new ChildFundException.CustomDMLException('There was an error saving the Payment Method. ' + dmlEx.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There was an error saving the Payment Method.'));
            //ref = new PageReference('/apex/EditChargeCard?retURL=' + Apexpages.currentPage().getParameters().get('retURL'));
        }
        
        return ref;
    }
    
    //  Return to the Payment method home page
    //  @param null
    //  @return a new PageReference with retURL 
    public PageReference cancel() {
        
        if(retURL == Null)
        {
            if(PaymentMethod.Id != null)
                retURL = '/' + PaymentMethod.id;
            else
            {
                Schema.DescribeSObjectResult result = Account.SObjectType.getDescribe();
                retUrl = result.getKeyPrefix();
            }    
        }
        return (new PageReference(retURL));
    }
    
    //looks up the bank name given a routing number
    //okay to fail silently on no lookup or invalid input
    //uses existing function developed for web site
    //which looks for Routing_Number__c objects and returns their associated Account.Name
    public void lookupBankName()
    {
        try
        {
            integer routingNumber = integer.valueOf(this.PaymentMethod.rC_Giving__Routing_Number__c);
            this.PaymentMethod.rC_Giving__Bank_Name__c = TransactionService.GetBankName(routingNumber);
        }
        catch(exception ex)
        {}
    }
}