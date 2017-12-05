/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ProjectServiceTest
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class for the ProjectService
 * Created Date : July 29, 2016
 * Modified By                   Modified On                      Description
 * Ashu Gupta                   Aug 01, 2016                      Increased code coverage
 **********************************************************************************************************/

@isTest
private class ProjectServiceTest {
    
    static Project__c parentProj, childProj1, childProj2;
    static Funding__c fundingObj, fundingObj2 ;
    static Opportunity opp;
    static Account national_Office_Acc;
    
	private static testMethod void testUpdateParentProjectWithFundingAmount() {
	    createTestData();
	    Decimal fundsRaisedToDate = 0, fundsRaisedToDateLC = 0, projExpenses = 0, projExpensesLC = 0;
	    
	    Project__c pr = [SELECT id,name,Total_Funds_Awarded_Raised_to_Date__c,Project_Total_Expenses__c,Project_Direct_Expenses__c,
	                    Project_Total_Expenses_NO_Currency__c,Total_Funds_Awarded_Raised_to_Date_LC__c,Parent_Project__c 
	                    FROM Project__c 
	                    WHERE id =:childProj1.id];
	                   
	    Project__c pr2 = [SELECT id,name,Total_Funds_Awarded_Raised_to_Date__c,Project_Total_Expenses__c,Project_Direct_Expenses__c,
	                    Project_Total_Expenses_NO_Currency__c,Total_Funds_Awarded_Raised_to_Date_LC__c,Parent_Project__c 
	                    FROM Project__c 
	                    WHERE id =:childProj2.id];
	   fundsRaisedToDate =  pr.Total_Funds_Awarded_Raised_to_Date__c + pr2.Total_Funds_Awarded_Raised_to_Date__c;           
	   fundsRaisedToDateLC = pr.Total_Funds_Awarded_Raised_to_Date_LC__c + pr2.Total_Funds_Awarded_Raised_to_Date_LC__c;
	   projExpenses = pr.Project_Total_Expenses__c + pr2.Project_Total_Expenses__c;
	   projExpensesLC = pr.Project_Total_Expenses_NO_Currency__c + pr2.Project_Total_Expenses_NO_Currency__c;
	   
	    Project__c parentPr = [SELECT id,name,Parent_Project_Funds_Raised_to_Date__c,Parent_Project_Funds_Raised_to_Date_LC__c,Parent_Project_Expenses__c,Parent_Project_Expenses_LC__c 
	                            FROM Project__c
	                            WHERE id =:parentProj.id];
	    List<Project__c> listOfProjects = new List<Project__c>();
	    listOfProjects.add(pr);
	    listOfProjects.add(pr2);
	     System.debug(' In updateParentProjectWithFundingAmount : fundsRaisedToDate@@@ '+fundsRaisedToDate);
	     System.debug(' In updateParentProjectWithFundingAmount : fundsRaisedToDateLC@@@'+fundsRaisedToDateLC);
	     System.debug(' In updateParentProjectWithFundingAmount : projExpenses@@@'+projExpenses);
	     System.debug('In updateParentProjectWithFundingAmount : projExpensesLC@@@'+projExpensesLC);
	     
	    
	    ProjectService.updateParentProjectWithFundingAmount(listOfProjects);
	     System.debug(' In updateParentProjectWithFundingAmount : Parent  field@@@ Total_Funds_Awarded_Raised_to_Date__c'+parentPr.Parent_Project_Funds_Raised_to_Date__c);
	     System.debug(' In updateParentProjectWithFundingAmount : Parent  field Parent_Project_Funds_Raised_to_Date_LC__c@@@'+parentPr.Parent_Project_Funds_Raised_to_Date_LC__c);
	     System.debug(' In updateParentProjectWithFundingAmount : Parent  field Parent_Project_Expenses__c@@@'+parentPr.Parent_Project_Expenses__c);
	     System.debug('In updateParentProjectWithFundingAmount : Parent  field Parent_Project_Expenses_LC__c@@@'+parentPr.Parent_Project_Expenses_LC__c);
	     
	     System.assertEquals(fundsRaisedToDate, parentPr.Parent_Project_Funds_Raised_to_Date__c);
	     System.assertEquals(fundsRaisedToDateLC, parentPr.Parent_Project_Funds_Raised_to_Date_LC__c);
	     System.assertEquals(projExpenses, parentPr.Parent_Project_Expenses__c);
	     System.assertEquals(projExpensesLC, parentPr.Parent_Project_Expenses_LC__c);
	}
	private static testMethod void testUpdateParentProjectWithChildExpenses() {
	    createTestData();
	    Project__c pr1 = [SELECT id,name,Parent_Project__c,Project_Direct_Expenses__c, Project_Match_Expenses__c,
												Project_Direct_Expenses_FYTD__c, Project_Match_Expenses_FYTD__c, 
												Project_Match_Budget_FYTD__c, Project_Direct_Budget_FYTD__c
	                    FROM Project__c 
	                    WHERE id =:childProj1.id];
	    Project__c pr2 = [SELECT id,name,Parent_Project__c,Project_Direct_Expenses__c, Project_Match_Expenses__c,
												Project_Direct_Expenses_FYTD__c, Project_Match_Expenses_FYTD__c, 
												Project_Match_Budget_FYTD__c,Project_Direct_Budget_FYTD__c
	                    FROM Project__c 
	                    WHERE id =:childProj2.id];
	                    
	   Project__c parentPr = [SELECT id,name,Parent_Project_Direct_Expenses__c, Parent_Project_Match_Expenses__c,
											Parent_Project_Direct_Expenses_FYTD__c, Parent_Project_Match_Expenses_FYTD__c,
											Parent_Project_Match_Budget_FYTD__c, Parent_Project_Direct_Budget_FYTD__c 
	                            FROM Project__c
	                            WHERE id =:parentProj.id];             
	    Decimal childDirectExpenses = 0, childMatchExpenses = 0, childDirectExpensesFYTD = 0, childMatchExpensesFYTD = 0, childDirectBudgetFYTD = 0, childMatchBudgetFYTD = 0;                
	    Test.startTest();
	    
	    childDirectExpenses = pr1.Project_Direct_Expenses__c + pr2.Project_Direct_Expenses__c;
	    childMatchExpenses = pr1.Project_Match_Expenses__c + pr2.Project_Match_Expenses__c;
	    childDirectExpensesFYTD = pr1.Project_Direct_Expenses_FYTD__c + pr2.Project_Direct_Expenses_FYTD__c;
	    childMatchExpensesFYTD = pr1.Project_Match_Expenses_FYTD__c + pr2.Project_Match_Expenses_FYTD__c;
	    childDirectBudgetFYTD = pr1.Project_Direct_Budget_FYTD__c + pr2.Project_Direct_Budget_FYTD__c;
	    childMatchBudgetFYTD = pr1.Project_Match_Budget_FYTD__c + pr2.Project_Match_Budget_FYTD__c;
	    
	    List<Project__c> listOfProjects = new List<Project__c>();
	    listOfProjects.add(pr1);
	    listOfProjects.add(pr2);
	    
	    System.debug(' In testUpdateParentProjectWithChildExpenses : childDirectExpenses @@@'+childDirectExpenses);
	    System.debug(' In testUpdateParentProjectWithChildExpenses : childMatchExpenses@@@'+childMatchExpenses);
	    System.debug(' In testUpdateParentProjectWithChildExpenses : childDirectExpensesFYTD@@@'+childDirectExpensesFYTD);
	    System.debug(' In testUpdateParentProjectWithChildExpenses : childMatchExpensesFYTD@@@'+childMatchExpensesFYTD);
	    System.debug(' In testUpdateParentProjectWithChildExpenses : childDirectBudgetFYTD@@@'+childDirectBudgetFYTD);
	    System.debug(' In testUpdateParentProjectWithChildExpenses : childMatchBudgetFYTD@@@'+childMatchBudgetFYTD);
	    
	    ProjectService.updateParentProjectWithChildExpenses(listOfProjects);
	    
	     System.assertEquals(childDirectExpenses, parentPr.Parent_Project_Direct_Expenses__c);
	    System.assertEquals(childMatchExpenses, parentPr.Parent_Project_Match_Expenses__c);
	    System.assertEquals(childDirectExpensesFYTD, parentPr.Parent_Project_Direct_Expenses_FYTD__c);
	    System.assertEquals(childMatchExpensesFYTD, parentPr.Parent_Project_Match_Expenses_FYTD__c);
	    System.assertEquals(childMatchBudgetFYTD, parentPr.Parent_Project_Match_Budget_FYTD__c);
	    System.assertEquals(childDirectBudgetFYTD, parentPr.Parent_Project_Direct_Budget_FYTD__c);
	    Test.stopTest();
	    
	}
	
