/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressValidationComponentController
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Controller class for the AddressValidationComponent
 * Created Date : 07/01/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 07/01/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class AddressValidationComponentController 
{
    public boolean IsRefinementListRendered{get;set;}
    public boolean IsMultipleListRendered{get;set;}
    public boolean IsNoResultsRendered{get;set;}
    public boolean IsVerifiedAddressRendered{get;set;}
    public boolean IsDialogRendered{get;set;}
    public AddressValidateRestResponse Response{get;set;}
    public boolean IsValidVisible{get;set;}
    public boolean IsLine1Required{get;set;}
    public boolean IsLine2Required{get;set;}
    public boolean IsLine3Required{get;set;}
    public boolean IsCityRequired{get;set;}
    public boolean IsStateProvRequired{get;set;}
    public boolean IsCountryRequired{get;set;}
    public boolean IsPostalCodeRequired{get;set;}
    private List<SelectOption> StateProvPicklistValuesList;
    public ValidatedAddress Address{get;set;}
    public string AddressId{get;set;}
    public List<SelectOption> AddressPicklistValuesList{get;set;}
    //public List<string> AddressList{get;set;}
    public string Refinement{get;set;}
    public AddressComponentHostController host{get;set;}
    public boolean IsReadOnly{get;set;}
    
    public boolean IsValidateButtonVisible
    {
        get
        {
            if(this.address.IsValid == false)
                if(this.IsValidVisible && !this.address.IsOverridden)
                	return true; 
            	else
                    return false;
            else
               return false;
                    
        }
        set;
    }
    public List<AddressValidationComponentController> AddressControllers
    {
        get;
        set
        {
            AddressControllers = value;
            AddressControllers.add(this);
        }
    }
    
    public boolean IsAddressRequired
    {
        get;
        set
        {
            IsAddressRequired = value;
            this.ShowRequiredIndicators();
        }
    }
    
    public void ShowRequiredIndicators()
    {
        if(this.IsAddressRequired ||
          (!string.isBlank(this.address.Line1) || !string.isBlank(this.address.Line2)
          || !string.isBlank(this.address.Line3) || !string.isBlank(this.address.City)
          || !string.isBlank(this.address.StateProv) || !string.isBlank(this.address.Country)
          || !string.isBlank(this.address.PostalCode)))
        {
            this.IsLine1Required = true;
            
            if(!string.isBlank(this.address.Line3))
                this.IsLine2Required = true;
            else
                this.IsLine2Required = false;
            
            this.IsCityRequired = true;
            
            if(this.address.Country == 'USA' || this.address.Country == 'CAN')           
                this.IsStateProvRequired = true;           
            else
                this.IsStateProvRequired = false;
            
            this.IsCountryRequired = true;
            this.IsPostalCodeRequired = true;
        }
        else
        {
            this.IsLine1Required = false;
            this.IsLine2Required = false;
            this.IsCityRequired = false;
            this.IsStateProvRequired = false;   
            this.IsCountryRequired = false;
            this.IsPostalCodeRequired = false;
        }
        
        if(this.address.Country == 'USA')
            this.IsValidVisible = true;
        else
            this.IsValidVisible = false;
    } 
    
    //validates the address with the provider through a service call
    public void ValidateAddress()
    {
    	try
        {
            
            //call the appropriate address validation method
            if(string.isBlank(this.AddressId))
            {
                //verify address
                if(!Test.isRunningTest()) {
                    System.debug('Address >> ' + address);
                	this.Response = AddressValidateRestApi.VerifyAddress(address);
                } else {
                	AddressValidateRestResponse res = instatiateResponseForTest();
                	res.verifyLevel = 'Multiple';
			        this.Response = res;
                }
            }
            
            if(!string.isBlank(this.AddressId) && string.isBlank(this.Refinement))
            {
                //call layout
                if(!Test.isRunningTest()) {
                	this.Response = AddressValidateRestApi.AddressLayout(this.AddressId);
                } else {
                	AddressValidateRestResponse res = instatiateResponseForTest();
                	res.verifyLevel = 'Verified';
			        this.Response = res;
                }
                this.AddressId = null;
                this.Refinement = null;
            }
            
            if(!string.isBlank(this.AddressId) && !string.isBlank(this.Refinement))
            {
                //call refine
                if(!Test.isRunningTest()) {
                	this.Response = AddressValidateRestApi.RefineAddress(this.AddressId, this.Refinement, address.Country);
                } else {
                	AddressValidateRestResponse res = instatiateResponseForTest();
			        res.verifyLevel = 'None';
			        this.Response = res;
                }
                this.AddressId = null;
                this.Refinement = null;
            }
            
            
            //display the modal dialog and the appropriate section based on the response
            this.IsDialogRendered = true;
            
            if(response.verifyLevel == 'Verified' || response.verifyLevel == 'InteractionRequired')
            {
                this.IsVerifiedAddressRendered = true;
                this.IsRefinementListRendered = false;
                this.IsNoResultsRendered = false;
                this.IsMultipleListRendered = false;
            }
            //else if(response.verifyLevel == 'None' && response.prompt == null)
            else if(response.verifyLevel == 'None' && response.results.size() == 1 && response.results[0].text == 'No matches')    
            {
            	this.IsNoResultsRendered = true;
            	this.IsVerifiedAddressRendered = false;
            	this.IsRefinementListRendered = false;
                this.IsMultipleListRendered = false;
            }
            else if(response.verifyLevel == 'PremisesPartial' ||
            response.verifyLevel == 'StreetPartial' ||
            response.verifyLevel == 'Multiple'|| response.verifyLevel == 'None') 
            {
                if(response.verifyLevel == 'Multiple' || response.verifyLevel == 'None')
                {
                    this.IsRefinementListRendered = false;
                	this.IsMultipleListRendered = true;
                }
                else
                {
                    this.IsRefinementListRendered = true;
                	this.IsMultipleListRendered = false;
                }

                this.IsVerifiedAddressRendered = false;
                this.IsNoResultsRendered = false;
                
                
                this.AddressPicklistValuesList = new List<SelectOption>();
                           
                for(AddressValidateRestResponse.result result : response.results)
                {
                	SelectOption option = new SelectOption(result.id, result.text);
            		this.AddressPicklistValuesList.add(option);
                }
            }
            else
            {
                this.IsVerifiedAddressRendered = true;
                this.IsRefinementListRendered = false;
                this.IsNoResultsRendered = false;
                this.IsMultipleListRendered = false;
            }
            
            	
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        
    }
    
    public void OverrideAddress()
    {
        this.address.IsOverridden = true;
        this.address.IsValid = false;
        this.IsDialogRendered = false;
        this.IsRefinementListRendered = false;
        this.IsMultipleListRendered = false;
        this.IsNoResultsRendered = false;
    }
    
    public void CloseNoResults()
    {
    	this.IsDialogRendered = false;
        this.IsRefinementListRendered = false;
        this.IsMultipleListRendered = false;
        this.IsNoResultsRendered = false;
    }

    public void AcceptAddressList()
    {
        this.IsDialogRendered = false;
        this.IsRefinementListRendered = false;
        this.IsMultipleListRendered = false;
        this.IsNoResultsRendered = false;
    }

    public void CloseAddressList()
    {
        this.IsDialogRendered = false;
        this.IsRefinementListRendered = false;
        this.IsMultipleListRendered = false;
        this.IsNoResultsRendered = false;
    }

    public void AcceptVerifyAddress()
    {
        this.Address.IsValid = true;
        this.address.IsOverridden = false;
        this.Address.Line1 = response.fields[0].content;
        this.Address.Line2 = response.fields[1].content;
        this.Address.Line3 = response.fields[2].content;
        this.Address.City = response.fields[3].content;
        this.Address.StateProv = response.fields[4].content;
        this.Address.PostalCode = response.fields[5].content;
        this.Address.IsChanged = true;
        this.IsDialogRendered = false;
        this.IsVerifiedAddressRendered = false;   
        this.IsRefinementListRendered = false;
        this.IsMultipleListRendered = false;
        this.IsNoResultsRendered = false;

        if(this.host != null)
            host.AddressEvent(this);
    }
    
    public void CloseVerifyAddress()
    {
        this.Address.IsValid = false;
        this.IsDialogRendered = false;
        this.IsVerifiedAddressRendered = false;  
    }
    
    public List<SelectOption> StateProvPicklistValues
    {
        get
        {
            this.RefreshStateProvPicklistValues();
            return this.StateProvPicklistValuesList;
        }
        set;
    }
    
    public void RefreshStateProvPicklistValues()
    {
        List<SelectOption> options = new List<SelectOption>();
        //get all of the state code values
        List<StateTerrProvRefCodes__c> codesList = StateTerrProvRefCodes__c.getAll().values();
        
        //create a custom sorted list that sorts by description instead of name and sort the list
        List<StateTerrProvRefCodesSortWrapper> sortList = new List<StateTerrProvRefCodesSortWrapper>();
        
        for(StateTerrProvRefCodes__c code : codesList)
        {
            if(this.address.Country == 'USA')
            {
                if(code.Code_Type__c != 'PROV')
                    sortList.add(new StateTerrProvRefCodesSortWrapper(code));
            }
            else if(this.address.Country == 'CAN')
            {
                if(code.Code_Type__c == 'PROV')
                    sortList.add(new StateTerrProvRefCodesSortWrapper(code));
            }
        }
        
        sortList.sort();
        
        options.add(new SelectOption('','-- Select --'));
        for(StateTerrProvRefCodesSortWrapper wrap : sortList)
        {
            SelectOption option = 
                new SelectOption(wrap.StateRefCodes.Code__c, wrap.StateRefCodes.Code__c + ' - ' + wrap.StateRefCodes.Description__c);
            options.add(option);
        }
        
        this.StateProvPicklistValuesList = options;
    }
    
    public List<SelectOption> CountryPicklistValues
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            
            //get all of the countries code values
            List<CountriesRefCodes__c> codesMap = CountriesRefCodes__c.getAll().values();
           
            //create a custom sorted list that sorts by description instead of name and sort the list
            List<CountriesRefCodesSortWrapper> sortList = new List<CountriesRefCodesSortWrapper>();
            
            for(CountriesRefCodes__c code : codesMap)
            {
            	sortList.add(new CountriesRefCodesSortWrapper(code));
            }
            
            sortList.sort();
            
            //add the sorted list items to the returned list
            options.add(new SelectOption('','-- Select --'));
            for(CountriesRefCodesSortWrapper wrap : sortList)
            {
                SelectOption option = 
                    new SelectOption(wrap.CountriesRefCodes.Code__c, wrap.CountriesRefCodes.Code__c + ' - ' + wrap.CountriesRefCodes.Description__c);
                options.add(option);
            }
            
            return options;
        }
        set;
    }
    
    public void CountryChanged()
    {     
        if(this.address.Country != 'USA' && this.address.Country != 'CAN')
        {
            this.address.StateProv = null;
            this.address.City = null;
            this.address.PostalCode = null;
        }

        this.address.StateProv = null;
        this.address.IsChanged = true;
        this.address.IsValid = false;
        this.address.IsOverridden = false;
        this.RefreshStateProvPicklistValues();
        this.ShowRequiredIndicators();
    }
    
    public void LineChanged()
    {
        this.address.IsChanged = true;
        this.address.IsValid = false;
        this.address.IsOverridden = false;
        this.ShowRequiredIndicators();  

        if(this.host != null)
            host.AddressEvent(this); 
    }
    
    public void ValidateFields()
    {
        //USA based address must be validated to save
        if(this.address.country == 'USA' && !this.address.IsValid)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Address must validated.'));
        
        if(this.IsLine1Required && string.IsBlank(this.address.Line1))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Line 1 is required.'));
        
        if(this.IsLine2Required && string.IsBlank(this.address.Line2))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Line 2 is required.'));
        
        if(this.IsCityRequired && string.IsBlank(this.address.City))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'City is required.'));
        
        if(this.IsStateProvRequired && string.IsBlank(this.address.StateProv))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'State/Province is required.'));
        
        if(this.IsCountryRequired && string.IsBlank(this.address.Country))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Country is required.'));
        
        if(this.IsPostalCodeRequired && string.IsBlank(this.address.PostalCode))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Postal Code is required.'));
    }
    
    public AddressValidateRestResponse instatiateResponseForTest(){
    	AddressValidateRestResponse.result addressValidateResult = createResultsRecord('','','','');
        List<AddressValidateRestResponse.result> resultList = new List<AddressValidateRestResponse.result>();
        resultList.add(addressValidateResult);
        AddressValidateRestResponse.field addressValidateField;
        List<AddressValidateRestResponse.field> fieldList = new List<AddressValidateRestResponse.field>();
		for(integer i=0;i<6;i++){
        	 addressValidateField = createFieldsRecord('','','');
        	 fieldList.add(addressValidateField);
        }
    	AddressValidateRestResponse addressValidate = new AddressValidateRestResponse();
        addressValidate.results = resultList;
        addressValidate.count = 0;
        addressValidate.fields = fieldList;
        addressValidate.query = '';
        addressValidate.verifyLevel = '';
        return addressValidate;
    }
     // Creating instance of AddressValidateRestResponse.field class
    public AddressValidateRestResponse.field createFieldsRecord(String id, String label, String content){
    	AddressValidateRestResponse.field addressValidateField = new AddressValidateRestResponse.field();
        addressValidateField.id=id;
        addressValidateField.label = label;
        addressValidateField.content = content;
        return addressValidateField;
    }
    
    // Creating instance of AddressValidateRestResponse.result class
    public AddressValidateRestResponse.result createResultsRecord(String id, String text, String grouped, String url){
    	AddressValidateRestResponse.result addressValidateResult = new AddressValidateRestResponse.result();
        addressValidateResult.id=id;
        addressValidateResult.text = text;
        addressValidateResult.grouped = grouped;
        addressValidateResult.url = url;
        return addressValidateResult;
    }
}