/***********************************************************************************************************
* Appirio, Inc
* Name         : DonarPortalServiceTest  
* Created By   : Jagjeet Singh (Appirio)
* Purpose      : Test class for DonorPortalService
* Created Date : 03/09/2016 
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 04/04/2016                   Jagjeet Singh           Unit Test Mehtod got GetLTEOptInGlobal.
* 22/03/2016                   Vaibhav Goel            Writing Unit Test Mehtods for task T-485191
* 11/08/2016                   Vaibhav Goel            Adding asserts and code optimization for test-data creation
**********************************************************************************************************/
@isTest
private class DonorPortalServiceTest {
    // Declaring all static variable for Account Record types
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id ACC_CO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    
    //Declaring static variable for contact Record types
    Final Static Id CON_HD_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id CON_PT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    
    //Declaring static variable for Opportunity Record types
    Final Static Id OPP_DON_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    Final Static Id OPP_TRAN_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    
    Static Account HH_Acc, NO_Acc, NO_Acc2, localPartner, community;
    Static Contact householdCon, participantCon, con;
    Static Opportunity donationOpp, transactionOpp;
    static Map<String, Contact> mapRectypeContact;
    
    //Declaring static variable for payment method Record type
    Final Static Id PM_EFT_RT = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
    static rC_Giving__Payment_Method__c paymentMethod;
       
@isTest //testMethod for AddContact
static void AddContactTest(){
//createTestData
createTestData();
Test.startTest();
ContactInfo info = new ContactInfo();
info.name = 'testInforName';
CountriesRefCodes__c counCode = [select Name, Description__c, Active__c from CountriesRefCodes__c limit 1];
if(counCode != null){
info.ctrycode = counCode.Name;
}
WebTitlesRefCodes__c webTitCode =  [select Name, Description__c, Active__c from WebTitlesRefCodes__c limit 1];
if(webTitCode != null){
info.clstnmtitleid = Integer.valueOf(webTitCode.Name);
}
Envelope env = DonorPortalService.AddContact(info);
// system.assertNotEquals(null, env.NewID);

//testing for Catch statement
ContactInfo info1 = new ContactInfo();
Envelope env1 = DonorPortalService.AddContact(info1);
system.assertNotEquals(null, env1.ReturnMessage);
ContactInfo info2 = new ContactInfo();
info2.conttype ='ORG';
info2.inddeceased = 'Y';
info2.indvip = 'Y';
info2.clstnmsuffixid = 2;
info2.cdesstatprovterrid = 4;
info2.phoneareacode = '222';
info2.phone ='1212121212';
info2.email = 'avb@rtet.com';
Envelope env2 = DonorPortalService.AddContact(info2);
system.debug('----env1---' + env1);


Test.stopTest();

}


@isTest //testMethod for AddOrgContact
static void AddOrgContactTest(){
//start Test
//createTestData
createTestData();
Test.startTest();
//ContactInfo Object
ContactInfo info = new ContactInfo();
info.name = 'testInforName';
//Invoke the AddOrgContact of DonorPortalService
Envelope env = DonorPortalService.AddOrgContact(info);
system.assertNotEquals(null, env.NewID);

//stop test
Test.stopTest();

}



@isTest //testMethod for UpdateContact
static void UpdateContactTest(){
//start Test
Test.startTest(); 
//creates the test data
createTestData();
Contact conDb = [select Id, firstname, lastname, rC_Bios__Middle_Name__c, Contact_Number__c from Contact Limit 1];

//Contact Update Info Object
ContactUpdateInfo info = new ContactUpdateInfo();
info.Id = Integer.valueOf(conDb.Contact_Number__c);
info.ctrycode = 'IND';
info.street1  = 'testStreet1';
info.city = 'testInfoCity';
info.middlename =  'testInforMiddleName';
info.clstnmtitleid = 2;
info.cdesstatprovterrid = 12;
info.street2 = 'testInfoStreet2';
info.postalcode = '12311';
info.email = 'testemail@gmail.com';
info.phoneareacode  = '1122';
info.phone = '9898101010';
info.clstnmsuffixid = 45;    
//invoke the DonorPortalService method.
Integer retVal = DonorPortalService.UpdateContact(info);

system.debug('---retVal---'+ retVal);

system.assertEquals(0,retVal);

//stop test
Test.stopTest();

}



@isTest //testMethod for GetContactByEmail
static void GetContactByEmailTest(){
//start Test
Test.startTest();
//creates the test data
createTestData();
//get the Contact From DB
Contact conDb = [select Id,rC_Bios__HOME_Email__c,Contact_Number__c from Contact where recordTypeId =: CON_HD_RT Limit 1 ];

//Invoke the Donor portal Service Method.
Integer retVal = DonorPortalService.GetContactIdByEmail(conDb.rC_Bios__HOME_Email__c);

//asserts
system.assertEquals(retVal,Integer.ValueOf(conDb.Contact_Number__c));

retVal = DonorPortalService.GetContactIdByEmail('test@test.com');
//stop test
Test.stopTest();

}


@isTest //testMethod for GetContactById
static void GetContactByIdTest(){
//start Test
Test.startTest(); 
//createTestData
createTestData();
//get the ContactFromDB
Contact conDB = [select Id, Contact_Number__c from Contact where recordTypeId =: CON_HD_RT Limit 1];
Integer ContactId = Integer.valueOf(conDb.Contact_Number__c);
system.debug('---ContactId---' + ContactId);
//Inkvoke the Donor Service
ContactInfo info = DonorPortalService.GetContactById(ContactId);
system.debug('---info---' + info);
//asserts
system.assertNotEquals(info, null);
system.assertEquals(info.inddeceased, 'N');
system.assertEquals(info.email, 'testhomeemail@test.com');

//update the contact Data to match other conditions
conDB.rC_Bios__Deceased__c = true;
conDb.VIP__c = true;
conDb.Board_Member__c = true;
conDb.rC_Bios__Preferred_Email__c = 'Other';
conDb.rC_Bios__Other_Email__c = 'other@test.com';
conDb.Other_Email_Description__c = 'test other email description';
conDb.rC_Bios__Preferred_Phone__c = 'Home';
conDb.HomePhone = '(804) 555-1212';
update conDb;

//invoke the Donor service with udpated data.
info = DonorPortalService.GetContactById(ContactId);
//asserts
system.assertNotEquals(info, null);
system.assertEquals(info.inddeceased, 'N');
system.assertEquals(info.email, 'other@test.com');
system.assertEquals(info.indboardmember, 'Y');


ContactInfo info1 = DonorPortalService.GetContactById(121111);
system.assertEquals(info1, null);
conDb.rC_Bios__Preferred_Phone__c = 'Work';
update conDb;
DonorPortalService.GetContactById(ContactId);
conDb.rC_Bios__Preferred_Phone__c = 'Mobile';
update conDb;
DonorPortalService.GetContactById(ContactId);
conDb.rC_Bios__Preferred_Phone__c = 'Assistant';
update conDb;
DonorPortalService.GetContactById(ContactId);
conDb.rC_Bios__Preferred_Phone__c = 'Other';
update conDb;
DonorPortalService.GetContactById(ContactId);

//stop Test
Test.stopTest();

}



//Method Name                   : GetPaymentInfoTest
//Purpose                       : testMethod for method 'GetPaymentInfo' of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Vaibhav Goel
//Reference                     : T-485191
//Date                          : April 1,2016
@isTest 
static void GetPaymentInfoTest(){
createTestData();
test.StartTest();

system.debug('----transaction----' + [Select Id, name, StageName, Participant__c, recordTypeId, Amount from opportunity where Id =: transactionOpp.Id]);

List<Contact> primaryConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];
system.debug('----primaryConListAfterInsert----' + primaryConListAfterInsert);
Id conId = primaryConListAfterInsert.get(0).Id;
List<Opportunity> oppList = [select Id , rC_Giving__Primary_Contact__c ,CloseDate,  Amount from Opportunity where Id = :transactionOpp.Id];

system.debug('----oppList----' + oppList);

List<DonationHistoryInfo> DonationHistoryInfoList  = DonorPortalService.GetPaymentInfo(Integer.ValueOF(primaryConListAfterInsert.get(0).Contact_Number__c));
system.debug('----DonationHistoryInfoList----' + DonationHistoryInfoList);
System.assertEquals(DonationHistoryInfoList.get(0).TransAmount ,  oppList.get(0).Amount);
oppList.get(0).Amount = null;
update oppList;
//testing for catch block of method
List<DonationHistoryInfo> DonationHistoryInfoBlankList  = DonorPortalService.GetPaymentInfo(Integer.ValueOF(primaryConListAfterInsert.get(0).Contact_Number__c));
system.debug('----DonationHistoryInfoBlankList----' + DonationHistoryInfoBlankList);
System.assertNotEquals(DonationHistoryInfoList.get(0).TransAmount ,  oppList.get(0).Amount);

test.StopTest();

}




