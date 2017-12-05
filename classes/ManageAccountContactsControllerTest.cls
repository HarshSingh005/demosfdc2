/***********************************************************************************************************
* Appirio, Inc
* Name         : ManageAccountContactsControllerTest
* Created By   : Rohit B. (Appirio)
* Purpose      : Test class for the ManageAccountContactsController
* Created Date : 02/17/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 08/03/2016                   Ravi Chauhan            Ramp Up Code coverage
* 11/08/2016                   Vaibhav Goel            Changes to test methods to put up asserts and checking code coverage 
**********************************************************************************************************/

@isTest
public class ManageAccountContactsControllerTest{
    //public static Integer i=1;
    static List<Contact> lstContact;
    static List<Account> lstAccount;
    static Web_Transaction__c webTrans;
    static final string RT_ACC_LOCAL = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    static final string RT_ACC_HHOLD = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    @isTest
    static void test_saveManageAccountContactsController(){
        lstContact=new List<Contact>();
        lstAccount=new List<Account>();
        createdata();

        List<ManageAccountContactsController.contactHelper> conhelperlist=new List<ManageAccountContactsController.contactHelper>();
        
        Test.setCurrentPage(Page.ManageAccountContacts);
        ApexPages.StandardController sc = new ApexPages.standardController(lstAccount.get(0));
        ManageAccountContactsController manageacc=new ManageAccountContactsController(sc);
        
        manageacc.acc=lstAccount.get(0);
        ManageAccountContactsController.contacthelper conhelper=new ManageAccountContactsController.contacthelper();
        conhelper.contact=lstContact.get(0);
        
        ManageAccountContactsController.contacthelper conhelper1=new ManageAccountContactsController.contacthelper();
        conhelper1.contact=lstContact.get(3);
        
        conhelperlist.add(conhelper);
        conhelperlist.add(conhelper1);
        manageacc.contactHelperList=conhelperlist;
        
        Test.startTest();
            PageReference upsrtConAndAccSamPageResult = manageacc.upsertContactsAndAccountSamePage();
            //system.assert(upsrtConAndAccSamPageResult.getUrl().contains('ManageAccountContacts'));
            
            manageacc.contactHelperList=conhelperlist;
            
            PageReference upsertContactsAndAccountSamePageResult = manageacc.upsertContactsAndAccountSamePage();
            system.assertEquals(upsertContactsAndAccountSamePageResult, null);
            
            manageacc.upsertContactsAndAccountSamePage_Dup();
        Test.stopTest();
    }
    
    
    @isTest
    static void test_saveManageAccountContactsController0(){
        lstContact=new List<Contact>();
        lstAccount=new List<Account>();
        createdata();

        List<ManageAccountContactsController.contactHelper> conhelperlist=new List<ManageAccountContactsController.contactHelper>();
        
        Test.setCurrentPage(Page.ManageAccountContacts);
        ApexPages.currentPage().getParameters().put('id', lstAccount.get(2).id);
        ApexPages.StandardController sc = new ApexPages.standardController(lstAccount.get(0));
        ManageAccountContactsController manageacc=new ManageAccountContactsController(sc);
        
        Test.startTest();
            manageacc.isContactDuplicate = true;
            PageReference upsertContactsAndAccountSamePageDupResult = manageacc.upsertContactsAndAccountSamePage_Dup();
            system.assertEquals(upsertContactsAndAccountSamePageDupResult, null);
        Test.stopTest();
    }

