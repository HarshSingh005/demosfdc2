@isTest
private class TestCalculateExchangeRateCtr {
	
	static Account acc;
	static Opportunity opp;
	static Currency__c crncy;
	static Exchange_Rate__c exchangeRate;
	
	static void setup(String currencyCode, String country, Decimal rate, Date startDate, Date endDate){
		acc = TestUtils.createAccount('Test Acc', true);
    	opp = TestUtils.createOpportunity(acc, 'Test Opp', 100000, true);
    	crncy = TestUtils.createCurrency(currencyCode, country, true);
    	exchangeRate = TestUtils.createExchangeRate(crncy.Id, rate, startDate, endDate, true);
	}
	
    static testMethod void testExchangeRateForInvalidObject() {
    	setup('DKK', 'Denmark', 0.17, null, null);
    	ApexPages.currentPage().getParameters().put('sObjName', 'Account');
		ApexPages.currentPage().getParameters().put('id', acc.Id);
		CalculateExchangeRateCtr ctr = new CalculateExchangeRateCtr();
		System.assertEquals(true, ctr.isError);
		//Ensure there is an error message added to the page
        System.assertEquals(true, !ApexPages.getMessages().isEmpty());
    }
    
    static testMethod void testExchangeRateWithInvalidParams() {
    	ApexPages.currentPage().getParameters().put('sObjName', null);
		ApexPages.currentPage().getParameters().put('id', '');
		CalculateExchangeRateCtr ctr = new CalculateExchangeRateCtr();
		System.assertEquals(true, ctr.isError);
		//Ensure there is an error message added to the page
        System.assertEquals(true, !ApexPages.getMessages().isEmpty());
    }
    
    static testMethod void testExchangeRateForOpportunity() {
    	setup('AUD', 'Australia', 1.1, Date.today().addDays(-10), Date.today().addDays(20));
    	
    	ApexPages.currentPage().getParameters().put('sObjName', ExchangeRateService.ExchangeRateSObjects.Opportunity.name());
		ApexPages.currentPage().getParameters().put('id', opp.Id);
		CalculateExchangeRateCtr ctr = new CalculateExchangeRateCtr();
		ctr.calculateExchangeRate();
		System.assertEquals(true, !ApexPages.getMessages().isEmpty());
		
		ctr.exchangeRate.Convert_From__c = 'USD --> Local Currency';
		ctr.exchangeRate.Currency__c = crncy.Id;
		ctr.exchangeRate.Start_Date__c = Date.today();
		System.assertNotEquals(true, ctr.isError);
		ctr.calculateExchangeRate();
        System.assertEquals(1.1, [SELECT Exchange_Rate__c FROM Opportunity WHERE Id =: opp.Id].Exchange_Rate__c);
        
        ctr.exchangeRate.Start_Date__c = Date.today().addDays(40);
        ctr.calculateExchangeRate();
        System.assertEquals(1.1, [SELECT Exchange_Rate__c FROM Opportunity WHERE Id =: opp.Id].Exchange_Rate__c);
        
        delete exchangeRate;
        ctr.calculateExchangeRate();
 		System.assertEquals(true, !ApexPages.getMessages().isEmpty());       
        
        Pagereference pRef = new Apexpages.Standardcontroller(opp).view();
        System.assertEquals(pRef.getURL(), ctr.cancel().getURL());
    }
    
    static testMethod void testExchangeRateForMatchGoals() {
    	setup('INR', 'India', 63.4, Date.today().addDays(-10), Date.today().addDays(20));
    	Match_Goals__c matchGoals = new Match_Goals__c(bw_match_Opportunity_Name__c = opp.Id);
    	insert matchGoals;
    	ApexPages.currentPage().getParameters().put('sObjName', ExchangeRateService.ExchangeRateSObjects.MatchGoals.name());
		ApexPages.currentPage().getParameters().put('id', matchGoals.Id);
		CalculateExchangeRateCtr ctr = new CalculateExchangeRateCtr();
		
		ctr.exchangeRate.Convert_From__c = 'USD --> Local Currency';
		ctr.exchangeRate.Currency__c = crncy.Id;
		ctr.exchangeRate.Start_Date__c = Date.today();
		
		ctr.calculateExchangeRate();
        System.assertEquals(63.4, [SELECT Exchange_Rate__c FROM Match_Goals__c WHERE Id =: matchGoals.Id].Exchange_Rate__c);
    }
    
