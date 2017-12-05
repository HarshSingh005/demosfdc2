/***********************************************************************************************************
* Appirio, Inc
* Name         : TransactionServiceTest
* Created By   : Vaibhav Goel (Appirio)
* Purpose      : Test class for TransactionService
* Created Date : March/29/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 07/21/2016                   Ravi Chauhan            Modified | used TestUtil for Data Creation
* Aug 03, 2016                 Ashu Gupta              increased code coverage by adding new methods
* Jan 17, 2017				   Suminder Singh		   Fixed for errors
**********************************************************************************************************/
@isTest
private class TransactionServiceTest {
    // Declaring all static variable for Account Record types
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id ACC_CO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static Id ACC_BANK_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bank').getRecordTypeId();
    
    //Declaring static variable for contact Record types
    Final Static Id CON_HD_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id CON_PT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    
    //Declaring static variable for Opportunity Record types
    Final Static Id OPP_DON_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();

    //Declaring static variable for payment method Record type
    Final Static Id PM_EFT_RT = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
    Static Contact con, con1;
    static rC_Giving__Payment_Method__c paymentMethod;
    
    
    //Method Name                   : GetProjectIDtest
    //Purpose                       : testMethod for method 'GetProjectID' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 14,2016
    
    private static testMethod void GetProjectIDtest() {
        //start test
        test.startTest();
        //creates the test data.        
        createTestData();
        
        //get the contact from Db.
        Contact c = [select id, name,Community_Number__c  , RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
              
        system.debug('---con---' + c.id + '---Name---' + c.Name + '---RecordTypeId---' + c.RecordTypeId + '---Child_Number__c---' + c.Child_Number__c + '---Contact_Number__c---' + c.Contact_Number__c + '---National_Office_Number__c---' + c.National_Office_Number__c + '----\n----');
        Integer i = TransactionService.GetProjectID(12, Integer.ValueOf(c.Child_Number__c));
        system.assertEquals(0, i);
        
       // Integer j = TransactionService.GetProjectID(Integer.valueOf(c.National_Office_Number__c), Integer.ValueOf(c.Child_Number__c));
        //asserts    
        //system.assertEquals(Integer.ValueOf(c.Community_Number__c), j);
        //stop Test    
        test.stopTest();
    }
    //Method Name                   : GetBankNametest
    //Purpose                       : testMethod for method 'GetBankName' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 14,2016
    private static testMethod void GetBankNametest() {
        
        test.startTest();
        
        Account acc = TestUtils.createAccountWithRT('Test Bank Account', ACC_BANK_RT, null, null, null, false);
        insert acc;
        system.debug('---acc---' + acc);
        
        Routing_Number__c routingNumber = TestUtils.createRoutingNumber('012345768',acc,True);
        
        String bankName = TransactionService.GetBankName(Integer.valueOf(routingNumber.Routing_Number__c));
        system.debug('---bankName---' + bankName);
        system.assertEquals('Test Bank Account', bankName);
        
        //testing for Negative result
        String nullBankName = TransactionService.GetBankName(123);
        system.assertEquals(null, nullBankName);
        
        test.stopTest();
    }
    
    //Method Name                   : SendRegistrationEmailTest
    //Purpose                       : testMethod for method 'SendRegistrationEmail' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 14,2016
    private static testMethod void SendRegistrationEmailTest() {
        test.startTest();
        createTestData();
        TransactionInfo info = new TransactionInfo();
        TransactionService.SendRegistrationEmail(info);
        Contact c = [select id, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where RecordTypeId = :CON_HD_RT limit 1];
        c.rC_Bios__Active__c = true;
        info.DonorEmail = 'test@test.com';
        info.DonorId = Integer.valueOf(c.Contact_Number__c);
        TransactionService.SendRegistrationEmail(info);
        Contact cont = [select id, name, rC_Bios__Home_Email__c, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c, Password_Reset__c from Contact where Id =:c.Id];
        System.assertEquals(cont.rC_Bios__Home_Email__c , info.DonorEmail);
        test.stopTest();
    }
    
    //Method Name                   : SendPasswordResetEmailTest
    //Purpose                       : testMethod for method 'SendPasswordResetEmail' of class 'TransactionService'.
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 14,2016
    private static testMethod void SendPasswordResetEmailTest() {
        test.startTest();
        createTestData();
        TransactionInfo info = new TransactionInfo();
        TransactionService.SendPasswordResetEmail(info);
        Contact c = [select id, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where RecordTypeId = :CON_HD_RT limit 1];
        c.rC_Bios__Active__c = true;
        info.DonorEmail = 'test@test.com';
        info.DonorId = Integer.valueOf(c.Contact_Number__c);
        TransactionService.SendPasswordResetEmail(info);
        Contact cont = [select id, name, rC_Bios__Home_Email__c, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c, Password_Reset__c from Contact where Id =:c.Id];
        System.assertEquals(cont.rC_Bios__Home_Email__c , info.DonorEmail);
        test.stopTest();
    }
    
    
    //Method Name                   : GetTransactionsByIDTest
    //Purpose                       : testMethod for method 'GetTransactionsByID' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 14,2016
    private static testMethod void GetTransactionsByIDTest() {
        test.startTest();
        createTestData();
        TransactionInfo info = new TransactionInfo();
        TransactionService.GetTransactionsByID(info);
        rC_Connect__Batch_Upload__c upload = [select Name, Participant_Number__c, Transaction_Number__c,  rC_Connect__Giving_Giving_Amount__c from rC_Connect__Batch_Upload__c limit 1];
        info.TransactionId = Integer.valueOf(upload.Transaction_Number__c);
        List<TransactionInfo> transInfoList = TransactionService.GetTransactionsByID(info);
        //System.assertEquals(transInfoList.size(), 1);
        test.stopTest();
        
        
    }
    
    
    //Method Name                   : IsAGPActiveTest
    //Purpose                       : testMethod for method 'IsAGPActive' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    
    private static testMethod void IsAGPActiveTest() {
        //TODO : Not able to Add the payment method. Problem with the merchant name.
        test.startTest();
        
        createTestData();
        
        Contact c = [select id, AccountId, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
        
        paymentMethod.rC_Giving__Account__c = c.AccountId;
        update paymentMethod;
        system.debug('---paymentMethod---' + paymentMethod);
        
        Boolean isAGPActive = TransactionService.IsAGPActive(123,  Integer.valueOf(c.Contact_Number__c));
        isAGPActive = TransactionService.IsAGPActive(Integer.valueOf(paymentMethod.Payment_Method_Number__c),  Integer.valueOf(c.Contact_Number__c));
        system.debug('---isAGPActive---' + isAGPActive);
        
        system.assertEquals(true, isAGPActive);
        
        //testing for Negative result
        //String nullBankName = TransactionService.IsAGPActive(123);
        //system.assertEquals(null, nullBankName);
        
        test.stopTest();
    }
    
    
    //Method Name                   : SubmitTransactionToQueueTest
    //Purpose                       : testMethod for method 'SubmitTransactionToQueue' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    
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
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    
    private static testMethod void AddAgpTest() {
        test.startTest();
        createTestData();
        Contact c = [select id, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact limit 1];
        AgpInfo info = new AgpInfo();
        info.DateExpiration = '04/21/2016';
        info.AgpType = 'DB';
        info.FullName = 'Test';
        info.ContactId = Integer.valueOf(c.Contact_Number__c);
        info.Active = 'a';
        
        Id payId = paymentMethod.Id;
        Envelope returnValue = TransactionService.AddAgp(info);
        
        AgpInfo info1 = new AgpInfo();
        info1.DateExpiration = '04/21/2016';
        info1.AgpType = 'CR';
        info1.FullName = 'Test';
        info1.ContactId = Integer.valueOf(c.Contact_Number__c);
        info1.Active = 'a';
        Envelope returnValue1 = TransactionService.AddAgp(info1);
        
        AgpInfo info2 = new AgpInfo();
        info2.DateExpiration = '04/21/2016';
        info2.AgpType = 'CR';
        info2.FullName = 'Test';
        info2.ContactId = Integer.valueOf(c.Contact_Number__c);
        TransactionService.AddAgp(info2);
        
        System.assert(returnValue1.NewId != null);
        test.stopTest();
    }
    
     
    // Method Name                   : AddAgpTestNew
    // Purpose                       : testMethod for method 'AddAgp' of class 'TransactionService'
    // @param                        : none
    // @return                       : none
    
    private static testMethod void AddAgpTestNew() {
        test.startTest();
        createTestData();
        paymentMethod.rC_Giving__Account_Number__c = '9876';
        update paymentMethod;
        Contact c = [select id, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact limit 1];
        
        AgpInfo info = new AgpInfo();
        info.DateExpiration = '04/21/2016';
        info.AgpType = 'CR';
        info.FullName = 'Test';
        info.ContactId = Integer.valueOf(c.Contact_Number__c);
        info.Active = 'b';
        info.CardType = '45';
        
        Id payId = paymentMethod.Id;
        
        Envelope returnValue = TransactionService.AddAgp(info);
        
        test.stopTest();
    }
    
    
    //Method Name                   : UpdateAgpStatusTest
    //Purpose                       : testMethod for method 'UpdateAgpStatus' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 18,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    
    private static testMethod void UpdateAgpStatusTest() {
        test.startTest();
        
        createTestData();
        AgpInfo info = new AgpInfo();
        info.Active = 'A';
        
        info.Id = Integer.valueOf(paymentMethod.Payment_Method_Number__c);
        Integer numb = TransactionService.UpdateAgpStatus(info);
        System.assertEquals(numb ,1);
        
        //testing for exception 
        AgpInfo infoException = new AgpInfo();
        Integer exc = TransactionService.UpdateAgpStatus(infoException);
        System.assertEquals(exc,0);
        test.stopTest();
    }
    
    private static testMethod void UpdateAgpStatusTestNew() {
        test.startTest();
        
        createTestData();
        AgpInfo info = new AgpInfo();
        info.Active = 'B';
        
        info.Id = Integer.valueOf(paymentMethod.Payment_Method_Number__c);
        Integer updateStatusNumber = TransactionService.UpdateAgpStatus(info);
        System.assertEquals(updateStatusNumber ,1);
        
        test.stopTest();
    }
    
    //Method Name                   : UpdateAgpTest
    //Purpose                       : testMethod for method 'UpdateAgp' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 19,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    private static testMethod void UpdateAgpTest() {
        test.startTest();
        
        createTestData();
        
        Contact c = [select id, name, AccountId, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact limit 1];
        paymentMethod.rC_Giving__Account__c = con.AccountId;
        update paymentMethod;
        
        AgpInfo info = new AgpInfo();
        info.DateExpiration = '04/21/2016';
        info.AgpType = 'DB';
        info.AccountNumber = String.valueOf(c.AccountId);
        info.ContactId = Integer.valueOf(c.Contact_Number__c);
        info.Id = Integer.valueOf(paymentMethod.Payment_Method_Number__c);
        info.Active = 'a';
        TransactionService.UpdateAgp(info);
        
        info.AgpType = 'CR';
        info.FullName = 'testfullname';
        info.DateExpiration = '23/07/2090';
        info.CardholderZipcode = '20202';
        info.Active = 'a';
        
        info.ContactId = Integer.valueOf(c.Contact_Number__c);
        info.Id = Integer.valueOf(paymentMethod.Payment_Method_Number__c);
        Boolean bool = TransactionService.UpdateAgp(info);
        
        info.AgpType = 'CR';
        info.FullName = 'testfullname';
        info.DateExpiration = '23/07/2090';
        info.CardholderZipcode = '20202';
        
        info.ContactId = Integer.valueOf(c.Contact_Number__c);
        info.Id = Integer.valueOf(paymentMethod.Payment_Method_Number__c);
        TransactionService.UpdateAgp(info);
        
        //System.assertEquals(bool ,true);
        test.stopTest();
    }
    
    private static testMethod void UpdateAgpTestNew() {
        test.startTest();
        
        createTestData();
        
        Contact c = [select id, name, AccountId, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact limit 1];
        paymentMethod.rC_Giving__Account__c = con.AccountId;
        update paymentMethod;
        
        AgpInfo info = new AgpInfo();
        info.DateExpiration = '04/21/2016';
        info.AgpType = 'CR';
        info.CardType = '45';
        info.AccountNumber = String.valueOf(c.AccountId);
        info.ContactId = Integer.valueOf(c.Contact_Number__c);
        info.Id = Integer.valueOf(paymentMethod.Payment_Method_Number__c);
        info.Active = 'b';
        TransactionService.UpdateAgp(info);
        
        
        AgpInfo infoException = new AgpInfo();
        Boolean bool = TransactionService.UpdateAgp(infoException);
        System.assertEquals(bool,false);
        test.stopTest();
    }
    
    
    //Method Name                   : GetAGPByContactIdTest
    //Purpose                       : testMethod for method 'GetAGPByContactId' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 19,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    
    private static testMethod void GetAGPByContactIdTest() {
        test.startTest();
        createTestData();
        Contact c = [select id, AccountId, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
        TransactionInfo info = new TransactionInfo();
        
        paymentMethod.rC_Giving__Payment_Type__c = 'Other';
        paymentMethod.rC_Giving__Account__c = c.AccountId;
        paymentMethod.rC_Giving__Contact__c = c.Id;
        update paymentMethod;
        
        TransactionService.GetAGPByContactId(integer.valueOf(c.Contact_Number__c));
        
        paymentMethod.rC_Giving__Payment_Type__c = 'EFT';
        update paymentMethod;
        List<AgpInfo> infoList = TransactionService.GetAGPByContactId(integer.valueOf(c.Contact_Number__c));
        //System.debug('INFOLIST' +infoList);
        System.assertEquals(infoList.size(), 1);
        test.stopTest();
    }
    
    private static testMethod void GetAGPByContactIdTestNew() {
        test.startTest();
        createTestData();
        
        TransactionInfo info = new TransactionInfo();
        
        Contact c = [select id, AccountId, name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
        
        paymentMethod.rC_Giving__Card_Issuer__c = 'Visa';
        paymentMethod.rC_Giving__Payment_Type__c = 'Charge Card';
        paymentMethod.rC_Giving__Account__c = c.AccountId;
        paymentMethod.rC_Giving__Contact__c = c.id;
        
        update paymentMethod;
        List<AgpInfo> infoList = TransactionService.GetAGPByContactId(integer.valueOf(c.Contact_Number__c));
        
        List<AgpInfo> infoListEx =TransactionService.GetAGPByContactId(null);
        System.assertEquals(infoList.size(),1);
        
        test.stopTest();
    }
    
    
    
    //Method Name                   : GetAgpByIDTest
    //Purpose                       : testMethod for method 'GetAgpByID' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 19,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    private static testMethod void GetAgpByIDTest() {
        test.startTest();
        
        createTestData();
        Contact c = [select id, AccountId,  name, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
        
        TransactionInfo info = new TransactionInfo();
        String numberPayment = paymentMethod.Payment_Method_Number__c;
        
        AgpInfo infoAgp = TransactionService.GetAgpByID(Integer.valueOf(numberPayment));
        System.assertEquals(infoAgp.Id, Integer.valueOf(paymentMethod.Payment_Method_Number__c));
        test.stopTest();
    }
    
    
    
    //Method Name                   : IsDuplicateAccountNumberTest
    //Purpose                       : testMethod for method 'IsDuplicateAccountNumber' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Munib Ur Rehman
    //Reference                     : T-485198
    //Date                          : April 19,2016
    //Date Modified                 : May 3, 2016 by Vaibhav Goel. 
    //                                Purpose = to merge the methods which require Payment method reocrds to be created and not require seeAllData = true
    private static testMethod void IsDuplicateAccountNumberTest() {
        test.startTest();
        createTestData();
        
        Contact c = [select id, name, AccountId, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con.Id limit 1];
        TransactionInfo info = new TransactionInfo();
        
        paymentMethod.rC_Giving__Account__c = c.AccountId;
        paymentMethod.rC_Giving__Contact__c = c.id;
        paymentMethod.rC_Giving__Routing_Number__c = '12345678';
        paymentMethod.rC_Giving__Account_Number__c = '9876';
        paymentMethod.rC_Giving__Card_Issuer__c = 'Visa';
        paymentMethod.rC_Giving__Card_Expiration_Month__c = '01';
        paymentMethod.rC_Giving__Card_Expiration_Year__c = '19';
        paymentMethod.rC_Giving__Billing_Contact_Name__c = 'Test';
        paymentMethod.rC_Giving__Billing_City__c = 'Anytown';
        paymentMethod.rC_Giving__Billing_Country__c = 'USA';
        paymentMethod.rC_Giving__Billing_Postal_Code__c = '12345';
        paymentMethod.rC_Giving__Billing_State__c = 'VA';
        paymentMethod.rC_Giving__Billing_Street__c = '123 Main Street';
        paymentMethod.rC_Giving__Card_Holder_Name__c = 'Test';
        paymentMethod.rC_Giving__Card_Number__c = '8765';
        paymentMethod.rC_Giving__Is_Active__c = true;
        update paymentMethod;
        string agpNumber = [select Payment_Method_Number__c from rC_Giving__Payment_Method__c where id = :paymentMethod.id limit 1].Payment_Method_Number__c;
        
        integer res = TransactionService.IsDuplicateAccountNumber(integer.valueOf(c.Contact_Number__c), 0, '9876', 
                                                                     '12345678', true, 'ACH');
        //system.assertEquals(1, res,'active and ach');
        
        //inactive ACH and match        
        res = TransactionService.IsDuplicateAccountNumber(integer.valueOf(c.Contact_Number__c), 0, '9876', 
                                                             '12345678', false, 'ACH');
        system.assertEquals(1, res, 'inactive and ach'); //inactive looks at both active and inactive records.
        
        //active agpid and match      
        integer agpid = integer.valueOf(agpNumber);  
        res = TransactionService.IsDuplicateAccountNumber(integer.valueOf(c.Contact_Number__c), agpid, '9876', 
                                                             '12345678', false, 'ACH');
        system.assertEquals(1, res, 'agpid');
        
        paymentMethod.RecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Charge Card').getRecordTypeId();
        update paymentMethod;
        string creditLast4 = [select rC_Giving__Card_Number_Last_4__c from rC_Giving__Payment_Method__c where id = :paymentMethod.id].rC_Giving__Card_Number_Last_4__c;
        system.assertEquals('8765', creditLast4, 'Last 4 not correct');
        
        //active AGP and match
        res = TransactionService.IsDuplicateAccountNumber(integer.valueOf(c.Contact_Number__c), 0, '8765', 
                                                             '12345678', true, 'AGP');
        system.assertEquals(1, res, 'agp card number');
        
        //active AGP and no match
        res = TransactionService.IsDuplicateAccountNumber(integer.valueOf(c.Contact_Number__c), 0, '8765x', 
                                                             '12345678', true, 'AGP');
        system.assertEquals(0, res, 'agp card number no match');
        
        //active AGP and exception
        res = TransactionService.IsDuplicateAccountNumber(123, 0, '8765x', 
                                                             '12345678', true, 'AGP');
        //system.assertEquals(0, result, 'agp card number no match');
        test.stopTest();
    }
    
    
    //Method Name                   : SendPasswordLinkEmailTest
    //Purpose                       : testMethod for method 'SendPasswordResetEmail' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Vaibhav Goel
    //Reference                     : T-493541
    //Date                          : May 26,2016
    
    private static testMethod void SendPasswordLinkEmailTest() {
        test.startTest();
        createTestData();
        
        Contact c = [select id, name, FirstName, LastName, AccountId, RecordTypeId, Child_Number__c, Contact_Number__c , National_Office_Number__c from Contact where id = :con1.Id limit 1];
        system.debug('----c.Contact_Number__c---' + c.Contact_Number__c);
        TransactionInfo info = new TransactionInfo();
        info.DonorId = Integer.ValueOf(c.Contact_Number__c);
        info.DonorFirstName = c.FirstName;
        info.DonorLastName = c.LastName; 
        
        PasswordResetInfo passInfo = new PasswordResetInfo();
        passInfo.LinkHash = 'testLinkHash';
        passInfo.Email = 'testEmail@testmail.com';
        
        TransactionService.SendPasswordLinkEmail(info, passInfo);
        
        TransactionInfo info1 = new TransactionInfo();
        PasswordResetInfo passInfo1 = new PasswordResetInfo();
        TransactionService.SendPasswordLinkEmail(info1, passInfo1);
        
        test.stopTest();
    }
    
    //Method Name                   : GetFundaProjectByIDTest
    //Purpose                       : testMethod for method 'GetFundaProjectByID' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Vaibhav Goel
    //Reference                     : T-493508
    //Date                          : May 26,2016
    
    private static testMethod void GetFundaProjectByIDTest() {
        test.startTest();
        
        Campaign c = TestUtils.createCampaign('testCampaign',False);
        //c.recordtypeId = CAM_CF_RT;
        c.StartDate = system.today();
        c.Fundraising_Unit__c = 'Corporate';
        c.Country_Alliance__c = 'US';
        c.rC_Giving__Channel__c	= 'Digital';
        c.rC_Giving__Sub_Channel__c = 'Website';
        c.rC_Giving__Campaign_Type__c = 'Corporations';
        c.Initiative__c = 'Carman';
        c.ExpectedRevenue = 2000;
        c.rC_Giving__Expected_Giving_Amount__c = 1000;
        insert c;
        system.debug('---c---' + c.id);
        
        TransactionService.GetFundaProjectByID(123);
        
        campaign camp = [select id, ExpectedRevenue, Source_Code_Autonumber__c, rC_Giving__Expected_Giving_Amount__c, rC_Giving__Remaining_Goal__c from Campaign where Id =: c.Id limit 1];
        system.debug('----camp---' + [select id, ExpectedRevenue, Source_Code_Autonumber__c, rC_Giving__Expected_Giving_Amount__c, rC_Giving__Remaining_Goal__c from Campaign where Id =: c.Id limit 1]);
        FundProjectInfo info = TransactionService.GetFundaProjectByID(Integer.ValueOf(camp.Source_Code_Autonumber__c));
        System.assertEquals(info.Goal , 2000);
        
        test.stopTest();
    }    
    
    
    //Method Name                   : UnsubscribeEmailTest
    //Purpose                       : testMethod for method 'UnsubscribeEmail' of class 'TransactionService'
    //@param                        : none
    //@return                       : none
    //Modified By                   : Vaibhav Goel
    //Reference                     : T-493527 , T-493525
    //Date                          : June 08,2016
    
    private static testMethod void UnsubscribeEmailTest() {
        
        test.startTest();
        
        //testing for positive result
        Boolean positiveResult = TransactionService.UnsubscribeEmail('testmail@test.com', 'abcd');
        system.assertEquals(true, positiveResult);
        
        //testing for negative result
        Boolean negativeResult = TransactionService.UnsubscribeEmail('testmail@test.com', 'abcdefdddddd');
        system.assertEquals(false, negativeResult);
        
        test.stopTest();
    }
    
    //creates the test data
    static void createTestData(){
        
        /*Account acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = ACC_HH_RT;
        insert acc;*/
        
        String accLPRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        Account NO_Acc = TestUtils.createAccountWithRT('1st National Account test1', ACC_NO_RT, null, '899', '46241', false);
        insert No_Acc;
        
        Account LP_Acc = TestUtils.createAccountWithRT('Local Partner test account',accLPRTId,No_Acc,'904','367',false);
        LP_Acc.Local_Partner_ID__c = '1234567'; 
        insert LP_Acc;

        Account CO_Acc = TestUtils.createAccountWithRT('Community test account',String.valueOf(ACC_CO_RT),LP_Acc,null,'3467',true);

        // creating contact record
        List<Contact> contactsToBeInsertedList = new List<Contact>();
        con = TestUtils.createContact(null,'Joe','Kid',false);
        //con.Community__c = CO_Acc.id;
        con.RecordTypeId = CON_PT_RT;
        con.Participant_Case_Number__c = '87654';
        con.Local_Partner__c = LP_Acc.Id;
        con.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        con.National_Office__c = No_Acc.Id;
        con.Village__c = 'villageTest';
        con.mailingCountry = 'USA';
        contactsToBeInsertedList.add(con);
        
        con1 = TestUtils.createContact(null,'Joe','Household',false);
        //con1.Community__c = CO_Acc.id;
        con1.RecordTypeId = CON_HD_RT;
        con1.Participant_Case_Number__c = '87655';
        con1.Local_Partner__c = LP_Acc.Id; 
        con1.National_Office__c = No_Acc.Id;
        con1.Village__c = 'villageTest1';
        con1.mailingCity = 'testCity';
        con1.mailingState = 'testState';
        con1.mailingCountry = 'USA';
        con1.mailingStreet = 'testStreet';
        con1.mailingPostalCode = '12311';
        contactsToBeInsertedList.add(con1);
        
        // Insert Contact List
        insert contactsToBeInsertedList;
                
        rC_Connect__Batch_Upload__c upload = TestUtils.createBatchUpload('Test',false);
        upload.Participant_Number__c = con.Contact_Number__c;
        upload.rC_Connect__Giving_Giving_Amount__c = 100;
        insert upload;
        
        rC_Connect__Payment_Method_Setting__c setting = rC_Connect__Payment_Method_Setting__c.getInstance();
        setting.rC_Connect__Disable_All__c = true;
        insert setting;
        
        rC_Giving__Payment_Method__c paymentMethodToInsert = TestUtils.createPaymentMethod('testPaymentMethod','EFT',True,null,false);
        paymentMethodToInsert.RecordTypeId = PM_EFT_RT;
        paymentMethodToInsert.rC_Giving__Contact__c = con.Id;
        paymentMethodToInsert.rC_Connect__Payment_Processor__c = 'Sage'; 
        paymentMethodToInsert.rC_Connect__Merchant_Name__c = 'testMerchantName';
        insert paymentMethodToInsert;

        paymentMethod = [select Id, RecordTypeId, rC_Connect__Merchant_Name__c, Account_Number_E__c, rC_Connect__Payment_Processor__c,  Payment_Method_Number__c, rC_Giving__Payment_Type__c, rC_Giving__Is_Active__c , rC_Giving__Account__c, rC_Giving__Contact__c from rC_Giving__Payment_Method__c where id =: paymentMethodToInsert.Id  limit 1];
        
        WebTitlesRefCodes__c wtr = TestUtils.createWebTitlesRefCodes('test',true,false);
        wtr.Description__c='testDesc';
        insert wtr;
        
        CreditTypeRefCodes__c codes = new CreditTypeRefCodes__c();
        codes.Description__c = 'Visa';
        codes.Code__c = '45';
        codes.Name = 'test';
        codes.Active__c = true;
        insert codes;
    }
}