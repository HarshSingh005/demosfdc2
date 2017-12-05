/**
*    @ClassName    : CartTriggerHandlerTest 
*    @CreatedOn    : 6/OCT/2016
*    @ModifiedBy   : Trekbin
*    @Description  : This is an test class of CartTriggerHandler.
*
*  Modified By         Modified Date          Reason
*  Alexander Miller     4.27.2017            00194215
*  Dimpesh K Gehlot		7.17.2017 			 T-617693
*  Dimpesh K Gehlot		7.18.2017			 T-617694 uncommented codes to bring back functionality and changed Cart__c to Cart_Item__c
*/
@isTest
private class CartTriggerHandlerTest 
{
    /**
    * START AMILLER 4.27.2017 00194215
    *
    *  Introducing test setup to help prevent SOQL limits
    */
    // DG T-617693 7/17/2017
    // DG T-617694 7/18/2017 uncommented code again with new API Name
    @testSetup 
    static void setup() 
    {
        List<RecordType> lstRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Chapter' limit 1];

        Account objAccount1 = insertAccount('Test Account - 01', 100, 200, 300, lstRecordType[0].Id);
        Account objAccount2 = insertAccount('Test Account - 02', 800, 400, 200, lstRecordType[0].Id);
        Account objAccount3 = insertAccount('Test Account - 02', 200, 800, 400, lstRecordType[0].Id);
        Account objAccount4 = insertAccount('Test Account - 02', 400, 200, 800, lstRecordType[0].Id);
        
        Contact objContact1 = insertContact('Test', 'Contact - 01', objAccount1.Id, '');
        Contact objContact2 = insertContact('Test', 'Contact - 02', objAccount2.Id, 'Civilian');
        Contact objContact3 = insertContact('Test', 'Contact - 03', objAccount2.Id, '');
        
        Listing__c objListing = insertListing('Test Listing - 01', true, true, true, objAccount1.Id);
        Listing_Session__c objLS1 = insertListSession('Test LS - 01', objListing.Id, objAccount2.Id, DateTime.Now(), DateTime.Now().addDays(4));
        Listing_Session__c objLS2 = insertListSession('Test LS - 02', objListing.Id, objAccount3.Id, DateTime.Now(), DateTime.Now().addDays(4));
        Listing_Session__c objLS3 = insertListSession('Test LS - 03', objListing.Id, objAccount4.Id, DateTime.Now(), DateTime.Now().addDays(4));
        
        Session_Registration__c objSesReg1 = insertSesRegistration(objContact1.Id, objLS1.Id);
        Session_Registration__c objSesReg2 = insertSesRegistration(objContact2.Id, objLS1.Id);
        Session_Registration__c objSesReg3 = insertSesRegistration(objContact2.Id, objLS2.Id);
        Session_Registration__c objSesReg4 = insertSesRegistration(objContact2.Id, objLS3.Id);
        
        Engagement_Type__c objEngType1 = insertEngType(objContact2.Id, 'Participant');
        Engagement_Type__c objEngType2 = insertEngType(objContact3.Id, 'Participant');
        
        Id communityUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Community User'].Id;  
        
        Membership_Registration__c objMemReg = insertMemRegistration(objAccount2.Id, objContact2.Id, true);
        // DG T-617694 Changed Cart__c to Cart_Item__c
        Cart_Item__c objCart = insertCart(objSesReg1.Id);
    }
    // END AMILLER 4.27.2017 00194215

    //Method to insert and return Account record.
    private static Account insertAccount(String strName, Decimal dbSibDisAmt, Decimal dbMilDisAmt, Decimal dbMemDisAmt, Id recTypeId)
    {
       Account objAccount = new Account(Name = strName,
                                        RecordTypeId = recTypeId,
                                        Sibling_Discount_Amount__c = dbSibDisAmt,
                                        Military_Discount_Amount__c = dbMilDisAmt,
                                        Membership_Discount_Amount__c = dbMemDisAmt);
        insert objAccount; 
        return objAccount;
    }
    
    //Method to insert and return Contact record.
    private static Contact insertContact(String strFName, String strLName, Id accountId, String strMiltAff)
    {
       Contact objContact = new Contact(FirstName = strFName, 
                                        LastName = strLName, 
                                        AccountId = accountId,
                                        Military__c =true,
                                        Military_Affiliation__c = strMiltAff);
        insert objContact; 
        return objContact;
    }
    
