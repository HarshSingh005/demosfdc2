/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressValidateResponseTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the AddressValidateResponse
 * Created Date : 10/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 10/04/2016                   Munib Ur Rehman       Created
 **********************************************************************************************************/
@isTest
public with sharing class AddressValidateResponseTest
{
    
	@isTest
	public static void testAddressValidateResponse() {
    	//setting up of all data 
        Test.startTest();
    	AddressValidateRestResponse.result addressValidateResult = new AddressValidateRestResponse.result();
        addressValidateResult.id = '';
        addressValidateResult.text= '';
        addressValidateResult.grouped='';
        addressValidateResult.url='';
        List<AddressValidateRestResponse.result> resultList = new List<AddressValidateRestResponse.result>();
        resultList.add(addressValidateResult);
        AddressValidateRestResponse.field addressValidateField = new AddressValidateRestResponse.field();
        addressValidateField.id='';
        addressValidateField.label = '';
        addressValidateField.content = '';
        List<AddressValidateRestResponse.field> fieldList = new List<AddressValidateRestResponse.field>();
        fieldList.add(addressValidateField);
    	AddressValidateRestResponse addressValidate = new AddressValidateRestResponse();
        addressValidate.results = resultList;
        addressValidate.count = 0;
        addressValidate.fields = fieldList;
        addressValidate.query = '';
        addressValidate.prompt= '';
        addressValidate.verifyLevel = '';
        System.assert(addressValidate.fields[0].label != null);
        test.stopTest();
    } 
   
} // END public with sharing class AddressValidateResponseTest