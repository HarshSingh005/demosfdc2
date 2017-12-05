/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PreferenceTriggerHandlerTest 
 * Created By   : Kanika Mathur (Appirio)
 * Purpose      : Test class of PreferenceTriggerHandler class
 * Created Date : 21/July/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/12/2016                   Ravi Chauhan            Fixed Test failure
 **********************************************************************************************************/
@isTest
private class PreferenceTriggerHandlerTest {

    final static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    final static Id OPP_DON_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    final static Id BP_SP_RT = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();
    final static Id CAMP_CC_RT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Childfund Campaign').getRecordTypeId();
    final static Id CON_PT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    static User u;
    static Opportunity donation;
    static UserRole ur;
    
    private static testMethod void onBeforeUpdateTest() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        String sysAdminUserProfileID = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        User userToinsertUserRole = TestUtils.createUser('Beiber','JustBe',sysAdminUserProfileID,false);
        userToinsertUserRole.userRoleId = r.Id;
        insert userToinsertUserRole;
        
        System.runAs(userToinsertUserRole){
            createTestData();
            Account partner = TestUtils.createAccount('testAccount', true);

            Contact partnerContact = TestUtils.createContact(partner, 'Test', 'Contact1', true);
            
            String allianceUserProfileID = [SELECT Id FROM Profile WHERE Name='Alliance Partner User' LIMIT 1].Id;
            u = TestUtils.createPartnerUser('testLname', 'tuname', allianceUserProfileID, partnerContact, true);
        }

        System.runAs(u){
            Test.startTest();

            List<rC_Bios__Preference__c> prefList = new List<rC_Bios__Preference__c>();
            rC_Bios__Preference__c pref = TestUtils.createBiosPref(null, true, BP_SP_RT, false);
            pref.rC_Bios__Category__c = 'Sponsorship';
            pref.rC_Bios__Subcategory__c = 'Contact Search';
            pref.rC_Bios__Type__c = 'Religion';
            pref.rC_Bios__Subtype__c = 'Gamo';
            pref.Auto_Assign_Preference__c = true;
            prefList.add(pref);
            insert prefList;

            pref.rC_Bios__Subtype__c = 'Asian';
            Database.SaveResult[] srList = Database.update(prefList, false);
            for(Database.SaveResult sr : srList){
                System.assert(!sr.isSuccess());
            }
            Test.stopTest();
        }
    }
    
    private static testMethod void onBeforeDeleteTest() {
        
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        String sysAdminUserProfileID = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        User userToinsertUserRole = TestUtils.createUser('Beiber','JustBe',sysAdminUserProfileID,false);
        userToinsertUserRole.userRoleId = r.Id;
        insert userToinsertUserRole;
        
        System.runAs(userToinsertUserRole){
            createTestData();
            Account partner = TestUtils.createAccount('testAccount', true);

            Contact partnerContact = TestUtils.createContact(partner, 'Test', 'Contact1', true);
            
            String allianceUserProfileID = [SELECT Id FROM Profile WHERE Name='Alliance Partner User' LIMIT 1].Id;
            u = TestUtils.createPartnerUser('testLname', 'tuname', allianceUserProfileID, partnerContact, true);
        }
        
        System.runAs(u){ 
            Test.startTest();
            List<rC_Bios__Preference__c> prefList = new List<rC_Bios__Preference__c>();
            rC_Bios__Preference__c pref = TestUtils.createBiosPref(null, true, BP_SP_RT, false);
            pref.rC_Bios__Category__c = 'Sponsorship';
            pref.rC_Bios__Subcategory__c = 'Contact Search';
            pref.rC_Bios__Type__c = 'Religion';
            pref.rC_Bios__Subtype__c = 'Gamo';
            pref.Auto_Assign_Preference__c = true;
            prefList.add(pref);
            insert prefList;

            Database.DeleteResult[] drList = Database.delete(prefList, false);
            for(Database.DeleteResult dr : drList){
                System.assert(!dr.isSuccess());
            }
            Test.stopTest();
        }
        
    }
    
    private static void createTestData() {

        /*rC_Giving__Contact_Setting__c setting = new rC_Giving__Contact_Setting__c();
        setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert setting; */

        rC_Giving__Contact_Setting__c rc_con_settings = rC_Giving__Contact_Setting__c.getOrgDefaults(); 
        rc_con_settings .rC_Giving__Disable_RollupHardCredits__c = true; 
        upsert rc_con_settings;

        Account household = TestUtils.createAccount('testAccount', false);
        household.RecordTypeId = ACC_HH_RT;
        insert household;

        Contact participant = TestUtils.createContact(household, 'Test', 'Contact1', false);
        participant.RecordTypeId = CON_PT_RT;
        insert participant;

        Campaign camp = TestUtils.createCampaign('test Camp', false);
        camp.RecordTypeId = CAMP_CC_RT;
        insert camp;

        donation = TestUtils.createOpportunity(household, 'testOpp', 100, false);
        donation.RecordTypeId = OPP_DON_RT;
        donation.Campaign = camp;
        donation.Product_Type__c = 'Designated Fund';
        donation.Product_Sub_Type__c = 'Birthday';
        donation.Description__c = 'test Description';
        donation.rC_Giving__Hard_Credit_Contact__c = participant.Id;
        //insert donation;
       
    }
}