/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MCSScanCloseTest 
 * Created By   : Rohit B (Appirio)
 * Purpose      : Test class of MCSScanClose controller class
 * Created Date : 09/Dec/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/10/2016                   Ashu Gupta(Appirio)     Increased code coverage    
 **********************************************************************************************************/
@isTest
private class MCSScanCloseTest {
    static Mail_Control_Slip__c mcs,mcsWithOpp;
    static Opportunity opp;
    @isTest 
    static void test_scan() {
        createTestData();
        Test.setCurrentPage(Page.MCSScanClosePage);
        
        List<Mail_Control_Slip__c> lstMCS = [SELECT Id, Name, MCS_Status__c FROM Mail_Control_Slip__c WHERE Id =: mcs.Id];                                                       
        
        System.Debug('mcsActiveName : ' + lstMCS[0].Name);                                                    

        Test.startTest();
            ApexPages.Message[] pageMessages;

            MCSScanClose mcsSC = new MCSScanClose();
            mcsSC.scan();
            pageMessages = ApexPages.getMessages();
            System.debug('PageMessage 0 : ' + pageMessages[0].getSummary());
            System.assertEquals(pageMessages[0].getSummary().contains('MCS code does not exist in database'), true);
            
            mcsSC.MCS_id = lstMCS[0].Name;
            mcsSC.scan();
            pageMessages = ApexPages.getMessages();
            System.debug('PageMessage 1 : ' + pageMessages[1].getSummary());
            System.assertEquals(pageMessages[1].getSummary().contains('MCS Successfully Closed'), true);

            mcs.MCS_Status__c = 'Closed';
            update mcs;

            mcsSC.scan();
            pageMessages = ApexPages.getMessages();
            System.debug('PageMessage 2 : ' + pageMessages[2].getSummary());
            System.assertEquals(pageMessages[2].getSummary().contains('MCS code has already been closed'), true);

            mcs.MCS_Status__c = 'Cancel';
            update mcs;

            mcsSC.scan();
            pageMessages = ApexPages.getMessages();
            System.debug('PageMessage 3 : ' + pageMessages[3].getSummary());
            System.assertEquals(pageMessages[3].getSummary().contains('MCS code has already been cancelled'), true);
        Test.stopTest();
    } // END static void test_method() {
    
   @isTest  static void test_scanWithOpp() {
        createTestData();
        Test.setCurrentPage(Page.MCSScanClosePage);
        
        List<Mail_Control_Slip__c> lstMCS = [SELECT Id, Name, MCS_Status__c FROM Mail_Control_Slip__c WHERE Id =: mcsWithOpp.Id];
        Test.startTest();
        MCSScanClose mcsSC = new MCSScanClose();
        mcsSC.MCS_id = lstMCS[0].name ;
        mcsSC.scan();
        Opportunity oppAfterUpdate = [SELECT id,dfc_status__c FROM Opportunity WHERE id =:opp.id];
        System.assertEquals(oppAfterUpdate.dfc_status__c,'Received by Child');
        test.stopTest();
        
    }
    static void createTestData(){
        Account acc = TestUtils.createAccount('testAccount', true);
        Contact participant = TestUtils.createContact(acc, 'testParticipant_First', 'testParticipant_Last', false);
        participant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        participant.National_Office__c = [SELECT National_Office__c FROM User WHERE Id =: UserInfo.getUserId()][0].National_Office__c;
        insert participant;
        Contact donor = TestUtils.createContact(acc, 'testDonor_First', 'testDonor_Last', true);
        mcs = TestUtils.createMailControlSlip(donor.Id, 'Child Welcome Letter', 'Active', 
                                                                    Null, 'Email', true);
        
        rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('600',true);
        
        campaign testCamp = TestUtils.createCampaign('Test Campaign',false);
        testCamp.Product_Type__c = 'Designated Fund';
        testCamp.Product_Sub_Type__c = 'Belated Christmas';
        insert testCamp;
         Id oppTransRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Opportunity parentOpp = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
    	parentOpp.recordTypeId  = oppTransRecTypeId;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.Product_Type__c = 'Designated Fund';
        parentOpp.Product_Sub_Type__c = 'Child Sponsorship';
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.rC_Giving__GAU__c = gau.Id;
        insert parentOpp;
        
        
        opp = TestUtils.createOpportunity(acc,'testopp',100,false);
        opp.rC_Giving__Parent__c = parentOpp.Id;
        opp.dfc_status__c = 'Pending';
        insert opp;
        mcsWithOpp = TestUtils.createMailControlSlip(donor.Id, 'Child Welcome Letter', 'Active', 
                                                                    Null, 'Email', false);
        mcsWithOpp.DFC_Opportunity__c = opp.id;
        insert mcsWithOpp;
                                                    
    }
} // END private class MCSScanCloseTest {