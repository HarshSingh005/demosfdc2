public class Account_ManageAddressesController {
    
    public List<rC_Bios__Account_Address__c> accountAddressList {get;set;}// ////List of all the available address
    public rC_Bios__Account_Address__c accountAddressInsert {get;set;}// New account address to be inserted
    public List<rC_Bios__Account_Address__c> relatedAddressList {get; set;}
    public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	public ValidatedAddress Address {get;set;}
    String accID;
    public List<ValidatedAddress> AddressList {get; Set;}
    public List<AddressValidationComponentController> AddressControllers{get;set;}
    public PageReference redirectToSelf{get;set;}
    // I-251485 | Boolean flag to check if Profile has access to create rC_Bios__Account_Address__c > Start
    public boolean hasCreateAccessOnAccountAddress {get;set;}
    // I-251485 | Boolean flag to check if Profile has access to create rC_Bios__Account_Address__c > End

    /**
	* @description - Constructor
	* @param - ApexPages.StandardController
	* @return - null
	*/
    public Account_ManageAddressesController(ApexPages.StandardController stdController) {
        Address = new ValidatedAddress();
        addressControllers = new List<AddressValidationComponentController>();
    }
    
    /**
	* @description - Method for initialization
	* @return - null
	*/
    public void initialize() {
        accID = ApexPages.currentPage().getParameters().get('id');
        
        // I-251485 | Check if the logged in user has create access on Contact Address object > Start
        Schema.DescribeSObjectResult AccountAddresstDescribeSObjectResult = rC_Bios__Account_Address__c.sObjectType.getDescribe();
        hasCreateAccessOnAccountAddress = AccountAddresstDescribeSObjectResult.isCreateable();
        if(!hasCreateAccessOnAccountAddress){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You do not have access to create a new address.'));
        }
        // I-251485 | End
        
        if(accID==null || accID=='') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You are coming from wrong wDisplayObjectDetail; Please go to Account for which you want to create a accountAddressInsert.'));
        }
        else {
            System.debug('RSC >> accID ' + accID);
			redirectToSelf = Page.Account_ManageAddresses;
            redirectToSelf.getParameters().put('id',accID);
            accountAddressInsert = new rC_Bios__Account_Address__c();
            accountAddressList = new List<rC_Bios__Account_Address__c>();
            relatedAddressList = new List<rC_Bios__Account_Address__c>();
            System.debug('RSC >> accountAddressInsert ' + accountAddressInsert);
            Address = new ValidatedAddress(accountAddressInsert);
            this.address.rcBiosAccountAddress.rC_Bios__Account__c = accID;
            AddressList = new List<ValidatedAddress>();
            
      
            accountAddressList = [SELECT Id, rC_Bios__Account__c, rC_Bios__Type__c, rC_Bios__Verified__c,rC_Bios__Preferred_Billing__c,
                                 rC_Bios__Seasonal_Start_Month__c, rC_Bios__Seasonal_Start_Day__c, rC_Bios__Start_Date__c,
                                 rC_Bios__Seasonal_End_Month__c, rC_Bios__Seasonal_End_Day__c, rC_Bios__End_Date__c,
                                 rC_Bios__Original_Street_Line_1__c, rC_Bios__Original_Street_Line_2__c, rC_Bios__Additional_Line_1__c,
                                 rC_Bios__Original_City__c, rC_Bios__Original_State__c, rC_Bios__Original_Country__c, rC_Bios__Original_Postal_Code__c,
                                 rC_Bios__Attention_Line__c, Seasonal_Phone__c, rC_Bios__Active__c, 
                                 rC_Bios__Street_Line_1__c, rC_Bios__Street_Line_2__c, rC_Bios__City__c, rC_Bios__State__c,
                                 rC_Bios__Postal_Code__c, rC_Bios__Country__c, Overridden__c ,
                                 rC_Bios__Preferred_Shipping__c,rC_Bios__Do_Not_Mail__c
                                 FROM rC_Bios__Account_Address__c 
                                 WHERE rC_Bios__Account__c = :accID ORDER BY CreatedDate ASC];
            
            
            for(rC_Bios__Account_Address__c accAddr : accountAddressList) {
                ValidatedAddress accValAdd = new ValidatedAddress(accAddr);
                AddressList.add(accValAdd);
            } 
        }
    }
	
    /**
    * @description - Method to fetch the list of field names by the objectName and FieldSetName.
    * Parameter 1 - Object Name whose field set we are using to fetch fields.
    * Parameter 2 - FieldSet Name from which we will get field names.
    * @return - List<Schema.FieldSetMember>
    */
    List<Schema.FieldSetMember> getFields(String objectName, String fsName) {
        return schemaMap.get(objectName).getDescribe().FieldSets.getMap().get(fsName).getFields();
    }
	
	/**
    * 
    * @description - Method to insert related Addresses.
    * @return - null
    */
    public PageReference insertRelatedAddress() {
        try {
            for(rC_Bios__Account_Address__c accAdd : relatedAddressList) {
                accAdd.rC_Bios__Account__c = accID;
            }
            insert relatedAddressList;
            initialize();
        }
        catch(Exception e) {
            system.debug('----exceptionWhileInserting---' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
        return null;
    }
	
	/**
    * @description - Method to upsert account Addresses and stays on the same page.
    * @return - null
    */
    public PageReference upsertAccountAddressList() {
        if(SaveAccountAddresses())
        	initialize();
        
        return null;
    }
	
	/**
    * @description - Method to upsert account Addresses and redirect to the account record from which we are coming.
    * @return - null
    */
    public PageReference upsertAccountAddressListAndReturn() {
        if(SaveAccountAddresses())
            return (new PageReference('/' + accID));
        else
            return null;
    }
	
	//Saves any account addresses that are valid and changed.
    private boolean SaveAccountAddresses()
    {
        boolean result = validateFields();
        
        if(result)
        {
            System.SavePoint trans = database.setSavepoint();
        
            try
            {
                //save the newly inserted Address
                if(this.Address.IsChanged)
                	insert this.Address.rcBiosAccountAddress;
                
                //save any changed existing addresses
                List<rC_Bios__Account_Address__c> addressesToSave = new List<rC_Bios__Account_Address__c>();
                for(ValidatedAddress addr : AddressList)
                    addressesToSave.add(addr.rcBiosAccountAddress);
                
                if(addressesToSave.size() > 0)
                    update addressesToSave;
            }
            catch(exception ex)
            {
                result = false;
                database.rollback(trans);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            }
        }
        
        return result;
    }
	
	//Field validation before save
    private boolean validateFields()
    {
    	boolean result = true;
    	System.debug('RSC >> Address ' + Address);
    	//System.debug('RSC >> Address.IsChanged ' + this.Address.IsChanged);
        //System.debug('RSC >> Address.rcBiosAccountAddress ' + Address.rcBiosAccountAddress);
        //System.debug('RSC >> Address.rcBiosAccountAddress.rC_Bios__Type__c ' + Address.rcBiosAccountAddress.rC_Bios__Type__c);
        //first validate the new address has changes and if it is valid
    	if(this.Address.IsChanged && (!this.Address.IsValid && !this.Address.IsOverridden))
        {
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Address must be validated before saving.'));
        }

        if(this.Address.IsChanged && string.isblank(this.Address.rcBiosAccountAddress.rC_Bios__Type__c))
        {
            result = false;
            this.address.rcBiosAccountAddress.rC_Bios__Type__c.addError('Type is required');
        }
        
        //validate the existing address fields
        for(ValidatedAddress addr : AddressList)
        {
            if(addr.IsChanged && (!addr.IsValid && !addr.IsOverridden))
            {
                result = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Address must be validated before saving.'));
            }
            
            if(string.isblank(addr.rcBiosAccountAddress.rC_Bios__Type__c))
            {
                result = false;
                addr.rcBiosAccountAddress.rC_Bios__Type__c.addError('Type is required');
            }
        }
        
        return result;
    }    
}