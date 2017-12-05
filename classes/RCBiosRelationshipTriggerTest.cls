// 
// (c) 2015 Appirio, Inc.
//
// Test Class For RCBiosRelationshipTrigger trigger.
//
// 23rd Dec 2015     Sumit Tanwar       Original Ref - T-460324
// 25th Feb 2015     Jagjeet Singh      I-202708
// 08 Aug 2016      Ashu Gupta          Added createTestData method and increased coverage
// 05 Dec 2016      Harsh Singh         Added fifteenDayCorrespondencePausetest method
@isTest
private class RCBiosRelationshipTriggerTest{
    static Opportunity opp;
    static Contact conPart, con2, con3, conPartcipant;
    static Account acc, accChildFund, acLoc, acCom, acNat;
    static Campaign testCamp;
    static Opportunity parentOpp,opportunity;
    
     public static testMethod void createDFCTest(){
     	Test.startTest();
     	createTestData();
        Opportunity oppor = [SELECT id,Auto_Assign_Preference__c 
                            FROM Opportunity 
                            WHERE id=:opportunity.id ];
        oppor.Auto_Assign_Preference__c = true;
        update oppor;
        
        
        
        List<rC_Bios__Preference__c> preferenceList = [SELECT Id,rC_Bios__Category__c,rC_Bios__Subcategory__c,rC_Bios__Active__c
                                                        FROM rC_Bios__Preference__c  ];
        System.assertEquals(preferenceList[0].rC_Bios__Category__c,'Sponsorship');
        System.assertEquals(preferenceList[0].rC_Bios__Subcategory__c,'Contact Search');
        System.assertEquals(preferenceList[0].rC_Bios__Active__c,false);
        
        Test.stopTest();
        
    
     }
   
