/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressTriggerHandler
 * Created By   : Karl Houseknecht
 * Purpose      : Trigger Handler for trigger on Address object
 * Created Date : 01/20/2017
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/20/2017                   Karl Houseknecht        Add support for writing Country name to the Address object before insert/update
 **********************************************************************************************************/
public class AddressTriggerHandler 
{
	//update the Country Name field based on the 3 character ISO country code
	//in the Country field
	public static void UpdateCountryName(List<rC_Bios__Address__c> addresses)
	{
		List<CountriesRefCodes__c> codes = CountriesRefCodes__c.getAll().values();
		Map<string,CountriesRefCodes__c> codesMap = new Map<string,CountriesRefCodes__c>();

		for(CountriesRefCodes__c code : codes)
			codesMap.put(code.Code__c, code);

		for(rC_Bios__Address__c address : addresses)
		{
			if(address.rC_Bios__Country__c != null)
			{
				CountriesRefCodes__c code = codesMap.get(address.rC_Bios__Country__c);
				if(code != null)
					address.rC_Bios__Country_Name__c = code.Description__c;
			}
			
		}
	}
}