//Method Name                   : AddEmailSubscriptionHistTest
//Purpose                       : testMethod for method 'AddEmailSubscriptionHist' of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Vaibhav Goel
//Reference                     : T-485191 and T-487422
//Date                          : April 4,2016
@isTest 
static void AddEmailSubscriptionHistTest(){

//method has been developed yet, creating test method skeleton. 
test.StartTest();

Envelope EnvelopeInstance  = DonorPortalService.AddEmailSubscriptionHist(123, 123, 'False');
system.assertEquals(null, EnvelopeInstance);

test.StopTest();

}



//Method Name                   : GetContactTaxTotalsTest
//Purpose                       : testMethod for method 'GetContactTaxTotals' of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Vaibhav Goel
//Reference                     : T-485191
//Date                          : April 4,2016
@isTest 
static void GetContactTaxTotalsTest(){

test.StartTest();

createTestData();

Opportunity transactionOppLastYear = TestUtils.createOpportunity(NO_Acc, 'Test transaction Opp LastYear', 100000, false);
transactionOppLastYear.RecordTypeId = OPP_TRAN_RT;
transactionOppLastYear.rC_Giving__Primary_Contact__c = mapRectypeContact.get('Household').Id;
transactionOppLastYear.Participant__c = mapRectypeContact.get('Participant').Id;
transactionOppLastYear.StageName = 'Adjusted';
transactionOppLastYear.rC_Giving__Parent__c = donationOpp.Id;
transactionOppLastYear.CloseDate = Date.newInstance((system.today().year()- 1), system.today().Month(), system.today().Day());
transactionOppLastYear.Amount = 200;
insert transactionOppLastYear;

List<Contact> primaryConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];
system.debug('----primaryConListAfterInsert----' + primaryConListAfterInsert);

TaxTotalInfo TaxTotalInfoInstance  = DonorPortalService.GetContactTaxTotals(Integer.ValueOF(primaryConListAfterInsert.get(0).Contact_Number__c));
system.debug('----TaxTotalInfoInstance----' + transactionOppLastYear.Amount);
system.debug('----TaxTotalInfoInstance----' + TaxTotalInfoInstance);
TaxTotalInfo TaxTotalInfoInstance1  = DonorPortalService.GetContactTaxTotals(123);
system.debug('----TaxTotalInfoInstance1----' + TaxTotalInfoInstance1);
System.assertEquals(0, Decimal.valueOf(TaxTotalInfoInstance1.PreviousYearTotal));

test.StopTest();

}

//Method Name                   : GetAndUpdateHandlingFeeTests
//Purpose                       : testMethod for method 'GetHandlingFee' and 'UpdateHandlingFee' of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Vaibhav Goel
//Reference                     : T-485191
//Date                          : April 4,2016
@isTest 
static void GetAndUpdateHandlingFeeTests(){

test.StartTest();

createTestData();

List<Contact> householdConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];

String getHandlingFeeResult  = DonorPortalService.GetHandlingFee(Integer.ValueOF(householdConListAfterInsert.get(0).Contact_Number__c));
//system.assertEquals('N', getHandlingFeeResult);

String getHandlingFeeNegativeResult  = DonorPortalService.GetHandlingFee(121);
system.assertEquals('N', getHandlingFeeNegativeResult);

Boolean updateResult = DonorPortalService.UpdateHandlingFee(Integer.ValueOF(householdConListAfterInsert.get(0).Contact_Number__c), 'true');
system.assertEquals(true, updateResult);