    static testMethod void testExchangeRateForProject() {
    	setup('KES', 'Kenya', 87.4, Date.today().addDays(-10), Date.today().addDays(20));
    	Project__c project = TestUtils.createProject('Test Proj', 'Kenya', 'Available', true);
    	
    	ApexPages.currentPage().getParameters().put('sObjName', ExchangeRateService.ExchangeRateSObjects.Project.name());
		ApexPages.currentPage().getParameters().put('id', project.Id);
		CalculateExchangeRateCtr ctr = new CalculateExchangeRateCtr();
		
		ctr.exchangeRate.Convert_From__c = 'USD --> Local Currency';
		ctr.exchangeRate.Currency__c = crncy.Id;
		ctr.exchangeRate.Start_Date__c = Date.today();
		
		ctr.calculateExchangeRate();
        System.assertEquals(87.4, [SELECT Exchange_Rate__c FROM Project__c WHERE Id =: project.Id].Exchange_Rate__c);
    }
 
    /*
    static testMethod void testExchangeRateForFunding() {
    	setup('BRL', 'Brazil', 2.4, Date.today().addDays(-10), Date.today().addDays(20));
    	Project__c project = TestUtils.createProject('Test Proj', 'Brazil', 'Available', true);
    	Funding__c funding = TestUtils.createFunding(project.Id, opp.Id, null, true);
    	
    	ApexPages.currentPage().getParameters().put('sObjName', ExchangeRateService.ExchangeRateSObjects.Funding.name());
		ApexPages.currentPage().getParameters().put('id', funding.Id);
		CalculateExchangeRateCtr ctr = new CalculateExchangeRateCtr();
		
		ctr.exchangeRate.Convert_From__c = 'USD --> Local Currency';
		ctr.exchangeRate.Currency__c = crncy.Id;
		ctr.exchangeRate.Start_Date__c = Date.today();
		
		ctr.calculateExchangeRate();
        System.assertEquals(2.4, [SELECT Exchange_Rate__c FROM Funding__c WHERE Id =: funding.Id].Exchange_Rate__c);
    }*/
    
    static testMethod void testExchangeRateForSolicitation() {
    	setup('GBP', 'England', 1.528, Date.today().addDays(-10), Date.today().addDays(20));
    	Solicitation_RFP__c sRFP = TestUtils.createSolicitation('Test SRFP', acc.Id, true);
    	
    	ApexPages.currentPage().getParameters().put('sObjName', ExchangeRateService.ExchangeRateSObjects.Solicitation.name());
		ApexPages.currentPage().getParameters().put('id', sRFP.Id);
		CalculateExchangeRateCtr ctr = new CalculateExchangeRateCtr();
		
		ctr.exchangeRate.Convert_From__c = 'USD --> Local Currency';
		ctr.exchangeRate.Currency__c = crncy.Id;
		ctr.exchangeRate.Start_Date__c = Date.today();
		
		ctr.calculateExchangeRate();
        System.assertEquals(1.528, [SELECT Exchange_Rate__c FROM Solicitation_RFP__c WHERE Id =: sRFP.Id].Exchange_Rate__c);
    }
    
    static testMethod void testExchangeRateForAccountRole() {
    	setup('GBP', 'England', 1.528, Date.today().addDays(-10), Date.today().addDays(20));
    	Account_Roles__c accRole = TestUtils.createAccountRole(acc.Id, opp.Id, true);
    	
    	ApexPages.currentPage().getParameters().put('sObjName', ExchangeRateService.ExchangeRateSObjects.AccountRole.name());
		ApexPages.currentPage().getParameters().put('id', accRole.Id);
		CalculateExchangeRateCtr ctr = new CalculateExchangeRateCtr();
		
		ctr.exchangeRate.Convert_From__c = 'USD --> Local Currency';
		ctr.exchangeRate.Currency__c = crncy.Id;
		ctr.exchangeRate.Start_Date__c = Date.today();
		
		ctr.calculateExchangeRate();
        System.assertEquals(1.528, [SELECT Exchange_Rate__c FROM Account_Roles__c WHERE Id =: accRole.Id].Exchange_Rate__c);
    }
}