/***********************************************************************************************************
* Appirio, Inc
* Name         : OpportunityRelatedContentsTest
* Created By   : Ravi Chauhan (Appirio)
* Purpose      : Test class for OpportunityRelatedContents
* Created Date : 28/July/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* Aug 12, 2016                  Ashu Gupta              Implemented coding conventions
**********************************************************************************************************/
@isTest
public class OpportunityRelatedContentsTest {
    
    // Declaring all static variable for Account Record types
    Final Static Id nationalAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id TransactionOppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    
    Static Account accNational,acc;
    Static Obligation__c obligation1,obligation2,obligation3;
    Static Opportunity opportunity1;
    Static rC_Giving__GAU__c gau1;
    Static GL_Allocation__c GLAllocation1,GLAllocation2,GLAllocation3;
    
    @isTest
    public static void testInitialization1(){
        
        setUpTestData();
        
        // Creation of GL Account
        GLAllocation1 = TestUtils.createGlAllocation(String.valueOf(gau1.Id), False);
        GLAllocation1.IsObligation__c = True;
        GLAllocation1.Obligation__c = obligation1.Id;
        GLAllocation1.Amount__c = 100;
        GLAllocation1.Transaction__c = opportunity1.Id;
        insert GLAllocation1;
        Test.startTest();
        Test.setCurrentPage(Page.OpportunityRelatedContents);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opportunity1);
        OpportunityRelatedContents extension = new OpportunityRelatedContents(stdCon);
        
