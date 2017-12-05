/***********************************************************************************************************
 * Appirio, Inc
 * Name         : FundingModelTest 
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class of FundingModel class
 * Created Date : Aug 09, 2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
@isTest
private class FundingModelTest {
    static Project__c proj;
    static final string RT_ACC_NAOFF = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    static Account national_Office_Acc;
    static Opportunity opp;
    
	private static testMethod void test_saveFunding() {
        	createTestData();
            Test.startTest();
            FundingModel FundingModelObj = new FundingModel(new Funding__c());
            FundingModelObj.saveFunding(opp,proj);
            
            //list of inserted funding after saveFunding method is called
            List<Funding__c> listOfFund = [SELECT id,Project__c,Opportunity_Name__c FROM Funding__c];
            System.assertEquals(listOfFund.size(),1);
            //to check the opportunity name of newly inserted funding obj
            System.assertEquals(listOfFund[0].Opportunity_Name__c,opp.id);
            //to check the project of newly inserted funding obj
            System.assertEquals(listOfFund[0].Project__c,proj.id);
            Test.stopTest();
            
	}
	
	private static testMethod void test_saveFundingEx() {
        	//createTestData();
            Test.startTest();
            
            FundingModel FundingModelObj = new FundingModel(new Funding__c());
            
    		try{
    		FundingModelObj.saveFunding();}
    		catch(Exception e){
    		    System.debug('Exception @@@'+e);
    		    System.assert(e.getMessage().contains('There was an error creating the Funding.'));
    		}
    		
            Test.stopTest();
            
	}
	static void createTestData(){
	    
	    national_Office_Acc = TestUtils.createAccountWithRT('Test NO Account', RT_ACC_NAOFF, null, '765', '9234', true);
	    
	    proj = TestUtils.createProject('testProject','Afghanistan','Available',true);
	    
	     rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('600',true);
	     opp = TestUtils.createOpportunity(national_Office_Acc,'testOpp',100,true);
	}

}