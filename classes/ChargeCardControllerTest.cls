/***********************************************************************************************************
* Appirio, Inc
* Name         : ChargeCardControllerTest 
* Created By   : Ashu Gupta (Appirio)
* Purpose      : Test class of ChargeCardController class
* Created Date : July 08, 2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* July 29, 2016                Ashu Gupta              Increased code coverage
* Aug 09, 2016                 Ashu Gupta              Added asserts as per the new implemented changes to the main class
* Nov 29, 2016                 Ravi Chauhan            Fixed failures and incresed coverage
**********************************************************************************************************/
@isTest(seeAllData = true)
private class ChargeCardControllerTest {
    static rC_Giving__Payment_Method__c testPaymentMethod,testPaymentMethodNew,testPayMethod;
    static Contact con1;
    static Id paymentMethodRtId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Charge Card').getRecordTypeId();
    static Id paymentMethodEFTRtId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
    static Id paymentMethodPaypalRtId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Paypal').getRecordTypeId();
    Final Static Id ACC_BANK_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bank').getRecordTypeId();
    Final Static Id ACC_HOUSE_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    
    
    static Account acc;
    private static ValidatedAddress newAddress;
    
    private static testMethod void testChargeCardRT() {
        createTestdata();
        
        PageReference pageRef = Page.EditChargeCard;        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('RecordType' ,paymentMethodRtId );
        Test.startTest();
        
        ChargeCardController cont = new ChargeCardController(new ApexPages.StandardController(new rC_Giving__Payment_Method__c()));
        //to check that it's a new Payment Method
        System.assertEquals(cont.isNew,true);
        //to check pageTitle as New Charge card Payment method
        System.assertEquals(cont.pageTitle,'New Charge Card Payment Method');
        cont.lookupBankName();
        ApexPages.StandardController sc = new ApexPages.StandardController(testPaymentMethod);
        cont = new ChargeCardController(sc);
        //to check the record type of payment method
        System.assertEquals(cont.isChargeRecordType, true);
        //to check that it's an existing payment method being edited
        System.assertEquals(cont.isNew,false);
        //to check pageTitle as Edit Charge Card Payment method
        System.assertEquals(cont.pageTitle,'Edit Charge Card Payment Method');
        //to check accountInfoTitle when record type is Charge card
        System.assertEquals(cont.accountInfoTitle,'Charge Card Information');
        
        cont.address = newAddress;
        PageReference prSave = cont.save();
        //to check the returned url when clicked on Save
        System.assertEquals(prSave.getURL(), new PageReference('/'+testPaymentMethod.id).getURL());
        cont.lookupBankName();
        System.debug('@@@ bank name'+testPaymentMethod.rC_Giving__Bank_Name__c);
        PageReference prCancel = cont.cancel(); 
        //to check the returned Url when clicked on cancel.
        System.assertEquals(prCancel.getURL(),new PageReference('/'+testPaymentMethod.id).getURL());
        
        Test.stopTest();
    }
    
    private static testMethod void testEFTPaymentMethod() {
        createTestdata();
        
        PageReference pageRef = Page.EditChargeCard;        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('RecordType' ,paymentMethodEFTRtId );
        test.startTest();
        
        ChargeCardController cont = new ChargeCardController(new ApexPages.StandardController(new rC_Giving__Payment_Method__c()));
        //to check that it's a new Payment Method
        System.assertEquals(cont.isNew,true);
        //to check pageTitle as New EFT Payment Method
        System.assertEquals(cont.pageTitle,'New EFT Payment Method');
        ApexPages.StandardController sc = new ApexPages.StandardController(testPaymentMethodNew);
        cont = new ChargeCardController(sc);
        //to check the record type of payment method
        System.assertEquals(cont.isChargeRecordType, false);
        //recordType of Payment Method is EFT or not 
        System.assertEquals(cont.isEFTRecordType, true);
        //to check that it's an existing payment method being edited
        System.assertEquals(cont.isNew,false);
        //to check pageTitle as Edit EFT Payment Method
        System.assertEquals(cont.pageTitle,'Edit EFT Payment Method');
        //to check accountInfoTitle when record type is not Charge card
        System.assertEquals(cont.accountInfoTitle,'Bank Account Information');
        
        cont.address = newAddress;
        PageReference prSave = cont.save();
        //to check the returned url when clicked on Save
        System.assertEquals(prSave.getURL(),new PageReference('/'+testPaymentMethodNew.id).getURL());
        cont.lookupBankName();
        System.debug('@@@ bank name'+testPaymentMethod.rC_Giving__Bank_Name__c);
        PageReference prCancel = cont.cancel();  
        //to check the returned Url when clicked on cancel.
        System.assertEquals(prCancel.getURL(),new PageReference('/'+testPaymentMethodNew.id).getURL());
        
        Test.stopTest();
    }
    
