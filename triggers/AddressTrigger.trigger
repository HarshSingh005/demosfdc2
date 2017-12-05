/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressTrigger
 * Created By   : Karl Houseknecht
 * Purpose      : Trigger on Address object
 * Created Date : 01/20/2017
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/20/2017                   Karl Houseknecht        Add support for writing Country name to the Address object before insert/update
 **********************************************************************************************************/
trigger AddressTrigger on rC_Bios__Address__c (before insert, before update) 
{
	if(TriggerState.isActive('AddressTrigger'))
	{
		if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate))
		{
			AddressTriggerHandler.UpdateCountryName(trigger.new);
		}
	}
}