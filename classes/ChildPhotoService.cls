/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ChildPhotoService
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Web services for the Child Photo application
 * Created Date : 01/20/2017
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/20/2017                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class ChildPhotoService 
{
	//Given the list of photos added to the processing queue, 
	//pass a list of child numbers to the web service method. 
	//The method will query participant records and return the above metadata.
	webservice static List<ChildPhotoMetadata> GetPhotoMetadata(List<string> participantNumbers)
	{
		List<ChildPhotoMetadata> metadataList = new List<ChildPhotoMetadata>();

		Set<string> participantIds = new Set<string>(participantNumbers);

		try
		{
			List<Contact> contacts = [select id,
									  Contact_Number__c,
									  Name,
									  Short_Name__c,
									  National_Office_Number__c,
									  Community_Number__c,
									  BirthDate,
									  rC_Bios__Gender__c,
									  rC_Sponsorship__Narrative__c,
									  Photo_Date__c,
									  Photo_Data__c 
									  from Contact
									  where recordtype.name = 'Participant' and 
									  Contact_Number__c in :participantIds];

			for(Contact contact : contacts)
			{
				ChildPhotoMetadata data = new ChildPhotoMetadata();

				data.ParticipantId = contact.Id; 
				data.ParticipantNumber = contact.Contact_Number__c;
				data.ParticipantName = contact.Name;
				data.ParticipantShortName = contact.Short_Name__c;
				data.NONumber = contact.National_Office_Number__c;
				data.CommunityNumber = contact.Community_Number__c;
				
				if(contact.BirthDate != null)
					data.DOB = string.valueOf(contact.BirthDate);
				
				data.Gender = contact.rC_Bios__Gender__c;
				data.Narrative = contact.rC_Sponsorship__Narrative__c;
				
				if(contact.Photo_Date__c != null)
					data.LastPhotoDate = string.valueOf(contact.Photo_Date__c);
				
				data.LastPhoto = contact.Photo_Data__c;

				metadataList.add(data);
			}  
		}
		catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('ChildPhotoService','GetPhotoMetadata','Exception');
            log.logException(ex);
            log.saveLogs();  
        }

		return metadataList;
	}

	//Calling this method saves information about the rejected photo 
	//into the Salesforce Contact record for the Participant.
	webservice static ChildPhotoResult SavePhoto(string participantId, string photo, string narrative)
	{
		ChildPhotoResult result = new ChildPhotoResult();
		result.Success = false;

		try
		{
			Contact contact = new Contact();
			contact.id = id.valueOf(participantId);
			contact.Photo_Data__c = photo;
			contact.rC_Sponsorship__Narrative__c = narrative;
			contact.Photo_Date__c = date.today();
			contact.Materials_Approval_Status__c = 'Approved';
			contact.Participant_Materials_Approved_Date__c = date.today();
			contact.Photo_Reject_Date__c = null;
			contact.Photo_Reject_Code__c = null;
			contact.Rejected_Photo_Name__c = null;

			update contact;
			result.Success = true;
		}
		catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('ChildPhotoService','SavePhoto','Exception');
            log.logException(ex);
            log.saveLogs();

            result.ErrorMessage = ex.getMessage();
            result.StackTrace = ex.getStackTraceString();
        }

		return result;
	}

	//Saves the photo and narrative to the Salesforce Contact record of the Participant.
	webservice static ChildPhotoResult RejectPhoto(string participantId, string photoName, string rejectCode)
	{
		ChildPhotoResult result = new ChildPhotoResult();
		result.Success = false;

		try
		{
			Contact contact = new Contact();
			contact.id = id.valueOf(participantId);
			contact.Photo_Reject_Date__c = datetime.now();
			contact.Photo_Reject_Code__c = rejectCode;
			contact.Rejected_Photo_Name__c = photoName;

			update contact;
			result.Success = true;
		}
		catch(Exception ex)
        {
            //log exception to the apex logger
            apexLogHandler.apexLog log = 
                new apexLogHandler.apexLog('ChildPhotoService','RejectPhoto','Exception');
            log.logException(ex);
            log.saveLogs();

            result.ErrorMessage = ex.getMessage();
            result.StackTrace = ex.getStackTraceString(); 
        }

		return result;
	}
}