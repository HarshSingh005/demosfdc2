@isTest
private class TestContact_SnapshotController {
    static Account accWithPlan,accWithoutPlan;
    static Contact contactWithPlan,contactWithoutPlan;
    static Opportunity opportunityWithPlan,opportunityWithoutPlan;
    static Campaign campaign;
    
    @isTest
    static void test_CFD_229_contact_snapshot_with_Planned_Giving() {
        String methodName = 'test_CFD_229_contact_snapshot_with_Planned_Giving';
        
        /*rC_Giving__Contact_Setting__c setting = new rC_Giving__Contact_Setting__c();
        setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert setting;*/
        
        
       rC_Giving__Contact_Setting__c rc_giv_con_st4 = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
       rc_giv_con_st4.rC_Giving__Disable_RollupHardCredits__c = true; 
       upsert rc_giv_con_st4 ; 
        
        createTestData();
        
        
        test.startTest();
            Contact_SnapshotController snapshotControllerObj = new Contact_SnapshotController(new ApexPages.StandardController(contactWithPlan));
            
            snapshotControllerObj.getContactDetailList();
            system.assertEquals(true, !snapshotControllerObj.contactDetailList.isEmpty(), methodName + 'Failed : contact list is empty');
            
            snapshotControllerObj.getRevenueDetailList();
            system.assertEquals(true, !snapshotControllerObj.revenueDetailList.isEmpty(), methodName + 'Failed : revenue list is empty');
            
            snapshotControllerObj.getProspectPlanList();
            system.assertEquals(true, !snapshotControllerObj.prospectPlanList.isEmpty(), methodName + 'Failed : prospect plan list is empty');
            
            snapshotControllerObj.getSponsorshipList();
            system.assertEquals(true, !snapshotControllerObj.sponsorshipList.isEmpty(), methodName + 'Failed : sponsorship list is empty');
            
            snapshotControllerObj.getFundingOpportunityList();
            system.assertEquals(true, !snapshotControllerObj.fundingOpportunityList.isEmpty(), methodName + 'Failed : sponsorship list is empty');
            
            snapshotControllerObj.getPlannedGivingList();
            system.assertEquals(true, !snapshotControllerObj.plannedGivingList.isEmpty(), methodName + 'Failed : sponsorship list is empty');
            
            snapshotControllerObj.getModelingAndPropensityList();
            system.assertEquals(true, !snapshotControllerObj.modelingAndPropensityList.isEmpty(), methodName + 'Failed : sponsorship list is empty');
            
        test.stopTest();
    }
    
