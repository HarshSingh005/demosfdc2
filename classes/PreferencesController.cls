/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PreferencesController
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Extension class for page "Preferences"
 * Created Date : 22/Dec/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 05/Jan/2015                  Rohit B                 Added "getFetchQuery" function and made some 
                                                        modifications in constructor for edit functionality.
 * 06/Jan/2015                  Rohit B                 Created a function "performValidation" and call this
                                                        function in Save method.
 **********************************************************************************************************/
public with sharing class PreferencesController {
    public rC_Bios__Preference__c pref {get; set;}
    public String codeValue {get; set;}
    public String opportunityID {get; set;}
    public String opportunity {get; set;}
    public Boolean isOptyEmpty {get; set;}
    public String recType {get; set;}
    public Boolean isEditMode {get; set;}
    Boolean isRecFound;
    String recID;
    public static String errorMsg {get; set;}

    public PreferencesController(ApexPages.StandardController stdCon) {
        isOptyEmpty = true;
        isRecFound = false;
        isEditMode = false;
        pref = new rC_Bios__Preference__c();
        recID = Apexpages.currentPage().getParameters().get('Id');
        String recTypeID = Apexpages.currentPage().getParameters().get('RecordType');
        opportunityID = Apexpages.currentPage().getParameters().get('OpportunityID');

        if(recID != Null) {
            isEditMode = true;
            String soql = getFetchQuery(recID);
            System.debug('[RB] - PreferencesController.Constructor :: soql = ' + soql);
            list<rC_Bios__Preference__c> lstPref = (list<rC_Bios__Preference__c>)Database.query(soql);
            if(!lstPref.IsEmpty()){
                pref = lstPref[0];
                codeValue = lstPref[0].rC_Bios__Code_Value__c;
                recTypeID = lstPref[0].RecordTypeId;
                opportunityID = lstPref[0].rC_Sponsorship__Opportunity__c;

                if(pref.rC_Bios__Type__c == 'Birthdate') {
                    string dt = lstPref[0].rC_Bios__Subtype__c;
                    pref.Legacy_Created_Date__c = Date.parse(dt.split('-')[1]+'/'+dt.split('-')[2]+'/'+dt.split('-')[0]);
                }
                isRecFound = true;
            } // END if(!lstPref.IsEmpty()){
        } // END if(recID != Null) {
        
        //if(!isRecFound){
            if(!String.isEmpty(opportunityID)) {
                isOptyEmpty = false;
                pref.rC_Sponsorship__Opportunity__c = opportunityID;
                opportunity = [SELECT Name FROM Opportunity WHERE Id =: opportunityID][0].Name;
            }

            if(!String.isEmpty(recTypeID))
                recType = [SELECT Name FROM RecordType WHERE ID =: recTypeID AND SObjectType = 'rC_Bios__Preference__c'][0].Name;
            else
                recType = 'Sponsorship';

            if(!isRecFound && isEditMode)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Record Id is not valid. Please create new Preference record.'));
        //} // END if(!isRecFound){
    } // END public PreferencesController(ApexPages.StandardController stdCon) {

    public String getFetchQuery(string recordID) {
        String objName = 'rC_Bios__Preference__c';
        String selects = '';
        
        if (recordID == null || recordID == ''){
            return null;
        } // END if (recordID == null || recordID == ''){
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){           // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe();   // describe each field (fd)
                if (fd.isCreateable())                              // field is creatable
                    selectFields.add(fd.getName());
            } // END for (Schema.SObjectField ft : fMap.values()){
        } // END if (fMap != null){
        
        if (!selectFields.isEmpty()){
            for (string s : selectFields)
                selects += s + ',';
            if (selects.endsWith(','))
                selects = selects.substring(0,selects.lastIndexOf(','));
        } // END if (!selectFields.isEmpty()){
        return 'SELECT ' + selects + ' FROM ' + objName + ' WHERE Id=\'' + recordID + '\'';
    } // END public String getFetchQuery(string recordID) {

    public List<SelectOption> getSelCodeValues() {
        List<SelectOption> options = new List<SelectOption>();
        Set<String> setOptions = new Set<String>();
        for(rC_Bios__Preference_Code__c pc : [SELECT rC_Bios__Category__c, rC_Bios__Subcategory__c, 
                                                rC_Bios__Type__c, rC_Bios__Subtype__c FROM rC_Bios__Preference_Code__c]) {
            setOptions.add(pc.rC_Bios__Category__c + '-' + pc.rC_Bios__Subcategory__c + '-' + 
                            pc.rC_Bios__Type__c + '-' + pc.rC_Bios__Subtype__c);
        } // END for(rC_Bios__Preference_Code__c pc : 

        options.add(new SelectOption('','--None--'));
        for(String strVal : setOptions) {
            options.add(new SelectOption(strVal, strVal));
        } // END for(String strVal : setOptions) {
        return options;
    } // END public List<SelectOption> getSelCodeValues() {

    public PageReference saveRecord() {
        Boolean isInserted = false;
        rC_Bios__Preference__c pref_new;
        if(performValidation() == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMsg));
            return null;
        }
        try {
            pref_new = new rC_Bios__Preference__c();
            //pref_new.rC_Bios__Code_Value__c = codeValue;
            pref_new.rC_Bios__Category__c = pref.rC_Bios__Category__c;
            pref_new.rC_Bios__Active__c = pref.rC_Bios__Active__c;
            pref_new.rC_Bios__Subcategory__c = pref.rC_Bios__Subcategory__c;
            pref_new.rC_Bios__Status__c = pref.rC_Bios__Status__c;
            pref_new.rC_Bios__Type__c = pref.rC_Bios__Type__c;
            pref_new.rC_Bios__Start_Date__c = pref.rC_Bios__Start_Date__c;
            pref_new.rC_Bios__End_Date__c = pref.rC_Bios__End_Date__c;
            pref_new.rC_Bios__Contact__c = pref.rC_Bios__Contact__c;
            if(!String.isEmpty(opportunityID))
                pref_new.rC_Sponsorship__Opportunity__c = opportunityID;
            else
                pref_new.rC_Sponsorship__Opportunity__c = pref.rC_Sponsorship__Opportunity__c;
            pref_new.Preference_Reason__c = pref.Preference_Reason__c;
            pref_new.rC_Bios__Comments__c = pref.rC_Bios__Comments__c;
            pref_new.National_Office__c = null;
            pref_new.Local_Partner__c = null;
            pref_new.Community__c = null;
            pref_new.RecordTypeId = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();

            if(pref.rC_Bios__Type__c == 'National Office') {
                pref_new.National_Office__c = pref.National_Office__c;
                pref_new.rC_Bios__Subtype__c = pref.National_Office__c;
            }
            else if(pref.rC_Bios__Type__c == 'Local Partner') {
                pref_new.Local_Partner__c = pref.Local_Partner__c;
                pref_new.rC_Bios__Subtype__c = pref.Local_Partner__c; 
            }
            else if(pref.rC_Bios__Type__c == 'Community') {
                pref_new.Community__c = pref.Community__c;
                pref_new.rC_Bios__Subtype__c = pref.Community__c;
            }
            else if(pref.rC_Bios__Type__c == 'Birthdate') 
                pref_new.rC_Bios__Subtype__c = String.valueOf(pref.Legacy_Created_Date__c);
            else
                pref_new.rC_Bios__Subtype__c = pref.rC_Bios__Subtype__c;

            if(isEditMode) {
                pref_new.Id = pref.Id;
                update pref_new;
            }
            else {  
                insert pref_new;
            }
            
            //pref_new.rC_Bios__Code_Value__c = codeValue;
            //update pref_new; //Again Updating same record after insert because it is not reflecting codeValue upon insert. 
            isInserted = true;
        } // END try {
        catch(Exception e) {
            System.debug('[RB] - PreferencesController.saveRecord :: Error(Save) = ' + e.getMessage() + '; Line No = ' + e.getLineNumber());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        } // END catch(Exception e) {

        if(isInserted)
            return (new PageReference('/' + pref_new.Id));
        else 
            return Null;
    } // END public PageReference saveRecord() {

    public PageReference cancel() {
        if(!String.isEmpty(opportunityID))
            return (new PageReference('/' + opportunityID));
        else if(isRecFound)
            return (new PageReference('/' + recID));
        else 
            return (new PageReference('/a0H/o')); 
    } // END public PageReference cancel() {

    Boolean performValidation() {
        //System.debug('[RB] - PreferencesController.performValidation :: Start..');
        Boolean flag = true;
        errorMsg = '';
        if(pref.rC_Sponsorship__Opportunity__c == Null) {
            errorMsg = 'Please select Opportunity..';
            flag = false;
        }
        if(pref.rC_Bios__Type__c == Null) {
            errorMsg = 'Please select Type..';
            flag = false;
        }
        if((pref.rC_Bios__Type__c == 'National Office' && pref.National_Office__c == Null) || 
            (pref.rC_Bios__Type__c == 'Local Partner' && pref.Local_Partner__c == Null) ||
            (pref.rC_Bios__Type__c == 'Community' && pref.Community__c == Null)) {
            errorMsg += 'Please choose Account of ' + pref.rC_Bios__Type__c + ' record type..';
            flag = false;
        }
        else if(pref.rC_Bios__Type__c == 'Birthdate' && pref.Legacy_Created_Date__c == Null) {
            errorMsg += 'Please Enter Birth Date..';
            flag = false;
        }
        //System.debug('[RB] - PreferencesController.performValidation :: End..');
        return flag;
    } // END Boolean performValidation() {
} // END public with sharing class PreferencesController {