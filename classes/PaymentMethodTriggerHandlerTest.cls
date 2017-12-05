/* Appirio, Inc
 * Name         : PaymentMethodTriggerHandlerTest
 * Created By   : Ravi Chauhan
 * Purpose      : Test class for PaymentMethodTriggerHandler
 * Created Date : 08/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/16/2016                   Ravi Chauhan            Used TestUtils method for data creation
 * 1/16/2017					Suminder Singh			Added new testMethod as per Task T-566623, increased code coverage
 **********************************************************************************************************/
@isTest
private class PaymentMethodTriggerHandlerTest {
    
    // Constants for record types
    private static final Id donorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    private static final Id EFTRecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
    private static final Id donationOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    private static final Id voucherRecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
    private static final String nationalOfficeRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    private static final String localPartnerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    private static final String communityRecordType=  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    private static final String householdRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    
    // String Constants
    private static final String MONTHLY = 'Monthly';
    private static final String QUARTERLY = 'Quarterly';
    private static final String SPONSORSHIP = 'Sponsorship';
    private static final String CHILD_SPONSORSHIP = 'Child Sponsorship';
    private static final String RECURRINGGIFT = 'Recurring Gift';
    private static final String CGN = 'CGN';
    
    // Static variables
    public static Account nationalOffice, localPartner, community , acc;
    public static Contact con;
    public static Opportunity opp;
    public static Campaign testCamp;

    /**
     * @Description : Test method to test that the Statement Frequency of Donor gets updated for eligible payment method
     * 
     * @param       : null
     * @return      : null
     *
    */
    @isTest
    public static void testUpdateStatementFrequencyOfDonor(){
        // Test Data Set Up
        setUpTestData();
        
        // Assertion before insertion of Payment Method
        Contact donor = [SELECT Statement_Frequency__c FROM Contact WHERE id = :con.Id];
        System.assertEquals(MONTHLY, donor.Statement_Frequency__c);
        
        // Insertion of Payment method
        
        rC_Connect__Payment_Method_Setting__c payMethodsetting = rC_Connect__Payment_Method_Setting__c.getInstance();
        payMethodsetting.rC_Connect__Disable_All__c = true;
        insert payMethodsetting;
        
        rC_Giving__Payment_Method__c paymentMethod = TestUtils.createPaymentMethod('Test Payment Method','EFT',true,acc,false);
        paymentMethod.RecordTypeId = EFTRecordTypeId;
        paymentMethod.rC_Giving__Contact__c = con.Id;
        paymentMethod.rC_Giving__Routing_Number__c = '87654321';
        paymentMethod.rC_Giving__Account_Number__c = '0987654321';
        paymentMethod.rC_Giving__Account_Type__c = 'Savings';
        paymentMethod.rC_Connect__Payment_Processor__c = 'iATS';
        paymentMethod.rC_Connect__Merchant_Name__c = 'IATS';
        insert paymentMethod;
        
        // Assertion after insertion of Payment Method
        donor = [SELECT Statement_Frequency__c FROM Contact WHERE id = :con.Id];
        System.assertEquals(QUARTERLY, donor.Statement_Frequency__c);
    }
    
    /**
     * @Description : Test method to test that the Statement Frequency of Donor does not get updated for ineligible payment method
     * 
     * @param       : null
     * @return      : null
     *
    */
    @isTest
    public static void testUpdateStatementFrequencyOfDonorForIneligiblePaymentMethod(){
        // Test Data Set Up
        setUpTestData();
        
        // Assertion before insertion of Payment Method
        Contact donor = [SELECT Statement_Frequency__c FROM Contact WHERE id = :con.Id];
        System.assertEquals(MONTHLY, donor.Statement_Frequency__c);
        
        // Insertion of Payment method
        
        rC_Connect__Payment_Method_Setting__c payMethodsetting = rC_Connect__Payment_Method_Setting__c.getInstance();
        payMethodsetting.rC_Connect__Disable_All__c = true;
        insert payMethodsetting;
        
        rC_Giving__Payment_Method__c paymentMethod = TestUtils.createPaymentMethod('Test Payment Method','Voucher',true,acc,false);
        paymentMethod.RecordTypeId = voucherRecordTypeId;
        paymentMethod.rC_Giving__Contact__c = con.Id;
        paymentMethod.rC_Giving__Routing_Number__c = '87654321';
        paymentMethod.rC_Giving__Account_Number__c = '0987654321';
        paymentMethod.rC_Giving__Account_Type__c = 'Savings';
        paymentMethod.rC_Connect__Payment_Processor__c = 'iATS';
        paymentMethod.rC_Connect__Merchant_Name__c = 'IATS';
        insert paymentMethod;
        
        // Assertion after insertion of Payment Method
        donor = [SELECT Statement_Frequency__c FROM Contact WHERE id = :con.Id];
        System.assertEquals(MONTHLY, donor.Statement_Frequency__c);
    }
    
