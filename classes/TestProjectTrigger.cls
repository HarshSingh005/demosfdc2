/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TestProjectTrigger
 * Purpose      : Test class for ProjectService class

 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/21/2017                  Suminder Singh(Appirio)  fixed for code coverage and errors
**********************************************************************************************************/
@isTest
private class TestProjectTrigger {
	static Account acc;
	static  Opportunity opp;
	
	private static void setup(){
		acc = TestUtils.createAccount('Test Acc', false);
        //Fixed for test class errors
		acc.RecordTypeId = SObjectServices.getRecordType('National_Office', 'Account').Id;
		acc.Office_Type__c = 'National';
        acc.National_Office_ID__c = '123';
		insert acc;
		opp = TestUtils.createOpportunity(acc, 'Test Opp', 100000, true);
	}
	
    static testMethod void testUpdateParentProjectWithFundingAmt() {
      	setup();
        Project__c parentProj = TestUtils.createProject('Test Parent Proj', 'Kenya', 'Available', false);
        parentProj.RecordTypeId = SObjectServices.getRecordType('Parent_Project', 'Project__c').Id;
        insert parentProj;
        
        //Create a child project that has been funded for $1000
        Project__c childProj1 = TestUtils.createProject('Test Child Proj 1', 'Kenya', 'Available', false);
        childProj1.Parent_Project__c = parentProj.Id;
        insert childProj1;
        Funding__c funding1 = TestUtils.createFunding(childProj1.Id, opp.Id, acc.Id, false);
        funding1.Funding_Approved_Donor_Amount__c = 1000;
        funding1.Project_Direct_Expenses__c = 300;
        funding1.Project_Match_Expenses__c = 200;
        insert funding1;
        
        System.assertEquals(1000, [SELECT Parent_Project_Funds_Raised_to_Date__c FROM Project__c WHERE Id =: parentProj.Id].Parent_Project_Funds_Raised_to_Date__c);
        System.assertEquals(500, [SELECT Parent_Project_Expenses__c FROM Project__c WHERE Id =: parentProj.Id].Parent_Project_Expenses__c);
        
        //Create an additional child project that has been funded for $800
        Project__c childProj2 = TestUtils.createProject('Test Child Proj 2', 'Kenya', 'Available', false);
        childProj2.Parent_Project__c = parentProj.Id;
        insert childProj2;
        Funding__c funding2 = TestUtils.createFunding(childProj2.Id, opp.Id, acc.Id, false);
        funding2.Funding_Approved_Donor_Amount__c = 800;
        insert funding2;
        
 		System.assertEquals(1800, [SELECT Parent_Project_Funds_Raised_to_Date__c FROM Project__c WHERE Id =: parentProj.Id].Parent_Project_Funds_Raised_to_Date__c);       
        
        funding1.Funding_Approved_Donor_Amount__c = 600;
        update funding1;
        
        System.assertEquals(1400, [SELECT Parent_Project_Funds_Raised_to_Date__c FROM Project__c WHERE Id =: parentProj.Id].Parent_Project_Funds_Raised_to_Date__c);
        
        delete childProj2;
        
        System.assertEquals(600, [SELECT Parent_Project_Funds_Raised_to_Date__c FROM Project__c WHERE Id =: parentProj.Id].Parent_Project_Funds_Raised_to_Date__c);
    }
    
    static testMethod void testUpdateParentProjectWithDirectAndMatchExpenses() {
    	
      	setup();
        Project__c parentProj = TestUtils.createProject('Test Parent Proj', 'Kenya', 'Available', false);
        parentProj.RecordTypeId = SObjectServices.getRecordType('Parent_Project', 'Project__c').Id;
        insert parentProj;
        
        //Create a child project that has been funded for $1000
        Project__c childProj1 = TestUtils.createProject('Test Child Proj 1', 'Kenya', 'Available', false);
        childProj1.Parent_Project__c = parentProj.Id;
        childProj1.Project_Direct_Expenses__c = 300;
        childProj1.Project_Match_Expenses__c = 200;
        insert childProj1;
       
        
        System.assertEquals(300, [SELECT Parent_Project_Direct_Expenses__c FROM Project__c WHERE Id =: parentProj.Id].Parent_Project_Direct_Expenses__c);
        System.assertEquals(200, [SELECT Parent_Project_Match_Expenses__c FROM Project__c WHERE Id =: parentProj.Id].Parent_Project_Match_Expenses__c);
        
        //Create an additional child project that has been funded for $800
        Project__c childProj2 = TestUtils.createProject('Test Child Proj 2', 'Kenya', 'Available', false);
        childProj2.Parent_Project__c = parentProj.Id;
        childProj2.Project_Direct_Expenses__c = 400;
        childProj2.Project_Match_Expenses__c = 300;
        test.starttest();
        insert childProj2;
        test.stoptest();
        
 		System.assertEquals(700, [SELECT Parent_Project_Direct_Expenses__c FROM Project__c WHERE Id =: parentProj.Id].Parent_Project_Direct_Expenses__c);
        System.assertEquals(500, [SELECT Parent_Project_Match_Expenses__c FROM Project__c WHERE Id =: parentProj.Id].Parent_Project_Match_Expenses__c);
        
        
        delete childProj2;
        
    }
    
}