    //create the test data
    static void createTestData(){
        
        
       
        
        rC_Giving__Contact_Setting__c con_settings = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        con_settings.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert con_settings ;
        
        Id oppTransRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id oppDonRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id conParticipantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        Id sponsorshipRecTypeId = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();
        Id nationalAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        Id commAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        Id localAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        Id childFundRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
        Id relrecTypeId = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Giving').getRecordTypeId();
        
        acc = TestUtils.createAccount('test',true);
        
        List<Account> listOfAcc = new List<Account>();
        accChildFund = TestUtils.createAccount('Test Account',false);
        accChildFund.RecordTypeId = childFundRecId;
        listOfAcc.add(accChildFund);
        
        acNat = TestUtils.createAccount('Test National', false );
        acNat.RecordTypeId = nationalAccRecId;
        acNat.National_Office_ID__c = '909';
        listOfAcc.add(acNat);
        insert listOfAcc;
        
        acLoc = TestUtils.createAccount('Test Local',false);
        acLoc.RecordTypeId = localAccRecId;
        acLoc.ParentId = acNat.Id;
        acLoc.Local_Partner_ID__c = '1233122';
        insert acLoc;
        
        acCom = TestUtils.createAccount('Test Comm', false);
        acCom.RecordTypeId = commAccRecId; 
        acCom.ParentId = acLoc.Id;
        acCom.Community_ID__c = '9099';
        insert acCom;
        
        List<Contact> listOfCon = new List<Contact>();
        
        conPart = TestUtils.createContact(acc,'test', 'Rec1', false);
        conPart.Local_Partner__c = acLoc.Id;
        conPart.National_Office__c = acNat.Id;
        conPart.Community__c = acCom.Id;
        conPart.RecordTypeId = conParticipantRecId;
        conPart.Participant_Case_Number__c = '90998';
        listOfCon.add(conPart);
        
       
        conPartcipant = TestUtils.createContact(acc,'Test First Name','Test Last Name',false);
        conPartcipant.National_Office__c = acNat.Id;
        conPartcipant.RecordTypeId = conParticipantRecId;
        conPartcipant.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        conPartcipant.rC_Bios__Preferred_Phone__c = 'Home';
        conPartcipant.HomePhone = '020-2656768';
        conPartcipant.rC_Bios__Preferred_Email__c = 'Home';
        conPartcipant.rC_Bios__Home_Email__c = 'test@gmail.com';
        conPartcipant.Lifetime_Amount__c = 1000;
        conPartcipant.Last_Gift_Amount__c = 100;
        conPartcipant.Largest_Gift_Amount__c = 500;
        conPartcipant.Largest_Gift_Date__c = date.today();
        conPartcipant.rC_Giving__Track_Hard_Credits__c = true;
        conPartcipant.Accept_DF_Fee__c = true;
        conPartcipant.Donor_Alliance__c = accChildFund.Id;
        conPartcipant.Participant_Case_Number__c = '90998';
        listOfCon.add(conPartcipant);
        
        insert listOfCon;
        
        testCamp = TestUtils.createCampaign('718 - DFC Fee', false);
        testCamp.Product_Type__c  = 'Sponsorship';
        insert testCamp;
        
        rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('600',true);
        
        parentOpp = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
    	parentOpp.recordTypeId  = oppDonRecTypeId;
    	//parentOpp.Participant__c = con3.Id;
        parentOpp.CampaignId = testCamp.Id;
        parentOpp.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        parentOpp.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        //parentOpp.rC_Giving__Hard_Credit_Contact__c = con4.Id;
        parentOpp.DFC_Release_Month_Master__c = 3;
        parentOpp.rC_Giving__GAU__c = gau.Id;
        parentOpp.rC_Giving__Is_Giving__c=false;
       parentOpp.rC_Giving__Is_Sustainer__c=true;
        insert parentOpp;
        
        
        opportunity = TestUtils.createOpportunity(acc,'testOpportunity',100,false);
        opportunity.RecordTypeId = Contact_SnapshotController.OPPORTUNITY_RECORDTYPE_PROSPECTPLAN;
        opportunity.StageName = 'Cultivation';
        opportunity.rC_Giving__Projected_Amount__c = 100;
        opportunity.CloseDate = Date.Today().addMonths(2);
        opportunity.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opportunity.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opportunity.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        //opportunity.rC_Giving__Hard_Credit_Contact__c = con3.Id;
        opportunity.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opportunity.Core_Program_Infants__c = true;
        opportunity.rC_Giving__Parent__c = parentOpp.Id;
        opportunity.rC_Giving__Primary_Contact__c = conPartcipant.Id;
        opportunity.rC_Giving__Is_Giving__c=false;
       opportunity.rC_Giving__Is_Sustainer__c=true;
        
        insert opportunity;
        
        rC_Bios__Preference__c pref = TestUtils.createBiosPref(opportunity,true,sponsorshipRecTypeId,false);
        pref.rC_Bios__Category__c = 'Sponsorship';
        pref.rC_Bios__Subcategory__c = 'Contact Search';
        //pref.rC_Bios__Type__c = 'Participant Number';
        pref.rC_Bios__Status__c = 'Confirmed';
        pref.rC_Bios__Type__c = 'Community';
        insert pref ;    
        
        List<rC_Bios__Relationship__c> listOfRel = new List<rC_Bios__Relationship__c>();
        rC_Bios__Relationship__c rel = TestUtils.createRelation(opportunity,conPart, relrecTypeId, false);
        rel.rC_Bios__Category__c = 'Sponsorship';
        rel.rC_Bios__Role_1__c = 'Participant';
        rel.rC_Bios__Role_2__c = 'Sponsorship Giving';
        listOfRel.add(rel);
        
        
        insert listOfRel;
        
    }
    public static testMethod void  fifteenDayCorrespondencePausetest(){
         Test.startTest();
        rC_Giving__Contact_Setting__c con_settings1 = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        con_settings1.rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert con_settings1 ;
        
        Id oppDonRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id conPart1icipantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        Id nationalAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        Id commAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        Id localAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        Id childFundRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
        Id relrecTypeId = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Giving').getRecordTypeId();
        
        Account testacc = TestUtils.createAccount('test',true);
        
        List<Account> listOfAcc = new List<Account>();
        Account accChildFund1 = TestUtils.createAccount('Test Account',false);
        accChildFund1.RecordTypeId = childFundRecId;
        listOfAcc.add(accChildFund1);
        
        Account acNat1 = TestUtils.createAccount('Test National', false );
        acNat1.RecordTypeId = nationalAccRecId;
        acNat1.National_Office_ID__c = '909';
        listOfAcc.add(acNat1);
        insert listOfAcc;
        
        Account acLoc1 = TestUtils.createAccount('Test Local',false);
        acLoc1.RecordTypeId = localAccRecId;
        acLoc1.ParentId = acNat1.Id;
        acLoc1.Local_Partner_ID__c = '1233122';
        insert acLoc1;
        
        Account acCom1 = TestUtils.createAccount('Test Comm', false);
        acCom1.RecordTypeId = commAccRecId; 
        acCom1.ParentId = acLoc1.Id;
        acCom1.Community_ID__c = '9099';
        insert acCom1;
        
        List<Contact> listOfCon = new List<Contact>();
        
        Contact conPart1 = TestUtils.createContact(testacc,'test', 'Rec1', false);
        conPart1.Local_Partner__c = acLoc1.Id;
        conPart1.National_Office__c = acNat1.Id;
        conPart1.Community__c = acCom1.Id;
        conPart1.RecordTypeId = conPart1icipantRecId;
        conPart1.Participant_Case_Number__c = '90998';
        conPart1.Correspondence_Paused__c=false;
        listOfCon.add(conPart1);
        
        
        Contact conPart1cipant1 = TestUtils.createContact(testacc,'Test First Name','Test Last Name',false);
        conPart1cipant1.National_Office__c = acNat1.Id;
        conPart1cipant1.RecordTypeId = conPart1icipantRecId;
        conPart1cipant1.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        conPart1cipant1.rC_Bios__Preferred_Phone__c = 'Home';
        conPart1cipant1.HomePhone = '020-2656768';
        conPart1cipant1.rC_Bios__Preferred_Email__c = 'Home';
        conPart1cipant1.rC_Bios__Home_Email__c = 'test@gmail.com';
        conPart1cipant1.Lifetime_Amount__c = 1000;
        conPart1cipant1.Last_Gift_Amount__c = 100;
        conPart1cipant1.Largest_Gift_Amount__c = 500;
        conPart1cipant1.Largest_Gift_Date__c = date.today();
        conPart1cipant1.rC_Giving__Track_Hard_Credits__c = true;
        conPart1cipant1.Accept_DF_Fee__c = true;
        conPart1cipant1.Donor_Alliance__c = accChildFund1.Id;
        conPart1cipant1.Participant_Case_Number__c = '90998';
        listOfCon.add(conPart1cipant1);
        
        insert listOfCon;
        
       Campaign testCamp1 = TestUtils.createCampaign('718 - DFC Fee', false);
        testCamp1.Product_Type__c  = 'Sponsorship';
        insert testCamp1;
        
        rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('600',true);
        
        
        Opportunity  pOppty = TestUtils.createOpportunity(testacc,'testOpportunity',100,false);
        pOppty.recordTypeId  = oppDonRecTypeId;
        //pOppty.Participant__c = con3.Id;
        pOppty.CampaignId = testCamp1.Id;
        pOppty.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        pOppty.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        //pOppty.rC_Giving__Hard_Credit_Contact__c = con4.Id;
        pOppty.DFC_Release_Month_Master__c = 3;
        pOppty.rC_Giving__GAU__c = gau.Id;
        pOppty.rC_Giving__Is_Giving__c=false;
        pOppty.rC_Giving__Is_Sustainer__c=true;
        insert pOppty;
        
        
        Opportunity  oppty = TestUtils.createOpportunity(testacc,'testoppty',100,false);
        oppty.RecordTypeId = Contact_SnapshotController.Opportunity_RECORDTYPE_PROSPECTPLAN;
        oppty.StageName = 'Cultivation';
        oppty.rC_Giving__Projected_Amount__c = 100;
        oppty.CloseDate = Date.Today().addMonths(2);
        oppty.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        oppty.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        oppty.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        //oppty.rC_Giving__Hard_Credit_Contact__c = con3.Id;
        oppty.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        oppty.Core_Program_Infants__c = true;
        oppty.rC_Giving__Parent__c = pOppty.Id;
        oppty.rC_Giving__Primary_Contact__c = conPart1cipant1.Id;
        oppty.rC_Giving__Is_Giving__c=false;
        oppty.rC_Giving__Is_Sustainer__c=true;
        
        insert oppty;
        List<rC_Bios__Relationship__c> listOfRel = new List<rC_Bios__Relationship__c>();
        rC_Bios__Relationship__c rel = TestUtils.createRelation(oppty,conPart1, relrecTypeId, false);
        rel.rC_Bios__Category__c = 'Sponsorship';
        rel.rC_Bios__Role_1__c = 'Participant';
        rel.rC_Bios__Role_2__c = 'Sponsorship Giving';
        rel.rC_Bios__Contact_1__c=null;
        oppty.rC_Sponsorship__Sponsorship_Status_Reason__c=null;
        oppty.Sponsorship_Change_Reason_Detail__c='Child Departure - [Age]';
        update oppty;
        rel.rC_Bios__Opportunity__r=oppty;
        listOfRel.add(rel);
        insert listOfRel;
        System.assertEquals('Sponsorship', listOfRel[0].rC_Bios__Category__c);
        System.assertNotEquals(null, listOfRel[0].rC_Bios__Contact_2__c);
        RCBiosRelationshipTriggerHelper.FifteenDayCorrespondencePause(listOfRel);
       // System.assertEquals(conPart1.Correspondence_Paused__c,null);
         Test.stopTest();
        //Code added for FifteenDayCorrespondencePause function ends
    }
}