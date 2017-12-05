/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PreferencesControllerTest 
 * Created By   : Rohit B (Appirio)
 * Purpose      : Test class of PreferencesController class
 * Created Date : 04/Jan/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * Aug 02, 2016                 Ashu Gupta            Added test_PreferencesControllerTestNew to increase code coverage 
 * Aug 11, 2016                 Ashu Gupta              Added more asserts
 **********************************************************************************************************/
@isTest
private class PreferencesControllerTest {
    static Opportunity opty;
    static Account NO_Acc, LP_Acc, Com_Acc;

    @isTest 
    static void test_PreferencesControllerTest() {
    	
    	createTestSetupData();
    	
    	Date dt = Date.parse('12/12/1990');
    	
    	Test.setCurrentPage(Page.Preferences);
    	ApexPages.StandardController stdCon = new ApexPages.StandardController(new rC_Bios__Preference__c());
    	PreferencesController pc = new PreferencesController(stdCon);
        pc.pref.rC_Sponsorship__Opportunity__c = opty.Id;
    	pc.codeValue = 'Sponsorship-Contact Search-Gender-Male';
    	pc.pref.rC_Bios__Type__c = 'Birthdate';
    	pc.pref.Legacy_Created_Date__c = dt;
    	List<SelectOption> selOps = pc.getSelCodeValues();
    	
    	System.assertEquals(selOps.isEmpty(),false);
    	
    	pc.saveRecord();
        pc.cancel();
    	List<rC_Bios__Preference__c> lstPref = [SELECT Id, rC_Bios__Subtype__c FROM rC_Bios__Preference__c 
    											WHERE rC_Bios__Type__c = 'Birthdate'];
    	System.assert(!lstPref.IsEmpty());
    	System.assertEquals(lstPref[0].rC_Bios__Subtype__c, '1990-12-12');
        String bdRecID = lstPref[0].Id;

    	String recType = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    	ApexPages.currentPage().getParameters().put('RecordType', recType);
    	ApexPages.currentPage().getParameters().put('OpportunityID', opty.Id);
    	PreferencesController pc1 = new PreferencesController(stdCon);
    	pc1.codeValue = 'Sponsorship-Contact Search-Gender-Male';
    	pc1.pref.rC_Bios__Type__c = 'National Office';
        pc1.pref.National_Office__c = NO_Acc.Id;
    	pc1.saveRecord();
        pc1.cancel();
    	lstPref = [SELECT Id, rC_Bios__Subtype__c, National_Office__c
    	            FROM rC_Bios__Preference__c
    				WHERE rC_Bios__Type__c = 'National Office'];
    	System.assert(!lstPref.IsEmpty());
        System.assertEquals(lstPref[0].National_Office__c,NO_Acc.id);
        System.assertEquals(lstPref[0].rC_Bios__Subtype__c,NO_Acc.id);
        
    	pc1.pref.rC_Bios__Type__c = 'Local Partner';
        pc1.pref.Local_Partner__c = LP_Acc.Id;
    	pc1.saveRecord();
    	lstPref = [SELECT Id, rC_Bios__Subtype__c,Local_Partner__c
    	            FROM rC_Bios__Preference__c 
    				WHERE rC_Bios__Type__c = 'Local Partner'];
    	
    	System.assert(!lstPref.IsEmpty());
        System.assertEquals(lstPref[0].Local_Partner__c,LP_Acc.id);
        System.assertEquals(lstPref[0].rC_Bios__Subtype__c,LP_Acc.id);
        
    	pc1.pref.rC_Bios__Type__c = 'Community';
        pc1.pref.Community__c = Com_Acc.Id;
    	pc1.saveRecord();
    	lstPref = [SELECT Id, rC_Bios__Subtype__c,Community__c
    	            FROM rC_Bios__Preference__c 
    				WHERE rC_Bios__Type__c = 'Community'];
    	System.assert(!lstPref.IsEmpty());
        System.assertEquals(lstPref[0].Community__c,Com_Acc.id);
        System.assertEquals(lstPref[0].rC_Bios__Subtype__c,Com_Acc.id);
        
    	pc1.pref.rC_Bios__Type__c = 'Age';
        pc1.pref.rC_Bios__Subtype__c = '10';
    	pc1.saveRecord();
    	lstPref = [SELECT Id, rC_Bios__Subtype__c FROM rC_Bios__Preference__c 
    											WHERE rC_Bios__Type__c = 'Age'];
    	System.assert(!lstPref.IsEmpty());

        ApexPages.currentPage().getParameters().put('Id', bdRecID);
        PreferencesController pc2 = new PreferencesController(stdCon);
        pc2.pref.rC_Bios__Type__c = 'Gender';
        pc2.pref.rC_Bios__Subtype__c = 'Male';
        pc2.saveRecord();
        pc2.cancel();
        lstPref = [SELECT Id, rC_Bios__Subtype__c FROM rC_Bios__Preference__c 
                                                WHERE rC_Bios__Type__c = 'Gender'];
        System.assert(!lstPref.IsEmpty());
        System.assertEquals(lstPref[0].rC_Bios__Subtype__c, 'Male');

        System.debug('[RB] - AccountTriggerHandlerTest.test_PreferencesControllerTest :: Method End..');
    } // END static void test_PreferencesControllerTest() {

