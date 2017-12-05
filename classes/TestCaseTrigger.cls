/**
 * TestCaseTrigger: Unit Test for testing on CaseTrigger
 *
 * Ver No.     Developer/Org                 Date         Changes
 * -----------------------------------------------------------------------------
 *   1.0       Charlie Xie/Bluewolf          02/10/2014    Created
 */  
@isTest
private class TestCaseTrigger {

    private static Contact testcontact;
    private static Account testacc;
    
    static void setup(){
        testacc = TestUtils.createAccount('Test Account for Case Wizard', true);
        testcontact = TestUtils.createContact(testacc, 'Dwight', 'Schrute', true);
    }

    @isTest static void testSetTargetSLATimes(){
        setup();
        Id masterRtId = TestUtils.getRecordTypeId('X0_Master_Case','Case');
        Test.startTest();
        Case testCase = TestUtils.createCase(masterRtId, 'Open', 'Standard','CS1',false);
        testCase.Response_Business_Hours__c =24;
        try{
            testCase.ContactId = testcontact.Id;
            insert testCase;
        }catch(DmlException de){
            System.debug(de);
        }

        Case insertedCase = [SELECT Id,Resolution_Business_Hours__c,Target_Response_Time__c,Target_Resolution_Time__c FROM Case WHERE Id =:testCase.Id];
        System.debug('@@ insertedCase.Target_Response_Time__c='+insertedCase.Target_Response_Time__c);
        System.debug('@@ insertedCase.Target_Resolution_Time__c='+insertedCase.Target_Resolution_Time__c);
        //Once the Response_Business_Hours__c is set, CaseTrigger will generate a Target_Response_Time__c
       // System.assertNotEquals(null,insertedCase.Target_Response_Time__c);
        //System.assertEquals(null,insertedCase.Target_Resolution_Time__c);
        /*
        * Once the Resolution_Business_Hours__c is set, CaseTrigger will generate a Target_Resolution_Time__c, 
        * while the Target_Response_Time__c will be clear out by a workflow rule.
        */
        insertedCase.Resolution_Business_Hours__c = 10;
        update insertedCase;
        insertedCase = [SELECT Id,Target_Response_Time__c,Target_Resolution_Time__c FROM Case WHERE Id =:testCase.Id];
       // System.assertEquals(null,insertedCase.Target_Response_Time__c);
       // System.assertNotEquals(null,insertedCase.Target_Resolution_Time__c);
        Test.stopTest();
    }

    @isTest static void testUpdateParentCaseWithStatus(){
        setup();
        Id masterRtId = TestUtils.getRecordTypeId('X0_Master_Case','Case');
        Id standardRtId = TestUtils.getRecordTypeId('X2_Routed_Case','Case');
        System.debug('@@ RecordType Id = '+masterRtId);
        //create a masterCase for testing
        Case masterCase = TestUtils.createCase(masterRtId, 'Open', 'Standard','CS1',false);
        masterCase.ContactId = testcontact.Id;
        insert masterCase;
        masterCase = [SELECT Id, status FROM Case WHERE Id =: masterCase.Id];
        System.debug('@@ masterCase status = '+masterCase.status);  
        //create childCases for testing
        List<Case> childCasesToInsert = new List<Case>();
        Case childCase1 = TestUtils.createCase(standardRtId, 'New', 'Standard','CS1',false);
        Case childCase2 = TestUtils.createCase(standardRtId, 'New', 'Standard','CS1',false);    
        childCase1.Master_Case__c = masterCase.Id;
        childCase2.Master_Case__c = masterCase.Id;
        childCase1.ContactId = testcontact.Id;
        childCase2.ContactId = testcontact.Id;
        childCasesToInsert.add(childCase1);
        childCasesToInsert.add(childCase2);
        insert childCasesToInsert;
        Test.startTest();
        childCase1 = [SELECT Id, status, Master_Case__c FROM Case WHERE Id =: childCase1.Id];
        System.debug('@@ childCase1 status = '+childCase1.status);      
        System.debug('@@ childCase1 Parent = '+childCase1.Master_Case__c);      
        childCase1.status = 'Marked Complete';
        //update the child case1 to fire the update trigger 
        update childCase1;
        childCase1 = [SELECT Id, status FROM Case WHERE Id =: childCase1.Id];
        System.debug('@@ childCase1 status = '+childCase1.status);  
        masterCase = [SELECT Id, status FROM Case WHERE Id =: masterCase.Id];
        System.debug('@@ masterCase status = '+masterCase.status);  

        childCase2 = [SELECT Id, status, Master_Case__c FROM Case WHERE Id =: childCase2.Id];
        System.debug('@@ childCase2 status = '+childCase2.status);      
        System.debug('@@ childCase2 Parent = '+childCase2.Master_Case__c);      
        childCase2.status = 'Marked Complete';
        //update the child case1 to fire the update trigger
        update childCase2;
        childCase2 = [SELECT Id, status FROM Case WHERE Id =: childCase2.Id];
        System.debug('@@ childCase2 status = '+childCase2.status);  
        masterCase = [SELECT Id, status FROM Case WHERE Id =: masterCase.Id];
        System.debug('@@ masterCase status = '+masterCase.status);  
        //since all its children cases are on 'Marked Complete' status, the masterCase should be on 'Closed' status.
        System.assertEquals('Closed', masterCase.status);   

        //Test Use Case: Update status of master case to 'In progress' from 'Closed', if one of its child cases status was changed from isClosed==true to isClosed==false
        childCase2.status = 'In Progress';
        update childCase2;
        masterCase = [SELECT Id, status FROM Case WHERE Id =: masterCase.Id];
        System.debug('@@ masterCase status = '+masterCase.status);  
        System.assertEquals('In Progress', masterCase.status);  
        Test.stopTest();
    }