    @isTest
    static void test_saveManageAccountContactsController1(){
        lstContact=new List<Contact>();
        lstAccount=new List<Account>();
        createdata();

        List<ManageAccountContactsController.contactHelper> conhelperlist1=new List<ManageAccountContactsController.contactHelper>();
        
        Test.setCurrentPage(Page.ManageAccountContacts);
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(lstAccount.get(1));
        ManageAccountContactsController manageacc1=new ManageAccountContactsController(sc1);
        manageacc1.acc=lstAccount.get(1);
        
        ManageAccountContactsController.contacthelper conhelper2=new ManageAccountContactsController.contacthelper();
        conhelper2.contact=lstContact.get(1);
        
        ManageAccountContactsController.contacthelper conhelper3=new ManageAccountContactsController.contacthelper();
        conhelper3.contact=lstContact.get(4);
        
        conhelperlist1.add(conhelper2);
        conhelperlist1.add(conhelper3);
        
        manageacc1.contactHelperList=conhelperlist1; 
        insert lstAccount.get(2);
        
        Test.startTest();
            PageReference upsertContactsAndAccountAndReturnRes = manageacc1.upsertContactsAndAccountAndReturn();
            //system.assert(upsertContactsAndAccountAndReturnRes.getUrl().contains('001'));
            system.debug('----upsertContactsAndAccountAndReturnRes---' + upsertContactsAndAccountAndReturnRes);
            
            PageReference upsertContactsAndAccountAndReturn_DupRes = manageacc1.upsertContactsAndAccountAndReturn_Dup();
            system.assertEquals(upsertContactsAndAccountAndReturn_DupRes, null);
            system.debug('----upsertContactsAndAccountAndReturn_DupRes---' + upsertContactsAndAccountAndReturn_DupRes);
            manageacc1.cancel();
        Test.stopTest();
    }
    
    
    @isTest
    static void test_saveManageAccountContactsController2(){
        lstContact=new List<Contact>();
        lstAccount=new List<Account>();
        createdata();

        List<ManageAccountContactsController.contactHelper> conhelperlist2 = new List<ManageAccountContactsController.contactHelper>();
        
        Test.setCurrentPage(Page.ManageAccountContacts);
        ApexPages.CurrentPage().getparameters().put('id',lstAccount.get(2).id);
        
        ApexPages.StandardController sc2 = new ApexPages.standardController(lstAccount.get(2));
        ManageAccountContactsController manageacc2=new ManageAccountContactsController(sc2);
        manageacc2.acc=lstAccount.get(2);
        
        ManageAccountContactsController.contacthelper conhelper4=new ManageAccountContactsController.contacthelper();
        conhelper4.contact=lstContact.get(2);
        
        ManageAccountContactsController.contacthelper conhelper5=new ManageAccountContactsController.contacthelper();
        conhelper5.contact=lstContact.get(5);
        
        conhelperlist2.add(conhelper4);
        conhelperlist2.add(conhelper5);
        
        Test.startTest();
            manageacc2.contactHelperList=conhelperlist2;
            manageacc2.upsertContactsAndAccountAndNewAccount();
            
            ApexPages.CurrentPage().getparameters().put('id',lstAccount.get(2).id);
        
            ApexPages.StandardController sc3 = new ApexPages.standardController(lstAccount.get(2));
            manageacc2=new ManageAccountContactsController(sc3);
            manageacc2.acc=lstAccount.get(2);
            
            ManageAccountContactsController.contacthelper conhelper6=new ManageAccountContactsController.contacthelper();
            conhelper6.contact=lstContact.get(2);
            
            ManageAccountContactsController.contacthelper conhelper7=new ManageAccountContactsController.contacthelper();
            conhelper7.contact=lstContact.get(5);
            
            conhelperlist2.add(conhelper4);
            conhelperlist2.add(conhelper5);
            
            PageReference upsertContactsAndAccountAndNewAccountRes  = manageacc2.upsertContactsAndAccountAndNewAccount();
          //  system.assert(upsertContactsAndAccountAndNewAccountRes != null);
            system.debug('----upsertContactsAndAccountAndNewAccountRes---' + upsertContactsAndAccountAndNewAccountRes);
            
            PageReference upsertContactsAndAccountAndNewAccount_DupRes = manageacc2.upsertContactsAndAccountAndNewAccount_Dup();
         //   system.assertEquals(upsertContactsAndAccountAndNewAccount_DupRes, null);
            system.debug('----upsertContactsAndAccountAndNewAccount_DupRes---' + upsertContactsAndAccountAndNewAccount_DupRes);
            
            manageacc2.cancel();
        Test.stopTest();
    }
    
    @isTest
    private static void utilfun(){
        List<ManageAccountContactsController.contactHelper> conhelperlist2 = new List<ManageAccountContactsController.contactHelper>();
        lstContact=new List<Contact>();
        lstAccount=new List<Account>();
        Account acc=new Account(name='test');
        acc.RecordTypeId = RT_ACC_HHOLD;
        insert acc;
        Contact con=new Contact(firstname='test',lastname='testlast', AccountID=acc.id);
        insert con;
        PageReference pageRef1 = new PageReference('/apex/ManageAccountContacts');
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('Id', acc.Id);
        ApexPages.StandardController sc1 = new ApexPages.standardController(acc);
        ManageAccountContactsController manageacc1=new ManageAccountContactsController(sc1);
        ManageAccountContactsController.contacthelper conhelper=new ManageAccountContactsController.contacthelper();
        conhelper.contact=con;
        conhelperlist2.add(conhelper);
        System.assertEquals( conhelper.contact.lastname,'testlast');        
        manageacc1.contactHelperList = conhelperlist2; // Change
        manageacc1.upsertContactsAndAccountAndReturn();
        manageacc1.contactExistingList.get(0).firstName = 'dummy Name';
        manageacc1.contactExistingList.get(0).rC_Bios__Preferred_Contact__c =true;
        PageReference upsertContactsAndAccountAndNewAccountRes  = manageacc1.upsertContactsAndAccountAndNewAccount();
        system.assert(upsertContactsAndAccountAndNewAccountRes!=null);
        system.debug('----upsertContactsAndAccountAndNewAccountRes---' + upsertContactsAndAccountAndNewAccountRes);
        
    }
    
