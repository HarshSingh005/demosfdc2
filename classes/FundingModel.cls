/*
 * Class        : FundingModel
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 9, 2013
 * Objective    : Model class for the Funding__c object. Any DML on Funding or SOQL queries to retrieve child objects should be done in this class. 
*/
public with sharing class FundingModel {
	
	//Properties
	public Funding__c funding{get;set;}
	
	//Constructor
	public FundingModel(Funding__c funding){
		this.funding = funding;
	}
	
	/**
     * Save this Funding record with the specified Opportunity and Project 
     * @parm Opportunity opp, Project__c project
     * @return
    */
	public void saveFunding(Opportunity opp, Project__c project){
		funding.Project__c = project.Id;
		funding.Opportunity_Name__c = opp.Id;
		saveFunding();
	}
	
	/**
     * Save this Funding record 
     * @parm
     * @return
    */
	public void saveFunding(){
		try{
			insert funding;
		}catch(DMLException dmlEx){
			throw new ChildFundException.CustomDMLException('There was an error creating the Funding. ' + dmlEx.getMessage());
		}		
	}	
}