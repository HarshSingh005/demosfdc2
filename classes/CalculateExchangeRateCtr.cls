/*
 * Class        : CalculateExchangeRateCtr
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Sep 17, 2013
 * Objective    : Controller to calculate exchange rates for various objects. Invoked from detail button.
 				To Implement this functionality for an object:
 				1. Add the SObject Name passed in the URL to the ExchangeRateSObjects enum in ExchangeRateService
 				2. Add an if condiion to the getSObjAndDefaultExchangeRateInfo method in ExchangeRateService
*/
public with sharing class CalculateExchangeRateCtr {
	
	//Properties
	private String sObjName;
	private String objId;
	public Boolean isError{get;private set;}
	
	private Wrapper.ExchangeRateWrapper exchangeRateWrapper;
	
	//Default the Exchange Rate fields from the SObject in Context
	public Exchange_Rate__c exchangeRate{
		get{
			if(exchangeRate == null && exchangeRateWrapper != null){
				exchangeRate = new Exchange_Rate__c(Convert_From__c = exchangeRateWrapper.convertFrom, Start_Date__c = exchangeRateWrapper.exchangeRateDate, 
														Currency__c = exchangeRateWrapper.localCurrency);
			}
			return exchangeRate; 	
		}
		set;
	}
	
	//Constructor
	public CalculateExchangeRateCtr(){
		//Get the SObject Name and id from the URL
		sObjName = ApexPages.currentPage().getParameters().get('sObjName');
		objId = ApexPages.currentPage().getParameters().get('id');
		//If either one of the parameters is missing, stop execution and display error 
		if(String.isBlank(sObjName) || String.isBlank(objId)){
			isError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page was invoked incorrectly. Please contact your System Administrator'));
			return;
		}
		//get the concrete SObject instance based on the URL param
		exchangeRateWrapper = ExchangeRateService.getSObjAndDefaultExchangeRateInfo(sObjName, objId);
		//If sObj is null, exchange rate is not implemented for the specified SObject
		if(exchangeRateWrapper == null || exchangeRateWrapper.sObj == null){
			isError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot Calculate Exchange Rate for this Object. Please contact your System Administrator'));
		}
	}
	
	/**
     * Redirect to SObjects detail page   
     * @parm 
     * @return PageReference
    */
	public PageReference cancel(){
		if(exchangeRateWrapper != null && exchangeRateWrapper.sObj != null)
			return new Apexpages.Standardcontroller(exchangeRateWrapper.sObj).view();
		else
			return null;	
	}
	
	/**
     * Calculate the Exchange rate and update the SObject   
     * @parm 
     * @return PageReference
    */
	public PageReference calculateExchangeRate(){
		//Validate all fields are populated
		if(String.isBlank(exchangeRate.Convert_From__c) || exchangeRate.Currency__c == null || exchangeRate.Start_Date__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all the fields'));
			return null;
		}
		
		//Get the Exchange Rate
		Exchange_Rate__c exchangeRateFromTable = ExchangeRateService.calculateExchangeRate(exchangeRate.Currency__c, exchangeRate.Start_Date__c);
		
		//Could not find Excahnge Rate
		if(exchangeRateFromTable == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not find Exchange Rate for the provided information.'));
			return null;	
		}
		//If update is successfull return to detail page of originating object
		if(ExchangeRateService.updateSObjectWithExchangeRate(exchangeRateWrapper.sObj, exchangeRate, exchangeRateFromTable.Exchange_Rate__c, exchangeRateFromTable.Start_Date__c))
			return new Apexpages.Standardcontroller(exchangeRateWrapper.sObj).view();	
		else//throw error
			return null;
	}
	
}