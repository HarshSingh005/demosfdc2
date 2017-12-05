/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TopicAssignmentServiceTest
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class for the TopicAssignmentService
 * Created Date : 15/09/2016
 *
 **********************************************************************************************************/

@isTest(seeAllData = true)
private class TopicAssignmentServiceTest {
    /*static Contact contact1;
    static List<ContentDocument> documents;
  private static testMethod void testCreate() {
    createTestData();
    
    //List<Topic> topicList = [select Id from Topic where Name = 'Child Photo'];
    //System.debug('---topicList'+topicList.size());
    List<TopicAssignment> topicAssignmentList = [select Id from TopicAssignment ];
    System.debug('-@@@--topicAssignmentList'+topicAssignmentList.size());
    
    ContentDocumentLink link = new ContentDocumentLink();
    link.LinkedEntityId = contact1.Id;
    link.ContentDocumentId = documents[0].Id;
      
    Test.startTest();
    Map<Id, TopicAssignment> contMap = new Map<Id, TopicAssignment>();
    contMap.put(topicAssignmentList[0].Id, topicAssignmentList[0]);    
    TopicAssignmentService.updateContactPhotoDateField(contMap);
    
    List<TopicAssignment> tp = [SELECT Id, EntityId FROM TopicAssignment where Topic.Name =: 'Child Photo'];
    system.debug('@@@Tpsize'+tp.size());
    
    Contact cont = [select Id, Photo_Date__c from Contact where Id = :contact1.Id];
    system.debug('con@@@'+cont.Photo_Date__c);
    Test.stopTest();
    
    
  }
  static void createTestData(){
      ContentVersion contentVersion_1 = new ContentVersion(
      Title = 'Penguins',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion_1;
    
    Account acct = TestUtils.createAccount('Acc1',true);
    
    contact1 = TestUtils.createContact(acct,'first','NewCont',true);
    
    TopicAssignment tpass = new TopicAssignment();
    
    
    ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
    documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    Topic topic1 = new Topic();
    topic1.Name = 'Child Photo New test';
    insert topic1;
      
  }*/
}