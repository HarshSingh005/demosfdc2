/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ManageDonorOpportunitiesController
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Extension class of ManageDonorOpportunities Page
 * Created Date : 22/Feb/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
public with sharing class ManageDonorOpportunitiesController {
    public String contactID{get;set;}
    public String contactName{get;set;}
    String accountID;
    Contact con;
    public static String errorMessage {get; set;}
    public Boolean gotError {get; set;}
    public Boolean noRecordFound {get; set;}
    public Boolean noRecordFoundSchedulePmnt {get; set;}
    public List<OpportunityWrapper> lstOppWrap {get; set;}
    public List<OpportunityWrapper> lstOppWrapSchedulePmnt {get; set;}
    public List<String> OpportunityFields {get; set;}
    public List<String> OpportunityFieldsSchedulePmnt {get;set;}
    Final String OPP_DONATION_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    Final String OPP_TRANSACTION_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    Final String CON_HOUSEHOLD_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    public Opportunity oppty {get; set;}
    public String DF_Type {get; set;}
    public String selectedTab {get; set;}
    public String saveButtonName {get; set;}
    public String scrd {get; set;} 
    public String orderByField {get; set;}
    public String sortingOrder {get; set;}
    Map<String, Campaign> mapCamp;
    Final List<String> OPPSTAGELIST = new List<String>{'Open', 'Partially Complete'};
    Final List<String> OPPSTAGEOPEN = new List<String>{'Open'};
    Final Set<String> DFANNUALEVENTS = new Set<String>{'30 - Birthday', '31 - Christmas', '32 - Easter', '41 - New Years', '42 - Valentines', '74 - Thanksgiving'};
    
    public string productType{get;set;}
    public string productSubType{get;set;}
    public Boolean isAGP{get;set;}
    public string paymentMethod{get;set;}
    public boolean displayTab6{get;set;}
    public List<SelectOption> productSubTypeList {get;set;}  //Code added for I-251516 
    private boolean checkOption{get;set;}      //Code added for I-251516 
    @TestVisible
    class OpportunityWrapper {
        public Opportunity opp {get; set;}
        public String contactID {get; set;}
        public Boolean isUpdate {get; set;}
        public OpportunityWrapper() {
            opp = new Opportunity();
            isUpdate = false;
        }
    } 

    public ManageDonorOpportunitiesController() {
        mapCamp = new Map<String, Campaign>();
      
    }

    public ManageDonorOpportunitiesController(ApexPages.StandardController stdCon) {
        errorMessage = '';
        selectedTab = 'Tab5';
        saveButtonName = 'Create Sponsorship';
        productType = '';
        productSubType = '';
        contactID = Apexpages.currentPage().getParameters().get('id');
        isAGP = false;
        displayTab6 = false;
        
        if(String.isNotBlank(contactID)) {
            con = [SELECT Id, Name, AccountId, RecordtypeId, Donor_Alliance__r.Country__c FROM Contact WHERE Id = :contactID LIMIT 1];
            if(con.RecordTypeId == CON_HOUSEHOLD_RT) {
                contactName = con.Name;
                accountID = con.AccountId;
                initialize();
                fetchOpportunities();
            } else {
                gotError = true;
                errorMessage = 'Contact should be a Donor i.e. Recordtype should be Household. ';
            }
        } 
        else {
            gotError = true;
            errorMessage = 'You\'r coming from a wrong way. Please GoTo: \n';
            errorMessage += 'Contact -> Select Donor Contact -> Click \'Opportunities Update\'\n';
        }
    } 

    void initialize() {
        oppty = new Opportunity();
        lstOppWrap = new List<OpportunityWrapper>();
        //new List for records in tab6
        lstOppWrapSchedulePmnt = new List<OpportunityWrapper>();
        OpportunityFields = new List<String>();
        OpportunityFieldsSchedulePmnt = new List<String>();
        noRecordFound = false;
        noRecordFoundSchedulePmnt = false;
        gotError = false;
        oppty.AccountId = con.AccountId;
        oppty.rC_Giving__Primary_Contact__c = con.Id;
        oppty.rC_Giving__Hard_Credit_Contact__c = con.Id;
        orderByField = '';
        
        getOpportunityFields();
        getOpportunityFieldsSchedulePmnt();
    } 

    /**
    * @description - Method to get all Campaign whose product type is "Designated Fund" to show on the page in "DF Types" field.
    * @return - List<SelectOption>
    */
    public List<SelectOption> getDF_Types() {
        List<SelectOption> options = new List<SelectOption>();
        //List<String> setOptions = TStringUtils.GetDependentOptions('Opportunity', 'Product_Type__c', 'Product_Sub_Type__c').get('Designated Fund');
        mapCamp = new Map<String, Campaign>();
        options.add(new SelectOption('','--None--'));
        for(Campaign camp : [SELECT Id, Name, Product_Type__c, Product_Sub_Type__c, rC_Giving__GAU__c 
                                FROM Campaign WHERE Product_Type__c = 'Designated Fund' 
                                AND Country_Alliance__c = :con.Donor_Alliance__r.Country__c
                                Order By Name]) {
            mapCamp.put(camp.Id, camp);
            options.add(new SelectOption(camp.Id, camp.Name));
        } 
        return options;
    } 

    /**
    * @description - Method to get all picklist values of "Sponsorship Change Reason Details" on the basis of "Sponsorship Status Reason" to show on the page in "Cancel Reason" field.
    * @return - List<SelectOption>
    */
    public List<SelectOption> getSponsorshipChangeReasonDetail() {
        List<SelectOption> options = new List<SelectOption>();
        List<String> setOptions = TStringUtils.GetDependentOptions('Opportunity', 'rC_Sponsorship__Sponsorship_Status_Reason__c', 'Sponsorship_Change_Reason_Detail__c').get('Cancellation');
        options.add(new SelectOption('','--None--'));
        for(String strVal : setOptions) {
            options.add(new SelectOption(strVal, strVal));
        } 
        return options;
    } 

    public List<SelectOption> getDoNotSubs() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('true','True'));
        options.add(new SelectOption('false','False'));
        return options;
    } 

    void getOpportunityFieldsSchedulePmnt() {
        OpportunityFieldsSchedulePmnt.add('Id');
        OpportunityFieldsSchedulePmnt.add('Name');
        OpportunityFieldsSchedulePmnt.add('StageName');
        OpportunityFieldsSchedulePmnt.add('Amount');
        OpportunityFieldsSchedulePmnt.add('CloseDate');
        OpportunityFieldsSchedulePmnt.add('rC_Giving__GAU__c');
        OpportunityFieldsSchedulePmnt.add('AGP_Method__c');
        OpportunityFieldsSchedulePmnt.add('rC_Giving__Payment_Method_Selected__c');
        OpportunityFieldsSchedulePmnt.add('Date_of_Distribution__c');
        OpportunityFieldsSchedulePmnt.add('Campaign_Source_Number__c');
        OpportunityFieldsSchedulePmnt.add('DFC_Status__c');
    }

    void getOpportunityFields() {
        OpportunityFields.add('Id');
        OpportunityFields.add('Name');
        OpportunityFields.add('Product_Type__c');
        OpportunityFields.add('Product_Sub_Type__c');
        OpportunityFields.add('DFC_Release_Month_Master__c');
        OpportunityFields.add('rC_Giving__Payment_Method_Selected__c');
        OpportunityFields.add('Sponsorship_Status__c');
        OpportunityFields.add('rC_Giving__Giving_Frequency__c');
        OpportunityFields.add('rC_Giving__Giving_Amount__c');
        OpportunityFields.add('CloseDate');
        OpportunityFields.add('Paid_Through_Date__c');
    } 

    /**
    * @description - Method to fetch all the opportunities based on "Hard Credit Contact" with some other conditions as well
    * @return - void
    */
    public void fetchOpportunities() {
        lstOppWrap = new List<OpportunityWrapper>();
        lstOppWrapSchedulePmnt = new List<OpportunityWrapper>();
        String sortField = 'CloseDate';
        String sortOrder = 'DESC';
        if(orderByField!='' && orderByField!=Null)
            sortField = orderByField;
        if(sortingOrder!='' && sortingOrder!=Null)
            sortOrder = sortingOrder;
        
        String oppQuery = 'SELECT RecordTypeId, RecordType.Name, rC_Giving__Primary_Contact__c, rC_Giving__Hard_Credit_Contact__c, Campaign.Name, ';
        for(String oppField : OpportunityFields) {
            oppQuery += oppField + ', ';
        }
        oppQuery = oppQuery.left(oppQuery.length()-2);
        oppQuery += ' FROM Opportunity WHERE RecordTypeId != \'' + OPP_TRANSACTION_RT + '\'';
        oppQuery += ' AND StageName IN :OPPSTAGELIST AND rC_Giving__Hard_Credit_Contact__c = \''+ contactID + '\'';
        oppQuery += ' Order by ' + sortField + ' ' + sortOrder;
        System.debug('[RB] - ManageDonorOpportunitiesController.fetchOpportunities :: oppQuery = ' + oppQuery);
        for(Opportunity opp : Database.query(oppQuery)) {
            OpportunityWrapper ow = new OpportunityWrapper();
            ow.opp = opp;
            ow.contactID = opp.rC_Giving__Hard_Credit_Contact__c;
            ow.isUpdate = false;
            lstOppWrap.add(ow);
        } 
        if(lstOppWrap.size()==0)
            noRecordFound = true; 
        
        String sortFieldPmt = 'CloseDate';
        String sortOrderPmt = 'ASC';
        if(orderByField!='' && orderByField!=Null)
            sortFieldPmt = orderByField;
        if(sortingOrder!='' && sortingOrder!=Null)
            sortOrderPmt = sortingOrder;
        // fetching Open transaction Opportunities for "Schedule Payments for Processing" tab
        oppQuery = 'SELECT RecordTypeId, RecordType.Name, rC_Giving__Primary_Contact__c, rC_Giving__Hard_Credit_Contact__c, Campaign.Name, ';
        for(String oppField : OpportunityFieldsSchedulePmnt) {
            oppQuery += oppField + ', ';
        }
        oppQuery = oppQuery.left(oppQuery.length()-2);
        oppQuery += ' FROM Opportunity WHERE RecordTypeId = \'' + OPP_TRANSACTION_RT + '\'';
        oppQuery += ' AND StageName IN :OPPSTAGEOPEN AND rC_Giving__Hard_Credit_Contact__c = \''+ contactID + '\'';
        oppQuery += ' Order by ' + sortFieldPmt + ' ' + sortOrderPmt;
        System.debug('[RB] - ManageDonorOpportunitiesController.fetchOpportunities :: oppQuery = ' + oppQuery);
        for(Opportunity opp : Database.query(oppQuery)) {
            OpportunityWrapper ow = new OpportunityWrapper();
            ow.opp = opp;
            ow.contactID = opp.rC_Giving__Hard_Credit_Contact__c;
            ow.isUpdate = false;
            lstOppWrapSchedulePmnt.add(ow);
        } 
        
        if(lstOppWrapSchedulePmnt.size()==0)
            noRecordFoundSchedulePmnt = true; 
    } 

    /*public PageReference printValue() {
        errorMessage = 'DF_Type => ' + DF_Type + '; givingFreq => ' + oppty.rC_Giving__Giving_Frequency__c + '; Close Date => ' + oppty.Cancelled_Date__c + '; Giving Amount : ' + oppty.rC_Giving__Giving_Amount__c;
        return null;
    } // End public PageReference printValue() {*/

    /**
    * @description - Method to set value of "selectedTab" and "Update" button name on the basis of tab selection on the page.
    * @return - PageReference (null)
    */
    public PageReference selectTab() {
        //errorMessage = '';
        displayTab6 = false;
        if (selectedTab == 'Tab1') {
            saveButtonName = 'Create DFs';
        } else if (selectedTab == 'Tab4') {
            saveButtonName = 'Create Contribution';
        } else if (selectedTab == 'Tab5') {
            saveButtonName = 'Create Sponsorship';
        } else {
            saveButtonName = 'Update Opps';
        }
        if(selectedTab == 'Tab6'){
            displayTab6 = true;
        }
        
        return null;
    } 

    /**
    * @description - Method to update/insert records as per the tab selection and values provided on the page.
    * @return - PageReference (null)
    */
    public PageReference updateRecords() {
        System.debug('[RB] - ManageDonorOpportunitiesController.updateRecords :: Start..');
        List<Opportunity> lstOppToUpsert = new List<Opportunity>();
        Set<String> setOppIDs = new Set<String>();
        errorMessage = (errorMessage == null) ? '' : errorMessage;
        for(OpportunityWrapper ow : lstOppWrap) {
            if(ow.isUpdate == true) {
                setOppIDs.add(ow.opp.Id);
            }
        }
        Map<String, Opportunity> mapOpp = new Map<String, Opportunity>([SELECT Id, Name, AccountId, RecordTypeId, Participant__c,
                                            rC_Giving__Primary_Contact__c, rC_Giving__Hard_Credit_Contact__c, Monthly_Standard_Pay__c,  
                                            rC_Giving__Giving_Frequency__c, rC_Giving__Giving_Amount__c, Participant__r.BirthDate, 
                                            CampaignId, Campaign.Name, Campaign.Product_Type__c, Campaign.Product_Sub_Type__c   
                                            FROM Opportunity WHERE Id in :setOppIDs]);
        Integer cntAllRecord=0;
        Integer cntSelectedRecords=0;
        for(OpportunityWrapper ow : lstOppWrap) {
            ++cntAllRecord;
            if(ow.isUpdate == true) {
                ++cntSelectedRecords;
                String oppID = ow.opp.Id;
                if(mapOpp.get(oppID).Participant__c == Null) {
                    errorMessage += 'Opportunity \''+ ow.opp.Name +'\' must have Participant to proceed. First populate Participant on the Opportunity then proceed.';
                    return null;
                }
                if(selectedTab == 'Tab1') {
                    Opportunity opTab1 = Update_Tab1(mapOpp, oppID);
                    if(opTab1 != null)
                        lstOppToUpsert.add(opTab1);
                } 

                if(selectedTab == 'Tab2') {
                    Opportunity opTab2 = Update_Tab2(mapOpp, oppID, ow.opp.Name);
                    if(opTab2 != null)
                        lstOppToUpsert.add(opTab2);
                } 

                if(selectedTab == 'Tab3') {
                    Opportunity opTab3 = Update_Tab3(mapOpp, oppID);
                    if(opTab3 != null)
                        lstOppToUpsert.add(opTab3);
                } 
            } 
        } 
        
        if(selectedTab == 'Tab4') {//creating new Record for Tab4
            Opportunity opTab4 = Update_Tab4(mapOpp);
                if(opTab4 != null)
                    lstOppToUpsert.add(opTab4);
        } 
        if(selectedTab == 'Tab5') {//creating new record for tab5
            Opportunity opTab5 = Update_Tab5(mapOpp);
                if(opTab5 != null)
                    lstOppToUpsert.add(opTab5);
        } 
        if(selectedTab == 'Tab6') {//updating selected records for tab6
            for(OpportunityWrapper ow : lstOppWrapSchedulePmnt) {
                ++cntAllRecord;
                if(ow.isUpdate == true) {
                    ++cntSelectedRecords;
                    Boolean gotValue = false;
                    String oppID = ow.opp.Id;
                    
                    Opportunity opTab6 = new Opportunity(id = oppId);
                    opTab6.Amount = oppty.Amount;
                    opTab6.CloseDate = oppty.Cancelled_Date__c;
                    opTab6.rC_Giving__Payment_Method_Selected__c = oppty.Selected_Payment_Method_EFT_CC__c;
                    //opTab6.rC_Giving__Payment_Method__c = paymentMethod;
                    lstOppToUpsert.add(opTab6);
                    
                }
            }
        } 
        
        System.debug('[RB] - ManageDonorOpportunitiesController.updateRecords :: count => ' + cntAllRecord + ' & ' + cntSelectedRecords);
        System.debug('[RB] - ManageDonorOpportunitiesController.updateRecords :: lstOppToUpsert => ' + lstOppToUpsert);
        try {
            if(lstOppToUpsert.size() > 0) {
                upsert lstOppToUpsert;
                if(selectedTab == 'Tab1')
                    errorMessage += lstOppToUpsert.size() + ' DF opportunity has been successfully created for your selected opportunity.';
                else if(selectedTab == 'Tab4')
                    errorMessage += 'Contribution has been successfully created..';
                else if(selectedTab == 'Tab5')
                    errorMessage += 'Sponsorship has been successfully created..';
                else
                    errorMessage += lstOppToUpsert.size() + ' opportunity selected by you has been successfully updated.';
                initialize();
                fetchOpportunities();
            } 
            else if(cntSelectedRecords == 0 && selectedTab != 'Tab4'){
                errorMessage = 'There is no opportunity selected to perform action. Please select at least one opportunity.';
                return null;
            }
        } catch(Exception e) {
            errorMessage += e.getMessage();
            return null;
        }
        return null; //(new PageReference('/apex/ManageDonorOpportunities?id=' + Apexpages.currentPage().getParameters().get('id')));
    } 

    /**
    * @description - Method to return an opportunity on the basis of selected values for Tab1 on the page.
    * @return - Oppportunity
    */
    Opportunity Update_Tab1(Map<String, Opportunity> mapOpp, String oppID) {
        System.debug('[RB] - ManageDonorOpportunitiesController.Update_Tab1 :: Start..');
        if(String.isNotEmpty(DF_Type)) {
            String givingFreq;
            Decimal givingAmount;
            Opportunity opNew = new Opportunity();
            if(oppty.rC_Giving__Giving_Frequency__c != Null && oppty.rC_Giving__Giving_Frequency__c != '') {
                givingFreq = oppty.rC_Giving__Giving_Frequency__c;
                if(mapCamp!=null && mapCamp.get(DF_Type)!=null && mapCamp.get(DF_Type).Name!=null){
                    String dfType = mapCamp.get(DF_Type).Name;
                System.debug('[RB] - ManageDonorOpportunitiesController.Update_Tab1 :: dfType => ' + dfType + '; givingFreq => ' + givingFreq + '; Close Date => ' + oppty.Cancelled_Date__c);
                    if((DFANNUALEVENTS.contains(dfType)) && !(givingFreq=='Annually' || givingFreq=='One Payment')) {
                        errorMessage += 'You must choose Giving Frequency as \'One Payment\' or \'Annually\' for \'' + dfType + '\' DF Type.';
                        return null;
                    }
                }
            } 
            else
                givingFreq = 'Monthly';
            
            if (givingFreq != 'One Payment')
                opNew.rC_Giving__Is_Sustainer__c = true;

            if(oppty.rC_Giving__Giving_Amount__c == Null) {
                errorMessage += 'You must enter DF Amount to create new DF Opportunity..';
                return null;
            } else
                givingAmount = oppty.rC_Giving__Giving_Amount__c;
                        
            if (oppty.Cancelled_Date__c == Null) {
                errorMessage += 'You must Close Date to create new DF Opportunity..';
                return null;
            } else 
                opNew.CloseDate = oppty.Cancelled_Date__c;

            opNew.DFC_Related_Opportunity__c = oppID;
            //opNew.Product_Type__c = 'Designated Fund';
            //opNew.Product_Sub_Type__c = DF_Type;
            if(mapCamp!=null && mapCamp.get(DF_Type)!=null && mapCamp.get(DF_Type).Product_Type__c!=null){
                opNew.Product_Type__c = mapCamp.get(DF_Type).Product_Type__c;
            }
            if(mapCamp!=null && mapCamp.get(DF_Type)!=null && mapCamp.get(DF_Type).Product_Sub_Type__c!=null){
                opNew.Product_Sub_Type__c = mapCamp.get(DF_Type).Product_Sub_Type__c;
            }
            opNew.RecordtypeId = OPP_DONATION_RT;
            opNew.AccountId = oppty.AccountId;
            //opNew.CampaignId = mapOpp.get(oppID).CampaignId; 
            opNew.CampaignId = DF_Type;  //done to check test
            opNew.StageName = 'Open';
                        
            opNew.Participant__c = mapOpp.get(oppID).Participant__c;

            if(String.isNotEmpty(oppty.rC_Giving__Payment_Method_Selected__c))
                opNew.rC_Giving__Payment_Method_Selected__c = oppty.rC_Giving__Payment_Method_Selected__c;
                        
            opNew.rC_Giving__Giving_Frequency__c = givingFreq;
            opNew.rC_Giving__Giving_Amount__c = givingAmount;
            if(mapCamp!=null && mapCamp.get(DF_Type)!=null && mapCamp.get(DF_Type).Name!=null && mapOpp!=null && mapOpp.get(oppID)!=null && mapOpp.get(oppID).Participant__c!=null && mapOpp.get(oppID).Participant__r.BirthDate!=null){
                opNew.DFC_Release_Month_Master__c = getReleaseMonth(mapCamp.get(DF_Type).Name, mapOpp.get(oppID).Participant__r.BirthDate);
            }                           

            opNew.rC_Giving__Primary_Contact__c = mapOpp.get(oppID).rC_Giving__Primary_Contact__c;
            opNew.rC_Giving__Hard_Credit_Contact__c = mapOpp.get(oppID).rC_Giving__Hard_Credit_Contact__c;

            //opNew.rC_Giving__First_Payment_Date__c = System.today();
            opNew.rC_Giving__First_Payment_Date__c = null;

            //opNew.rC_Giving__Payment_End_Date__c = System.today();
            opNew.rC_Giving__Payment_End_Date__c = null;

            //opNew.rC_Giving__Payment_Day__c = '1st';

            return opNew;
            //errorMessage += 'DF Type : ' + DF_Type;
        } 
        else
            errorMessage += 'You didn\'t selected any DF. Please select any DF Type to create new DF opportunity.';

        System.debug('[RB] - ManageDonorOpportunitiesController.Update_Tab1 :: End..');
        return null;
    }

    /**
    * @description - Method to return an opportunity on the basis of selected values for Tab2 on the page.
    * @return - Oppportunity
    */
    Opportunity Update_Tab2(Map<String, Opportunity> mapOpp, String oppID, String oppName) {
        System.debug('[RB] - ManageDonorOpportunitiesController.Update_Tab2 :: Start..');
        Boolean gotValue = false;
        Opportunity opTab2 = new Opportunity(Id = oppID);
        String oldFreq = mapOpp.get(oppID).rC_Giving__Giving_Frequency__c;
        if(oppty.rC_Giving__Giving_Frequency__c != Null && oppty.rC_Giving__Giving_Frequency__c != '' && oppty.rC_Giving__Giving_Amount__c != Null && oldFreq != oppty.rC_Giving__Giving_Frequency__c) {
            errorMessage += 'Please select one at a time \'Giving Frequency\' or \'Monthly Standard Pay Increase\'.';
            return null;
        }
        if(oppty.rC_Giving__Payment_Method_Selected__c != Null) {
            if(accountID != mapOpp.get(oppID).AccountId) {
                errorMessage += 'Account is different on Selected Opportunity \''+ oppName +'\' and Contact \'' + contactName + '\'. Please make them same.';
                return null;
            }
            opTab2.rC_Giving__Payment_Method_Selected__c = oppty.rC_Giving__Payment_Method_Selected__c;
            gotValue = true;
        }
        if(oppty.rC_Giving__Giving_Frequency__c != Null && oppty.rC_Giving__Giving_Frequency__c != '') {
            String newFreq = oppty.rC_Giving__Giving_Frequency__c;
            Decimal givingAmount = mapOpp.get(oppID).rC_Giving__Giving_Amount__c;
            opTab2.rC_Giving__Giving_Frequency__c = newFreq;
            if(newFreq != 'One Payment' && oldFreq != 'One Payment')
                opTab2.rC_Giving__Giving_Amount__c = calculateGivingAmount(oldFreq, newFreq, givingAmount);
                        
            gotValue = true;
        }
        if(oppty.rC_Giving__Giving_Amount__c != Null) {
            Decimal oldMSP =  mapOpp.get(oppID).rC_Giving__Giving_Amount__c;
            String Freq = mapOpp.get(oppID).rC_Giving__Giving_Frequency__c;
            Decimal givingAmount = oppty.rC_Giving__Giving_Amount__c;
            if(oldMSP != null)   
                opTab2.rC_Giving__Giving_Amount__c = oldMSP + calculateGivingAmount('Monthly', Freq, givingAmount);
            else 
                opTab2.rC_Giving__Giving_Amount__c = calculateGivingAmount('Monthly', Freq, givingAmount);
            gotValue = true;
        }
        if(oppty.Cancelled_Date__c != null) {
            opTab2.CloseDate = oppty.Cancelled_Date__c;
            gotValue = true;
        }

        if(gotValue) 
            return opTab2;

        System.debug('[RB] - ManageDonorOpportunitiesController.Update_Tab2 :: End..');
        return null;
    }

    /**
    * @description - Method to return an opportunity on the basis of selected values for Tab3 on the page.
    * @return - Oppportunity
    */
    Opportunity Update_Tab3(Map<String, Opportunity> mapOpp, String oppID) {
        System.debug('[RB] - ManageDonorOpportunitiesController.Update_Tab3 :: Start..');
        Boolean gotValue = false;
        Opportunity opTab3 = new Opportunity(Id = oppID);
        if(oppty.rC_Giving__Suspended_Start_Date__c != Null && oppty.rC_Giving__Suspended_End_Date__c != Null) {
            Integer daysDiff = oppty.rC_Giving__Suspended_Start_Date__c.daysBetween(oppty.rC_Giving__Suspended_End_Date__c);
            System.debug('[RB] - ManageDonorOpportunitiesController.Update_Tab3 :: daysDiff => ' + daysDiff);
            if(daysDiff>90) {
                errorMessage += 'Difference of \'Suspend Date From\' and \'Suspend Date To\' cannot be greater than 90 days.';
                return null;
            }
        }
        if(oppty.CFI_Do_Not_Substitute__c != Null && oppty.CFI_Do_Not_Substitute__c != '') {
            opTab3.CFI_Do_Not_Substitute__c = oppty.CFI_Do_Not_Substitute__c;
            if(oppty.Do_Not_Sub_Reason__c != Null && oppty.Do_Not_Sub_Reason__c != '')
                opTab3.Do_Not_Sub_Reason__c = oppty.Do_Not_Sub_Reason__c;
            gotValue = true;
        }
        if(String.isNotEmpty(scrd)) {
            opTab3.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
            opTab3.Sponsorship_Change_Reason_Detail__c = scrd;
            opTab3.Cancelled_Date__c = System.today();
            opTab3.Cancel_Sponsorship__c = 'Cancel - Reinstateable';
            opTab3.StageName = 'Canceled';
            gotValue = true;
        }
        if(oppty.Paid_Through_Date__c != Null) {
            opTab3.Paid_Through_Date__c = oppty.Paid_Through_Date__c;
            gotValue = true;
        }
        if(oppty.rC_Giving__Suspended_Start_Date__c != Null) {
            opTab3.rC_Giving__Suspended_Start_Date__c = oppty.rC_Giving__Suspended_Start_Date__c;
            gotValue = true;
        }
        if(oppty.rC_Giving__Suspended_End_Date__c != Null) {
            opTab3.rC_Giving__Suspended_End_Date__c = oppty.rC_Giving__Suspended_End_Date__c;
            gotValue = true;
        }
        if(gotValue)
            return opTab3;

        System.debug('[RB] - ManageDonorOpportunitiesController.Update_Tab3 :: End..');
        return null;
    }

    /**
    * @description - Method to return an opportunity on the basis of selected values for Tab4 on the page.
    * @return - Oppportunity
    */
    Opportunity Update_Tab4(Map<String, Opportunity> mapOpp) {
        System.debug('[PB] - ManageDonorOpportunitiesController.Update_Tab4 :: Start..');
        Opportunity opTab4 = new Opportunity(AccountId = oppty.AccountId);
            
        String tab4Amount = Apexpages.currentPage().getParameters().get('tab4Amount');
        String tab4Campaign = Apexpages.currentPage().getParameters().get('tab4Campaign');
        String tab4PmntMethod = Apexpages.currentPage().getParameters().get('tab4PmntMethod');

        if(productType=='' || productType =='None'){
            errorMessage += 'Please Select Product Type. ';
            return null;
        }
        else {
            opTab4.Product_Type__c = productType;
            //Added by Rohit B on 15/June/2015 as per updated task description by Tim       --START--
            if(productType=='Recurring Gift') {
                opTab4.rC_Giving__Giving_Frequency__c = 'Monthly';
                opTab4.rC_Giving__Is_Sustainer__c = true;
            } else if(productType=='One Time Gift') {
                opTab4.rC_Giving__Giving_Frequency__c = 'One Payment';
            }
            //Added by Rohit B on 15/June/2015 as per updated task description by Tim       --END--
        }
        if(productSubType=='' || productSubType =='None'){
            errorMessage += 'Please Select Product Sub Type. ';
            return null;
        }
        else{
            opTab4.Product_Sub_Type__c  = productSubType;
        }

        if(tab4Amount!=null && tab4Amount!='')
            opTab4.rC_Giving__Giving_Amount__c = Decimal.valueOf(tab4Amount);
         else{
            errorMessage += 'Please enter giving amount. ';
            return null;
        }
            
        //opTab4.rC_Giving__Payment_Method__c = tab4PmntMethod;
        opTab4.CloseDate = oppty.Cancelled_Date__c;
        opTab4.CampaignId = oppty.Campaign_Recurring_OneTime__c;
        opTab4.StageName = 'Open';
        //opTab4.AGP_Method__c= isAGP;
        opTab4.rC_Giving__Is_Giving__c = true;
        opTab4.rC_Giving__Is_Giving_Transaction__c = true;
        opTab4.Payment_Hard_Credit_Contact__c = contactID;
        opTab4.rC_Giving__Primary_Contact__c = contactID;
        opTab4.rC_Giving__Payment_Method_Selected__c = oppty.rC_Giving__Payment_Method_Selected__c;
        opTab4.RecordtypeId = OPP_DONATION_RT;//code added for I-251516
             
        System.debug('[PB] - ManageDonorOpportunitiesController.Update_Tab4 :: End..');
        return opTab4;
    }

    /**
    * @description - Method to return an opportunity on the basis of selected values for Tab5 on the page.
    * @return - Oppportunity
    */
    Opportunity Update_Tab5(Map<String, Opportunity> mapOpp) {
        System.debug('[PB] - ManageDonorOpportunitiesController.Update_Tab5 :: Start..');
        Opportunity opTab5 = new Opportunity(AccountId = oppty.AccountId);
        
        //String tab5GivingSchedule = Apexpages.currentPage().getParameters().get('tab5GivingSchedule');
        //String tab5Campaign = Apexpages.currentPage().getParameters().get('tab5Campaign');
        //String tab5PmntMethod = Apexpages.currentPage().getParameters().get('tab5PmntMethod');
        opTab5.RecordtypeId = OPP_DONATION_RT; // Setting recordtype as part of issue I-224762
        opTab5.rC_Giving__Giving_Amount__c = oppty.rC_Giving__Annual_Giving_Amount__c;
        opTab5.CloseDate = oppty.rC_Giving__First_Payment_Date__c;
        //opTab5.rC_Giving__Payment_Method__c = tab5PmntMethod;
        opTab5.rC_Giving__Payment_Method_Selected__c = oppty.rC_Giving__Payment_Method_Selected__c;
        opTab5.CampaignId = oppty.Campaign_Sponsorship__c;
        opTab5.rC_Giving__Reporting_Schedule__c = oppty.rC_Giving__Reporting_Schedule__c; //tab5GivingSchedule;
        opTab5.rC_Giving__Giving_Frequency__c = oppty.rC_Giving__Reporting_Schedule__c;
        opTab5.rC_Giving__First_Payment_Date__c = oppty.rC_Giving__First_Payment_Date__c;
        opTab5.StageName = 'Open';
        //opTab5.AGP_Method__c= isAGP;
        opTab5.rC_Giving__Is_Giving__c = true;
        opTab5.rC_Giving__Is_Giving_Transaction__c = true;
        opTab5.Payment_Hard_Credit_Contact__c = contactID;
        opTab5.rC_Giving__Primary_Contact__c = contactID;
        opTab5.Product_Type__c = 'Sponsorship';
        opTab5.Product_Sub_Type__c = 'Child Sponsorship';
        opTab5.rC_Giving__Is_Sustainer__c = true;
        If(oppty.Participant__c != null) {
            opTab5.Participant__c = oppty.Participant__c;
            opTab5.Auto_Assign_Participant__c = 'Direct Sponsorship';
        } else {
            opTab5.Auto_Assign_Participant__c = 'New Assignment';
        }
        
        System.debug('[PB] - ManageDonorOpportunitiesController.Update_Tab5 :: End..');
        return opTab5;
    }

    /**
    * @description - Method to calculate "Giving Amount" on the basis of "Giving Frequency".
    * @return - Decimal
    */
    Decimal calculateGivingAmount(String oldFreq, String newFreq, Decimal amt) {
        Map<String, Decimal> mapFreq = getFrequencyMap();
        System.debug('[RB] - ManageDonorOpportunitiesController.calculateGivingAmount :: oldFreq => ' + oldFreq + '; newFreq => ' + newFreq + '; amt => ' + amt);
        System.debug('[RB] - ManageDonorOpportunitiesController.calculateGivingAmount :: mapFreq.get(oldFreq) => ' + mapFreq.get(oldFreq) + '; mapFreq.get(newFreq) => ' + mapFreq.get(newFreq));
        
        if(newFreq=='One Payment' || oldFreq=='One Payment')
            return amt;
        else if(mapFreq.get(newFreq) > mapFreq.get(oldFreq)) {
            amt *= (mapFreq.get(newFreq)/mapFreq.get(oldFreq));
        }
        else if(mapFreq.get(newFreq) < mapFreq.get(oldFreq)) {
            amt /= (mapFreq.get(oldFreq)/mapFreq.get(newFreq));
        }
        
        return amt;
    } 
    
    /**
    * @description - Method to produce Frequency map to calculate "Giving Amount" on the basis of "Giving Frequency".
    * @return - Map<String, Decimal>
    */
    Map<String, Decimal> getFrequencyMap() {
        Map<String, Decimal> mapFreq = new Map<String, Decimal>();
        mapFreq.put('Annually', 12);
        mapFreq.put('Semi-Annually', 6);
        mapFreq.put('Quarterly', 3);
        mapFreq.put('Monthly', 1);
        mapFreq.put('Semi-Monthly', 0.5);
        mapFreq.put('Weekly', 0.25);
        return mapFreq;
    } 

    /**
    * @description - Method to return "Release Month" on the basis some selected events.
    * @return - Integer
    */
    @TestVisible
    Integer getReleaseMonth(String dfType, Date bDate) {
        if(dfType.contains('30 - Birthday') && bDate != null)
            return (bDate.month() > 2) ? bDate.month() - 2 : 12 + (bDate.month() - 2);
        else if(dfType.contains('31 - Christmas') || dfType.contains('41 - New Years'))
            return 10;
        else if(dfType.contains('42 - Valentines'))
            return 12;
        else if(dfType.contains('74 - Thanksgiving'))
            return 9;
        else if(dfType.contains('32 - Easter'))
            return (System.today().year() == 2016) ? 1 : 2;
        else
            return 0;
    } 
    
    /**
    * @description - Method to return "Payment Methods" for "Schedule Payment for Processing" tab
    * @return - List<SelectOption>
    */
    public List<SelectOption> getPaymentMethods() {
        List<SelectOption> stOptions = new List<SelectOption>();
        stOptions.add(new SelectOption('None','--None--'));
        stOptions.add(new SelectOption('Charge Card','Charge Card'));
        stOptions.add(new SelectOption('EFT','EFT'));
        return stOptions;
    }

    /**
    * @description - Method to return "Product Type" for Create Contribution tab
    * @return - List<SelectOption>
    */
    public List<SelectOption> getProductTypes() {
        List<SelectOption> stOptions = new List<SelectOption>();
        stOptions.add(new SelectOption('None','--None--'));
        stOptions.add(new SelectOption('Recurring Gift','Recurring Gift'));
        stOptions.add(new SelectOption('One Time Gift','One Time Gift'));
        //Code added for I-251516 begin
        if(checkOption!=true){
          productSubTypeList= new List<SelectOption>();
        productSubTypeList.add(new SelectOption('None','--None--'));
        checkOption=true;
             //Code added for I-251516 end
         }  
        return stOptions;
    }

    /**
    * @Code Commented for I-251516
    * @description - Method to return "Product Sub Type" on the basis of Selected Product type on Create Contribution Tab.
    * @return - List<SelectOption>
    */
   /* public List<SelectOption> getProductSubTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','--None--'));
        if (productType.equals('Recurring Gift')) {
            options.add(new SelectOption('CGN','CGN'));
            options.add(new SelectOption('EFS','EFS'));
            options.add(new SelectOption('Guardian Angel', 'Guardian Angel'));
            options.add(new SelectOption('Other Contribution','Other Contribution'));
        } else if (productType.equals('One Time Gift')) {
            options.add(new SelectOption('Standard','Standard'));
            options.add(new SelectOption('Gift Catalog','Gift Catalog'));
        }
        return options;
    }
    
   */
   /*
   @description - Method to return "Product Sub Type" on the basis of Selected Product type on Create Contribution Tab for I-251516
   10-Dec-2017
   */
    public void showproductSubtype(){
        productSubTypeList= new List<SelectOption>();
        productSubTypeList.add(new SelectOption('None','--None--'));
        if (productType.equals('Recurring Gift')) {
            productSubTypeList.add(new SelectOption('CGN','CGN'));
            productSubTypeList.add(new SelectOption('EFS','EFS'));
            productSubTypeList.add(new SelectOption('Guardian Angel', 'Guardian Angel'));
            productSubTypeList.add(new SelectOption('Other Contribution','Other Contribution'));
        } else if (productType.equals('One Time Gift')) {
            productSubTypeList.add(new SelectOption('Standard','Standard'));
            productSubTypeList.add(new SelectOption('Gift Catalog','Gift Catalog'));
        }
        
      //  return null;
    }
  

    /**
    * @description - Method to redirect to a defined page/record on the basis of retURL/Id value.
    * @return - PageReference
    */
    public PageReference cancel() {
        String retURL = Apexpages.currentPage().getParameters().get('retURL');
        if(String.isBlank(retURL))
            retURL = Apexpages.currentPage().getParameters().get('id');
        if(String.isBlank(retURL))
            retURL = '/003/o';

        return (new PageReference('/'+retURL));
    } 
}