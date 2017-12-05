/**
*    @ClassName    : TFT_CheckoutSummaryControllerTest
*    @CreatedOn    : 24/Oct/2016
*    @CreatedBy    : Tekbin
*    @Description  : Test class for TFT_CheckoutSummaryController.
*
* Appirio (c) - 2017
*
* Modified By         Modified Date       Reason
* Alexander Miller      3.15.2017        00190749
* Jessica Schilling     6.16.2017        00197780       Updated test data
* Dimpesh K Gehlot		7.17.2017		T-617693  commented code to modify obj model
* Dimpesh K Gehlot		7.18.2017		T-617694  uncommented code and changed Cart__c to Cart_Item__c
*/
@isTest
private class TFT_CheckoutSummaryControllerTest 
{
    // DG T-617693
    // DG T-617694 uncommented code
	private static testMethod void test() 
	{
        //Create cardID
        String cardId = '';
        //Create account
        Account portalAccount1 = new Account(
            Name = 'TestAccount', 
            RecordTypeId = UtilityTest.idAccountProgramLocationListingRecordType
        );
        Database.insert(portalAccount1);
        
        //Create contact
        Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            // START AMILLER 00190749 3.15.2017
            // Email = System.now().millisecond() + 'test@test.com'
            Email = System.now().millisecond() + 'test@test.com',
            ChapterID__c = '',
            Override__c = true
            // END AMILLER 00190749 3.15.2017
        );
        Database.insert(contact1);
        test.startTest();

            Listing__c objListing1 = new Listing__c(Name = 'Test Listing', Account__c = portalAccount1.Id, RecordTypeId = UtilityTest.idListingRecordType);
            insert objListing1; 
            
            //START JSCHILLING 00197780 6/16/2017
            //Updated test data
            Listing_Session__c objLS1 = new Listing_Session__c(Name = 'Test LS - 01', Max_Capacity__c = 1, Listing__c = objListing1.Id, 
                                                                Event_Coordinator__c = contact1.Id);
            insert objLS1;

            Waivers__c waiver = new Waivers__c(Name = 'Test Waiver', Waiver_Active__c = true);
            insert waiver;

            Selected_Waivers__c selectedWaiver = new Selected_Waivers__c(Listing_Session__c = objLS1.Id, Waivers__c = waiver.Id);
            insert selectedWaiver;

            objLS1.Register_Start_Date_Time__c = DateTime.now().addDays(-1);
            objLS1.Register_End_Date_Time__c = DateTime.now().addDays(1);
            update objLS1;
            //END JSCHILLING 00197780 6/16/2017
        
            Session_Registration__c objSR1 = new Session_Registration__c(Listing_Session__c = objLS1.Id, Contact__c = contact1.Id, Status__c = 'In Process');
            insert objSR1;
        	// DG T-617694 Changed Cart__c to Cart_Item__c
            Cart_Item__c objCart1 = new Cart_Item__c(Session_Registration__c = objSR1.Id, Status__c = 'In Process',Discount__c = 23,Apply_Membership_Amount__c = true);//OwnerId = user1.Id);
            insert objCart1;
            // DG T-617694 Changed Cart__c to Cart_Item__c
            Cart_Item__c objCart2 = new Cart_Item__c(Session_Registration__c = objSR1.Id, Status__c = 'In Process',Apply_Membership_Amount__c = true);//OwnerId = user1.Id);
            insert objCart2;
            // DG T-617694 Changed Cart__c to Cart_Item__c
            List<Cart_Item__c> cartList = new List<Cart_Item__c>();
            cartList.add(objCart1);
            upsert cartList;
            
         //Membership_Registration__c record
         Membership_Registration__c membershipReg = new Membership_Registration__c();
         membershipReg.Account__c = portalAccount1.Id;
         membershipReg.Contact__c = contact1.id;
         membershipReg.Start_Date__c = date.newInstance(2017, 1, 20);
         membershipReg.End_Date__c = date.newInstance(2017,7,20);
         membershipReg.Override__c = false;
         membershipReg.Membership_Dues_Paid__c = true;
         //insert membershipReg;
         List<Membership_Registration__c> membershipRegList = new List<Membership_Registration__c>();
         membershipRegList.add(membershipReg);
         insert membershipRegList;
         Session_Registration__c objSR2 = new Session_Registration__c(Listing_Session__c = objLS1.Id,Membership_Registration__c =membershipReg.id, Contact__c = contact1.Id, Status__c = 'On Waitlist');
            
         insert objSR2 ;
            
            CustomMessages__c setting = new CustomMessages__c();
                   
                   setting.Website_Parameter_Check_Message__c = 'parameter not found';
                   insert setting;