    private static testMethod void testPaypalMethod() {
        createTestdata();
        
        PageReference pageRef = Page.EditChargeCard;        
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType' ,paymentMethodPaypalRtId );
        ApexPages.StandardController sc = new ApexPages.StandardController(testPayMethod);
        ChargeCardController cont = new ChargeCardController(sc);
        Test.startTest();
        //RecordType of the Payment method is ChargeCard or not 
        System.assertEquals(cont.isChargeRecordType, false);
        //RecordType of the Payment method is EFT or not 
        System.assertEquals(cont.isEFTRecordType, false);
        //returned URL is not null.
        System.assertNotEquals(cont.URL,null);
        Test.stopTest();
    }
    
    private static testMethod void testRedirectMethod() {
        createTestdata();
        
        PageReference pageRef = Page.EditChargeCard;        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('RecordType' ,paymentMethodPaypalRtId );
        Test.startTest();
        
        ChargeCardController cont = new ChargeCardController(new ApexPages.StandardController(new rC_Giving__Payment_Method__c()));
        cont.redirect();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testPayMethod);
        ApexPages.currentPage().getParameters().put('id' ,testPayMethod.Id );
        cont = new ChargeCardController(sc);
        cont.redirect();
    }
    
    private static testMethod void PopulateAccountContactInfotest(){
        //pageReference pg=;
        createTestdata();
        rC_Giving__Payment_Method__c gpm=[SELECT rC_Giving__Contact__c,rC_Giving__Account__c
                                          FROM rC_Giving__Payment_Method__c
                                          Limit 1  
                                         ];
        Account accnt=[SELECT ID FROM ACCOUNT LIMIT 1]; 
        Contact cntct= TestUtils.createContact(accnt, 'test', 'Acnt', true);
        rC_Bios__Address__c addr=TestUtils.createAddress('Street Line One', 'Street Line Two', 'Gilbert', '223344', 'USA' , false) ;
        addr.Validated__c=true;
        insert addr;
        
        cntct.rC_Bios__Preferred_Mailing_Address__c=addr.ID;
        cntct.Phone='7345551212';
        update cntct;
        
        gpm.rC_Giving__Account__c=accnt.ID;
        gpm.rC_Giving__Contact__c=cntct.ID;
        update gpm;
        
        test.startTest();
        ApexPages.StandardController controller=new ApexPages.StandardController(gpm);
        ChargeCardController chrgcrd = new ChargeCardController(new ApexPages.StandardController(gpm));
        pageReference pg=chrgcrd.PopulateAccountContactInfo();
        rC_Bios__Address__c rcbc=   [Select rC_Bios__Country__c,rC_Bios__Postal_Code__c from rC_Bios__Address__c where id=:cntct.rC_Bios__Preferred_Mailing_Address__c];
        //Validating country and postal code for T-566624
        System.assertEquals(chrgcrd.address.Country, rcbc.rC_Bios__Country__c); 
        System.assertEquals(chrgcrd.address.PostalCode, rcbc.rC_Bios__Postal_Code__c);
        //Validating phone number for T-566624
        System.assertEquals(cntct.Phone,chrgcrd.PaymentMethod.rC_Connect__Billing_Phone__c);        
        accnt.rC_Bios__Preferred_Billing_Address__c=addr.ID;
        gpm.rC_Giving__Account__c=accnt.ID;
        gpm.rC_Giving__Contact__c=null;
        update gpm;   
        
        ApexPages.StandardController controller1=new ApexPages.StandardController(gpm);
        ChargeCardController chrgcrd1 = new ChargeCardController(new ApexPages.StandardController(gpm));
        pageReference pg1=chrgcrd1.PopulateAccountContactInfo();
        //Validating country and postal code for T-566624
        System.assertEquals(chrgcrd1.address.Country,accnt.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Country__c);
        System.assertEquals(chrgcrd1.address.PostalCode,accnt.rC_Bios__Preferred_Billing_Address__r.rC_Bios__Postal_Code__c);
        
        test.stopTest();
    }
    
     /**
     * @Description : Test method to test that address info is populated if not already populated
     * Added new testMethod as per Task T-566623 - Suminder Singh
     * @param       : null
     * @return      : null
     *
    */
    @isTest
    public static void testDefaultAccountAndAddressInfoMethod(){
        // Test Data Set Up
        acc = TestUtils.createAccount('test',true);
        Account BankAcc = TestUtils.createAccountWithRT('Test Bank Account', ACC_BANK_RT, null, null, null, false);
        insert BankAcc;
        Account houseAcc = TestUtils.createAccountWithRT('Test house Account', ACC_HOUSE_RT, null, null, null, false);
        insert houseAcc;
        Routing_Number__c routingNumber = TestUtils.createRoutingNumber('012345768',BankAcc,True);
        
        Contact cntct= TestUtils.createContact(houseAcc, 'test', 'Acnt', true);
        rC_Bios__Address__c addr=TestUtils.createAddress('Street Line One', 'Street Line Two', 'Gilbert', '223344', 'USA' , false) ;
        addr.Validated__c=true;
        insert addr;
        
        cntct.rC_Bios__Preferred_Mailing_Address__c=addr.ID;
        cntct.Phone='7345551212';
        update cntct;
        // Insertion of Payment method
        rC_Connect__Payment_Method_Setting__c payMethodsetting = rC_Connect__Payment_Method_Setting__c.getInstance();
        system.debug('---setting--' + payMethodsetting);
        payMethodsetting.rC_Connect__Disable_All__c = true;
        insert payMethodsetting;
        
        rC_Giving__Payment_Method__c paymentMethod = TestUtils.createPaymentMethod('Test Payment Method','EFT',true,acc,false);
        paymentMethod.RecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Charge Card').getRecordTypeId();
        paymentMethod.rC_Giving__Contact__c = cntct.Id;
        paymentMethod.rC_Giving__Routing_Number__c = '87654321';
        paymentMethod.rC_Giving__Account_Number__c = '0987654321';
        paymentMethod.rC_Giving__Account_Type__c = 'Savings';
        paymentMethod.rC_Connect__Payment_Processor__c = 'iATS';
        paymentMethod.rC_Connect__Merchant_Name__c = 'IATS';
        paymentMethod.rC_Giving__Is_Default__c = false;
        paymentMethod.rC_Giving__Is_Active__c = false;
        insert paymentMethod;
        // Assertion after insertion of Payment Method
        paymentMethod = [SELECT rC_Giving__Billing_Street__c FROM rC_Giving__Payment_Method__c WHERE id = :paymentMethod.Id];
        cntct = [Select rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c from Contact where id = :cntct.Id];
        system.assertEquals(paymentMethod.rC_Giving__Billing_Street__c, cntct.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c);
    }
    
    static void createTestdata(){
        acc = TestUtils.createAccount('test',true);
        Account BankAcc = TestUtils.createAccountWithRT('Test Bank Account', ACC_BANK_RT, null, null, null, false);
        insert BankAcc;
        Account houseAcc = TestUtils.createAccountWithRT('Test house Account', ACC_HOUSE_RT, null, null, null, false);
        insert houseAcc;
        Routing_Number__c routingNumber = TestUtils.createRoutingNumber('012345768',BankAcc,True);
        
        List<rC_Giving__Payment_Method__c> listOfPaymentMethod = new List<rC_Giving__Payment_Method__c>();
        
        testPaymentMethod = TestUtils.createPaymentMethod('Test Payment','Paypal',true,acc,false);
        testPaymentMethod.RecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Charge Card').getRecordTypeId();
        testPaymentMethod.rC_Giving__Billing_State__c = 'test';
        testPaymentMethod.rC_Giving__Routing_Number__c = String.valueOf(routingNumber);
        testPaymentMethod.rC_Giving__Account__c=BankAcc.ID;
        listOfPaymentMethod.add(testPaymentMethod);
        
        testPaymentMethodNew = TestUtils.createPaymentMethod('Test Payment new','Paypal',true,acc,false);
        testPaymentMethodNew.RecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
        testPaymentMethodNew.rC_Giving__Routing_Number__c = '234';
        listOfPaymentMethod.add(testPaymentMethodNew); 
        
        testPayMethod = TestUtils.createPaymentMethod('Test Pay Method','Paypal',true,acc,false);
        testPayMethod.RecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Paypal').getRecordTypeId();
        listOfPaymentMethod.add(testPayMethod);
        
        insert listOfPaymentMethod;
                   
        newAddress = new ValidatedAddress();
        newAddress.Line1 = 'Street Line One';
        newAddress.Line2 = 'Street Line Two';
        newAddress.city = 'Gilbert';
        newAddress.stateProv = 'Arizona';
        newAddress.country = 'USA';
        newAddress.postalCode = '223344';
        newAddress.IsValid = True;
        newAddress.IsOverridden = False;
    }
}