/*
*
* Appirio (c) - 2017
* 
* Modified By          Modified Date      Reason
* Alexander Miller       5.10.2017       00192931
* Jessica Schilling      June 14 2017    00197780     Added additional error handling
* Dimpesh K Gehlot 		 July 17 2017    T-617693     commented code to change obj model
* Dimpesh K Gehlot		 July18.2017	 T-617694     uncommented codes to bring back functionality and changed Cart__c to Cart_Item__c
*/
public class TFT_CheckoutSummaryController {
	
    //Variables
    public Decimal sessionTotal                                                         {get; set;}
    public Decimal cartDiscounts                                                        {get; set;}
    public Decimal checkoutTotal                                                        {get; set;}
    public Decimal donationAmount                                                       {get; set;}
    public Decimal cartMemPrice                                                         {get; set;}
    public Decimal cartFinAidApplied                                                    {get; set;}
    public Integer numberOfYearsToBeDisplayed                                           {get; set;}
    public String website                                                               {get; set;}
    public String listingSessionIdToDelete                                              {get; set;}
    Public Contact objContact                                                           {get; set;}
    // DG T-617694 Changed Cart__c to Cart_Item__c
    public List<Cart_Item__c> objCartList                                                    {get; set;}
    public List<Session_Registration__c> objSessionRegistrationList                     {get; set;}
    public List<Listing_Session__c> objListingSessionList                               {get; set;}
    public Map<String, String> objListingSessionIdWithContactId                         {get; set;}
    public Map<String, List<TFT_CheckoutControllerWrapper>> objContactIdWithWrapperList {get; set;}
    
    //Payment Itegration Variables
    public String tokenString                                                           {get; set;}
    public String selectedPaymentInfo                                                   {get; set;}
    public String selectedExpiryMonth                                                   {get; set;}
    public String selectedExpiryYear                                                    {get; set;}
    public List<String> ExpiryYearOptions                                               {get; set;}
    public String creditCardBlockStyle                                                  {get; set;}
    public String cardNumber                                                            {get; set;}
    public String SelectedPaymentMethod                                                 {get; set;}
    public String cardName                                                              {get; set;}
    public String cardCVV                                                               {get; set;}
    
    public Boolean showForm                                                             {get; set;}
    public Boolean showErrorSection                                                     {get; set;}
    public Boolean ShowCreditCardInfoFlag                                               {get; set;}
    public Boolean ShowCardSectionFlag                                                  {get; set;}
    public Boolean ShowPaymentSection                                                   {get; set;}
    public Boolean finAidApplied                             							{get; set;}
    public Account objAcc                                                               {get; set;}
    public Payment_Information__c objPaymentInfoRec                                     {get; set;}
    public List<Account> objAccList                                                     {get; set;}
    public List<Payment_Information__c> objPaymentInfo                                  {get; set;}
    public List<SelectOption> fillSelectCardPaymentInfoList                             {get; set;}
    public string sessionregistrationForCartTodelete                                    {get;set;}
    //Variables for Confirmation section for cardId
    public String cardId    															{get; set;}
    
    // Modified below one line AMILLER 5.10.2017 00192931
    public String errorMessage                                                          {get;set;}

    //Custom Settings instance
    public CustomMessages__c customMsgs													{get; set;}
    
    //Variable to be used on page to show number of session added to cart.
    public Integer sessionCartCount                                                     {get; set;} 
    
    public Boolean isZeroBalance                                                        {get; set;}
   
    private Decimal checkoutTotalInitial;
    private User loggedInUser;// will hold details of logged in user.
    private Map<Id, Listing_Session__c> listingSessionMap;
    private List<User> lstUser;
    public Account loggedInUserAccount{get;set;}// will hold details of logged in user account.
    public boolean chapterOfferMembership{get;set;}
    /*Method to initialize variables*/
    // DG
    // DG T-617694 uncommented code
    
    private void initialize() {
        //Variable Initializations
        cartMemPrice = 0.00;
        sessionTotal = 0.00;
        cartDiscounts = 0.00;
        checkoutTotal = 0.00;
        donationAmount = 0.00;
        cartFinAidApplied = 0.00;
        creditCardBlockStyle = 'display:none;';
        isZeroBalance = false;
        // DG T-617694 Changed Cart__c to Cart_Item__c
        objCartList = new List<Cart_Item__c>();
        objContact = new Contact();
        ShowPaymentSection = true;
        finAidApplied = true;
        numberOfYearsToBeDisplayed = setNumberOfYearsToBeDisplayed();
        ExpiryYearOptions = new List<String>();
        sessionCartCount = TFT_CartItems.count(UserInfo.getUserId());
        for(Integer i = Date.today().year() ; i <= Date.today().year() + numberOfYearsToBeDisplayed ; i++){
          ExpiryYearOptions.add( String.valueOf(i) ); 
        }
    }
    
