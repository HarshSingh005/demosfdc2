/***********************************************************************************************************
 * Appirio, Inc
 * Name         : OppPreferenceListControllerTest
 * Created By   : Vaibhav Goel (Appirio)
 * Purpose      : Test class for class "OppPreferenceListController"
 * Created Date : 4/Jan/2016
 * Task Number  : T-460209
 * 
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]						[Person Name]			[Short Description]
 **********************************************************************************************************/
@isTest
private class OppPreferenceListControllerTest {
	
	public static Account regularAcc, localPart, nationalOfc, community;
	public static List<Account> accList;
	public static Opportunity testOpp;
	public static List<rC_Bios__Preference_Code__c> prefCodeList;
	public static List<rC_Bios__Preference__c> prefRecList; 
	
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        createTestData();
        test.StartTest();
        apexpages.currentpage().getparameters().put('myEditParam', prefRecList.get(0).Id);
        OppPreferenceListController controllerObj = new OppPreferenceListController(new ApexPages.StandardController(testOpp));
        
        system.assertEquals(prefRecList.size(), controllerObj.prefList.size());
        
        controllerObj.editPreference();
        controllerObj.addRow();
        system.assertEquals(prefRecList.size() + 1, controllerObj.oppPrefList.size());
        
        controllerObj.addRow();
        controllerObj.addRow();
        controllerObj.addRow();
        controllerObj.addRow();
        controllerObj.addRow();
        
        controllerObj.oppPrefList.get(2).needsToBeDeleted = 'true';
        controllerObj.oppPrefList.get(6).needsToBeDeleted = 'true';
        controllerObj.saveRecords();
        
        controllerObj.oppPrefList.get(3).prefObj.rC_Bios__Type__c = 'National Office';
        controllerObj.saveRecords();
        controllerObj.oppPrefList.get(3).prefObj.National_Office__c = nationalOfc.Id;
        
        controllerObj.oppPrefList.get(4).prefObj.rC_Bios__Type__c = 'Local Partner';
        controllerObj.oppPrefList.get(4).prefObj.Local_Partner__c = localPart.Id;
        
        controllerObj.oppPrefList.get(5).prefObj.rC_Bios__Type__c = 'Community';
        controllerObj.oppPrefList.get(5).prefObj.Community__c = community.Id;
        
        controllerObj.oppPrefList.get(7).prefObj.rC_Bios__Type__c = 'Birthdate';
        controllerObj.saveRecords();
        controllerObj.oppPrefList.get(7).prefObj.Legacy_Created_Date__c = system.today();
        
        controllerObj.deletePreference();
        system.assertEquals(prefRecList.size() + 4, controllerObj.oppPrefList.size());
        
