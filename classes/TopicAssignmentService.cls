/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TopicAssignmentService
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Service(Helper) class for TopicAssignment for T-522892
 * Created Date : 08/31/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/31/2016                   Munib Ur Rehman         Created
   ----------------------------------------------------------------------------------------------------------
 * 01/23/2017                   John Hecker             Modified per I-254699
 **********************************************************************************************************/
 public with sharing class TopicAssignmentService {
    // methods for After Insertion
    public static void OnAfterInsert(List<TopicAssignment> newTopicAssignments, Map<Id, TopicAssignment> topicAssignmentMap) {
     //   updateContactPhotoDateField(topicAssignmentMap);
    }
    //method to update contacts photo fields
    
    /* Method deactivated by John Hecker (Appirio) per I-254699, remove SFDC based photo upload and approval process
    public static void updateContactPhotoDateField(Map<Id, TopicAssignment> topicAssignmentMap){
        System.debug('method updateContactPhotDateField starts....');
        Set<Id> relatedContactIdSet = new Set<Id>();
        List<Id> feedItemIdList = new List<Id>();
        Map<Id, Id> ContsToFeedMap = new Map<Id, Id>(); 
        Map<Id, Id> feedToDocMap =new Map<Id, Id>();
        
        
        //Fetching All Topic Assignments With Topic as 'Child Photo'
        List<TopicAssignment> topList = [SELECT Id, EntityId FROM TopicAssignment 
                                            WHERE Topic.Name = 'Child Photo' 
                                            AND Id in :topicAssignmentMap.keySet()];
                                            
        
        // Creating RelatedFeedItem List 
        for(TopicAssignment topAssign :topList){
            if(topAssign.EntityId != null && String.valueOf(topAssign.EntityId).startsWith('0D5')){ // Checking for Feed Item Initial
                 feedItemIdList.add(topAssign.EntityId);
            } 
        }
        
        //Creating FeedItem to Contact(Parent) Map
        Map<Id,Id> feedItemParentMap = new Map<Id,Id>();
        if(!feedItemIdList.isEmpty()){
            List<FeedItem> itemfeedList = [SELECT Id, ParentId FROM FeedItem where Id in :feedItemIdList];
                for(FeedItem itemfeed : itemfeedList){
                    if(itemfeed.ParentId != null && String.valueOf(itemfeed.ParentId).startsWith('003')){ // Checking for the Contact Id Initials
                         feedItemParentMap.put(itemfeed.Id, itemfeed.ParentId);
                    } 
                }
        }
        
        //Creating  List Of COntacts and 'FeedAttachment to ContentVersion' Map
        if(!feedItemParentMap.isEmpty()) {
            List<FeedAttachment> feedAttachmentList = [SELECT Id, RecordId, FeedEntityId, Type
                                                         FROM FeedAttachment
                                                         where FeedEntityId in :feedItemParentMap.keySet() and Type = 'Content'];
            for(FeedAttachment attachmentRecord : feedAttachmentList){
                if(feedItemParentMap.get(attachmentRecord.FeedEntityId) != null){
                    relatedContactIdSet.add(feedItemParentMap.get(attachmentRecord.FeedEntityId));
                    //ContsToFeedMap.put(feedItemParentMap.get(attachmentRecord.FeedEntityId), attachmentRecord.Id);
                }
                //feedToDocMap.put(attachmentRecord.Id, attachmentRecord.RecordId);
            }
        }
        
        // Now updating the Contact Records for the feed.
        List<Contact> contRecords = new List<Contact>();
        Id feedAttachId;
         if(!relatedContactIdSet.isEmpty()){
            List<Contact> contRecordList = [SELECT Id, Photo_Date__c , PhotoContentId__c , PhotoVersionId__c , Photo_User__c 
                                            FROM Contact 
                                            where Id in :relatedContactIdSet];
             for(Contact contRecord : contRecordList){
                contRecord.Photo_Date__c = System.today(); // Todays Date
                // Code to update the Photo Content Id and Photo Version Id, Later commented on recommendation of John Hecker
                
                contRecord.Photo_User__c  = UserInfo.getUserId(); // Current User Id assignment
                contRecords.add(contRecord);
             }
             
             // updating the Contact Records
             if(!contRecords.isEmpty()){
                update contRecords;
             }
         }
        
    }
    End comment out of method*/ 
    
}