            TFT_CheckoutSummaryController controller = new TFT_CheckoutSummaryController();
            controller.cardId = '';
           
            controller.listingSessionIdToDelete = objLS1.Id;
            controller.removeSessionRegistration();
        test.stopTest();
	}
	//variable
    public static Account objAcc = new Account();
    
    //Prepare the Test data for the Test class
    public static Payment_Information__c TestDataFactory() {
        
        //Create Account
        Account acc = new Account(name='AccTest', Website = 'test.com');
        Insert acc;
        objAcc = acc;
        
        //Create Contact
        // START AMILLER 00190837 3.15.2017
        //Contact con = new Contact(firstname='Test',lastname='Test',AccountId=acc.Id);
        Contact con = new Contact(firstname='Test',lastname='Test',AccountId=acc.Id, ChapterID__c = '', Override__c = true);
        // END AMILLER 00190837 3.15.2017
        //Insert con;
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        insert conList;
         //system.assert(true,membershipReg.Active_Status__c);
        //Create Payment Information
        Payment_Information__c objPaymentInfo = new Payment_Information__c(Card_Number__c='4242', 
                                                                           Customer_Contact__c=con.Id, 
                                                                           Expiration_Month__c=12,
                                                                           Expiration_Year__c=201, 
                                                                           Token__c='cus_00000000000000', 
                                                                           Chapter__c=acc.Id, 
                                                                           Bank_Account_Number__c=001254412
                                                                           );
                                                                           
         Payment_Information__c objPaymentInfo2 = new Payment_Information__c(Card_Number__c='4242', 
                                                                           Customer_Contact__c=con.Id, 
                                                                           Expiration_Month__c=12,
                                                                           Expiration_Year__c=201, 
                                                                           Token__c='cus_00000000000000', 
                                                                           Bank_Account_Number__c=001254412
                                                                           );                                                                  
        Insert objPaymentInfo;
        //Create List of Payment Information
        List<Payment_Information__c> objPaymentInfoList = new List<Payment_Information__c>();
        objPaymentInfoList.add(objPaymentInfo2);
        insert objPaymentInfoList;
        return objPaymentInfo;
    }
    
    
    //Test Method
    private static testMethod void test_TFT_ProRegistrationPaymentController() {
        
        //Create Test Data
        Payment_Information__c objPaymentInformation = TestDataFactory();
        
        Test.startTest();
        
        //Set page parametere
        PageReference pgRef = Page.TFT_ProgramRegistrationPayment;
        Test.setCurrentPage(pgRef); 
        ApexPages.currentPage().getParameters().put('website', 'test.com');//Pass Id to page 
        
        //Create Object of class
        TFT_CheckoutSummaryController controller = new TFT_CheckoutSummaryController();
        
        //Set variables and call respective methods of the class.
        controller.cardNumber = '4242';
        controller.selectedExpiryMonth = '12';
        controller.selectedExpiryYear = '2014';
        controller.checkoutTotal = 10.00;
        controller.cardName = 'testTee';
        controller.cardCVV = '123';
        controller.SelectedPaymentMethod = 'credit-payment';
        controller.ShowSelectCard();
        
        controller.SelectedPaymentMethod = 'Test';
        controller.ShowSelectCard();
        
        controller.selectedPaymentInfo = 'Add New';
        controller.ShowCreditCardSection();
        controller.CreateCustomer();
        controller.fetchPaymentInformationsForChapter();
        
        controller.selectedPaymentInfo = objPaymentInformation.Id;
        controller.ShowCreditCardSection();
        controller.CreateCustomer();
        
        controller.selectedPaymentInfo = 'Add New';
        controller.SelectedPaymentMethod = 'credit-payment';
        
        controller.selectedExpiryYear = '2032';
        controller.selectedExpiryMonth = '02';
        controller.tokenString = 'testToken';
        controller.finAidApplied = false;
        controller.CreateCustomer();
        controller.rerenderSummaryComponent();
         
        controller.SelectedPaymentMethod = 'credit-payment';
        controller.selectedPaymentInfo = objPaymentInformation.Id;
        controller.CreateCustomer();
        controller.SubmitRegistration('objPaymentInfo');
        
        controller.SelectedPaymentMethod = 'Check Cash Payment';
        controller.ShowSelectCard();
        controller.CreateCustomer();
        controller.updateCheckoutTotal();
        
         
        controller.listingSessionIdToDelete = '1';
        controller.sessionregistrationForCartTodelete = '2';
        controller.removeSessionRegistration();
        controller.CreateCustomerZeroBalance();
        PageReference pg = controller.redirectBack();
        Test.stopTest();
    }
	
}