/***********************************************************************************************************
 * Appirio, Inc
 * Name         : showParticipantPhotoController
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Extension class of showParticipantPhoto Page
 * Created Date : 01/Sept/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/

public class showParticipantPhotoController { 
	public Contact conPart { get; Set; }
	public String conID {get; Set; }
	public static String errorMessage {get; set;}
    public Boolean gotError {get; set;}
	public Boolean isPhotoAvailable {get; Set;}
	public String imageURL {get; set;}

	/**
    * @description - Constructor of the class
	* @return - void
    */
	public showParticipantPhotoController(ApexPages.StandardController stdCon) {
		conPart = new Contact();
		isPhotoAvailable = true;
		conID = Apexpages.currentPage().getParameters().get('id');
		if(String.isNotBlank(conID)) {
			init();
		} else {
            gotError = true;
            errorMessage = 'You\'r coming from a wrong way. Please GoTo: \n';
            errorMessage += 'Contact -> Select Participant Contact \n';
        }
	}

	/**
    * @description - Method to initialize or query the required data (calling from constructor)
	* @return - void
    */
	void init() {
		conPart = [SELECT Id, Name, Photo_Data__c, RecordtypeId FROM Contact WHERE Id = :conID];
		if(conPart.Photo_Data__c == null) {
			isPhotoAvailable = false;
			imageURL='/servlet/servlet.FileDownload?file=';
			String downloadURL = fetchPhotoFromChatter(conPart.Id);
			System.debug('[RB] - showParticipantPhotoController.init :: downloadURL (Before If) => ' + downloadURL);
			if(!String.isEmpty(downloadURL)) {
				imageURL = downloadURL; 
				System.debug('[RB] - showParticipantPhotoController.init :: imageURL (Inside If) => ' + imageURL);
			}
			else {
				Document doc = [SELECT Id, Name, DeveloperName FROM Document WHERE Name = 'No Photo Available'][0];
				imageURL += doc.Id;
				System.debug('[RB] - showParticipantPhotoController.init :: imageURL (Inside else) => ' + imageURL);
			}
		}
	}

	/**
    * @description - Method to fetch contact's latest photo from chatter if available otherwise from documents.
    * Parameter 1 - contact Id fow which we want to fetch the photo on the basis of #Child Photo.
	* @return - String (URL of the photo)
    */
	String fetchPhotoFromChatter(String conID){
		System.debug('[RB] - showParticipantPhotoController.fetchPhotoFromChatter :: Method Start..');
		String retVal=null;
		List<TopicAssignment> lstTA = [SELECT Id, EntityId, Topic.Id, Topic.Name FROM TopicAssignment WHERE Topic.Name = 'Child Photo' AND EntityId IN (SELECT Id FROM FeedItem WHERE ParentId=:conID AND Type='ContentPost')];
		System.debug('[RB] - showParticipantPhotoController.fetchPhotoFromChatter :: lstTA => ' + lstTA);
		if(lstTA.size()>0) {
			List<FeedAttachment> lstFA = [SELECT Id, RecordId FROM FeedAttachment WHERE FeedEntityId = :lstTA[0].EntityId];
			retVal = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + lstFA[0].RecordId;
		}
		System.debug('[RB] - showParticipantPhotoController.fetchPhotoFromChatter :: Method End..');
		return retVal;
	}
}