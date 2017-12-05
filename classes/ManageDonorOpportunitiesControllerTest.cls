/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ManageDonorOpportunitiesControllerTest
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class of ManageDonorOpportunitiesController class
 * Created Date : 29/Mar/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 20/July/2016                 Kanika Mathur           Mofified code to fix error in testingTab1() and to create data using TestUtil
 * 01/Aug/2016                  Ashu Gupta              Increased code coverage
 * 10/Aug/2016                  Ashu Gupta              Added testTString to increase coverage of TStringUtils class
 * 6/Dec/2016                   Ravi Chauhan            Fixed failures in test class
 **********************************************************************************************************/
 
@isTest
private class ManageDonorOpportunitiesControllerTest {
    static Contact conHousehold, con1,conPP;
    static Campaign testCamp;
    static rC_Giving__Payment_Method__c testPayMethod;
    static Account acc, nationalOffice, localPartner, community, household;

    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_COM_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id CON_HH_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id CON_PP_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    Final Static Id OPP_DON_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    Final Static Id OPP_TR_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();

    @isTest
    private static void testingTab1() {
        setupTestData();
        Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc0 = new ManageDonorOpportunitiesController(stdCon0);
            mdoc0.cancel();
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
            System.assertNotEquals(mdoc.lstOppWrap, Null);
            
            List<SelectOption> DF_Types = mdoc.getDF_Types();
            List<SelectOption> SponsorshipChangeReasonDetail = mdoc.getSponsorshipChangeReasonDetail();
            List<SelectOption> DoNotSubs = mdoc.getDoNotSubs();
            mdoc.selectTab();
            mdoc.updateRecords();
            mdoc.lstOppWrap[0].isUpdate = true;
            mdoc.updateRecords();
            mdoc.cancel();
            String oppId = mdoc.lstOppWrap[0].Opp.Id;
            
            // For Tab 1 functionality
            ManageDonorOpportunitiesController mdoc_Tab1 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab1.selectedTab = 'Tab1';
            mdoc_Tab1.lstOppWrap[0].isUpdate = true;
            mdoc_Tab1.DF_Type = testCamp.Id;
            mdoc_Tab1.oppty.rC_Giving__Giving_Frequency__c = 'Annually';
            mdoc_Tab1.oppty.rC_Giving__Giving_Amount__c = 10;
            mdoc_Tab1.oppty.Cancelled_Date__c = Date.parse('12/12/2020');
            mdoc_Tab1.updateRecords();
            String newOppId = [SELECT Id FROM Opportunity WHERE DFC_Related_Opportunity__c = :oppId][0].Id;
            System.assertNotEquals(Null, newOppId);
            
            ManageDonorOpportunitiesController mdoc_Tab13 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab13.selectedTab = 'Tab1';
            mdoc_Tab13.lstOppWrap[0].isUpdate = true;
            mdoc_Tab13.DF_Type = testCamp.Id;
            mdoc_Tab13.oppty.rC_Giving__Giving_Frequency__c = 'Annually';
            mdoc_Tab13.oppty.rC_Giving__Giving_Amount__c = 45;
            mdoc_Tab13.oppty.Cancelled_Date__c = Date.parse('12/12/2020');
            mdoc_Tab13.oppty.Product_Type__c = 'Designated Fund';
            mdoc_Tab13.oppty.Product_Sub_Type__c = 'Graduation';
            mdoc_Tab13.updateRecords();
            //--------------------------
            
        
        List<Opportunity>  oppList = [SELECT StageName,rC_Giving__Payment_Day__c FROM Opportunity WHERE rC_Giving__Giving_Amount__c=45];
            System.assert(oppList.size()>0);
            System.assertEquals('Open',oppList[0].StageName);
        Test.stopTest();
    } // END private static void test_Method1() {
    