    @isTest static void testInsertCaseToClosedCase()
    {
        setup();
        //Get recordType Id of Master and Standard Case
        List<RecordType> masterRtLst = [SELECT Id FROM RecordType WHERE DeveloperName = 'X0_Master_Case' AND SobjectType='Case'];
        List<RecordType> standardCaseRtLst = [SELECT Id FROM RecordType WHERE DeveloperName = 'X2_Routed_Case' AND SobjectType='Case'];
        System.debug('@@@ masterRtLst size '+masterRtLst.size());
        RecordType masterRt = masterRtLst[0];
        RecordType standardRt = standardCaseRtLst[0];
        System.debug('@@@ RecordType Id = '+masterRt.Id);
        //create a masterCase for testing
        Case masterCase = new Case(RecordType=masterRt, Status = 'Closed', Agent_Skill__c='CS1', Priority='Standard', Priority_Reason__c='TestCase0',Response_Business_Hours__c =24);
        try{
            masterCase.ContactId = testcontact.Id;
            insert masterCase;
        }catch(DmlException de){
            System.debug(de);
        }

        masterCase = [SELECT Id, status FROM Case WHERE Id =: masterCase.Id];
        System.debug('@@@ masterCase status = '+masterCase.status); 
        //create childCase for testing
        List<Case> childCasesToInsert = new List<Case>();
        Case childCase = new Case(RecordType=standardRt, Master_Case__c=masterCase.Id, Agent_Skill__c='CS1', Priority='Standard', Priority_Reason__c='TestCase1',Response_Business_Hours__c =24);
        childCase.ContactId = testcontact.Id;
        childCasesToInsert.add(childCase);

        Test.startTest();
        //Test to make sure the master case is closed
        System.assertEquals('Closed', masterCase.status);
        //insert the test child case
        try{
            //childCasesToInsert.ContactId = testcontact.Id;
            insert childCasesToInsert;
        }catch(DmlException de){
            System.debug(de);
        }
        //update the master case
        masterCase = [SELECT Id, status FROM Case WHERE Id =: masterCase.Id];
        //Print the updated master case status
        System.debug('@@@ masterCase status = ' + masterCase.status);
        //Test the master case status
        System.assertEquals('In Progress', masterCase.status);
        Test.stopTest();
    }
    
    static testMethod void testUpdateCaseWithAccount(){
        setup();
        Account acc = TestUtils.createAccount('Test Account for Case Trigger', true);
        Contact contact = TestUtils.createContact(acc, 'Dwight', 'Schrute', true);
        List<Case> cases = new List<Case>();
        Id recTypeId = TestUtils.getRecordTypeId('X2_Routed_Case', 'Case');
        for(Integer i=0; i<200; i++){
            Case c = TestUtils.createCase(recTypeId, 'Open', 'Standard', 'CS1', false);
            c.ContactId = contact.Id;
            cases.add(c);
        }       
        insert cases;
        
        for(Case c : [SELECT AccountId FROM Case WHERE Id IN : cases]){
            System.assertEquals(acc.Id, c.AccountId);
        }
    }    
    
    static testMethod void testValidateMasterCase(){
        setup();
        Account acc = TestUtils.createAccount('Test Account for Case Trigger', true);
        Contact contact = TestUtils.createContact(acc, 'Dwight', 'Schrute', true);
        Case masterCase = TestUtils.createCase(TestUtils.getRecordTypeId('X0_Master_Case', 'Case'), 'Open', 'Normal', 'CS1', false);
        try{
            masterCase.ContactId = testcontact.Id;
            insert masterCase;
        }catch(DmlException de){
            System.debug(de);
        }

        List<Case> cases = new List<Case>();
        Id recTypeId = TestUtils.getRecordTypeId('X2_Routed_Case', 'Case');
        for(Integer i=0; i<5; i++){
            Case c = TestUtils.createCase(recTypeId, 'Marked Complete', 'Standard', 'CS1', false);
            c.ContactId = contact.Id;
            c.Master_Case__c = masterCase.Id;
            cases.add(c);
        }
        cases.get(0).Status = 'Open';       
        insert cases;
        
        masterCase.Status = 'Closed';
        try{
            update masterCase;
        }catch(Exception e){
            
        }
        
        masterCase = [SELECT Status FROM Case WHERE Id =: masterCase.Id];
        System.assertNotEquals('Closed', masterCase.Status);
        
        cases.get(0).Status = 'Marked Complete';
        update cases.get(0);
        
        masterCase.Status = 'Closed';
        try{
            update masterCase;
        }catch(Exception e){
            
        }
        
        masterCase = [SELECT Status FROM Case WHERE Id =: masterCase.Id];
        System.assertEquals('Closed', masterCase.Status);
         
    }
    
}