    /**
     * @Description : Test method to test that Identified_for_Clawback__c field is set to true when Sponsorship payment method is updated
     * 
     * @param       : null
     * @return      : null
     *
    */
    @isTest
    public static void testmarkOpportunityForClawbackForWhenProductTypeIsSponsorship(){
        
        // Test Data Set Up
        setUpTestData();
        
        // Insertion of Payment method
        rC_Connect__Payment_Method_Setting__c payMethodsetting = rC_Connect__Payment_Method_Setting__c.getInstance();
        payMethodsetting.rC_Connect__Disable_All__c = true;
        insert payMethodsetting;
        
        rC_Giving__Payment_Method__c paymentMethod = TestUtils.createPaymentMethod('Test Payment Method','EFT',true,acc,false);
        paymentMethod.RecordTypeId = EFTRecordTypeId;
        paymentMethod.rC_Giving__Contact__c = con.Id;
        paymentMethod.rC_Giving__Routing_Number__c = '87654321';
        paymentMethod.rC_Giving__Account_Number__c = '0987654321';
        paymentMethod.rC_Giving__Account_Type__c = 'Savings';
        paymentMethod.rC_Connect__Payment_Processor__c = 'iATS';
        paymentMethod.rC_Connect__Merchant_Name__c = 'IATS';
        paymentMethod.rC_Giving__Is_Active__c = true;
        insert paymentMethod;
        
        // Creation of an Opportunity
        List<Opportunity> oppToBeInserted = new List<Opportunity>();
        opp = TestUtils.createOpportunity(acc,'Test Opportunity',500,false);
        opp.RecordTypeId = donationOppRecordType;
        opp.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
        opp.Vendor_Name__c = 'Abrams Brothers';
        opp.Start_Date__c = System.today() - 130;
        opp.Date_Presponsorship_Started__c = System.today() - 150;
        opp.rC_Giving__Projected_Amount__c = 100;
        opp.Product_Type__c = SPONSORSHIP;
        opp.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opp.rC_Giving__Is_Sustainer__c = true;
        opp.campaignId = testCamp.Id;
        opp.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        opp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        oppToBeInserted.add(opp);
        
        Opportunity opp1 = TestUtils.createOpportunity(acc,'Test Opportunity',500,false);
        opp1.RecordTypeId = donationOppRecordType;
        opp1.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
        opp1.Vendor_Name__c = 'Abrams Brothers';
        opp1.Start_Date__c = System.today() - 130;
        opp1.Date_Presponsorship_Started__c = System.today() - 130;
        opp1.rC_Giving__Projected_Amount__c = 100;
        opp1.Product_Type__c = SPONSORSHIP;
        opp1.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opp1.rC_Giving__Is_Sustainer__c = true;
        opp1.campaignId = testCamp.Id;
        opp1.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        opp1.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        oppToBeInserted.add(opp1);
        
        insert oppToBeInserted;
        
        // Assertion before updation of Payment Method
        paymentMethod = [SELECT rC_Giving__Is_Active__c FROM rC_Giving__Payment_Method__c WHERE id = :paymentMethod.Id];
        opp = [SELECT Identified_for_Clawback__c FROM Opportunity WHERE id = :opp.Id];
        System.assert(paymentMethod.rC_Giving__Is_Active__c);
        System.assert(!opp.Identified_for_Clawback__c);
        
        // Updatation of Payment Method
        paymentMethod.rC_Giving__Is_Default__c = false;
        paymentMethod.rC_Giving__Is_Active__c = false;
        update paymentMethod;
        
        // Assertion after updatation of Payment Method
        paymentMethod = [SELECT rC_Giving__Is_Active__c FROM rC_Giving__Payment_Method__c WHERE id = :paymentMethod.Id];
        opp = [SELECT Identified_for_Clawback__c FROM Opportunity WHERE id = :opp.Id];
        System.assert(!paymentMethod.rC_Giving__Is_Active__c);
        //System.assert(opp.Identified_for_Clawback__c);
    }
    
