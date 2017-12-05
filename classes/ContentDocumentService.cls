/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ContentDocumentService
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Service(Helper) class for ContentDocumentTrigger
 * Created Date : 08/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/26/2016                   Munib Ur Rehman         Created
 **********************************************************************************************************/
 public with sharing class ContentDocumentService {
    public static void OnAfterInsert(List<ContentDocument> newContentDocuments, Map<Id, ContentDocument> contentDocumentMap) {
        updateContactPhotoDateField(contentDocumentMap);
    }
    public static void updateContactPhotoDateField(Map<Id, ContentDocument> contentDocumentMap){
        System.debug('method updateContactPhotDateField starts....');
        List<Id> newContentIdList = new List<Id>();
        Set<Id> relatedContactIdSet = new Set<Id>();
        
        // Check First if any elligible contentDocument Records exists for RElated TopicAssignments>0
        for (ContentDocument cdKey : [SELECT Id, (SELECT Id, EntityId FROM TopicAssignments where Topic.Name =: 'ChildPhoto' OR Topic.Name =: 'Child Photo') FROM ContentDocument WHERE ID IN :contentDocumentMap.keySet()]){        
          System.debug('hiii67868'+cdkey.TopicAssignments.size());
            //System.debug('@@@hi'+cdkey.size());
            if(cdKey.TopicAssignments!= null && cdKey.TopicAssignments.size()>0){
                
                   System.debug('hiii'+cdkey);
                 newContentIdList.add(cdKey.Id);
                
            }   
            
        }
        system.debug('contentidlisttt'+newContentIdList);
        
        //Creating a list of Contacts to be updated from related ContentDocumentLinks of ContentDocuments filtered above
        if(!newContentIdList.isEmpty()) {
            List<ContentDocumentLink> docLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId in :newContentIdList];
                    system.debug('docLinkListtttt'+docLinkList);
            for(ContentDocumentLink contentDocLink : docLinkList){
                if(contentDocLink.LinkedEntityId != null && String.valueOf(contentDocLink.LinkedEntityId).startsWith('003')){
                    relatedContactIdSet.add(contentDocLink.LinkedEntityId);
                }
            }
        }
        system.debug('relatedContactIdSettttttt'+relatedContactIdSet);
         
        //Checking if Contact Ids are not Empty
        if(!relatedContactIdSet.isEmpty()){
            List<Contact> contRecords = [select Id , Photo_Date__c from Contact where Id in :relatedContactIdSet];
            //updating Dates for All elligible Contacts retrieved.
            for(Contact cont : contRecords){
                cont.Photo_Date__c = System.today();
               
            }
            update contRecords;
        }
        System.debug('method updateContactPhotDateField ends....');
    }
}