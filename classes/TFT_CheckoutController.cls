/**
* Appirio (c) - 2017
*
* Modified By         Modified Date       Reason
* Alexander Miller      3.15.2017        00190837
* Jessica Schilling     6.8.2017         00197495   Added Engagement Type information
* Dimpesh K Gehlot		7.17.2017		 T-617693	commented code to change object model
* Dimpesh K Gehlot		7.18.2017		 T-617694	uncommented code and changed Cart__c to Cart_Item__c
* Dimpesh K Gehlot 		24.7.2017 		 I-285348   unable to load contact info page
*/

//*********************************Edit History************************************************
//Edited by Mark Mafilios 10/26/2016
//Lines #42,#47,#48    
//*********************************************************************************************/

public class TFT_CheckoutController {
    
    //Variables for session details section
    public Decimal sessionTotal                                                         {get; set;}
    public Decimal cartDiscounts                                                        {get; set;}
    public String website                                                               {get; set;}
    public String listingSessionIdToDelete                                              {get; set;}  
    // DG T-617694 changed Cart__c to Cart_Item__c
    public List<Cart_Item__c> objCartList                                               {get; set;}
    public List<Listing_Session__c> objListingSessionList                               {get; set;}
    public List<Session_Registration__c> objSessionRegistrationList                     {get; set;}
    
    //Variables for Contact Info section
    public Map<String, String> objListingSessionIdWithContactId                         {get; set;}
    public Map<String, List<TFT_CheckoutControllerWrapper>> objContactIdWithWrapperList {get; set;} 
    public List<Contact> lstContact                                                     {get; set;}
    //Added below 2 lines JSCHILLING 00197495 6/08/2017 Added Engagement Type information
    public Map<Id, Engagement_Type__c> contactToEngagementGrade                         {get; set;}
    public List<Engagement_Type__c> engagementTypeUpdate                                {get; set;}
    
    //Variables for Participant Questions section
    public Map<Id,List<String>> mapContactIdToLstOfLables                               {get; set;}
    public Map<String, List<Question_Response__c>> mapLabelsToQestionAnswer             {get; set;} 
    public Map<Id, List<SelectOption>> mapQAIdToPicklistValues                          {get; set;}
    public Map<Id, List<SelectOption>> mapQAIdToSelectedPicklistValues                  {get; set;} 
    public Id quesitonID                                                                {get; set;}
    public String questionPAnswers                                                      {get; set;}
    public List<Contact> lstContactQuestion                                             {get; set;}
    
    //Variables for Financial Aid section
    public Boolean isFinAidPannel                                                       {get; set;}
    public Boolean isListSessPannel                                                     {get; set;}
    public Boolean isErrorMessage                                                       {get; set;}
    public Boolean isFinAidNo                                                           {get; set;}
    public Boolean isFinAidYes                                                          {get; set;}
    public Financial_Aid__c objFinancialAid                                             {get; set;}
    public List<Contact> lstContactFinAid                                               {get; set;} 
    public Map<Id, List<Session_Registration__c>> mapConIdToSessionReg                  {get; set;} 
    
    //Variables for Waviers section
    public List<Contact> lstContactWavier                                               {get; set;}
    public Map<Id,List<String>> mapContactIdToLstListingSessions                        {get; set;}
    public Map<String, List<Waiver_Authorization__c>> mapListingSessionToWaiver         {get; set;}
    
    //Variables for Confirmation section
    public String cardId                                                                {get; set;}
    
    //Variables for rendering different sections
    public Boolean loadSession                                                          {get; set;}
    public Boolean loadContactInfo                                                      {get; set;}
    public Boolean loadPartQuestion                                                     {get; set;}
    public Boolean loadFinancialAid                                                     {get; set;}
    public Boolean loadWaviers                                                          {get; set;}
    public Boolean loadSummary                                                          {get; set;}
    public Boolean loadConfirmation                                                     {get; set;}
    //Custom Settings instance
    public CustomMessages__c customMsgs                                                 {get; set;}
    
    //Variable to be used on page to show number of session added to cart.
    public Integer sessionCart                                                          {get; set;} 
    
    private User loggedInUser;// will hold details of logged in user.
    Map<Id, Question_Response__c> mapQuestionResponses = new Map<Id, Question_Response__c>();   
    public List<Waiver_Authorization__c> waiverList;
     public boolean chapterOfferMembership{get;set;}
    
