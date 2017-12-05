/***********************************************************************************************************
 * Appirio, Inc
 * Name         : RefCodeInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Implements iComparable to sort CountriesRefCodes__c by Description
 * Created Date : 03/02/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/02/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class CountriesRefCodesSortWrapper implements Comparable
{
	public CountriesRefCodes__c CountriesRefCodes;
    
    public CountriesRefCodesSortWrapper(CountriesRefCodes__c countriesRefCodes)
    {
        this.CountriesRefCodes = countriesRefCodes;
    }
    
    //compares by the description
    //TODO: extend class to be configurable on field to sort by
	public integer compareTo(Object compareTo) 
    {
        CountriesRefCodesSortWrapper compareToRefCodes = (CountriesRefCodesSortWrapper)compareTo;
        
        integer returnValue = 0;
        if(CountriesRefCodes.Description__c > compareToRefCodes.CountriesRefCodes.Description__c)
            returnValue = 1;
        else if (CountriesRefCodes.Description__c < compareToRefCodes.CountriesRefCodes.Description__c)
            returnValue = -1;
        
        return returnValue;
    }
}