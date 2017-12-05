/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PaymentMethodServicesTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : To Cover All Payment related web service methods of DonorPortalService and TransactionService classes with SeeAllData as true
 * Created Date : 04/18/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/24/2016                   Munib Ur Rehman        Created
 * Aug 12, 2016                 Ashu Gupta              Implemented coding conventions
 * Jan 17, 2017					Suminder Singh			Fixed for error and code coverage
 **********************************************************************************************************/
@isTest(SeeAllData=true)
public class PaymentMethodServicesTest { 
    
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id ACC_CO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static Id ACC_BANK_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bank').getRecordTypeId();
    //Declaring static variable for contact Record types
    Final Static Id CON_HD_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id CON_PT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    Static Contact con, con1;
        //Declaring static variable for Opportunity Record types
    Final Static Id OPP_DON_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    Final Static Id OPP_TRAN_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    
    Static Account HH_Acc, NO_Acc, NO_Acc2, localPartner, community,acc;
    Static Contact householdCon, participantCon;
    Static Opportunity donationOpp, transactionOpp;
    static Map<String, Contact> mapRectypeContact;
    
    //-----payment methods for DonorPortalService
    
     //Method Name                   : PaySetupTest
    //Purpose                       : testMethod for method 'PaySetup'  of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    
     @isTest  //testMethod for PaySetup
     static void PaySetupTest(){
        //start Test
        Test.startTest();
        //creates the test data
        createTestDataForDonor();
        //get the Contact From DB
        Contact conDB = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :participantCon.Id];
        conDB.AccountId = NO_Acc.Id; 
        update conDB;
        Id conId = conDB.Id;
        List<rC_Giving__Payment_Method__c> paymentMethodList = [select Id, Account_Number_E__c, rC_Giving__Account_Number_Last_4__c, Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where rC_Giving__Is_Active__c = true limit 1];
        System.assert(paymentMethodList.size()>0);
             if(paymentMethodList.size()>0){
                paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'EFT';
                paymentMethodList.get(0).rC_Giving__Account__c = NO_Acc.Id;
                paymentMethodList.get(0).rC_Giving__Contact__c = participantCon.Id;
                paymentMethodList.get(0).rC_Giving__Account_Number_Last_4__c = '421';
                update paymentMethodList;
                System.debug('---first---');
             }
            donationOpp.rC_Giving__Payment_Method_Selected__c = paymentMethodList.get(0).Id;
            update donationOpp;
            System.debug('---Second---');
        //Invoke the Donor portal Service Method.
        List<SponsoredChildrenInfo> infoList = DonorPortalService.PaySetup(Integer.valueOf(conDB.Contact_Number__c));
        //System.assertEquals(infoList.size(), 1);
        Test.stopTest();
    }
    
  //Method Name                   : GetSponsorAndUpdateChildTest
    //Purpose                       : testMethod for two methods 'GetOptInsBySponsor' and 'UpdateOptInByChild' of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-485191
    //Date                          : March 22,2016
    @isTest 
    static void GetSponsorAndUpdateChildTest(){
        
        test.StartTest();
        createTestDataForDonor();
        
        List<Contact> primaryConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];
        
        List<Contact> participantConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Participant').Id LIMIT 1];
        
        
        List<SponsoredChildrenInfo> SponsoredChildrenInfoList = DonorPortalService.GetSponsoredChildren(Integer.ValueOF(participantConListAfterInsert.get(0).Child_Number__c));
        
        List<LTEOptInInfo> LTEOptInInfoList = DonorPortalService.GetOptInsBySponsor(Integer.ValueOF(participantConListAfterInsert.get(0).Contact_Number__c));
        system.debug('----LTEOptInInfoList----' + LTEOptInInfoList);
        if(!LTEOptInInfoList.isEmpty())
        	system.assertEquals('Active', LTEOptInInfoList.get(0).Status);
        
        //Testing for negative result
        List<LTEOptInInfo> LTEOptInInfoListEmptyList = DonorPortalService.GetOptInsBySponsor(11111);
        system.assertEquals(0, LTEOptInInfoListEmptyList.size());
        
        //testing for method - UpdateOptInByChild of class 'DonorPortalService'
        Boolean trueResult = DonorPortalService.UpdateOptInByChild(Integer.ValueOF(participantConListAfterInsert.get(0).Contact_Number__c), 
                                                            Integer.ValueOF(participantConListAfterInsert.get(0).National_Office_Number__c), 
                                                            Integer.ValueOF(participantConListAfterInsert.get(0).Child_Number__c), false);
        //system.assertEquals(true, trueResult);
        
        
        //testing method UpdateOptInByChild with some garbage value to cover negative result
        Boolean negativeResult = DonorPortalService.UpdateOptInByChild(111, 222, 333, false);
        system.assertEquals(false, negativeResult);
        
        
        
        test.StopTest();
        
    }
    
    //Method Name                   : GetLTEOptInGlobal
    //Purpose                       : testMethod for method 'GetLTEOptInGlobal' of class 'DonorPortalService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Jagjeet Singh 
    //Reference                     : T-487436
    //Date                          : April 4,2016
    static testMethod void GetLTEOptInGlobalTest(){
        //start Test
        test.StartTest();
        
        //create test data
        createTestDataForDonor();
        List<Contact> primaryConListAfterInsert = [Select Id, Name, recordTypeId, recordType.Name, Contact_Number__c, National_Office__c, National_Office_Number__c, Child_Number__c FROM Contact WHERE Id = :mapRectypeContact.get('Household').Id LIMIT 1];
        //invoke the web service method.
        LTEOptInGlobalInfo infoRet = DonorPortalService.GetLTEOptInGlobal(Integer.ValueOf(primaryConListAfterInsert.get(0).Contact_Number__c));
        
        //asserts
        if(infoRet != null)
        	system.assertEquals('Active', infoRet.Status);
        
        test.StopTest();
    }
    
    
    
