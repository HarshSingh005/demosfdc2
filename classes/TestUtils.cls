/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TestUtils
 * Created By   : Alexandra Loh
 * Purpose      : Test class utility
 * Created Date : 05/Nov/2013
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 09/Dec/2015                  Rohit B (Appirio)       Added a function named "createMailControlSlip"
 * 15/Dec/2015                  Rohit B (Appirio)       Added a function named "createAccountWithRT"
 * 09/Jun/2016                  Ashu Gupta (Appirio)    Added a function named "createCampaign" and "createUndistributedFundsGAU"
 * 22/Jun/2016                  Ashu Gupta (Appirio)    Added a function named "createGlAllocation"
 * 19/July/2016                 Kanika Mathur(Appirio)  Added a function named "createCountriesRefCodes" and "createSponsorshipReserve"
 * 21/July/2016                 Ravi Chauhan (Appirio)  Added function named "createRoutingNumber" and "createPaymentMethod"
 * 05/Aug/2016                  Ashu Gupta (Appirio)    Added a function named "createRelation"
* 11/Aug/2016                   Ashu Gupta (Appirio)    Added a function named "createPrefCode"
* 16/Aug/2016                   Ashu Gupta (Appirio)    Added a function named "createBatchUpload"
**********************************************************************************************************/