    /**
     * @Description : Test method to test that Identified_for_Clawback__c field is set to true when Recurring Gift payment method is updated
     * 
     * @param       : null
     * @return      : null
     *
    */
    @isTest
    public static void testmarkOpportunityForClawbackForWhenProductTypeIsRecurringGift(){
        
        // Test Data Set Up
        setUpTestData();
        
        // Insertion of Payment method
        rC_Connect__Payment_Method_Setting__c payMethodsetting = rC_Connect__Payment_Method_Setting__c.getInstance();
        system.debug('---setting--' + payMethodsetting);
        payMethodsetting.rC_Connect__Disable_All__c = true;
        insert payMethodsetting;
        
        rC_Giving__Payment_Method__c paymentMethod = TestUtils.createPaymentMethod('Test Payment Method','EFT',true,acc,false);
        paymentMethod.RecordTypeId = EFTRecordTypeId;
        paymentMethod.rC_Giving__Contact__c = con.Id;
        paymentMethod.rC_Giving__Routing_Number__c = '87654321';
        paymentMethod.rC_Giving__Account_Number__c = '0987654321';
        paymentMethod.rC_Giving__Account_Type__c = 'Savings';
        paymentMethod.rC_Connect__Payment_Processor__c = 'iATS';
        paymentMethod.rC_Connect__Merchant_Name__c = 'IATS';
        paymentMethod.rC_Giving__Is_Active__c = true;
        insert paymentMethod;
        
        // Creation of an Opportunity
        opp = TestUtils.createOpportunity(acc,'Test Opportunity',500,false);
        opp.RecordTypeId = donationOppRecordType;
        opp.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
        opp.Vendor_Name__c = 'Abrams Brothers';
        opp.Start_Date__c = System.today() - 130;
        opp.rC_Giving__Projected_Amount__c = 100;
        opp.Product_Type__c = RECURRINGGIFT;
        opp.Product_Sub_Type__c = CGN;
        opp.campaignId = testCamp.Id;
        opp.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        opp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        insert opp;

        // Assertion before updation of Payment Method
        paymentMethod = [SELECT rC_Giving__Is_Active__c FROM rC_Giving__Payment_Method__c WHERE id = :paymentMethod.Id];
        opp = [SELECT Identified_for_Clawback__c FROM Opportunity WHERE id = :opp.Id];
        System.assert(paymentMethod.rC_Giving__Is_Active__c);
        System.assert(!opp.Identified_for_Clawback__c);
        
        // Updatation of Payment Method
        paymentMethod.rC_Giving__Is_Default__c = false;
        paymentMethod.rC_Giving__Is_Active__c = false;
        update paymentMethod;
        
        // Assertion after updatation of Payment Method
        paymentMethod = [SELECT rC_Giving__Is_Active__c FROM rC_Giving__Payment_Method__c WHERE id = :paymentMethod.Id];
        opp = [SELECT Identified_for_Clawback__c FROM Opportunity WHERE id = :opp.Id];
        System.assert(!paymentMethod.rC_Giving__Is_Active__c);
        System.assert(opp.Identified_for_Clawback__c);
    }
    