    @isTest
    static void test_CFD_229_contact_snapshot_without_planned_giving() {
        String methodName = 'test_CFD_229_contact_snapshot_without_planned_giving';
        
        rC_Giving__Contact_Setting__c setting = new rC_Giving__Contact_Setting__c();
        setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert setting; 
        
        createTestData();
        
        test.startTest();
            Contact_SnapshotController snapshotControllerObj = new Contact_SnapshotController(new ApexPages.StandardController(contactWithoutPlan));
            
            snapshotControllerObj.getContactDetailList();
            system.assertEquals(true, !snapshotControllerObj.contactDetailList.isEmpty(), methodName + 'Failed : contact list is empty');
            
            snapshotControllerObj.getRevenueDetailList();
            system.assertEquals(true, !snapshotControllerObj.revenueDetailList.isEmpty(), methodName + 'Failed : revenue list is empty');
            
            snapshotControllerObj.getProspectPlanList();
            system.assertEquals(true, !snapshotControllerObj.prospectPlanList.isEmpty(), methodName + 'Failed : prospect plan list is empty');
            
            snapshotControllerObj.getSponsorshipList();
            system.assertEquals(true, !snapshotControllerObj.sponsorshipList.isEmpty(), methodName + 'Failed : sponsorship list is empty');
            
            snapshotControllerObj.getFundingOpportunityList();
            system.assertEquals(true, !snapshotControllerObj.fundingOpportunityList.isEmpty(), methodName + 'Failed : sponsorship list is empty');
            
            snapshotControllerObj.getPlannedGivingList();
            system.assertEquals(true, snapshotControllerObj.plannedGivingList.isEmpty(), methodName + 'Failed : sponsorship list is not empty');
            
            snapshotControllerObj.getModelingAndPropensityList();
            system.assertEquals(true, snapshotControllerObj.modelingAndPropensityList.isEmpty(), methodName + 'Failed : sponsorship list is not empty');
            
        test.stopTest();
    }
    static void createTestData(){
        accWithPlan = TestUtils.createAccount('Test Account with Plan',false);
        accWithPlan.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        insert accWithPlan;
        
        contactWithPlan = TestUtils.createContact(accWithPlan,'Test First Name','Test Last Name',false);
        contactWithPlan.RecordTypeId = Contact_SnapshotController.CONTACT_RECORDTYPE_HOUSEHOLD;
        //contactWithPlan.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        contactWithPlan.rC_Bios__Preferred_Phone__c = 'Home';
        contactWithPlan.HomePhone = '020-2656768';
        contactWithPlan.rC_Bios__Preferred_Email__c = 'Home';
        contactWithPlan.rC_Bios__Home_Email__c = 'test@gmail.com';
        contactWithPlan.Lifetime_Amount__c = 1000;
        contactWithPlan.Last_Gift_Amount__c = 100;
        contactWithPlan.Largest_Gift_Amount__c = 500;
        contactWithPlan.Largest_Gift_Date__c = date.today();
        contactWithPlan.rC_Giving__Track_Hard_Credits__c = true;
        insert contactWithPlan;
        
        opportunityWithPlan = TestUtils.createOpportunity(accWithPlan,'Test Opportunity',100,false);
        opportunityWithPlan.RecordTypeId = Contact_SnapshotController.OPPORTUNITY_RECORDTYPE_PROSPECTPLAN;
        opportunityWithPlan.StageName = 'Cultivation';
        opportunityWithPlan.rC_Giving__Projected_Amount__c = 100;
        opportunityWithPlan.CloseDate = Date.Today().addMonths(2);
        opportunityWithPlan.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opportunityWithPlan.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opportunityWithPlan.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opportunityWithPlan.rC_Giving__Hard_Credit_Contact__c = contactWithPlan.Id;
        opportunityWithPlan.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opportunityWithPlan.Core_Program_Infants__c = true;
        insert opportunityWithPlan;
        
        rC_Bios__Relationship__c relationshipObj = new rC_Bios__Relationship__c();
        relationshipObj.RecordTypeId = Contact_SnapshotController.RELATIONSHIP_RECORDTYPE_CONTACT_GIVING;
        relationshipObj.rC_Bios__Contact_2__c = contactWithPlan.Id;
        relationshipObj.rC_Bios__Opportunity__c = opportunityWithPlan.Id;
        relationshipObj.rC_Bios__Active__c = true;
        insert relationshipObj;
        
        campaign = TestUtils.createCampaign('Test Campaign',true);
    
        
        rC_Giving__Planned_Giving__c plannedGiving = new rC_Giving__Planned_Giving__c();
        plannedGiving.RecordTypeId = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        plannedGiving.Name = 'Test Planned Giving';
        plannedGiving.rC_Giving__Stage__c = 'Cultivation';
        plannedGiving.rC_Giving__Contact__c = contactWithPlan.Id;
        plannedGiving.rC_Giving__Account__c = accWithPlan.Id;
        plannedGiving.rC_Giving__Campaign__c = campaign.Id;
        insert plannedGiving;
        
        Modeling_and_Propensity__c modelingAndPropensity = new Modeling_and_Propensity__c();
        modelingAndPropensity.Name = 'Test Modeling and Propensity';
        modelingAndPropensity.Age__c = 30;
        modelingAndPropensity.Marital_Status__c = 'Single';
        modelingAndPropensity.Planned_Giving_Likelihood__c = 12345;
        modelingAndPropensity.Contact__c = contactWithPlan.Id;
        insert modelingAndPropensity;
        
        accWithoutPlan = TestUtils.createAccount('Test Account',false);
        accWithoutPlan.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        insert accWithoutPlan;
        
        contactWithoutPlan = TestUtils.createContact(accWithoutPlan,'Test First Name','Test Last Name',false);
        contactWithoutPlan.RecordTypeId = Contact_SnapshotController.CONTACT_RECORDTYPE_HOUSEHOLD;
        //contactWithoutPlan.Enterprise_Legacy_Id__c = 'Test Legacy Id';
        contactWithoutPlan.rC_Bios__Preferred_Phone__c = 'Home';
        contactWithoutPlan.HomePhone = '020-2656768';
        contactWithoutPlan.rC_Bios__Preferred_Email__c = 'Home';
        contactWithoutPlan.rC_Bios__Home_Email__c = 'test@gmail.com';
        contactWithoutPlan.Lifetime_Amount__c = 1000;
        contactWithoutPlan.Last_Gift_Amount__c = 100;
        contactWithoutPlan.Largest_Gift_Amount__c = 500;
        contactWithoutPlan.Largest_Gift_Date__c = date.today();
        contactWithoutPlan.rC_Giving__Track_Hard_Credits__c = true;
        insert contactWithoutPlan;
        
        opportunityWithoutPlan = TestUtils.createOpportunity(accWithoutPlan,'Test Opportunity',100,false);
        opportunityWithoutPlan.RecordTypeId = Contact_SnapshotController.OPPORTUNITY_RECORDTYPE_PROSPECTPLAN;
        opportunityWithoutPlan.StageName = 'Cultivation';
        opportunityWithoutPlan.rC_Giving__Projected_Amount__c = 100;
        opportunityWithoutPlan.CloseDate = Date.Today().addMonths(2);
        opportunityWithoutPlan.Prospect_Plan_type__c = Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST;
        opportunityWithoutPlan.Product_Type__c = Contact_SnapshotController.SPONSORSHIP;
        opportunityWithoutPlan.Product_Sub_Type__c = Contact_SnapshotController.CHILD_SPONSORSHIP;
        opportunityWithoutPlan.rC_Giving__Hard_Credit_Contact__c = contactWithoutPlan.Id;
        opportunityWithoutPlan.Opportunity_Type__c = Contact_SnapshotController.PHILANTHROPY;
        opportunityWithoutPlan.Core_Program_Infants__c = true;
        insert opportunityWithoutPlan;
        
        rC_Bios__Relationship__c relationshipObjWithoutPlan = new rC_Bios__Relationship__c();
        relationshipObjWithoutPlan.RecordTypeId = Contact_SnapshotController.RELATIONSHIP_RECORDTYPE_CONTACT_GIVING;
        relationshipObjWithoutPlan.rC_Bios__Contact_2__c = contactWithoutPlan.Id;
        relationshipObjWithoutPlan.rC_Bios__Opportunity__c = opportunityWithoutPlan.Id;
        relationshipObjWithoutPlan.rC_Bios__Active__c = true;
        insert relationshipObjWithoutPlan;
        
    }
}