Boolean updateExceptionResult = DonorPortalService.UpdateHandlingFee(123, 'false');
system.assertEquals(false, updateExceptionResult);

test.StopTest();

}



//Method Name                   : UpdateContactEmailTest
//Purpose                       : testMethod for method 'UpdateContactEmail'  of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Vaibhav Goel
//Reference                     : T-485191
//Date                          : April 4,2016
@isTest 
static void UpdateContactEmailTest(){

test.StartTest();

createTestData();

List<Contact> householdConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];

Integer updateEmailResult  = DonorPortalService.UpdateContactEmail(Integer.ValueOF(householdConListAfterInsert.get(0).Contact_Number__c), 'testupdateemail@test.com');
system.assertEquals(1, updateEmailResult);

Integer updateEmailNegativeResult  = DonorPortalService.UpdateContactEmail(1112, 'testupdateemail@test.com');
system.assertEquals(0, updateEmailNegativeResult);

test.StopTest();

}

//Method Name                   : DeleteEmailSubscriptionTest
//Purpose                       : testMethod for method 'DeleteEmailSubscription'  of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Munib Ur Rehman
//Reference                     : T-485191
//Date                          : April 5,2016
//Modifed By                    : Vaibhav Goel  April 6,2016
@isTest 
static void DeleteEmailSubscriptionTest(){

test.StartTest();

createTestData();

List<Contact> householdConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];

Envelope EnvelopeInstance =  DonorPortalService.deleteEmailSubscription(Integer.ValueOF(householdConListAfterInsert.get(0).Contact_Number__c));
system.assertEquals(null, EnvelopeInstance.TransOut);

//Negative result test
Envelope EnvelopeInstanceNegativeResult = DonorPortalService.deleteEmailSubscription(11112);
system.assertNotEquals(null, EnvelopeInstanceNegativeResult.ReturnMessage);

test.StopTest();

}


//Method Name                  : AddEmailSubscriptionTest
//Purpose                       : testMethod for method 'AddEmailSubscription'  of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Munib Ur Rehman
//Reference                     : T-485191
//Date                          : April 5,2016
//Modified By                   : Vaibhav Goel April 6,2016
@isTest 
static void AddEmailSubscriptionTest(){

test.StartTest();

createTestData();

List<Contact> householdConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];

Envelope EnvelopeInstance = DonorPortalService.AddEmailSubscription(Integer.ValueOF(householdConListAfterInsert.get(0).Contact_Number__c), 2);
system.assertEquals(null, EnvelopeInstance.TransOut);

Envelope EnvelopeInstance1 = DonorPortalService.AddEmailSubscription(Integer.ValueOF(householdConListAfterInsert.get(0).Contact_Number__c), 3);
Envelope EnvelopeInstance2 = DonorPortalService.AddEmailSubscription(Integer.ValueOF(householdConListAfterInsert.get(0).Contact_Number__c), 4);

//Negative result test
Envelope EnvelopeInstanceNegativeResult = DonorPortalService.AddEmailSubscription(11112, 3);

test.StopTest();

}


//Method Name                   : GetLTEOptInGlobalTest
//Purpose                       : testMethod for method 'GetLTEOptInGlobal'  of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Munib Ur Rehman
//Reference                     : T-485191
//Date                          : April 5,2016
@isTest 
static void GetLTEOptInGlobalTest(){

test.StartTest();

createTestData();

List<Contact> householdConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];

LTEOptInGlobalInfo infoRet = DonorPortalService.GetLTEOptInGlobal(Integer.ValueOF(householdConListAfterInsert.get(0).Contact_Number__c));
system.assert(false, '===>'+ [select id,
                            Contact_Number__c
                            from Contact
                            where Contact_Number__c = :householdConListAfterInsert.get(0).Contact_Number__c
                            limit 1]);
    system.assertEquals('Active', infoRet.Status);
test.StopTest();

}


//Method Name                   : StandardizeStreetTest
//Purpose                       : testMethod for method 'StandardizeStreet'  of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Vaibhav Goel
//Reference                     : T-480495
//Date                          : July 7,2016
@isTest                         //testMethod for StandardizeStreet
static void StandardizeStreetTest(){


Experian_REST_API_Settings__c setting = testUtils.createExpRestSetting('Test Experian Setting', 'capture/v1/address-layout/', '12345567688ff', 
'https://api.experianmarketingservices.com/', 'capture/v1/search-address/text/', 'capture/v1/verify-address/text/', false);
setting.Refine_Address_Endpoint__c = 'capture/v1/verify-address/text';
insert setting;

StateTerrProvRefCodes__c stateTerrCodes = testUtils.createStateTerrProvRefCodes('12', true, 'AZ', 'AZ', false);
stateTerrCodes.Description__c = 'test State Description';
insert stateTerrCodes;

//Creating ContactInfo instance which will be passed as a parameter to test the method -  StandardizeStreet
ContactInfo info = testUtils.createContactInfoInstance('testFirstName', 'testName', 'testMiddleName', 'SMALLSYS INC', '795 E DRAGRAM', 'TUCSON', 12, '85705', '12');

test.startTest();

//Calling the DonorPortalService method without mock response.
ContactInfo infoResult1 = DonorPortalService.StandardizeStreet(info);


//calling the mockResponseGenerator class with isVerified= true
AddressValidationMock.isVerified = true;
Test.setMock(HttpCalloutMock.class, new AddressValidationMock());

//Calling the DonorPortalService method.
ContactInfo infoResult2 = DonorPortalService.StandardizeStreet(info);
system.assertNotEquals(null, infoResult2);
system.assertEquals(true, infoResult2.IsValidAddress);
system.debug('---returnedResult---' + infoResult2);

//calling the mockResponseGenerator class with isVerified= false
AddressValidationMock.isVerified = false;
Test.setMock(HttpCalloutMock.class, new AddressValidationMock());
//invoke the DonorPortalService method again.
ContactInfo infoResult3 = DonorPortalService.StandardizeStreet(info);
system.debug('---returnedResult1---' + infoResult3);
system.assertNotEquals(null, infoResult3);
system.assertEquals(false, infoResult3.IsValidAddress);

test.stopTest();
}