    @isTest
    private static void testingTab1New() {
        setupTestData();
        Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            
            // For Tab 1 functionality
            ManageDonorOpportunitiesController mdoc_Tab1 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab1.selectedTab = 'Tab1';
            mdoc_Tab1.orderByField = 'Name';
            mdoc_Tab1.sortingOrder = 'ASC';
            mdoc_Tab1.lstOppWrap[0].isUpdate = true;
            mdoc_Tab1.DF_Type = testCamp.Id;
            mdoc_Tab1.oppty.rC_Giving__Giving_Frequency__c = '';
            mdoc_Tab1.oppty.rC_Giving__Giving_Amount__c = null;
            mdoc_Tab1.oppty.Cancelled_Date__c = null;
            //mdoc_Tab1.oppty.rC_Giving__Payment_Method_Selected__c = testPayMethod.id;
            mdoc_Tab1.updateRecords();
            List<Opportunity>  oppList = [SELECT id FROM Opportunity WHERE rC_Giving__Giving_Amount__c=null];
            System.assertEquals(ManageDonorOpportunitiesController.errorMessage,'You must enter DF Amount to create new DF Opportunity..');
            System.assertEquals(null, mdoc_Tab1.updateRecords());
            
            Test.stopTest();
        
        
    } // END private static void test_Method1New() {
    
    @isTest
    private static void testingTab2() {
         setupTestData();
         Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc0 = new ManageDonorOpportunitiesController(stdCon0);
            mdoc0.cancel();
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
            System.assertNotEquals(mdoc.lstOppWrap, Null);
            
            List<SelectOption> DF_Types = mdoc.getDF_Types();
            List<SelectOption> SponsorshipChangeReasonDetail = mdoc.getSponsorshipChangeReasonDetail();
            List<SelectOption> DoNotSubs = mdoc.getDoNotSubs();
            mdoc.selectTab();
            mdoc.updateRecords();
            mdoc.lstOppWrap[0].isUpdate = true;
            mdoc.updateRecords();
            mdoc.cancel();
            String oppId = mdoc.lstOppWrap[0].Opp.Id;
            
            // For Tab 2 functionality
            ManageDonorOpportunitiesController mdoc_Tab2 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab2.selectedTab = 'Tab2';
            mdoc_Tab2.selectTab();
            mdoc_Tab2.lstOppWrap[1].isUpdate = true;
            mdoc_Tab2.oppty.rC_Giving__Giving_Amount__c = 25;
            //mdoc_Tab2.oppty.rC_Giving__Payment_Method_Selected__c = testPayMethod.id;
            mdoc_Tab2.oppty.rC_Giving__Giving_Frequency__c = 'Monthly';
            mdoc_Tab2.oppty.Cancelled_Date__c = Date.parse('12/12/2018');
            mdoc_Tab2.oppty.Product_Type__c = 'Designated Fund';
            mdoc_Tab2.oppty.Product_Sub_Type__c = 'Graduation';
            mdoc_Tab2.updateRecords();
            List<Opportunity> oppList = [SELECT rC_Giving__Giving_Amount__c,CloseDate FROM Opportunity WHERE rC_Giving__Giving_Amount__c > 0];
            System.assert(oppList.size() > 0);
            
         Test.stopTest();
    } // END private static void testingTab2() {
    
    @isTest
    private static void testingTab2New() {
         setupTestData();
         Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
           
             // For Tab 2 functionality
            ManageDonorOpportunitiesController mdoc_Tab2 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab2.selectedTab = 'Tab2';
            mdoc_Tab2.selectTab();
            mdoc_Tab2.lstOppWrap[1].isUpdate = true;
            mdoc_Tab2.oppty.rC_Giving__Giving_Amount__c = 25;
            //mdoc_Tab2.oppty.rC_Giving__Payment_Method_Selected__c = testPayMethod.id;
            mdoc_Tab2.oppty.rC_Giving__Giving_Frequency__c = 'One Payment';
            mdoc_Tab2.oppty.Cancelled_Date__c = Date.parse('12/12/2018');
            mdoc_Tab2.oppty.Product_Type__c = 'Designated Fund';
            mdoc_Tab2.oppty.Product_Sub_Type__c = 'Graduation';
            mdoc_Tab2.updateRecords();
            List<Opportunity> oppList = [SELECT rC_Giving__Giving_Amount__c,CloseDate FROM Opportunity WHERE rC_Giving__Giving_Amount__c =25];
            System.debug('OPP List of Tab 2'+oppList.size());
            
         Test.stopTest();
    } // END private static void testingTab2New() {
   