        // Assertion to check if values have been set in the controller
        System.assertEquals('Recieved by NO', extension.status);
        System.assertEquals('Received by NO', extension.pendingStatusMap.get(GLAllocation1.Id));
        test.stopTest();
    }
    
    @isTest
    public static void testInitialization2(){
        
        setUpTestData();
        Test.startTest();
        // Creation of GL Account
        GLAllocation2 = TestUtils.createGlAllocation(String.valueOf(gau1.Id), False);
        GLAllocation2.IsObligation__c = True;
        GLAllocation2.Obligation__c = obligation3.Id;
        GLAllocation2.Amount__c = 100;
        GLAllocation2.Transaction__c = opportunity1.Id;
        insert GLAllocation2;
        
        Test.setCurrentPage(Page.OpportunityRelatedContents);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opportunity1);
        OpportunityRelatedContents extension = new OpportunityRelatedContents(stdCon);
        
        // Assertion to check if values have been set in the controller
        System.assertEquals('Sent to NO', extension.status);
        System.assertEquals('Sent to NO', extension.pendingStatusMap.get(GLAllocation2.Id));
        Test.stopTest();
    }
    
    @isTest
    public static void testInitialization3(){
        
        setUpTestData();
        
        // Creation of GL Account
        GLAllocation3 = TestUtils.createGlAllocation(String.valueOf(gau1.Id), False);
        GLAllocation3.IsObligation__c = True;
        GLAllocation3.Obligation__c = obligation2.Id;
        GLAllocation3.Amount__c = 100;
        GLAllocation3.Transaction__c = opportunity1.Id;
        insert GLAllocation3;
        
        Test.setCurrentPage(Page.OpportunityRelatedContents);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opportunity1);
        OpportunityRelatedContents extension = new OpportunityRelatedContents(stdCon);
        
        // Assertion to check if values have been set in the controller
        System.assertEquals('Pending', extension.status);
        System.assertEquals('Pending', extension.pendingStatusMap.get(GLAllocation3.Id));
        
    }
    
    @isTest
    public static void testGetDFCOverRidePicklist(){
        setUpTestData();
        
        Test.setCurrentPage(Page.OpportunityRelatedContents);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opportunity1);
        OpportunityRelatedContents extension = new OpportunityRelatedContents(stdCon);
        
        List<SelectOption> picklist = extension.getdfcOverRidePicklist();
        
        // Assert the values and labels of SelectOptions
        for(SelectOption so : extension.getdfcOverRidePicklist()){
            if(so.getLabel() == '--none--')
                System.assertEquals('none', so.getValue());
            else if(so.getLabel() == 'Received by Child')
                System.assertEquals('Received by Child', so.getValue());
            else if(so.getLabel() == 'Kept by LP/Community')
                System.assertEquals('Kept by LP/Community', so.getValue());
            else if(so.getLabel() == 'Undeliverable - Project Closed')
                System.assertEquals('Undeliverable - Project Closed', so.getValue());
            else if(so.getLabel() == 'Undeliverable - Over $100')
                System.assertEquals('Undeliverable - Over $100', so.getValue());
        }
        
    }
    
    @isTest
    public static void testSaveContentWhenReceievednReleaseDateNotNull(){
        
        setUpTestData();
        
        // Creation of GL Account
        
        GLAllocation1 = TestUtils.createGlAllocation(String.valueOf(gau1.Id), False);
        GLAllocation1.IsObligation__c = True;
        GLAllocation1.Obligation__c = obligation1.Id;
        GLAllocation1.Amount__c = 100;
        GLAllocation1.Transaction__c = opportunity1.Id;
        insert GLAllocation1;
        
        Test.setCurrentPage(Page.OpportunityRelatedContents);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opportunity1);
        OpportunityRelatedContents extension = new OpportunityRelatedContents(stdCon);

        extension.selectedDFCOverrideStatus = 'Pending';
        
        extension.saveContent();
        
        // Assertion to check if values have been set in the controller
        System.assertEquals('Recieved by NO', extension.pendingStatusMap.get(GLAllocation1.Id));
    }
    
    @isTest
    public static void testSaveContentWhenReceievedDateIsNull(){
        
        setUpTestData();
        
        // Creation of GL Account
        
        GLAllocation2 = TestUtils.createGlAllocation(String.valueOf(gau1.Id), False);
        GLAllocation2.IsObligation__c = True;
        GLAllocation2.Obligation__c = obligation3.Id;
        GLAllocation2.Amount__c = 100;
        GLAllocation2.Transaction__c = opportunity1.Id;
        insert GLAllocation2;
        
        Test.setCurrentPage(Page.OpportunityRelatedContents);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opportunity1);
        OpportunityRelatedContents extension = new OpportunityRelatedContents(stdCon);

        extension.selectedDFCOverrideStatus = 'Pending';
        
        extension.saveContent();
        
        // Assertion to check if values have been set in the controller
        System.assertEquals('Sent to NO', extension.pendingStatusMap.get(GLAllocation2.Id));
        System.assertEquals('Sent to NO', extension.status);
    }
    
    @isTest
    public static void testSaveContentWhenReleaseDateIsNull(){
        
        setUpTestData();
        
        // Creation of GL Account
        GLAllocation3 = TestUtils.createGlAllocation(String.valueOf(gau1.Id), False);
        GLAllocation3.IsObligation__c = True;
        GLAllocation3.Obligation__c = obligation2.Id;
        GLAllocation3.Amount__c = 100;
        GLAllocation3.Transaction__c = opportunity1.Id;
        insert GLAllocation3;
        
        Test.setCurrentPage(Page.OpportunityRelatedContents);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opportunity1);
        OpportunityRelatedContents extension = new OpportunityRelatedContents(stdCon);
        
        extension.selectedDFCOverrideStatus = 'Pending';
        
        extension.saveContent();
        
        // Assertion to check if values have been set in the controller
        System.assertEquals('Pending', extension.status);
        System.assertEquals('Pending', extension.pendingStatusMap.get(GLAllocation3.Id));
    }
    
    @isTest
    public static void testdeleteContent(){
        
        setUpTestData();
        
        // Creation of GL Account
        GLAllocation1 = TestUtils.createGlAllocation(String.valueOf(gau1.Id), False);
        GLAllocation1.IsObligation__c = True;
        GLAllocation1.Obligation__c = obligation1.Id;
        GLAllocation1.Amount__c = 100;
        GLAllocation1.Transaction__c = opportunity1.Id;
        insert GLAllocation1;
        
        System.assertEquals(1, [SELECT count() From GL_Allocation__c]);
        
        Test.setCurrentPage(Page.OpportunityRelatedContents);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opportunity1);
        OpportunityRelatedContents extension = new OpportunityRelatedContents(stdCon);
        extension.selectedContent =  String.valueOf(GLAllocation1.Id);
        
        extension.deleteContent();
        // Assertion to check That the record has been deleted
        
        System.assertEquals(0, [SELECT count() From GL_Allocation__c]);
        
    }
    
    @isTest
    public static void testrenderVF(){
        setUpTestData();
        Test.setCurrentPage(Page.OpportunityRelatedContents);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opportunity1);
        OpportunityRelatedContents extension = new OpportunityRelatedContents(stdCon);
        extension.renderVF();
    }
    
    private static void setUpTestData(){
        // Creation of National Office Account required for Obligation
        accNational = TestUtils.createAccountWithRT('Test National Account',String.valueOf(nationalAccRecId),null,'909',null,True);
        acc = TestUtils.createAccount('Test Account', True);
        
        // Creation Of Obligation with release date and received by NO Date set
        List<Obligation__c> obList = new List<Obligation__c>();
        obligation1 = TestUtils.createObligation(accNational,False);
        obligation1.Received_by_NO_Date__c = Date.today();
        obligation1.Release_Date__c = Date.today();
        obligation1.Receipt_Type__c = '2 Sponsorship';
        obligation1.Amount_USD__c = 100;
        obligation1.Exchange_Rate__c = 5;
        obList.add(obligation1);
        
        // Creation Of Obligation with null release date
        obligation2 = TestUtils.createObligation(accNational,False);
        obligation2.Received_by_NO_Date__c = Date.today();
        obligation2.Receipt_Type__c = '2 Sponsorship';
        obligation2.Amount_USD__c = 100;
        obligation2.Exchange_Rate__c = 5;
        obList.add(obligation2);
        
        // Creation Of Obligation with null received by NO Date
        obligation3 = TestUtils.createObligation(accNational,False);
        obligation3.Release_Date__c = Date.today();
        obligation3.Receipt_Type__c = '2 Sponsorship';
        obligation3.Amount_USD__c = 100;
        obligation3.Exchange_Rate__c = 5;
        obList.add(obligation3);
        
        insert obList;
        // Creation of Opportunity of type Transaction to be related to GL Allocation
        rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('600',true);
        
        opportunity1 = TestUtils.createOpportunity(acc,'Transaction Opportunity 1',100,False);
        opportunity1.RecordTypeId = TransactionOppRecId;
        opportunity1.DFC_Status__c = 'Pending';
        insert opportunity1;

        // Creation of General Accounting Unit
        gau1 = TestUtils.createGeneralAccountingUnit('Test General Accounting Unit',True);
        
        
        
        
    }

}