        controllerObj.saveRecords();
        test.StopTest();
    }
    
    public static void createTestData(){
    	prefCodeList = new List<rC_Bios__Preference_Code__c>();
    	accList = new List<Account>();
    	
    	Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
		Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    	system.debug('---AccountRecordTypeInfo---' + AccountRecordTypeInfo);
    	
    	RecordType oppDonationRecType = [SELECT DeveloperName,Id, Name,SobjectType FROM RecordType where SObjectType = 'Opportunity' AND DeveloperName = 'Donation' limit 1];
    	Id oppDonationRecTypeId = oppDonationRecType.Id;
    	
    	RecordType prefSponsonshipRecType = [SELECT DeveloperName,Id, Name,SobjectType FROM RecordType where SObjectType = 'rC_Bios__Preference__c' AND DeveloperName = 'Sponsorship' limit 1];
    	Id prefSponsonshipRecTypeId = prefSponsonshipRecType.Id;
    	
		rC_Bios__Preference_Code__c prefCodeObj1 = TestUtils.createPrefCode('Sponsorship', 'Contact Search', 'Gender', 'Male', false);
    	prefCodeList.add(prefCodeObj1);
    	
    	rC_Bios__Preference_Code__c prefCodeObj2 = TestUtils.createPrefCode('Sponsorship', 'Contact Search', 'Country', 'USA', false);
    	prefCodeList.add(prefCodeObj2);
    	
    	rC_Bios__Preference_Code__c prefCodeObj3 = TestUtils.createPrefCode('Sponsorship', 'Contact Search', 'In HIV/AIDS Affected Area', 'False', false);
    	prefCodeList.add(prefCodeObj3);
    	
    	insert prefCodeList;
    	system.debug('---prefCodeList---' + prefCodeList.size());
    	
    	regularAcc = TestUtils.createAccount('testChildFundAccount', false);
    	regularAcc.recordTypeId = AccountRecordTypeInfo.get('ChildFund').getRecordTypeId();
    	regularAcc.Status__c = 'Active';
    	insert regularAcc;
    	system.debug('---regularAcc---' + regularAcc.Id);
    	
    	nationalOfc = TestUtils.createAccount('testNationalOfficeAccount', false);
    	nationalOfc.recordTypeId = AccountRecordTypeInfo.get('National Office').getRecordTypeId();
    	nationalOfc.Status__c = 'Active';
    	nationalOfc.National_Office_ID__c = '989';
    	insert nationalOfc;
    	system.debug('---nationalOfc---' + nationalOfc.Id);
    	
    	localPart = TestUtils.createAccount('testLocalPartnerAccount', false);
    	localPart.recordTypeId = AccountRecordTypeInfo.get('Local Partner').getRecordTypeId();
    	localPart.Status__c = 'Active';
    	localPart.ParentId = nationalOfc.Id;
    	localPart.Local_Partner_ID__c = '1121145';
		insert localPart;  
		system.debug('---localPart---' + localPart.Id);  	
    	
    	community = TestUtils.createAccount('testCommunityAccount', false);
    	community.recordTypeId = AccountRecordTypeInfo.get('Community').getRecordTypeId();
    	community.Status__c = 'Active';
    	community.ParentId = localPart.Id;
    	community.Community_Id__c = '9912';
    	insert community;
    	system.debug('---community---' + community.Id); 
    	
    	rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('600',true);
    	testOpp = TestUtils.createOpportunity(regularAcc, 'testOpportunity', 200, false);
    	testOpp.StageName = 'Open';
    	testOpp.CloseDate = system.today() + 30;
    	testOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
    	testOpp.Description__c = 'test Description';
    	//testOpp.recordTypeId  = oppDonationRecTypeId;
    	testOpp.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    	testOpp.Product_Type__c = 'Designated Fund';
        testOpp.Product_Sub_Type__c = 'Graduation';
    	insert  testOpp;
    	system.debug('---testOpp---' + testOpp);
    	
    	prefRecList = new List<rC_Bios__Preference__c>();
    	
    	rC_Bios__Preference__c prefObj1 = TestUtils.createBiosPref(testOpp, true, prefSponsonshipRecTypeId, false);
    	prefObj1.rC_Bios__Category__c = 'Sponsorship';
    	prefObj1.rC_Bios__Subcategory__c = 'Contact Search';
    	prefObj1.rC_Bios__Type__c = 'Gender';
    	prefObj1.rC_Bios__Subtype__c = 'Male';
    	prefObj1.rC_Bios__Start_Date__c = system.today();
    	prefObj1.rC_Bios__End_Date__c = system.today() + 30;
    	prefRecList.add(prefObj1);
    	
    	rC_Bios__Preference__c prefObj2 = TestUtils.createBiosPref(testOpp, true, prefSponsonshipRecTypeId, false);
    	prefObj2.RecordTypeId = prefSponsonshipRecTypeId;
    	prefObj2.rC_Bios__Category__c = 'Sponsorship';
    	prefObj2.rC_Bios__Subcategory__c = 'Contact Search';
    	prefObj2.rC_Bios__Type__c = 'Orphan Status';
    	prefObj2.rC_Bios__Subtype__c = 'Double Status';
    	prefObj2.rC_Bios__Start_Date__c = system.today();
    	prefObj2.rC_Bios__End_Date__c = system.today() + 30;
    	prefRecList.add(prefObj2);
    	insert prefRecList;
    }
}