//Method Name                   : GetEmailAddressCountTest
//Purpose                       : testMethod for method 'GetEmailAddressCount'  of class 'DonorPortalService'
//@param                        : none
//@return                       : none
//Developer name                : Vaibhav Goel
//Reference                     : T-485191
//Date                          : April 4,2016
@isTest 
static void GetEmailAddressCountTest(){

test.StartTest();

createTestData();

List<Contact> householdConListAfterInsert = [Select Id, rC_Bios__HOME_Email__c, Name, recordTypeId, recordType.Name FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];

Integer GetEmailCountResult  = DonorPortalService.GetEmailAddressCount(householdConListAfterInsert.get(0).rC_Bios__HOME_Email__c);
system.assertNotEquals(0, GetEmailCountResult);

Integer GetEmailCountNegativeResult  = DonorPortalService.GetEmailAddressCount(',');
system.assertEquals(0, GetEmailCountNegativeResult);

test.StopTest();

}
  
    //Method Name                   : GetOptInsBySponsorTest
    //Purpose                       : testMethod for method 'GetOptInsBySponsor'  of class 'DonorPortalService'
    //@param                        : contactId
    //@return                       : List<LTEOptInInfo>
    //Developer name                : Munib Ur Rehman
    //Reference                     : T-485191
    //Date                          : April 18,2016
    @isTest 
    static void GetOptInsBySponsorTest(){
        
        test.StartTest();
        
        createTestData();
        
        Opportunity oppts= [Select Id, Name, rC_Giving__Hard_Credit_Contact__r.Contact_Number__c,
                            Participant__r.National_Office_Number__c, Participant__r.Child_Number__c, 
                            Electronic_Correspondence_Opt_In__c, Child_Correspondence_Opt_In_Date__c, 
                            Salesforce_Opportunity_Code__c, rC_Sponsorship__Sponsorship_Status__c,
                            rC_Giving__Primary_Contact__r.Contact_Number__c
                            FROM Opportunity WHERE rC_Sponsorship__Sponsorship_Status__c = 'Active' 
                            AND recordtype.Name = 'Donation' AND Product_Type__c = 'Sponsorship' 
                            AND Product_Sub_Type__c = 'Child Sponsorship' limit 1];
        
        Contact cont= [SELECT National_Office__r.National_Office_ID__c,National_Office__c from Contact Where ID=:oppts.Participant__c limit 1];
        Account accnts=[Select Id,National_Office_ID__c from Account limit 1 ];
        cont.National_Office__c=accnts.ID;
        update cont;
        
        
        
        String contIds=oppts.rC_Giving__Primary_Contact__r.Contact_Number__c;
        //system.assertEquals(null, contIds);
        //List<Contact> contactListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Participants').Id LIMIT 1];
        
        List<LTEOptInInfo> infoList  = DonorPortalService.GetOptInsBySponsor(Integer.valueof(contIds));
        // system.assertEquals(oppts.Participant__r.National_Office_Number__c, null);
        system.assertEquals(cont.National_Office__r.National_Office_ID__c, null);
        system.assertNotEquals(0, infoList.size());
        //system.assertEquals(Integer.ValueOf(contactListAfterInsert.get(0).Contact_Number__c), infoList.get(0).Contactid);
        
        donationOpp.All_Child_Correspondence__c = false; 
        update donationOpp;
        
        //testing for conditon when donationOpp has All_Child_Correspondence__c = false
        List<LTEOptInInfo> infoList1  = DonorPortalService.GetOptInsBySponsor(Integer.valueof(contIds));
        // system.assertEquals(Integer.ValueOf(contactListAfterInsert.get(0).National_Office_Number__c), infoList1.get(0).Noid);
        DonorPortalService.GetOptInsBySponsor(78);
        
        test.StopTest();
        
    }
    
    
    //Method Name                   : UpdateOptInByChildTest
    //Purpose                       : testMethod for method 'UpdateOptInByChild'  of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-485191
    //Date                          : April 4,2016
    @isTest 
    static void UpdateOptInByChildTest(){
        
        test.StartTest();
        
        createTestData();
        
        Contact participantCon1 = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :participantCon.Id];
        donationOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        update donationOpp;
        Account accnts=[Select Id,National_Office_ID__c from Account where National_Office_ID__c!=null  limit 1 ];
        participantCon1.National_Office__c=accnts.ID;
        update participantCon1;
        participantCon1 = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :participantCon.Id];
        
        boolean updated  = DonorPortalService.UpdateOptInByChild(Integer.ValueOF(participantCon1.Contact_Number__c), Integer.ValueOF(participantCon1.National_Office_Number__c), Integer.ValueOF(participantCon1.Contact_Number__c) , true);
        system.assertEquals(false, updated);
        system.debug('---updated---' + updated);
        
        updated  = DonorPortalService.UpdateOptInByChild(11111, Integer.ValueOF(participantCon1.National_Office_Number__c), Integer.ValueOF(participantCon1.Child_Number__c) , true);
        //Integer GetEmailCountNegativeResult  = DonorPortalService.GetEmailAddressCount(',');
        //system.assertEquals(0, GetEmailCountNegativeResult);
        
        test.StopTest();
        
    }
    
    
    //Method Name                   : GetEmailPublicationsTest
    //Purpose                       : testMethod for method 'GetEmailPublications'  of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-485191
    //Date                          : April 1,2016
    @isTest 
    static void GetEmailPublicationsTest(){
        
        createTestData();
        
        test.StartTest();
        
        //creating 'EmailPublicationRefCodes__c' Custom setting data 
        EmailPublicationRefCodes__c customSetting1 = new EmailPublicationRefCodes__c();
        customSetting1.Name = '2';
        customSetting1.Active__c = true;
        customSetting1.Code__c = 'BDAY';
        customSetting1.Description__c = 'Birthday Annouhcements';
        insert customSetting1;    
        
        EmailPublicationRefCodes__c customSetting2 = new EmailPublicationRefCodes__c();
        customSetting2.Name = '3';
        customSetting2.Active__c = true;
        customSetting2.Code__c = 'EC';
        customSetting2.Description__c = 'E-mail Communications';
        insert customSetting2; 
        
        EmailPublicationRefCodes__c customSetting3 = new EmailPublicationRefCodes__c();
        customSetting3.Name = '4';
        customSetting3.Active__c = true;
        customSetting3.Code__c = 'SA';
        customSetting3.Description__c = 'Statement Announcements';
        insert customSetting3; 
        
        List<Contact> householdConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];
        
        List<EmailSubscriptionsInfo> EmailSubscriptionsInfoList  = DonorPortalService.GetEmailPublications(Integer.ValueOF(householdConListAfterInsert.get(0).Contact_Number__c));
        system.debug('----EmailSubscriptionsInfoList---' + EmailSubscriptionsInfoList.size());
        //system.assertNotEquals(0, EmailSubscriptionsInfoList.size());
        
        List<EmailSubscriptionsInfo> EmailSubscriptionsInfoBlankList  = DonorPortalService.GetEmailPublications(12111);
        system.assertEquals(0, EmailSubscriptionsInfoBlankList.size());
        
        test.StopTest();
        
    }
    
    
    
    //Method Name                   : getSponsorAndUpdateChildTest
    //Purpose                       : testMethod for two methods 'GetOptInsBySponsor' and 'UpdateOptInByChild' of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-485191
    //Date   Modified               : May 3,2016 Purpose : copied method from DonorPortalServiceTestExt to make only one test class
    @isTest 
    static void getSponsorAndUpdateChildTest(){
        
        test.StartTest();
        createTestData();
        Account accnts=[Select Id,National_Office_ID__c from Account where National_Office_ID__c!=null  limit 1 ];
        
        Contact primaryConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];
        primaryConListAfterInsert.National_Office__c=accnts.ID;
        update primaryConListAfterInsert;
        primaryConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :primaryConListAfterInsert.Id LIMIT 1];
        
        Contact participantConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Participant').Id LIMIT 1];
        participantConListAfterInsert.National_Office__c=accnts.ID;
        update participantConListAfterInsert;
        participantConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :participantConListAfterInsert.Id LIMIT 1];
        List<SponsoredChildrenInfo> sponsoredChildrenInfoList = DonorPortalService.GetSponsoredChildren(Integer.ValueOF(participantConListAfterInsert.Child_Number__c));
        List<LTEOptInInfo> optInInfoListLTE = DonorPortalService.GetOptInsBySponsor(Integer.ValueOF(participantConListAfterInsert.Contact_Number__c));
        system.debug('----optInInfoListLTE----' + optInInfoListLTE);
        system.assertEquals('Active', optInInfoListLTE.get(0).Status);
        
        //Testing for negative result
        List<LTEOptInInfo> optInInfoListLTEEmptyList = DonorPortalService.GetOptInsBySponsor(11111);
        system.assertEquals(0, optInInfoListLTEEmptyList.size());
        
        //testing for method - UpdateOptInByChild of class 'DonorPortalService'
        Boolean trueResult = DonorPortalService.UpdateOptInByChild(Integer.ValueOF(participantConListAfterInsert.Contact_Number__c), 
                                                                   Integer.ValueOF(participantConListAfterInsert.National_Office_Number__c), 
                                                                   Integer.ValueOF(participantConListAfterInsert.Child_Number__c), false);
        //system.assertEquals(true, trueResult);
        
        
        //testing method UpdateOptInByChild with some garbage value to cover negative result
        Boolean negativeResult = DonorPortalService.UpdateOptInByChild(111, 222, 333, false);
        system.assertEquals(false, negativeResult);
        test.StopTest();
    }
    
    
    //Method Name                   : PaySetupTest
    //Purpose                       : testMethod for method 'PaySetup'  of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    
    @isTest  //testMethod for PaySetup
    static void PaySetupTest(){
        
        //creates the test data
        createTestData();
        //start Test
        Test.startTest();
        //householdCon.Id
        Contact conDb = [Select Id, Name, AccountId , recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Participant').Id     ];
        Id conId = conDb.Id;
        Account accnts=[Select Id,National_Office_ID__c from Account where National_Office_ID__c!=null  limit 1 ];
        conDb.National_Office__c=accnts.ID;
        //conDb.Community__c=accnts.ID;
        update conDb;
        conDb = [Select Id, Name, AccountId ,recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :condb.Id];
        Opportunity opp = [select Id,Participant__c, rC_Giving__Giving_Amount__c, rC_Giving__Payment_Method_Selected__c, AccountId from Opportunity where Id = :donationOpp.Id];
        List<rC_Giving__Payment_Method__c> paymentMethodList = [select Id, Account_Number_E__c, rC_Giving__Account_Number_Last_4__c, Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where rC_Giving__Is_Active__c = true AND Id =: paymentMethod.Id limit 1];
        if(paymentMethodList.size()>0){
            paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'EFT';
            paymentMethodList.get(0).rC_Giving__Account__c = NO_Acc.Id;
            paymentMethodList.get(0).rC_Giving__Contact__c = conDb.Id;
            paymentMethodList.get(0).rC_Giving__Account_Number_Last_4__c = '421';
            update paymentMethodList;
            System.debug('---first---');
        }
        
        if(opp != null){
            opp.rC_Giving__Payment_Method_Selected__c = paymentMethodList.get(0).Id;
            update opp;
            system.debug('---Second---');
        }
        //Invoke the Donor portal Service Method.
        opp.Participant__c=conDb.ID;
        opp.rC_Giving__Hard_Credit_Contact__c=conDb.ID;
        update opp;
        opp = [select Id, rC_Giving__Giving_Amount__c, Participant__c,Participant__r.Child_Number__c,Participant__r.National_Office_Number__c,rC_Giving__Payment_Method_Selected__c, AccountId from Opportunity where Id = :donationOpp.Id];
        
        List<SponsoredChildrenInfo> infoList = DonorPortalService.PaySetup(Integer.valueOf(conDb.Contact_Number__c));
        system.debug('----infoList---' + infoList.size());
       // System.assertEquals(conDb.Child_Number__c, null);
       //System.assertEquals(null, opp.Participant__r.Child_Number__c);
     //   system.assertEquals(opp.rC_Giving__Giving_Amount__c, infoList.get(0).Amount);
        Test.stopTest();
    }
    
    //Method Name                   : FindContactsTest
    //Purpose                       : testMethod for method 'FindContacts'  of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-493527; T-493508 
    //Date                          : May 04,2016
    @isTest  
    static void FindContactsTest(){
        
        createTestData();
        test.StartTest();
        
        
        Contact conObj = [Select id,Contact_Number__c,recordtype.Name,LastName,MailingCountry,CreatedDate, 
                          rC_Bios__Deceased__c,Preferred_Communication_Method__c,VIP__c,MailingStreet,MailingCity,FirstName, 
                          rC_Bios__Middle_Name__c,Salutation,Custom_Salutation__c,MailingState,MailingPostalCode,Envelope_Salutation__c, 
                          rC_Bios__Preferred_Phone__c,Phone,MobilePhone,HomePhone,OtherPhone,AssistantPhone,Fax, 
                          rC_Bios__Preferred_Email__c,rC_Bios__Home_Email__c,rC_Bios__Work_Email__c, Contact_Flag_Formula__c,
                          rC_Bios__Assistant_Email__c,rC_Bios__Other_Email__c, Board_Member__c,LastModifiedDate,LastModifiedBy.Name 
                          FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];
        conObj.Preferred_Communication_Method__c = 'Mail';
        conObj.rC_Bios__Deceased__c = false;
        conObj.VIP__c = false;
        conObj.rC_Bios__Middle_Name__c = 'testMiddleName';
        conObj.Salutation = 'Mr.';
        conObj.HomePhone = '(804) 555-1212';
        conObj.AssistantPhone = '(804) 555-1212';
        conObj.rC_Bios__Work_Email__c = 'testwork@email.com';
        conObj.rC_Bios__Assistant_Email__c = 'testwork@email.com';
        conObj.Board_Member__c = false;    
        update conObj;
        
        ContactInfo infoObj = new ContactInfo();
        infoObj.id = Integer.ValueOf(conObj.Contact_Number__c);
        infoObj.name = conObj.LastName;
        infoObj.street1 = conObj.MailingStreet;
        infoObj.city  = conObj.MailingCity;
        infoObj.firstname = conObj.FirstName;
        infoObj.postalcode = String.ValueOf(conObj.MailingPostalCode);
        infoObj.email = String.valueOf(conObj.rC_Bios__Home_Email__c);
        infoObj.state = '12';
      /*  Contact cot=[Select Id,AccountId,Contact_Flag_Formula__c from Contact where ID=:infoObj.ID Limit 1];
        System.assertEquals(cot.AccountId, null);
        System.assertEquals(null, cot.Contact_Flag_Formula__c);*/
        
        List<ContactInfo> contactInfoList = DonorPortalService.FindContacts(infoObj);
        //system.assert(false, '====>' + [select id from contact where recordtypeid = :CON_HD_RT and contact_number__c = :conObj.Contact_Number__c ]);
        //System.assertEquals(conObj.MailingStreet, contactInfoList.get(0).street1);
        //system.debug('------contactInfoList---' + contactInfoList);
        
        infoObj.Id = 0;
        List<ContactInfo> contactInfoList1 = DonorPortalService.FindContacts(infoObj);
        //System.assertEquals(conObj.LastName, contactInfoList.get(0).Name);
        
        
        //testing for exception block 
        ContactInfo nullInfoObj = new ContactInfo();
        nullInfoObj = null;
        List<ContactInfo> contactInfoList2 = DonorPortalService.FindContacts(nullInfoObj);
        
        test.StopTest();
        
        
    }
    
    
    //Method Name                   : PaySetupTest
    //Purpose                       : testMethod for method 'PaySetup'  of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    
    @isTest  //testMethod for PaySetup
    static void addWebGiftRecipientsTest(){
        
        //creates the test data
        createTestData();
        //start Test
        Test.startTest();
        
        Contact conDb = [Select Id, Name, AccountId , recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Participant').Id LIMIT 1];
        
        Id conId = conDb.Id;
        
        Opportunity opp = [select Id, rC_Giving__Payment_Method_Selected__c, AccountId from Opportunity where rC_Giving__Primary_Contact__c = :conId Limit 1];
        ContactInfo info = new ContactInfo();
        info.name = 'testInforName';
        CountriesRefCodes__c counCode = [select Name, Description__c, Active__c from CountriesRefCodes__c limit 1];
        if(counCode != null){
            info.ctrycode = counCode.Name;
        }
        WebTitlesRefCodes__c webTitCode =  [select Name, Description__c, Active__c from WebTitlesRefCodes__c limit 1];
        if(webTitCode != null){
            info.clstnmtitleid = Integer.valueOf(webTitCode.Name);
        }
        
        integer retrieved = 0;
        //Invoke the Donor portal Service Method.
        retrieved = DonorPortalService.AddWebGiftRecipient(info);
        System.assert(retrieved != 0);
        Test.stopTest();
    }
    
    //Method Name                   : PaySetupTest
    //Purpose                       : testMethod for method 'PaySetup'  of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    
    @isTest  //testMethod for PaySetup
    static void getWebGiftRecipientsTest(){
        
        //creates the test data
        createTestData();
        //start Test
        Test.startTest();
        
        Contact conDb = [Select Id, Name, AccountId , recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Participant').Id LIMIT 1];
        
        
        List<Opportunity> opps = [select id, rC_Giving__Tribute_Contact__c
                                  from Opportunity
                                  where rC_Giving__Tribute_Contact__c != null
                                  and (rC_Giving__Primary_Contact__r.Contact_Number__c = :String.ValueOf(conDb.Contact_Number__c) or 
                                       rC_Giving__Hard_Credit_Contact__r.Contact_Number__c = :String.ValueOf(conDb.Contact_Number__c))];
        Id conId = conDb.Id;
        
        
        //Invoke the Donor portal Service Method.
        List<ContactInfo> contInfoList = DonorPortalService.GetWebGiftRecipients(Integer.valueOf(conDb.Contact_Number__c));
        System.assertEquals(contInfoList.size(), 1);
        System.assertEquals(con.LastName, contInfoList.get(0).name);
        Test.stopTest();
    }
    
    
    //Method Name                   : UpdateWebGiftRecipientTest
    //Purpose                       : testMethod for method 'UpdateWebGiftRecipient'  of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibha
    //Reference                     : T-493523; T-493527
    //Date                          : June 10,2016
    @isTest  //testMethod for UpdateWebGiftRecipient
    static void UpdateWebGiftRecipientTest(){
        
        test.StartTest();
        
        
        //creates the test data
        createTestData();
        Contact conDb = [Select Id, Name, AccountId , recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :con.Id LIMIT 1];
        
        
        //ContactInfo Object
        
        ContactInfo info = new ContactInfo();
        info.id = integer.valueOF(conDb.Contact_Number__c);
        info.firstName = 'testFirstName';
        info.name= 'testName';
        info.middlename  = 'testMiddleName';
        info.street1 = info.street1;
        info.city = 'testCity';
        info.cdesstatprovterrid = 2;
        info.postalcode = '12345'; 
        info.ctrycode = '12';
        info.clstnmsuffixid = 7;
        info.clstnmtitleid = 8;
        
        //invoke the DonorPortalService method.
        Boolean returnedResult = DonorPortalService.UpdateWebGiftRecipient(info);
        system.debug('---returnedResult---' + returnedResult);
        
        //testing for negative results
        ContactInfo info1;
        Boolean returnedNegativeResult = DonorPortalService.UpdateWebGiftRecipient(info1);
        system.assertEquals(false, returnedNegativeResult);
        
        test.stopTest();
    }
    
    
    @isTest  //testMethod for UpdateWebGiftRecipient
    static void testDeleteWebGiftRecipient(){
        test.StartTest();
        //creates the test data
        createTestData();
        List<Contact> primaryConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];
        system.debug('----primaryConListAfterInsert----' + primaryConListAfterInsert);
        Id conId = primaryConListAfterInsert.get(0).Id;
        DonorPortalService.DeleteWebGiftRecipient(Integer.valueOf(primaryConListAfterInsert.get(0).Contact_Number__c), 123);
        Test.stopTest();
    }
    
    //creates the test data
    static void createTestData() {
        
        rC_Giving__Contact_Setting__c settings = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        settings.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert settings ;
        
        List<account> accList = new List<Account>();
        NO_Acc = TestUtils.createAccountWithRT('1st National Account test', ACC_NO_RT, null, '209', '21245', false);
        //insert NO_Acc;
        accList.add(NO_Acc);
        
        NO_Acc2 = TestUtils.createAccountWithRT('2nd National Account test',ACC_HH_RT, null, '300', '22246', false);
        //insert NO_Acc2;
        accList.add(NO_Acc2);
        
        HH_Acc = TestUtils.createAccountWithRT('1st household Account test', ACC_HH_RT, null, '299', '22245', false);
        //insert HH_Acc;
        accList.add(HH_Acc);
        
        insert accList;
        
        localPartner = TestUtils.createAccount('Local Partner', false);
        localPartner.RecordTypeId = ACC_LP_RT;
        localPartner.ParentId = NO_Acc.Id;
        localPartner.Local_Partner_ID__c = '1121145'; 
        insert localPartner;
        
        community = TestUtils.createAccount('Community', false);
        community.RecordTypeId = ACC_CO_RT;
        community.ParentId = localPartner.Id;
        community.Community_Id__c = '3467';
        community.BillingStreet = 'test Street';
        community.BillingCity = 'test City';
        community.BillingState = 'test State';
        community.BillingPostalCode = '12311';
        community.BillingCountry = 'USA';
        insert community;
        
        //create the rC_Bios__Preferred_Mailing_Address__c test data 
        rC_Bios__Address__c prefMailingAddTemp = TestUtils.createAddress('test Street 1', 'test Street 2', 'test City', '12311', 'USA', false);
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        insert prefMailingAddTemp;
        
        rC_Bios__Address__c prefMailingAdd = [select id, Name, rC_Bios__Street_Line_1__c, rC_Bios__Street_Line_2__c,
                                              rC_Bios__City__c, rC_Bios__State__c, rC_Bios__Postal_Code__c, rC_Bios__Country__c, rC_Bios__Unique_MD5__c
                                              from rC_Bios__Address__c where id = :prefMailingAddTemp.Id limit 1];
        
        system.debug('---prefMailingAdd---' + prefMailingAdd);
        
        mapRectypeContact = new Map<String, Contact>();
        //HH_Acc
        participantCon = TestUtils.createContact(null, 'test Participant first name', 'test Participant last name', false);
        participantCon.accountId = null;
        participantCon.recordTypeId = CON_PT_RT;
        participantCon.National_Office__c = NO_Acc.Id; 
        // participantCon.Community__c = community.id;
        participantCon.Local_Partner__c = localPartner.Id;
        participantCon.Participant_Case_Number__c = '11211';
        participantCon.rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored';
        participantCon.rC_Bios__Birth_Month__c = '02';
        participantCon.rC_Bios__HOME_Email__c = 'testparticipanthomeemail@test.com';
        participantCon.Short_Name__c = 'testShortName';
        participantCon.rC_Bios__Preferred_Mailing_Address__c = prefMailingAdd.Id;
        participantCon.rC_Giving__Track_Hard_Credits__c = true;
        mapRectypeContact.put('Participant', participantCon);
        
        householdCon = TestUtils.createContact(HH_Acc, 'test Household first name', 'test Household last name', false);
        houseHoldCon.rC_Bios__Active__c = true;
        householdCon.recordTypeId = CON_HD_RT;
        householdCon.rC_Bios__HOME_Email__c = 'testhomeemail@test.com';
        householdCon.MailingStreet = 'test street';
        householdCon.MailingCountry = 'test description';
        householdCon.MailingCity = 'test City';
        householdCon.MailingState = 'RJ';
        householdCon.MailingPostalCode = 'test postal Code';
        householdCon.Salutation = 'test salutation';
        householdCon.rC_Bios__Preferred_Phone__c = 'Assistant';
        householdCon.AssistantPhone = '(804) 555-1212';
        householdCon.Fax = '(804) 555-1213';
        householdCon.rC_Bios__Preferred_Email__c = 'Home';
        householdCon.rC_Bios__Preferred_Mailing_Address__c = prefMailingAdd.id;
        householdCon.rC_Bios__Middle_Name__c = 'test Middle Name';
        mapRectypeContact.put('Household', householdCon);
        
        insert mapRectypeContact.Values();
        
        Campaign testCamp = TestUtils.createCampaign('test camp', false);
        testCamp.IsActive = true;
        testCamp.ActualCost = 100;
        testCamp.Product_Type__c = 'Sponsorship'; 
        insert testCamp;
        
        //create the contact data
        con = TestUtils.createContact(NO_Acc2, 'test first name', 'test last name', false);
        con.RecordTypeId = CON_HD_RT;
        con.MailingStreet = 'test street';
        con.MailingCountry = 'test description';
        con.MailingCity = 'test City';
        con.MailingState = 'test Description';
        con.MailingPostalCode = 'test postal Code';
        con.Salutation = 'test salutation';
        con.rC_Bios__Preferred_Phone__c = 'Assistant';
        con.AssistantPhone = '(804) 555-1212';
        con.Fax = '(804) 555-1213';
        con.rC_Bios__Preferred_Email__c = 'Home';
        con.rC_Bios__Home_Email__c = 'home@test.com';
        con.rC_Bios__Preferred_Mailing_Address__c = prefMailingAdd.id;
        con.rC_Bios__Middle_Name__c = 'test Middle Name';
        insert con;
        
        
        rC_Giving__GAU__c testGAU = TestUtils.createGeneralAccountingUnit('600',true);
        
        
        donationOpp = TestUtils.createOpportunity(NO_Acc, 'Test Donation Opp ', 100000, false);
        donationOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        donationOpp.Product_Type__c = 'Sponsorship';
        donationOpp.Product_Sub_Type__c = 'Child Sponsorship';
        donationOpp.RecordTypeId = OPP_DON_RT;
        donationOpp.rC_Giving__Primary_Contact__c = mapRectypeContact.get('Participant').Id;
        donationOpp.Participant__c = mapRectypeContact.get('Participant').Id;
        donationOpp.Child_Correspondence_Opt_In_Date__c = Datetime.newInstance(2016, 2, 17);
        donationOpp.All_Child_Correspondence__c = true;
        donationOpp.rC_Giving__Tribute_Contact__c = con.Id;
        donationOpp.Description__c = 'test Description';
        donationOpp.rC_Giving__Giving_Amount__c = 2000;
        donationOpp.rC_Giving__Giving_Frequency__c = 'One Payment';
        donationOpp.rC_Giving__Hard_Credit_Contact__c = householdCon.Id;
        donationOpp.rC_Sponsorship__Opportunity_Group_Id__c = 202;
        donationOpp.CampaignId = testCamp.Id; 
        donationOpp.Legacy_Type__c = '';
        donationOpp.Paid_Through_Date__c = system.today().Addyears(1); //Date.newInstance(System.Today().Addyears(1).year(), 02, System.Today().day());
        donationOpp.rC_Giving__GAU__c = testGAU.Id;
        donationOpp.rC_Giving__Is_Sustainer__c=true;
        insert donationOpp;
        system.debug('----donationOpp---' + donationOpp); 
        
        
        
        transactionOpp = TestUtils.createOpportunity(NO_Acc, 'Test transaction Opp ', 100000, false);
        transactionOpp.RecordTypeId = OPP_TRAN_RT;
        transactionOpp.rC_Giving__Primary_Contact__c = mapRectypeContact.get('Household').Id;
        transactionOpp.Participant__c = mapRectypeContact.get('Participant').Id;
        transactionOpp.StageName = 'Adjusted';
        transactionOpp.rC_Giving__Parent__c = donationOpp.Id;
        transactionOpp.rC_Giving__Hard_Credit_Contact__c = householdCon.Id;
        transactionOpp.CloseDate = system.today()  - 1;
        transactionOpp.Amount = 200;
        transactionOpp.Legacy_Type__c = '';
        transactionOpp.Product_Type__c = 'Sponsorship';
        transactionOpp.Product_Sub_Type__c = 'Child Sponsorship';
        insert transactionOpp;
        system.debug('----transactionOpp---' + transactionOpp);
        
        
        
        WebTitlesRefCodes__c webTitRefCode = TestUtils.createWebTitlesRefCodes('2', true, false);
        webTitRefCode.Description__c = 'test salutation';
        insert webTitRefCode; 
        
        //CountryRefCodes data.
        CountriesRefCodes__c refCodes = TestUtils.createCountriesRefCodes('IND', true,'IND', false);
        refCodes.Description__c = 'test description';
        insert refCodes;
        
        //creates the state territory codes.
        StateTerrProvRefCodes__c stateTerrCodes = TestUtils.createStateTerrProvRefCodes('12', true, 'RJ','RJA', false);
        stateTerrCodes.Description__c = 'test Description';
        insert stateTerrCodes;
        
        //creating test data for Payment Method records
        rC_Connect__Payment_Method_Setting__c setting = rC_Connect__Payment_Method_Setting__c.getInstance();
        system.debug('---setting--' + setting);
        setting.rC_Connect__Disable_All__c = true;
        insert setting;
        
        rC_Giving__Payment_Method__c paymentMethodToInsert = TestUtils.createPaymentMethod('testPaymentMethod','EFT',true,null,false);
        //paymentMethodToInsert.rC_Giving__Is_Active__c = true;
        paymentMethodToInsert.RecordTypeId = PM_EFT_RT;
        //paymentMethodToInsert.Name = 'testPaymentMethod';
        paymentMethodToInsert.rC_Giving__Contact__c = participantCon.Id;
        paymentMethodToInsert.rC_Connect__Payment_Processor__c = 'Sage'; 
        paymentMethodToInsert.rC_Connect__Merchant_Name__c = 'testMerchantName';
        //paymentMethodToInsert.rC_Giving__Payment_Type__c = 'EFT';
        //paymentMethod.rC_Giving__Account__c = con.AccountId;
        insert paymentMethodToInsert;
        system.debug('---paymentMethod---' + paymentMethod);
        System.debug('---paymentMethodInserted-----'+ [select id from rC_Giving__Payment_Method__c where id =: paymentMethodToInsert.Id]);
        
        paymentMethod = [select Id, RecordTypeId, rC_Connect__Merchant_Name__c, Account_Number_E__c, rC_Connect__Payment_Processor__c,  Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where id =: paymentMethodToInsert.Id  limit 1];
        
    }
    
}