    //constructor
    public TFT_CheckoutController() {
        //Getting the Custom Setting instance
        customMsgs = CustomMessages__c.getInstance();
        lstContactQuestion = new List<Contact>();
        //Variable Initializations
        // DG T-617694 
        objCartList = new List<Cart_Item__c>();
        
        website = ApexPages.currentPage().getParameters().get('website');
        User userObj;
         for(User u : [SELECT Id, ChapterID__c FROM User WHERE Id = :UserInfo.getUserId() limit 1]){
             userObj = u;
        }
        if(userObj != null){
            if(userObj.ChapterID__c != null && userObj.ChapterID__c != ''){
               for(Account acc : [SELECT Id, Website, Membership_Offered__c FROM Account WHERE Id = :userObj.ChapterID__c limit 1]){
                    chapterOfferMembership = acc.Membership_Offered__c;
                   if(acc.Website != null && acc.Website != ''){
                       website = acc.Website.removeStartIgnoreCase('https://');
                   }
               }
           }
        }
        if(website != null && website != ''){
            //Setting variables for rendering the Cart Session section
            backToSession();
            
            //Fetching Participants with their sessions.
            fetchParticipantsWithSessions();
            
            sessionCart = TFT_CartItems.count(UserInfo.getUserId());
         }
        
    }
 
    
    ///Session page///
    