    static void createTestData(){
        String accNORTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
        parentProj = TestUtils.createProject('Test Parent Proj', 'Kenya', 'Available', false);
        parentProj.RecordTypeId = SObjectServices.getRecordType('Parent_Project', 'Project__c').Id;
        insert parentProj;
        
        //Create a child project 
        List<Project__c> listOfChildProj = new List<Project__c>();
        
        childProj1 = TestUtils.createProject('Test Child Proj 1', 'Kenya', 'Available', false);
        childProj1.Parent_Project__c = parentProj.Id;
        childProj1.Project_Direct_Expenses__c = 45;
        childProj1.Project_Match_Expenses__c = 10;
        childProj1.Project_Match_Expenses_NO_Currency__c = 20;
        childProj1.Project_Direct_Expenses_NO_Currency__c = 50;
        childProj1.Total_Funds_Awarded_Raised_to_Date_LC__c = 45;
        listOfChildProj.add(childProj1);
        
        childProj2 = TestUtils.createProject('Test Child Proj 2', 'Kenya', 'Available', false);
        childProj2.Parent_Project__c = parentProj.Id;
        childProj2.Project_Direct_Expenses__c = 20;
        childProj2.Project_Match_Expenses__c = 10;
        childProj2.Project_Match_Expenses_NO_Currency__c = 20;
        childProj2.Project_Direct_Expenses_NO_Currency__c = 50;
        childProj2.Total_Funds_Awarded_Raised_to_Date_LC__c = 45;
        
        listOfChildProj.add(childProj2);
        
        insert listOfChildProj;
        
       
       /* national_Office_Acc = TestUtils.createAccountWithRT('Test NO Account', accNORTId, null, '765', '9234', true);
        opp = TestUtils.createOpportunity(national_Office_Acc,'testOpp',100,true);
        
        fundingObj = TestUtils.createFunding(childProj1.id,opp.id,national_Office_Acc.id,false);
        fundingObj.Funding_Approved_Donor_Amount__c = 35;
        fundingObj.Project_Match_Budget_FYTD__c = 20;
        fundingObj.Project_Direct_Budget_FYTD__c = 10;
        fundingObj.Project_Match_Expenses_FYTD__c = 15;
        fundingObj.Project_Direct_Expenses_FYTD__c = 10;
        insert fundingObj;
        
        fundingObj2 = TestUtils.createFunding(childProj2.id,opp.id,national_Office_Acc.id,false);
        fundingObj2.Funding_Approved_Donor_Amount__c = 25;
        fundingObj2.Project_Match_Budget_FYTD__c = 10;
        fundingObj2.Project_Direct_Budget_FYTD__c = 20;
        fundingObj2.Project_Match_Expenses_FYTD__c = 10;
        fundingObj2.Project_Direct_Expenses_FYTD__c = 10;
        insert fundingObj2;*/
        
        
    }
}