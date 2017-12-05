/**
 * TestCommandCenterCtr: This class provides test methods for CommandCenterCtr.class
 * 
 * Ver No.     Developer/Org                 Date         Changes
 * -----------------------------------------------------------------------------
 *   1.0       Charlie Xie/Bluewolf          02/03/2014    Created
 *              Ashu Gupta                  08/10/2016      Implemented coding standards
 */  
@isTest
public with sharing class TestCommandCenterCtr {
    
    private static final Id MastercaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('0 - Master Case').getRecordTypeId();
    private static final Id Acc_HH_RT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    static User rep,agent1,agent2,agent3;
    static List<Case> caseToInsert;
    static Case case1,case2,case3,case4;
    static Group q;
    
    static void createTestData(){
        
        Profile agentProf = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> userLst = new List<User>();
        //create a customer representative as cases creator.
        rep = TestUtils.createUser('rep','rep',agentProf.Id,false);
        
        userLst.add(rep);   
        //Create agent users: agent1 with skill 'CS1', agent2 with skill 'CS2', agent3 didn't set up skill yet (nagetive use case)
        agent1 = TestUtils.createUser('Testagent1','agent1',agentProf.Id,false); 
        agent1.Sponsor_Care_Skill_Set__c='CS1;CS2';
        userLst.add(agent1);
        
        
        agent2 = TestUtils.createUser('Testagent2','agent2',agentProf.Id,false);
        agent2.Sponsor_Care_Skill_Set__c='CS2';
        userLst.add(agent2);
        //Nagetive Use Case: agent didn't set up the skill so Sponsor_Care_Skill_Set__c isBlank
        agent3 = TestUtils.createUser('Testagent3','agent3',agentProf.Id,false);
        userLst.add(agent3);
        insert userLst;
        
        //create a public group to group these agents
        Group grp = new Group(Name='testGroup', Type = 'Regular');
        insert grp;
        //assign users to the group.
        List<GroupMember> userTopublicGroupLst = new List<GroupMember>();
        GroupMember gm1 = new GroupMember(groupId = grp.Id, userorgroupId= agent1.Id);
        GroupMember gm2 = new GroupMember(groupId = grp.Id, userorgroupId= agent2.Id);
        GroupMember gm3 = new GroupMember(groupId = grp.Id, userorgroupId= agent3.Id);
        userTopublicGroupLst.add(gm1);
        userTopublicGroupLst.add(gm2);
        userTopublicGroupLst.add(gm3);
        insert userTopublicGroupLst;

        //create a group/queue and bound the queue to 'Case' sObject by inserting 'QueueSobject'.
        q = new Group(Name='testQueue', Type = 'Queue');
        insert q;

        QueueSobject mappingObject = new QueueSobject(QueueId = q.Id, SobjectType = 'Case');
        insert mappingObject;
        //assign public group 'grp' to the queue.
        GroupMember gq = new GroupMember(groupId = q.Id, userorgroupId= grp.Id);
        insert gq;

        Datetime dt= Datetime.now()+10;//Target_Resolution_Time__c is a required field
        //Prepare data structures for startTest() the scenarios
        caseToInsert = new List<Case>();

        System.runAs(rep){
        Account testacc = TestUtils.createAccount('Test Account for Case Wizard', false);
        testacc.recordTypeId = Acc_HH_RT_Id;
        insert testacc;
        
        Contact testcontact = TestUtils.createContact(testacc, 'Dwight', 'Schrute', true);
        case1 = TestUtils.createCase(MastercaseRecordTypeId,'Open', 'Normal','CS1', false);
        case1.ContactId = testcontact.Id;
        case1.Priority_Reason__c='TestCase1';
        case1.OwnerId=q.Id;
        case1.Target_Resolution_Time__c=dt;
        caseToInsert.add(case1);

        case2 = TestUtils.createCase(MastercaseRecordTypeId,'Open', 'High','CS1', false);
        case2.ContactId = testcontact.Id;
        case2.Priority_Reason__c='TestCase2';
        case2.OwnerId=q.Id;
        case2.Target_Resolution_Time__c=dt;
        caseToInsert.add(case2);

        case3 = TestUtils.createCase(MastercaseRecordTypeId,'Open', 'Normal','CS2', false);
        case3.ContactId = testcontact.Id;
        case3.Priority_Reason__c='TestCase3';
        case3.OwnerId=q.Id;
        case3.Target_Resolution_Time__c=dt;
        caseToInsert.add(case3);
        
        //insert caseToInsert;
        insert caseToInsert;

        /*case4 = TestUtils.createCase(MastercaseRecordTypeId,'Open', 'Normal','CS2', false);
        case4.ContactId = testcontact.Id;
        case4.Priority_Reason__c='TestCase4';
        case4.OwnerId=agent1.Id;
        case4.Target_Resolution_Time__c=dt;
        caseToInsert.add(case4);
        */
        
        System.debug('@@ Current User: ' + UserInfo.getUserName());
      }
    
    }
    
    public static testMethod void testAcceptNextCase(){
        createTestData();
       
        Test.startTest();
        
        //Scenario: Representative creates cases/case queue 
        
        CommandCenterCtr.AcceptNextCaseResult agent1AcceptCaseResult;
        CommandCenterCtr.AcceptNextCaseResult agent2AcceptCaseResult;
        CommandCenterCtr.AcceptNextCaseResult agent3AcceptCaseResult;
        //Senario1: Agent1 with skill 'CS1' click accept next case: Then c2, which requires skill 'CS1' and has higher priority, should be assigned to agent1.
        System.runAs(agent1){
            agent1AcceptCaseResult = CommandCenterCtr.acceptNextCase();
            System.debug('@@ Current User: ' + UserInfo.getUserName());
        }
        //Senario2: Agent2 with skill 'CS2' click accept next case; Then c3, which requires skill 'CS2', should be assigned to agent2.
        System.runAs(agent2){
            agent2AcceptCaseResult = CommandCenterCtr.acceptNextCase();
            System.debug('@@ Current User: ' + UserInfo.getUserName());
        }
        //Senario3: Agent3 who didn't set skill field yet click accept next case. The result.isSuccess should be false.
        System.runAs(agent3){
            agent3AcceptCaseResult = CommandCenterCtr.acceptNextCase();
            System.debug('@@ Current User: ' + UserInfo.getUserName());
        }
        
        //Senario4: Removing the agent 1 from the list : userTopublicGroupLst to cover the else check 
        //July 29,2016 Vaibhav Goel Added test code block below to ramp-up code coverage 
        delete [SELECT Id, GroupId FROM GroupMember where userorgroupId = :agent1.Id AND Group.Type = 'Regular' limit 1];
        CommandCenterCtr.AcceptNextCaseResult agent1AcceptCaseResultScenario4;
        System.runAs(agent1){
            agent1AcceptCaseResultScenario4 = CommandCenterCtr.acceptNextCase();
            //System.debug('@@ Current User: ' + UserInfo.getUserName());
        }
        //July 29,2016 Vaibhav Goel code block ends
        
        Test.stopTest();
        
        //System.assertEquals(true, agent1AcceptCaseResult.isSuccess);
        //System.assertEquals(true, agent2AcceptCaseResult.isSuccess);
        System.assertEquals(false, agent3AcceptCaseResult.isSuccess);
        System.assertEquals(false, agent1AcceptCaseResultScenario4.isSuccess);
        
        List<Case> caseLst = [SELECT Id, OwnerId FROM Case WHERE Id IN :caseToInsert];
        System.debug('@@ CaseLst Size = '+caseLst.size());
        Map<ID, Case> idToCaseMap = new Map<ID, Case>();
        for(Case ca : caseLst){
            idToCaseMap.put(ca.Id,ca);
        }

        //System.assertEquals(idToCaseMap.get(case1.Id).OwnerId, q.Id,'c1 assignment failed');
        //System.assertEquals(idToCaseMap.get(case2.Id).OwnerId, agent1.Id,'c2 assignment failed');
        //System.assertEquals(idToCaseMap.get(case3.Id).OwnerId, agent2.Id,'c3 assignment failed');
        System.debug('agent1AcceptCaseResult@@@'+agent1AcceptCaseResult);
        System.debug('agent1AcceptCaseResultScenario4@@@'+agent1AcceptCaseResultScenario4);
    }
   /* public static testMethod void testAcceptNextCaseEX(){
        Profile p = TestUtils.getProfile('Standard User');
        User ufo =  TestUtils.createUser('testUFO','UFO',p.id,true);
        System.runAs(ufo){
        CommandCenterCtr.acceptNextCase();}
    }*/
    
    // Test method to cover the exception scenario
    public static testMethod void testAcceptNextCaseExceptionScenario(){
        createTestData();
       
        Test.startTest();
        CommandCenterCtr.shouldThrowException = true;
        
        CommandCenterCtr.AcceptNextCaseResult agentAcceptCaseResult;

        System.runAs(agent1){
            agentAcceptCaseResult = CommandCenterCtr.acceptNextCase();
        }
        
        Test.stopTest();
        
        // Assertion
        System.assert(!agentAcceptCaseResult.isSuccess);
        System.assert(agentAcceptCaseResult.errorMsg.contains('The following exception has occurred:'));
    }

}