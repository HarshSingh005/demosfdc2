/*********************************************************************************************************************************
* Appirio, Inc
* Name         : ManageAccountContactsController
* Created By   : Rohit B. (Appirio)
* Purpose      : Extension class of ManageAccountContacts
* Created Date : 10/Feb/2016
*
* Date Modified                Modified By             Description of the update
------------------------------------------------------------------------------------------------------------------------------------
* 16 Dec 2016                  Ravi Chauhan            I-247759 | changes to fix the issue
* 20 Dec 2016                  Ravi Chauhan            I-248674 | recordType aasinment based on parameter in URL
* 10 Jan 2017				   Suminder Singh		   I-243432 | MOdified for Lead check box on VF page 
* 11 Jan 2017				   Suminder Singh		   I-243432 | MOdified for Lead check box on VF page
* 31 Jan 2017				   Suminder Singh		   I-256024 | MOdified for Lead check box error on VF page
* 20 Feb 2017                  Ravi Chauhan            I-258868 | Change in mapping as per I-258868
* 16 Mar 2017                  Ravi Chauhan            I-260605 | Change to map the type, subtype and industry fields for Or Account
************************************************************************************************************************************/
public with sharing class ManageAccountContactsController {
    ApexPages.StandardController cStdCon;
    public Account acc {get; set;}
    public Integer noOfContacts {get; set;}
    public Boolean isRecordTypeError {get; set;}
    public Boolean isDisabledHideExistingContacts {get; set;}
    public Boolean isHideExistingContacts {get; set;}
    public Boolean isEnableConstituentTypes {get; set;}
    public String addressSectionName {get; set;}
    public Boolean showAccountName {get; set;}
    public String recordTypeIdHousehold {get; set;}
    public String recordTypeIdOrganizational {get; set;}
    public final String SINGLE_CONSTITUENT_WARNING_MESSAGE {get; set;} 
    public final String MULTIPLE_CONSTITUENT_WARNING_MESSAGE {get; set;} 
    public List<String> AccountFields {get; set;}
    public List<String> ContactFields {get; set;}
    public Map<String, Boolean> accountRequiredFieldMap {get; set;}
    public Map<String, Boolean> contactRequiredFieldMap {get; set;}
    public List<Contact> contactExistingList {get; set;}
    public rC_Bios__Account_Address__c accountAddress {get; set;}
    public List<contactHelper> contactHelperList {get; set;}
    public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    public Boolean isAccountDuplicate {get; set;}
    public Boolean isContactDuplicate {get; set;}
    public String errorMessage {get; set;}
    Boolean isDuplicateInsert {get; set;}
    public ValidatedAddress address {get; set;}
    public List<AddressValidationComponentController> AddressControllers{get;set;}
    // T-474751 | Ravi Chauhan | Changes > Start
    public List<sObject> duplicateRecords{get;set;}
    public boolean hasDuplicateResult{get;set;}
    Final String RecordTypeAccountHousehold = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final String RecordTypeContactHousehold = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    // T-474751 | Ravi Chauhan | Changes > End
    // I-242949 | Ravi Chauhan | Changes > Start
    Final String RecordTypeAccountOrganization = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
    public String recordTypeParameter{get;set;}
    // I-242949 | Ravi Chauhan | Changes > End
    public boolean hasErrorOccuredFlag {get; set;}
    public String insertedAccountName {get; set;}
    public boolean duplicateAccountIdentified {get; set;}
    //Suminder - Added for Issue I-243432
    public boolean isContactLead{get;set;}
    // I-248674 | Ravi Chauhan | Changes > Start
    Final String RecordTypeContactOrganization = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Organizational').getRecordTypeId();
    // I-248674 | Ravi Chauhan | Changes > End
    
    @TestVisible
    class contactHelper {
        public Account preference {get; set;}
        public Contact contact {get; set;}
        public contactHelper() {
            preference = new Account();
            contact = new Contact();
        }
    } // END class contactHelper {
    
    public ManageAccountContactsController(ApexPages.StandardController stdCon) {
        this.AddressControllers = new List<AddressValidationComponentController>();
        this.cStdCon = stdCon;
        this.isContactLead = false;
        SINGLE_CONSTITUENT_WARNING_MESSAGE = 'No Constituent Type has been selected.';
        MULTIPLE_CONSTITUENT_WARNING_MESSAGE = 'No Constituent Type has been selected for one or more Contacts.';
        
        // T-474751 | Ravi Chauhan | Changes > Start
        this.hasDuplicateResult = false;
        // T-474751 | Ravi Chauhan | Changes > End
        // I-242949 | Ravi Chauhan | Changes > Start
        recordTypeParameter = Apexpages.currentPage().getParameters().get('RecordType');
        // I-242949 | Ravi Chauhan | Changes > End
        initialize();
        addContactFields();
        addAccountFields();
        
        String accId = Apexpages.currentPage().getParameters().get('id');
        if(String.isNotBlank(accId)) {
            acc = new Account(id=accId);
            fetchContacts();
        }
        else
        {
          acc = new Account();
          if(recordTypeParameter!= null){
              acc.recordTypeId = recordTypeParameter;
          }
        }
            
        
        contactsToCreate();
        setDefaultsForAllianceUsers();
        this.PopulateWebTransactionInfo();
    } // END public ManageAccountContactsController(ApexPages.StandardController stdCon) {
    
    //Sets default field values for alliance portal users
    private void setDefaultsForAllianceUsers()
    {
        //default donor alliance for alliance portal users
        Id userId = UserInfo.getUserId();
        User communityUser = [select id, 
                              contact.AccountId,
                              contact.Account.Alliance__c
                              from user where id = :userId];
        
        if(communityUser.contact != null)
        {
            for(contactHelper cont : contactHelperList)
            {
                cont.contact.Donor_Alliance__c = communityUser.contact.AccountId;
                
                if(communityUser.contact.Account.Alliance__c)
                    acc.US_Based_Account__c = 'No';
                else 
                    acc.US_Based_Account__c = 'Yes';
            }
        }
    }
    
    public PageReference Redirect()
    {
        recordTypeIdHousehold = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        recordTypeIdOrganizational = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        string recordTypeId = Apexpages.currentPage().getParameters().get('RecordType');
        Map<Id, schema.recordtypeinfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosById();
        String recordTypeName = recordTypeMap.get(recordTypeId).getName(); 
        
        if(recordTypeName != 'Organization' && recordTypeName != 'Household')
        {
            string url = '/'+Account.sobjecttype.getDescribe().getKeyPrefix()+'/e?RecordType='+recordTypeId+'&nooverride=1';
            PageReference ref = new PageReference(url);
            return ref;
        }
        else
            return null;
    }
    
    void initialize() {
        this.hasErrorOccuredFlag = false;
        this.duplicateAccountIdentified = false;
        this.insertedAccountName = '';
        addressSectionName = 'Address Information for Account & Preferred Contact';
        noOfContacts = 1;
        isRecordTypeError = false;
        isDisabledHideExistingContacts = true;
        isHideExistingContacts = false;
        isEnableConstituentTypes = false;
        showAccountName = true;
        AccountFields = new List<String>();
        ContactFields = new List<String>();
        accountRequiredFieldMap = new Map<String, Boolean>();
        contactRequiredFieldMap = new Map<String, Boolean>();
        contactExistingList = new List<Contact>();
        accountAddress = new rC_Bios__Account_Address__c();
        contactHelperList = new List<contactHelper>();
        this.isDuplicateInsert = false;
        address = new ValidatedAddress();
        isAccountDuplicate = false;
        isContactDuplicate = false;
        
    } // END void initialize() {

    private void PopulateWebTransactionInfo()
    {
        string webTransactionId = Apexpages.currentPage().getParameters().get('webTransactionId');
        if(string.IsNotBlank(webTransactionId))
        {
            try
            {
                Web_Transaction__c trans = [select id,
                                        Contact_First_Name__c,
                                        Contact_Last_Name__c,
                                        Contact_City__c,
                                        Contact_Country__c,
                                        Contact_Email__c,
                                        Contact_Phone__c,
                                        Contact_Postal_Code__c,
                                        Contact_State_Prov_Terr__c,
                                        Contact_Street_1__c,
                                        Contact_Street_2__c,
                                        Contact_Suffix__c,
                                        Contact_Title__c
                                        from Web_Transaction__c
                                        where id = :webTransactionId limit 1];

                if(this.contactHelperList.size() == 1)
                {
                    Contact contact = contactHelperList[0].contact;
                    contact.FirstName = trans.Contact_First_Name__c;
                    contact.LastName = trans.Contact_Last_Name__c;

                    if(trans.Contact_Email__c != null)
                    {
                        contact.rc_Bios__Preferred_Email__c = 'Home';
                        contact.rc_Bios__Home_Email__c = trans.Contact_Email__c;
                    }

                    if(trans.Contact_Phone__c != null)
                    {
                        contact.rc_Bios__Preferred_Phone__c = 'Home';
                        contact.HomePhone = trans.Contact_Phone__c;
                    }

                    contact.Salutation = trans.Contact_Title__c;
                    contact.rc_Bios__Suffix__c = trans.Contact_Suffix__c;

                    this.address = new ValidatedAddress(trans.Contact_Street_1__c, 
                                                trans.Contact_Street_2__c, 
                                                null, 
                                                trans.Contact_City__c, 
                                                trans.Contact_State_Prov_Terr__c, 
                                                trans.Contact_Postal_Code__c, 
                                                trans.Contact_Country__c, null, false, false);
                    
                    
                }
            }
            catch(exception ex)
            {}
            
        }
    }
    
    void addContactFields() {
        // I-242949 | Ravi Chauhan | Changes > Start | Picking a different field set in case of Organisation Accounts
        if(recordTypeParameter != null && RecordTypeAccountOrganization.contains(recordTypeParameter)){
            for(Schema.FieldSetMember fsm : getFields('Contact', 'Account_ManageContacts_OrganisationAccou')) {
                ContactFields.add(fsm.getFieldPath());
                contactRequiredFieldMap.put(fsm.getFieldPath(), fsm.getRequired());
            }
            contactRequiredFieldMap.put('donotcall', false);
        }// I-242949 | Ravi Chauhan | Changes > End
        else
        {
            for(Schema.FieldSetMember fsm : getFields('Contact', 'rC_Bios__Account_ManageContacts')) {
                ContactFields.add(fsm.getFieldPath());
                contactRequiredFieldMap.put(fsm.getFieldPath(), fsm.getRequired());
            }
        }
        
    } // END void addContactFields() {
    
    void addAccountFields() {
        //I-260605 | Ravi Chauhan | Changes > Start | Picking a different field set in case of Organisation Accounts
        if(recordTypeParameter != null && RecordTypeAccountOrganization.contains(recordTypeParameter)){
            for(Schema.FieldSetMember fsm : getFields('Account', 'rC_Bios__OrgAccount_ManageContacts')){
                AccountFields.add(fsm.getFieldPath());
                accountRequiredFieldMap.put(fsm.getFieldPath(), fsm.getRequired());
            }
        }// I-260605 | Ravi Chauhan | Changes > End
        else
        {
            for(Schema.FieldSetMember fsm : getFields('Account', 'rC_Bios__Account_ManageContacts')) {
                AccountFields.add(fsm.getFieldPath());
                accountRequiredFieldMap.put(fsm.getFieldPath(), fsm.getRequired());
            }
        }
        
    } // END void addAccountFields() {
    /*
    public List<SelectOption> getAccountTypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Type.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            {
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
        return options;
    }*/
    
    List<Schema.FieldSetMember> getFields(String objectName, String fsName) {
        return schemaMap.get(objectName).getDescribe().FieldSets.getMap().get(fsName).getFields();
    } // END List<Schema.FieldSetMember> getFields(String objectName, String fsName) {
    
    void fetchContacts() {
        String conQuery = 'SELECT AccountId, ';
        for(String conField : ContactFields) {
            conQuery += conField + ', ';
        }
        conQuery += 'donotcall, ';
        Contact preferredContact;
        List<Contact> nonPreferredContactList = new List<Contact>();
        conQuery = conQuery.left(conQuery.length()-2);
        conQuery += ' FROM Contact Where AccountId=\'' + acc.Id + '\' LIMIT 500';
        System.debug('[RB] - ManageAccountContactsController.fetchContacts :: conQuery = ' + conQuery);
        for(Contact con : Database.Query(conQuery)){
            if(con.rC_Bios__Preferred_Contact__c){
                preferredContact = new Contact();
                preferredContact = con;
            }
            else
                nonPreferredContactList.add(con);
        }
        if(preferredContact != null)
            contactExistingList.add(preferredContact);
        for(Contact con : nonPreferredContactList){
            contactExistingList.add(con);
        }    
        
    } // END void fetchContacts() {
    
    public void contactsToCreate() {
        Integer chSize = contactHelperList.size();
        if(chSize>noOfContacts)
            for(Integer i=chSize-1; i>=noOfContacts; i--)
            contactHelperList.remove(i);
        else
            for(Integer i=chSize; i<noOfContacts; i++)
            contactHelperList.add(new contactHelper());
    } // END public void contactsToCreate() {
    
    public PageReference upsertContactsAndAccountSamePage() {
        Account ac = saveRecords();
        System.debug('RC >> ' + ac);
        if(ac != Null){
            //PageReference pageRef = new PageReference('/' + ac.Id);
            //PageReference pageRef = new PageReference('/apex/ManageAccountContacts?id=' + ac.Id);
            PageReference pageRef = new PageReference('/apex/ManageAccountContacts?id=' + ac.Id + '&RecordType=' + recordTypeParameter);//RecordTypeAccountHousehold);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
            return Null;
    } // END public PageReference upsertContactsAndAccountAndReturn() {
    
    public PageReference upsertContactsAndAccountAndReturn() {
        Account ac = saveRecords();
        if(ac != Null)
            return (new PageReference('/' + ac.Id));
        else
            return Null;
    } // END public PageReference upsertContactsAndAccountAndReturn() {
    
    public PageReference upsertContactsAndAccountAndNewAccount() {
        Account ac = saveRecords();
        if(ac != Null)
            return (new PageReference('/apex/ManageAccountContacts'));
        else
            return Null;
    } // END public PageReference upsertContactsAndAccountAndNewAccount() {
    
    public PageReference upsertContactsAndAccountSamePage_Dup() {
        this.isDuplicateInsert = true;
        return upsertContactsAndAccountSamePage();
    } // END public PageReference upsertContactsAndAccountSamePage_Dup() {
    
    public PageReference upsertContactsAndAccountAndReturn_Dup() {
        this.isDuplicateInsert = true;
        return upsertContactsAndAccountAndReturn();
    } // END public PageReference upsertContactsAndAccountAndReturn_Dup() {
    
    public PageReference upsertContactsAndAccountAndNewAccount_Dup() {
        this.isDuplicateInsert = true;
        return upsertContactsAndAccountAndNewAccount();
    } // END public PageReference upsertContactsAndAccountAndNewAccount_Dup() {
    
    public PageReference cancel() {
        String retURL = Apexpages.currentPage().getParameters().get('retURL');
        if(String.isNotBlank(retURL))
            return (new PageReference('/'+retURL));
        else
            return (new PageReference('/001/o'));
    } // END public PageReference cancel() {
    
    /**
    * Method Name       :   saveRecords
    * Purpose           :   Method is called whenever any of the save button on the page is clicked
    * Created By        :   
    * Reference         :   T-474751
    * Created Date      :   
    * @param            :   none
    * @return           :   Account
    * Modified By       :   Appirio - Ravi Chauhan
    * Modified Date     :   Oct 20,2016
    */
    Account saveRecords() {
        
        if(contactExistingList != null && contactExistingList.size() > 0){
            List<Contact> newContactToBeInserted = new List<Contact>();
            upsert contactExistingList;
            
            if(contactHelperList != null && contactHelperList.size()>0){
                newContactToBeInserted = new List<Contact>();
                for(ContactHelper ch : contactHelperList) {
                    Contact con = ch.Contact;
                    //con.Lead__c = isContactLead;//Suminder - Added for Issue I-243432 // Ravi - Commented for I-252933
                    con.RecordTypeId = RecordTypeContactHousehold;
                    if(acc.Id != Null)
                        con.AccountId = acc.Id;
                    if(con.get('Id')==null)
                        newContactToBeInserted.add(con);
                }
            }
            if(newContactToBeInserted.size()>0){
                insert newContactToBeInserted;
            }
            return acc;
        }
        Account accNew ;
        
        /*if(contactExistingList.isEmpty() && !validateAddress()){
            return null;
        }*/
        
        for(AddressValidationComponentController comp : AddressControllers)
            comp.ValidateFields();
        try {
            
            if(this.address!=null && ((this.address.isOverridden!=null &&  this.address.IsOverridden) || this.address.IsValid)){
                accNew = new Account();
                if(acc.Id == Null) {
                    accNew = new Account();
                }
                else
                    accNew = acc;

                System.debug('[RB] - ManageAccountContactsController.saveRecords :: contactHelperList => ' + contactHelperList);
                
                if(!this.hasDuplicateResult && !this.isDuplicateInsert){
                    Account accNew1 = checkDuplicateAndSaveRecords(contactHelperList, address, false);
                    if(!hasDuplicateResult)
                        return accNew1;
                    
                }
                
                if(this.hasDuplicateResult && this.isDuplicateInsert){
                    Account accNew2 = checkDuplicateAndSaveRecords(contactHelperList, address, true);
                    //Account accNew2 = checkDuplicate(sal, fName, lName, address.line1, address.city,address.StateProv, address.PostalCode, address.Country, true);
                    
                    return accNew2;
                }
                
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error in validating address. Please correct the address first..'));
            }
  
        } // END try 
        catch(Exception e) {
            System.debug('[RB] - ManageAccountContactsController.saveRecords :: Error(Save & Close) => ' + e.getMessage() + '; Line No => ' + e.getLineNumber());
            acc.Id = Null;
            errorMessage += e.getMessage() + '; Line No : ' + e.getLineNumber();
            //Database.rollback(sp);
        } // END catch(Exception e) {
        return null;
    } // END Account saveRecords() {
    
    
    // T-474751 | Ravi Chauhan | Changes > Start
    
    /**
    * Method Name       :   checkDuplicateAndSaveRecords
    * Purpose           :   Method will check whether the Account OR Contact inserted is a duplicate or not.
    * Created By        :   Appirio - Ravi Chauhan
    * Reference         :   T-474751
    * Created Date      :   Oct 20,2016
    * @param            :   List<ContactHelper>
    *                       ValidatedAddress
    *                       boolean
    * @return           :   Account
    * Modified By       :   
    * Modified Date     :   
    */
    private Account checkDuplicateAndSaveRecords(List<ContactHelper> contactHelperList,ValidatedAddress address, boolean overrideDupe){
        
        SavePoint trans = Database.setSavepoint();
        
        try{
            
            Database.DMLOptions options = new Database.DMLOptions(); 
            options.DuplicateRuleHeader.allowSave = overrideDupe;
            options.DuplicateRuleHeader.runAsCurrentUser = true;
            
            for(ContactHelper ch : contactHelperList) {
                this.insertedAccountName = ch.Contact.LastName;
                if(ch.Contact.rC_Bios__Preferred_Contact__c == true){
                    this.insertedAccountName = ch.Contact.LastName;
                }
            }
            Account account = new Account();
            List<Contact> contactsToBeInserted = new List<Contact>();
            rc_Bios__Address__c biosAddress = new rc_Bios__Address__c();
            rc_Bios__Contact_Address__c contactAddress = new rc_Bios__Contact_Address__c();
            List<Database.SaveResult> resultList = new List<Database.SaveResult>();
            
            //temp account name because trigger will overwrite with name of preferred contact
            //account.name = String.valueOf(System.now());
            account.name = this.insertedAccountName;
            account.RecordTypeId = recordTypeParameter;//RecordTypeAccountHousehold;// I-248674 | the record type should be assigned according to the record type selected
            account.rC_Bios__Active__c = true;
            
            //populate billing address fields on account to enable duplicate detection on address for account
            account.BillingStreet = address.line1;
            account.BillingCity = address.city;
            account.BillingState = address.StateProv;
            account.BillingPostalCode = address.PostalCode;
            account.BillingCountry = address.Country;
            if(acc != null){
                // Fields for Household Account
                account.US_Based_Account__c = acc.US_Based_Account__c;
                account.Phone = acc.Phone;
                account.Website = acc.Website;
                account.ParentID = acc.ParentID;
                // I-260605 - Fields for Organisation Account
                account.rC_Bios__External_ID__c = acc.rC_Bios__External_ID__c;
                account.rC_Bios__Acquired_Date__c = acc.rC_Bios__Acquired_Date__c;
                account.rC_Bios__Acquired_Source__c = acc.rC_Bios__Acquired_Source__c;
                account.Type = acc.Type;
                account.Sub_Type__c = acc.Sub_Type__c;
                account.Industry = acc.Industry;
            }
            account.UseDuplicateRules__c = true;
            Database.SaveResult accountResult = Database.insert(account, options);
            ID accountId = accountResult.getId();
            resultList.add(accountResult);
            
            this.ExamineErrors(resultList, trans);
            
            if(this.hasErrorOccuredFlag){
                this.duplicateAccountIdentified = true;
                this.hasErrorOccuredFlag = false;
                return null;
            }
            
            //must check to see if address exists first by comparing hash
            if(!string.isBlank(address.Line1) || !string.isBlank(address.City)//Suminder - Added for Issue I-243432
               || !string.isBlank(address.Country)
               || !string.isBlank(address.PostalCode)){
                String hashedAddress = LookupService.HashAddress(address.line1, address.line2, address.city, address.StateProv, address.PostalCode, address.Country);
                //System.assert(false,'hash: ' + hashedAddress);
                List<rC_Bios__Address__c> addressList = [select id, 
                                                         rC_Bios__Street_Line_1__c,
                                                         rC_Bios__Street_Line_2__c, // Added for I-258868
                                                         Extra_Address_1__c, // Added for I-258868
                                                         rC_Bios__City__c,
                                                         rC_Bios__State__c,
                                                         rC_Bios__Postal_Code__c,
                                                         rC_Bios__Country__c
                                                         from rc_Bios__Address__c
                                                         where rC_Bios__Unique_MD5__c = :hashedAddress];
                System.debug('Address List'+ addressList.size());
                if(addressList.size() > 0)
                {
                    biosAddress = addressList[0];
                }
                else
                {
                    biosAddress.rC_Bios__Street_Line_1__c = address.line1;
                    biosAddress.rC_Bios__Street_Line_2__c = address.line2; // Added for I-258868
                    biosAddress.Extra_Address_1__c = address.line3; // Added for I-258868
                    biosAddress.rC_Bios__City__c = address.city;
                    biosAddress.rC_Bios__State__c = address.StateProv;
                    biosAddress.rC_Bios__Postal_Code__c = address.PostalCode;
                    biosAddress.rC_Bios__Country__c = address.Country;
                    
                    Database.SaveResult addressResult = Database.insert(biosAddress, options);
                    resultlist.clear();
                    resultList.add(addressResult);
                    this.ExamineErrors(resultlist, trans);
                    if(this.hasErrorOccuredFlag){
                        return null;
                    }
                    biosAddress.id = addressResult.getId();
                }
            }
            
            //I-248674 | Ravi Chauhan | To have the contact record type according to the Account Record Type >> Start
            String contactRecordTypeId = '';
            if(RecordTypeAccountHousehold.contains(recordTypeParameter))
                    contactRecordTypeId = RecordTypeContactHousehold;
            else if(RecordTypeAccountOrganization.contains(recordTypeParameter))
                    contactRecordTypeId = RecordTypeContactOrganization;
            //I-248674 | Ravi Chauhan | To have the contact record type according to the Account Record Type >> End
            
            // Ieterating over the contactHelperList to fetch all the contacts and populate details and insert them
            for(ContactHelper ch : contactHelperList) {
                Contact con = ch.Contact;
                con.RecordTypeId = contactRecordTypeId;//RecordTypeContactHousehold;
                //con.Lead__c = isContactLead;//Suminder - Added for Issue I-243432 // Ravi - Commented for I-252933
                if(acc.Id != Null)
                    con.AccountId = acc.Id;
                else
                    con.AccountId = accountResult.getId();
                
                if(con.rC_Bios__Preferred_Contact__c == true) {
                    
                    //must insert contact mailing address first because the Database.DuplicateError will not propagate from rollup trigger.
                    con.MailingStreet = address.line1;
                    con.MailingCity = address.city;
                    con.MailingState = address.StateProv;
                    con.MailingPostalCode = address.PostalCode;
                    con.MailingCountry = address.Country;
                    con.UseDuplicateRules__c = true;
                }
                contactsToBeInserted.add(con);
            }
            resultlist.clear();

            if(this.duplicateAccountIdentified){
                this.duplicateAccountIdentified = false;
                Database.DMLOptions optionsNew = new Database.DMLOptions(); 
                optionsNew.DuplicateRuleHeader.allowSave = false;
                optionsNew.DuplicateRuleHeader.runAsCurrentUser = true;
                resultlist = Database.insert(contactsToBeInserted, optionsNew);
            }
            else
                resultlist = Database.insert(contactsToBeInserted, options);

            this.ExamineErrors(resultlist, trans);
            if(this.hasErrorOccuredFlag){
                this.hasErrorOccuredFlag = false;
                return null;
            }
             if(!string.isBlank(address.Line1) || !string.isBlank(address.City)//Suminder - Added for Issue I-243432
               || !string.isBlank(address.Country)
               || !string.isBlank(address.PostalCode)){
                   List<Contact> preferredContacts = [SELECT id,rC_Bios__Preferred_Contact__c 
                                                      FROM Contact 
                                                      WHERE id IN :contactsToBeInserted 
                                                      AND rC_Bios__Preferred_Contact__c = true];
                   
                   contactAddress.rC_Bios__Active__c = true;
                   contactAddress.rC_Bios__Address__c = biosAddress.id;
                   contactAddress.rC_Bios__Type__c = 'Home';
                   if(preferredContacts.size() > 0)
                       contactAddress.rC_Bios__Contact__c = preferredContacts.get(0).Id;
                   contactAddress.rC_Bios__Preferred_Mailing__c = true;
                   contactAddress.rC_Bios__Preferred_Other__c = true;
                   contactAddress.rC_Bios__Additional_Line_1__c = address.line3;// Added for I-258868
                   
                   Database.SaveResult contactAddressResult = Database.insert(contactAddress, options);
                   resultlist.clear();
                   resultlist.add(contactAddressResult);
                   this.ExamineErrors(resultlist, trans);
                   
                   if(this.hasErrorOccuredFlag){
                       return null;
                   }
               }
            return account;
            
        }
        catch(exception ex)
        {   
            System.debug('Error: ' + ex.getMessage());
            Database.rollback(trans);
            ApexPages.Message errorMessage = new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Exception: ' + 
                ex.getMessage());
            ApexPages.addMessage(errorMessage);
        }
        
        return null;
    }
    
    /**
    * Method Name       :   ExamineErrors
    * Purpose           :   Method will check the errors received while insertion of records
    * Created By        :   Appirio - Ravi Chauhan
    * Reference         :   T-474751
    * Created Date      :   Oct 20,2016
    * @param            :   List<Database.SaveResult>
    *                       SavePoint
    * @return           :   none
    * Modified By       :   
    * Modified Date     :   
    */
    private void ExamineErrors(List<Database.SaveResult> resultList, SavePoint trans)
    {
        for(Database.SaveResult result : resultList){
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()){
                    system.debug('status code: ' + error.getStatusCode());
                    // If there are duplicates, an error occurs
                    // Process only duplicates and not other errors 
                    //   (e.g., validation errors)
                    if (error instanceof Database.DuplicateError) 
                    {
                        // Handle the duplicate error by first casting it as a 
                        //   DuplicateError class
                        // This lets you use methods of that class 
                        //  (e.g., getDuplicateResult())
                        Database.DuplicateError duplicateError = 
                            (Database.DuplicateError)error;
                        Datacloud.DuplicateResult duplicateResult = 
                            duplicateError.getDuplicateResult();
                        
                        // Display duplicate error message as defined in the duplicate rule
                        ApexPages.Message errorMessage = new ApexPages.Message(
                            ApexPages.Severity.ERROR, 'Duplicate Error: ' + 
                            duplicateResult.getErrorMessage());
                        ApexPages.addMessage(errorMessage);
                        
                        // Get duplicate records
                        this.duplicateRecords = new List<sObject>();
                        
                        // Return only match results of matching rules that 
                        //  find duplicate records
                        Datacloud.MatchResult[] matchResults = 
                            duplicateResult.getMatchResults();
                        
                        // Just grab first match result (which contains the 
                        //   duplicate record found and other match info)
                        Datacloud.MatchResult matchResult = matchResults[0];
                        
                        Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                        
                        // Add matched record to the duplicate records variable
                        for (Datacloud.MatchRecord matchRecord : matchRecords) 
                        {
                            System.debug('MatchRecord: ' + matchRecord.getRecord());
                            this.duplicateRecords.add(matchRecord.getRecord());
                        }
                        this.hasDuplicateResult = !this.duplicateRecords.isEmpty();
                    }
                    else
                    {
                        ApexPages.Message errorMessage = new ApexPages.Message(
                            ApexPages.Severity.ERROR, 'Other Error: ' + 
                            error.getMessage());
                        ApexPages.addMessage(errorMessage);
                        this.hasDuplicateResult = true;
                    }
                }
                database.rollback(trans);
                this.hasErrorOccuredFlag = true;
            }
        }
    }
    
    // T-474751 | Ravi Chauhan | Changes > End
    
    public boolean validateAddress(){
        boolean isValid = true;
        if(string.isBlank(address.Line1) && string.isBlank(address.Country)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Address is required.'));
            isValid = false;
        }
        else if(string.isBlank(address.Line1)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Line 1 is required.'));
            isValid = false;
        }
        else if(string.isBlank(address.Country)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Country is required.'));
            isValid = false;
        }
        return isValid;       
    }
} // END public with sharing class ManageAccountContactsController {