/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressValidationComponentControllerTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the AddressValidationComponentController
 * Created Date : 10/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 10/04/2016                   Munib Ur Rehman       Created
 **********************************************************************************************************/
@isTest
public with sharing class AddressValidationComponentControllerTest
{
    Static rC_Bios__Account_Address__c acctAddress;
    Static rC_Bios__Contact_Address__c contAddress;
    Static rC_Bios__Address__c prefMailingAddTemp;
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Static AddressValidateRestResponse.result addressValidateResult;
    Static AddressValidateRestResponse addressValidate;
    Static ValidatedAddress validateAdd1;
    Static AddressValidationComponentController addressValidComponent;
    
    
    @isTest
    public static void testAddressValidationComponentController() {
        //setting up of all data 
        setUpTestData();
        Test.startTest();
        boolean isValid = addressValidComponent.IsValidateButtonVisible;
        
        // calling different methods of AddressValidationComponentController class
        addressValidComponent.CountryChanged();
        addressValidComponent.lineChanged();
        System.assert(validateAdd1.isChanged == true);
        addressValidComponent.ValidateAddress();
        System.assert(addressValidComponent.Response.verifyLevel == 'None');
        addressValidComponent.CloseNoResults();
        System.assert(addressValidComponent.IsDialogRendered == false);
        addressValidComponent.AcceptAddressList();
        System.assert(addressValidComponent.IsRefinementListRendered == false);
        addressValidComponent.CloseAddressList();
        System.assert(addressValidComponent.IsMultipleListRendered == false);
        addressValidComponent.AcceptVerifyAddress();
        System.assert(validateAdd1.IsChanged == true);
        addressValidComponent.CloseVerifyAddress();
        System.assert(addressValidComponent.IsDialogRendered == false);
        
        
        validateAdd1.country = 'USA';
        addressValidComponent.ValidateFields();
        validateAdd1 = new ValidatedAddress('','','','','','','CAN','111111',true, false);
        addressValidComponent.ValidateFields();
        
        // Creating another controleer instance to have the list of the controllers.
        List<AddressValidationComponentController> ctrls = new List<AddressValidationComponentController>();
        ctrls.add(addressValidComponent);
        AddressValidationComponentController addressValidComponent2 = new AddressValidationComponentController();
        addressValidComponent2.AddressControllers = ctrls;
        
        // Code coverage for picklist values
        List<SelectOption> pickValues = addressValidComponent.CountryPicklistValues;
        List<SelectOption> pickValues2 = addressValidComponent.StateProvPicklistValues;
        
        // Code coverage for IsValidateButtonVisible
        validateAdd1.isValid = false;
        isValid = addressValidComponent.IsValidateButtonVisible;
        validateAdd1 = new ValidatedAddress('','','','','','','','',false,false);
        validateAdd1.Country = '';
        addressValidComponent.IsAddressRequired = false;
        addressValidComponent.CountryChanged();
        addressValidComponent.Refinement = '';
        addressValidComponent.AddressId = '';
        addressValidComponent.ValidateAddress();
        System.assert(addressValidComponent.Response.verifyLevel == 'Multiple');
        addressValidComponent.AddressId = '12345';
        addressValidComponent.ValidateAddress();
        
        test.stopTest();
    } 
    
    // Code to initialize controller
    public static AddressValidationComponentController initialize(AddressValidateRestResponse addressValidate1, ValidatedAddress validateAdd){
        AddressValidationComponentController addressValidComponent1 = new AddressValidationComponentController();
        addressValidComponent1.IsRefinementListRendered = true;
        addressValidComponent1.IsMultipleListRendered = true;
        addressValidComponent1.IsNoResultsRendered = true;
        addressValidComponent1.IsVerifiedAddressRendered = true;
        addressValidComponent1.IsDialogRendered = true;
        addressValidComponent1.IsValidVisible = true;
        addressValidComponent1.IsLine1Required = true;
        addressValidComponent1.IsLine2Required = true;
        addressValidComponent1.IsLine3Required = true;
        addressValidComponent1.IsCityRequired = true;
        addressValidComponent1.IsStateProvRequired = true;
        addressValidComponent1.IsCountryRequired = true;
        addressValidComponent1.IsPostalCodeRequired = true;
        addressValidComponent1.Address = validateAdd;
        addressValidComponent1.AddressId = '12345';
        addressValidComponent1.Refinement = 'refinement';
        addressValidComponent1.Response = addressValidate1;
        addressValidComponent1.IsAddressRequired = true;
        addressValidComponent1.IsValidateButtonVisible = true;
        return addressValidComponent1;
    }
    
    // Creating instance of AddressValidateRestResponse.field class
    public static AddressValidateRestResponse.field createFieldsRecord(String id, String label, String content){
        AddressValidateRestResponse.field addressValidateField = new AddressValidateRestResponse.field();
        addressValidateField.id=id;
        addressValidateField.label = label;
        addressValidateField.content = content;
        return addressValidateField;
    }
    
    // Creating instance of AddressValidateRestResponse.result class
    public static AddressValidateRestResponse.result createResultsRecord(String id, String text, String grouped, String url){
        AddressValidateRestResponse.result addressValidateResult1 = new AddressValidateRestResponse.result();
        addressValidateResult1.id=id;
        addressValidateResult1.text = text;
        addressValidateResult1.grouped = grouped;
        addressValidateResult1.url = url;
        return addressValidateResult1;
    }
   
   // Creating instance of AddressValidateRestResponse class
   public static AddressValidateRestResponse  createAddressValidateRestResponse(List<AddressValidateRestResponse.field> fieldList, List<AddressValidateRestResponse.result> resultList, integer count ,String prompt, String query, String verifyLevel){
        AddressValidateRestResponse restResp = new AddressValidateRestResponse();
        restResp.results = resultList;
        restResp.count = 0;
        restResp.fields = fieldList;
        restResp.query = '';
        restResp.prompt= '';
        restResp.verifyLevel = '';
        return restResp;
   }
   
   // Creating Test Data
    public static void setUpTestData() {
        
        Account acc = TestUtils.createAccount('Test Account',False);
        acc.RecordTypeId = ACC_HH_RT;
        insert acc;
        
        Contact contact = TestUtils.createContact(acc,'Test First Name','Test Last Name',False);
        insert contact; 
        
        //create the rC_Bios__Preferred_Mailing_Address__c test data 
        prefMailingAddTemp = new rC_Bios__Address__c();
        prefMailingAddTemp.rC_Bios__Street_Line_1__c = 'test Street 1';
        prefMailingAddTemp.rC_Bios__Street_Line_2__c = 'test Street 2';
        prefMailingAddTemp.rC_Bios__City__c = 'test City';
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        prefMailingAddTemp.rC_Bios__Postal_Code__c = '12311';
        prefMailingAddTemp.rC_Bios__Country__c = 'test country';
        insert prefMailingAddTemp;
        
        
        // Creating Account Address and Contact Address
        acctAddress = TestUtils.createAccountAddress(acc, prefMailingAddTemp, true);
        contAddress = TestUtils.createContactAddress(contact, prefMailingAddTemp, true);
        
        //Creating AddressValidateRestResponse.result record and adding it into a list 
        addressValidateResult = createResultsRecord('','','','');
        List<AddressValidateRestResponse.result> resultList = new List<AddressValidateRestResponse.result>();
        resultList.add(addressValidateResult);
        
        //Creating 6  AddressValidateRestResponse.field records and ading all of these into a list
        AddressValidateRestResponse.field addressValidateField;
        List<AddressValidateRestResponse.field> fieldList = new List<AddressValidateRestResponse.field>();
        for(integer i=0;i<6;i++){
             addressValidateField = createFieldsRecord('','','');
             fieldList.add(addressValidateField);
        }
        
        // Creating a record for AddressValidateRestResponse by sending fieldlist and resultList created above
        addressValidate = createAddressValidateRestResponse(fieldList, resultList, 0 , '', '', '');
        
        AddressValidateRestApi addressApi = new AddressValidateRestApi();
        
        // Creating Validated Address Record and initializing its fields
        validateAdd1 = new ValidatedAddress('line1','line2','line3','city','stateProv','100100','Country','111111',true, false);
        validateAdd1.IsChanged = true;
        validateAdd1.rcaddress = prefMailingAddTemp;
        validateAdd1.rcContactAddress = contAddress;
        validateAdd1.rcAccountAddress = acctAddress;
        
        // Creating and Initializing AddressValidationComponentController Record
        addressValidComponent = initialize(addressValidate, validateAdd1);
        
    } // END public static void setUpTestData() {
    
} // END public with sharing class AddressValidateResponseTest