    //Method to insert and return Listing record.
    private static Listing__c insertListing(String strName, Boolean isSibDisActive, Boolean isMilDisActive, Boolean isMemDisActive, Id presentById)
    {
       Listing__c objListing = new Listing__c(Name = strName,
                                              Presented_By__c = presentById,
                                              Sibling_Discount_Active__c = isSibDisActive,
                                              Military_Discount_Active__c = isMilDisActive,
                                              Membership_Discount_Active__c = isMemDisActive);
        insert objListing; 
        return objListing;
    }
    
    //Method to insert and return Listing record.
    private static Listing_Session__c insertListSession(String strName, Id listingId, Id presentById, DateTime dtSessionStart, DateTime dtSessionEnd)
    {
       Listing_Session__c objListSession = new Listing_Session__c(Name = strName,
                                                                  Listing__c = listingId,
                                                                  Presented_By__c = presentById,
                                                                  Session_End_Date_Time__c = dtSessionEnd,
                                                                  Session_Start_Date_Time__c = dtSessionStart);
        insert objListSession; 
        return objListSession;
    }
    
    //Method to insert and return Session Registration record.
    private static Session_Registration__c insertSesRegistration(Id contactId, Id listSesId)
    {
       Session_Registration__c objSesReg = new Session_Registration__c(Contact__c = contactId,
                                                                       Listing_Session__c = listSesId);
        insert objSesReg; 
        return objSesReg;
    }
    
    //Method to insert and return Engagement Type record.
    private static Engagement_Type__c insertEngType(Id contactId, String strPartStatus)
    {
      //  Engagement_Type__c objEngType = new Engagement_Type__c(Contact__c = contactId,  Participation_Status__c = strPartStatus);//Commented for T-617691
      Engagement_Type__c objEngType = new Engagement_Type__c(Contact__c = contactId);
        insert objEngType; 
        return objEngType;
    }
     
    //Method to insert and return Engagement Type record.
    private static Membership_Registration__c insertMemRegistration(Id accountId, Id contactId, Boolean isActive)
    {
        Membership_Registration__c objMemReg = new Membership_Registration__c(Account__c = accountId,
                                                                              Contact__c = contactId);
        insert objMemReg; 
        return objMemReg;
    }
    
    // DG T-617694 changed API Name from Cart__c to Cart_Item__c
    //Method to insert and return Cart record.  // Cart Item
    private static Cart_Item__c insertCart(Id sesRegId)
    {
        Cart_Item__c objCart = new Cart_Item__c(Session_Registration__c = sesRegId);
        insert objCart; 
        return objCart;
    }
	
    
    /**
    * START AMILLER 4.27.2017 00194215
    *
    *  Refactored entire class segment since we were hitting SOQL 101 errors
    */
    //private static testMethod void TestCartTriggerHandler() 
    //{
    //    // AMILLER 4.26.2017 below one line
    //    Test.startTest();
    //    List<RecordType> lstRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Chapter' limit 1];
    //
    //    Account objAccount1 = insertAccount('Test Account - 01', 100, 200, 300, lstRecordType[0].Id);
    //    Account objAccount2 = insertAccount('Test Account - 02', 800, 400, 200, lstRecordType[0].Id);
    //    Account objAccount3 = insertAccount('Test Account - 02', 200, 800, 400, lstRecordType[0].Id);
    //    Account objAccount4 = insertAccount('Test Account - 02', 400, 200, 800, lstRecordType[0].Id);
    //    
    //    Contact objContact1 = insertContact('Test', 'Contact - 01', objAccount1.Id, '');
    //    Contact objContact2 = insertContact('Test', 'Contact - 02', objAccount2.Id, 'Civilian');
    //    Contact objContact3 = insertContact('Test', 'Contact - 03', objAccount2.Id, '');
        
