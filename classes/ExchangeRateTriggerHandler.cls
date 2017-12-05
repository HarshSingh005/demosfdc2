/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ExchangeRateTriggerHandler
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Trigger to validate that exchange rate start and end dates do not overlap for a given currency
 * Created Date : 01/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/26/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class ExchangeRateTriggerHandler 
{
    public void OnBeforeInsert(List<Exchange_Rate__c> newRates)
    {
        this.validateRateDates(newRates);
    }
    
    public void OnBeforeUpdate(List<Exchange_Rate__c> newRates, Map<Id, Exchange_Rate__c> ratesOldMap)
    {
        this.validateRateDates(newRates);
    }
    
    //validate that exchange rate start and end dates do not overlap for a given currency
    private void validateRateDates(List<Exchange_Rate__c> newRates)
    {
        //find the min and max dates in the rates
        List<date> startDates = new List<date>();
        List<date> endDates = new List<date>();
        Set<id> currencyIds = new Set<id>();
        
        for(Exchange_Rate__c rate : newRates)
        {
            startDates.add(rate.Start_Date__c);
            endDates.add(rate.End_Date__c);
            currencyIds.add(rate.Currency__c);
        }
        
        startDates.sort();
        endDates.sort();
        
        date startDate = startDates.get(0);
        date endDate = endDates.get(endDates.size() -1);
        
        //query for all existing rates between the min start date and max end date for the currencies included
        List<Exchange_Rate__c> existingRates = [select id,
                                       name,
                                       start_date__c,
                                       end_date__c,
                                       currency__c
                                       from Exchange_Rate__c
                                       where 
                                       //start_date__c >= :startDate and
                                       //end_date__c <= :endDate and
                                       currency__c in :currencyIds];
        
        //map holds the rates that have errors and list of records they overlap with
        Map<Exchange_Rate__c, List<Exchange_Rate__c>> errorMap = 
            new Map<Exchange_Rate__c, List<Exchange_Rate__c>>();
        
        //iterate through newRates to see if a rate exists for the same currency 
        //and has overlapping start and/or end dates
        for(Exchange_Rate__c newRate : newRates)
        {
            for(Exchange_Rate__c existingRate : existingRates)
            {
                if((newRate.Currency__c == existingRate.Currency__c) && (newRate.Id != existingRate.Id))
                {
                    //start date between
                    if(newRate.Start_Date__c >= existingRate.Start_Date__c &&
                       newRate.Start_Date__c <= existingRate.End_Date__c)
                    {
                        this.addRateToErrorMap(errorMap, newRate, existingRate);
                    }
                    else if(newRate.End_Date__c >= existingRate.Start_Date__c &&
                       newRate.End_Date__c <= existingRate.End_Date__c)
                    {
                        //end date overlaps
                        this.addRateToErrorMap(errorMap, newRate, existingRate);
                    }
                    else if(newRate.Start_Date__c <= existingRate.Start_Date__c &&
                            newRate.End_Date__c >= existingRate.End_Date__c)
                    {
                        //start date before, end date after
                        this.addRateToErrorMap(errorMap, newRate, existingRate);
                    }
                    
                }
            }
        }
        
        //if errors are found, add a message to the record containing the details of overlapping records
        if(!errorMap.isEmpty())
        {
            for(Exchange_Rate__c errorRate : errorMap.keySet())
            {
                List<Exchange_Rate__c> overlapping = errorMap.get(errorRate);
                
                string message = 'Date range overlaps with:<br/>';
                for(Exchange_Rate__c overlap : overlapping)
                {
                    message += '<a href="/' + overlap.Id + '">' + overlap.Name + '</a>&nbsp;' + string.valueOf(overlap.Start_Date__c) + ' - ' + string.valueOf(overlap.End_Date__c) + '<br/>';
                    overlap.Start_Date__c.addError(message);
                }
                
                errorRate.Name.addError(message,false);
            }
        }
    }
    
    //adds the error information for overlapping exchange rates to the error map
    private void addRateToErrorMap(Map<Exchange_Rate__c, List<Exchange_Rate__c>> errorMap, Exchange_Rate__c key, Exchange_Rate__c existing)
    {
        if(errorMap.containsKey(key))
        {
            List<Exchange_Rate__c> existingList = errorMap.get(key);
            existingList.add(existing);
        }
        else
        {
            List<Exchange_Rate__c> existingList = new List<Exchange_Rate__c>();
            existingList.add(existing);
            errorMap.put(key, existingList);
        }
    }
}