/*
 * Class        : ExchangeRateService
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Sep 25, 2013
 * Objective    : This class contains logic to calculate Exchange Rates 
*/
public with sharing class ExchangeRateService {
	
	//Enum that holds all the Objects that you can calculate Exchange Rate for
	public enum ExchangeRateSObjects {MatchGoals, Opportunity, Project, Solicitation, AccountRole}	
	
	/**
     * Get the Exchange Rate record for the specified currency and date range   
     * @parm Id currencyId, Date exchangeRateDate
     * @return Exchange_Rate__c
    */
	public static Exchange_Rate__c calculateExchangeRate(Id currencyId, Date exchangeRateDate){
		Exchange_Rate__c exchangeRate;
		try{
			//get exchange rate within date range
			exchangeRate = [SELECT Exchange_Rate__c, Start_Date__c FROM Exchange_Rate__c WHERE Currency__c =: currencyId AND Start_Date__c <=: exchangeRateDate 
								AND End_Date__c >=: exchangeRateDate 
								ORDER BY LastModifiedDate DESC LIMIT 1];
			//if an exchange rate is found within date range use the specified date range. If not use the Start date of the latest exchange rate
			exchangeRate.Start_Date__c = null;										
		}catch(QueryException qryEx){
			System.debug('Could not find an exchange rate within specified date range. ' + qryEx.getMessage());			
			try{
				//get latest exchange rate
				exchangeRate = [SELECT Exchange_Rate__c, Start_Date__c FROM Exchange_Rate__c WHERE Currency__c =: currencyId ORDER BY End_Date__c DESC LIMIT 1];
			}catch(QueryException qe){
				System.debug('Could not find an exchange rate. ' + qe.getMessage());
			}
		}
		return exchangeRate;
	}
	
	/**
     * Get the SObject and instantial Wrapper with default ExchangeRate info   
     * @parm String sObjName, Id objId
     * @return Wrapper.ExchangeRateWrapper
    */
	public static Wrapper.ExchangeRateWrapper getSObjAndDefaultExchangeRateInfo(String sObjName, Id objId){
		try{
			if(ExchangeRateService.ExchangeRateSObjects.MatchGoals.name() == sObjName){
				Match_Goals__c mg = [SELECT Id, Convert_From__c, Local_Currency__c, Exchange_Rate_Date__c FROM  Match_Goals__c WHERE Id =: objId];
				return new Wrapper.ExchangeRateWrapper(mg.Convert_From__c, mg.Local_Currency__c, mg.Exchange_Rate_Date__c, mg);
			}else if(ExchangeRateService.ExchangeRateSObjects.Opportunity.name() == sObjName){
				Opportunity opp = [SELECT Id, Convert_From__c, Local_Currency__c, Exchange_Rate_Date__c FROM  Opportunity WHERE Id =: objId];
				return new Wrapper.ExchangeRateWrapper(opp.Convert_From__c, opp.Local_Currency__c, opp.Exchange_Rate_Date__c, opp);
			}else if(ExchangeRateService.ExchangeRateSObjects.Project.name() == sObjName){
				Project__c proj = [SELECT Id, Convert_From__c, Local_Currency__c, Exchange_Rate_Date__c FROM  Project__c WHERE Id =: objId];
				return new Wrapper.ExchangeRateWrapper(proj.Convert_From__c, proj.Local_Currency__c, proj.Exchange_Rate_Date__c, proj);
			}else if(ExchangeRateService.ExchangeRateSObjects.Solicitation.name() == sObjName){
				Solicitation_RFP__c sRFP = [SELECT Id, Convert_From__c, Local_Currency__c, Exchange_Rate_Date__c FROM  Solicitation_RFP__c WHERE Id =: objId];
				return new Wrapper.ExchangeRateWrapper(sRFP.Convert_From__c, sRFP.Local_Currency__c, sRFP.Exchange_Rate_Date__c, sRFP);
			}else if(ExchangeRateService.ExchangeRateSObjects.AccountRole.name() == sObjName){
				Account_Roles__c accRole = [SELECT Id, Convert_From__c, Local_Currency__c, Exchange_Rate_Date__c FROM  Account_Roles__c WHERE Id =: objId];
				return new Wrapper.ExchangeRateWrapper(accRole.Convert_From__c, accRole.Local_Currency__c, accRole.Exchange_Rate_Date__c, accRole);
			} 
			
			//To implement exchange rate functionality for a new object, just Add another condition
		}catch(QueryException qe){
			System.debug('Error getting SObject. ' + qe.getMessage());
		}
		return null; 
	}
	
	/**
     * Update the SObject with ExchangeRate info   
     * @parm Sobject sObj, Exchange_Rate__c exchangeRate, Decimal exchangeRateFromTable, Date newestExchangeRateDate
     * @return Boolean
    */
	public static Boolean updateSObjectWithExchangeRate(Sobject sObj, Exchange_Rate__c exchangeRate, Decimal exchangeRateFromTable, Date newestExchangeRateDate){
		//Update SObject
		SObjectServices.setSObjectFieldValue(sObj, 'Convert_From__c', exchangeRate.Convert_From__c);
		SObjectServices.setSObjectFieldValue(sObj, 'Exchange_Rate__c', exchangeRateFromTable);
		//if newestExchangeRateDate is not null the exchange rate date will be the start date of the newest exchange rate		
		if(newestExchangeRateDate != null)
			SObjectServices.setSObjectFieldValue(sObj, 'Exchange_Rate_Date__c', newestExchangeRateDate);
		else//Use specified exchange rate date
			SObjectServices.setSObjectFieldValue(sObj, 'Exchange_Rate_Date__c', exchangeRate.Start_Date__c);	
		SObjectServices.setSObjectFieldValue(sObj, 'Local_Currency__c', exchangeRate.Currency__c);
		try{
			update sObj;
		}catch(DMLException dmlEx){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating the Exchange Rate. Please contact your System Administrator.'));
			System.debug('Error updating Exchange Rate for SObject. ' + dmlEx.getMessage());
			return false;
		}
		return true;
	}	
}