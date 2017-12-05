/***********************************************************************************************************
 * Appirio, Inc
 * Name         : OpportunityRefundAdjustmentTest 
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class for "OpportunityRefundAdjustment" class
 * Created Date : 07/Apr/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/03/2016                   Ravi Chauhan            Assertions
 * 31/08/2016                   Ashu Gupta              Increased code coverage
 * 27/12/2016					Suminder Singh			Fixed for errors and code coverage
 **********************************************************************************************************/

@isTest
private class OpportunityRefundAdjustmentTest {
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_COM_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id ACC_CF_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
    Final Static Id CON_PART_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    Final Static Id oppTransactionRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    Final Static Id oppDonationRecTypeId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
	static Account acc;
	static Opportunity opp2,opp1,opp3;
	static Obligation__c ob;
	static rC_Giving__Payment_Method__c paymentMethod,newPM;
	
  
   @isTest
    private static void test_adjustmentTypeChange() {
        Test.startTest();
			setupTestData();
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_adjustmentTypeChange :: Method Start..');
			Opportunity OpportunityInstance = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_adjustmentTypeChange :: OpportunityInstance => ' + OpportunityInstance);
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			//ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			//OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', OpportunityInstance.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(OpportunityInstance);
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);

            ora.adjustmentType = '-select-';
            ora.adjustmentTypeChange();
            //System.assertEquals('152',ora.negTransGAUoptions.get(0).getValue());
            
            ora.adjustmentType = 'Refund';
            ora.adjustmentTypeChange();
            //System.assertEquals('152',ora.negTransGAUoptions.get(0).getValue());
            System.assertEquals('0150',ora.posTransGAUoptions.get(0).getValue());
            
            ora.adjustmentType = 'Return';
            ora.adjustmentTypeChange();
            //System.assertEquals('152',ora.negTransGAUoptions.get(0).getValue());
            for(SelectOption so : ora.posTransGAUoptions){
                System.assert(so.getValue() == '0154' || so.getValue() == '0157' || 
                              so.getValue() == '0158' || so.getValue() == '0160' || so.getValue() == '0161');
            }
            
            ora.adjustmentType = 'Adjustment';
            ora.adjustmentTypeChange();
           // System.assertEquals('152',ora.negTransGAUoptions.get(0).getValue());
            for(SelectOption so : ora.posTransGAUoptions){
                System.assert(so.getValue() == 'Destination Opportunity' || so.getValue() == '0600');
            }

            ora.adjustmentType = 'Designated Fund';
            ora.productType = 'prod1';
            ora.adjustmentTypeChange();
            //System.assertEquals('152',ora.negTransGAUoptions.get(0).getValue());
            System.assertEquals(0,ora.posTransGAUoptions.size());

            OpportunityInstance.DFC_Status__c = 'Undeliverable - Project Closed';
            update OpportunityInstance;
            System.debug('AG----OpportunityInstance' +OpportunityInstance);
            ora.adjustmentTypeChange();
            
