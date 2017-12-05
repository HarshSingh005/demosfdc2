/***********************************************************************************************************
 * Appirio, Inc
 * Name         : Contact_ManageAddressesController 
 * Created By   : Rohit B (Appirio)
 * Purpose      : Web Exception controller extension
 * Created Date : 04/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 04/26/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class Contact_ManageAddressesController 
{
    public rC_Bios__Contact_Address__c contactAddressInsert {get; set;}
    public List<rC_Bios__Contact_Address__c> contactAddressList {get; set;}
    public List<rC_Bios__Contact_Address__c> relatedAddressList {get; set;}
    public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    public ValidatedAddress Address {get;set;}
    String conID;
    public List<ValidatedAddress> AddressList {get; Set;}
    public List<AddressValidationComponentController> AddressControllers{get;set;}
    public PageReference redirectToSelf{get;set;}
    // I-251485 | Boolean flag to check if Profile has access to create rC_Bios__Contact_Address__c > Start
    public boolean hasCreateAccessOnContact {get;set;}
    // I-251485 | Boolean flag to check if Profile has access to create rC_Bios__Contact_Address__c > End
    
    public Contact_ManageAddressesController(ApexPages.StandardController controller) 
    {
        
    }
    
    public void initialize() {
        this.AddressControllers = new List<AddressValidationComponentController>();
        
        // I-251485 | Check if the logged in user has create access on Contact Address object > Start
        Schema.DescribeSObjectResult contactDescribeSObjectResult = rC_Bios__Contact_Address__c.sObjectType.getDescribe();
        hasCreateAccessOnContact = contactDescribeSObjectResult.isCreateable();
        if(!hasCreateAccessOnContact){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You do not have access to create a new address.'));
        }
        // I-251485 | End
        conId = ApexPages.currentPage().getParameters().get('id');
        if(conId==null || conId=='') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You are coming from wrong path; Please go to Contact for which you want to create acontactAddressInsert.'));
        }
        else {
            redirectToSelf = Page.Contact_ManageAddresses;
            redirectToSelf.getParameters().put('id',conId);
            contactAddressInsert = new rC_Bios__Contact_Address__c();
            contactAddressList = new List<rC_Bios__Contact_Address__c>();
            relatedAddressList = new List<rC_Bios__Contact_Address__c>();
            Address = new ValidatedAddress(contactAddressInsert);
            this.address.rcBiosContactAddress.rC_Bios__Contact__c = conID;
            AddressList = new List<ValidatedAddress>();
            
      
            contactAddressList = [SELECT Id, rC_Bios__Contact__c, rC_Bios__Type__c, rC_Bios__Verified__c,
                                 rC_Bios__Seasonal_Start_Month__c, rC_Bios__Seasonal_Start_Day__c, rC_Bios__Start_Date__c,
                                 rC_Bios__Seasonal_End_Month__c, rC_Bios__Seasonal_End_Day__c, rC_Bios__End_Date__c,
                                 rC_Bios__Active__c, rC_Bios__Preferred_Mailing__c, rC_Bios__Preferred_Other__c, rC_Bios__Do_Not_Mail__c,
                                 rC_Bios__Original_Street_Line_1__c, rC_Bios__Original_Street_Line_2__c, rC_Bios__Additional_Line_1__c,
                                 rC_Bios__Original_City__c, rC_Bios__Original_State__c, rC_Bios__Original_Country__c, rC_Bios__Original_Postal_Code__c,
                                 rC_Bios__Attention_Line__c, Seasonal_Phone__c, Informational__c, Returned_Mail__c,
                                 rC_Bios__Street_Line_1__c, rC_Bios__Street_Line_2__c, rC_Bios__City__c, rC_Bios__State__c,
                                  rC_Bios__Postal_Code__c, rC_Bios__Country__c, Overridden__c, Care_Of__c, Care_Of__r.Name
                                 FROM rC_Bios__Contact_Address__c 
                                  WHERE rC_Bios__Contact__c = :conId ORDER BY CreatedDate ASC];
            
            
            for(rC_Bios__Contact_Address__c conAddr : contactAddressList) {
                ValidatedAddress conValAdd = new ValidatedAddress(conAddr);
                AddressList.add(conValAdd);
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
            for(rC_Bios__Contact_Address__c conAdd : relatedAddressList) {
                conAdd.rC_Bios__Contact__c = conID;
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
    * @description - Method to upsert contact Addresses and stays on the same page.
    * @return - null
    */
    public PageReference upsertContactAddressList() {
        if(SaveContactAddresses())
        	initialize();
        
        return null;
    }

    /**
    * @description - Method to upsert contact Addresses and redirect to the contact record from which we are coming.
    * @return - null
    */
    public PageReference upsertContactAddressListAndReturn() {
        if(SaveContactAddresses())
            return (new PageReference('/' + conID));
        else
            return null;
    }

    //Saves any contact addresses that are valid and changed.
    private boolean SaveContactAddresses()
    {
        boolean result = validateFields();
        
        if(result)
        {
            System.SavePoint trans = database.setSavepoint();
        
            try
            {
                //save the newly inserted address
                if(this.address.IsChanged)
                	insert this.address.rcBiosContactAddress;
                
                //save any existing addresses
                List<rC_Bios__Contact_Address__c> addressesToSave = new List<rC_Bios__Contact_Address__c>();
                for(ValidatedAddress addr : AddressList)
                    addressesToSave.add(addr.rcBiosContactAddress);
                
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
        
        //first validate the new address has changes and if it is valid
    	if(this.address.IsChanged && (!this.address.IsValid && !this.address.IsOverridden))
        {
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Address must be validated before saving.'));
        }
        
        if(this.address.IsChanged && string.isblank(this.address.rcBiosContactAddress.rC_Bios__Type__c))
        {
            result = false;
            this.address.rcBiosContactAddress.rC_Bios__Type__c.addError('Type is required');
        }
        
        //validate the existing address fields
        for(ValidatedAddress addr : AddressList)
        {
            if(addr.IsChanged && (!addr.IsValid && !addr.IsOverridden))
            {
                result = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Address must be validated before saving.'));
            }
            
            if(string.isblank(addr.rcBiosContactAddress.rC_Bios__Type__c))
            {
                result = false;
                addr.rcBiosContactAddress.rC_Bios__Type__c.addError('Type is required');
            }
        }
        
        return result;
    }
}