    @isTest
    private static void testingTab3() {
         setupTestData();
         Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc0 = new ManageDonorOpportunitiesController(stdCon0);
            mdoc0.cancel();
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
            System.assertNotEquals(mdoc.lstOppWrap, Null);
            
            List<SelectOption> DF_Types = mdoc.getDF_Types();
            List<SelectOption> SponsorshipChangeReasonDetail = mdoc.getSponsorshipChangeReasonDetail();
            List<SelectOption> DoNotSubs = mdoc.getDoNotSubs();
            mdoc.selectTab();
            mdoc.updateRecords();
            mdoc.lstOppWrap[0].isUpdate = true;
            mdoc.updateRecords();
            mdoc.cancel();
            String oppId = mdoc.lstOppWrap[0].Opp.Id;
            
            // For Tab 3 functionality
            ManageDonorOpportunitiesController mdoc_Tab3 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab3.selectedTab = 'Tab3';
            mdoc_Tab3.selectTab();
            mdoc_Tab3.lstOppWrap[1].isUpdate = true;
            mdoc_Tab3.oppty.CFI_Do_Not_Substitute__c = 'Do Not Substitute';
            mdoc_Tab3.oppty.Do_Not_Sub_Reason__c = 'Auto Upgrade';
            mdoc_Tab3.scrd = 'Age of Child';
            mdoc_Tab3.oppty.Paid_Through_Date__c = Date.parse('12/12/2018');
            mdoc_Tab3.oppty.rC_Giving__Suspended_Start_Date__c = Date.parse('11/11/2017');
            mdoc_Tab3.oppty.rC_Giving__Suspended_End_Date__c = Date.parse('12/12/2017');
            mdoc_Tab3.oppty.Product_Type__c = 'Designated Fund';
            mdoc_Tab3.oppty.Product_Sub_Type__c = 'Graduation';
            mdoc_Tab3.updateRecords();
            
            List<Opportunity> oppList = [SELECT rC_Sponsorship__Sponsorship_Status_Reason__c,StageName,Cancel_Sponsorship__c FROM Opportunity WHERE Product_Type__c = 'Designated Fund'];
            
         Test.stopTest();
    }// END private static void testingTab3() {
    
    @isTest
    private static void testingTab3New() {
         setupTestData();
         Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
           
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
            //System.assertNotEquals(mdoc.lstOppWrap, Null);
            
            List<SelectOption> DF_Types = mdoc.getDF_Types();
            List<SelectOption> SponsorshipChangeReasonDetail = mdoc.getSponsorshipChangeReasonDetail();
            List<SelectOption> DoNotSubs = mdoc.getDoNotSubs();
            mdoc.selectTab();
            mdoc.updateRecords();
            mdoc.lstOppWrap[0].isUpdate = true;
            mdoc.updateRecords();
            mdoc.cancel();
            String oppId = mdoc.lstOppWrap[0].Opp.Id;
            
            // For Tab 3 functionality
            ManageDonorOpportunitiesController mdoc_Tab3 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab3.selectedTab = 'Tab3';
            mdoc_Tab3.selectTab();
           
            mdoc_Tab3.oppty.Paid_Through_Date__c = Date.parse('12/12/2018');
            mdoc_Tab3.oppty.rC_Giving__Suspended_Start_Date__c = Date.parse('11/11/2016');
            mdoc_Tab3.oppty.rC_Giving__Suspended_End_Date__c = Date.parse('12/12/2017');
            Integer dateDifference = mdoc_Tab3.oppty.rC_Giving__Suspended_Start_Date__c.daysBetween(mdoc_Tab3.oppty.rC_Giving__Suspended_End_Date__c);
           System.debug('DateDiffernce is @@@'+dateDifference);
            mdoc_Tab3.updateRecords();
            System.assertEquals(null, mdoc_Tab3.updateRecords());
         Test.stopTest();
    } // END private static void testingTab3New() {
    
