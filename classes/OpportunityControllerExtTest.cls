/***********************************************************************************************************
* Appirio, Inc
* Name         : OpportunityControllerExtTest
* Created By   : Vaibhav Goel (Appirio)
* Purpose      : Test class for the OpportunityControllerExt
* Created Date : 27/07/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 28/07/2016                   Vaibhav Goel             Created
* 08/17/2016                   Ashu Gupta              Created test data using TestUtils class
**********************************************************************************************************/@isTest
private class OpportunityControllerExtTest {
    
    
    private static Contact con, kid, participant;
    private static Account acc;
    private static Opportunity parentOpportunity,oppNew;
    static final string DESIGNATED_FUND = 'Designated Fund';
    static final string AS_INSTRUCTED = 'As Instructed';
    static final string RT_CON_HHOLD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    static final string RT_CON_PART = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    static final string RT_OPP_DONAT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    
    
    private static testMethod void testingController1() {
        
        createTestData();
        test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppNew);
        OpportunityControllerExt contInstance = new OpportunityControllerExt(sc);  
        PageReference savePageRefResult = contInstance.save();
        system.assertEquals(savePageRefResult, null);
        RecordType recType = SObjectServices.getRecordType(Constants.PROJECT_REC_TYPE_SINGLE_NO, Constants.PROJECT_SOBJECT_TYPE);
        system.assertEquals(recType.id,contInstance.projModel.project.RecordTypeId);
        test.stopTest();
        
    }
    
    private static testMethod void testingController2() {
        
        test.startTest();
        ApexPages.Message[] pageMessages;
        oppNew = new Opportunity();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppNew);
        OpportunityControllerExt contInstance = new OpportunityControllerExt(sc); 
        system.assertEquals(contInstance.isError, true);
        pageMessages = ApexPages.getMessages();
        System.assertEquals(pageMessages[0].getSummary().contains('Invalid invocation. Go to the Opportunity detail page and click \'Create Project\''), true);
        test.stopTest();
        
    }
    
    private static void createTestData(){
        acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        insert acc;
        
        
        List<Contact> conList = new List<Contact>();
        con = TestUtils.createContact(acc, 'Unit test 1', 'Apex 1', false);
        con.RecordTypeId = RT_CON_HHOLD;
        con.Correspondence_Paused__c = false;
        con.Donor_Flag__c = 'Black';
        con.Flag_Comments__c = 'test comment';
        conList.add(con);
        
        
        kid = TestUtils.createContact(acc, 'Good', 'Kid', false);
        kid.RecordTypeId = RT_CON_PART;
        kid.Participant_Case_Number__c = '12345';
        kid.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        kid.rC_Giving__Track_Hard_Credits__c = true;
        conList.add(kid);
        
        
        insert conList;
        
        Campaign testCamp = TestUtils.createCampaign('test camp',false);
        testCamp.Product_Type__c = 'Designated Fund';
        testCamp.Product_Sub_Type__c = 'Belated Christmas';
        insert testCamp;
        
        
        
        oppNew = TestUtils.createOpportunity(acc, 'testOpportunity',100,false);
        oppNew.recordTypeId  = RT_OPP_DONAT;
        oppNew.Participant__c = kid.Id;
        oppNew.CampaignId = testCamp.Id;
        oppNew.Product_Type__c = DESIGNATED_FUND;
        oppNew.Product_Sub_Type__c = AS_INSTRUCTED;
        oppNew.rC_Giving__Primary_Contact__c = con.Id;
        oppNew.rC_Sponsorship__Substitute_Contact__c = kid.Id;
        insert oppNew;
        
        
        
        
    }
}