        Test.stopTest();
        System.debug('[RB] - OpportunityRefundAdjustmentTest.test_adjustmentTypeChange :: Method End..');
    } // END private static void test_adjustmentTypeChange() {
     @isTest
    private static void test_adjustmentTypeChange3() {
        setupTestData();
        Test.startTest();
			
			
			Opportunity OpportunityInstance = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c FROM Opportunity WHERE id =: Opp2.id];
			System.debug('@@@ OpportunityInstance => ' + OpportunityInstance);
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			//ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			//OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', OpportunityInstance.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(OpportunityInstance);
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
            
            ora.adjustmentTypeChange();
            
            
            ora.dfc_InProcess_Sent_ReceivedbyNO = true;
            
            ora.adjustmentTypeChange();
            System.assertEquals('0152',ora.negTransGAUoptions.get(0).getValue());
            
            OpportunityInstance.DFC_Status__c = 'Kept by LP/Community';
            update OpportunityInstance;
            stdCon = new ApexPages.StandardController(OpportunityInstance);
            ora = new OpportunityRefundAdjustment(stdCon);
            ora.adjustmentTypeChange();
            System.assertEquals('0156',ora.negTransGAUoptions.get(0).getValue());
           
           OpportunityInstance.DFC_Status__c = 'Undeliverable - Project Closed';
            update OpportunityInstance;
            stdCon = new ApexPages.StandardController(OpportunityInstance);
            ora = new OpportunityRefundAdjustment(stdCon);
            ora.adjustmentTypeChange();
            System.assertEquals('0155',ora.negTransGAUoptions.get(0).getValue());
            
            
    } // END private static void test_adjustmentTypeChange() {
    @isTest
    private static void test_adjustmentTypeChange2() {
        setupTestData();
        Test.startTest();
			//setupTestData3();
			
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_adjustmentTypeChange :: Method Start..');
			Opportunity OpportunityInstance = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_adjustmentTypeChange :: OpportunityInstance => ' + OpportunityInstance);
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			//ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			//OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', OpportunityInstance.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(OpportunityInstance);
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);

            ora.adjustmentType = '-select-';
            ora.adjustmentTypeChange();
            System.assertEquals('Origin',ora.negTransGAUoptions.get(0).getValue());
            System.assertEquals(0,ora.posTransGAUoptions.size());

            ora.adjustmentType = 'Refund';
            ora.adjustmentTypeChange();
            //System.assertEquals('Origin',ora.negTransGAUoptions.get(0).getValue());
            System.assertEquals('0150',ora.posTransGAUoptions.get(0).getValue());

            ora.adjustmentType = 'Return';
            ora.adjustmentTypeChange();
           // System.assertEquals('Origin',ora.negTransGAUoptions.get(0).getValue());
            for(SelectOption so : ora.posTransGAUoptions){
                System.assert(so.getValue() == '0154' || so.getValue() == '0157' || 
                              so.getValue() == '0158' || so.getValue() == '0160' || so.getValue() == '0161');
            }

            ora.adjustmentType = 'Adjustment';
            ora.adjustmentTypeChange();
            System.assertEquals('Origin',ora.negTransGAUoptions.get(0).getValue());
            for(SelectOption so : ora.posTransGAUoptions){
                System.assert(so.getValue() == 'Destination Opportunity' || so.getValue() == '0600');
            }

            ora.adjustmentType = 'Designated Fund';
            ora.productType = 'prod1';
            ora.adjustmentTypeChange();
            System.assertEquals('Origin',ora.negTransGAUoptions.get(0).getValue());
            System.assertEquals(0,ora.posTransGAUoptions.size());

            OpportunityInstance.DFC_Status__c = 'Undeliverable - Project Closed';
            update OpportunityInstance;
            System.debug('AG----OpportunityInstance' +OpportunityInstance);
            ora.adjustmentTypeChange();

        Test.stopTest();
        System.debug('[RB] - OpportunityRefundAdjustmentTest.test_adjustmentTypeChange :: Method End..');
    } // END private static void test_adjustmentTypeChange() {
    
    @isTest
    private static void test_submitRefundAdjustmentReturn() {
       setupTestData();
			createPM();
        Boolean messageFound = false;
        Test.startTest();
			
			Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Method Start..');
			Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c,Amount FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Opp => ' + Opp);

			Opp.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
			update Opp;

			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', Opp.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
        
			OpportunityRefundAdjustment ora2 = new OpportunityRefundAdjustment(stdCon);
			ora2.adjustmentType = '-select-';
            ora2.submitRefundAdjustment();
            for(ApexPages.Message message : ApexPages.getMessages()) {
                if(message.getDetail() == 'Adjustment Type must be selected.'
                    && message.getSeverity() == ApexPages.severity.ERROR) {
                        messageFound = true;        
                }
            }
            System.assert(messageFound);
            
            ora2.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora2.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora2.submitRefundAdjustment();
            
            ora2.uiOpportunityFields.Adjustment_Reason__c = 'RTR - DF Returned to Richmond';
            ora2.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora2.submitRefundAdjustment();
            

            ora2.adjustmentType = 'Return';
            ora2.posTransGAU = '';
            ora2.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            ora2.submitRefundAdjustment();
            

            ora2.uiOpportunityFields.Amount = Opp.Amount;
            ora2.uiOpportunityFields.Adjustment_Reason__c = null;
            ora2.submitRefundAdjustment();
            
        Test.stopTest();
    }
    
    @isTest
    private static void test_submitRefundAdjustmentReturn1() {
        
			setupTestData();
			
			createPM();
			Test.startTest();
			Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Method Start..');
			Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c,Amount FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Opp => ' + Opp);
			
			Opp.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
			update Opp;
			
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', Opp.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
        
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
            
            ora.adjustmentType = 'Return';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.uiOpportunityFields.Adjustment_Reason__c = 'Reason';
			//ora.uiOpportunityFields.Amount = 101;
            ora.submitRefundAdjustment();
        Test.stopTest();

		List<Opportunity> lstOpp = [SELECT Id FROM Opportunity WHERE StageName='Returned' AND Return_Code__c='C08 - Reserved' AND Adjustment_Reason__c='Reason'];
		System.assertNotEquals(0, lstOpp.size());
    }
    
    //@isTest
    private static void test_submitRefundAdjustmentReturn2() {
        Test.startTest();
			//setupTestData2();
			Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Method Start..');
			Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c,Amount FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Opp => ' + Opp);
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', Opp.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
        
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
            
            ora.adjustmentType = 'Return';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.uiOpportunityFields.Adjustment_Reason__c = 'Reason';
			ora.uiOpportunityFields.Amount = 101;
            ora.submitRefundAdjustment();
        Test.stopTest();
		List<Opportunity> lstOpp = [SELECT Id FROM Opportunity WHERE StageName='Returned' AND Return_Code__c='C08 - Reserved' AND Adjustment_Reason__c='Reason'];
		//System.assertNotEquals(0, lstOpp.size());
    }
    
	//@isTest
    private static void test_submitRefundAdjustmentReturn3() {
        Test.startTest();
			setupTestData();
			Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Method Start..');
			Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c,Amount FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Opp => ' + Opp);
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', Opp.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
        
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
            
            ora.adjustmentType = 'Return';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.uiOpportunityFields.Adjustment_Reason__c = 'Reason';
            ora.uiOpportunityFields.Amount = 101;
            ora.submitRefundAdjustment();
        Test.stopTest();
		
		List<Opportunity> lstOpp = [SELECT Id FROM Opportunity WHERE StageName='Returned' AND Amount = 101];
		System.assertNotEquals(0, lstOpp.size());
    }

    @isTest
    private static void test_submitRefundAdjustmentTransaction() {
        Boolean messageFound = False;
			
			setupTestData();
			Test.startTest();
			ApexPages.Message[] pageMessages;
			//Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Method Start..');
			Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c,Amount FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			ApexPages.currentPage().getParameters().put('id', Opp.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
       
            OpportunityRefundAdjustment ora1 = new OpportunityRefundAdjustment(stdCon);
            ora1.adjustmentType = '-select-';
            ora1.submitRefundAdjustment();
           
            
            pageMessages = ApexPages.getMessages();
            System.assertEquals(pageMessages[2].getSummary().contains('Adjustment Type must be selected.'), true);
            
            
            ora1.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora1.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora1.submitRefundAdjustment();
            //pageMessages = ApexPages.getMessages();
            

            ora1.adjustmentType = 'Adjustment';
            ora1.posTransGAU = '';
            ora1.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            ora1.submitRefundAdjustment();
            //pageMessages = ApexPages.getMessages();

            ora1.uiOpportunityFields.Amount = Opp.Amount;
            ora1.uiOpportunityFields.Adjustment_Reason__c = null;
            ora1.submitRefundAdjustment();
            //pageMessages = ApexPages.getMessages();
            
            //--------------------------------------case3
            OpportunityRefundAdjustment ora2 = new OpportunityRefundAdjustment(stdCon);
            ora2.adjustmentType = '-select-';
            ora2.submitRefundAdjustment();
            
            ora2.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora2.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora2.submitRefundAdjustment();
            

            ora2.adjustmentType = '';
            ora2.posTransGAU = '';
            ora2.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            ora2.submitRefundAdjustment();
            

            ora2.uiOpportunityFields.Amount = Opp.Amount;
            ora2.uiOpportunityFields.Adjustment_Reason__c = null;
            ora2.submitRefundAdjustment();
            
        Test.stopTest();
        
		List<Opportunity> lstTranOpps = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Transaction'];
        System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: lstTranOpps => ' + lstTranOpps);
      // System.assertNotEquals(Null, tranOpp);
        System.debug('[RB] - OpportunityRefundAdjustmentTest.test_adjustmentTypeChange :: Method End..');
    } // END private static void test_submitRefundAdjustment() {
    
   
    @isTest
    private static void test_submitRefundAdjustmentDestination() {
        Boolean messageFound = False;
        setupTestData();
        createPM();
        Test.startTest();
        Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Method Start..');
			Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,rC_Giving__Hard_Credit_Contact__c,name,DFC_Status__c,Amount FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Opp => ' + Opp);
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			//ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			//OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', Opp.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
            
            ora.adjustmentType = '-select-';
            ora.submitRefundAdjustment();
            for(ApexPages.Message message : ApexPages.getMessages()) {
                if(message.getDetail() == 'Adjustment Type must be selected.'
                    && message.getSeverity() == ApexPages.severity.ERROR) {
                        messageFound = true;        
                }
            }
            
            ora.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.submitRefundAdjustment();
            

			try{
            ora.adjustmentType = 'Adjustment';
            ora.posTransGAU = 'Destination Opportunity';
            ora.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            Opportunity ooop = [SELECT id,Participant__c,rC_Giving__Hard_Credit_Contact__c,
                                Participant__r.name,Participant__r.Sponsorship_Status__c from Opportunity WHERE id =:Opp.rC_Giving__Parent__c LIMIT 1];
            System.assertEquals(ooop.rC_Giving__Hard_Credit_Contact__c ,null); 
            ora.submitRefundAdjustment();
            
             
            ora.adjustmentType = 'Adjustment';
            ora.posTransGAU = 'Transaction Opportunity';
            ora.uiOpportunityFields.Adjustment_Reason__c = 'RTR - DF Returned to Richmond';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
			} catch(Exception e) {}
           // ora.submitRefundAdjustment();
            
            ora.adjustmentType = 'Return';
            ora.uiOpportunityFields.Return_Code__c = null;
            ora.submitRefundAdjustment();
            
            ora.uiOpportunityFields.rC_Giving__Parent__c = null;
            ora.submitRefundAdjustment();
            

            opp.recordTypeId = oppDonationRecTypeId;
            update opp;

            System.debug('In submit refund test method Opportuntity'+opp);
            ora.submitRefundAdjustment();
             
       
       
    } // END private static void test_submitRefundAdjustment() {
    @isTest
    private static void test_submitRefundAdjustmentDestination2() {
        Boolean messageFound = False;
        setupTestData();
        createPM();
        Test.startTest();
		
			Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
			
			Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,rC_Giving__Hard_Credit_Contact__c,name,DFC_Status__c,Amount FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
		
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			
			ApexPages.currentPage().getParameters().put('id', Opp.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
            
           
            ora.adjustmentType = 'Adjustment';
            ora.posTransGAU = 'Transaction Opportunity';
            ora.uiOpportunityFields.Adjustment_Reason__c = 'RTR - DF Returned to Richmond';
            ora.dfc_InProcess_Sent_ReceivedbyNO = true;
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.submitRefundAdjustment();
            ora = new OpportunityRefundAdjustment(stdCon);
			ora.dfc_InProcess_Sent_ReceivedbyNO = false;
            ora.submitRefundAdjustment();
             
             
            ora.posTransGAU = 'Destination Opportunity';
            
           
        Test.stopTest();
      
    } 
    
    
    @isTest
    public static void testsuspenseOpportunity(){
    	Test.startTest();
    		setupTestData();
			Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Method Start..');
			Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c,Amount FROM Opportunity WHERE rC_Giving__Parent__c != Null LIMIT 1];
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Opp => ' + Opp);
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', Opp.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
        
			ora.adjustmentType = 'Adjustment';
            ora.posTransGAU = 'Destination Opportunity';
            ora.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            ora.submitRefundAdjustment();
            ora.uiOpportunityFields.rC_Giving__Parent__c = null;
            ora.submitRefundAdjustment();
        Test.stopTest();
    }
    
    @isTest
    public static void testController(){
    	setupTestData();
    	Test.startTest();
    		
			Id oppDonationRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
			System.debug('[RB] - OpportunityRefundAdjustmentTest.test_submitRefundAdjustment :: Method Start..');
			Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c,Amount,StageName FROM Opportunity WHERE id=:opp2.id];
			
			Test.setCurrentPage(Page.OpportunityRefundAdjustment);
			ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Opportunity());
			OpportunityRefundAdjustment ora0 = new OpportunityRefundAdjustment(stdCon0);
			ApexPages.currentPage().getParameters().put('id', Opp.Id);
			ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
			OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
            
            List<GL_Allocation__c> lstGLA = [select Release_Date__c, Received_by_NO_Date__c
			from GL_Allocation__c where
			IsObligation__c = true
			AND Transaction__c = :Opp.id];
			system.assertEquals(lstGLA.size(),1);
		    System.assertEquals(opp.DFC_Status__c,'Pending');
		     System.assertEquals(ora.calculatedDFCStatus,'Sent to NO');
		    
		    
		    ob.Release_Date__c = null;
		    update ob;
		    ora = new OpportunityRefundAdjustment(stdCon);
		    System.assertEquals(ora.calculatedDFCStatus,'In Process');
		     
		    ob.Received_by_NO_Date__c = System.today();
		    ob.Release_Date__c = System.today();
		    update ob;
		    ora = new OpportunityRefundAdjustment(stdCon);
		    System.assertEquals(ora.calculatedDFCStatus,'Received by NO');
		    
		    
		    opp.StageName = 'Completed';
		    update opp;
		    ora = new OpportunityRefundAdjustment(stdCon);
		    System.assertEquals(ora.disableAdjustment,true);
        Test.stopTest();
    }
     @isTest
    private static void test_submitRefundAdjustmentDestination3() {
        setupTestData();
        Test.startTest();
    	Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c,Amount FROM Opportunity WHERE id=:opp2.id];
    	Test.setCurrentPage(Page.OpportunityRefundAdjustment);
        ApexPages.currentPage().getParameters().put('id', Opp.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
	    OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
	    try{
	    ora.suppressFromStatement = true;
	     ora.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
        ora.submitRefundAdjustment();}
        catch(Exception e ){}
        Test.stopTest();
    }
    
    @isTest
    private static void test_submitRefundAdjustmentDestination4() {
        setupTestData();
        Test.startTest();
    	Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,name,DFC_Status__c,Amount FROM Opportunity WHERE id=:Opp3.id];
    	Test.setCurrentPage(Page.OpportunityRefundAdjustment);
        ApexPages.currentPage().getParameters().put('id', Opp.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
	    OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
	    ora.adjustmentType = 'Adjustment';
	    ora.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.posTransGAU = 'Destination Opportunity';
            ora.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            ora.submitRefundAdjustment();
            
            Opportunity destOpp= [SELECT id,Participant__c,Participant__r.Sponsorship_Status__c FROM Opportunity WHERE id=:Opp.rC_Giving__Parent__c LIMIT 1];
            System.assertNotEquals(destOpp.id,null);
           
            system.assertNotEquals(destOpp.Participant__r.Sponsorship_Status__c,'Departed');
            ora.uiOpportunityFields.rC_Giving__Parent__c = null;
            ora.submitRefundAdjustment();
	    
	 test.stopTest();   
    }
    @isTest
    private static void test_submitRefundAdjustmentDestination5() {
        setupTestData();
        Test.startTest();
         newPM.rC_Giving__Payment_Type__c = 'Charge Card';
	        Update newPM;
    	Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,name,DFC_Status__c,Amount FROM Opportunity WHERE id=:Opp3.id];
	    System.assertEquals(Opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,'Charge Card');
    	Test.setCurrentPage(Page.OpportunityRefundAdjustment);
        ApexPages.currentPage().getParameters().put('id', Opp.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
	    OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
	    ora.adjustmentType = 'Adjustment';
	    ora.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.posTransGAU = 'Destination Opportunity';
            ora.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            ora.submitRefundAdjustment();
    Test.stopTest();       
    }
    @isTest
    private static void test_submitRefundAdjustmentDestination6() {
        setupTestData();
        Test.startTest();
         newPM.rC_Giving__Payment_Type__c = 'EFT';
	    Update newPM;
    	Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,name,DFC_Status__c,Amount FROM Opportunity WHERE id=:Opp3.id];
	    System.assertEquals(Opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,'EFT');
    	Test.setCurrentPage(Page.OpportunityRefundAdjustment);
        ApexPages.currentPage().getParameters().put('id', Opp.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
	    OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
	    ora.adjustmentType = 'Adjustment';
	    ora.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.posTransGAU = 'Destination Opportunity';
            ora.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            ora.submitRefundAdjustment();
    Test.stopTest();       
    }
    
    @isTest
    private static void test_submitRefundAdjustmentDestination7() {
        setupTestData();
        Test.startTest();
         newPM.rC_Giving__Payment_Type__c = 'Securities';
         newPm.rC_Giving__Ticker_Symbol__c = 'xyz';
	        Update newPM;
    	Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,rC_Giving__Payment_Method_Selected__r.rC_Giving__Ticker_Symbol__c,
    	                    
    	                    rC_Giving__Ticker_Symbol__c,rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,name,DFC_Status__c,Amount 
    	                    FROM Opportunity WHERE id=:Opp3.id];
	    
	    System.assertEquals(Opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,'Securities');
    	Test.setCurrentPage(Page.OpportunityRefundAdjustment);
        ApexPages.currentPage().getParameters().put('id', Opp.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
	    OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
	    ora.adjustmentType = 'Adjustment';
	    ora.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.posTransGAU = 'Destination Opportunity';
            ora.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            ora.submitRefundAdjustment();
    Test.stopTest();       
    }
    @isTest
    private static void test_submitRefundAdjustmentDestination8() {
        setupTestData();
        Test.startTest();
         newPM.rC_Giving__Payment_Type__c = 'Third Party Charge';
	        Update newPM;
    	Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,name,DFC_Status__c,Amount FROM Opportunity WHERE id=:Opp3.id];
	    System.assertEquals(Opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,'Third Party Charge');
    	Test.setCurrentPage(Page.OpportunityRefundAdjustment);
        ApexPages.currentPage().getParameters().put('id', Opp.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
	    OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
	    ora.adjustmentType = 'Adjustment';
	    ora.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.posTransGAU = 'Destination Opportunity';
            ora.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
            ora.submitRefundAdjustment();
    Test.stopTest();       
    }
     @isTest
    private static void test_submitRefundAdjustmentDestination9() {
        setupTestData();
        Test.startTest();
         newPM.rC_Giving__Payment_Type__c = 'test';
	        Update newPM;
    	Opportunity Opp = [SELECT Id, rC_Giving__Parent__c,rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,name,DFC_Status__c,Amount FROM Opportunity WHERE id=:Opp3.id];
	    System.assertEquals(Opp.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,'test');
    	Test.setCurrentPage(Page.OpportunityRefundAdjustment);
        ApexPages.currentPage().getParameters().put('id', Opp.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(Opp);
	    OpportunityRefundAdjustment ora = new OpportunityRefundAdjustment(stdCon);
	    ora.adjustmentType = 'Adjustment';
	    ora.uiOpportunityFields.Adjustment_Reason__c = 'PR - Personal Reason';
            ora.uiOpportunityFields.Return_Code__c = 'C08 - Reserved';
            ora.posTransGAU = 'Destination Opportunity';
            ora.uiOpportunityFields.rC_Giving__Parent__c = Opp.rC_Giving__Parent__c;
           try{
            ora.submitRefundAdjustment();}
            catch(exception e){}
    Test.stopTest();       
    }
    private static void setupTestData() {
		rC_Giving__Contact_Setting__c Contact_Setting = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        Contact_Setting.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert Contact_Setting;
        
        // Account Creation
        List<Account> accountToBeInserted = new List<Account>();
        
        Account NO_Acc = TestUtils.createAccountWithRT('1st National Account', ACC_NO_RT, null, '199', '1245', false);
        NO_Acc.BillingCountry = 'IN';
        NO_Acc.NO_Country__c = 'India';
        accountToBeInserted.add(NO_Acc);
        
        acc = TestUtils.createAccount('My Unit test', false);
        accountToBeInserted.add(acc);
        
        insert accountToBeInserted;
        
        Account LP_Acc = TestUtils.createAccountWithRT('Google Retail Partner', ACC_LP_RT, NO_Acc, '149', '1346', true);
        Account Com_Acc = TestUtils.createAccountWithRT('Maheshwari Community Services', ACC_COM_RT, LP_Acc, '159', '1247', true);
        //Account HH_Acc = TestUtils.createAccountWithRT('Test Household Account', ACC_HH_RT, Com_Acc, '565', '2134', true);
        Account CF_Acc = TestUtils.createAccountWithRT('Test Household Account123', ACC_CF_RT, Com_Acc, '560', '2030', true);
        
        // Contact Creation
        List<Contact> contactToBeInserted = new List<Contact>();
        Contact participant = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participant.RecordTypeId = CON_PART_RT;
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participant.Correspondence_Paused__c = false;
        participant.Community__c = Com_Acc.Id;
        participant.Donor_Alliance__c = CF_Acc.Id;
        participant.Participant_Case_Number__c = '12345';
        participant.MailingStreet = '23 A Bakers Street';
        participant.MailingCity = 'London';
        participant.MailingState = 'London';
        participant.MailingPostalCode = '30201';
        participant.Sponsorship_Status__c = 'Departed';
        contactToBeInserted.add(participant);
        //insert participant;  
        
		Contact con = TestUtils.createContact(acc, 'Unit test 1', 'Apex 1', false);
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.Correspondence_Paused__c = false;
        con.Participant_Case_Number__c = '14253';
        con.Participant_Number__c = '53241';
        contactToBeInserted.add(con);
        //insert con;
        
        Contact participantNew = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participantNew.RecordTypeId = CON_PART_RT;
        participantNew.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        participantNew.Correspondence_Paused__c = false;
        participantNew.Community__c = Com_Acc.Id;
        participantNew.Donor_Alliance__c = CF_Acc.Id;
        participantNew.Participant_Case_Number__c = '12345';
        participantNew.MailingStreet = '23 A Bakers Street';
        participantNew.MailingCity = 'London';
        participantNew.MailingState = 'London';
        participantNew.MailingPostalCode = '30201';
        participantNew.Sponsorship_Status__c = 'Enrolled';
        contactToBeInserted.add(participantNew);
        //insert participantNew;
        
        insert contactToBeInserted;
        
        rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('600',true);

        // Campaign Creation
        List<Campaign> campaignToBeInserted = new List<Campaign>();
        Campaign testCamp = TestUtils.createCampaign('testCamp',false);
        testCamp.Product_Type__c = 'One Time Gift';
        testCamp.Product_Sub_Type__c = 'DFC Fee';
        testcamp.rC_Giving__GAU__c = gau.id;
        campaignToBeInserted.add(testCamp);
        //insert testCamp;

		Campaign testCampNew = TestUtils.createCampaign('718 - DFC Fee',false);
        testCampNew.Product_Type__c = 'Designated Fund';
        campaignToBeInserted.add(testCampNew);
        //insert testCampNew;
        
        insert campaignToBeInserted;
        
        // Payment Method Creation
        
        newPM = TestUtils.createPaymentMethod('testPaymentMethod','Cash/Check',false,acc,false);
		newPM.RecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Cash/Check').getRecordTypeId();
		newPM.rC_Giving__Contact__c = con.Id;
		newPM.rC_Connect__Payment_Processor__c = 'Sage'; 
		newPM.rC_Connect__Merchant_Name__c = 'testMerchantName';
		insert newPM;
        
        // Opportunity Creation
        List<Opportunity> parentOppsToBeInserted = new List<Opportunity>();
        List<Opportunity> childOppsToBeInserted = new List<Opportunity>();
        Opportunity parentOpp = TestUtils.createOpportunity(acc,'parentOpportunity',100,false);
        parentOpp.recordTypeId  = oppDonationRecTypeId1;
        parentOpp.Participant__c = participant.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.Product_Type__c = 'Designated Fund';
        parentOpp.Product_Sub_Type__c = 'Valentines';
        parentOpp.rC_Giving__GAU__c = gau.id;
        parentOppsToBeInserted.add(parentOpp);
        //insert parentOpp;
        
        Opportunity parentOppNew = TestUtils.createOpportunity(acc,'parentOpportunity',100,false);
        parentOppNew.recordTypeId  = oppDonationRecTypeId1;
        parentOppNew.Participant__c = participantNew.Id;
        parentOppNew.CampaignId = testCamp.Id;
        parentOppNew.Product_Type__c = 'Designated Fund';
        parentOppNew.Product_Sub_Type__c = 'Valentines';
        parentOppNew.rC_Giving__GAU__c = gau.id;
        parentOppsToBeInserted.add(parentOppNew);
        //insert parentOppNew;
        
        insert parentOppsToBeInserted;
        
        Opp1 = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        Opp1.recordTypeId  = oppTransactionRecTypeId;
        Opp1.Participant__c = participant.Id;
        Opp1.CampaignId = testCamp.Id;
        Opp1.Cost_Extension__c = true;
        Opp1.rC_Giving__Parent__c = parentOpp.Id;
        Opp1.DFC_Status__c = 'Pending';
        Opp1.CFI_Do_Not_Substitute__c = 'Do Not Substitute - Contact Donor';
        Opp1.Do_Not_Sub_Reason__c = 'Auto Upgrade';
        Opp1.rC_Giving__Hard_Credit_Contact__c = con.Id;
        //Opp.Return_Code__c = 'ABV';
       // opp.Adjustment_Reason__c = null;
        childOppsToBeInserted.add(Opp1);
        //insert  Opp1;
        
        Opp2 = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        Opp2.recordTypeId  = oppTransactionRecTypeId;
        Opp2.Participant__c = participant.Id;
        Opp2.CampaignId = testCamp.Id;
        Opp2.Cost_Extension__c = true;
        Opp2.rC_Giving__Parent__c = parentOpp.Id;
        Opp2.DFC_Status__c = 'Received by Child';
        Opp2.CFI_Do_Not_Substitute__c = 'Do Not Substitute - Contact Donor';
        Opp2.Do_Not_Sub_Reason__c = 'Auto Upgrade';
        Opp2.rC_Giving__Hard_Credit_Contact__c = con.Id;
        childOppsToBeInserted.add(Opp2);
        //insert  Opp2;
        
        Opp3 = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        Opp3.recordTypeId  = oppTransactionRecTypeId;
        Opp3.Participant__c = participantNew.Id;
        Opp3.CampaignId = testCamp.Id;
        Opp3.Cost_Extension__c = true;
        Opp3.rC_Giving__Parent__c = parentOppNew.Id;
        Opp3.DFC_Status__c = 'Received by Child';
        Opp3.CFI_Do_Not_Substitute__c = 'Do Not Substitute - Contact Donor';
        Opp3.Do_Not_Sub_Reason__c = 'Auto Upgrade';
        Opp3.rC_Giving__Hard_Credit_Contact__c = con.Id;
        Opp3.rC_Giving__Payment_Method_Selected__c = newPM.id;
        childOppsToBeInserted.add(Opp3);
        //insert  Opp3;
        
        insert childOppsToBeInserted;
        
        // Obligation Creation
        
        List<Obligation__c> oblList = new List<Obligation__c>();
        Obligation__c ob1L = testUtils.createObligation(null, false);
        ob1L.Release_Date__c = System.today();
        oblList.add(ob1L);
        
        Obligation__c obL = testUtils.createObligation(null, false);
        obL.Release_Date__c = System.today();
        obL.Received_by_NO_Date__c = System.today();
        oblList.add(obL);
        
        ob = testUtils.createObligation(null, false);
        ob.Release_Date__c = System.today();
        oblList.add(ob);
        
        insert oblList;
        
        // GL Allocation Creation
        List<GL_Allocation__c> glaList = new List<GL_Allocation__c>();
        GL_Allocation__c gl1L = TestUtils.createGlAllocation(gau.id,false);
        gl1L.IsObligation__c = true;
        gl1L.Transaction__c = opp1.id;
        gl1L.Obligation__c = oblList.get(0).id; 
        glaList.add(gl1L);
        
        GL_Allocation__c glL = TestUtils.createGlAllocation(gau.id,false);
        glL.IsObligation__c = true;
        glL.Transaction__c = opp1.id;
        glL.Obligation__c = oblList.get(1).id; 
        glaList.add(glL);
        
        GL_Allocation__c gl = TestUtils.createGlAllocation(gau.id,false);
        gl.IsObligation__c = true;
        gl.Transaction__c = opp2.id;
        gl.Obligation__c = ob.id; 
        glaList.add(gl);
        
        insert glaList;
        
        // Preference Creation
        
        Id biosPref_SPON = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();
     
        List<rC_Bios__Preference__c> lstPref = new List<rC_Bios__Preference__c>();
        rC_Bios__Preference__c pref = TestUtils.createBiosPref(Opp1,true,biosPref_SPON,false);
        pref.rC_Bios__Category__c = 'Sponsorship'; 
        pref.rC_Bios__Subcategory__c = 'Contact Search';
        pref.rC_Bios__Type__c = 'Music';
        pref.rC_Bios__Status__c = 'Confirmed';
        lstPref.add(pref);
        
        rC_Bios__Preference__c prefNO =  TestUtils.createBiosPref(Opp1,true,biosPref_SPON,false);
        prefNO.rC_Bios__Category__c = 'Sponsorship'; 
        prefNO.rC_Bios__Subcategory__c = 'Contact Search';
        prefNO.rC_Bios__Type__c = 'National Office';
        prefNO.rC_Bios__Status__c = 'Confirmed';
        prefNO.National_Office__c = NO_Acc.Id;
        lstPref.add(prefNO);
        
        rC_Bios__Preference__c prefLP = TestUtils.createBiosPref(Opp1,true,biosPref_SPON,false);
        prefLP.rC_Bios__Category__c = 'Sponsorship'; 
        prefLP.rC_Bios__Subcategory__c = 'Contact Search';
        prefLP.rC_Bios__Type__c = 'Local Partner';
        prefLP.rC_Bios__Status__c = 'Confirmed';
        prefLP.Local_Partner__c = LP_Acc.Id;
        lstPref.add(prefLP);
                                                               
        
        rC_Bios__Preference__c prefCOM = TestUtils.createBiosPref(Opp1,true,biosPref_SPON,false);
        prefCOM.rC_Bios__Category__c = 'Sponsorship'; 
        prefCOM.rC_Bios__Subcategory__c = 'Contact Search';
        prefCOM.rC_Bios__Type__c = 'Community';
        prefCOM.rC_Bios__Status__c = 'Confirmed';
        prefCOM.Community__c = Com_Acc.Id;
        lstPref.add(prefCOM);
       
        insert lstPref;
    } // END private static void test_callbatch() {
    
   
	static void createPM() {
		Contact con = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
		con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
		con.rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored';
		con.Correspondence_Paused__c = false;
		con.Participant_Case_Number__c = '15423';
		con.Participant_Number__c = '51941';
		insert con;

		rC_Connect__Payment_Method_Setting__c PM_Setting = rC_Connect__Payment_Method_Setting__c.getInstance();
		PM_Setting.rC_Connect__Disable_All__c = true;
		insert PM_Setting;
        
		paymentMethod = TestUtils.createPaymentMethod('testPaymentMethod','Cash/Check',false,acc,false);
	
		paymentMethod.RecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Cash/Check').getRecordTypeId();
		
		paymentMethod.rC_Giving__Contact__c = con.Id;
		paymentMethod.rC_Connect__Payment_Processor__c = 'Sage'; 
		paymentMethod.rC_Connect__Merchant_Name__c = 'testMerchantName';
		
		insert paymentMethod;
	}
} // END private class OpportunityRefundAdjustmentTest {