    //Method for fetching the Participants with their sessions
    public Void fetchParticipantsWithSessions() {
        
        //Variable Initializations
        Set<Id> sessionRegistrationIds = new Set<Id>();
        Set<Id> listingSessionsIds = new Set<Id>();
        Map<String, double> objContactWithCartDiscount = new Map<String, double>();
        Map<String, double> objContactWithCartMembershipPrice = new Map<String, double>();
        Map<String, double> objContactWithCartActualPrice = new Map<String, double>();
        objContactIdWithWrapperList = new Map<String, List<TFT_CheckoutControllerWrapper>>();
        objSessionRegistrationList = new List<Session_Registration__c>();
        objListingSessionList = new List<Listing_Session__c>();
        objListingSessionIdWithContactId = new Map<String, String> (); 
        
        objCartList = [SELECT Id, Name,Membership_Registration__c, Session_Registration__r.Id, Discount__c, 
                       // changed Membership_Price__c to Item_Price__c
                       Item_Price__c, Actual_Price__c, Session_Registration__r.Contact__r.Id,
                              Session_Registration__r.Contact__r.Name
                       // DG T-617694
                       FROM Cart_Item__c
                       WHERE Session_Registration__r.Status__c = 'In Process'
                       // DG T-617694
                       AND Cart_Item__c.CreatedByID =: UserInfo.getUserId() 
                       ORDER BY Session_Registration__r.Contact__r.Name, Session_Registration__c];
        
        sessionTotal = 0.00;
        cartDiscounts = 0.00;
        
        if(objCartList.size() > 0) {
            // DG T-617694
            for(Cart_Item__c cart: objCartList) {
                //Session Total Count
                if(cart.Actual_Price__c != null) {
                    sessionTotal = sessionTotal + cart.Actual_Price__c;
                }
                //Cart Discount Total
                if(cart.Discount__c != null) {
                    cartDiscounts = cartDiscounts + cart.Discount__c;
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
        
        if(sessionRegistrationIds.size() > 0) {
            objSessionRegistrationList = [SELECT Id, Name, Listing_Session__r.Listing_Session_Location_Name__c,
                                                 Listing_Session__r.Primary_Program_Level_Restriction__c, 
                                                 Listing_Session__r.Secondary_Program_Level_Restriction__c, 
                                                 Listing_Session__r.Session_Start_Date_Time__c,
                                                 Listing_Session__r.Session_End_Date_Time__c,
                                                 Listing_Session__r.Actual_Price__c, 
                                                 Listing_Session__r.Base_Price__c, 
                                                 Contact__r.Name, Listing_Session__r.Id, Contact__c
                                          FROM Session_Registration__c
                                          WHERE Id In: sessionRegistrationIds];
            
            Set<Id> setContactIdsOnSessionReg = new Set<Id>();
                                        
            if(objSessionRegistrationList.size() > 0) {
                for(Session_Registration__c sessionRegistration: objSessionRegistrationList) {
                    listingSessionsIds.add(sessionRegistration.Listing_Session__r.Id);
                    setContactIdsOnSessionReg.add(sessionRegistration.Contact__c);
                }
                
                Map<Id, Listing_Session__c> listingSessionMap = new Map<Id, Listing_Session__c>(
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
                
                for(Session_Registration__c sessionRegistration: objSessionRegistrationList){
                    objListingSessionIdWithContactId.put(sessionRegistration.Listing_Session__r.Id,sessionRegistration.Contact__r.Name);
                    objContactIdWithWrapperList.put(sessionRegistration.Contact__r.Name+sessionRegistration.Id, new List<TFT_CheckoutControllerWrapper>());
                    Listing_Session__c listingSession = listingSessionMap.get(sessionRegistration.Listing_Session__r.Id);
               
                    objContactIdWithWrapperList.get(sessionRegistration.Contact__r.Name+sessionRegistration.Id).add(new TFT_CheckoutControllerWrapper(sessionRegistration.Contact__r.Name, 
                                                                                                       listingSession, 
                                                                                                       objContactWithCartActualPrice.get(sessionRegistration.Contact__r.Name+sessionRegistration.Id),
                                                                                                       objContactWithCartDiscount.get(sessionRegistration.Contact__r.Name+sessionRegistration.Id),
                                                                                                       sessionRegistration.Id,objContactWithCartMembershipPrice.get(sessionRegistration.Contact__r.Name+sessionRegistration.Id)));
                }
            }  
        }
    }
    
    //Method for removing the session registrations and their corresponding cart records when user clicks delete button for registered sessions
    public void removeSessionRegistration() {
        
        if(listingSessionIdToDelete != '' && listingSessionIdToDelete != null) {
            List<Session_Registration__c> objSessionRegRecToDelete = new List<Session_Registration__c>();
            if(objSessionRegistrationList.size() > 0) {
                for(Session_Registration__c sr : objSessionRegistrationList){
                    if(listingSessionIdToDelete == sr.Id){
                        objSessionRegRecToDelete.add(sr);                        
                    }
                }  
            }
            
            if(objSessionRegRecToDelete.size() > 0) {
				// DG T-617694                 
                List<Cart_Item__c> objCartRecToDelete = new List<Cart_Item__c>();
                for(Cart_Item__c car : objCartList){
                    for(Session_Registration__c sessionReg: objSessionRegRecToDelete){ 
                        if(sessionReg.Id == car.Session_Registration__r.Id){
                            objCartRecToDelete.add(car);                        
                        }
                    }
                } 
                if(objCartRecToDelete.size() > 0){
                    if(objCartRecToDelete[0].Membership_Registration__c != null){
						// DG T-617694                 
                        Cart_Item__c anotherCartToUpdateWithMembership;
                        for(Cart_Item__c c : [SELECT Id FROM Cart_Item__c WHERE Membership_Registration__c = null AND Payment_Information__c = null AND Session_Registration__c != null AND Session_Registration__r.Listing_Session__r.Membership_Required__c = true AND  Session_Registration__r.Contact__c = :objCartRecToDelete[0].Session_Registration__r.Contact__r.Id]){
                            anotherCartToUpdateWithMembership = c;
                        }
                     if(anotherCartToUpdateWithMembership != null){
                             anotherCartToUpdateWithMembership.Membership_Registration__c = objCartRecToDelete[0].Membership_Registration__c;
                             anotherCartToUpdateWithMembership.Apply_Membership_Amount__c = true;
                             update anotherCartToUpdateWithMembership;
                     }else{
                         Membership_Registration__c oBjToDel = new Membership_Registration__c(Id=objCartRecToDelete[0].Membership_Registration__c);
                         delete oBjToDel;
                     }
                    }
                }
                if(objCartRecToDelete.size() > 0) {
                    Delete objCartRecToDelete;
                }
                delete objSessionRegRecToDelete;
            }
        }
        // DG T-617694                         
        objCartList = new List<Cart_Item__c>();
        //Re-fetching Participants with their sessions after delete
        fetchParticipantsWithSessions();
        sessionCart = TFT_CartItems.count(UserInfo.getUserId());
    }
    
    ///Session Page///
    
    
    ///Contact Info page///
    
    //Method to fetch participant/contact record details and display on page
    public void fecthContact()
    {
        lstContact = new List<Contact>();
        //Added below 2 lines JSCHILLING 00197495 6/08/2017 Added Engagement Type information
        contactToEngagementGrade = new Map<Id, Engagement_Type__c>();
        engagementTypeUpdate = new List<Engagement_Type__c>();

        Set<Id> setContactId = new Set<Id>();
        
        for(Session_Registration__c objSR : objSessionRegistrationList) 
        {
            setContactId.add(objSR.Contact__c);
        }
        
        for(Contact objContact: [SELECT Id, Name, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                        HomePhone, MobilePhone, Email, Emergency_Contact_Name__c, Emergency_Contact_Number__c, 
                                        Emergency_Contact_Email__c, Birthdate, Grade__c, Gender__c, Ethnicity__c, Allergies__c, 
                                        Disabilities__c, Dietary_Restrictions__c, Nickname__c, Relationship_To_Participants__c,
                                        //Added below 1 line JSCHILLING 00197495 6/08/2017 Added Engagement Type information
                                        (SELECT Id, Grade_Level__c FROM Engagement_Type__r ORDER BY CreatedDate ASC)
                                   FROM Contact
                                  WHERE Id IN : setContactId])
        {
            //START JSCHILLING 00197495 6/08/2017
            //Added Engagement Type information
            List<Engagement_Type__c> listEngagementType = new List<Engagement_Type__c>();
            
            for(Engagement_Type__c engage: objContact.Engagement_Type__r){
                listEngagementType.add(engage);
            }
            if(listEngagementType != null && listEngagementType.size() > 0){
                contactToEngagementGrade.put(objContact.Id, listEngagementType[0]);
                engagementTypeUpdate.add(listEngagementType[0]);
            }
            else{
            	// DG 7/24/2017 I-285348 when no engagement_Type__c is related to contact
                contactToEngagementGrade.put(objContact.Id, new Engagement_Type__c(Contact__c = objContact.Id));  
            }
            System.debug('### Map values: ' + contactToEngagementGrade);
            //END JSCHILLING 00197495 6/08/2017
            lstContact.add(objContact);
        }
        
        //Setting variables for rendering the Contact Info section
        backToContactInfo();
    }
    
    //Method to update contact records
    public void updateContact()
    {
        //Updating the contacts list
        update lstContact;
        //Added below 1 line JSCHILLING 00197495 6/08/2017 Added Engagement Type information
        update engagementTypeUpdate;
     
        //Setting variables for rendering the Participant Questions section
        backToPartQuestion();
        
        //Initializinga and fetching the Participant Questions section details
        mapContactIdToLstOfLables = new Map<Id,List<String>>();
        displayRecords();
    }
    
    //Method called on back button of Contact Info section to render the Session section back
    public void backToSession(){
        loadSession = true;
        loadContactInfo = false;
        loadPartQuestion = false;
        loadFinancialAid = false;
        loadWaviers = false;
        loadSummary = false;
        loadConfirmation = false;
    }
    
    ///Contact Info page///
    
    
    ///Participant Question Page///
    
    //Method to display QuestionAnswers records grouped by Contacts
    public void displayRecords() {
        Set<Id> setContact = new set<Id>();
        lstContactQuestion = new List<Contact>();
        Set<Id> setQuestionIds = new set<Id>();
        Map<Id, List<String>> mapQuestionIdToListAnswers = new Map<Id, List<String>>();
        List<Question_Response__c> lstQuestionResponses = new List<Question_Response__c>(); 
        mapLabelsToQestionAnswer = new Map<String, List<Question_Response__c>>();
        mapQAIdToPicklistValues = new Map<Id, List<SelectOption>>();
        mapQAIdToSelectedPicklistValues = new Map<Id, List<SelectOption>>();
        for(Session_Registration__c objSR : [SELECT Name, Listing_Session__c, Listing_Session__r.Name, Contact__c,
                                                    (   SELECT Name, Listing_Questions__r.Question__c, Listing_Questions__r.Question__r.Question_Type__c, 
                                                        Listing_Questions__r.Listing_Session__r.Name, Contact_Response__c, Session_Registration__r.Name,
                                                        Listing_Questions__r.Question__r.Question__c, Customer_Response_For_Date__c
                                                        FROM Question_Responses__r
                                                    )
                                                FROM Session_Registration__c 
                                                WHERE Status__c = 'In Process' 
                                                AND CreatedById =: UserInfo.getUserId()
                                            ]) {
            if(!objSR.Question_Responses__r.isEmpty()) {
                
                setContact.add(objSR.Contact__c);
                
                if(mapContactIdToLstOfLables.containsKey(objSR.Contact__c)) {
                    mapContactIdToLstOfLables.get(objSR.Contact__c).add(objSR.Name+' - '+objSR.Listing_Session__r.Name);
                }
                else{
                    mapContactIdToLstOfLables.put(objSR.Contact__c,new List<String>{objSR.Name+' - '+objSR.Listing_Session__r.Name});
                }
                for(Question_Response__c objQA : objSR.Question_Responses__r) {                
                    setQuestionIds.add(objQA.Listing_Questions__r.Question__c);
                    lstQuestionResponses.add(objQA);                 
                    if(!mapLabelsToQestionAnswer.containsKey(objQA.Session_Registration__r.Name+' - '+objQA.Listing_Questions__r.Listing_Session__r.Name)) {
                        mapLabelsToQestionAnswer.put(objQA.Session_Registration__r.Name+' - '+objQA.Listing_Questions__r.Listing_Session__r.Name,new List<Question_Response__c>{objQA});
                    }
                    else{
                         mapLabelsToQestionAnswer.get(objQA.Session_Registration__r.Name+' - '+objQA.Listing_Questions__r.Listing_Session__r.Name).add(objQA);
                    }
                }
            }
        }      
        
        if(!setQuestionIds.isEmpty()) {
            for(Question__c objQuestion : [ SELECT Id,
                                            (   SELECT Answer_Options__c, Order_Index__c
                                                FROM Answers__r Order By Order_Index__c ASC
                                            )
                                            FROM Question__c
                                            WHERE Id = :setQuestionIds
                                            ]) {
                
                for(Answer__c objAns : objQuestion.Answers__r) {
                    if(mapQuestionIdToListAnswers.containsKey(objQuestion.Id))
                        mapQuestionIdToListAnswers.get(objQuestion.Id).add(objAns.Answer_Options__c);
                    else
                        mapQuestionIdToListAnswers.put(objQuestion.Id, new List<String>{objAns.Answer_Options__c});
                }
            }
            for(Question_Response__c objQA : lstQuestionResponses) {
                mapQAIdToPicklistValues.put(objQA.Id, new List<SelectOption>());
                mapQAIdToSelectedPicklistValues.put(objQA.Id, new List<SelectOption>());
                if(objQA.Listing_Questions__r.Question__r.Question_Type__c == 'Picklist' && mapQuestionIdToListAnswers.containsKey(objQA.Listing_Questions__r.Question__c)) {
                    List<SelectOption> selectOptionsList = new List<SelectOption>();
                    for(String strPicklistValues : mapQuestionIdToListAnswers.get(objQA.Listing_Questions__r.Question__c)) {
                        selectOptionsList.add(new SelectOption(strPicklistValues, strPicklistValues));
                    }               
                    mapQAIdToPicklistValues.put(objQA.Id, selectOptionsList);    
                } else if(objQA.Listing_Questions__r.Question__r.Question_Type__c == 'Checkbox' && mapQuestionIdToListAnswers.containsKey(objQA.Listing_Questions__r.Question__c)) {
                    List<SelectOption> selectOptionsList = new List<SelectOption>();
                    for(String strPicklistValues : mapQuestionIdToListAnswers.get(objQA.Listing_Questions__r.Question__c)) {
                        selectOptionsList.add(new SelectOption(strPicklistValues, strPicklistValues));
                    }
                    mapQAIdToPicklistValues.put(objQA.Id, selectOptionsList);
                } 
                else if(objQA.Listing_Questions__r.Question__r.Question_Type__c == 'Multi-Select Picklist' && mapQuestionIdToListAnswers.containsKey(objQA.Listing_Questions__r.Question__c)) {
                    Set<String> setStrSelectedAns = new Set<String>();
                    if(objQA.Contact_Response__c != null) { 
                        for(String strAns : objQA.Contact_Response__c.split(';')) { 
                            setStrSelectedAns.add(strAns);
                        }
                    }
                    
                    List<SelectOption> selectOptionsList = new List<SelectOption>();
                    List<SelectOption> selectedOptionsList = new List<SelectOption>();
    
                    for(String strPicklistValues : mapQuestionIdToListAnswers.get(objQA.Listing_Questions__r.Question__c)) {
                        if(!setStrSelectedAns.contains(strPicklistValues)) 
                            selectOptionsList.add(new SelectOption(strPicklistValues, strPicklistValues));
                        else
                            selectedOptionsList.add(new SelectOption(strPicklistValues, strPicklistValues));
                    }
                    
                    mapQAIdToPicklistValues.put(objQA.Id, selectOptionsList);
                    mapQAIdToSelectedPicklistValues.put(objQA.Id, selectedOptionsList);
                } 
            }
        }
    
        for(Contact objContat : [Select Id,Name From Contact Where Id IN: setContact]) {
            lstContactQuestion.add(objContat);
        }
        
    }
    
    //Method for getting the picklist values for questions
    public void recordPicklist() {
        if(mapQAIdToPicklistValues.containsKey(quesitonID)) {  
            Set<String> setStrAns = new Set<String>();
            List<SelectOption> selectedOptionsList = new List<SelectOption>();
            for(String strAns : questionPAnswers.split(';')) {
                setStrAns.add(strAns);
                selectedOptionsList.add(new SelectOption(strAns, strAns));
            }
            mapQAIdToSelectedPicklistValues.put(quesitonID, selectedOptionsList);
            List<SelectOption> selectOptionsList = new List<SelectOption>();
            for(SelectOption objSelOptn : mapQAIdToPicklistValues.get(quesitonID)) {
                if(!setStrAns.contains(objSelOptn.getValue())) {
                    selectOptionsList.add(objSelOptn);
                }
            }
            mapQAIdToPicklistValues.put(quesitonID, selectOptionsList);
        }
    }
    
    //Method for getting only the selected picklist values for questions
    public void removePicklist() { 

        if(mapQAIdToPicklistValues.containsKey(quesitonID)) {     
            Set<String> setStrAns = new Set<String>();
            List<SelectOption> selectedOptionsList = new List<SelectOption>();
          
            for(String strAns : questionPAnswers.split(';')) {
                setStrAns.add(strAns);
                selectedOptionsList.add(new SelectOption(strAns, strAns));
            }
            
            mapQAIdToPicklistValues.put(quesitonID, selectedOptionsList);
            List<SelectOption> selectOptionsList = new List<SelectOption>();
        
            for(SelectOption objSelOptn : mapQAIdToSelectedPicklistValues.get(quesitonID)) {
                if(!setStrAns.contains(objSelOptn.getValue())) {
                    selectOptionsList.add(objSelOptn);
                }
            }
            
            mapQAIdToSelectedPicklistValues.put(quesitonID, selectOptionsList);
        }
    }
    
    //Method to save Question Answer records based on page values provided by User
    public void saveQA() {
        Boolean isError = False;
        List<Question_Response__c> lstQAToUpdate = New List<Question_Response__c>();
        for(List<Question_Response__c> lstQA: mapLabelsToQestionAnswer.values()) {
            for(Question_Response__c objQA : lstQA) {
                if(objQA.Listing_Questions__r.Question__r.Question_Type__c == 'Text') { 
                    if(objQA.Contact_Response__c == Null) {
                        objQA.Contact_Response__c.addError(customMsgs.Required_Questions_Check__c);
                        isError = True;
                    } else 
                        lstQAToUpdate.add(objQA);
                } 
                if(objQA.Listing_Questions__r.Question__r.Question_Type__c == 'Date') { 
                    if(objQA.Customer_Response_For_Date__c == Null) {
                        objQA.Customer_Response_For_Date__c.addError(customMsgs.Required_Questions_Check__c);
                        isError = True;
                    } else {      
                        objQA.Contact_Response__c = objQA.Customer_Response_For_Date__c.format();
                        lstQAToUpdate.add(objQA);
                        
                    }
                }
                if(objQA.Listing_Questions__r.Question__r.Question_Type__c == 'Numeric') { 
                    if(objQA.Contact_Response__c == Null) {
                        objQA.Contact_Response__c.addError(customMsgs.Required_Questions_Check__c);
                        isError = True;
                    }else 
                        lstQAToUpdate.add(objQA);
                }
                if(objQA.Listing_Questions__r.Question__r.Question_Type__c == 'Checkbox') { 
                    if(objQA.Contact_Response__c != Null)
                        lstQAToUpdate.add(objQA);
                }
                if(objQA.Listing_Questions__r.Question__r.Question_Type__c == 'Picklist') { 
                    if(objQA.Contact_Response__c == Null) {
                        objQA.Contact_Response__c.addError(customMsgs.Required_Questions_Check__c);
                        isError = True;
                    } else 
                        lstQAToUpdate.add(objQA);
                }
                if(objQA.Listing_Questions__r.Question__r.Question_Type__c == 'Multi-Select Picklist') { 
                   
                    if(mapQAIdToSelectedPicklistValues.containsKey(objQA.Id)) {
                        String strMultiPicklistAns = '';
                        Integer noOfAnswers = mapQAIdToSelectedPicklistValues.get(objQA.Id).size();
                        Integer counter = 0;
                        
                        for(SelectOption objSelOptn : mapQAIdToSelectedPicklistValues.get(objQA.Id)) {
                            counter += 1;                         
                            strMultiPicklistAns += objSelOptn.getValue();
                            if(counter != noOfAnswers)
                                strMultiPicklistAns += ';';
                        }
                        
                        objQA.Contact_Response__c = strMultiPicklistAns;
                        
                        lstQAToUpdate.add(objQA);
                    }
                }
            }     
        }

        if(!isError){ 
            //Updating Question Answers
            if(!lstQAToUpdate.isEmpty())
                update lstQAToUpdate;
          
            //Setting variables for rendering the Financial Aid section
            backToFinancialAid();
        
            //Initializing and Fetching the Financial Aid section details
            displayFinAidRecords(); 

        }
    }
    
    //Method called on back button of Participant Questions section to render the Contact Info section back
    public void backToContactInfo(){
        loadSession = false;
        loadContactInfo = true;
        loadPartQuestion = false;
        loadFinancialAid = false;
        loadWaviers = false; 
        loadSummary = false;
        loadConfirmation = false;
    }
    
    ///Participant Question Page///
    
    
    ///Financial Aid Page///
    
    //Method to fetch Session Registration records and display on Financial Aid page
    public void displayFinAidRecords(){
        
        //Initializing Variables
        isErrorMessage = false;
        isFinAidNo = true; 
        isFinAidYes = false;
        isFinAidPannel = true;
        isListSessPannel = false;
        lstContactFinAid = new List<Contact>();
        objFinancialAid = new Financial_Aid__c();
        mapConIdToSessionReg = new Map<Id, List<Session_Registration__c>>();
        Set<Id> setListSessionId = new Set<Id>();
        
        for(Session_Registration__c objSR : [SELECT Id, Name, Listing_Session__c, Listing_Session__r.Name, 
                                                    Contact__c, Contact__r.Name, Financial_Aid_Applied__c
                                               FROM Session_Registration__c 
                                              WHERE Status__c = 'In Process'
                                                AND Financial_Aid_Applied__c = false
                                                AND CreatedById =: UserInfo.getUserId()]) 
        {
            if(!setListSessionId.contains(objSR.Listing_Session__c)) {
                setListSessionId.add(objSR.Listing_Session__c);
            }
                
            if(!mapConIdToSessionReg.containskey(objSR.Contact__c))
            {
                mapConIdToSessionReg.put(objSR.Contact__c, new List<Session_Registration__c>{objSR});
            }
            else
            {
                mapConIdToSessionReg.get(objSR.Contact__c).add(objSR);
            }
        }
        
        for(Contact objContat : [SELECT Id, Name FROM Contact WHERE Id IN: mapConIdToSessionReg.keyset()]) 
        {
            lstContactFinAid.add(objContat);
        }
    }
    
    //Method to set Financial Aid variables
    public void setFinancialAidNo()
    {
        isFinAidNo = true;
        isFinAidYes = false;
    }
    
    //Method to set Financial Aid variables
    public void setFinancialAidYes()
    {
        isFinAidNo = false;
        isFinAidYes = true;
    }
    
    //Method to render output pannel, return page, update and insert records
    public pagereference checkFinancialAidValue()
    {
        isErrorMessage = false;
        
        if(!isFinAidNo && isFinAidYes && isFinAidPannel && !isListSessPannel)
        {
            if(objFinancialAid.What_is_your_household_income__c != Null && objFinancialAid.How_many_people_are_in_your_household__c != Null &&
               objFinancialAid.Are_you_receiving_free_or_reduced_lunch__c != Null &&
               objFinancialAid.Are_you_experiencing_a_finan_hardship__c != Null && objFinancialAid.How_much_are_you_able_to_pay_if_any__c != Null)
            {
                isFinAidPannel = false;
                isListSessPannel = true;
            }
            else
            {
                isFinAidPannel = true;
                isListSessPannel = false;
                isErrorMessage = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,customMsgs.Required_Questions_Check__c));
            }
            return null;
        }
        else if(!isFinAidPannel && isListSessPannel)
        {
            List<Financial_Aid__c> lstFinancialAidToInsert = new List<Financial_Aid__c>();
            List<Session_Registration__c> lstSessionRegToUpdate = new List<Session_Registration__c>();
            
            for(List<Session_Registration__c> lstSR : mapConIdToSessionReg.values())
            {
                for(Session_Registration__c objSR : lstSR)
                {
                    if(objSR.Financial_Aid_Applied__c)
                    {
                        lstSessionRegToUpdate.add(objSR);
                        lstFinancialAidToInsert.add(new Financial_Aid__c(Contact__c = objSR.Contact__c,
                                                                         Session_Registration__c = objSR.Id,
                                                                         What_is_your_household_income__c = objFinancialAid.What_is_your_household_income__c,
                                                                         How_much_are_you_able_to_pay_if_any__c = objFinancialAid.How_much_are_you_able_to_pay_if_any__c,
                                                                         How_many_people_are_in_your_household__c = objFinancialAid.How_many_people_are_in_your_household__c,
                                                                         Are_you_experiencing_a_finan_hardship__c = objFinancialAid.Are_you_experiencing_a_finan_hardship__c,
                                                                         Are_you_receiving_free_or_reduced_lunch__c = objFinancialAid.Are_you_receiving_free_or_reduced_lunch__c)
                                                                         );
                    }
                }
            }
            
            try
            {   
                if(!lstSessionRegToUpdate.isEmpty()) {
                    Database.update(lstSessionRegToUpdate, true);
                    
                    if(!lstFinancialAidToInsert.isEmpty())
                        Database.insert(lstFinancialAidToInsert, true);
                    } else {
                        isErrorMessage = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,customMsgs.Financial_Aid_Sessions_Message__c));
                        return null;
                    }
               
                //Initializing and fetching details for Waviers section
                lstContactWavier = new List<Contact>();
                mapContactIdToLstListingSessions = new Map<Id,List<String>>();
                mapListingSessionToWaiver = new Map<String, List<Waiver_Authorization__c>>();
                displayWavierRecords();
                
                //Setting rendering variables to render the Waviers section
                backToWaviers();
                
                return null;
            }
            catch(Exception ex)
            {
                isErrorMessage = true;
                
                if(ex.getMessage().contains('membership'))
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,customMsgs.AddActiveMembership__c));
                }
                else if(ex.getMessage().contains('age restriction'))
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,customMsgs.AgeRestrictionError__c));
                }
                else if(ex.getMessage().contains('gender restriction'))
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,customMsgs.Gender_Restriction_Error__c));
                }
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                }
                return null;
            }
        }
        else
        {
            //Initializing and fetching details for Waviers section
            lstContactWavier = new List<Contact>();
            mapContactIdToLstListingSessions = new Map<Id,List<String>>();
            mapListingSessionToWaiver = new Map<String, List<Waiver_Authorization__c>>();
            displayWavierRecords();
            
            //Setting rendering variables to render the Waviers section
            backToWaviers();
            
            return null;
        }
    }
    
    //Method called on back button of Financial Aid section to render the Participant Questions section back
    public void backToPartQuestion(){
        loadSession = false;
        loadContactInfo = false;
        loadPartQuestion = true;
        loadFinancialAid = false;
        loadWaviers = false;
        loadSummary = false;
        loadConfirmation = false;
    }
    ///Financial Aid Page///
    
    
    ///Waviers Page///
    
    //Method to display Waiver records grouped by Contacts
    public void displayWavierRecords() {
        Set<Id> setContact = new set<Id>();
        Map<Id,Id> mapSRIdToLSId = new Map<Id,Id>();
        lstContactWavier = new List<Contact>();
        mapContactIdToLstListingSessions = new Map<Id,List<String>>();
        mapListingSessionToWaiver = new Map<String, List<Waiver_Authorization__c>>();
        waiverList = new List<Waiver_Authorization__c>();
        Integer counter = 0;
       
        for(Session_Registration__c objSR : [SELECT Id, Name, Listing_Session__c, Listing_Session__r.Name, Contact__c, 
                                                    (SELECT Id, Session_Registration__c, Session_Registration__r.Listing_Session__r.Name, 
                                                            Selected_Waivers__r.Waivers__r.Waiver_Language__c, Waiver_Signed__c 
                                                       FROM Waiver_Authorizations__r)
                                               FROM Session_Registration__c 
                                              WHERE Status__c = 'In Process' 
                                                AND CreatedById =: UserInfo.getUserId()]) {
            
            if(objSR.Waiver_Authorizations__r.Size() > 0) {
                counter++;
                setContact.add(objSR.Contact__c);
                if(mapContactIdToLstListingSessions.containsKey(objSR.Contact__c)) {
                    mapContactIdToLstListingSessions.get(objSR.Contact__c).add(objSR.Listing_Session__r.Name);
                } else {
                    mapContactIdToLstListingSessions.put(objSR.Contact__c,new List<String>{objSR.Listing_Session__r.Name});
                }
                
                for(Waiver_Authorization__c objWA : objSR.Waiver_Authorizations__r) {
                    String key = objSR.Contact__c + '' + objSR.Listing_Session__r.Name;
                    if(!mapListingSessionToWaiver.containsKey(key)) { 
                        mapListingSessionToWaiver.put(key,new List<Waiver_Authorization__c>{objWA}); 
                    } else {
                         mapListingSessionToWaiver.get(key).add(objWA); 
                    }
                    
                    waiverList.add(objWA);
                }
            }
        }
       
        if(counter == 0)
            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO, customMsgs.No_Waivers_Requirement_Message__c));
       
        for(Contact objContat : [Select Id,Name From Contact Where Id IN: setContact]) {
            lstContactWavier.add(objContat);
        } 
    } 
    
    // Method to Update Waivers Authorization record based on user input in Page
    public void saveWaiver() {
        List<Waiver_Authorization__c> lstWAToUpdate = new List<Waiver_Authorization__c>();
        for(Waiver_Authorization__c objWA : waiverList){
            objWA.Waiver_Signed__c=true;
            lstWAToUpdate.add(objWA);
        }
       
        if(!lstWAToUpdate.isEmpty()) { update lstWAToUpdate; }
            
        //Setting rendering variables to render the Summary section
        backToSummary();
    }
    
    //Method called on back button of Waviers section to render the Financial Aid section back
    public void backToFinancialAid(){
        loadSession = false;
        loadContactInfo = false;
        loadPartQuestion = false;
        loadFinancialAid = true;
        loadWaviers = false;
        loadSummary = false;
        loadConfirmation = false;
    }  
    
    ///Waviers Page///
    
    
    ///Summary Page///
    
    //Method called on back button of Summary section to render the Waviers section back
    public void backToWaviers(){
        loadSession = false;
        loadContactInfo = false;
        loadPartQuestion = false;
        loadFinancialAid = false;
        loadWaviers = true;
        loadSummary = false;
        loadConfirmation = false;
    } 
    
    ///Summary Page///
    
    ///Confirmation Page///
    
    //Method called on back button of Confirmation section to render the Summary section back
    public void backToSummary(){
        loadSession = false;
        loadContactInfo = false;
        loadPartQuestion = false;
        loadFinancialAid = false;
        loadWaviers = false;
        loadSummary = true;
        loadConfirmation = false;
    } 

    //Method called on top navigation button of Confirmation section to render the Confirmation section back    
    public void loadConfirmationPage(){
        loadSession = false;
        loadContactInfo = false;
        loadPartQuestion = false;
        loadFinancialAid = false;
        loadWaviers = false;
        loadSummary = false;
        loadConfirmation = true;
        sessionCart = TFT_CartItems.count(UserInfo.getUserId());
    }
    
    ///Confirmation Page///
}