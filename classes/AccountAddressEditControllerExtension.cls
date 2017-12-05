/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountAddressEditControllerExtension
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Controller extension to support address validation on Account Addresses
 * Created Date : 07/27/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 07/27/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class AccountAddressEditControllerExtension 
{
    public rC_Bios__Account_Address__c record{get;set;}
    public ValidatedAddress address{get;set;}
    private string retUrl{get;set;}
    public List<AddressValidationComponentController> AddressControllers{get;set;}
    
	public AccountAddressEditControllerExtension(ApexPages.StandardController controller)
    {
         List<String> fieldsList = new List<String>{'rC_Bios__Original_Street_Line_1__c','rC_Bios__Original_Street_Line_2__c',
                'rC_Bios__Original_City__c','rC_Bios__Original_State__c','rC_Bios__Original_Postal_Code__c',
                'rC_Bios__Original_Country__c','rC_Bios__Account__c','rC_Bios__Address__c',
                'rC_Bios__Preferred_Billing__c','rC_Bios__Preferred_Shipping__c','rC_Bios__Type__c','rC_Bios__Do_Not_Mail__c',
                'rC_Bios__Active__c','rC_Bios__Verified__c','rC_Bios__Seasonal_Start_Month__c', 'rC_Bios__Seasonal_End_Month__c',
                'rC_Bios__Seasonal_Start_Day__c','rC_Bios__Seasonal_End_Day__c',
                'rC_Bios__Start_Date__c','rC_Bios__End_Date__c','Overridden__c','rC_Bios__Street_Line_1__c', 'rC_Bios__Street_Line_2__c', 'rC_Bios__City__c', 'rC_Bios__State__c',
                                  'rC_Bios__Postal_Code__c', 'rC_Bios__Country__c','rC_Bios__Additional_Line_1__c'};
        
        // 08/05/2016 Appirio Inc. Vaibhav Goel  addFields method throws failure in test-class.
        if(!test.isRunningTest()){
            controller.addFields(fieldsList);
        }
        
        this.record = (rC_Bios__Account_Address__c)controller.getRecord();
        this.address = new ValidatedAddress(this.record);
        this.AddressControllers = new List<AddressValidationComponentController>();
        
        //get the cancel or return url.  If null, use the url of the tab
        this.retUrl = ApexPages.currentPage().getParameters().get('retURL');
        if(this.retUrl == null)
        {
            string prefix = rC_Bios__Account_Address__c.sObjectType.getDescribe().getKeyPrefix();
            this.retUrl = '/' + prefix + '/o';
        }
    }
    
    //saves the record and returns to detail page
    //@return PageReference - the url of the record detail page
    public PageReference Save()
    {
        PageReference ref;
        
        for(AddressValidationComponentController comp : AddressControllers)
            comp.ValidateFields();
        
        if(this.address.isValid)
        {
        	this.record = this.address.rcBiosAccountAddress;
            
            try
            {
                if(record.id == null)
                    insert record;
                else
                    update record;
                
                ref = new PageReference(this.retUrl);
            }
            catch(exception ex)
            {
                system.debug('---exceptionSave---' + ex);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error saving Contact Address: ' + ex.getMessage()));
            }
        }
        
        
        return ref;
    }
    
    //saves record and displays new record edit page
    //@return PageReference - url of a new record edit page
    public PageReference SaveAndNew()
    {
        PageReference ref;
        
        for(AddressValidationComponentController comp : AddressControllers)
            comp.ValidateFields();
        
        if(this.address.isValid)
        {
        	this.record = this.address.rcBiosAccountAddress;
            
            try
            {
                if(record.id == null)
                    insert record;
                else
                    update record;
                
                ref = Page.AddressEdit;
                ref.setRedirect(true);
            }
            catch(exception ex)
            {
                system.debug('---exceptionSaveAndNew---' + ex);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error saving Contact Address: ' + ex.getMessage()));
            }
        }
        
        
        return ref;
    }

    //returns to the detail page
    //@return PageReference - url of the detail page
    public PageReference Cancel()
    {
        return new PageReference(this.retUrl);
    }
}