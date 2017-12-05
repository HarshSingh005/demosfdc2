@isTest
private class TestOpportunityTrigger {
	
	static List<Opportunity> oppList;
	static Account acc;
		
	static void setup(Integer noOfOpp){
		acc = TestUtils.createAccount('Test Acc', true);
		rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('600',true);
    	oppList= new List<Opportunity>();
    	for(Integer i=0; i<noOfOpp; i++){
    		oppList.add(TestUtils.createOpportunity(acc, 'Test Opp ' + i, 100000, false));
    	}
    	insert oppList;
	}
	
	
    static testMethod void testSetExchangeRateForRelatedFundings() {
        setup(20);
        Project__c project = TestUtils.createProject('Test Proj', 'Australia', 'Available', true);
        Currency__c crncy = TestUtils.createCurrency('AUD', 'Australia', true);
        List<Funding__c> fundingList = new List<Funding__c>();
        for(Opportunity opp : oppList){
        	fundingList.add(TestUtils.createFunding(project.Id, opp.Id, null, false));
        	opp.Exchange_Rate__c = 1.4;
        	opp.Convert_From__c = 'USD --> Local Currency';
        	opp.Exchange_Rate_Date__c = Date.today();
        	opp.Local_Currency__c = crncy.Id;
        }
        insert fundingList;
        
        //update the Opp with exchange rate info
        update oppList;
        
        for(Funding__c funding : [SELECT Exchange_Rate__c,Convert_From__c, Exchange_Rate_Date__c, Local_Currency__c FROM Funding__c WHERE Id IN: fundingList]){
        	System.assertEquals(1.4, funding.Exchange_Rate__c);
        	System.assertEquals('USD --> Local Currency', funding.Convert_From__c);
        	System.assertEquals(Date.today(), funding.Exchange_Rate_Date__c);
        	System.assertEquals(crncy.Id, funding.Local_Currency__c);
        }
    }
    
    static testMethod void testDoNotUpdateExemptField(){
		setup(20);
		List<Opportunity> oppListReturned = [select Id , Approval_Path_Exempt__c from Opportunity where Id IN: oppList];
		system.assertEquals(false, oppListReturned[0].Approval_Path_Exempt__c);    	
    }
    
}