    @isTest
    private static void testingTab4() {
         setupTestData();
         Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc0 = new ManageDonorOpportunitiesController(stdCon0);
            mdoc0.cancel();
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
            System.assertNotEquals(mdoc.lstOppWrap, Null);
            
            List<SelectOption> DF_Types = mdoc.getDF_Types();
            List<SelectOption> SponsorshipChangeReasonDetail = mdoc.getSponsorshipChangeReasonDetail();
            List<SelectOption> DoNotSubs = mdoc.getDoNotSubs();
            mdoc.selectTab();
            mdoc.updateRecords();
            mdoc.lstOppWrap[0].isUpdate = true;
            mdoc.updateRecords();
            mdoc.cancel();
            String oppId = mdoc.lstOppWrap[0].Opp.Id;
            
              // For Tab 4 functionality
             
            ApexPages.currentPage().getParameters().put('tab4Amount', '1000');
            ManageDonorOpportunitiesController mdoc_Tab4 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab4.productType = 'Sponsorship';
            mdoc_Tab4.productSubType = 'Child Sponsorship';
            mdoc_Tab4.selectedTab = 'Tab4';
            mdoc_Tab4.selectTab();
            mdoc_Tab4.lstOppWrap[0].isUpdate = true;
            mdoc_Tab4.oppty.CFI_Do_Not_Substitute__c = 'Do Not Substitute';
            mdoc_Tab4.oppty.Do_Not_Sub_Reason__c = 'Retirement';
            mdoc_Tab4.scrd = 'Age of Child';
            //mdoc_Tab4.productType = 'Sponsorship';
            //mdoc_Tab4.productSubType = 'Child Sponsorship';
            mdoc_Tab4.oppty.Paid_Through_Date__c = Date.parse('12/12/2018');
            mdoc_Tab4.oppty.rC_Giving__Suspended_Start_Date__c = Date.parse('11/11/2017');
            mdoc_Tab4.oppty.rC_Giving__Suspended_End_Date__c = Date.parse('12/12/2017');
            mdoc_Tab4.updateRecords();
            //System.assertEquals('Cancellation', Status_Reason);
            // For generating Errors 
            List<Opportunity> oppList =  [SELECT StageName,rC_Giving__Is_Giving__c,rC_Giving__Is_Giving_Transaction__c
                                            FROM Opportunity
                                            WHERE StageName = 'Open'];
            
           // System.assertEquals('Open',oppList[0].StageName);
            //System.assertEquals(true,oppList[0].rC_Giving__Is_Giving__c);
            //System.assertEquals(true,oppList[0].rC_Giving__Is_Giving_Transaction__c);
         Test.stopTest();
    }
    @isTest
    private static void testingTab4New() {
         setupTestData();
         Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc0 = new ManageDonorOpportunitiesController(stdCon0);
            mdoc0.cancel();
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
            System.assertNotEquals(mdoc.lstOppWrap, Null);
            
            List<SelectOption> DF_Types = mdoc.getDF_Types();
            List<SelectOption> SponsorshipChangeReasonDetail = mdoc.getSponsorshipChangeReasonDetail();
            List<SelectOption> DoNotSubs = mdoc.getDoNotSubs();
            mdoc.selectTab();
            mdoc.updateRecords();
            mdoc.lstOppWrap[0].isUpdate = true;
            mdoc.updateRecords();
            mdoc.cancel();
            String oppId = mdoc.lstOppWrap[0].Opp.Id;
            
              // For Tab 4 functionality
             
            ApexPages.currentPage().getParameters().put('tab4Amount', '1000');
            ManageDonorOpportunitiesController mdoc_Tab4 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab4.productType = 'None';
            mdoc_Tab4.productSubType = 'None';
            mdoc_Tab4.selectedTab = 'Tab4';
            mdoc_Tab4.paymentMethod = 'EFT';
            mdoc_Tab4.selectTab();
            mdoc_Tab4.lstOppWrap[0].isUpdate = true;
            mdoc_Tab4.oppty.CFI_Do_Not_Substitute__c = 'Do Not Substitute';
            mdoc_Tab4.oppty.Do_Not_Sub_Reason__c = 'Auto Upgrade';
            mdoc_Tab4.scrd = 'Age of Child';
            //mdoc_Tab4.productType = 'Sponsorship';
            //mdoc_Tab4.productSubType = 'Child Sponsorship';
            mdoc_Tab4.oppty.Paid_Through_Date__c = Date.parse('12/12/2018');
            mdoc_Tab4.oppty.rC_Giving__Suspended_Start_Date__c = Date.parse('11/11/2017');
            mdoc_Tab4.oppty.rC_Giving__Suspended_End_Date__c = Date.parse('12/12/2017');
            mdoc_Tab4.updateRecords();
            mdoc_Tab4.productType = 'Recurring Gift';
            mdoc_Tab4.updateRecords();
            
            mdoc_Tab4.productType = 'One Time Gift';
            mdoc_Tab4.updateRecords();
         Test.stopTest();
    }
    @isTest
    private static void testingTab5() {
         setupTestData();
         Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc0 = new ManageDonorOpportunitiesController(stdCon0);
            mdoc0.cancel();
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
            System.assertNotEquals(mdoc.lstOppWrap, Null);
            
            List<SelectOption> DF_Types = mdoc.getDF_Types();
            List<SelectOption> SponsorshipChangeReasonDetail = mdoc.getSponsorshipChangeReasonDetail();
            List<SelectOption> DoNotSubs = mdoc.getDoNotSubs();
            mdoc.selectTab();
            mdoc.updateRecords();
            mdoc.lstOppWrap[0].isUpdate = true;
            mdoc.updateRecords();
            mdoc.cancel();
            String oppId = mdoc.lstOppWrap[0].Opp.Id;
            
              ManageDonorOpportunitiesController mdoc_Tab5 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab5.selectedTab = 'Tab5';
            mdoc_Tab5.selectTab();
            mdoc_Tab5.lstOppWrap[0].isUpdate = true;
            mdoc_Tab5.oppty.CFI_Do_Not_Substitute__c = 'Do Not Substitute';
            mdoc_Tab5.oppty.Do_Not_Sub_Reason__c = 'Auto Upgrade';
            mdoc_Tab5.scrd = 'Age of Child';
            mdoc_Tab5.oppty.Product_Type__c = 'Designated Fund';
            mdoc_Tab5.oppty.Product_Sub_Type__c = 'Belated Christmas';
            mdoc_Tab5.oppty.Paid_Through_Date__c = Date.parse('12/12/2018');
            mdoc_Tab5.oppty.rC_Giving__Suspended_Start_Date__c = Date.parse('11/11/2017');
            mdoc_Tab5.oppty.rC_Giving__Suspended_End_Date__c = Date.parse('12/12/2017');
            mdoc_Tab5.updateRecords();
            //List<Opportunity> oppList =  [SELECT StageName,rC_Giving__Is_Giving__c,Product_Type__c
            //                                FROM Opportunity 
            //                                WHERE Product_Sub_Type__c = 'Belated Christmas'];
            List<Opportunity> oppList =  [SELECT rC_Giving__Is_Sustainer__c
                                            FROM Opportunity 
                                            WHERE Auto_Assign_Participant__c = 'Direct Sponsorship'
                                            OR Auto_Assign_Participant__c = 'New Assignment'];                                
                                            
            //System.assert(oppList.size() > 0);
            //System.assert(oppList[0].rC_Giving__Is_Sustainer__c);
            //System.assertEquals(oppList[0].StageName,'Open');
            //System.assertEquals(oppList[0].rC_Giving__Is_Giving__c,true);
            //System.assertEquals(oppList[0].Product_Type__c,'Sponsorship');
         Test.stopTest();
    }
    @isTest
    private static void testingTab5New() {
         setupTestData();
         Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
           
            
            List<SelectOption> DF_Types = mdoc.getDF_Types();
            List<SelectOption> SponsorshipChangeReasonDetail = mdoc.getSponsorshipChangeReasonDetail();
            List<SelectOption> DoNotSubs = mdoc.getDoNotSubs();
            mdoc.selectTab();
            mdoc.updateRecords();
            mdoc.lstOppWrap[0].isUpdate = true;
            mdoc.updateRecords();
            mdoc.cancel();
            String oppId = mdoc.lstOppWrap[0].Opp.Id;
            
            ManageDonorOpportunitiesController mdoc_Tab5 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab5.oppty.Participant__c = conHousehold.id;
            mdoc_Tab5.updateRecords();
            
         Test.stopTest();
    }
    @isTest
    private static void testingTab6AndOtherFunctions() {
         setupTestData();
         Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.ManageDonorOpportunities);
            ApexPages.StandardController stdCon0 = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc0 = new ManageDonorOpportunitiesController(stdCon0);
            mdoc0.cancel();
            
