/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TestFundingTrigger
 * Purpose      : Test class for FundingService class

 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/21/2017                  Suminder Singh(Appirio)  fixed for code coverage and errors
**********************************************************************************************************/
@isTest
private class TestFundingTrigger {
    
    static Account acc;
    static Opportunity opp;
    
    private static void setup(){
        acc = TestUtils.createAccount('Test Acc', false);
        //Fixed for test class errors
        acc.RecordTypeId = SObjectServices.getRecordType('National_Office', 'Account').Id;
        acc.Office_Type__c = 'National';
        acc.National_Office_ID__c = '123';
		insert acc;
        opp = TestUtils.createOpportunity(acc, 'Test Opp', 100000, true);
    }
    
    static testMethod void testRollupFundingAmount() {
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
        
        //Create an additional Funding for $800
        Funding__c funding2 = TestUtils.createFunding(childProj1.Id, opp.Id, acc.Id, false);
        funding2.Funding_Approved_Donor_Amount__c = 1000;
        funding2.Project_Direct_Expenses__c = 500;
        funding2.Project_Match_Expenses__c = 300;
        insert funding2;
        
        System.assertEquals(800, [SELECT Project_Direct_Expenses__c FROM Project__c WHERE Id =: childProj1.Id].Project_Direct_Expenses__c);
        System.assertEquals(500, [SELECT Project_Match_Expenses__c FROM Project__c WHERE Id =: childProj1.Id].Project_Match_Expenses__c);
        
        //update funding direct expense amount
        funding2.Project_Direct_Expenses__c = 1200;
        update funding2;
        System.assertEquals(1500, [SELECT Project_Direct_Expenses__c FROM Project__c WHERE Id =: childProj1.Id].Project_Direct_Expenses__c);
        
        //delete second funding
        delete funding2;
        System.assertEquals(300, [SELECT Project_Direct_Expenses__c FROM Project__c WHERE Id =: childProj1.Id].Project_Direct_Expenses__c);
    }
    
    static testMethod void testRollupFundingAmountForMatchingOpp() { 
        setup();
        Opportunity parentOpp = TestUtils.createOpportunity(acc, 'Test Parent Opp', 100000, true);
        opp.ChildFund_Match__c = true;
        opp.rC_Giving__Parent__c = parentOpp.Id;
        update opp;
        
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
        funding1.Project_Direct_Expenses_NO_Currency__c = 600;
        funding1.Project_Match_Expenses_NO_Currency__c = 1000;
        insert funding1;
        
        System.assertEquals(0, [SELECT Project_Direct_Expenses__c FROM Project__c WHERE Id =: childProj1.Id].Project_Direct_Expenses__c);
        System.assertEquals(500, [SELECT Project_Match_Expenses__c FROM Project__c WHERE Id =: childProj1.Id].Project_Match_Expenses__c);       
        System.assertEquals(0, [SELECT Project_Direct_Expenses_NO_Currency__c FROM Project__c WHERE Id =: childProj1.Id].Project_Direct_Expenses_NO_Currency__c);
        System.assertEquals(1600, [SELECT Project_Match_Expenses_NO_Currency__c FROM Project__c WHERE Id =: childProj1.Id].Project_Match_Expenses_NO_Currency__c);
    }    
    
}