//-----payment methods for TransactionService    

 //Method Name                   : IsAGPActiveTest
    //Purpose                       : testMethod for method 'IsAGPActive' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016

    private static testMethod void IsAGPActiveTest() {
        //TODO : Not able to Add the payment method. Problem with the merchant name.
        test.startTest();
        
            createTestData();
            Id PM_EFT_RT = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
            
            Contact c = [select id, AccountId, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
            
            
            rC_Giving__Payment_Method__c paymentMethod = TestUtils.createPaymentMethod('testPaymentMethod','EFT',true,acc,false);
            paymentMethod.RecordTypeId = PM_EFT_RT;
            paymentMethod.rC_Giving__Contact__c = c.Id;
            //paymentMethod.rC_Connect__Payment_Processor__c = 'Sage'; 
            //paymentMethod.rC_Connect__Merchant_Name__c = 'testMerchantName';
            //insert paymentMethod;
            system.debug('---paymentMethod---' + paymentMethod);
            
            //rC_Giving__Payment_Method__c payMethodAfterInsert = [select id, name, Payment_Method_Number__c from rC_Giving__Payment_Method__c where id = :paymentMethod.Id limit 1];
            List<rC_Giving__Payment_Method__c> paymentMethodList = [select Id, Account_Number_E__c, Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where rC_Giving__Is_Active__c = true limit 1];
             if(paymentMethodList.size()>0){
                paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'EFT';
                paymentMethodList.get(0).rC_Giving__Account__c = c.AccountId;
                paymentMethodList.get(0).rC_Giving__Contact__c = c.Id;
                update paymentMethodList;
                System.debug('---payment updated-----'+paymentMethodList);
             }
            Boolean isAGPActive = TransactionService.IsAGPActive(123,  Integer.valueOf(c.Contact_Number__c));
            isAGPActive = TransactionService.IsAGPActive(Integer.valueOf(paymentMethodList.get(0).Payment_Method_Number__c),  Integer.valueOf(c.Contact_Number__c));
            system.debug('---isAGPActive---' + isAGPActive);
            
            //system.assertEquals(true, isAGPActive);
            
            //testing for Negative result
            //String nullBankName = TransactionService.IsAGPActive(123);
            //system.assertEquals(null, nullBankName);
            
        test.stopTest();
    }
    
    //Method Name                   : SubmitTransactionToQueueTest
    //Purpose                       : testMethod for method 'SubmitTransactionToQueue' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    
    
    private static testMethod void SubmitTransactionToQueueTest() {
        
        test.startTest();
        createTestData();
            TransactionInfo info = new TransactionInfo();
            Contact c = [select id, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact limit 1];
            info.DonorId = Integer.valueOf(c.Contact_Number__c);
            DonationInfo donInfo = new DonationInfo();
            donInfo.Amount = 1000;
            donInfo.childNumber = 100;
            List<DonationInfo> donInfoList = new List<DonationInfo>();
            info.PurchasedDonations = donInfoList;
            info.PaymentId = 0;
            Envelope env = TransactionService.SubmitTransactionToQueue(info);
            system.debug('---ReturnMessage---' + env.ReturnMessage);
            system.debug('---ErrorMessage---' + env.ErrorMessage);
            system.debug('---StackTrace---' + env.StackTrace);
            info.DonorId = 0;
            info.DonorTitleId = 0;
            info.DonorState = 0;
            info.DonorCountryCode ='0';
            info.PaymentId = 0;
            env = TransactionService.SubmitTransactionToQueue(info);
            info.PaymentId = 123;
            info.TransactionId = 124;
            env = TransactionService.SubmitTransactionToQueue(info);
            system.assertEquals(env.NewID, null);
            
            //testing for Negative result
            //String nullBankName = TransactionService.IsAGPActive(123);
            //system.assertEquals(null, nullBankName);
            
        test.stopTest();
    }
    
    //Method Name                   : AddAgpTest
    //Purpose                       : testMethod for method 'AddAgp' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    
    private static testMethod void AddAgpTest() {
         test.startTest();
         createTestData();
         AgpInfo info = new AgpInfo();
         info.DateExpiration = '04/21/2016';
         info.AgpType = 'DB';
         info.FullName = 'Test';
         Contact c = [select id, AccountId,  name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
         List<rC_Giving__Payment_Method__c> paymentMethodList = [select Id, Account_Number_E__c, Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where rC_Giving__Is_Active__c = true limit 1];
         if(paymentMethodList.size()>0){
            paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'EFT';
            paymentMethodList.get(0).rC_Giving__Account__c = c.AccountId;
            paymentMethodList.get(0).rC_Giving__Contact__c = c.Id;
            update paymentMethodList;
         }
         Id payId = paymentMethodList.get(0).Id;
         Envelope returnValue = TransactionService.AddAgp(info);
         test.stopTest();
    }
    
    //Method Name                   : UpdateAgpStatusTest
    //Purpose                       : testMethod for method 'UpdateAgpStatus' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    
    private static testMethod void UpdateAgpStatusTest() {
         test.startTest();
         createTestData();
         AgpInfo info = new AgpInfo();
         info.Active = 'A';
         Contact c = [select id, AccountId,  name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
         List<rC_Giving__Payment_Method__c> paymentMethodList = [select Id, Account_Number_E__c, Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where rC_Giving__Is_Active__c = true limit 1];
         if(paymentMethodList.size()>0){
            paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'EFT';
            paymentMethodList.get(0).rC_Giving__Account__c = c.AccountId;
            paymentMethodList.get(0).rC_Giving__Contact__c = c.Id;
            update paymentMethodList;
         }
         info.Id = Integer.valueOf(paymentMethodList.get(0).Payment_Method_Number__c);
         Integer numb = TransactionService.UpdateAgpStatus(info);
         System.assertEquals(numb ,1);
         test.stopTest();
    }
    
    //Method Name                   : UpdateAgpTest
    //Purpose                       : testMethod for method 'UpdateAgp' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 19,2016
    private static testMethod void UpdateAgpTest() {
         test.startTest();
         createTestData();
         AgpInfo info = new AgpInfo();
         info.DateExpiration = '04/21/2016';
         TransactionService.UpdateAgp(info);
         Contact c = [select id, name, AccountId, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where Id = :con1.Id];
         info.ContactId = Integer.valueOf(c.Contact_Number__c);
         List<rC_Giving__Payment_Method__c> paymentMethodList = [select Id, Account_Number_E__c, Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where rC_Giving__Is_Active__c = true limit 1];
         if(paymentMethodList.size()>0){
            paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'EFT';
            paymentMethodList.get(0).rC_Giving__Account__c = c.AccountId;
            paymentMethodList.get(0).rC_Giving__Contact__c = c.Id;
            update paymentMethodList;
         }
         info.Id = Integer.valueOf(paymentMethodList.get(0).Payment_Method_Number__c);
         info.Active = 'a';
         Boolean bool = TransactionService.UpdateAgp(info);
         //System.assertEquals(bool ,true);
         test.stopTest();
    }
    
    //Method Name                   : GetAGPByContactIdTest
    //Purpose                       : testMethod for method 'GetAGPByContactId' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 19,2016
    
    private static testMethod void GetAGPByContactIdTest() {
         test.startTest();
         createTestData();
         Id PM_EFT_RT = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
         Contact c = [select id, AccountId, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
         TransactionInfo info = new TransactionInfo();
         List<rC_Giving__Payment_Method__c> paymentMethodList = [select Id, Account_Number_E__c, Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where rC_Giving__Is_Active__c = true limit 1];
         if(paymentMethodList.size()>0){
            paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'Other';
            paymentMethodList.get(0).rC_Giving__Account__c = c.AccountId;
            paymentMethodList.get(0).rC_Giving__Contact__c = c.Id;
            update paymentMethodList;
         }
         TransactionService.GetAGPByContactId(integer.valueOf(c.Contact_Number__c));
         paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'EFT';
         update paymentMethodList;
         //insert paymentMethod;
         //paymentMethod.rC_Connect__Payment_Processor__c = 'Sage'; 
         //paymentMethod.rC_Connect__Merchant_Name__c = 'testMerchantName';
         List<AgpInfo> infoList = TransactionService.GetAGPByContactId(integer.valueOf(c.Contact_Number__c));
         if(!infoList.isEmpty())
            System.assertEquals(infoList.size(), 1);
         test.stopTest();
    }
    
    //Method Name                   : GetAgpByIDTest
    //Purpose                       : testMethod for method 'GetAgpByID' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 19,2016
    private static testMethod void GetAgpByIDTest() {
         test.startTest();
         createTestData();
         Id PM_EFT_RT = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
         Contact c = [select id, AccountId,  name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
         TransactionInfo info = new TransactionInfo();
         List<rC_Giving__Payment_Method__c> paymentMethodList = [select Id, Account_Number_E__c, Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where rC_Giving__Is_Active__c = true limit 1];
         if(paymentMethodList.size()>0){
            paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'EFT';
            paymentMethodList.get(0).rC_Giving__Account__c = c.AccountId;
            paymentMethodList.get(0).rC_Giving__Contact__c = c.Id;
            update paymentMethodList;
         }
         String numberPayment = paymentMethodList.get(0).Payment_Method_Number__c;
         
         //paymentMethod.rC_Connect__Payment_Processor__c = 'Sage'; 
         //paymentMethod.rC_Connect__Merchant_Name__c = 'testMerchantName';
         //insert paymentMethod;
         AgpInfo infoAgp = TransactionService.GetAgpByID(Integer.valueOf(numberPayment));
         System.assertEquals(infoAgp.Id, Integer.valueOf(paymentMethodList.get(0).Payment_Method_Number__c));
         test.stopTest();
    }
    
    //Method Name                   : IsDuplicateAccountNumberTest
    //Purpose                       : testMethod for method 'IsDuplicateAccountNumber' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 19,2016
    private static testMethod void IsDuplicateAccountNumberTest() {
         test.startTest();
         createTestData();
         Id PM_EFT_RT = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
         Contact c = [select id, name, AccountId, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
         TransactionInfo info = new TransactionInfo();
        List<rC_Giving__Payment_Method__c> paymentMethodList = [select Id, Account_Number_E__c, Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where rC_Giving__Is_Active__c = true AND Payment_Method_Number__c <> NULL limit 1];
         if(paymentMethodList.size()>0){
            paymentMethodList.get(0).rC_Giving__Payment_Type__c = 'EFT';
            paymentMethodList.get(0).rC_Giving__Account__c = c.AccountId;
            paymentMethodList.get(0).rC_Giving__Contact__c = c.Id;
            paymentMethodList.get(0).rC_Giving__Routing_Number__c = '321';
            paymentMethodList.get(0).Account_Number_E__c = '464';
            update paymentMethodList;
         }
         String accountNumber = paymentMethodList.get(0).Account_Number_E__c;
         Integer numb = TransactionService.IsDuplicateAccountNumber(integer.valueOf(c.Contact_Number__c), Integer.valueOf(paymentMethodList.get(0).Payment_Method_Number__c), paymentMethodList.get(0).Account_Number_E__c,paymentMethodList.get(0).rC_Giving__Routing_Number__c,true,'');
         //System.assertEquals(numb, 1);
         numb = TransactionService.IsDuplicateAccountNumber(integer.valueOf(c.Contact_Number__c), Integer.valueOf(paymentMethodList.get(0).Payment_Method_Number__c), paymentMethodList.get(0).Account_Number_E__c,'123',true,'');
         //System.assertEquals(numb, 1);
         numb = TransactionService.IsDuplicateAccountNumber(0, 0, paymentMethodList.get(0).Account_Number_E__c,paymentMethodList.get(0).rC_Giving__Routing_Number__c,true,'');
         Integer counting = [select count() from rC_Giving__Payment_Method__c where Account_Number_E__c = :accountNumber and rC_Giving__Is_Active__c = true AND rC_Giving__Routing_Number__c = '321'];
         System.debug('---counting---'+counting);
         //System.assertEquals(numb, 1);
         test.stopTest();
    }
      //creates the test data for Transaction Service Payment Methods
    static void createTestData(){
        List<Account> listAcc = new List<Account>();
        
        acc = TestUtils.createAccount('test123',false);
        listAcc.add(acc);
        NO_Acc = TestUtils.createAccountWithRT('1st National Account test134', ACC_NO_RT, null, '809', '46143', false);
        listAcc.add(No_Acc);
        insert listAcc;
        
        Account LP_Acc = TestUtils.createAccountWithRT('Local Partner test account', ACC_LP_RT, No_Acc, null, null, false);
        LP_Acc.Local_Partner_ID__c = '1121145'; 
        insert LP_Acc;
        system.debug('----LP_Acc----' + LP_Acc);
        
        Account CO_Acc =TestUtils.createAccountWithRT('Community test account', ACC_CO_RT, LP_Acc ,null,'3467' , true);
        system.debug('----CO_Acc----' + CO_Acc);
        
        // creating contact record
        List<Contact> listCon = new List<Contact>();
        con = TestUtils.createContact(acc ,'Joe', 'Kid', false);
        con.Community__c = CO_Acc.id;
        con.RecordTypeId = CON_PT_RT;
        con.Participant_Case_Number__c = '87654';
        con.Local_Partner__c = LP_Acc.Id;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.National_Office__c = No_Acc.Id;
        con.Village__c = 'villageTest';
        listCon.add(con);
        system.debug('----con----' + con);
        
        con1 =TestUtils.createContact(acc ,'Joe', 'Household', false);
        con1.Community__c = CO_Acc.id;
        con1.RecordTypeId = CON_HD_RT;
        //con1.Participant_Case_Number__c = '87655';
        //con1.Local_Partner__c = LP_Acc.Id; 
        con1.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        //con1.National_Office__c = No_Acc.Id;
        con1.Village__c = 'villageTest1';
        con1.mailingCity = 'testCity';
        con1.mailingState = 'testState';
        con1.mailingCountry = 'testCountry';
        con1.mailingStreet = 'testStreet';
        con1.mailingPostalCode = '12311';
        //con1.AccountId = No_Acc.Id;
        listCon.add(con1);
        
        insert listCon;
        
        for(Contact c : [select id, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id OR id =: con1.Id]){
            system.debug('---con---' + c.id + '---Name---' + c.Name + '---RecordTypeId---' + c.RecordTypeId + '---Child_Number__c---' + c.Child_Number__c + '---Contact_Number__c---' + c.Contact_Number__c + '---National_Office_Number__c---' + c.National_Office_Number__c + '----\n----');
        }
        
        
    }
    
    //creates the test data for DonorPortalService Payment Related Methods
    static void createTestDataForDonor() {
        
        List<Account> accList = new List<Account>();
        NO_Acc = TestUtils.createAccountWithRT('1st National Account test', ACC_NO_RT, null, '209', '21245', true);
        accList.add(NO_Acc);
        
        NO_Acc2 = TestUtils.createAccountWithRT('2nd National Account test456',ACC_HH_RT, null, '301', '22241', true);
        accList.add(NO_Acc2);
        
        HH_Acc = TestUtils.createAccountWithRT('1st household Account test', ACC_HH_RT, null, '289', '22282', true);
        accList.add(HH_Acc);
        
       // insert accList;
        
        localPartner =TestUtils.createAccountWithRT('Local Partner', ACC_LP_RT, NO_Acc, null, null, false);
        localPartner.Local_Partner_ID__c = '1121005'; 
        insert localPartner;
        
        community = TestUtils.createAccountWithRT('Community', ACC_CO_RT, localPartner ,null,'3435' , false);
        community.BillingStreet = 'test Street';
        community.BillingCity = 'test City';
        community.BillingState = 'test State';
        community.BillingPostalCode = '12311';
        community.BillingCountry = 'test country';
        insert community;
        
         //create the rC_Bios__Preferred_Mailing_Address__c test data 
        rC_Bios__Address__c prefMailingAddTemp = TestUtils.createAddress('test Street 1','test Street 2','test City','12311','test country',false);
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        insert prefMailingAddTemp;
        
        rC_Bios__Address__c prefMailingAdd = [select id, Name, rC_Bios__Street_Line_1__c, rC_Bios__Street_Line_2__c,
                            rC_Bios__City__c, rC_Bios__State__c, rC_Bios__Postal_Code__c, rC_Bios__Country__c, rC_Bios__Unique_MD5__c
                            from rC_Bios__Address__c where id = :prefMailingAddTemp.Id limit 1];
        
        system.debug('---prefMailingAdd---' + prefMailingAdd);
        
        mapRectypeContact = new Map<String, Contact>();
        participantCon = TestUtils.createContact(HH_Acc, 'test Participant first name', 'test Participant last name', false);
        participantCon.accountId = null;
        participantCon.recordTypeId = CON_PT_RT;
        participantCon.National_Office__c = NO_Acc.Id; 
        participantCon.Community__c = community.id;
        participantCon.Local_Partner__c = localPartner.Id;
        participantCon.Participant_Case_Number__c = '11211';
        participantCon.rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored';
        participantCon.rC_Bios__Birth_Month__c = '02';
        participantCon.rC_Bios__HOME_Email__c = 'testparticipanthomeemail@test.com';
        participantCon.Short_Name__c = 'testShortName';
        participantCon.rC_Bios__Preferred_Mailing_Address__c = prefMailingAdd.Id;
        mapRectypeContact.put('Participant', participantCon);
        
        householdCon = TestUtils.createContact(HH_Acc, 'test Household first name', 'test Household last name', false);
        houseHoldCon.rC_Bios__Active__c = true;
        householdCon.recordTypeId = CON_HD_RT;
        householdCon.rC_Bios__HOME_Email__c = 'testhomeemail@test.com';
        householdCon.MailingStreet = 'test street';
        householdCon.MailingCountry = 'test description';
        householdCon.MailingCity = 'test City';
        householdCon.MailingState = 'test Description';
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
        
        Campaign testCamp = TestUtils.createCampaign('test camp',true);
        
        rC_Giving__GAU__c testGAU = TestUtils.createGeneralAccountingUnit('600',true);
        
        donationOpp = TestUtils.createOpportunity(NO_Acc, 'Test Donation Opp 123', 100000, false);
        donationOpp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        donationOpp.Product_Type__c = 'Sponsorship';
        donationOpp.Product_Sub_Type__c = 'Child Sponsorship';
        donationOpp.RecordTypeId = OPP_DON_RT;
        donationOpp.rC_Giving__Primary_Contact__c = mapRectypeContact.get('Participant').Id;
        donationOpp.Participant__c = mapRectypeContact.get('Participant').Id;
        donationOpp.Child_Correspondence_Opt_In_Date__c = Datetime.newInstance(2016, 2, 17);
        donationOpp.All_Child_Correspondence__c = true;
        donationOpp.Description__c = 'test Description';
        donationOpp.rC_Giving__Giving_Amount__c = 2000;
        donationOpp.rC_Giving__Giving_Frequency__c = 'Monthly';
        donationOpp.rC_Sponsorship__Opportunity_Group_Id__c = 202;
        donationOpp.CampaignId = testCamp.Id;        
        donationOpp.rC_Giving__Is_Sustainer__c = true;
        donationOpp.rC_Giving__Anniversary_Date__c = system.today();
        donationOpp.Paid_Through_Date__c = system.today().Addyears(1); //Date.newInstance(System.Today().Addyears(1).year(), 02, System.Today().day());
        donationOpp.rC_Giving__GAU__c = testGAU.Id;
        insert donationOpp;
        system.debug('----donationOpp---' + donationOpp);
        
        transactionOpp = TestUtils.createOpportunity(NO_Acc, 'Test transaction Opp ', 100000, false);
        transactionOpp.RecordTypeId = OPP_TRAN_RT;
        transactionOpp.rC_Giving__Primary_Contact__c = mapRectypeContact.get('Household').Id;
        transactionOpp.Participant__c = mapRectypeContact.get('Participant').Id;
        transactionOpp.StageName = 'Adjusted';
        transactionOpp.rC_Giving__Parent__c = donationOpp.Id;
        transactionOpp.CloseDate = system.today()  - 1;
        transactionOpp.Amount = 200;
        insert transactionOpp;
        system.debug('----transactionOpp---' + transactionOpp);
       
        
        /*
        //create the contact data
        Contact con = TestUtils.createContact(NO_Acc2, 'test first name', 'test last name', false);
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
        */
        
        WebTitlesRefCodes__c webTitRefCode = TestUtils.createWebTitlesRefCodes('2',true,false);
        webTitRefCode.Description__c = 'test salutation';
        insert webTitRefCode;
        
        //CountryRefCodes data.
        CountriesRefCodes__c refCodes = TestUtils.createCountriesRefCodes('IND',true,'IND',false);
        refCodes.Description__c = 'test description';
        insert refCodes;
        
        //creates the state territory codes.
        StateTerrProvRefCodes__c stateTerrCodes = TestUtils.createStateTerrProvRefCodes('12',true,'re','RJA',false);
        stateTerrCodes.Description__c = 'test Description';
        insert stateTerrCodes;
    }
    
}