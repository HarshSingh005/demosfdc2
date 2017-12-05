/***********************************************************************************************************
 * Appirio, Inc
 * Name         : WebTitlesRefCodesSortWrapper
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Implements iComparable to sort WebTitlesRefCodes__c by Description
 * Created Date : 05/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 05/04/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class WebTitlesRefCodesSortWrapper implements Comparable
{
    public WebTitlesRefCodes__c TitlesRefCodes;
    
    public WebTitlesRefCodesSortWrapper(WebTitlesRefCodes__c TitlesRefCodes)
    {
        this.TitlesRefCodes = TitlesRefCodes;
    }
    
    //compares by the description
    //TODO: extend class to be configurable on field to sort by
    public integer compareTo(Object compareTo) 
    {
        WebTitlesRefCodesSortWrapper compareToRefCodes = (WebTitlesRefCodesSortWrapper)compareTo;
        
        integer returnValue = 0;
        if(TitlesRefCodes.Description__c > compareToRefCodes.TitlesRefCodes.Description__c)
            returnValue = 1;
        else if (TitlesRefCodes.Description__c < compareToRefCodes.TitlesRefCodes.Description__c)
            returnValue = -1;
        
        return returnValue;
    }
}