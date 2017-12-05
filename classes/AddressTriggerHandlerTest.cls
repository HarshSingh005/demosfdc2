/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressTriggerHandlerTest
 * Created By   : Karl Houseknecht
 * Purpose      : Trigger Handler test class for trigger on Address object
 * Created Date : 01/20/2017
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/20/2017                   Karl Houseknecht        Add support for writing Country name to the Address object before insert/update
 **********************************************************************************************************/
@isTest()
public with sharing class AddressTriggerHandlerTest 
{
	public static testmethod void UpdateCountryNameTest()
	{
		CountriesRefCodes__c code = new CountriesRefCodes__c();
		code.name = '1';
		code.Code__c = 'USA';
		code.Description__c = 'USA';
		insert code;


		rC_Bios__Address__c address = new rC_Bios__Address__c();
		address.rC_Bios__Country__c = 'USA';
		insert address;

		address = [select id, rC_Bios__Country__c, rC_Bios__Country_Name__c from rC_Bios__Address__c where id = :address.id limit 1];

		system.assertEquals(code.Description__c, address.rC_Bios__Country_Name__c, 'Country name should equal the custom setting description');

	}
}