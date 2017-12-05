/**
 * This class contains unit tests for validating the behavior of the Case Wizard functionality
 */
@isTest
private class TestCaseControllerExt {
     private static final String nationalOfficeRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    private static Contact contact;
    private static Account acc,nationalOffice;
    
    static void setup(){
       
        List<Account> listOfAccount = new List<Account>();
        
        acc = TestUtils.createAccount('Test Account for Case Wizard', false);
        listOfAccount.add(acc);
        
        nationalOffice = TestUtils.createAccountWithRT('National Office', nationalOfficeRecordType, null, '899', '21245', false);
        listOfAccount.add(nationalOffice);
        insert listOfAccount;
        
        contact = TestUtils.createContact(acc, 'Dwight', 'Schrute', true);
    }
    
    static testMethod void test_InvokeFromContact() {
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.currentPage().getParameters().put(Constants.CONTACT_URL_PARM, contact.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        //Case is not created. Just Instantiated and Initialized
        System.assertEquals(null, ext.masterCase.caseRecord.Id);
        //Contact Id is defaulted on the Case
        System.assertEquals(contact.Id, ext.masterCase.caseRecord.contactId);
        //Case Record Type is defaulted to Master
        System.assertEquals(TestUtils.getRecordTypeId(Constants.CASE_REC_TYPE_MASTER, 'Case'), ext.masterCase.caseRecord.RecordTypeId);
        //Clicking Return  will take User to the Contact page 
        System.assertEquals(new PageReference('/'+contact.Id).getURL(), ext.cancel().getURL());
    }
    
    static testMethod void test_InvokeFromCaseTab() {
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        //Case is not created. Just Instantiated and Initialized
        System.assertEquals(null, ext.masterCase.caseRecord.Id);
        //Contact Id is null
        System.assertEquals(null, ext.masterCase.caseRecord.contactId);
        //Case Record Type is defaulted to Master
        System.assertEquals(TestUtils.getRecordTypeId(Constants.CASE_REC_TYPE_MASTER, 'Case'), ext.masterCase.caseRecord.RecordTypeId);
        //Clicking Return  will take User to the Case tab 
        System.assertEquals(new PageReference(Constants.CASE_TAB).getURL(), ext.cancel().getURL());
    }
    
    static testMethod void test_CreateMasterCase() {
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.currentPage().getParameters().put(Constants.CONTACT_URL_PARM, contact.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        
        //Create Master Case
        createMasterCase(ext);
        Case masterCase = [SELECT ContactId, AccountId, Status, Priority, Priority_Reason__c FROM Case WHERE ContactId =: contact.Id];
        
        System.assertEquals(ext, ext.thisCon);
        System.assertEquals(acc.Id, masterCase.AccountId);
        System.assertEquals('Open', masterCase.Status);
        System.assertEquals('High', masterCase.Priority);
        System.assertEquals('Major Donor', masterCase.Priority_Reason__c);
        System.assertEquals('Case is saved', ext.pageMessage);
        System.assertEquals('info', ext.pageMessageSeverity);
        
        //Clicking Return will take User to the newly created Case's detail page 
        System.assertEquals(new PageReference('/'+masterCase.Id).getURL(), ext.cancel().getURL());
    }
    //test addRelatedCase() of CaseModel class
    static testMethod void test_AddRelatedCase(){
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.currentPage().getParameters().put(Constants.CONTACT_URL_PARM, contact.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        
        //Create Master Case
        createMasterCase(ext);
        Case masterCase = [SELECT ContactId, AccountId, Status, Priority, Priority_Reason__c FROM Case WHERE ContactId =: contact.Id];
        
        //Click 'Add Case' but Cancel the action
        ext.addCase();
        System.debug('@@@ Mastercase'+masterCase);
        System.assertEquals(true, ext.displayOverlay);
        System.assertEquals(false,ext.isEditOp);
        ext.closeOverlay();
        System.assertEquals(false, ext.displayOverlay);
        System.assertEquals(null, ext.relatedCaseError);
        
        //Add Case for real now
        ext.addCase();
        ext.relatedCase.National_Office__c = nationalOffice.id;
        System.assertEquals(true, ext.displayOverlay);
        ext.saveRelatedCase();        
        
        List<Case> relatedCases = [SELECT Related_Case_Record_Type__c, RecordType.DeveloperName, Status FROM Case WHERE Master_Case__c =: masterCase.Id];
        system.debug('@@@ Related case list'+relatedCases);
        System.assertEquals(1, ext.masterCase.relatedCases.size());
        System.assertEquals(Constants.CASE_REC_TYPE_NO, relatedCases.get(0).Related_Case_Record_Type__c);
        System.assertEquals('X3_National_Office_Project_Request', relatedCases.get(0).RecordType.DeveloperName);
        System.assertEquals('Pending - National Office', relatedCases.get(0).Status);  
    }
    
    static testMethod void test_AddRelatedCases(){
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.currentPage().getParameters().put(Constants.CONTACT_URL_PARM, contact.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        
        //Create Master Case
        createMasterCase(ext);
        Case masterCase = [SELECT ContactId, AccountId, Status, Priority, Priority_Reason__c FROM Case WHERE ContactId =: contact.Id];
        
        //Click 'Add Case' but Cancel the action
        ext.addCase();
        System.assertEquals(true, ext.displayOverlay);
        ext.closeOverlay();
        System.assertEquals(false, ext.displayOverlay);
        System.assertEquals(null, ext.relatedCaseError);
        
        Test.startTest();
        //Adding Case 1
        ext.addCase();
        System.assertEquals(true, ext.displayOverlay);
        ext.relatedCase.National_Office__c = nationalOffice.id;
        ext.saveRelatedCase();        
        
        
        //Adding Case 2
        ext.addCase();
        ext.relatedCase.National_Office__c = nationalOffice.id;
        ext.saveRelatedCase();
       //Adding Case 3
        ext.addCase();
        ext.relatedCase.National_Office__c = nationalOffice.id;
        ext.saveRelatedCase();
       
        List<Case> relatedCases = [SELECT Related_Case_Record_Type__c, RecordType.DeveloperName, Status FROM Case WHERE Master_Case__c =: masterCase.Id];
        System.assertEquals(3, ext.masterCase.relatedCases.size());
        for(Case c : relatedCases){
            System.assertEquals(Constants.CASE_REC_TYPE_NO, c.Related_Case_Record_Type__c);
            System.assertEquals('X3_National_Office_Project_Request', c.RecordType.DeveloperName);
            System.assertEquals('Pending - National Office', c.Status);
         
        }
        Test.stopTest();
    }
    
    static testMethod void test_EditExistingMasterCase(){
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.currentPage().getParameters().put(Constants.CONTACT_URL_PARM, contact.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        
        //Create Master Case
        createMasterCase(ext);
        Case masterCase = [SELECT ContactId, AccountId, Status, Priority, Priority_Reason__c FROM Case WHERE ContactId =: contact.Id];
        
        //Create a National Office Child Related Case
        ext.addCase();
        ext.relatedCase.Related_Case_Record_Type__c = Constants.CASE_REC_TYPE_CHILD_INQ;
        Contact child = TestUtils.createContact(acc, 'Sponsored', 'Kid', false);
        child.RecordTypeId = TestUtils.getRecordTypeId('Participant', 'Contact');
        insert child;
        ext.relatedCase.Child__c = child.Id;
        ext.setRecordTypeAndRefresh();
        System.assertEquals(true, ext.displayOverlay);
        ext.saveRelatedCase();        
        
        List<Case> relatedCases = [SELECT Related_Case_Record_Type__c, RecordType.DeveloperName, Status FROM Case WHERE Master_Case__c =: masterCase.Id];
        System.assertEquals(1, ext.masterCase.relatedCases.size());
        System.assertEquals(Constants.CASE_REC_TYPE_CHILD_INQ, relatedCases.get(0).Related_Case_Record_Type__c);
        System.assertEquals('X4_National_Office_Participant_Request', relatedCases.get(0).RecordType.DeveloperName);
        System.assertEquals('Pending - National Office', relatedCases.get(0).Status);
        
        //Refresh page and make sure Master Case and Related Cases are populated with correct values
        masterCase = [SELECT Status, ContactId, AccountId, Origin, Organization_Name__c, Priority, Priority_Reason__c, RecordType.DeveloperName,
        				Preferred_Method_of_Response__c, Use_Case_Assignment_Rules__c FROM Case WHERE Id =: masterCase.Id];
        stdCon = new ApexPages.StandardController(masterCase);
        ext = new CaseControllerExt(stdCon);
        ext.init();
        //System.assertEquals('Open', ext.masterCase.caseRecord.Status);
        System.assertEquals('High', ext.masterCase.caseRecord.Priority);
        System.assertEquals('Major Donor', ext.masterCase.caseRecord.Priority_Reason__c);
        System.assertEquals(1, ext.masterCase.relatedCases.size());
    }
    
    static testMethod void test_EditNonMasterCase(){
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        Case nonMasterCase = TestUtils.createCase(TestUtils.getRecordTypeId('X2_Routed_Case', 'Case'), 'Open', 'Standard', 'CS1', false);
        try{
            nonMasterCase.ContactId = contact.Id;
            insert nonMasterCase;
        }catch(DmlException de){
            System.debug(de);
        }
        ApexPages.StandardController stdCon = new ApexPages.StandardController(nonMasterCase);
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        PageReference returnedPRef = ext.init();
        PageReference pRef = new ApexPages.StandardController(nonMasterCase).edit();
        pRef.getParameters().put(Constants.RETURN_URL, nonMasterCase.Id);
        pRef.getParameters().put(Constants.NO_OVERRIDE, '1');
        System.assertEquals(pRef.getURL(), returnedPRef.getURL());
    }
    
    static testMethod void test_DeleteRelatedCase(){
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.currentPage().getParameters().put(Constants.CONTACT_URL_PARM, contact.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        
        //Create Master Case
        createMasterCase(ext);
        Case masterCase = [SELECT ContactId, AccountId, Status, Priority, Priority_Reason__c FROM Case WHERE ContactId =: contact.Id];
        
        //Create a National Office Related Case
        ext.addCase();
        ext.relatedCase.Related_Case_Record_Type__c = Constants.CASE_REC_TYPE_NO;
        ext.setRecordTypeAndRefresh();
        System.assertEquals(true, ext.displayOverlay);
        ext.relatedCase.National_Office__c = nationalOffice.id;
        ext.saveRelatedCase();        
        
        List<Case> relatedCases = [SELECT Related_Case_Record_Type__c, RecordType.DeveloperName, Status FROM Case WHERE Master_Case__c =: masterCase.Id];
        System.debug('@@@relatedCases'+relatedCases);
        System.assertEquals(1, ext.masterCase.relatedCases.size());
        System.assertEquals(Constants.CASE_REC_TYPE_NO, relatedCases.get(0).Related_Case_Record_Type__c);
        System.assertEquals('X3_National_Office_Project_Request', relatedCases.get(0).RecordType.DeveloperName);
        System.assertEquals('Pending - National Office', relatedCases.get(0).Status);
        
        //Delete Related Case
        ext.caseIdtoDel = relatedCases.get(0).Id;
        ext.deleteRelatedCase();
        relatedCases = [SELECT Related_Case_Record_Type__c, RecordType.DeveloperName, Status FROM Case WHERE Master_Case__c =: masterCase.Id];
        System.assertEquals(0, ext.masterCase.relatedCases.size());       
    }
    static testMethod void test_DeleteRelatedCaseNew(){
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.currentPage().getParameters().put(Constants.CONTACT_URL_PARM, contact.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        
        //Create Master Case
        createMasterCase(ext);
        Case masterCase = [SELECT ContactId, AccountId, Status, Priority, Priority_Reason__c FROM Case WHERE ContactId =: contact.Id];
        
        //Create a National Office Related Case
        ext.addCase();
        ext.relatedCase.Related_Case_Record_Type__c = Constants.CASE_REC_TYPE_NO;
        ext.setRecordTypeAndRefresh();
        System.assertEquals(true, ext.displayOverlay);
        ext.saveRelatedCase();        
        
        ext.caseIdToDel = masterCase.id;
        ext.deleteRelatedCase();
        List<Case> relatedCases = [SELECT Related_Case_Record_Type__c, RecordType.DeveloperName, Status FROM Case WHERE Master_Case__c =: masterCase.Id];
        relatedCases = [SELECT Related_Case_Record_Type__c, RecordType.DeveloperName, Status FROM Case WHERE Master_Case__c =: masterCase.Id];
        System.assertEquals(0, ext.masterCase.relatedCases.size()); 
             
    }
    
    static testMethod void test_EditRelatedCase(){
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.currentPage().getParameters().put(Constants.CONTACT_URL_PARM, contact.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        
        //Create Master Case
        createMasterCase(ext);
        Case masterCase = [SELECT ContactId, AccountId, Status, Priority, Priority_Reason__c FROM Case WHERE ContactId =: contact.Id];
        
        //Create a Standard Related Case
        ext.addCase();
        ext.relatedCase.Related_Case_Record_Type__c = Constants.CASE_REC_TYPE_STANDARD;
        ext.setRecordTypeAndRefresh();
        ext.relatedCase.Type = 'Donation';
        ext.relatedCase.Use_Case_Assignment_Rules__c = true;
        System.assertEquals(true, ext.displayOverlay);
        ext.relatedCase.National_Office__c = nationalOffice.id;
        ext.saveRelatedCase();        
        
        List<Case> relatedCases = [SELECT CaseNumber, Subject,Related_Case_Record_Type__c, RecordType.DeveloperName, Status FROM Case WHERE Master_Case__c =: masterCase.Id];
        System.assertEquals(1, ext.masterCase.relatedCases.size());
        System.assertEquals(Constants.CASE_REC_TYPE_STANDARD, relatedCases.get(0).Related_Case_Record_Type__c);
        System.assertEquals('X2_Routed_Case', relatedCases.get(0).RecordType.DeveloperName);
        System.assertEquals('Closed', relatedCases.get(0).Status);
        
        //Edit Related Case
        ext.caseIdtoEdit = relatedCases.get(0).Id;
        ext.editRelatedCase();
        System.assertEquals(relatedCases.get(0).Id, ext.relatedCase.Id);
        ext.relatedCase.Secondary_Type__c = 'Gifts in Kind';
        ext.saveRelatedCase();
        relatedCases = [SELECT Secondary_Type__c FROM Case WHERE Master_Case__c =: masterCase.Id];
        System.assertEquals(1, ext.masterCase.relatedCases.size());
        System.assertEquals('Gifts in Kind', ext.masterCase.relatedCases.get(0).Secondary_Type__c);
    }
    
    static testMethod void test_AddEditRoutedCase(){
        setup();
        Test.setCurrentPage(Page.CaseWizard);
        ApexPages.currentPage().getParameters().put(Constants.CONTACT_URL_PARM, contact.Id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        ext.init();
        
        System.assertEquals(null, ext.routedCase);
        
        //Create Master Case
        createMasterCase(ext);
        
        Case masterCase = [SELECT Status, ContactId, AccountId, Origin, Organization_Name__c, Priority, Priority_Reason__c, RecordType.DeveloperName,
        					Preferred_Method_of_Response__c, Use_Case_Assignment_Rules__c FROM Case WHERE ContactId =: contact.Id];
        stdCon = new ApexPages.StandardController(masterCase);
        ext = new CaseControllerExt(stdCon);
        ext.init();
        
        //Create a Routed Case
        ext.routedCase.Target_Resolution_Time__c = Datetime.now().addDays(3);
        ext.routedCase.Type = 'Donation';
        ext.routedCase.Secondary_Type__c = 'Stocks';
        ext.saveRoutedCase();        
        
        List<Case> relatedCases = ext.masterCase.relatedCases;
        System.assertEquals(1, relatedCases.size());
        System.assertEquals(Constants.CASE_REC_TYPE_STANDARD, relatedCases.get(0).Related_Case_Record_Type__c);
        System.assertEquals('Closed', relatedCases.get(0).Status);
        System.assertEquals('Donation', relatedCases.get(0).Type);
        System.assertEquals('Stocks', relatedCases.get(0).Secondary_Type__c);
    }
    
      
    private static void createMasterCase(CaseControllerExt ext){
        ext.masterCase.caseRecord.Status = 'Open';
        ext.masterCase.caseRecord.Priority = 'High';
        ext.masterCase.caseRecord.Priority_Reason__c = 'Major Donor';
        ext.saveMasterCase();
    }
     static testMethod void createMasterCaseCatchEx(){
        Test.setCurrentPage(Page.CaseWizard);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
        CaseControllerExt ext = new CaseControllerExt(stdCon);
        System.assertEquals(null,ext.saveMasterCase());
        System.assertEquals(ext.pageMessageSeverity,'error');
    }
}