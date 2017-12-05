/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressEditControllerExtension
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : rc Bios Address Edit controller extension
 * Created Date : 07/13/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 07/13/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class AddressEditControllerExtension
{
    public rC_Bios__Address__c record{get;set;}
    public ValidatedAddress address{get;set;}
    private string retUrl{get;set;}
    private ApexPages.StandardController base;
    public List<AddressValidationComponentController> AddressControllers{get;set;}
    
    //constructor - initializes controller fields, record, and populates address
    public AddressEditControllerExtension(ApexPages.StandardController controller)
    {  
        base = controller;
        
        if(!test.isRunningTest()){
            controller.addFields(new List<String>{'rC_Bios__Street_Line_1__c','rC_Bios__Street_Line_2__c',
            'Extra_Address_1__c','rC_Bios__City__c','rC_Bios__State__c','rC_Bios__Postal_Code__c',
            'rC_Bios__Country__c','Care_of__c','Envelope_Line__c','Ind_Returned_Mail__c','Validated__c','Overridden__c'});    
        }
        
        this.record = (rC_Bios__Address__c)controller.getRecord();
        this.address = new ValidatedAddress(this.record);
        this.AddressControllers = new List<AddressValidationComponentController>();
        
        //get the cancel or return url.  If null, use the url of the tab
        this.retUrl = ApexPages.currentPage().getParameters().get('retURL');
        if(this.retUrl == null)
        {
            string prefix = rC_Bios__Address__c.sObjectType.getDescribe().getKeyPrefix();
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
        
        if(this.address.IsOverridden || this.address.isValid)
        {
        	this.record = this.address.rcBiosAddress;
            
            try
            {
                if(record.id == null)
                    insert record;
                else
                    update record;
                
                ref = new PageReference('/' + this.record.id);
            }
            catch(exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error saving address: ' + ex.getMessage()));
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
        
        if(this.address.IsOverridden || this.address.isValid)
        {
        	this.record = this.address.rcBiosAddress;
            
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error saving address: ' + ex.getMessage()));
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Address must be validated to save.'));
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