    //constructor
    public TFT_CheckoutSummaryController() {
        website = ApexPages.currentPage().getParameters().get('website');
        for(User u : [SELECT Id, ChapterID__c FROM User WHERE Id = :UserInfo.getUserId() limit 1]){
             loggedInUser = u;
        }
        if(loggedInUser != null){
            if(loggedInUser.ChapterID__c != null && loggedInUser.ChapterID__c != ''){
               for(Account acc : [SELECT Id, Website,Membership_Offered__c FROM Account WHERE Id = :loggedInUser.ChapterID__c limit 1]){
                   loggedInUserAccount = acc;
                   chapterOfferMembership = acc.Membership_Offered__c;
                   if(acc.Website != null && acc.Website != '' && website != null && website != ''){
                       website = acc.Website.removeStartIgnoreCase('https://');
                   }
               }
           }
        }
        customMsgs = CustomMessages__c.getInstance();
        
        initialize();
        //Fetch Participants with their sessions.
        fetchParticipantsWithSessions();
        fetchportalUserContact();
        fetchPaymentInformationsForChapter();
    }
    
    //Method called to render the Summary details
    public void rerenderSummaryComponent(){
        website = ApexPages.currentPage().getParameters().get('website');
        for(User u : [SELECT Id, ChapterID__c FROM User WHERE Id = :UserInfo.getUserId() limit 1]){
             loggedInUser = u;
        }
        if(loggedInUser != null){
            if(loggedInUser.ChapterID__c != null && loggedInUser.ChapterID__c != ''){
               for(Account acc : [SELECT Id, Website,Membership_Offered__c FROM Account WHERE Id = :loggedInUser.ChapterID__c limit 1]){
                   loggedInUserAccount = acc;
                   chapterOfferMembership = acc.Membership_Offered__c;
                   if(acc.Website != null && acc.Website != '' && website != null && website != ''){
                       website = acc.Website.removeStartIgnoreCase('https://');
                   }
               }
           }
        }
        customMsgs = CustomMessages__c.getInstance();
        
        initialize();
        //Fetch Participants with their sessions.
        fetchParticipantsWithSessions();
        fetchportalUserContact();
        fetchPaymentInformationsForChapter();
    }
    
