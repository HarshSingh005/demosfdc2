/***********************************************************************************************************
 * Appirio, Inc
 * Name         : WebSuffixRefCodesSortWrapper
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Implements iComparable to sort WebSuffixRefCodes__c by Description
 * Created Date : 05/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 05/04/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class WebSuffixRefCodesSortWrapper implements Comparable
{
	public WebSuffixRefCodes__c SuffixRefCodes;
    
    public WebSuffixRefCodesSortWrapper(WebSuffixRefCodes__c SuffixRefCodes)
    {
        this.SuffixRefCodes = SuffixRefCodes;
    }
    
    //compares by the description
    //TODO: extend class to be configurable on field to sort by
    public integer compareTo(Object compareTo) 
    {
        WebSuffixRefCodesSortWrapper compareToRefCodes = (WebSuffixRefCodesSortWrapper)compareTo;
        
        integer returnValue = 0;
        if(SuffixRefCodes.Description__c > compareToRefCodes.SuffixRefCodes.Description__c)
            returnValue = 1;
        else if (SuffixRefCodes.Description__c < compareToRefCodes.SuffixRefCodes.Description__c)
            returnValue = -1;
        
        return returnValue;
    }
}