    //    Listing__c objListing = insertListing('Test Listing - 01', true, true, true, objAccount1.Id);
    //    Listing_Session__c objLS1 = insertListSession('Test LS - 01', objListing.Id, objAccount2.Id, DateTime.Now(), DateTime.Now().addDays(4));
    //    Listing_Session__c objLS2 = insertListSession('Test LS - 02', objListing.Id, objAccount3.Id, DateTime.Now(), DateTime.Now().addDays(4));
    //    Listing_Session__c objLS3 = insertListSession('Test LS - 03', objListing.Id, objAccount4.Id, DateTime.Now(), DateTime.Now().addDays(4));
    //   
    //    Session_Registration__c objSesReg1 = insertSesRegistration(objContact1.Id, objLS1.Id);
    //    Session_Registration__c objSesReg2 = insertSesRegistration(objContact2.Id, objLS1.Id);
    //    Session_Registration__c objSesReg3 = insertSesRegistration(objContact2.Id, objLS2.Id);
    //    Session_Registration__c objSesReg4 = insertSesRegistration(objContact2.Id, objLS3.Id);
    //    
    //    Engagement_Type__c objEngType1 = insertEngType(objContact2.Id, 'Participant');
    //    Engagement_Type__c objEngType2 = insertEngType(objContact3.Id, 'Participant');
    //    
    //    Id communityUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Community User'].Id;
    //
    //    
    //    
    //    Membership_Registration__c objMemReg = insertMemRegistration(objAccount2.Id, objContact2.Id, true);
    //  
    //   
    //   
    //    Cart_Item__c objCart = insertCart(objSesReg1.Id);
    //    
    //
    //
    //    /*All three criteria met*/
    //    //Case I:
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg2.Id;
    //    objCart.Discount__c = Null;
    //    update objCart;
    //     // AMILLER below one line 4.26.2017
    //     //Test.startTest();
    //     //Case II:
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg3.Id;
    //    update objCart;
    //    
    //    //Case III:
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg4.Id;
    //    update objCart;
    //    
    //    //  System.assertEquals(800, [SELECT Id, Discount__c FROM Cart_Item__c WHERE Id =: objCart.Id].Discount__c);
    //    /*All three criteria met*/
    //    
    //    Any two criteria met
    //    //Case I:
    //    //objMemReg.Active__c = false;
    //    update objMemReg;
    //    
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg2.Id;
    //    update objCart;
    //   // System.assertEquals(800, [SELECT Id, Discount__c FROM Cart_Item__c WHERE Id =: objCart.Id].Discount__c);
    //      CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg3.Id;
    //    update objCart;
    //  //  System.assertEquals(800, [SELECT Id, Discount__c FROM Cart_Item__c WHERE Id =: objCart.Id].Discount__c);
    //    
    //    //Case II:
    //    //objMemReg.Active__c = true;
    //    update objMemReg;
    //    objEngType2.Participation_Status__c = 'Prospect';
    //    update objEngType2;
    //    
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg4.Id;
    //    update objCart;
    //   // System.assertEquals(800, [SELECT Id, Discount__c FROM Cart_Item__c WHERE Id =: objCart.Id].Discount__c);
    //    
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg3.Id;
    //    update objCart;
    //   // System.assertEquals(800, [SELECT Id, Discount__c FROM Cart_Item__c WHERE Id =: objCart.Id].Discount__c);
    //    
    //    //Case III:
    //    objEngType2.Participation_Status__c = 'Participant';
    //    update objEngType2;
    //    objContact2.Military_Affiliation__c = '';
    //    update objContact2;
    //    
    //     CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg2.Id;
    //    update objCart;
    // //   System.assertEquals(800, [SELECT Id, Discount__c FROM Cart_Item__c WHERE Id =: objCart.Id].Discount__c);
    //    
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg3.Id;
    //    update objCart;
    // //   System.assertEquals(400, [SELECT Id, Discount__c FROM Cart_Item__c WHERE Id =: objCart.Id].Discount__c);
    //    /*Any two criteria met*/
    //    
    //    /*Any one criteria met*/
    //    //Case I:
    //    //objMemReg.Active__c = false;
    //    update objMemReg;
    //    
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg2.Id;
    //    update objCart;
    //  //  System.assertEquals(800, [SELECT Id, Discount__c FROM Cart_Item__c WHERE Id =: objCart.Id].Discount__c);
    //    
    //    //Case II:
    //    objEngType2.Participation_Status__c = 'Prospect';
    //    update objEngType2;
    //    objContact2.Military_Affiliation__c = 'Civilian';
    //    update objContact2;
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg3.Id;
    //    update objCart;
    //    
    //    objContact2.Military_Affiliation__c = '';
    //    update objContact2;
    //    //objMemReg.Active__c = true;
    //    update objMemReg;
    //    
    //    CartTriggerHandler.isRecursion = false;
    //    objCart.Session_Registration__c = objSesReg4.Id;
    //    update objCart;
    //    
    //    test.stopTest();
    //   // System.assertEquals(800, [SELECT Id, Discount__c FROM Cart_Item__c WHERE Id =: objCart.Id].Discount__c);
    //    /*Any one criteria met*/
    //    
    //}

