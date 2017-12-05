/***********************************************************************************************************
 * Appirio, Inc
 * Name         : SobjectServicesTest
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class for the SobjectServices
 * Created Date : July 28, 2016
 ** Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * Aug 03, 2016                 Ashu Gupta              Added asserts and increased code coverage
 **********************************************************************************************************/
@isTest
private class SobjectServicesTest {
    static List<Sobject> sObjList, sObjList1;
    
    private static testMethod void testGetRecordType() {
        createTestData();
        Test.startTest();
        RecordType rt = SObjectServices.getRecordType('Proposal','Opportunity');
        System.assertNotEquals(rt,null);
        
        //Negative Testing 
        RecordType rt2 = SObjectServices.getRecordType('Invalid','Opportunity');
        System.assertEquals(rt2,null);
        
        //Testing insertSObjects Method SobjectServices Class
        SObjectServices.insertSObjects(sObjList);
        List<Sobject> sObjListreturned = [SELECT id,name FROM Account WHERE name= 'test'];
        System.assertEquals(sObjListreturned.size(),1);
        
        SObjectServices.insertSObjects(sObjList1);
        List<Sobject> sObjListreturned1 = [SELECT id,name FROM Account WHERE name= 'test'];
        System.assertEquals(sObjListreturned1.size(),2);
        
        //testing updateSObjects Method of SobjectServices Class
        SObjectServices.updateSObjects(sObjList,true);
        Map<String, Schema.SObjectField> returnedMap = SObjectServices.getFieldsForSObject('Account');
        System.assertEquals(!returnedMap.isEmpty(),true);
        
        
        Test.stopTest();
    }
    private static testMethod void testGetGroupsForUser(){
       
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
        UserRoleId = portalRole.Id,
        ProfileId = profile1.Id,
        Username = System.now().millisecond() + 'test@test.com',
        Alias = 'test',
        Email='ashu.gupta@appirio.com',
        EmailEncodingKey='UTF-8',
        Firstname='testFirst',
        Lastname='testLast',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        
        
        
        Test.startTest();
        SObjectServices.getGroupsForUser('test',portalAccountOwner1.id);
        
        test.stopTest();
    
    }
    
    private static testMethod void testGetRecordNameIdMap(){
        Schema.DescribeSObjectResult objectDescribe  = Account.SObjectType.getDescribe();
        
        Test.startTest();
        Map<String, Id> returnedMap = SObjectServices.getRecordNameIdMap(objectDescribe);
        System.assertEquals(!returnedMap.isEmpty(),true);
        test.stopTest();
        
    }
    
    private static testMethod void testSetSObjectFieldValue(){
        String typeName = 'Account';
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        sObject obj = targetType.newSObject();
        
        Test.startTest();
        Boolean bool = SObjectServices.setSObjectFieldValue(obj,'Name',null);
        system.assertEquals(bool,true);
        test.stopTest();
        
    }
    
    private static testMethod void testGetRecordType1() {
        createTestData1();
        Test.startTest();
        try{
        SObjectServices.insertSObjects(sObjList);
        } catch(Exception e){
        System.debug('Error Occured');
    }
        Test.stopTest();
    }
    
     //create Test Data
    static void createTestData1(){
    
    sObjList = new List<SObject>();
     sObjList.add(new Account());
   
    }
    
    //create Test Data
    static void createTestData(){
        
    sObjList = new List<SObject>();
    sObjList.add(new Account(name='test'));
    
    sObjList1 = new List<SObject>();
    sObjList1.add(new Account(name='test'));
    
    }
    
}