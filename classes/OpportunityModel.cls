/*
 * Class        : OpportunityModel
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 9, 2013
 * Objective    : Model class for the Opportunity object. Any DML on Opp or SOQL to retrieve child objects should be done in this class. 
*/
public with sharing class OpportunityModel {
	
	//Properties
	public Opportunity opp{get; set;}
	
	//Constructor
	public  OpportunityModel(Opportunity opp){
		this.opp = opp;
	}
	
	/**
     * Save this Opportunity record 
     * @parm
     * @return
    */
	public void saveOpp(){
		try{
			insert opp;
		}catch(DMLException dmlEx){
			throw new ChildFundException.CustomDMLException('There was an error creating the Opportunity. ' + dmlEx.getMessage());
		}
	}	
}