    // DG T-617693
    // DG T-617694 uncommented codes and changed API Name
    private static testMethod void AllThreeCriteriaMet_firstUseCase(){
        
        Test.startTest();

        // get cart
        // DG T-617694 Changed Cart__c to Cart_Item__c
        Cart_Item__c tempCart = ([SELECT Id, Session_Registration__c, Discount__c FROM Cart_Item__c LIMIT 1]);

        // get session registration
        Listing_Session__c tempListSession = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 01' LIMIT 1]);
        Contact tempContact = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 01' LIMIT 1]);
        Session_Registration__c tempSesReg = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact.Id AND Listing_Session__c = :tempListSession.Id LIMIT 1]);

        // make modification
        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg.Id;
        tempCart.Discount__c = Null;
        update tempCart;

        Test.stopTest();
    }

    private static testMethod void AllThreeCriteriaMet_secondUseCase(){

        Test.startTest();

        // get cart
        // DG T-617694 Changed Cart__c to Cart_Item__c
        Cart_Item__c tempCart = ([SELECT Id, Session_Registration__c, Discount__c FROM Cart_Item__c LIMIT 1]);

        // get session registration
        Listing_Session__c tempListSession = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 02' LIMIT 1]);
        Contact tempContact = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Session_Registration__c tempSesReg = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact.Id AND Listing_Session__c = :tempListSession.Id LIMIT 1]);

        // make modification
        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg.Id;
        update tempCart;

        Test.stopTest();
    }

    private static testMethod void AllThreeCriteriaMet_thirdUseCase(){

        Test.startTest();

        // get cart
        // DG T-617694 Changed Cart__c to Cart_Item__c
        Cart_Item__c tempCart = ([SELECT Id, Session_Registration__c, Discount__c FROM Cart_Item__c LIMIT 1]);

        // get session registration
        Listing_Session__c tempListSession = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 02' LIMIT 1]);
        Contact tempContact = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Session_Registration__c tempSesReg = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact.Id AND Listing_Session__c = :tempListSession.Id LIMIT 1]);

        // make modification
        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg.Id;
        update tempCart;

        Test.stopTest();
    }

    private static testMethod void TwoMet_firstUseCase(){

        Test.startTest();

        // get cart
        // DG T-617694 Changed Cart__c to Cart_Item__c
        Cart_Item__c tempCart = ([SELECT Id, Session_Registration__c, Discount__c FROM Cart_Item__c LIMIT 1]);

        // get session registration
        Listing_Session__c tempListSession = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 02' LIMIT 1]);
        Contact tempContact = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Session_Registration__c tempSesReg = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact.Id AND Listing_Session__c = :tempListSession.Id LIMIT 1]);

        // make modification
        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg.Id;
        update tempCart;

        Test.stopTest();
    }

    private static testMethod void TwoMet_secondUseCase(){

        Test.startTest();

        // get cart
        // DG T-617694 Changed Cart__c to Cart_Item__c
        Cart_Item__c tempCart = ([SELECT Id, Session_Registration__c, Discount__c FROM Cart_Item__c LIMIT 1]);

        // get session registration
        Listing_Session__c tempListSession = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 02' LIMIT 1]);
        Contact tempContact = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Engagement_Type__c tempEngage = ([SELECT Id FROM Engagement_Type__c WHERE Contact__c = :tempContact.Id LIMIT 1]);
        Session_Registration__c tempSesReg = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact.Id AND Listing_Session__c = :tempListSession.Id LIMIT 1]);

        // make modification
       //  tempEngage.Participation_Status__c = 'Prospect'; Commented for T-617691
        update tempEngage;
        
        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg.Id;
        update tempCart;

        // another set of updates

        Listing_Session__c tempListSession2 = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 02' LIMIT 1]);
        Contact tempContact2 = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Session_Registration__c tempSesReg2 = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact2.Id AND Listing_Session__c = :tempListSession2.Id LIMIT 1]);

        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg2.Id;
        update tempCart;

        Test.stopTest();
    }

    private static testMethod void TwoMet_thirdUseCase(){

        Test.startTest();

        // get cart
        // DG T-617694 Changed Cart__c to Cart_Item__c
        Cart_Item__c tempCart = ([SELECT Id, Session_Registration__c, Discount__c FROM Cart_Item__c LIMIT 1]);

        // get session registration
        Listing_Session__c tempListSession = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 02' LIMIT 1]);
        Contact tempContact = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Engagement_Type__c tempEngage = ([SELECT Id FROM Engagement_Type__c WHERE Contact__c = :tempContact.Id LIMIT 1]);
        Session_Registration__c tempSesReg = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact.Id AND Listing_Session__c = :tempListSession.Id LIMIT 1]);

        // make modification
      //  tempEngage.Participation_Status__c = 'Prospect'; //Commented for T-617691
        update tempEngage;

        tempContact.Military_Affiliation__c = ''; 
        update tempContact;
        
        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg.Id;
        update tempCart;

        // another set of updates
        Listing_Session__c tempListSession2 = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 01' LIMIT 1]);
        Contact tempContact2 = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Session_Registration__c tempSesReg2 = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact2.Id AND Listing_Session__c = :tempListSession2.Id LIMIT 1]);

        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg2.Id;
        update tempCart;

        Listing_Session__c tempListSession3 = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 01' LIMIT 1]);
        Contact tempContact3 = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Session_Registration__c tempSesReg3 = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact3.Id AND Listing_Session__c = :tempListSession3.Id LIMIT 1]);

        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg3.Id;
        update tempCart;

        Test.stopTest();
    }


    private static testMethod void OneMet_firstUseCase(){

        Test.startTest();

        // get cart
        // DG T-617694 Changed Cart__c to Cart_Item__c
        Cart_Item__c tempCart = ([SELECT Id, Session_Registration__c, Discount__c FROM Cart_Item__c LIMIT 1]);

        // get session registration
        Listing_Session__c tempListSession = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 01' LIMIT 1]);
        Contact tempContact = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Session_Registration__c tempSesReg = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact.Id AND Listing_Session__c = :tempListSession.Id LIMIT 1]);

        // make modification
        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg.Id;
        update tempCart;

        Test.stopTest();
    }

    private static testMethod void OneMet_secondUseCase(){

        Test.startTest();

        // get cart
        // DG T-617694 Changed Cart__c to Cart_Item__c
        Cart_Item__c tempCart = ([SELECT Id, Session_Registration__c, Discount__c FROM Cart_Item__c LIMIT 1]);

        // get session registration
        Listing_Session__c tempListSession = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 02' LIMIT 1]);
        Contact tempContact = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 02' LIMIT 1]);
        Engagement_Type__c tempEngage = ([SELECT Id FROM Engagement_Type__c WHERE Contact__c = :([SELECT Id FROM Contact WHERE LastName = 'Contact - 03' LIMIT 1]).Id LIMIT 1]);
        Session_Registration__c tempSesReg = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact.Id AND Listing_Session__c = :tempListSession.Id LIMIT 1]);

        // make modification
       // tempEngage.Participation_Status__c = 'Prospect'; //Commented for T-617691
        update tempEngage;

        tempContact.Military_Affiliation__c = 'Civilian';
        update tempContact;

        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg.Id;
        update tempCart;

        tempContact.Military_Affiliation__c = '';
        update tempContact;

        Listing_Session__c tempListSession2 = ([SELECT Id FROM Listing_Session__c WHERE Name = 'Test LS - 02' LIMIT 1]);
        Contact tempContact2 = ([SELECT Id FROM Contact WHERE LastName = 'Contact - 03' LIMIT 1]);
        Engagement_Type__c tempEngage2 = ([SELECT Id FROM Engagement_Type__c WHERE Contact__c = :([SELECT Id FROM Contact WHERE LastName = 'Contact - 03' LIMIT 1]).Id LIMIT 1]);
        Session_Registration__c tempSesReg2 = ([SELECT Id FROM Session_Registration__c WHERE Contact__c = :tempContact.Id AND Listing_Session__c = :tempListSession.Id LIMIT 1]);

        CartTriggerHandler.isRecursion = false;
        tempCart.Session_Registration__c = tempSesReg2.Id;
        update tempCart;

        Test.stopTest();
    }
	
    // END AMILLER 4.27.2017 00194215
}