/*
 * Class        : FundingService
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Dec 11, 2013
 * Objective    : This class contains static methods for the Funding__c object
*/
public with sharing class FundingService {
	
	/**
     * Update the Funding amount on the parent project   
     * @parm List<Funding__c> fundings
     * @return 
    */
	public static void updateProjectWithFundingAmount(List<Funding__c> fundings){
		//Get the Projects tied to the Fundings
		Set<Id> projectIds = new Set<Id>();
		for(Funding__c funding : fundings){
			projectIds.add(funding.Project__c);
		}
		
		List<Project__c> projectsToUpdate = new List<Project__c>();
		//For each Parent project, calculate the rollup of all child funding amounts
		for(Project__c proj : [SELECT Project_Direct_Expenses__c, Project_Match_Expenses__c, Project_Direct_Expenses_NO_Currency__c, Project_Match_Expenses_NO_Currency__c,
										(SELECT Project_Direct_Expenses__c, Project_Match_Expenses__c, Opportunity_Name__r.ChildFund_Match__c,
											Project_Direct_Expenses_NO_Currency__c, Project_Match_Expenses_NO_Currency__c FROM Fundings__r) 
										FROM Project__c WHERE Id IN: projectIds]){
			Decimal projDirectExpenses = 0, projMatchExpenses = 0, projDirectExpensesNO = 0, projMatchExpensesNO = 0;
			//Calculate sum of all child funding amounts 
			for(Funding__c funding : proj.Fundings__r){
				if(funding.Project_Direct_Expenses__c != null){
					//For Childfund Matching Opps rollup the direct expense on funding to the match expense on Project
					if(funding.Opportunity_Name__r.ChildFund_Match__c)
						projMatchExpenses += funding.Project_Direct_Expenses__c;	
					else
						projDirectExpenses += funding.Project_Direct_Expenses__c;
				}
				if(funding.Project_Match_Expenses__c != null){
					projMatchExpenses += funding.Project_Match_Expenses__c;
				}
				if(funding.Project_Direct_Expenses_NO_Currency__c != null){
					//For Childfund Matching Opps rollup the direct expense on funding to the match expense on Project
					if(funding.Opportunity_Name__r.ChildFund_Match__c)
						projMatchExpensesNO += funding.Project_Direct_Expenses_NO_Currency__c;	
					else
						projDirectExpensesNO += funding.Project_Direct_Expenses_NO_Currency__c;
				}
				if(funding.Project_Match_Expenses_NO_Currency__c != null){
					projMatchExpensesNO += funding.Project_Match_Expenses_NO_Currency__c;
				}
			}
			
			proj.Project_Direct_Expenses__c = projDirectExpenses;
			proj.Project_Match_Expenses__c = projMatchExpenses;
			proj.Project_Direct_Expenses_NO_Currency__c = projDirectExpensesNO;
			proj.Project_Match_Expenses_NO_Currency__c = projMatchExpensesNO;
			projectsToUpdate.add(proj); 		
		}
		
		Database.SaveResult[] saveResult = Database.update (projectsToUpdate, false);
	}
	
}