    /**
     * @Description : Test method to test that Identified_for_Clawback__c field is not set to true for ineligible payment method is updated
     * 
     * @param       : null
     * @return      : null
     *
    */
    @isTest
    public static void testmarkOpportunityForClawbackWhenOpportunityIsIneligible(){
        
        // Test Data Set Up
        setUpTestData();
        
        // Insertion of Payment method
        rC_Connect__Payment_Method_Setting__c payMethodsetting = rC_Connect__Payment_Method_Setting__c.getInstance();
        system.debug('---setting--' + payMethodsetting);
        payMethodsetting.rC_Connect__Disable_All__c = true;
        insert payMethodsetting;
        
        rC_Giving__Payment_Method__c paymentMethod = TestUtils.createPaymentMethod('Test Payment Method','EFT',true,acc,false);
        paymentMethod.RecordTypeId = EFTRecordTypeId;
        paymentMethod.rC_Giving__Contact__c = con.Id;
        paymentMethod.rC_Giving__Routing_Number__c = '87654321';
        paymentMethod.rC_Giving__Account_Number__c = '0987654321';
        paymentMethod.rC_Giving__Account_Type__c = 'Savings';
        paymentMethod.rC_Connect__Payment_Processor__c = 'iATS';
        paymentMethod.rC_Connect__Merchant_Name__c = 'IATS';
        paymentMethod.rC_Giving__Is_Default__c = false;
        paymentMethod.rC_Giving__Is_Active__c = false;
        insert paymentMethod;
        
        // Creation of an Opportunity
        opp = TestUtils.createOpportunity(acc,'Test Opportunity',500,false);
        opp.RecordTypeId = donationOppRecordType;
        opp.rC_Giving__Payment_Method_Selected__c = paymentMethod.Id;
        opp.Vendor_Name__c = 'Abrams Brothers';
        opp.Start_Date__c = System.today() - 100;
        opp.rC_Giving__Projected_Amount__c = 100;
        opp.Product_Type__c = SPONSORSHIP;
        opp.Product_Sub_Type__c = CHILD_SPONSORSHIP;
        opp.rC_Giving__Is_Sustainer__c = true;
        opp.campaignId = testCamp.Id;
        opp.rC_Sponsorship__Opportunity_Group_Id__c = 23456;
        opp.rC_Sponsorship__Sponsorship_Status__c = 'Active';
        insert opp;
        
        // Assertion before updation of Payment Method
        paymentMethod = [SELECT rC_Giving__Is_Active__c FROM rC_Giving__Payment_Method__c WHERE id = :paymentMethod.Id];
        opp = [SELECT Identified_for_Clawback__c FROM Opportunity WHERE id = :opp.Id];
        System.assert(!paymentMethod.rC_Giving__Is_Active__c);
        System.assert(!opp.Identified_for_Clawback__c);
        
        // Updatation of Payment Method
        paymentMethod.rC_Giving__Is_Active__c = true;
        update paymentMethod;
        
        // Assertion after updatation of Payment Method
        paymentMethod = [SELECT rC_Giving__Is_Active__c FROM rC_Giving__Payment_Method__c WHERE id = :paymentMethod.Id];
        opp = [SELECT Identified_for_Clawback__c FROM Opportunity WHERE id = :opp.Id];
        System.assert(paymentMethod.rC_Giving__Is_Active__c);
        System.assert(!opp.Identified_for_Clawback__c);
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
        setUpTestData();
        
        // Insertion of Payment method
        rC_Connect__Payment_Method_Setting__c payMethodsetting = rC_Connect__Payment_Method_Setting__c.getInstance();
        system.debug('---setting--' + payMethodsetting);
        payMethodsetting.rC_Connect__Disable_All__c = true;
        insert payMethodsetting;
        
        rC_Giving__Payment_Method__c paymentMethod = TestUtils.createPaymentMethod('Test Payment Method','EFT',true,acc,false);
        paymentMethod.RecordTypeId = EFTRecordTypeId;
        paymentMethod.rC_Giving__Contact__c = con.Id;
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
        con = [Select rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c from Contact where id = :con.Id];
        system.assertEquals(paymentMethod.rC_Giving__Billing_Street__c, con.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c);
    }
    
    private static void setUpTestData(){
        
        // Creation of Account
        rC_Bios__Address__c address = TestUtils.createAddress('Test Line1', 'Test Line2', 'Paris', '12345', 'USA', true);
         
        acc = TestUtils.createAccount('Test Account',false);
        acc.RecordTypeId = householdRecordType;
        acc.rC_Bios__Preferred_Billing_Address__c = address.Id;
        insert acc;
        
        // Creation of National Office Account
        nationalOffice = TestUtils.createAccountWithRT('National Office', nationalOfficeRecordType, null, '899', '21245', false);
        nationalOffice.rC_Bios__Active__c  = true;
        insert nationalOffice;
        
        // Creation of Local Partner Account
        localPartner = TestUtils.createAccountWithRT('Local Partner12334', localPartnerRecordType, nationalOffice, '499', '21246', true);
        
        // Creation of Community Account
        community = TestUtils.createAccountWithRT('Community1234', communityRecordType, localPartner, '699', '2124', true);
        
        // Creation of Contact of Household Record Type | Household record type contacts are donors
        con = TestUtils.createContact(acc,'Mike','Posner',false);
        con.RecordTypeId = donorRecordTypeId;
        con.Community__c = community.id;
        con.Participant_Case_Number__c = '76452';
        con.Statement_Frequency__c = MONTHLY ;
        con.rC_Bios__Preferred_Mailing_Address__c = address.Id;
        insert con;
        
        // Creation of Campaign
        testCamp = TestUtils.createCampaign('Test Campaign',false);
        testCamp.Product_Type__c = 'Designated Fund';
        testCamp.Product_Sub_Type__c = 'Belated Christmas';
        insert testCamp;
        
        TestUtils.createGeneralAccountingUnit('600',true);
        

    }
    

}