            ApexPages.currentPage().getParameters().put('id', conHousehold.Id);
            // calling standard set controller 
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
            ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
            System.assertNotEquals(mdoc.lstOppWrap, Null);
            
            List<SelectOption> DF_Types = mdoc.getDF_Types();
            List<SelectOption> SponsorshipChangeReasonDetail = mdoc.getSponsorshipChangeReasonDetail();
            List<SelectOption> DoNotSubs = mdoc.getDoNotSubs();
            mdoc.selectTab();
            mdoc.updateRecords();
            mdoc.lstOppWrap[0].isUpdate = true;
            mdoc.updateRecords();
            mdoc.cancel();
            String oppId = mdoc.lstOppWrap[0].Opp.Id;
            
              ManageDonorOpportunitiesController mdoc_Tab6 = new ManageDonorOpportunitiesController(stdCon);
            mdoc_Tab6.selectedTab = 'Tab6';
            mdoc_Tab6.selectTab();
            mdoc_Tab6.lstOppWrapSchedulePmnt[0].isUpdate = true;
            mdoc_Tab6.oppty.CFI_Do_Not_Substitute__c = 'Do Not Substitute';
            mdoc_Tab6.oppty.Do_Not_Sub_Reason__c = 'Auto Upgrade';
            mdoc_Tab6.scrd = 'Age of Child';
            mdoc_Tab6.oppty.Product_Type__c = 'Sponsorship';
            mdoc_Tab6.oppty.Product_Sub_Type__c = 'Child Sponsorship';
            mdoc_Tab6.oppty.Paid_Through_Date__c = Date.parse('12/12/2018');
            mdoc_Tab6.oppty.rC_Giving__Suspended_Start_Date__c = Date.parse('11/11/2017');
            mdoc_Tab6.oppty.rC_Giving__Suspended_End_Date__c = Date.parse('12/12/2017');
            mdoc_Tab6.updateRecords();
            