    //Method to fetch Payment Informations for Chapter
    public void fetchPaymentInformationsForChapter() {
        //Memory Allocations for the variables.
        objPaymentInfo = new List<Payment_Information__c>();
        objPaymentInfoRec = new Payment_Information__c();
        fillSelectCardPaymentInfoList = new list<SelectOption>();
        objAccList = new List<Account>();
        objAcc = new Account();
        
        if(String.isNotEmpty(website)) {     
            //get the account details with the Stripe API Keys
            objAccList = [SELECT Id, Name,Payments_Accepted_In_Person__c, Stripe_Publishable_Live_Key__c, Stripe_Publishable_Test_Key__c, Stripe_Secret_Live_Key__c, Stripe_Secret_Test_Key__c
                          FROM Account 
                          WHERE RecordType.DeveloperName='Chapter' and Website =: website LIMIT 1];
        }
        
        //Fill up the Select Card Dropdown with Payment Info.
        SelectOption  objPaymentInfoFirstOption = new SelectOption('--Select--', '--Select--');
        SelectOption  objPaymentInfoAddNewOption = new SelectOption('Add New', 'Add New');
        fillSelectCardPaymentInfoList.add(objPaymentInfoFirstOption);
        fillSelectCardPaymentInfoList.add(objPaymentInfoAddNewOption);
        
        if(objAccList.size() > 0) {  
            //get Account object to refer ibn VF page.
            objAcc = objAccList[0];
            //get the Payment Informations for the current logged in user's contact
            objPaymentInfo = [SELECT Id, Name,Card_Number__c, Customer_Contact__c, Expiration_Month__c, Expiration_Year__c, Token__c, Chapter__c,
                                     Account_Holder_Name__c, Account_Holder_Type__c, Bank_Account_Number__c, Bank_Account_Token__c
                              FROM Payment_Information__c
                              WHERE Chapter__c =: null];
            showForm = true;
            showErrorSection = false;
            
            if(objPaymentInfo.size() > 0) {
                objPaymentInfoRec = objPaymentInfo[0];
                for(Payment_Information__c payInfo : objPaymentInfo) {
                    if(payInfo.Card_Number__c !=  null) {
                        this.fillSelectCardPaymentInfoList.add(new SelectOption(payInfo.id,string.valueOf(payInfo.Card_Number__c)));
                    }
                }
            }
        }
        else {
            showForm = false;
            showErrorSection = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,customMsgs.Website_Parameter_Check_Message__c));
        }
    }
    
    //Fetching the Participants with session registrations
    public Void fetchParticipantsWithSessions() {
        //Variables & initializations
        Set<Id> sessionRegistrationIds = new Set<Id>();
        Set<Id> listingSessionsIds = new Set<Id>();
        Map<String, double> objContactWithCartDiscount = new Map<String, double>();
        Map<String, double> objContactWithCartActualPrice = new Map<String, double>();
        Map<String, double> objContactWithCartMembershipPrice = new Map<String, double>();
        objContactIdWithWrapperList = new Map<String, List<TFT_CheckoutControllerWrapper>>();
        objSessionRegistrationList = new List<Session_Registration__c>();
        objListingSessionList = new List<Listing_Session__c>();
        objListingSessionIdWithContactId = new Map<String, String> (); 
        // DG T-617694 Changed Cart__c to Cart_Item__c
        List<Cart_Item__c> objCartListTemp = new List<Cart_Item__c>();
        
        objCartListTemp = [SELECT Id, Name, Session_Registration__r.Id, Discount__c, Actual_Price__c, Session_Registration__r.Contact__r.Id, Apply_Membership_Amount__c,
                              Session_Registration__r.Contact__r.Name, 
                           // changed Membership_Price__c to Item_Price__c 
                           Item_Price__c, Financial_Aid_Applied__c, Status__c, Session_Registration__r.Status__c, Membership_Registration__c
                         // DG T-617694 Changed Cart__c to Cart_Item__c
                         FROM Cart_Item__c
                         WHERE (Session_Registration__r.Status__c = 'In Process' OR Session_Registration__r.Status__c = 'Financial Aid Applied')
                         // DG T-617694 Changed Cart__c to Cart_Item__c
                         AND Cart_Item__c.CreatedByID =: UserInfo.getUserId()
                         AND Status__c != 'Unpaid' AND Status__c != 'Charged' 
                         ORDER BY Session_Registration__r.Contact__r.Name, Session_Registration__c];

        sessionTotal = 0.00;
        cartDiscounts = 0.00;
        cartMemPrice = 0.00;
        cartFinAidApplied = 0.00;
        
        if(!objCartListTemp.isEmpty()) {
             Set<Id> setContactIds = new Set<Id>();
             // DG T-617694 Changed Cart__c to Cart_Item__c
             for(Cart_Item__c cart: objCartListTemp) {
                 if(cart.Session_Registration__r.Status__c == 'In Process') {
                     finAidApplied = false;
                     objCartList.add(cart);
                 }
            }
            
            if(finAidApplied)
              objCartList.addAll(objCartListTemp);
            // DG T-617694 Changed Cart__c to Cart_Item__c
            for(Cart_Item__c cart: objCartList) {
              setContactIds.add(cart.Session_Registration__r.Contact__r.Id);
            }
            
            Set<Id> setMembershipIdsOnContact = new Set<Id>();
            
            if(!setContactIds.isEmpty()) {
              for(Contact objContactOnSR : [ SELECT Id, (  SELECT Id 
                                FROM Membership_Registrations__r 
                                WHERE Active_Status__c = TRUE
                                  )
                            FROM Contact WHERE Id = :setContactIds 
                          ]) {
                
                if(!objContactOnSR.Membership_Registrations__r.isEmpty()) {
                  for(Membership_Registration__c objMembershipOnContact : objContactOnSR.Membership_Registrations__r) {
                    setMembershipIdsOnContact.add(objMembershipOnContact.Id);
                  }
                }
              }
            }
            
            set<Id> setSessionRegIds = new set<Id>();
 
            if(!setMembershipIdsOnContact.isEmpty()) {
              for(Membership_Registration__c objMembershipOnContact : [   SELECT Id, (  SELECT Id
                                                    FROM Session_Registrations__r  
                                                    WHERE Status__c != 'In Process'
                                                   ) 
                                             FROM Membership_Registration__c
                                             WHERE Id = :setMembershipIdsOnContact]) {
                
                if(!objMembershipOnContact.Session_Registrations__r.isEmpty()) {
                  for(Session_Registration__c objSR : objMembershipOnContact.Session_Registrations__r) {
                    setSessionRegIds.add(objSR.Id);
                  }
                }
              }
            }
            
            Set<Id> setContactIdsWithMembershipPaid = new Set<Id>();
            
            if(!setSessionRegIds.isEmpty()) {
              // DG T-617694 Changed Cart__c to Cart_Item__c
              for(Cart_Item__c objCartWithMembershipPrice : [   SELECT Session_Registration__r.Contact__r.Id, Status__c, Apply_Membership_Amount__c, Membership_Registration__c 
                                    // DG T-617694 Changed Cart__c to Cart_Item__c
                                    FROM Cart_Item__c 
                                    WHERE Session_Registration__c = :setSessionRegIds
                                    AND (Status__c = 'Unpaid' OR Status__c = 'Charged') 
                                  ]) {
                
                setContactIdsWithMembershipPaid.add(objCartWithMembershipPrice.Session_Registration__r.Contact__r.Id);
              } 
            }
             
            Map<Id, Decimal> mapContactIdToMembershipPrice = new Map<Id, Decimal>();
            // DG T-617694 Changed Cart__c to Cart_Item__c
            for(Cart_Item__c cart: objCartList) {
                //Session Total Count
                if(cart.Actual_Price__c != null) {
                    sessionTotal = sessionTotal + cart.Actual_Price__c;
                }
                
                //Cart Discount Total
                if(cart.Discount__c != null) {
                    cartDiscounts = cartDiscounts + cart.Discount__c;
                }
                
                //Cart Membership  Price Total
                // changed Membership_Price__c to Item_Price__c
                if(cart.Item_Price__c != null && cart.Apply_Membership_Amount__c) {
                  if(!mapContactIdToMembershipPrice.containsKey(cart.Session_Registration__r.Contact__r.Id)) {
                    if(!setContactIdsWithMembershipPaid.contains(cart.Session_Registration__r.Contact__r.Id)) {
                      mapContactIdToMembershipPrice.put(cart.Session_Registration__r.Contact__r.Id, 
                      // changed Membership_Price__c to Item_Price__c
                      cart.Item_Price__c);
              		  cartMemPrice = cartMemPrice + 
                      // changed Membership_Price__c to Item_Price__c   
                          cart.Item_Price__c;  
              		  //system.assert(false,'mem price'+cart.Membership_Price__c);
                    }                
                  }    
                }
                
                //Cart Financial Aid Applied Total
                if(cart.Financial_Aid_Applied__c != null) { 
                    cartFinAidApplied = cartFinAidApplied + cart.Financial_Aid_Applied__c;
                }
                
                sessionRegistrationIds.add(cart.Session_Registration__r.Id);
                objContactWithCartActualPrice.put(cart.Session_Registration__r.Contact__r.Name+cart.Session_Registration__r.Id, cart.Actual_Price__c);
                
                Decimal membershipDiscount;
                
                if(cart.Discount__c == null)
                  membershipDiscount = 0;
                else
                  membershipDiscount = cart.Discount__c;
                  
                objContactWithCartDiscount.put(cart.Session_Registration__r.Contact__r.Name+cart.Session_Registration__r.Id, membershipDiscount);  
                
                // changed Membership_Price__c to Item_Price__c
                Decimal MembershipPrice = cart.Item_Price__c;
                
                objContactWithCartMembershipPrice.put(cart.Session_Registration__r.Contact__r.Name+cart.Session_Registration__r.Id, MembershipPrice);  
            }
        } 
        
        if(!sessionRegistrationIds.isEmpty()) {
            objSessionRegistrationList = [SELECT Id, Name, Listing_Session__r.Listing_Session_Location_Name__c,
                                                 Listing_Session__r.Primary_Program_Level_Restriction__c, 
                                                 Listing_Session__r.Secondary_Program_Level_Restriction__c, 
                                                 Listing_Session__r.Session_Start_Date_Time__c,
                                                 Listing_Session__r.Session_End_Date_Time__c,
                                                 Listing_Session__r.Actual_Price__c, 
                                                 Listing_Session__r.Base_Price__c, 
                                                 Contact__r.Name, Listing_Session__r.Id
                                          FROM Session_Registration__c
                                          WHERE Id In: sessionRegistrationIds];
                                          
            if(!objSessionRegistrationList.isEmpty()) {
                for(Session_Registration__c sessionRegistration: objSessionRegistrationList) {
                    listingSessionsIds.add(sessionRegistration.Listing_Session__r.Id);
                }
                
                listingSessionMap = new Map<Id, Listing_Session__c>(
                    [SELECT Id, Name, Listing_Session_Location_Name__r.Name, 
                                         Primary_Program_Level_Restriction__c,
                                         Listing_Session_Location_Address__c,
                                         Secondary_Program_Level_Restriction__c, 
                                         Session_Start_Date_Time__c,
                                         Session_End_Date_Time__c,
                                         Actual_Price__c,
                                         Base_Price__c
                                         FROM Listing_Session__c
                                         WHERE Id In: listingSessionsIds]);
                
                for(Session_Registration__c sessionRegistration: objSessionRegistrationList) {
                    objListingSessionIdWithContactId.put(sessionRegistration.Listing_Session__r.Id,sessionRegistration.Contact__r.Name);
                    objContactIdWithWrapperList.put(sessionRegistration.Contact__r.Name+sessionRegistration.Id, new List<TFT_CheckoutControllerWrapper>());
                    Listing_Session__c listingSession = listingSessionMap.get(sessionRegistration.Listing_Session__r.Id);
                    
                    objContactIdWithWrapperList.get(sessionRegistration.Contact__r.Name+sessionRegistration.Id).add(new TFT_CheckoutControllerWrapper(sessionRegistration.Contact__r.Name, 
                                                                                                       listingSession, 
                                                                                                       objContactWithCartActualPrice.get(sessionRegistration.Contact__r.Name+sessionRegistration.Id),
                                                                                                       objContactWithCartDiscount.get(sessionRegistration.Contact__r.Name+sessionRegistration.Id),null,
                                                                                                       objContactWithCartMembershipPrice.get(sessionRegistration.Contact__r.Name+sessionRegistration.Id)));
                }
            }
            
            
            if(!listingSessionsIds.isEmpty()) {
                objListingSessionList = listingSessionMap.values();
            }
            
            checkoutTotal = 0.00;
            checkoutTotalInitial = 0;
            donationAmount = donationAmount == null ? 0.00 : donationAmount;
            
            if(!objListingSessionList.isEmpty()) {
                for(Listing_Session__c listingSession: objListingSessionList) { 
                    if(objContactIdWithWrapperList.containsKey(objListingSessionIdWithContactId.get(listingSession.Id))) {   
                        String contactName = objListingSessionIdWithContactId.get(listingSession.Id);
                        objContactIdWithWrapperList.get(contactName).add(new TFT_CheckoutControllerWrapper(contactName, listingSession, objContactWithCartActualPrice.get(contactName),objContactWithCartDiscount.get(contactName),null,objContactWithCartMembershipPrice.get(contactName)));
                    }
                }
                if(finAidApplied) {
                  cartFinAidApplied = sessionTotal + cartMemPrice - cartDiscounts;
                  checkoutTotal = donationAmount;
                  sessionTotal = 0.00;
                  cartMemPrice = 0.00;
                  cartDiscounts = 0.00;
                } else
                  checkoutTotal = sessionTotal + cartMemPrice - cartDiscounts - cartFinAidApplied + donationAmount;
            }
        }
        checkoutTotalInitial = checkoutTotal;
        if(checkoutTotal == 0.00){
            isZeroBalance = true;
            creditCardBlockStyle = 'display:none;';
        }
    }
    
    //Method to fetch contact record correspond to portal user
    private void fetchportalUserContact() {
        lstUser = [SELECT Id, Contact.Id, Contact.Name, Contact.FirstName, 
                                     Contact.LastName, Contact.MailingStreet, Contact.MailingCity, 
                                     Contact.MailingState, Contact.MailingPostalCode, Contact.HomePhone, 
                                     Contact.MobilePhone, Contact.Work_Phone__c, Contact.Email, Contact.Preferred_Contact_Method__c
                               FROM User
                               WHERE Id =: UserInfo.getUserId() limit 1];
        
        if(!lstUser.isEmpty())
        {
            objContact = new Contact(Id = lstUser[0].Contact.Id,
                                     FirstName = lstUser[0].Contact.FirstName,
                                     LastName = lstUser[0].Contact.LastName,
                                     MailingStreet = lstUser[0].Contact.MailingStreet,
                                     MailingCity = lstUser[0].Contact.MailingCity,
                                     MailingState = lstUser[0].Contact.MailingState,
                                     MailingPostalCode = lstUser[0].Contact.MailingPostalCode,
                                     HomePhone = lstUser[0].Contact.HomePhone,
                                     MobilePhone = lstUser[0].Contact.MobilePhone,
                                     Work_Phone__c = lstUser[0].Contact.Work_Phone__c,
                                     Email = lstUser[0].Contact.Email,
                                     Preferred_Contact_Method__c = lstUser[0].Contact.Preferred_Contact_Method__c);
        }
    }
	
    //Method for removing the session registrations
    public PageReference removeSessionRegistration() {    
        if(listingSessionIdToDelete != '' && listingSessionIdToDelete != null && sessionregistrationForCartTodelete != null && sessionregistrationForCartTodelete != '') {
            sessionregistrationForCartTodelete = sessionregistrationForCartTodelete.LEFT(15);
            // DG T-617694 Changed Cart__c to Cart_Item__c
            List<Cart_Item__c> objCartToDelete = new List<Cart_Item__c>();
            List<Session_Registration__c> sessionRegToDel = new List<Session_Registration__c>();
                                                                
             set<Id> objSessionRegIds = new set<Id>();           
            // DG T-617694 Changed Cart__c to Cart_Item__c                                    
            for(Cart_Item__c cr : [SELECT Id, Session_Registration__c,Membership_Registration__c, Session_Registration__r.Contact__r.Id,Session_Registration__r.Id 
                                                                FROM Cart_Item__c
                                                                WHERE Session_Registration__r.Listing_Session__c =: listingSessionIdToDelete
                                                                AND CreatedByID =: UserInfo.getUserId() AND Session_Registration__c = :sessionregistrationForCartTodelete AND Session_Registration__c != null]){
            
                objCartToDelete.add(cr); 
                sessionRegToDel.add(new Session_Registration__c(Id = cr.Session_Registration__c));
            }
            
            if(objCartToDelete.size() > 0){
                if(objCartToDelete[0].Membership_Registration__c != null){
                		// DG T-617694 Changed Cart__c to Cart_Item__c
                        Cart_Item__c anotherCartToUpdateWithMembership;
                        // DG T-617694 Changed Cart__c to Cart_Item__c
                        for(Cart_Item__c c : [SELECT Id FROM Cart_Item__c WHERE Membership_Registration__c = null AND Payment_Information__c = null AND Session_Registration__c != null AND Session_Registration__r.Listing_Session__r.Membership_Required__c = true AND  Session_Registration__r.Contact__c = :objCartToDelete[0].Session_Registration__r.Contact__r.Id]){
                            anotherCartToUpdateWithMembership = c;
                        }
                     if(anotherCartToUpdateWithMembership != null){
                             anotherCartToUpdateWithMembership.Membership_Registration__c = objCartToDelete[0].Membership_Registration__c;
                             anotherCartToUpdateWithMembership.Apply_Membership_Amount__c = true;
                             update anotherCartToUpdateWithMembership;
                     }else{
                         Membership_Registration__c oBjToDel = new Membership_Registration__c(Id=objCartToDelete[0].Membership_Registration__c);
                         delete oBjToDel;
                     }
                }
            }
            
            if(objCartToDelete.size() > 0){
                delete objCartToDelete;
            }
            if(sessionRegToDel.size() > 0){
                delete sessionRegToDel;
            }
        }
        
        initialize();
        //Fetch Participants with their sessions.
        fetchParticipantsWithSessions();
        fetchportalUserContact();
        fetchPaymentInformationsForChapter();
        return null;
    }
    
    //Method to enable the Select Card Dropdown where we filled the payment information
    public pageReference ShowSelectCard() {
       selectedPaymentInfo = 'Add New';
       if(selectedPaymentInfo != '--Select--')
          selectedPaymentInfo = '--Select--';
          
        if(selectedPaymentMethod == 'credit-payment'){
            creditCardBlockStyle = 'display:block;';
            ShowCreditCardInfoFlag = true;
            numberOfYearsToBeDisplayed = ShowCreditCardSection();
            return null;
        }
        else if(selectedPaymentMethod == 'Check Cash Payment') {
            creditCardBlockStyle = 'display:none;';
            ShowCreditCardInfoFlag = false;
            ShowCardSectionFlag = false;
            return null;
        }
        else {
            creditCardBlockStyle = 'display:none;';
            ShowCreditCardInfoFlag = false;
            ShowCardSectionFlag = false;
            return null;     
        }
    }
    
    //Method to enable the credit-payment Section where user will given the card details.
    public Integer ShowCreditCardSection() {
            ShowCardSectionFlag = true;
            selectedExpiryYear = '';
            numberOfYearsToBeDisplayed = setNumberOfYearsToBeDisplayed();
            if(cardNumber != null)
              cardNumber = '';
            return numberOfYearsToBeDisplayed;
    }
    
    //Method to set the number of Years
    public Integer setNumberOfYearsToBeDisplayed(){
      numberOfYearsToBeDisplayed = (Integer)(Credit_Card_Expiration_Years__c.getInstance().Number_Of_Years__c);
      if(numberOfYearsToBeDisplayed == null){
        numberOfYearsToBeDisplayed = 10;
      }
      return numberOfYearsToBeDisplayed;    
    }
    
    //Create Customer in Stripe based on the given card information
    public pageReference CreateCustomer() {
        StripeCharge ch;
        StripeCustomer StripeCust;
        objPaymentInfoRec = new Payment_Information__c();
        
        if(finAidApplied)
          SelectedPaymentMethod = 'Check Cash Payment';
          
        if(SelectedPaymentMethod != '' && SelectedPaymentMethod != null) {
            if(SelectedPaymentMethod == 'credit-payment') {
                    Try{  
                        //Call Stripe Customer's Create method to make Callout
                        stripeCust = StripeCustomer.create(tokenString , 'Customer', objAccList[0].Stripe_Secret_Test_Key__c);   
                        //START JSCHILLING 00197780 6/14/2017
                        //If an error message is found from stripe, kill the operation and allow for it to be retrieved
                        if(stripeCust.failure_message != null){
                          showForm = false;
                          showErrorSection = true;
                          errorMessage = StripeCharge.parseErrorMessage(stripeCust.failure_message).escapeEcmaScript();
                          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, errorMessage));
                          return null;
                        }
                        else {
                          errorMessage = '';
                        }
                        //END JSCHILLING 00197780 6/14/2017
                    }
                    Catch(Exception e){
                        showForm = false;
                        showErrorSection = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,e.getMessage()));
                        return null;
                    }
    
                    if(stripeCust != null) {
                        try{
                            //Call Stripe Charges's Create method to make Callout
                            ch = StripeCharge.create(stripeCust.Id, checkoutTotal, objAccList[0].Stripe_Secret_Test_Key__c, objContact.FirstName+' '+objContact.LastName);
                            /*
                             * START AMILLER 5.5.2017 00192931
                             * 
                             * If an error message is found from stripe, kill the operation and allow for it to be retrieved
                             */
    // DG
    // DG T-617694 uncommented code
    
                            if(ch.failure_message != null){
                              showForm = false;
                              showErrorSection = true;
                              errorMessage = StripeCharge.parseErrorMessage(ch.failure_message);
                              ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, errorMessage));
                              return null;
                            }
                            else {
                              errorMessage = '';
                            }
                            // END AMILLER 5.5.2017 00192931 
                        }
                        Catch(Exception e){
                            showForm = false;
                            showErrorSection = true;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,e.getMessage()));
                            return null;
                        }

                        //Insert Payment Information(Card Details)
                        objPaymentInfoRec.Payment_Method__c = 'credit-payment';
                        objPaymentInfoRec.Card_Number__c = cardNumber.right(4);
                        objPaymentInfoRec.Expiration_Month__c = Decimal.valueOf(selectedExpiryMonth);
                        objPaymentInfoRec.Expiration_Year__c = Decimal.valueOf(selectedExpiryYear);
                        objPaymentInfoRec.Status__c = 'Paid in Full';
                        objPaymentInfoRec.Token__c = stripeCust.Id;
                    }
                    else {
                        showForm = false;
                        showErrorSection = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,customMsgs.ErrorMessage__c));
                        return null;
                    }
            }
            else if(SelectedPaymentMethod == 'Check Cash Payment') {
                objPaymentInfoRec = new Payment_Information__c();
                objPaymentInfoRec.Payment_Method__c = 'Check Cash Payment';
                objPaymentInfoRec.Status__c = 'Payment Outstanding';
            }
            else if(SelectedPaymentMethod == 'No Payment Required') {
                objPaymentInfoRec = new Payment_Information__c();
                objPaymentInfoRec.Payment_Method__c = 'Zero Balance';
                objPaymentInfoRec.Status__c = 'Paid in Full';
            }
                
            try{
                //List<Contact> lstCon = [SELECT Id, Name FROM Contact WHERE AccountId =: objAccList[0].Id Limit 1]; 
                //objPaymentInfoRec.Customer_Contact__c = (lstCon.size() > 0) ? lstCon[0].Id : Null;
                objPaymentInfoRec.Customer_Contact__c =  lstUser[0].Contact.Id;
                objPaymentInfoRec.Chapter__c = objAccList[0].Id;
                upsert objPaymentInfoRec;
            }
            Catch(Exception e){
                showForm = false;
                showErrorSection = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage()));
                return null;
            }
            
            //update Cart Charge amount
            // DG T-617694 Changed Cart__c to Cart_Item__c
            List<Cart_Item__c> updateCartList = new List<Cart_Item__c>();
            for(Cart_Item__c c :objCartList) {
              
                c.Charge_Amount__c = checkoutTotal;
                c.Payment_information__c = objPaymentInfoRec.ID;
                // changed reference to cart.Charge_Token
                c.Cart__r.Charge_Token__c = (ch != Null) ? ch.Id : Null;
                
                if(c.Charge_Amount__c == 0)                  
                  ShowPaymentSection=FALSE;
                
                if(donationAmount != null)
                    c.Donation__c = donationAmount;
                
                if(SelectedPaymentMethod == 'No Payment Required')
                     c.Cart__r.Charge_Token__c = 'Zero Balance';
                     
                updateCartList.add(c);
            }
            
            update updateCartList;
             
            if(!finAidApplied) {
              //update Session Registration Record
              List<Session_Registration__c> objSessionRegList = new List<Session_Registration__c>();
              for(Session_Registration__c sessions: objSessionRegistrationList) {
                  
                  sessions.Status__c = 'Registered';
                  objSessionRegList.add(sessions);
              }
              update objSessionRegList;
            }
            
            //Redirect to the Payment Confirmation Page where we create the charge for the same.
            if(objPaymentInfoRec != null) {
              SubmitRegistration(objPaymentInfoRec.Id);
              List<Payment_Information__c> lstPaymentInfoRec = new List<Payment_Information__c>();
              if(SelectedPaymentMethod == 'Check Cash Payment' || SelectedPaymentMethod == 'No Payment Required')
              	lstPaymentInfoRec = [SELECT Name FROM Payment_Information__c WHERE id = :objPaymentInfoRec.Id];
             
                cardId = (!Test.isRunningTest()) ? ((!lstPaymentInfoRec.isEmpty()) ? lstPaymentInfoRec[0].Name : ((StripeCust != Null) ? StripeCust.sources.stripeData[0].Id : '')) : '';
            }
            return null;
        }
        return null;
    }
    
     //Create Customer in Stripe based on the given card information
    public void CreateCustomerZeroBalance() {
        SelectedPaymentMethod = 'No Payment Required';
        CreateCustomer();
    }
    
    /*Method to update contact records*/
    // DG 
    // DG T-617694 uncommented code
    public void SubmitRegistration(String payId)
    {
        if( objContact.Id != Null && objContact.LastName != Null ){
          update objContact;
        }
        Set<Membership_Registration__c> setMember= new Set<Membership_Registration__c>();//Added by Sneha for case# 00190749
        List<Membership_Registration__c> updateMemberShips = new List<Membership_Registration__c>();
        boolean AwaitingPayment = false;
        for(Cart_Item__c cart : objCartList){
            if(cart.Membership_Registration__c != null){
                AwaitingPayment = (objPaymentInfoRec.Status__c == 'Paid in Full') ? false : true;
                setMember.add( new Membership_Registration__c(id=cart.Membership_Registration__c, Payment_Information__c=payId, Membership_Dues_Paid__c = (objPaymentInfoRec.Status__c == 'Paid in Full') ? true : false, Awaiting_Payment__c = AwaitingPayment));
            } 
        }
        if(!setMember.isEmpty())
        {
            updateMemberShips.addAll(setMember);
            update updateMemberShips;
        }
    }
    
    //Method to update the checkoutTotal
    public void updateCheckoutTotal() {
        if(donationAmount != null){
            checkoutTotal = checkoutTotalInitial + donationAmount;
        }
        else{
            checkoutTotal = checkoutTotalInitial;
        }
        
        if(checkoutTotal == 0.00){
            isZeroBalance = true;
            creditCardBlockStyle = 'display:none;';
        }
        else{
            isZeroBalance = false;
        }
    }
    
    //Method to redirect user back to Programs and Events page
    public PageReference redirectBack(){
        PageReference objPage = new PageReference('/TFT_ProgramsAndEvents');
        objPage.getParameters().put('website',website);
        return objPage;
    }
    
}