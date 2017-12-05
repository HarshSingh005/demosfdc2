/***********************************************************************************************************
 * Appirio, Inc
 * Name         : showParticipantPhotoControllerTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the showParticipantPhotoController
 * Created Date : 27/01/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 27/01/2016                   Munib Ur Rehman         Created
 **********************************************************************************************************/
@isTest(seeAllData = true)
public with sharing class showParticipantPhotoControllerTest {

 	static Contact contact1;
    static List<ContentDocument> documents;

    @isTest
	public static void testShowParticipantPhoto() {
       
        createTestData();
        Test.startTest();
        System.currentPageReference().getParameters().put('id', String.valueOf(contact1.Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contact1);
        showParticipantPhotoController testAccPlan = new showParticipantPhotoController(sc);
        Test.stopTest();
		System.assertEquals(testAccPlan.isPhotoAvailable, false);
    } // END public static void testUpdateLocalPartnerNationalOffice() {
    
    
     @isTest
	public static void testShowParticipantPhoto1() {
       
        createTestData();
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contact1);
        showParticipantPhotoController testAccPlan = new showParticipantPhotoController(sc);
        Test.stopTest();
        System.assertEquals(testAccPlan.isPhotoAvailable, true);
    } // END public static void testUpdateLocalPartnerNationalOffice() {
    
    //create account and contact data
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
    
    FeedItem feed = new FeedItem (
        ParentId = contact1.id,
        Body = 'Child Photo',
        Type = 'ContentPost'
        );
        insert feed;

    TopicAssignment tpass = new TopicAssignment();

    ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
    documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
      
  }
    
} // END public with sharing class MCSCPRRequestTest