/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ChildPhotoServiceTest
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Test class for Web services for the Child Photo application
 * Created Date : 01/20/2017
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/20/2017                   Karl Houseknecht        Created
 **********************************************************************************************************/
@isTest(seeAllData=true) //because of NGOC custom settings
public class ChildPhotoServiceTest 
{

	public static void setup()
	{
		Account nationalOffice = new Account();
		nationalOffice.rC_Bios__Active__c = true;
		nationalOffice.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
		nationalOffice.National_Office_ID__c = '000';
		nationalOffice.name = 'Test NO';
		nationalOffice.National_Director__c = UserInfo.getUserId();
		nationalOffice.Regional_Director__c = UserInfo.getUserId();
		nationalOffice.Participant_Contact_Owner__c = UserInfo.getUserId();
		insert nationalOffice;

		Account localPartner = new Account();
		localPartner.rC_Bios__Active__c = true;
		localPartner.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
		localPartner.Local_Partner_ID__c = '0000000';
		localPartner.name = 'Test LP';
		localPartner.parentid = nationalOffice.id;
		insert localPartner;

		Account community = new Account();
		community.rC_Bios__Active__c = true;
		community.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
		community.Community_ID__c = '0000';
		community.name = 'Test Community';
		community.parentid = localPartner.id;
		insert community;

		Contact contact = new Contact();
		contact.rC_Bios__Active__c = true;
		contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
		contact.accountid = community.id;
		contact.rC_Sponsorship__Sponsorship_Status__c = 'Available';
		contact.FirstName = 'Tester';
		contact.LastName = 'GetPhotoMetadataTest';
		contact.Short_Name__c = 'Test';
		contact.Community__c = community.id;
		contact.rC_Bios__Birth_Day__c = '01';
		contact.rC_Bios__Birth_Month__c = '01';
		contact.rC_Bios__Birth_Year__c = string.valueOf(date.today().year() - 5);
		contact.rC_Bios__Gender__c = 'Male';
		contact.rC_Sponsorship__Narrative__c = 'This is a kid';
		contact.Photo_Date__c = date.today().addMonths(-6);
		contact.Photo_Data__c = 'xzy';
		insert contact;
	}

	public static testmethod void GetPhotoMetadataTest()
	{
		setup();

		Contact child = [select Id, Contact_Number__c,
						 Name, Short_Name__c, National_Office_Number__c,
						 Community_Number__c, BirthDate, rC_Bios__Gender__c,
						 rC_Sponsorship__Narrative__c, Photo_Date__c,
						 Photo_Data__c
						 from contact 
						 where lastname = 'GetPhotoMetadataTest' and 
						 firstname = 'Tester' and
						 Short_Name__c = 'Test' and 
						 recordtype.name = 'Participant' limit 1];

		List<string> childNumbers = new List<string>();
		childNumbers.add(child.Contact_Number__c);

		List<ChildPhotoMetadata> photoData = ChildPhotoService.GetPhotoMetadata(childNumbers);
		ChildPhotoMetadata data = photoData[0];
		
		system.assertEquals(photoData.size(), 1, 'One child should be returned from function');
		system.assertEquals(data.ParticipantId, string.valueOf(child.id), 'ParticipantId should equal child.id');
		system.assertEquals(data.ParticipantNumber, child.Contact_Number__c, 'ParticipantNumber should equal Contact_Number__c');
		system.assertEquals(data.ParticipantName, child.Name, 'Name should equal Contact.Name');
		system.assertEquals(data.ParticipantShortName, child.Short_Name__c, 'ParticipantShortName should equal Contact Short Name');
		system.assertEquals(data.NONumber, child.National_Office_Number__c, 'NONumber should equal Contact NO number');
		system.assertEquals(data.CommunityNumber, child.Community_Number__c, 'CommunityNumber should equal Contact Community');
		system.assertEquals(data.DOB, string.valueOf(child.BirthDate), 'DOB should equal Contact BirthDate');
		system.assertEquals(data.Gender, child.rC_Bios__Gender__c, 'Gender should equal Contact Gender');
		system.assertEquals(data.Narrative, child.rC_Sponsorship__Narrative__c, 'Narrative should equal Contact Narrative');
		system.assertEquals(data.LastPhotoDate, string.valueOf(child.Photo_Date__c), 'LastPhotoDate should equal Contact Photo Date');
		system.assertEquals(data.LastPhoto, child.Photo_Data__c, 'LastPhoto should equal Contact Photo Data');

	}

	public static testmethod void SavePhotoTest()
	{
		setup();

		Contact child = [select Id
						 from contact 
						 where lastname = 'GetPhotoMetadataTest' and 
						 firstname = 'Tester' and
						 Short_Name__c = 'Test' and 
						 recordtype.name = 'Participant' limit 1];

		ChildPhotoResult result = ChildPhotoService.SavePhoto(child.id, 'zzz', 'new narrative');

		child = [select id, Photo_Data__c, Photo_Date__c, rC_Sponsorship__Narrative__c,
				Materials_Approval_Status__c, Participant_Materials_Approved_Date__c,
				Photo_Reject_Date__c, Photo_Reject_Code__c, Rejected_Photo_Name__c
				from contact where id = :child.id];

		system.assertEquals(true, result.success, 'result should be successful');
		system.assertEquals('new narrative', child.rC_Sponsorship__Narrative__c, 'Narrative should equal Contact Narrative');
		system.assertEquals(string.valueOf(date.today()), string.valueOf(child.Photo_Date__c), 'LastPhotoDate should equal Contact Photo Date');
		system.assertEquals('zzz', child.Photo_Data__c, 'LastPhoto should equal Contact Photo Data');
		system.assertEquals('Approved', child.Materials_Approval_Status__c, 'Materials_Approval_Status__c should be null');
		system.assertEquals(null, child.Photo_Reject_Date__c, 'Photo_Reject_Date__c should be null');
		system.assertEquals(null, child.Photo_Reject_Code__c, 'Photo_Reject_Code__c should be null');
		system.assertEquals(null, child.Rejected_Photo_Name__c, 'Rejected_Photo_Name__c should be null');

		result = ChildPhotoService.SavePhoto('x', 'zzz', 'new narrative'); //invalid record id
		system.assertEquals(false, result.success, 'result should be unsuccessful');

	}

	public static testmethod void RejectPhotoTest()
	{
		setup();

		Contact child = [select Id
						 from contact 
						 where lastname = 'GetPhotoMetadataTest' and 
						 firstname = 'Tester' and
						 Short_Name__c = 'Test' and 
						 recordtype.name = 'Participant' limit 1];

		ChildPhotoResult result = ChildPhotoService.RejectPhoto(child.id, 'zzz', 'Other');

		child = [select id, Photo_Reject_Date__c, Photo_Reject_Code__c, Rejected_Photo_Name__c
				from contact where id = :child.id];

		system.assertEquals(true, result.success, 'result should be successful');
		system.assert(child.Photo_Reject_Date__c != null, 'Photo_Reject_Date__c should be populated');
		system.assertEquals('Other', child.Photo_Reject_Code__c, 'Photo_Reject_Code__c should be Other');
		system.assertEquals('zzz', child.Rejected_Photo_Name__c, 'Rejected_Photo_Name__c should be zzz');
		
		result = ChildPhotoService.RejectPhoto(child.id, 'zzz', 'xxx'); //error because xxx is not a valid value
		system.assertEquals(false, result.success, 'result should be unsuccessful');
	}
}