            mdoc_Tab6.getReleaseMonth('30 - Birthday' , System.today().addDays(-5000));
            System.assertEquals(10,mdoc_Tab6.getReleaseMonth('31 - Christmas' , System.today().addDays(-5000)));
            System.assertEquals(12,mdoc_Tab6.getReleaseMonth('42 - Valentines' , System.today().addDays(-5000)));
            System.assertEquals(9,mdoc_Tab6.getReleaseMonth('74 - Thanksgiving' , System.today().addDays(-5000)));
            mdoc_Tab6.getReleaseMonth('32 - Easter' , System.today().addDays(-5000));
            mdoc_Tab6.getReleaseMonth('33 - Easter' , System.today().addDays(-5000));
            
            mdoc_Tab6.getPaymentMethods();
            mdoc_Tab6.getProductTypes();
            mdoc_Tab6.productType = 'Recurring Gift';
            mdoc_Tab6.showproductSubtype();
            mdoc_Tab6.productType = 'One Time Gift';
            mdoc_Tab6.showproductSubtype();
            
            List<Opportunity> oppList = [SELECT CloseDate FROM Opportunity WHERE CloseDate != null];
            System.assert(oppList.size() > 1);
         Test.stopTest();
    }
    
    @isTest
    private static void testConstructor() {
        setupTestData();
        Test.startTest();
        ManageDonorOpportunitiesController manageObj = new ManageDonorOpportunitiesController();
        Test.setCurrentPage(Page.ManageDonorOpportunities);
        
        
        ApexPages.currentPage().getParameters().put('id', conPP.Id);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(conPP);
        ManageDonorOpportunitiesController mdoc = new ManageDonorOpportunitiesController(stdCon);
        System.debug('Ashu>> COntact PP'+conPP+ 'recordType'+conPP.recordType);
        
        
        Test.stopTest();
    }
    
    @isTest
    private static void testTString() {
       
         Test.startTest();
         
            TStringUtils.TPicklistEntry obj = new TStringUtils.TPicklistEntry();
            obj.active='testA';
            obj.defaultValue = 'testB';
            obj.value = 'testValue';
         Test.stopTest();
    }
    
    private static void setupTestData() {
        
        /*rC_Giving__Contact_Setting__c setting = new rC_Giving__Contact_Setting__c();
            setting.rC_Giving__Disable_RollupHardCredits__c = true;
            upsert setting;*/
            
            rC_Giving__Contact_Setting__c cust_st = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
       cust_st.rC_Giving__Disable_RollupHardCredits__c = true; 
       upsert cust_st ; 
            
        nationalOffice = TestUtils.createAccount('National Office', false);
        //nationalOffice.Name = 'National Office';
        nationalOffice.RecordTypeId = ACC_NO_RT;
        nationalOffice.National_Office_Id__c = '899';
        insert nationalOffice;
        
        localPartner = TestUtils.createAccount('Local Partner', false);
        //localPartner.Name = 'Local Partner';
        localPartner.RecordTypeId = ACC_LP_RT;
        localPartner.ParentId = nationalOffice.Id;
        localPartner.Local_Partner_ID__c = '1234567';
        insert localPartner;
        
        community = TestUtils.createAccount('Community', false);
        //community.Name = 'Community';
        community.RecordTypeId = ACC_COM_RT;
        community.ParentId = localPartner.Id;
        community.Community_Id__c = '3436';
        insert community;
        rC_Giving__GAU__c testGAU = TestUtils.createGeneralAccountingUnit('600',true);
        
        household = TestUtils.createAccount('Household', false);
        //household.Name = 'Household';
        household.RecordTypeId = ACC_HH_RT;
        household.ParentId = community.Id;
        insert household;
        
        acc = TestUtils.createAccount('test',true);
        
        testCamp = TestUtils.createCampaign('718 - DFC Fee', false);
        testCamp.Product_Type__c = 'One Time Gift';
        testCamp.Product_Sub_Type__c = 'DFC Fee';
        insert testCamp;
        
       // creating contact record
        conHousehold = TestUtils.createContact(household, 'Rohit', 'B', false);
        conHousehold.Community__c = community.id;
        conHousehold.RecordTypeId = CON_HH_RT;
        conHousehold.Participant_Case_Number__c = '87754';
        conHousehold.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        insert conHousehold;
        
        con1 = TestUtils.createContact(household, 'Rohit', 'B', false);
        con1.Community__c = community.id;
        con1.RecordTypeId = CON_HH_RT;
        con1.Participant_Case_Number__c = '87754';
        con1.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        insert con1;
        
        conPP = TestUtils.createContact(acc, 'Ashu', 'Gupta', false);
        conPP.Community__c = community.id;
        conPP.RecordTypeId = CON_PP_RT;
        conPP.Participant_Case_Number__c = '87754';
        conPP.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        insert conPP;
        
        Campaign camp = TestUtils.createCampaign('TestCamp1',false);
        camp.Product_Type__c = 'Designated Fund';
        camp.Product_Sub_Type__c = 'Child Sponsorship';
        insert camp;
        
        
        List<Opportunity> lstOppToInsert = new List<Opportunity>();
        
        Opportunity donationOpp = TestUtils.createOpportunity(nationalOffice, 'Test Donation Opp ', 100000, false);
        //donationOpp.RecordTypeId = OPP_DON_RT;
        donationOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        donationOpp.Campaign = camp;
        donationOpp.Product_Type__c = 'Designated Fund';
        donationOpp.Product_Sub_Type__c = 'Graduation';
        donationOpp.Description__c = 'test Description';
        insert donationOpp;
        
        
        Opportunity opp = TestUtils.createOpportunity(community,'Test Opportunity1',100,false);
        opp.RecordTypeId = OPP_DON_RT;
        opp.rC_Giving__Projected_Amount__c = 100;
        opp.CloseDate = Date.Today().addMonths(2);
        opp.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opp.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opp.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opp.rC_Giving__Hard_Credit_Contact__c = conHousehold.Id;
        opp.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opp.Core_Program_Infants__c = true;
        opp.Date_of_Distribution__c = system.today().addDays(-150);
        opp.rC_Giving__Parent__c = donationOpp.Id;
        opp.Remaining_Non_Adjusted__c = 10;
        opp.Participant__c = con1.Id;
        opp.rC_Giving__Hard_Credit_Contact__c = conHousehold.Id;
        opp.rC_Giving__Primary_Contact__c = conHousehold.Id;
        opp.rC_Giving__Is_Sustainer__c = true; // required for new validation rule | Sponsorships_must_be_Sustainers
        //lstOppToInsert.add(opp);
        opp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        insert opp;
        
       /* opp = [SELECT Id, Name, AccountId, RecordTypeId, Participant__c,
                                            rC_Giving__Primary_Contact__c, rC_Giving__Hard_Credit_Contact__c, Monthly_Standard_Pay__c,  
                                            rC_Giving__Giving_Frequency__c, rC_Giving__Giving_Amount__c, Participant__r.BirthDate, 
                                            CampaignId, Campaign.Name, Campaign.Product_Type__c, rC_Giving__Payment_Day__c, Campaign.Product_Sub_Type__c   
                                            FROM Opportunity WHERE Id =:opp.Id];
        System.debug('==opp=='+opp);
        */
        Opportunity opp2 = TestUtils.createOpportunity(community,'Test Opportunity2',100,false);
        opp2.RecordTypeId = OPP_DON_RT;
        opp2.rC_Giving__Projected_Amount__c = 101;
        
        opp2.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opp2.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opp2.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opp2.rC_Giving__Hard_Credit_Contact__c = conHousehold.Id;
        opp2.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opp2.Core_Program_Infants__c = true;
        opp2.Date_of_Distribution__c = system.today().addDays(-150);
        opp2.rC_Giving__Parent__c = donationOpp.Id;
        opp2.Remaining_Non_Adjusted__c = 10;
        opp2.Participant__c = con1.Id;
        opp2.rC_Giving__Is_Sustainer__c = true; // required for new validation rule | Sponsorships_must_be_Sustainers
        opp2.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        lstOppToInsert.add(opp2);
        
        Opportunity opp3 = TestUtils.createOpportunity(community,'Test Opportunity3',100,false);
        opp3.RecordTypeId = OPP_DON_RT;
        opp3.rC_Giving__Projected_Amount__c = 101;
        opp3.StageName = 'Partially Complete';
        opp3.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opp3.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opp3.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opp3.rC_Giving__Hard_Credit_Contact__c = conHousehold.Id;
        opp3.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opp3.Core_Program_Infants__c = true;
        opp3.Date_of_Distribution__c = system.today().addDays(-150);
        opp3.rC_Giving__Parent__c = donationOpp.Id;
        opp3.Remaining_Non_Adjusted__c = 10;
        opp3.Participant__c = con1.Id;
        opp3.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        opp3.rC_Giving__Is_Sustainer__c = true; // required for new validation rule | Sponsorships_must_be_Sustainers
        lstOppToInsert.add(opp3);
        /*opp2 = [SELECT Id, Name, AccountId, RecordTypeId, Participant__c,
                                            rC_Giving__Primary_Contact__c, rC_Giving__Hard_Credit_Contact__c, Monthly_Standard_Pay__c,  
                                            rC_Giving__Giving_Frequency__c, rC_Giving__Giving_Amount__c, Participant__r.BirthDate, 
                                            CampaignId, Campaign.Name, Campaign.Product_Type__c, rC_Giving__Payment_Day__c, Campaign.Product_Sub_Type__c   
                                            FROM Opportunity WHERE Id =:opp2.Id];
        System.debug('==opp2=='+opp2.participant__c);
        */
         Opportunity donationOpp1 = TestUtils.createOpportunity(nationalOffice, 'Test Donation Opp1 ', 100001, false);
        //donationOpp.RecordTypeId = OPP_DON_RT;
        donationOpp1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        donationOpp1.Campaign = camp;
        donationOpp1.Product_Type__c = 'Designated Fund';
        donationOpp1.Product_Sub_Type__c = 'Graduation';
        donationOpp1.Description__c = 'test Description';
        donationOpp1.DFC_Related_Opportunity__c = opp.Id;
        insert donationOpp1;

        Opportunity transactionOpp = TestUtils.createOpportunity(household, 'transaction opp', 100, false);
        transactionOpp.RecordTypeId = OPP_TR_RT;
        transactionOpp.rC_Giving__Hard_Credit_Contact__c = conHousehold.Id;
        lstOppToInsert.add(transactionOpp);
        
        insert  lstOppToInsert;
        //lstOppToInsert.add(donationOpp);
        
        testPayMethod = TestUtils.createPaymentMethod('Test Payment','Paypal',true,acc,false);
        testPayMethod.RecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Paypal').getRecordTypeId();
        testPayMethod.rC_Giving__Billing_State__c = 'test';
        testPayMethod.rC_Connect__Merchant_Name__c = 'IATS';
        insert testPayMethod;
        
    } // END private static setupTestData() {
}