     @isTest
    static void testRedirect(){
        lstContact=new List<Contact>();
        lstAccount=new List<Account>();
        createdata();

        Test.setCurrentPage(Page.ManageAccountContacts);
        ApexPages.currentPage().getParameters().put('RecordType', RT_ACC_LOCAL);
        ApexPages.StandardController sc = new ApexPages.standardController(lstAccount.get(0));
        ManageAccountContactsController manageacc=new ManageAccountContactsController(sc);
        
        Test.startTest();
            PageReference upsertContactsAndAccountSamePageDupResult = manageacc.Redirect();
            system.assert(upsertContactsAndAccountSamePageDupResult != null);
        Test.stopTest();
    }
    
     @isTest
    static void testPopulateWebTransactionInfo(){
        lstContact=new List<Contact>();
        lstAccount=new List<Account>();
        createdata();

        ValidatedAddress address = new ValidatedAddress();
        Test.setCurrentPage(Page.ManageAccountContacts);
        ApexPages.currentPage().getParameters().put('webTransactionId', webTrans.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(lstAccount.get(0));
        ManageAccountContactsController manageacc=new ManageAccountContactsController(sc); 
        ManageAccountContactsController.contacthelper conhelper6=new ManageAccountContactsController.contacthelper();
        conhelper6.contact=lstContact.get(2);
        lstAccount.get(0).RecordTypeId = RT_ACC_HHOLD;
        Test.startTest();
        insert lstAccount.get(0);
        Test.stopTest();
    }
    /*@isTest
    private static void testMethodNew(){
        Account acc=new Account(name='test');
        insert acc;
        Contact con=new Contact(firstname='test',lastname='testlast', AccountID=acc.id);
        insert con;
        
        Test.setCurrentPage(new PageReference('Page.ManageAccountContacts'));
        //ApexPages.currentPage().getParameters().put('Id', acc.Id);
        System.currentPageReference().getParameters().put('id', acc.Id);
        ApexPages.StandardController sc1 = new ApexPages.standardController(acc);
        ManageAccountContactsController manageacc1=new ManageAccountContactsController(sc1);
        manageacc1.contactHelperList = new List<ManageAccountContactsController.ContactHelper>();
        manageacc1.upsertContactsAndAccountAndReturn();
        
        // To cover the exception scenario of saveRecords() method
        manageacc1.contactHelperList = null;
        manageacc1.upsertContactsAndAccountAndReturn();
        //System.assert(manageacc1.errorMessage.contains('Attempt to de-reference a null object'));
    }*/
    

    
    static void createdata(){
        for(Integer i=0 ; i<=2 ; i++){
            lstAccount.add(TestUtils.createAccount('test'+i,false));
            Account acc=lstAccount.get(i);
            acc.RecordTypeId = RT_ACC_HHOLD;
            acc.US_Based_Account__c='Yes';
            acc.BillingCity='testcity';
            acc.BillingCountry='testcountry';
            acc.BillingPostalCode='345';
            acc.BillingState='teststate';
            acc.BillingStreet='teststreet';
            acc.Phone='9890';
            acc.Website='abc.com';
        
        }
            Account accDup = TestUtils.createAccount('test1',false);
            accDup.RecordTypeId = RT_ACC_HHOLD;
            accDup.US_Based_Account__c='Yes';
            accDup.BillingCity='testcity';
            accDup.BillingCountry='testcountry';
            accDup.BillingPostalCode='345';
            accDup.BillingState='teststate';
            accDup.BillingStreet='teststreet';
            accDup.Phone='9890';
            accDup.Website='abc.com';
        	insert accDup;
        for(Integer i=0;i<=2;i++){
            lstContact.add(TestUtils.createContact(lstAccount.get(i),'test'+i,'testt'+i,false));
            lstContact.add(TestUtils.createContact(lstAccount.get(i),'test'+i+3,'testt'+i,false));
            
            Contact con=lstContact.get(i);
            con.rC_Bios__Preferred_Contact__c = true;
            con.Email='abc@xyz.com';
            con.MailingStreet='teststreet';
            con.MailingPostalCode='8979';
            con.MailingCity='testcity';
            
            Contact con1=lstContact.get(i+1);
            con1.Email='pql@mno.com';
            con1.MailingStreet='1st bk';
            con1.MailingPostalCode='9879';
            con1.MailingCity='man';
        
        }
        webTrans = TestUtils.createWebTransaction(false);
        webTrans.Contact_First_Name__c = 'Test';
        webTrans.Contact_Last_Name__c  = 'Last Name';
        webTrans.Contact_City__c = 'Test';
        webTrans.Contact_Country__c = 'TC';
        webTrans.Contact_Email__c = 't@test.com';
        webTrans.Contact_Phone__c = '238628332';
        webTrans.Contact_Postal_Code__c = '21313';
        webTrans.Contact_State_Prov_Terr__c = 'DL';
        webTrans.Contact_Street_1__c = 'Test S1';
        webTrans.Contact_Street_2__c = 'Test S2';
        webTrans.Contact_Suffix__c = 'Mr.';
        webTrans.Contact_Title__c = 'tt';
        insert webTrans;
    }
}