 @isTest 
    static void test_PreferencesControllerTestNew() {
        createTestSetupData();
        
    	Date dt = Date.parse('12/12/1990');
    	Test.setCurrentPage(Page.Preferences);
    	ApexPages.StandardController stdCon = new ApexPages.StandardController(new rC_Bios__Preference__c());
    	PreferencesController pc1 = new PreferencesController(stdCon);
    	System.assertEquals(pc1.isOptyEmpty,true);
    	
    	System.assertEquals(pc1.isEditMode,false);
    	
    	pc1.saveRecord();
    	ApexPages.currentPage().getParameters().put('Id', null);
    	
    	ApexPages.StandardController stdCon1 = new ApexPages.StandardController(new rC_Bios__Preference__c());
    	PreferencesController pc2 = new PreferencesController(stdCon1);
    	pc2.pref.rC_Sponsorship__Opportunity__c = opty.Id;
    	pc2.codeValue = 'Sponsorship-Contact Search-Gender-Male';
    	pc2.pref.rC_Bios__Type__c = 'Birthdate';
    	pc2.pref.Legacy_Created_Date__c = dt;
    	List<SelectOption> selOps = pc2.getSelCodeValues();
    	
    	PageReference pr = pc2.saveRecord();
    	LIST<rC_Bios__Preference__c> listOfPref= [SELECT  id ,name,rC_Bios__Type__c,rC_Bios__Category__c,
    	                                        rC_Bios__Contact__c,rC_Sponsorship__Opportunity__c,rC_Bios__Subtype__c
    	                                            FROM rC_Bios__Preference__c] ;
    	                                            
    	
    	System.assertEquals(listOfPref[0].rC_Bios__Type__c,'Birthdate');
    	System.assertEquals(listOfPref[0].rC_Sponsorship__Opportunity__c,opty.id);
    	System.assertEquals(listOfPref[0].rC_Bios__Subtype__c,String.valueOf(dt));
    	System.assertEquals(pr.getURL(),new PageReference('/'+listOfPref[0].id).getURL());
        pc2.cancel();
    	pc2.pref.Preference_Reason__c = null;
    	pc2.saveRecord();
    	
        LIST<rC_Bios__Preference__c> listOfPref2= [SELECT  id ,name,rC_Bios__Type__c,rC_Bios__Category__c,Preference_Reason__c,
    	                                        rC_Bios__Contact__c,rC_Sponsorship__Opportunity__c,rC_Bios__Subtype__c
    	                                            FROM rC_Bios__Preference__c] ;
    	System.assertEquals(listOfPref2.size(),2);
    	System.assertEquals(listOfPref2[1].Preference_Reason__c,null);
    	
    	pc2.pref.Legacy_Created_Date__c = null;
        pc2.saveRecord();
        System.debug('ERror msg @@@'+PreferencesController.errorMsg);
        System.assertEquals(PreferencesController.errorMsg.contains('Please Enter Birth Date..'),true);
    }
    static void createTestSetupData() {
    	System.debug('[RB] - PreferencesControllerTest.createTestSetupData :: Method Start..');

    	String accNORTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        String accLPRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        String accComRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        
    	NO_Acc = TestUtils.createAccountWithRT('Test NO Account', accNORTId, null, '123', '1245', true);
        LP_Acc = TestUtils.createAccountWithRT('Test LP Account', accLPRTId, NO_Acc, '134', '1246', true);
        Com_Acc = TestUtils.createAccountWithRT('Test Community Account', accComRTId, LP_Acc, '145', '1237', true);

    	Double amt = 3435.50;
    	opty = TestUtils.createOpportunity(NO_Acc, 'test Opportunity', amt, true);

    	rC_Bios__Preference_Code__c prefCode = TestUtils.createPrefCode('Sponsorship', 'Contact Search', 'Gender', 'Male', true);
    	

    	System.debug('[RB] - PreferencesControllerTest.createTestSetupData :: Method End..');
    } // END static void createTestSetupData() {
} // END private class PreferencesControllerTest {