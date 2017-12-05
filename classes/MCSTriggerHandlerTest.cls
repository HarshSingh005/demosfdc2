/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MCSTriggerHandlerTest 
 * Created By   : Rohit B (Appirio)
 * Purpose      : Test class of MCSTriggerHandler class
 * Created Date : 12/Dec/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * Aug 04, 2016                 Ashu Gupta              Increased code coverage
 * 08/05/2016                   Ravi Chauhan            Ramp Up Code Coverage
 * Aug 08, 2016                 Ashu Gupta              Implemented Coding Standards
 * Sep 09, 2016                 Munib Ur Rehman         Updated Code to incorporate AfterInsert and AfterUpdate method changes
 **********************************************************************************************************/
@isTest
private class MCSTriggerHandlerTest {
    
    private static final String nationalOfficeRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    private static final String localPartnerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    private static final String CommunityRecordType =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    private static final Id relrecTypeId = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Giving').getRecordTypeId();
    private static final String SPONSORSHIP = 'Sponsorship';
    private static final String CHILD_SPONSORSHIP = 'Child Sponsorship';
    static Mail_Control_Slip__c mcsCWL,mcsCBL,mcsTLDF,mcsSL,mcsCRL,mcsCIL,mcsCPR,mcsNDWL,mcsSSNDWL,mcsCSL,mcsCFL,mcsPart;
    static Contact participantToInsert,donor,participant;
    static Account acc,nationalOffice,NO_Acc,localPartner,community;
    static Campaign testCamp;
    static Opportunity opportunity, parentOpp;
    static User testUser;
    
    
    @isTest 
    static void test_method() {
        createTestData();
        Test.startTest();
        Mail_Control_Slip__c upMCSCWL = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsCWL.Id];
        Mail_Control_Slip__c upMCSCBL = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsCBL.Id];
        Mail_Control_Slip__c upMCSTLDF = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsTLDF.Id];
        Mail_Control_Slip__c upMCSSL = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsSL.Id];
        Mail_Control_Slip__c upMCSCRL = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsCRL.Id];
        Mail_Control_Slip__c upMCSCIL = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsCIL.Id];
        Mail_Control_Slip__c upMCSCPR = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsCPR.Id];
        Mail_Control_Slip__c upMCSNDWL = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsNDWL.Id];
        Mail_Control_Slip__c upMCSSSNDWL = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsSSNDWL.Id];
        Mail_Control_Slip__c upMCSCSL = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsCSL.Id];
        Mail_Control_Slip__c upMCSCFL = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsCFL.Id];
        Mail_Control_Slip__c upMCSPART = [SELECT Id, Due_Date__c FROM Mail_Control_Slip__c WHERE Id =: mcsPart.Id];
        
        System.assertEquals(upMCSCWL.Due_Date__c, date.today().addDays(20));
        System.assertEquals(upMCSCBL.Due_Date__c, date.today().addDays(90));
        System.assertEquals(upMCSTLDF.Due_Date__c, date.today().addDays(45));
        System.assertEquals(upMCSSL.Due_Date__c, date.today().addDays(5));
        System.assertEquals(upMCSCRL.Due_Date__c, date.today().addDays(45));
        System.assertEquals(upMCSCIL.Due_Date__c, date.today().addDays(30));
        System.assertEquals(upMCSCPR.Due_Date__c, date.today().addDays(90));
        System.assertEquals(upMCSNDWL.Due_Date__c, date.today().addDays(15));
        System.assertEquals(upMCSSSNDWL.Due_Date__c, date.today().addDays(15));
        
        Contact participantToUpdate = [SELECT id FROM Contact WHERE id =:participantToInsert.id];
        
        participantToUpdate.Local_Partner__c = localPartner.id;
        update participantToUpdate;
        
        upMCSCFL.Alliance_Name__c = 'test';
        update upMCSCFL;
        
        System.assertEquals(upMCSCSL.Due_Date__c, date.today().addDays(5));
        System.assertEquals(upMCSCFL.Due_Date__c, date.today().addDays(60));    
    
        Test.stopTest();
        
    } // END static void test_method() {
    

    static void createTestData(){
        //Accounts to be inserted
        List<Account> listOfAccount = new List<Account>();
        
        Profile profile = TestUtils.getProfile('Standard User');
        testUser = TestUtils.createUser('TestUsertxy1','Alias1', profile.Id, false);
        insert testUser;
        
        rC_Giving__GAU__c testGAU = TestUtils.createGeneralAccountingUnit('600',true);
        
        acc = TestUtils.createAccount('testAccount', false);
        listOfAccount.add(acc);
        
        nationalOffice = TestUtils.createAccountWithRT('National Office', nationalOfficeRecordType, null, '899', '21245', false);
        listOfAccount.add(nationalOffice);
        insert listOfAccount;
        
        localPartner = TestUtils.createAccountWithRT('Local Partner', localPartnerRecordType, nationalOffice, '499', '21246', false);
        localPartner.Participant_Contact_Owner__c = testUser.Id;
        insert localPartner;
        community = TestUtils.createAccountWithRT('Community', CommunityRecordType, localPartner, '699', '2124', true);
        
        //Contact to be inserted
        list<Contact> listOfContact = new List<Contact>();
        participantToInsert = TestUtils.createContact(acc, 'testParticipant_First', 'testParticipant_Last', false);
        participantToInsert.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        participantToInsert.National_Office__c = nationalOffice.id;
        listOfContact.add(participantToInsert);
        
        donor = TestUtils.createContact(acc, 'testDonor_First', 'testDonor_Last', false);
        listOfContact.add(donor);
        
        participant = TestUtils.createContact(acc, 'Bryan', 'Adams', false);
        participant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        participant.Community__c = community.Id;
        participant.National_Office__c = nationalOffice.id;
        participant.Local_Partner__c = localPartner.Id;
        listOfContact.add(participant);
        insert listOfContact;
        
        List<Mail_Control_Slip__c> lstMCS = new List<Mail_Control_Slip__c>();
        
            mcsCWL = TestUtils.createMailControlSlip(donor.Id, 'Child Welcome Letter', 'Active', Null, 'Email', false);
            lstMCS.add(mcsCWL);
            

            mcsCBL = TestUtils.createMailControlSlip(donor.Id, 'Child Bonding Letter', 'Active',Null, 'Email', false);
            lstMCS.add(mcsCBL);
            
            mcsTLDF = TestUtils.createMailControlSlip(donor.Id, 'Thank You Letter for DF', 'Active',Null, 'Email', false);
            lstMCS.add(mcsTLDF);

            mcsSL = TestUtils.createMailControlSlip(donor.Id, 'Sponsor Letter', 'Active',Null, 'Email', false);
            lstMCS.add(mcsSL);

            mcsCRL = TestUtils.createMailControlSlip(donor.Id, 'Child Reply Letter', 'Active',Null, 'Email', false);
            lstMCS.add(mcsCRL);

            mcsCIL = TestUtils.createMailControlSlip(donor.Id, 'Child Initiated Letter', 'Active',Null, 'Email', false);
            lstMCS.add(mcsCIL);

            mcsCPR = TestUtils.createMailControlSlip(donor.Id, 'Child Progress Report', 'Active', Null, 'Email', false);
            lstMCS.add(mcsCPR);

            mcsNDWL = TestUtils.createMailControlSlip(donor.Id, 'National Director Welcome Letter', 'Active',Null, 'Email', false);
            lstMCS.add(mcsNDWL);

            mcsSSNDWL = TestUtils.createMailControlSlip(donor.Id, 'Sub/Shift National Director Welcome Letter', 'Active',Null, 'Email', false);
            lstMCS.add(mcsSSNDWL);

            mcsCSL = TestUtils.createMailControlSlip(donor.Id, 'Child Spontaneous Letter', 'Active',Null, 'Email', false);
            lstMCS.add(mcsCSL);

            mcsCFL = TestUtils.createMailControlSlip(donor.Id, 'Child Farewell Letter', 'Active',Null, 'Email', false);
            lstMCS.add(mcsCFL);
            
             mcsPart = TestUtils.createMailControlSlip(donor.Id, 'Child Farewell Letter', 'Active',null, 'Email', false);
            mcsPart.Participant__c = participantToInsert.id;
            lstMCS.add(mcsPart);
            
            insert lstMCS;
        
        
        //insert Campaign
        testCamp = TestUtils.createCampaign('Test Campaign',false);
        testCamp.Product_Type__c = 'Designated Fund';
        testCamp.Product_Sub_Type__c = 'Belated Christmas';
        insert testCamp;
        
        Id oppTransRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        
        //insert Opportunity
        parentOpp = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        parentOpp.recordTypeId  = oppTransRecTypeId;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.Product_Type__c = SPONSORSHIP;
        parentOpp.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.rC_Giving__Is_Giving__c=false;
        parentOpp.rC_Giving__Is_Sustainer__c=true;
    //    parentOpp.Participant__c = participantToInsert.id;
    
        insert parentOpp;
        
        
        opportunity = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        opportunity.RecordTypeId = Contact_SnapshotController.OPPORTUNITY_RECORDTYPE_PROSPECTPLAN;
        opportunity.StageName = 'Cultivation';
        opportunity.rC_Giving__Projected_Amount__c = 100;
        opportunity.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opportunity.Product_Type__c = SPONSORSHIP;
        opportunity.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opportunity.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opportunity.Core_Program_Infants__c = true;
        opportunity.rC_Giving__Parent__c = parentOpp.Id;
        opportunity.rC_Giving__Primary_Contact__c = participant.Id;
        Opportunity.All_Child_Correspondence__c = true;
        opportunity.rC_Giving__GAU__c = testGAU.Id;
        opportunity.rC_Giving__Is_Giving__c=false;
        opportunity.rC_Giving__Is_Sustainer__c=true;
        insert opportunity;
        
        Opportunity opportunity1 = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        opportunity1.RecordTypeId = Contact_SnapshotController.OPPORTUNITY_RECORDTYPE_PROSPECTPLAN;
        opportunity1.StageName = 'Cultivation';
        opportunity1.rC_Giving__Projected_Amount__c = 100;
        opportunity1.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opportunity1.Product_Type__c = SPONSORSHIP;
        opportunity1.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opportunity1.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opportunity1.Core_Program_Infants__c = true;
        opportunity1.rC_Giving__Parent__c = parentOpp.Id;
        opportunity1.rC_Giving__Primary_Contact__c = participant.Id;
        Opportunity1.All_Child_Correspondence__c = true;
        opportunity1.rC_Giving__GAU__c = testGAU.Id;
        opportunity1.rC_Giving__Is_Giving__c=false;
        opportunity1.rC_Giving__Is_Sustainer__c=true;
        insert opportunity1;
        
        List<rC_Bios__Relationship__c> listOfRel = new List<rC_Bios__Relationship__c>();
        
        rC_Bios__Relationship__c rel = TestUtils.createRelation(opportunity,participant, relrecTypeId, false);
        rel.rC_Bios__Category__c = 'Sponsorship';
        rel.rC_Bios__Role_1__c = 'Sponsor';
        rel.rC_Bios__Role_2__c = 'Participant';
        rel.rC_Bios__Active__c = true;
        listOfRel.add(rel);
        
        rC_Bios__Relationship__c rel1 = TestUtils.createRelation(opportunity,participant, relrecTypeId, false);
        rel1.rC_Bios__Category__c = 'Sponsorship';
        rel1.rC_Bios__Role_1__c = 'Participant';
        rel1.rC_Bios__Role_2__c = 'Sponsorship Giving';
        rel1.rC_Bios__Active__c = true;
        listOfRel.add(rel1);
        
        insert listOfRel;
        Mail_Control_Slip__c mcs = TestUtils.createMailControlSlip('', 'Child Welcome Letter', 'Active',participant.Id, 'Email', false);
        
        insert mcs;

        
    }
} // END private class MCSTriggerHandlerTest {