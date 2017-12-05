@isTest
private class TestSetPermissionSetForUserBatch {
    
    static List<User> users,usersWithoutPSA;
    static PermissionSet pSet,pSetNew;
    static List<PermissionSetAssignment> psaList,ps;
    
    static void setup(Boolean createPS){
        users = new List<User>();
        Profile profile = TestUtils.getProfile('Standard User');
        for(Integer i=0; i<200; i++){
            users.add(TestUtils.createUser('LastNameng'+i, 'alias'+i, profile.Id, false));
        }
        insert users;
        UserLicense ul = TestUtils.getUserLicense('Salesforce');
        pSet = TestUtils.createPermissionSet('TestPS', 'TestPS', ul, true);
        if(createPS){
            psaList = new List<PermissionSetAssignment>();
            for(User usr: users){
                psaList.add(new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = pSet.Id));
            }
            insert psaList;
        }
        usersWithoutPSA = new List<User>();
        
        for(Integer i=0; i<200; i++){
            usersWithoutPSA.add(TestUtils.createUser('Last'+i, 'alias'+i, profile.Id, false));
        }
        insert usersWithoutPSA;
         pSetNew = TestUtils.createPermissionSet('TestPS', 'TestPS', ul, false);
        if(createPS){
            ps = new List<PermissionSetAssignment>();
            for(User usr: usersWithoutPSA){
                ps.add(new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = pSetNew.id));
            }
            //insert ps;
        }
    }   
    
    static void setupOnlyUsers(){
        users = new List<User>();
        Profile profile = TestUtils.getProfile('Standard User');
        for(Integer i=0; i<200; i++){
            users.add(TestUtils.createUser('LastNameng'+i, 'alias'+i, profile.Id, false));
        }
        insert users;
    }   
    
   static testMethod void testSetPermissionSetOnUser() {
        setup(true);
        SetPermissionSetForUserBatch batch = new SetPermissionSetForUserBatch();
        batch.testUsers = users;
        Test.startTest();
            Database.executeBatch(batch, 200);
        Test.stopTest();
        
        users = [SELECT Id, Permission_Set__c FROM User WHERE Id IN: users];
        for(User usr : users){
            System.assertNotEquals(null, usr.Permission_Set__c);
            System.assertEquals(true, usr.Permission_Set__c.contains(pSet.Id));
        }        
    }
    
    /*static testMethod void testWithoutPermissionSet() {
        setup(false);
        
        SetPermissionSetForUserBatch batch = new SetPermissionSetForUserBatch();
        batch.testUsers = users;
        Test.startTest();
            Database.executeBatch(batch, 200);
        Test.stopTest();
        
        users = [SELECT Id, Permission_Set__c FROM User WHERE Id IN: users];
        for(User usr : users){
            System.assertEquals(null, usr.Permission_Set__c);
        }
    }*/
    
     static testMethod void testWithoutPermissionSet2() {
        setupOnlyUsers();
        
        SetPermissionSetForUserBatch batch = new SetPermissionSetForUserBatch();
        batch.testUsers = users;
        Test.startTest();
            Database.executeBatch(batch, 200);
        Test.stopTest();
        
        users = [SELECT Id, Permission_Set__c FROM User WHERE Id IN: users];
        for(User usr : users){
            System.assertEquals(null, usr.Permission_Set__c);
        }
    }
     /*static testMethod void testWithoutPermissionSet1() {
        
        
        setup(true);
        System.debug('PSALIST@@@'+psaList);
        
        psaList.clear();
        System.debug('PSALIST@@@'+psaList);
        SetPermissionSetForUserBatch batch = new SetPermissionSetForUserBatch();
        batch.testUsers = usersWithoutPSA;
        Test.startTest();
            Database.executeBatch(batch, 200);
        Test.stopTest();
        
        users = [SELECT Id, Permission_Set__c FROM User WHERE Id IN: usersWithoutPSA];
        /*for(User usr : usersWithoutPSA){
            System.assertNotEquals(null, usr.Permission_Set__c);
            System.assertEquals(true, usr.Permission_Set__c.contains(pSet.Id));
        } */       
    // }
}