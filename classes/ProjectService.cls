/*
 * Class        : ProjectService
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Oct 1, 2013
 * Updated 		: Jan 20, 2015
 * Updated By	: Dharani Pothula/Bluewolf
 * Objective    : This class contains static methods for the Project__c object
*/
public with sharing class ProjectService {
	
	/**
     * Update the Funding amount on the parent project   
     * Update the Direct Expense on the parent project
     * Update the Match Expension on the parent project
     * @parm List<Project__c> projects
     * @return 
    */
    
	public static void updateParentProjectWithFundingAmount(List<Project__c> projects){
		//Get the Parent Projects
		Set<Id> parentProjects = new Set<Id>();
		for(Project__c proj : projects){
			if(proj.Parent_Project__c != null){
				parentProjects.add(proj.Parent_Project__c);
			}	
		}
		//Stop Execution if there are no Parent Projects that need to be updated
		if(parentProjects.isEmpty())
			return;
			
		List<Project__c> projectsToUpdate = new List<Project__c>();
		//For each Parent project, calculate the rollup of all child funding amounts
		for(Project__c parentProj : [SELECT Parent_Project_Funds_Raised_to_Date__c, Parent_Project_Funds_Raised_to_Date_LC__c, Parent_Project_Expenses__c,
										Parent_Project_Expenses_LC__c,
										(SELECT Total_Funds_Awarded_Raised_to_Date__c, Total_Funds_Awarded_Raised_to_Date_LC__c, Project_Total_Expenses__c,
											Project_Total_Expenses_NO_Currency__c FROM Child_Projects__r) 
										FROM Project__c WHERE Id IN: parentProjects]){
			Decimal fundsRaisedToDate = 0, fundsRaisedToDateLC = 0, projExpenses = 0, projExpensesLC = 0;
			//Calculate sum of all child funding amounts 
			for(Project__c childProj : parentProj.Child_Projects__r){
				if(childProj.Total_Funds_Awarded_Raised_to_Date__c != null)
					fundsRaisedToDate += childProj.Total_Funds_Awarded_Raised_to_Date__c;
				if(childProj.Total_Funds_Awarded_Raised_to_Date_LC__c != null)
					fundsRaisedToDateLC += childProj.Total_Funds_Awarded_Raised_to_Date_LC__c; 
				if(childProj.Project_Total_Expenses__c != null)
					projExpenses += childProj.Project_Total_Expenses__c; 
				if(childProj.Project_Total_Expenses_NO_Currency__c != null)
					projExpensesLC += childProj.Project_Total_Expenses_NO_Currency__c; 
			}								
			parentProj.Parent_Project_Funds_Raised_to_Date__c = fundsRaisedToDate;
			parentProj.Parent_Project_Funds_Raised_to_Date_LC__c = fundsRaisedToDateLC;
			parentProj.Parent_Project_Expenses__c = projExpenses;
			parentProj.Parent_Project_Expenses_LC__c = projExpensesLC;
			projectsToUpdate.add(parentProj);
		}
		
		update projectsToUpdate;
	}
	
	public static void updateParentProjectWithChildExpenses(List<Project__c> projects){
		//Get the Parent Projects
		Set<Id> parentProjects = new Set<Id>();
		for(Project__c proj : projects){
			if(proj.Parent_Project__c != null){
				parentProjects.add(proj.Parent_Project__c);
			}	
		}
		//Stop Execution if there are no Parent Projects that need to be updated
		if(parentProjects.isEmpty())
			return;
			
		List<Project__c> projectsToUpdate = new List<Project__c>();
		//For each Parent project, calculate the rollup of all child funding amounts
		for(Project__c parentProj : [SELECT Parent_Project_Direct_Expenses__c, Parent_Project_Match_Expenses__c,
											Parent_Project_Direct_Expenses_FYTD__c, Parent_Project_Match_Expenses_FYTD__c,
											Parent_Project_Match_Budget_FYTD__c, Parent_Project_Direct_Budget_FYTD__c,
										(SELECT Project_Direct_Expenses__c, Project_Match_Expenses__c,
												Project_Direct_Expenses_FYTD__c, Project_Match_Expenses_FYTD__c, 
												Project_Match_Budget_FYTD__c, Project_Direct_Budget_FYTD__c FROM Child_Projects__r) 
										FROM Project__c WHERE Id IN: parentProjects]){
			Decimal childDirectExpenses = 0, childMatchExpenses = 0, childDirectExpensesFYTD = 0, childMatchExpensesFYTD = 0, childDirectBudgetFYTD = 0, childMatchBudgetFYTD = 0;
			//Calculate sum of all child funding amounts 
			for(Project__c childProj : parentProj.Child_Projects__r){
				if(childProj.Project_Direct_Expenses__c != null)
					childDirectExpenses += childProj.Project_Direct_Expenses__c; 
				if(childProj.Project_Match_Expenses__c != null)
					childMatchExpenses += childProj.Project_Match_Expenses__c; 
				if(childProj.Project_Direct_Expenses_FYTD__c != null)
					childDirectExpensesFYTD += childProj.Project_Direct_Expenses_FYTD__c; 
				if(childProj.Project_Match_Expenses_FYTD__c != null)
					childMatchExpensesFYTD += childProj.Project_Match_Expenses_FYTD__c; 
				if(childProj.Project_Match_Budget_FYTD__c != null)
					childDirectBudgetFYTD += childProj.Project_Direct_Budget_FYTD__c;
				if(childProj.Project_Direct_Budget_FYTD__c != null)
					childMatchBudgetFYTD += childProj.Project_Match_Budget_FYTD__c;
			}
									
			parentProj.Parent_Project_Direct_Expenses__c = childDirectExpenses;
			parentProj.Parent_Project_Match_Expenses__c = childMatchExpenses;
			parentProj.Parent_Project_Direct_Expenses_FYTD__c = childDirectExpensesFYTD;
			parentProj.Parent_Project_Match_Expenses_FYTD__c = childMatchExpensesFYTD;
			parentProj.Parent_Project_Match_Budget_FYTD__c = childMatchBudgetFYTD;
			parentProj.Parent_Project_Direct_Budget_FYTD__c = childDirectBudgetFYTD;
			projectsToUpdate.add(parentProj);
		}
		
		update projectsToUpdate;
	}
	
}