@isTest
public with sharing class TestUtils {
    public static Account createAccount(String name, Boolean doInsert){
        Account acc = new Account(Name = name);
        
        //added for failure of contactriggerhandlertest as localid is not of 7digit
        //13 sept 2016 sahil rathore
         string temp;
        do{
        integer rand= Math.round(math.random()*10000000);
        //system.debug('hiii'+rand);
        //system.debug('hiiiiii'+acc.Local_Partner_ID__c);
        temp =string.valueof(rand);
        }while(temp.length() != 7);
            acc.Local_Partner_ID__c= temp; 
        if(doInsert)
            insert acc;
        return acc;
    }
    
    public static Opportunity createOpportunity(Account acc, String name, Double amount, Boolean doInsert){
        Opportunity opp = new Opportunity(AccountId = acc.id, Name = name, Amount = amount,StageName = 'Open', CloseDate = Date.Today().addMonths(2),
                                            Core_Program_Children__c = true, rC_Giving__Giving_Amount__c = 100,Legacy_Type__c = 'Term', RecordTypeId = getRecordTypeId('Grant', 'Opportunity'));
       
        if(doInsert)
            insert opp;
            
        return opp;
    }
    
    public static Contact createContact(Account acc, String firstName, String lastName, Boolean doInsert){
        Contact contact = new Contact(FirstName = firstName, LastName = lastName , 
                                      rC_Bios__Birth_Day__c = '02', rC_Bios__Birth_Month__c = '04',
                                      rC_Bios__Birth_Year__c='2002',Primary_Occupation__c ='Farmer');
        if(acc != null)
            contact.AccountId = acc.id;
       
        if(doInsert)
            insert contact;
            
        return contact;
    }
    
    public static OpportunityTeamMember createOpportunityTeamMember(Opportunity opp, User usr, String role, Boolean doInsert){
        OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(OpportunityId = opp.Id, UserId = usr.Id, TeamMemberRole = role);
       
        if(doInsert)
            insert oppTeamMember;
            
        return oppTeamMember;
    }
    
    public static User createUser(String lastName, String alias, Id profileId, Boolean doInsert){
        User usr = new User(LastName = lastName, Alias = alias , Email = lastName +'@childfund.org', Username = lastName+'@test.com',
                                    ProfileId = profileId, IsActive = true, LanguageLocaleKey = 'en_US', TimeZoneSidKey = 'America/New_York',
                                    EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'en_US');
        
        if(doInsert)
            insert usr;
            
        return usr;    
    }
    
    public static Project__c createProject(String name, String country, String status, Boolean doInsert){
        Project__c project = new Project__c(Name = name, Country__c = country, Status__c = status, Core_Program_Children__c = true);
       
        if(doInsert)
            insert project;
            
        return project;
    }
    
    public static Funding__c createFunding(Id projId, Id oppId, Id nationalOffice, Boolean doInsert){
        Funding__c funding = new Funding__c(Project__c = projId, Opportunity_Name__c = oppId, ChildFund_Office__c = nationalOffice);
        
        if(doInsert)
            insert funding;
            
        return funding;
    }
    
    public static Solicitation_RFP__c createSolicitation(String name, Id accId, Boolean doInsert){
        Solicitation_RFP__c sRFP = new Solicitation_RFP__c(Name = name, Account__c = accId);
        
        if(doInsert)
            insert sRFP;
            
        return sRFP;
    }
     
    public static Exchange_Rate__c createExchangeRate(Id currencyId, Decimal rate, Date startDate, Date endDate, Boolean doInsert){
        Exchange_Rate__c exchangeRate = new Exchange_Rate__c(Currency__c = currencyId, Exchange_Rate__c = rate, Start_Date__c = startDate, End_Date__c = endDate);
        
        if(doInsert)
            insert exchangeRate;
            
        return exchangeRate;
    }
    
    public static Account_Roles__c createAccountRole(Id accId, Id oppId, Boolean doInsert){
        Account_Roles__c accRole = new Account_Roles__c(Account_Name__c = accId, Opportunity_Name__c = oppId);
        
        if(doInsert)
            insert accRole;
            
        return accRole;
    }
    
    public static Currency__c createCurrency(String code, String country, Boolean doInsert){
        Currency__c crncy = new Currency__c(Code__c = code, Country__c = country);
        
        if(doInsert)
            insert crncy;
        
        return crncy;   
    }
    
    public static Task createTask(Date dueDate, String description, String priority, String status, String subject, Boolean doInsert){
        Task t = new Task(ActivityDate = dueDate, Description = description, Priority = priority, Status = status, Subject = subject);
        if(doInsert)
            insert t;
        return t;    
    }
    public static Case createCase(Id caseRecordTypeId, String caseStatus, String casePriority, String agentSkill, Boolean doInsert){
        Case c = new Case(RecordTypeId = caseRecordTypeId, Status = caseStatus, Priority=casePriority, Agent_Skill__c=agentSkill);
        if(doInsert)
            insert c;
        return c;    
    }

    public static Case createCase(Id caseRecordTypeId, String caseStatus, String casePriority, String agentSkill, Boolean doInsert, Id accId, Id conId){
        Case c = new Case(RecordTypeId = caseRecordTypeId, Status = caseStatus, Priority=casePriority, Agent_Skill__c=agentSkill, AccountId = accId, ContactId = conId);
        if(doInsert)
            insert c;
        return c;    
    }
    
    public static PermissionSet createPermissionSet(String name, String label, UserLicense ul, Boolean doInsert){
        PermissionSet pSet = new PermissionSet(Name = name, Label = Label, UserLicenseId = ul.Id);
        if(doInsert)
            insert pSet;
        return pSet;    
    }
    
    public static Profile getProfile(String profileName){
        return [SELECT Id FROM Profile WHERE Name like: '%'+profileName+'%' limit 1];
    }
    
    public static UserLicense getUserLicense(String ulName){
        return [SELECT Id FROM UserLicense WHERE Name like: '%'+ulName+'%' limit 1];
    }
    
    public static Id getRecordTypeId(String name, String sObj){
        return [SELECT Id FROM RecordType WHERE DeveloperName =: name AND SObjectType =: sObj].Id;
    }

    //Added by Rohit B on 09/Dec/2015; This method is used for creating Mail Control Slip. 
    public static Mail_Control_Slip__c createMailControlSlip(String DonorID, String letterType, String status,
                                                                 ID ParticipantID, String recordType, Boolean isInsert) {

        // Note: don't use recordtype for MCS, will be removed
        // no need to set status or donor - this is done by the trigger
        
        Mail_Control_Slip__c mcs = new Mail_Control_Slip__c(
            Participant__c = (ID) ParticipantID,
            MCS_Letter_Type__c = letterType, 
            Comments__c = 'testComments'
        );

        if(isInsert)
            insert mcs;
        return mcs;
    }

    //Added by Rohit B on 15/Dec/2015 for creating account with specified RT and parent account
    public static Account createAccountWithRT(String name, String recordTypeID, Account parentAcc, String noId, String commID, Boolean isInsert){
        Account acc = new Account(Name = name, RecordTypeId = recordTypeID, rC_Bios__Active__c = true);
        if(parentAcc != Null)
            acc.ParentId = parentAcc.Id;
       // acc.National_Office_ID__c = noId;
        acc.Community_ID__c = commID;
        string temp;
        String cmnty;
        String noi;
       do{
        integer rand= Math.round(math.random()*10000000);
        //system.debug('hiii'+rand);
        //system.debug('hiiiiii'+acc.Local_Partner_ID__c);
        temp =string.valueof(rand);
        }while(temp.length() != 7);
         if(commID!=null){
         do{
        integer rand= Math.round(math.random()*10000);
          cmnty =string.valueof(rand);
        }while(cmnty.length() != 4);
         }     
        String chars='0123456789';
        String naID = '' ;
        
        while(naID.length()<3){
            Integer Idx=Math.mod(MAth.abs(Crypto.getRandomInteger()),chars.length());
            naID  +=chars.substring(Idx,Idx+1);             
        }
        acc.Community_ID__c=cmnty;       
        if(noID!=null)
        acc.National_Office_ID__c =naID;
        acc.Local_Partner_ID__c = temp; 
        system.debug('hiiiiii'+acc.Local_Partner_ID__c);
        if(isInsert)
            insert acc;
        return acc;
    }
 
    public static rC_Giving__GAU__c createGeneralAccountingUnit(String gauName , Boolean isInsert){
        rC_Giving__GAU__c gau = new rC_Giving__GAU__c(Name = gauName) ;
        if(isInsert)
            insert gau;
        return gau;
    }
    public static Standard_Allocation__c createStandardAllocation(String GLCode , String GAUId , Boolean isInsert){
        Standard_Allocation__c standardAllocation = new Standard_Allocation__c(Name = GLCode, GAU__c = GAUId, GL_Account__c=GAUId);
        if(isInsert)
            insert standardAllocation;
        return standardAllocation;
    }
    //Added by Ashu Gupta on 09/Jun/2016 for creating a new Campaign
    public static Campaign createCampaign(String CampName , Boolean isInsert){
        Campaign camp = new Campaign(Name = CampName , IsActive = true , ActualCost = 100);
        if(isInsert)
            insert camp;
        return camp;
    }
    //Added by Ashu Gupta on 09/Jun/2016 for creating an UndistributedFundsGAU 
    public static Undistributed_Funds_GAU__c createUndistributedFundsGAU(String ufGAUName, String GAUId, Boolean isInsert){
        Undistributed_Funds_GAU__c ufGAU = new Undistributed_Funds_GAU__c(Name = ufGAUName, SFDC_Id__c = GAUId);
        if(isInsert)
            insert ufGAU;
        return ufGAU;
    }
    
    //Added by Ashu Gupta on 22/Jun/2016 for creating a new GL Allocation  
    public static GL_Allocation__c createGlAllocation( String GAUId,Boolean isInsert){
        GL_Allocation__c glAllocation = new GL_Allocation__c(GL_Account__c = GAUId);
        if(isInsert)
            insert glAllocation;
        return glAllocation;
    } 
    
    public static Contact createCommContact(String firstName, String lastName,Community comm, Boolean doInsert){
        Contact contact = new Contact(FirstName = firstName, LastName = lastName,Community__c = comm.id, Participant_Case_Number__c = '87654', rC_Sponsorship__Sponsorship_Status__c = 'Sponsored');
       
        if(doInsert)
            insert contact;
            
        return contact;
    }
    
    //Added by Kanika Mathur on 19/July/2016 for creating a new CountriesRefCodes
    public static CountriesRefCodes__c createCountriesRefCodes(String name, Boolean active, String code, Boolean doinsert) {
        CountriesRefCodes__c crc = new CountriesRefCodes__c(Name = name, Active__c = active, Code__c = code);
    
        if(doInsert)
            insert crc;

        return crc;
    }

    //Added by Kanika Mathur on 19/July/2016 for creating a new Sponsorship Reserve.
    public static rC_Sponsorship__Reserve__c createSponsorshipReserve(String name, Boolean doInsert) {
        rC_Sponsorship__Reserve__c spres = new rC_Sponsorship__Reserve__c(Name = name);

        if(doInsert)
            insert spres;

        return spres;
    }
     //Added by Munib Rehman on 19/July/2016 for creating a new Email Exclusion Record
    public static Email_Exclusion__c createEmailExclusion(String name, String email, String pubCode, Boolean doInsert) {
        Email_Exclusion__c exclusion1 = new Email_Exclusion__c();
        exclusion1.Name = name;
        exclusion1.Email__c = email;
        exclusion1.EPub_Code__c = pubCode;

        if(doInsert)
            insert exclusion1;

        return exclusion1;
    }

    //Added by Kanika Mathur on 20/July/2016 for creating a new Web Exception record.
    public static Web_Transaction__c createWebTransaction(Boolean doInsert) {
        Web_Transaction__c wt = new Web_Transaction__c();

        if(doInsert)
            insert wt;

        return wt;
    }

    //Addded by Kanika Mathur on 20/July/2016 for creating a new rC_Connect__Batch_Upload__c
    public static rC_Connect__Batch_Upload__c createBatchUpload(String name, Boolean doInsert) {
        rC_Connect__Batch_Upload__c upload = new rC_Connect__Batch_Upload__c(Name = name);
        
        if(doInsert)
            insert upload;

        return upload;
    }
    
    //Added by Ravi Chauhan on 20/July/2016 for creating a new PartnerCountriesRefCodes__c
    public static PartnerCountriesRefCodes__c createPartnerCountriesRefCodes(String name, Boolean active, String description, Boolean doinsert) {
        PartnerCountriesRefCodes__c prc = new PartnerCountriesRefCodes__c(Name = name, Active__c = active, Description__c = description);
    
        if(doInsert)
            insert prc;

        return prc;
    }
    
    //Added by Ravi Chauhan on 20/July/2016 for creating a new StateTerrProvRefCodes__c
    public static StateTerrProvRefCodes__c createStateTerrProvRefCodes(String name, Boolean active, String code, String codeType, Boolean doinsert) {
        StateTerrProvRefCodes__c stpr = new StateTerrProvRefCodes__c(Name = name, Active__c = active, Code__c = code, Code_Type__c = codeType);
    
        if(doInsert)
            insert stpr;

        return stpr;
    } 
    
    //Added by Ravi Chauhan on 20/July/2016 for creating a new WebTitlesRefCodes__c
    public static WebTitlesRefCodes__c createWebTitlesRefCodes(String name, Boolean active, Boolean doinsert) {
        WebTitlesRefCodes__c wtr = new WebTitlesRefCodes__c(Name = name, Active__c = active);
    
        if(doInsert)
            insert wtr;

        return wtr;
    }
    
    //Added by Ravi Chauhan on 20/July/2016 for creating a new WebSuffixRefCodes__c
    public static WebSuffixRefCodes__c createWebSuffixRefCodes(String name, Boolean active, Boolean doinsert) {
        WebSuffixRefCodes__c wsr = new WebSuffixRefCodes__c(Name = name, Active__c = active);
    
        if(doInsert)
            insert wsr;

        return wsr;
    }
    
    //Added by Ravi Chauhan on 20/July/2016 for creating a new Prank_Phone__c
    public static Prank_Phone__c createPrankPhone(String phoneNumber, Boolean doinsert) {
        Prank_Phone__c pp = new Prank_Phone__c(Phone__c = phoneNumber);
    
        if(doInsert)
            insert pp;

        return pp;
    }  
    
    public static rC_Bios__Address__c createAddress(String Addressline1, String Addressline2, String city, String postalCode, String country , Boolean doInsert) {
        rC_Bios__Address__c prefMailingAddTemp  = new rC_Bios__Address__c();
        prefMailingAddTemp.rC_Bios__Street_Line_1__c = Addressline1+String.valueOf(System.now());
        prefMailingAddTemp.rC_Bios__Street_Line_2__c = Addressline2;
        prefMailingAddTemp.rC_Bios__City__c = city;
        prefMailingAddTemp.rC_Bios__Postal_Code__c = postalCode;
        prefMailingAddTemp.rC_Bios__Country__c = country;
        if(doInsert)
            insert prefMailingAddTemp;

        return prefMailingAddTemp;
    }
    
    //Added by Ravi Chauhan on 21/July/2016 for creating a new rC_Giving__Payment_Method__c
    public static rC_Giving__Payment_Method__c createPaymentMethod(String name, String paymentType, Boolean active, Account acc, Boolean doinsert) {
        rC_Giving__Payment_Method__c payMethod = new rC_Giving__Payment_Method__c(Name = name,rC_Giving__Payment_Type__c = paymentType,
                                                                                  rC_Giving__Is_Active__c = active);
        if(acc !=null)
            payMethod.rC_Giving__Account__c = acc.Id ;                                                                          
    
        if(doInsert)
            insert payMethod;

        return payMethod;
    }
    
    //Added by Ravi Chauhan on 21/July/2016 for creating a new Routing_Number__c
    public static Routing_Number__c createRoutingNumber(String routingNumber, Account acc, Boolean doinsert) {
        Routing_Number__c routeNumber = new Routing_Number__c(Routing_Number__c = routingNumber);
        if(acc != null)
            routeNumber.Bank__c = acc.Id ;                                                                          
    
        if(doInsert)
            insert routeNumber;

        return routeNumber;
    }

    //Added by Kanika Mathur on 21/July/2016 for creating a new rC_Bios__Preference__c record
    public static rC_Bios__Preference__c createBiosPref(Opportunity opp, Boolean isActive, Id recordType, Boolean doInsert) {
        rC_Bios__Preference__c pref = new rC_Bios__Preference__c(rC_Bios__Active__c = isActive, RecordTypeId = recordType);
        if(opp != null)
            pref.rC_Sponsorship__Opportunity__c = opp.Id;

        if(doInsert)
            insert pref;

        return pref;
    }   

    //Added by Kanika Mathur on 21/July/2016 for creating a new partner user
    public static User createPartnerUser(String lastName, String alias, Id profileId, Contact con, Boolean doInsert){
        User usr = new User(LastName = lastName, Alias = alias , Email = lastName +'@childfund.org', Username = lastName+'@test.com',
                                    ProfileId = profileId, IsActive = true, LanguageLocaleKey = 'en_US', TimeZoneSidKey = 'America/New_York',
                                    EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'en_US', ContactId = con.Id);
        
        if(doInsert)
            insert usr;
            
        return usr;    
    }
    
     public static Obligation__c createObligation(Account acc, Boolean doInsert){
        Obligation__c obligation = new Obligation__c();
        if(acc != null){
            obligation.National_Office__c = acc.Id;    
        }
        
        if(doInsert)
            insert obligation;
            
        return obligation;
    }
    
    //Added by Vaibhav Goel on 25/July/2016 for creating a new rC_Bios__Account_Address__c record
    public static rC_Bios__Account_Address__c createAccountAddress(Account acc, rC_Bios__Address__c biosAddress, Boolean toInsert){
        rC_Bios__Account_Address__c accAddress = new rC_Bios__Account_Address__c();
        accAddress.rC_Bios__Account__c = acc.Id;
        accAddress.rC_Bios__Address__c = biosAddress.Id;
        if(toInsert){
            insert accAddress;
        }
        return accAddress;
    }
    
    //Added by Vaibhav Goel on 25/July/2016 for creating a new rC_Bios__Contact_Address__c record
    public static rC_Bios__Contact_Address__c createContactAddress(Contact con, rC_Bios__Address__c biosAddress, Boolean toInsert){
        rC_Bios__Contact_Address__c conAddress = new rC_Bios__Contact_Address__c();
        conAddress.rC_Bios__Contact__c = con.Id;
        conAddress.rC_Bios__Address__c = biosAddress.Id;
        if(toInsert){
            insert conAddress;
        }
        return conAddress;
    }
    
    //Added by Vaibhav Goel on 28/July/2016 for creating a new rC_Bios__Address__c record
    public static rC_Bios__Address__c createBiosAddress(String nameOfRec, String streetline1, String streetline2, String city, String extraAddress1, String state, 
                                                        String postalCode, String country, String careOf, String envelopeLine, Boolean returnedMail, Boolean validated, Boolean doInsert) {
        rC_Bios__Address__c testBiosAdd  = new rC_Bios__Address__c();
        testBiosAdd.name = nameOfRec;
        testBiosAdd.rC_Bios__Street_Line_1__c = streetline1;
        testBiosAdd.rC_Bios__Street_Line_2__c = streetline2;
        testBiosAdd.rC_Bios__City__c = city;
        testBiosAdd.Extra_Address_1__c = extraAddress1;
        testBiosAdd.rC_Bios__State__c = state;
        testBiosAdd.rC_Bios__Postal_Code__c = postalCode;
        testBiosAdd.rC_Bios__Country__c = country;
        testBiosAdd.Care_of__c = careOf;
        testBiosAdd.Envelope_Line__c = envelopeLine;
        testBiosAdd.Ind_Returned_Mail__c = returnedMail;
        testBiosAdd.Validated__c = validated;
        if(doInsert)
            insert testBiosAdd;

        return testBiosAdd;
    }
    
      //Addded by Munib Ur Rehman  on 28/July/2016 for creating a new rC_Giving__Batch__c
    public static rC_Giving__Batch__c createBatch(String name, Decimal totalVal , Integer totalNum , Boolean doInsert) {
        rC_Giving__Batch__c batch = new rC_Giving__Batch__c(Name = name);
        batch.rC_Giving__Total_Value__c = totalVal;
        batch.rC_Giving__Total_Number__c = totalNum;
        if(doInsert)
            insert batch;

        return batch;
    }
    public static rC_Bios__Relationship__c createRelation(Opportunity opp, Contact con, Id recordType, Boolean doInsert){
        rC_Bios__Relationship__c relation = new rC_Bios__Relationship__c();
        relation.RecordTypeId = recordType;
        relation.rC_Bios__Opportunity__c = opp.Id;
        relation.rC_Bios__Contact_2__c = con.Id;
        if(doInsert)
            insert relation;

        return relation;
    }
    public static rC_Bios__Preference_Code__c createPrefCode(String category, String Subcategory, String Type, String Subtype, Boolean doInsert){
        rC_Bios__Preference_Code__c prefCode = new rC_Bios__Preference_Code__c();
        prefCode.rC_Bios__Category__c = category;
        prefCode.rC_Bios__Subcategory__c = Subcategory;
        prefCode.rC_Bios__Type__c = Type;
        prefCode.rC_Bios__Subtype__c = Subtype;
        if(doInsert)
            insert prefCode;

        return prefCode;
    }
    
    public static Experian_REST_API_Settings__c createExpRestSetting(string name, string addlayoutEndpoint, string authT, string baseUrl, string searchAddEndpoint, string verifyAddEndPoint, boolean isInsert){
        Experian_REST_API_Settings__c setting = new Experian_REST_API_Settings__c();
        setting.name = name;
        setting.Address_Layout_Endpoint__c = addlayoutEndpoint;
        setting.Auth_Token__c = authT;
        setting.Base_URL__c = baseUrl;
        setting.Search_Address_Endpoint__c = searchAddEndpoint;
        setting.Verify_Address_Endpoint__c = verifyAddEndPoint;
        if(isInsert){
            insert setting;
        }
        return setting;
        
    }
    
    public static ContactInfo createContactInfoInstance(String firstName, string standardName, 
                                                        string middleName, string street1, string street2, string city, 
                                                        integer cdesstatprovterrid, string postalCode, string ctrycode){
        ContactInfo infoInstance = new ContactInfo();
        infoInstance.firstName = firstName;
        infoInstance.name= standardName;
        infoInstance.middlename  = middleName;
        infoInstance.street1 = street1;
        infoInstance.street2 = street2;
        infoInstance.city = city;
        infoInstance.cdesstatprovterrid = cdesstatprovterrid;
        infoInstance.postalcode = postalCode;
        infoInstance.ctrycode = ctrycode;
        return infoInstance;        
    }
     public static Batch_Upload_Distribution__c createBatchUploadDistribution(String name, Id upload, Id camp, Id gau, Id opportunity, Boolean doInsert) {
        Batch_Upload_Distribution__c batchUploadDist = new Batch_Upload_Distribution__c();
        batchUploadDist.name = name;
        batchUploadDist.Batch_Upload__c = upload;
        batchUploadDist.Campaign__c = camp;
        batchUploadDist.GAU__c = gau;
        batchUploadDist.Opportunity__c = opportunity;
        batchUploadDist.Product_Type__c = 'Sponsorship';
        batchUploadDist.Close_Date__c = System.today();
         
        if(doInsert)
            insert batchUploadDist;

        return batchUploadDist;
    }
    //Added by Ashu Gupta on 17/Aug/2016 for creating a new Apex Log
     public static Apex_Log__c createApexLog(String className,String methodName, String message,Boolean doInsert) {
        Apex_Log__c apexLog = new Apex_Log__c(class_name__c = className, method_name__c = methodName, message__c = message);
        if(doInsert)
            insert apexLog;

        return apexLog;
    }   

    
}