/***********************************************************************************************************
 * Appirio, Inc
 * Name         : StateTerrProvRefCodesSortWrapper
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Implements iComparable to sort StateTerrProvRefCodes__c by Description
 * Created Date : 03/02/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/02/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class StateTerrProvRefCodesSortWrapper implements Comparable
{
	public StateTerrProvRefCodes__c StateRefCodes;
    
    public StateTerrProvRefCodesSortWrapper(StateTerrProvRefCodes__c stateRefCodes)
    {
        this.StateRefCodes = stateRefCodes;
    }
    
    //compares by the description
    //TODO: extend class to be configurable on field to sort by
	public integer compareTo(Object compareTo) 
    {
        StateTerrProvRefCodesSortWrapper compareToRefCodes = (StateTerrProvRefCodesSortWrapper)compareTo;
        
        integer returnValue = 0;
        if(StateRefCodes.Description__c > compareToRefCodes.StateRefCodes.Description__c)
            returnValue = 1;
        else if (StateRefCodes.Description__c < compareToRefCodes.StateRefCodes.Description__c)
            returnValue = -1;
        
        return returnValue;
    }
}