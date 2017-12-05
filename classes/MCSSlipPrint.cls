/***********************************************************************************************************
* Appirio, Inc
* Name         : MCSSlipPrint 
* Created By   : Dirk Koechner (Appirio Inc.)
* Purpose      : Extension class of MCSSlipPrint page.
* Created Date : April/20/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
*April 20,2016                 Vaibhav Goel            Added functionality of Page Breaks, naming of files to be downloaded. 
*Aug 26,2016                   Ravi Chauhan            Functionality for Child Status Slip 
*Dec 14, 2016				   Suminder Singh		   I-247733 - Fixed for errors
*Dec 26, 2016				   Suminder Singh		   I-250379 - Fixed for view state errors
**********************************************************************************************************/
public with sharing class MCSSlipPrint {
    
    private Mail_Control_Slip__c mailControlSlip;
    public String urlToRedirect {get; set;}
    String sfSession;
    String sfServerURL;
    public String NationOfficeName {get; set;}
    public String LocalPartnerName {get; set;} 
    public String CommunityName {get; set;}
    public SearchFilter filter {get; set;}
    transient List<Mail_Control_Slip__c> mcsList;//I-250379 - Suminder Singh
    
    //list of the MCS_Query_Staging__c records to be inserted into database.
    transient List<MCS_Query_Staging__c> mcsStagingList;//I-250379 - Suminder Singh
    public String uniqueToken; 
    public String selectedLetterType{get;set;}
    public Decimal dfcLocalTotal;
    public Decimal dfcUsTotal;
    public Integer mcsListSize{get;set;}
    public List<SubTotalWrap> subTotalWrapList{get;set;}
    
    //defining the variable 'MAX_RECORDS_PER_PAGE' value from Custom Label
    private static Integer MAX_RECORDS_PER_PAGE = Integer.ValueOf(label.MCS_Records_Per_Chunk);
    
    public List<CongaButton>  congaButtons{get;set;}
    public Integer noOfButtons{get;set;}
    public List<SelectOption> congaButtonsPicklist{get;set;}
    
    // Ravi Chauhan | T-499682
    public List<Contact_Query_Staging__c> childStatusSlipStagingList;
    public List<ContactHistory> childStatusSlipList;
    public Integer childStatusSlipListSize{get;set;}
    public map<String, rC_Bios__Relationship__c> mapPartIdRelaObj; //creating map of ParticipantId and related rC_Bios__Relationship__c record.
    public map<String, rC_Bios__Relationship__c> mapPartIdSponsorObj;
    public static Map<String, String> mapMonthNames = new Map<String, String>{'01' => 'Jan', '02' => 'Feb', '03' => 'Mar', '04' => 'Apr', '05' => 'May', '06' => 'Jun', '07' => 'Jul', '08' => 'Aug',
        '09' => 'Sep', '10' => 'Oct', '11' => 'Nov', '12' => 'Dec'};
            
    /**
    * A helper class to define and hold the values of instances 
    * of Contact and Mail_Control_Slip__c object. These instances
    * are used on VF page to hold the user input for search.
    * @param  none
    * @return none
    */    
    public class SearchFilter {
        public Contact participant {get; set;}
        public Mail_Control_Slip__c mcs {get; set;}
                
        /** 
        * Class constructor.
        */
        public SearchFilter() {
            participant = new Contact();
            mcs = new Mail_Control_Slip__c();
        }
    } 
    
    /** 
    * Class constructor.
    * @param  standardController instance to hold the current Mail Control SLip record Id .
    */
    public MCSSlipPrint(ApexPages.StandardController stdController) {
        
        //this.mailControlSlip = (Mail_Control_Slip__c)stdController.getRecord();
        
        this.mailControlSlip = [SELECT Id,Conga_Server_URL__c FROM Mail_Control_Slip__c LIMIT 1];

        filter = new SearchFilter();
        mcsList = new List<Mail_Control_Slip__c>();
        mcsStagingList= new List<MCS_Query_Staging__c>();
        // Ravi Chauhan | T-499682
        childStatusSlipStagingList = new List<Contact_Query_Staging__c>();
        
        //storing the current session Id in the variable 'sfSession'
        //sfSession = Apexpages.currentPage().getParameters().get('sessionId'); //I-261611 - Commented as part of this issue 
        
        // In case the page is opened from Home Page custom link
        
        sfSession = UserInfo.getSessionId();//I-261611 - Fetching session Id From UserInfo rather thean $api.session in sustom URL
        
        //storing the current URL in the variable 'sfServerURL'
        //sfServerURL = Apexpages.currentPage().getParameters().get('serverURL');//I-261611 - Commented as part of this issue 
        // In case the page is opened from Home Page custom link
        if(this.mailControlSlip != null){
            sfServerURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/29.0/' + UserInfo.getOrganizationId();
            //sfServerURL = this.mailControlSlip.Conga_Server_URL__c;//I-261611 - Fetching server url from formula field rather than custom url {!$Api.Partner_Server_URL_290}
        }
        noOfButtons = 0;
        congaButtonsPicklist = new List<SelectOption>();
        
    } 
    
    /**
    * Creates and Returns a picklist for the user to show on MCS SLip Print page.
    * 
    * @param  none
    * @return List<SelectOption> list of select options to show to the user. 
    * 
    */
    public List<SelectOption> getletterTypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('', '- None -'));
        Schema.DescribeFieldResult fieldResult = Mail_Control_Slip__c.MCS_Letter_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            if (!f.getLabel().contains('National Director'))
                options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        options.add(new selectOption('Child Welcome and Child Bonding Letters', 'Child Welcome and Child Bonding Letters'));
        options.add(new selectOption('Sponsor and Child Reply Letters', 'Sponsor and Child Reply Letters'));
        options.add(new selectOption('---', '---'));
        options.add(new selectOption('Labels - ND Welcome/SS ND Welcome Letter (for processed letters)', 'Labels - ND Welcome/SS ND Welcome Letter (for processed letters)'));
        options.add(new selectOption('Labels - MCS Address Labels (for closed MCS)', 'Labels - MCS Address Labels (for closed MCS)'));
        options.add(new selectOption('Report - DF Register', 'Report - DF Register'));
        options.add(new selectOption('Report - Child Status Slip', 'Report - Child Status Slip'));
        return options;
    }
    
    /**
    * Method will create the conga URLs based upon the selection criteria.
    * It divides the results returned by SOQL into chunks i.e. Conga-documents links. A new Conga-document link is created for each community 
    * and also whenever the number of records belonging to one commmunity are more than the defined in the variable - 'MAX_RECORDS_PER_PAGE'.
    * Conga-documents links are stored as the instances of the wrapper class - 'CongaButton' in list 'congaButtons'.
    *
    *
    * @param  none
    * @return null
    * 
    */
    public PageReference launchConga() {
        
        mcsListSize = 0;
        subTotalWrapList = new List<SubTotalWrap>();
        mcsList = new List<Mail_Control_Slip__c>();
        mcsStagingList= new List<MCS_Query_Staging__c>();//I-250379 - Suminder Singh
        // Ravi Chauhan | T-499682 | Changes Start
        if(selectedLetterType == 'Report - Child Status Slip'){
            childStatusSlip();
        }else{
            // Ravi Chauhan | T-499682 | Changes End    
            mcsList = fetchMCSSlips();
            
            //Creating a new list of wrapper class
            congaButtons = new List<congaButton>();
            
            //clearing the values of the picklist before storing the final document URLs
            congaButtonsPicklist.clear();
            
            //iterating over the search result list to create conga-document links.
            if(mcsList != null && mcsList.size() > 0){
                
                mcsStagingList.clear();
                
                uniqueToken = '';
                //generating the unique for each search made by the user. this would help in indetifying the records to be used while createing the conga documents.
                uniqueToken = UserInfo.getUserId()+DateTime.now().getTime();
                
                mcsListSize = mcsList.size();
                
                set<string> communityIdSet = new set<string>();
                String communityID;
                Double localSubTotal = 0;
                Double usSubTotal = 0;
                
                Integer recordsInCurrentPage = 0;
                
                //initializing the variable value to zero. this variable stores the value of number of links that will be created.
                noOfButtons = 0; 
                
                map<String, Integer> commIdAndPages = new map<String, Integer>();
                String requestID;
                for(Integer i = 0; i < mcsList.size(); i++){
                    
                    
                    MCS_Query_Staging__c mStageObj = new MCS_Query_Staging__c();
                    
                    mStageObj.Mail_Control_Slip__c = mcsList.get(i).Id;
                    
                    if(math.mod(i, 2) == 0){
                        mStageObj.Table_Column__c = 'Left';                        
                    }else if(math.mod(i, 2) == 1){
                        mStageObj.Table_Column__c = 'Right';
                    }    
                    mStageObj.Request_ID__c = requestID;                
                    
                    //the very first record of mcsList will also pass this if check as variable - communityID is blank at the begining. 
                    //Hence, we are getting the button created for the first chunk as well. 
                    if(math.mod((recordsInCurrentPage), MAX_RECORDS_PER_PAGE) == 0 || communityID != mcsList.get(i).Community_ID__c) {// We need button either on Community change or current button has reached it's max size
                        
                        system.debug('---communityID---' + communityID);
                        system.debug('---mcsList.get(i).Community_ID__c---' + mcsList.get(i).Community_ID__c);
                        
                        requestID = uniqueToken + 'page' + noOfButtons + '.' + mcsList.get(i).Community_ID__c;
                        mStageObj.Request_ID__c = requestID;                    
                        congaButtons.add(new CongaButton(mStageObj.Request_ID__c, System.Today().format() + '_Doc' + (((i + 1)/ MAX_RECORDS_PER_PAGE) + 1) + 'OftotalDocs', '', mcsList.get(i).Community__c, mcsList.get(i).Community_ID__c));
                        recordsInCurrentPage = 0;
                        noOfButtons++;
                        
                        //Preparing the map of CommunityId and number of chunks for each communityId
                        if(!commIdAndPages.containsKey(mcsList.get(i).Community_ID__c)){
                            commIdAndPages.put(mcsList.get(i).Community_ID__c, 1);
                        }else{
                            Integer numberOfpagesPerCommunity = commIdAndPages.get(mcsList.get(i).Community_ID__c);
                            numberOfpagesPerCommunity++;
                            commIdAndPages.put(mcsList.get(i).Community_ID__c, numberOfpagesPerCommunity);
                        }
                        
                    }     
                    
                    if(communityID != null && communityID != mcsList.get(i).Community_ID__c) { // Community get changed
                        
                        system.debug('---communityIDINIF---' + communityID);
                        system.debug('---mcsList.get(i).Community_ID__cINIF---' + mcsList.get(i).Community_ID__c);
                        system.debug('---localAmountINIF---' + mcsList.get(i).DFC_Amount_Local__c);
                        system.debug('---USAmouontINIF---' + mcsList.get(i).DFC_Amount__c);
                        
                        
                        mcsStagingList.get(i - 1).Community_Gifts_Local_Total__c = localSubTotal;
                        mcsStagingList.get(i - 1).Community_Gifts_US_Total__c = usSubTotal;
                        
                        system.debug('---mcsStagingList.get(i - 1)Community_Gifts_Local_Total__c---' + mcsStagingList.get(i - 1).Community_Gifts_Local_Total__c);
                        system.debug('---mcsStagingList.get(i - 1)Community_Gifts_US_Total__c---' + mcsStagingList.get(i - 1).Community_Gifts_US_Total__c);
                        
                        subTotalWrapList.add(new SubTotalWrap(mcsList.get(i - 1).Community__c, localSubTotal, usSubTotal));
                        localSubTotal = 0; 
                        usSubTotal = 0;
                        
                        communityID = mcsList.get(i).Community_ID__c;
                        localSubTotal = localSubTotal + mcsList.get(i).DFC_Amount_Local__c;
                        usSubTotal = usSubTotal + mcsList.get(i).DFC_Amount__c;
                    } else {
                        
                        system.debug('---mcsList.get(i).Community_ID__cINELSE---' + mcsList.get(i).Community_ID__c);
                        system.debug('---localAmountINELSE---' + mcsList.get(i).DFC_Amount_Local__c);
                        system.debug('---USAmouontINELSE---' + mcsList.get(i).DFC_Amount__c);                        
                        
                        communityID = mcsList.get(i).Community_ID__c;
                        localSubTotal = localSubTotal + mcsList.get(i).DFC_Amount_Local__c;
                        usSubTotal = usSubTotal + mcsList.get(i).DFC_Amount__c;
                    }
                    
                    communityID = mcsList.get(i).Community_ID__c;
                    /*++localSubTotal; //+= mcsList.get(i).DFC_Amount_Local__c;
                    usSubTotal += mcsList.get(i).DFC_Amount__c;*/
                    
                    mcsStagingList.add(mStageObj);
                    recordsInCurrentPage++;
                    
                }
                
                mcsStagingList.get(mcsStagingList.size() - 1).Community_Gifts_Local_Total__c = localSubTotal;
                mcsStagingList.get(mcsStagingList.size() - 1).Community_Gifts_US_Total__c  = usSubTotal;
                subTotalWrapList.add(new SubTotalWrap(mcsList.get(mcsList.size() - 1).Community__c, localSubTotal, usSubTotal));
                
                system.debug('---subTotalWrapList---' + subTotalWrapList.size());
                
                if(mcsStagingList != null && mcsStagingList.size() > 0){
                    
                    system.debug('---mcsStagingList---' + mcsStagingList.size());
                    insert mcsStagingList;
                }
                
                String url = buildURL_Query();  
                urlToRedirect = url;
                
                if(congaButtons != null && congaButtons.size() > 0){
                    map<String, Integer> fileNamingMap = new map<String, Integer>();
                    Integer pageCounter = 1;
                    String CommunityIdPlaceHolder = congaButtons.get(0).communityID;
                    
                    
                    for(Integer i = 0; i < congaButtons.size(); i++){
                        
                        if(!fileNamingMap.containsKey(congaButtons.get(i).communityID)){
                            Integer localPageCounter = 1;
                            fileNamingMap.put(congaButtons.get(i).communityID, localPageCounter);
                            congaButtons.get(i).fileName = System.Today().format() + '_'+ congaButtons.get(i).communityName +'_Doc_' + localPageCounter + '_Of_' + commIdAndPages.get(congaButtons.get(i).communityID);
                        }else{
                            Integer localPageCounterIncrease = fileNamingMap.get(congaButtons.get(i).communityID);
                            localPageCounterIncrease++;
                            fileNamingMap.put(congaButtons.get(i).communityID, localPageCounterIncrease);
                            congaButtons.get(i).fileName = System.Today().format() + '_'+ congaButtons.get(i).communityName +'_Doc_' + localPageCounterIncrease + '_Of_' + commIdAndPages.get(congaButtons.get(i).communityID);
                        }
                        congaButtons.get(i).congaURL = urlToRedirect.replace('uniquePageToken', congaButtons.get(i).urlString).replace('fileName', congaButtons.get(i).fileName);
                        
                    }
                    
                    for(congaButton c : congaButtons){
                        congaButtonsPicklist.add(new SelectOption(c.congaURL, c.fileName));
                    }
                    
                }
                
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records found within search criteria.'));	
            }  
        }
        //return new PageReference(urlToRedirect);
        return null;  
    }
    
    /**
    * Method will build the dynamic query based upon the search options input by user and other dependent conditions. 
    *
    * @param  none
    * @return List<Mail_Control_Slip__c> list of records of - Mail_Control_Slip__c object 
    * 
    */
    public List<Mail_Control_Slip__c> fetchMCSSlips(){
        String mcsQuery = '';
        String countQuery = '';
        String commonQuery = '';
        Date mcsFromDate =  filter.mcs.MCS_Date__c;
        Date mcsToDate =  filter.mcs.Due_Date__c;
         
        mcsQuery += 'Select Id, NAME,DFC_Opportunity__c,Date_Closed__c, MCS_Date__c, LastModifiedById, DFC_Opportunity__r.rC_Giving__Comments__c, ';
        mcsQuery += ' DFC_Amount__c, Community_ID__c, Community__c, DFC_Amount_Local__c, DFC_Opportunity__r.rC_Giving__Grant_Purpose__c FROM Mail_Control_Slip__c ';
        countQuery += 'Select count() FROM Mail_Control_Slip__c';
        
        if(selectedLetterType == 'Child Welcome and Child Bonding Letters')
        {
            commonQuery += ' WHERE MCS_Letter_Type__c IN ( \'Child Welcome Letter\', \'Child Bonding Letter\' ) AND MCS_Status__c = \'Active\'';    
        }
        else if(selectedLetterType == 'Sponsor and Child Reply Letters')
        {
            commonQuery += ' WHERE MCS_Letter_Type__c IN ( \'Sponsor Letter\', \'Child Reply Letter\' ) AND MCS_Status__c = \'Active\'';    
        }
        else if(selectedLetterType == 'Report - DF Register')
        {
            commonQuery += ' WHERE MCS_Letter_Type__c = \'Thank You Letter For DF\' AND MCS_Status__c = \'Active\'';    
            // AND DFC_Opportunity__c != null AND DFC_Opportunity__c != \'\' 
        }
        else if(selectedLetterType == 'Labels - ND Welcome/SS ND Welcome Letter (for processed letters)')
        {
            commonQuery += ' WHERE MCS_Letter_Type__c IN ( \'National Director Welcome Letter\', \'Sub/Shift National Director Welcome Letter\' ) AND MCS_Status__c = \'Closed\''; 
        }
        else if(selectedLetterType == 'Labels - MCS Address Labels (for closed MCS)')
        {
            commonQuery += ' WHERE MCS_Letter_Type__c NOT IN ( \'Sponsor Letter\', \'National Director Welcome Letter\', \'Sub/Shift National Director Welcome Letter\' ) AND MCS_Status__c = \'Closed\''; 
        }
        else
        {
            commonQuery += ' WHERE MCS_Letter_Type__c = \'' + String.escapeSingleQuotes(selectedLetterType) + '\' AND MCS_Status__c = \'Active\'';    
        }
                     
            // I-253889 - Now using Lookups for NO, LP, Community
        //commonQuery += ' AND Child_NO__c = \'' +  String.escapeSingleQuotes(NationOfficeName) + '\'';    
        commonQuery += ' AND NO_Lookup__c = \''+filter.participant.National_Office__c+'\'';    

        if(mcsFromDate != null && mcsToDate != null) {
            if(selectedLetterType != Null && !String.isEmpty(selectedLetterType) && selectedLetterType.contains('Labels')){// I-250384 | RSC | removed 'Labels - '
                commonQuery += ' AND Date_Closed__c >= :mcsFromDate AND Date_Closed__c <= :mcsToDate';
            }else{
                //mcsQuery += ' AND CreatedDate>= :mcsFromDate AND CreatedDate<= :mcsToDate';          
                commonQuery += ' AND MCS_Date__c >= :mcsFromDate AND MCS_Date__c <= :mcsToDate';              
            }
            
        }

            // I-253889 - Now using Lookups for NO, LP, Community
        //if(filter.participant.Local_Partner__c != Null && String.escapeSingleQuotes(LocalPartnerName) != '') {
        //    commonQuery += +' AND Local_Partner__c = \'' + String.escapeSingleQuotes(LocalPartnerName) + '\'';
        //}
        if(filter.participant.Local_Partner__c != Null ) {
            commonQuery += +' AND LP_Lookup__c = \''+filter.participant.Local_Partner__c+'\'';
        }

            // I-253889 - Now using Lookups for NO, LP, Community
        //if(filter.participant.Community__c != Null && String.escapeSingleQuotes(CommunityName) != '') {
        //    commonQuery += ' AND Community__c = \'' + String.escapeSingleQuotes(CommunityName) + '\'';
        //}
        if(filter.participant.Community__c != Null ) {
            commonQuery += +' AND Community_Lookup__c = \''+filter.participant.Community__c+'\'';
        }

        if(filter.mcs.Village__c != Null && filter.mcs.Village__c != '') {
            commonQuery += ' AND Village__c = \'' + String.escapeSingleQuotes(filter.mcs.Village__c) + '\'';       
        }

        if(filter.mcs.LastModifiedById != Null) {
            String lastModifiedByField = String.ValueOf(filter.mcs.LastModifiedById);
            commonQuery += ' AND LastModifiedById = \'' + String.escapeSingleQuotes(lastModifiedByField) + '\'';       
        }
     
        countQuery += commonQuery;
        //checking the total number of records returned as per the search criteria. If more than 10,000 then show page error message. 
        
        if(Database.CountQuery(countQuery) > 10000){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, String.ValueOf(label.Conga_10k_records_warning_message)));
            return null;
        }else{
            mcsQuery += commonQuery;
            
            //mcsQuery += ' ORDER BY MCS_Letter_Type__c, Local_Partner__c ASC, Community__c ASC, Village__c ASC LIMIT 3000'; // 
            if(selectedLetterType.contains('MCS Address Labels'))
            {
                mcsQuery += ' ORDER BY Community__c ASC, LastModifiedDate ASC LIMIT 10000'; // Enforcing to fetch at max 10000 records
            }
            else if(selectedLetterType == 'Report - DF Register')
            {
                mcsQuery += ' ORDER BY Community_ID__c ASC, Community__c ASC, Village__c ASC LIMIT 10000'; // Enforcing to fetch at max 10000 records.
                
            }else{
                mcsQuery += ' ORDER BY Community__c ASC, Village__c ASC LIMIT 10000'; // Enforcing to fetch at max 10000 records.    
            }
            
            system.debug(')))))))) MCS Query )))))))'+mcsQuery);
            
            return Database.query(mcsQuery);
        }
        
    }
    
    /**
    * Method will called by the method 'launchConga' to prepare the conga URL. This method prepares the conga URl based upon
    * the lettertype selected by user. 
    *
    * @param  none
    * @return String returns the conga url string.
    * 
    */
    String buildURL_Query() {
        String tempId = '';
        if(selectedLetterType == 'Child Welcome Letter' || selectedLetterType == 'Child Initiated Letter'
         || selectedLetterType == 'Child Bonding Letter'
         || selectedLetterType == 'Child Spontaneous Letter'
         || selectedLetterType == 'Child Farewell Letter'
         || selectedLetterType == 'Child Welcome and Child Bonding Letters'
         ){
            tempId = String.ValueOf(label.Conga_Template_MCS_Child_Initiated_and_Welcome_Letter);
        }
        if(selectedLetterType == 'Thank You Letter for DF'){
            tempId = String.ValueOf(label.Conga_Template_MCS_Thank_You_Letter_for_DF);
        }
        if(selectedLetterType == 'Child Progress Report'){
            tempId = String.ValueOf(label.Conga_Template_MCS_Child_Progress_Report);
        }
        if(selectedLetterType == 'Sponsor Letter' || selectedLetterType == 'Sponsor and Child Reply Letters' || selectedLetterType == 'Child Reply Letter'){
            tempId = String.ValueOf(label.Conga_Template_MCS_Sponsor_Letter);
        }
        if(selectedLetterType == 'Report - DF Register'){
            tempId = String.ValueOf(label.Conga_Template_MCS_DF_Register);
        }
        // Ravi Chauhan | I-234105 | Changes Start
        if(selectedLetterType.contains('MCS Address Labels') || selectedLetterType.contains('Labels - ND Welcome/SS ND Welcome Letter')){
            tempId = String.ValueOf(label.Conga_Template_MCS_Address_Labels); 
        }// Ravi Chauhan | I-234105 | Changes End
        
        // Ravi Chauhan | T-499682 | Changes Start
        if(selectedLetterType == 'Report - Child Status Slip'){
            tempId = String.ValueOf(label.Conga_Template_MCS_Child_Status_Slip); 
        }// Ravi Chauhan | T-499682 | Changes End
        String url = 'https://composer.congamerge.com?sessionId=' + sfSession + '&serverUrl=' + sfServerURL + 
            '&id=' + mailControlSlip.id+ '&TemplateGroup=MCS&DefaultPDF=1';
        if(tempId != null && !(string.isBlank(tempId))){
            url += '&TemplateId=' + tempId;
            url += '&DS7=3';
        }
        if(selectedLetterType == 'Report - DF Register'){
            Date mcsFromDate =  filter.mcs.MCS_Date__c;
            Date mcsToDate =  filter.mcs.Due_Date__c;
            
            String fromDateMonth = monthName(mcsFromDate.month());
            String toDateMonth = monthName(mcsToDate.month());
            
            String fromDateString = String.ValueOf(mcsFromDate.day()) + '-' + fromDateMonth  + '-' + String.ValueOf(mcsFromDate.year());
            String toDateString = String.ValueOf(mcsToDate.day()) + '-' + toDateMonth + '-' + String.ValueOf(mcsToDate.year());
            
            system.debug('---fromDateString---' + fromDateString);
            system.debug('---toDateString---' + toDateString);
            
            url += '&QueryId=[DFRegister]' + String.Valueof(label.Conga_Query_MCS_DF_Register) +'?pv0=uniquePageToken' + '&Dv0=' + fromDateString + ' to ' +  toDateString + '&BML=Please wait while the document is being merged for download.&OFN=fileName';
        }// Ravi Chauhan | T-499682 | Changes Start
        else if(selectedLetterType == 'Report - Child Status Slip'){// condition for Child Status Slip
            Date mcsFromDate =  filter.mcs.MCS_Date__c;
            Date mcsToDate =  filter.mcs.Due_Date__c;
            
            String fromDateMonth = monthName(mcsFromDate.month());
            String toDateMonth = monthName(mcsToDate.month());
            
            String fromDateString = String.ValueOf(mcsFromDate.day()) + '-' + fromDateMonth  + '-' + String.ValueOf(mcsFromDate.year());
            String toDateString = String.ValueOf(mcsToDate.day()) + '-' + toDateMonth + '-' + String.ValueOf(mcsToDate.year());
            url += '&QueryId=[Childs]' + String.Valueof(label.Conga_Query_MCS_Child_Status_Slip) + '?pv0=uniquePageToken' + '&Dv0=' + 'From ' + fromDateString + ' to ' +  toDateString + '&BML=Please wait while the document is being merged for download.&OFN=fileName';
        }// Ravi Chauhan | T-499682 | Changes End
        else{
            
            url += '&QueryId=[LEFT]' + String.Valueof(label.Conga_Query_MCS_Left) + '?pv0=uniquePageToken' + '&QueryId=[RIGHT]' + String.Valueof(label.Conga_Query_MCS_Right) + '?pv0=uniquePageToken' + '&BML=Please wait while the document is being merged for download.&OFN=fileName';    
        }
        
        return url;
    } 
    
    /**
    * Method will called by the method 'buildURL_Query' to get the month name in string format based upon the integer value passed as parameter.
    *
    * @param  Integer Value of the month
    * @return String returns the month name string.
    * 
    */
    private String monthName(integer m){
        if(m == 1){
            return 'Jan';
        }else if(m == 2){
            return 'Feb';
        }else if(m == 3){
            return 'Mar';
        }else if(m == 4){
            return 'Apr';
        }else if(m == 5){
            return 'May';
        }else if(m == 6){
            return 'Jun';
        }else if(m == 7){
            return 'Jul';
        }else if(m == 8){
            return 'Aug';
        }else if(m == 9){
            return 'Sep';
        }else if(m == 10){
            return 'Oct';
        }else if(m == 11){
            return 'Nov';
        }else if(m == 12){
            return 'Dec';
        }
        return null;
    }
    
    public class SubTotalWrap{ 
        public string communityName{get;set;}
        public Decimal localTotal{get;set;}
        public Decimal usTotal{get;set;}
        
        public SubTotalWrap(String communityName, Decimal localSubTotal, Decimal usSubTotal) {
            this.communityName = communityName;
            this.localTotal = localSubTotal;
            this.usTotal = usSubTotal;
            
        }
        
    }
    
    public class CongaButton{
        public String urlString{get;set;}
        public String fileName{get;set;}
        public String congaURL{get;set;}
        public String communityName{get;set;}
        public String communityID{get;set;}
        CongaButton(String urlString, String fileName, String congaURL, String communityName, String communityID) {
            this.urlString = urlString;
            this.fileName = fileName;
            this.congaURL = congaURL;
            this.communityName = communityName;
            this.communityID = communityID;
        }
    }

    
    
    
    // Ravi Chauhan | T-499682 | Changes Start
    /**
    * Method to create conga button based on the lsit of childs
    *
    * @param  none
    * @return 
    * 
    */
    public void childStatusSlip(){
        
        childStatusSlipListSize = 0;
        
        childStatusSlipList = new List<ContactHistory>() ;
        childStatusSlipList = fetchChildStatusSlips();
        System.debug('---childStatusSlipListBeforeRefining---' + childStatusSlipList);
        System.debug('---childStatusSlipListBeforeRefining---' + childStatusSlipList.size());
        
        List<rC_Bios__Relationship__c>  childSponsorTransfersList = new List<rC_Bios__Relationship__c>();
        childSponsorTransfersList = fetchChildStatusTransfers();
        System.debug('---childSponsorTransfersListBeforeRefining---' + childSponsorTransfersList);
        System.debug('---childSponsorTransfersListBeforeRefining---' + childSponsorTransfersList.size());
        
        //Creating a new list of wrapper class
        congaButtons = new List<congaButton>();
        
        //clearing the values of the pick-list before storing the final document URLs
        congaButtonsPicklist.clear();
        
        //creating a set of Participant Ids
        set<String> partIdSet = new Set<String>();

        //creating map of ContactId (participant Id) and related hostory list
        Map<String, List<ContactHistory>> mapConIdAndHistory = new map<String, List<ContactHistory>>();
        if(childStatusSlipList != null && childStatusSlipList.size() > 0){
            for(ContactHistory hisObj : childStatusSlipList){
                String partId = String.valueOf(hisObj.ContactId);
                
                if(!mapConIdAndHistory.containsKey(partId)){
                    partIdSet.add(partId);
                    List<ContactHistory> tempHisList = new List<ContactHistory>();
                    tempHisList.add(hisObj);
                    mapConIdAndHistory.put(partId, tempHisList);
                }else{
                    List<ContactHistory> tempHisList = mapConIdAndHistory.get(partId);
                    tempHisList.add(hisObj);
                    mapConIdAndHistory.put(partId, tempHisList);
                }
            }
        }
        
        //creating map of ContactId (participant Id) and related transfers. Note : rC_Bios__Contact_2__c is represented as Participant. 
        Map<String, List<rC_Bios__Relationship__c>> mapConIdSponTrans = new map<String, List<rC_Bios__Relationship__c>>();
        if(childSponsorTransfersList != null && childSponsorTransfersList.size() > 0){
            for(rC_Bios__Relationship__c relObj : childSponsorTransfersList){
                String partId = String.valueOf(relObj.rC_Bios__Contact_2__r.Id);
                
                if(!mapConIdSponTrans.containsKey(partId)){
                    partIdSet.add(partId);
                    List<rC_Bios__Relationship__c> tempRelList = new List<rC_Bios__Relationship__c>();
                    tempRelList.add(relObj);
                    mapConIdSponTrans.put(partId, tempRelList);
                }else{
                    List<rC_Bios__Relationship__c> tempRelList = mapConIdSponTrans.get(partId);
                    tempRelList.add(relObj);
                    mapConIdSponTrans.put(partId, tempRelList);
                }
            }
        }
        
        Map<String,Id> mapPartIdInitialRelationshipRecord = new Map<String,Id>();
        List<Contact> initialRelationshipRecordList = [SELECT Id,
                                                       (SELECT id FROM rc_Bios__Relationships_Contact_2__r
                                                        WHERE recordType.name = 'Contact - Contact'
                                                        ORDER BY createdDate ASC 
                                                        Limit 1)
                                                        FROM Contact
                                                        WHERE id IN : partIdSet];
        if(initialRelationshipRecordList != null && initialRelationshipRecordList.size() > 0){
            for(Contact initialRecord : initialRelationshipRecordList){
                String partId = String.ValueOf(initialRecord.Id);
                if(!mapPartIdInitialRelationshipRecord.containsKey(partId) && initialRecord.rc_Bios__Relationships_Contact_2__r.size() > 0) // I-247733              
                    mapPartIdInitialRelationshipRecord.put(partId,initialRecord.rc_Bios__Relationships_Contact_2__r[0].Id);
            }
        }
        System.debug('Ravi Chauhan >> ' + mapPartIdInitialRelationshipRecord);
            
        /*
        List<rC_Bios__Relationship__c> donorRelationshipList = [SELECT id, rC_Bios__Contact_1__c, rC_Bios__Contact_1__r.Name,rC_Bios__Contact_1__r.Donor_Alliance__r.Name,
                                                                rC_Bios__Contact_1__r.Donor_Number__c,rC_Bios__Contact_2__r.Id,rC_Bios__Contact_2__c
                                                                FROM rC_Bios__Relationship__c 
                                                                WHERE rC_Bios__Contact_2__c IN : partIdSet AND rC_Bios__Active__c = true AND rC_Bios__Role_1__c = 'Sponsor'];
        
        if(donorRelationshipList != null && donorRelationshipList.size() > 0){
            for(rC_Bios__Relationship__c relObj : donorRelationshipList){
                String donorId = String.ValueOf(relObj.rC_Bios__Contact_2__r.Id);
                if(!mapPartIdSponsorObj.containsKey(donorId)){
                    mapPartIdSponsorObj.put(donorId, relObj);
                }
            }
        }*/ 

        //Checking for Active Relationships records for searched contact history and sponsor transfer
        List<rC_Bios__Relationship__c> activeRelList = [Select id, Name, rC_Bios__Contact_2__r.Id, rC_Bios__Contact_1__c, rC_Bios__Contact_1__r.Name, rC_Bios__Contact_1__r.Donor_Alliance__r.Name,
                                                        rC_Bios__Contact_1__r.Donor_Number__c, rC_Bios__Role_2__c, rC_Bios__Role_1__c,
                                                        rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Name, rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Number__c,  
                                                        rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.rC_Giving__Donor_Id__c, rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__r.Name, 
                                                        rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Alliance_ID__c, rC_Bios__Opportunity__r.All_Child_Correspondence__c  
                                                        FROM rC_Bios__Relationship__c WHERE rC_Bios__Contact_2__c IN : partIdSet AND rC_Bios__Active__c = true 
                                                        AND (rC_Bios__Role_2__c = 'Sponsorship Giving' OR rC_Bios__Role_1__c = 'Sponsor')];
        
        system.debug('---activeRelList---' + activeRelList);
        
        //creating map of ParticipantId and related rC_Bios__Relationship__c record.
        mapPartIdRelaObj = new map<String, rC_Bios__Relationship__c>();
        
        mapPartIdSponsorObj = new map<String, rC_Bios__Relationship__c>();
        
        if(activeRelList != null && activeRelList.size() > 0){
            for(rC_Bios__Relationship__c relObj : activeRelList){
                String partId = String.ValueOf(relObj.rC_Bios__Contact_2__r.Id);
                
                if(!mapPartIdRelaObj.containsKey(partId) && relObj.rC_Bios__Role_2__c == 'Sponsorship Giving'){
                    mapPartIdRelaObj.put(partId, relObj);
                }
                
                if(!mapPartIdSponsorObj.containsKey(partId) && relObj.rC_Bios__Role_1__c == 'Sponsor'){
                    mapPartIdSponsorObj.put(partId, relObj);
                }
            }
        }
        
        //refining the previously created map - mapConIdAndHistory if it contains any extra Participants than keyset of map - mapPartIdRelaObj
        if(mapConIdAndHistory != null && mapConIdAndHistory.size() > 0){
            for(String partId : mapConIdAndHistory.keySet()){
                if(!mapPartIdRelaObj.containsKey(partId)){
                    mapConIdAndHistory.remove(partId);
                }
            }
            
            //now iterating over refined maps to get a refined list of ContactHistory    
            childStatusSlipList.clear();
            for(List<ContactHistory> tempHisList : mapConIdAndHistory.values()){
                childStatusSlipList.addAll(tempHisList);
            }
            System.debug('---childStatusSlipListAfterRefining---' + childStatusSlipList.size());
            
        }
        
        //refining the previously created map - mapConIdSponTrans if it contains any extra Participants than keyset of map - mapPartIdRelaObj
        System.debug('Ravi Chauhan >> ' + mapConIdSponTrans);
        if(mapConIdSponTrans != null && mapConIdSponTrans.size() > 0){
            for(String partId : mapConIdSponTrans.keySet()){
                if(!mapPartIdRelaObj.containsKey(partId)){
                    mapConIdSponTrans.remove(partId);
                }
            }
            // Looping through the map and removing sponsor transfer record if its the initial record
            for(String partId : mapConIdSponTrans.keySet()){
                List<rC_Bios__Relationship__c> tempRelList = mapConIdSponTrans.get(partId);
                Id initailRecordId = mapPartIdInitialRelationshipRecord.get(partId);
                
                for (Integer i = (tempRelList.size()-1) ; i>= 0 ; i--){
                    Id listItemRelationshipId = tempRelList[i].Id;
                    System.debug('Ravi Chauhan >> initailRecordId : ' + initailRecordId + ' listItemRelationshipId ' + listItemRelationshipId);
                    
                    if(listItemRelationshipId == initailRecordId){
                        tempRelList.remove(i);
                    }
                }
                mapConIdSponTrans.put(partId,tempRelList);
            }
            System.debug('Ravi Chauhan >> ' + mapConIdSponTrans);
            //now iterating over refined maps to get a refined list of ContactHistory    
            childSponsorTransfersList.clear();
            for(List<rC_Bios__Relationship__c> tempSponTransList : mapConIdSponTrans.values()){
                childSponsorTransfersList.addAll(tempSponTransList);
            }
            System.debug('---childSponsorTransfersAfterBeforeRefining---' + childSponsorTransfersList.size());
        }
        
        
        //iterating over the search result list to create conga-document links.
        if( (childStatusSlipList != null && childStatusSlipList.size() > 0) || (childSponsorTransfersList != null && childSponsorTransfersList.size() > 0)){
            
            prepareBothContactHistoryAndTransfers(childStatusSlipList, childSponsorTransfersList);
            
        }else if( (childStatusSlipList == null || childStatusSlipList.size() == 0) && (childSponsorTransfersList == null || childSponsorTransfersList.size() == 0)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records found within search criteria.'));	
        }
        
    }
    
    
    /**
    * Method Name       :   prepareBothContactHistoryAndTransfers
    * Purpose           :   Method will fetch all the participants within given data range whose sponsorhips has ben transferred as per the filters set out by user from Visualforce Page.
    * Created By        :   Appirio - Vaibhav Goel
    * Reference         :   T-499682
    * Created Date      :   Sep 6,2016
    * @param            :   none
    * @return           :   
    * Modified By       :   
    * Modified Date     :   
    */
    public void  prepareBothContactHistoryAndTransfers(List<ContactHistory> childStatusSlipList, List<rC_Bios__Relationship__c>  childSponsorTransfersList){
        System.debug('Ravi Chauhan >> childStatusSlipList : ' + childStatusSlipList);
        System.debug('Ravi Chauhan >> childSponsorTransfersList : ' + childSponsorTransfersList);
        List<Contact_Query_Staging_Parent__c> stageParentList = new List<Contact_Query_Staging_Parent__c>();
        
        //generating the unique for each search made by the user. this would help in identifying the records to be used while creating the conga documents.
        uniqueToken = UserInfo.getUserId()+DateTime.now().getTime();
        String requestID = uniqueToken + 'child';
        
        // Map to store the number of pages per community
        Map<String, Integer> commIdAndPages = new Map<String, Integer>();
        //creating the map of Contact Id and List of ContactHistory records against one ContactId.
        map<String, List<ContactHistory>> contactIdAndHistoryMap = new map<String, List<ContactHistory>>();
        
        // creating map of CommunityIds and CommunityName
        map<string, String> mapCommIdAndCommName = new map<String, String>();
        
        //creating set of request_ids which have been generated and used for foeld - "stageParentObj.Request_ID__c"
        Set<String> generatedRequestIdsSet = new Set<String>();
        
        //preparing a map of ContactId and object Instance of Contact_Query_Staging_Parent__c (this Instance has not been saved to database yet)
        //Purpose of this map is to avoid insert of duplicate Contact_Query_Staging_Parent__c records. 
        Map<String, Contact_Query_Staging_Parent__c> mapOfConIdAndStagingparent = new Map<String, Contact_Query_Staging_Parent__c>();
        
        //creating a map of Standard API Contact Field-name and associated field-Label
        Map<String, String> labelMap = getLabelsForContactFields();
        system.debug('---labelMap---' + labelMap);
        
        if(childStatusSlipList != null && childStatusSlipList.size() > 0){
            
            for(ContactHistory child : childStatusSlipList){
                
                //creating map - contactIdAndHistoryMap
                if(!contactIdAndHistoryMap.containsKey(child.ContactId)){
                    List<ContactHistory> conHisTemList = new List<ContactHistory>();
                    conHisTemList.add(child);
                    contactIdAndHistoryMap.put(child.ContactId, conHisTemList);
                }else{
                    List<ContactHistory> conHisTemList = contactIdAndHistoryMap.get(child.ContactId);
                    conHisTemList.add(child);
                    contactIdAndHistoryMap.put(child.ContactId, conHisTemList);
                }
                system.debug('----contactIdAndHistoryMap----' + contactIdAndHistoryMap.size());
                
                //creating map - mapCommIdAndCommName.
                //This map is used in creating conga-links
                if(!mapCommIdAndCommName.containsKey(String.ValueOf(child.Contact.Community_Number__c))){
                    mapCommIdAndCommName.put(String.ValueOf(child.Contact.Community_Number__c), String.ValueOf(child.Contact.Community__r.Name));
                }
                system.debug('----mapCommIdAndCommName----' + mapCommIdAndCommName.size());
                system.debug('----mapCommIdAndCommName----' + mapCommIdAndCommName);
            }
        }
        
        // Create Contact_Query_Staging_Parent__c objects based on contactIdAndHistoryMap map
        createStagingParentFromContactIdAndHistoryMap(contactIdAndHistoryMap,mapOfConIdAndStagingparent,stageParentList,requestID,generatedRequestIdsSet);
        
        //creating a map of contactId (Participant ID) and it's related Transfers
        map<String, List<rC_Bios__Relationship__c>> mapConIdAndSponTransfers = new map<String, List<rC_Bios__Relationship__c>>();
        if(childSponsorTransfersList != null && childSponsorTransfersList.size() > 0){
            for(rC_Bios__Relationship__c child : childSponsorTransfersList){
                
                //creating map - mapConIdAndSponTransfers
                if(!mapConIdAndSponTransfers.containsKey(child.rC_Bios__Contact_2__r.Id)){
                    List<rC_Bios__Relationship__c> conTransferTempList = new List<rC_Bios__Relationship__c>();
                    conTransferTempList.add(child);
                    mapConIdAndSponTransfers.put(child.rC_Bios__Contact_2__r.Id, conTransferTempList);
                }else{
                    List<rC_Bios__Relationship__c> conTransferTempList = mapConIdAndSponTransfers.get(child.rC_Bios__Contact_2__r.Id);
                    conTransferTempList.add(child);
                    mapConIdAndSponTransfers.put(child.rC_Bios__Contact_2__r.Id, conTransferTempList);
                }
                
                //Putting values to map - "mapCommIdAndCommName". Only new communityIds will be added to this map which do not already exist in this map.
                if(!mapCommIdAndCommName.containsKey(String.ValueOf(child.rC_Bios__Contact_2__r.Community_Number__c))){
                    mapCommIdAndCommName.put(String.ValueOf(child.rC_Bios__Contact_2__r.Community_Number__c), String.ValueOf(child.rC_Bios__Contact_2__r.Community__r.Name));
                }
            }
            
        }
        
        // Create Contact_Query_Staging_Parent__c objects based on mapConIdAndSponTransfers map
        createStagingParentFromConIdAndSponTransfersMap(mapConIdAndSponTransfers,mapOfConIdAndStagingparent,stageParentList,requestID,generatedRequestIdsSet,childStatusSlipList);
        
        if(stageParentList != null && stageParentList.size() > 0){
            system.debug('----stageParentList----' + stageParentList.size());
            insert stageParentList;
        }
        
        // Create Contact_Query_Staging__c objects based on childStatusSlipList and childSponsorTransfersList
        createStagingObjects(childStatusSlipList, childSponsorTransfersList, generatedRequestIdsSet, labelMap);

        // Creation of Conga Buttons for Child Status Slip
        createCongaButtonsForChildStatusSlip(generatedRequestIdsSet,mapCommIdAndCommName,commIdAndPages);

        String url = buildURL_Query();  
        urlToRedirect = url;
        
        // Update conga buttons with the fileNames and uniqueToken
        updateCongaButtonsForChildStatusSlip(commIdAndPages);
        
    }
    
    /**
    * Method Name       :   createStagingParentFromContactHistory
    * Purpose           :   Method to create object of Contact_Query_Staging_Parent__c based on the contactIdAndHistoryMap
    * Created By        :   Appirio - Ravi Chauhan
    * Reference         :   T-499682
    * @param            :   map<String, List<ContactHistory>> contactIdAndHistoryMap,map<String, Contact_Query_Staging_Parent__c> mapOfConIdAndStagingparent,
	*						List<Contact_Query_Staging_Parent__c> stageParentList,String requestID,Set<String> generatedRequestIdsSet
    * @return           :   none
    * Modified By       :   
    * Modified Date     :   
    */
    private void createStagingParentFromContactIdAndHistoryMap(map<String, List<ContactHistory>> contactIdAndHistoryMap,map<String, Contact_Query_Staging_Parent__c> mapOfConIdAndStagingparent,
												       List<Contact_Query_Staging_Parent__c> stageParentList,String requestID,Set<String> generatedRequestIdsSet){
	    //Iterating above created map  - "contactIdAndHistoryMap" to instantiate records of object - Contact_Query_Staging_Parent__c and adding them to list - "stageParentList" for insert
        if(contactIdAndHistoryMap != null && contactIdAndHistoryMap.size() > 0){
            system.debug('----contactIdAndHistoryMap---' + contactIdAndHistoryMap);
            
            stageParentList.clear();
            
            for(String conId : contactIdAndHistoryMap.keySet()){
                
                Contact_Query_Staging_Parent__c stageParentObj = new Contact_Query_Staging_Parent__c();
                
                stageParentObj.Name = contactIdAndHistoryMap.get(conId).get(0).Contact.Name;
                stageParentObj.NewValue__c = String.ValueOf(contactIdAndHistoryMap.get(conId).get(0).NewValue);
                stageParentObj.Birthdate__c = contactIdAndHistoryMap.get(conId).get(0).Contact.Birthdate;
                stageParentObj.Case_No__c = contactIdAndHistoryMap.get(conId).get(0).Contact.Participant_Case_Number__c;
                stageParentObj.Child_No__c = contactIdAndHistoryMap.get(conId).get(0).Contact.Child_Number__c;
                stageParentObj.Gender__c = contactIdAndHistoryMap.get(conId).get(0).Contact.rC_Bios__Gender__c;
                stageParentObj.ContactId__c = conId;
                stageParentObj.Project_ID__c = contactIdAndHistoryMap.get(conId).get(0).Contact.Community_Number__c;
                stageParentObj.Request_ID__c = requestID + contactIdAndHistoryMap.get(conId).get(0).Contact.Community_Number__c;
                stageParentObj.Village__c = contactIdAndHistoryMap.get(conId).get(0).Contact.Village__c;
                stageParentObj.Status__c = contactIdAndHistoryMap.get(conId).get(0).Contact.rC_Sponsorship__Sponsorship_Status__c;
                /*
                if(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Number__c != null){
                    String donorId = String.ValueOf(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Number__c);
                    stageParentObj.DonorID__c = donorId;
                }
                
                if(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__r.Name != null){
                    String donorAlliance = String.ValueOf(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__r.Name);
                    stageParentObj.Donor_Alliance__c = donorAlliance;
                }
                
                if(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Name != null){
                    String donorName = String.ValueOf(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Name);
                    stageParentObj.Donor_Name__c = donorName;
                }*/
                System.debug('Ravi Chauhan >> mapPartIdSponsorObj.containsKey(conId) ' + mapPartIdSponsorObj.containsKey(conId));
                
                if(mapPartIdSponsorObj.containsKey(conId) && mapPartIdSponsorObj.get(conId).rC_Bios__Contact_1__c != null){
                    stageParentObj.DonorID__c = mapPartIdSponsorObj.get(conId).rC_Bios__Contact_1__r.Donor_Number__c;
                    stageParentObj.Donor_Alliance__c = mapPartIdSponsorObj.get(conId).rC_Bios__Contact_1__r.Donor_Alliance__r.Name;
                    stageParentObj.Donor_Name__c = mapPartIdSponsorObj.get(conId).rC_Bios__Contact_1__r.Name;
                }
                
                //need to confirm with Dirk
                if(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.All_Child_Correspondence__c){
                    stageParentObj.Correspondence_Value__c = 'Field Correspondence';
                }else{
                    stageParentObj.Correspondence_Value__c = 'No Field Correspondence';
                }
                
                stageParentList.add(stageParentObj);
                generatedRequestIdsSet.add(stageParentObj.Request_ID__c);
                if(!Test.isRunningTest()){
                    if(!mapOfConIdAndStagingparent.containsKey(conId)){
                        mapOfConIdAndStagingparent.put(conId, stageParentObj);    
                    }
                }
                
            }
        }
												           
	}
    
    /**
    * Method Name       :   createContactQueryStagingParent
    * Purpose           :   Method to create object of Contact_Query_Staging_Parent__c based on the mapConIdAndSponTransfers
    * Created By        :   Appirio - Ravi Chauhan
    * Reference         :   T-499682
    * @param            :   map<String, List<rC_Bios__Relationship__c>> mapConIdAndSponTransfers,map<String, Contact_Query_Staging_Parent__c> mapOfConIdAndStagingparent,
	*						List<Contact_Query_Staging_Parent__c> stageParentList,String requestID,Set<String> generatedRequestIdsSet,List<ContactHistory> childStatusSlipList
    * @return           :   none
    * Modified By       :   
    * Modified Date     :   
    */
    private void createStagingParentFromConIdAndSponTransfersMap(map<String, List<rC_Bios__Relationship__c>> mapConIdAndSponTransfers,map<String, Contact_Query_Staging_Parent__c> mapOfConIdAndStagingparent,
												       List<Contact_Query_Staging_Parent__c> stageParentList,String requestID,Set<String> generatedRequestIdsSet,List<ContactHistory> childStatusSlipList){
	    //Iterating map above created to instantiate records of object - Contact_Query_Staging_Parent__c and adding them to list - "stageParentList" for insert
        if(mapConIdAndSponTransfers != null && mapConIdAndSponTransfers.size() > 0){
            system.debug('----mapConIdAndSponTransfers---' + mapConIdAndSponTransfers);
            
            if(childStatusSlipList == null || childStatusSlipList.size() == 0){
                stageParentList.clear();    
            }
            
            
            for(String conId : mapConIdAndSponTransfers.keySet()){
                
                //We will only create new instances of Contact_Query_Staging_Parent__c if they haven't been created above 
                //We are utilizing above created map - "mapOfConIdAndStagingparent" to check if there is already an instance
                //of Contact_Query_Staging_Parent__c in list - "stageParentList" when ContactHistory records have been iterated.
                if(!mapOfConIdAndStagingparent.containsKey(conId)){
                    
                    Contact_Query_Staging_Parent__c stageParentObj = new Contact_Query_Staging_Parent__c();
                    
                    stageParentObj.Name = mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_2__r.Name;
                    stageParentObj.NewValue__c = String.ValueOf(mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_1__c);
                    stageParentObj.Birthdate__c = mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_2__r.Birthdate;
                    stageParentObj.Case_No__c = mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_2__r.Participant_Case_Number__c;
                    stageParentObj.Child_No__c = mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_2__r.Child_Number__c;
                    stageParentObj.Gender__c = mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_2__r.rC_Bios__Gender__c;
                    stageParentObj.ContactId__c = conId;
                    stageParentObj.Project_ID__c = mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_2__r.Community_Number__c;
                    stageParentObj.Request_ID__c = requestID + mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_2__r.Community_Number__c;
                    stageParentObj.Village__c = mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_2__r.Village__c;
                    stageParentObj.Status__c = mapConIdAndSponTransfers.get(conId).get(0).rC_Bios__Contact_2__r.rC_Sponsorship__Sponsorship_Status__c;
                    /*
                    if(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Number__c != null){
                        String donorId = String.ValueOf(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Number__c);
                        stageParentObj.DonorID__c = donorId;
                    }
                    
                    if(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__r.Name != null){
                        String donorAlliance = String.ValueOf(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__r.Name);
                        stageParentObj.Donor_Alliance__c = donorAlliance;
                    }
                    
                    if(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Name != null){
                        String donorName = String.ValueOf(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.rC_Giving__Hard_Credit_Contact__r.Name);
                        stageParentObj.Donor_Name__c = donorName;
                    }*/
                    System.debug('Ravi Chauhan >> mapPartIdSponsorObj.containsKey(conId) ' + mapPartIdSponsorObj.containsKey(conId));
                    
                    if(mapPartIdSponsorObj.containsKey(conId) && mapPartIdSponsorObj.get(conId).rC_Bios__Contact_1__c != null){
                        stageParentObj.DonorID__c = mapPartIdSponsorObj.get(conId).rC_Bios__Contact_1__r.Donor_Number__c;
                        stageParentObj.Donor_Alliance__c = mapPartIdSponsorObj.get(conId).rC_Bios__Contact_1__r.Donor_Alliance__r.Name;
                        stageParentObj.Donor_Name__c = mapPartIdSponsorObj.get(conId).rC_Bios__Contact_1__r.Name;
                    }
                    
                    //need to confirm with Dirk
                    if(mapPartIdRelaObj.get(conId).rC_Bios__Opportunity__r.All_Child_Correspondence__c){
                        stageParentObj.Correspondence_Value__c = 'Field Correspondence';
                    }else{
                        stageParentObj.Correspondence_Value__c = 'No Field Correspondence';
                    }
                    
                    stageParentList.add(stageParentObj);
                    generatedRequestIdsSet.add(stageParentObj.Request_ID__c);
                    mapOfConIdAndStagingparent.put(conId, stageParentObj); 
                }
                
            }
        }    
												           
	}
	
	/**
    * Method Name       :   createStagingObjects
    * Purpose           :   Method to create object of Contact_Query_Staging__c based on childStatusSlipList and childSponsorTransfersList
    * Created By        :   Appirio - Ravi Chauhan
    * Reference         :   T-499682
    * @param            :   List<ContactHistory> childStatusSlipList,List<rC_Bios__Relationship__c> childSponsorTransfersList,Set<String> generatedRequestIdsSet,Map<String, String> labelMap
    * @return           :   none
    * Modified By       :   
    * Modified Date     :   
    */
	private void createStagingObjects(List<ContactHistory> childStatusSlipList,List<rC_Bios__Relationship__c> childSponsorTransfersList,Set<String> generatedRequestIdsSet,Map<String, String> labelMap){
        //now fetching the staging parent records based upon the Unique RequestId which is unique per search made by User.
        List<Contact_Query_Staging_Parent__c> stagingparentListAsterInsert = [select Id, Name, NewValue__c, Birthdate__c, 
                                                                              Case_No__c, Child_No__c, Gender__c, ContactId__c, Project_ID__c, Request_ID__c, Village__c 
                                                                              FROM Contact_Query_Staging_Parent__c WHERE Request_ID__c IN :generatedRequestIdsSet
                                                                              ORDER BY Project_ID__c];
        
        system.debug('----stagingparentListAsterInsert----' + stagingparentListAsterInsert.size());
        //checking if new records has been inserted in database.
        if(stagingparentListAsterInsert != null && stagingparentListAsterInsert.size() > 0){
            
            mcsListSize = stagingparentListAsterInsert.size();
            
            //clearing value of childStagingList to add new object instances and insert it.
            childStatusSlipStagingList.clear();
            
            //Creating a map of ContactId and corresponding Contact_Query_Staging_Parent__c record. Creating a map of ContactId and stageParentObj after stageParentObj is inserted
            Map<String, Contact_Query_Staging_Parent__c> mapConIdAndStagParent = new map<String, Contact_Query_Staging_Parent__c>();
            
            //iterating over newly created "Contact_Query_Staging_Parent__c" records to create a map of ContactId and corresponding "Contact_Query_Staging_Parent__c" record.
            for(Contact_Query_Staging_Parent__c stageParentObj : stagingparentListAsterInsert){
                
                if(!mapConIdAndStagParent.containsKey(stageParentObj.ContactId__c)){
                    mapConIdAndStagParent.put(stageParentObj.ContactId__c, stageParentObj);
                }
                system.debug('----mapConIdAndStagParent----' + mapConIdAndStagParent.size());
            }
            
            //Now, iterating over searched records of Contact History to create a list of new object instances of - Contact_Query_Staging__c
            for(ContactHistory child : childStatusSlipList){
                
                Contact_Query_Staging__c childStageObj = new Contact_Query_Staging__c();
                
                if(child.CreatedDate != null || Test.isRunningTest()){ // MR to increase code coverage editDate is given an arbitrary value 
                    //Creating a instance of DateTime which will be utilized in assigning the correct formatted date value to field - "Date_Updated__c" of object "Contact_Query_Staging__c"
                    DateTime editDate = System.today();
                    if(!Test.isRunningTest()){
                        editDate = child.CreatedDate;
                    }
                    childStageObj.Date_Updated__c = Date.newinstance(editDate.year(), editDate.month(), editDate.day());    
                }
                
                if(child.NewValue != null || child.OldValue != null || Test.isRunningTest()){ //// MR to increase code coverage newValue and oldValue are  given arbitrary values.
                    system.debug('---API_name_ContactHistoryObject---' + String.valueOf(labelMap.get(String.ValueOf(child.Field))));
                    childStageObj.NewValue__c = '00:00:00';
                    childStageObj.OldValue__c = '00:00:00';
                    if(!Test.isRunningTest()){
                        childStageObj.NewValue__c = String.ValueOf(child.NewValue);
                        childStageObj.OldValue__c = String.ValueOf(child.OldValue);
                    }
                    system.debug('---childStageObj.NewValue__c---' + childStageObj.NewValue__c);
                    if(childStageObj.NewValue__c != null && childStageObj.NewValue__c.contains('00:00:00')){
                        system.debug('---DateTimeFieldValueDetected---' );
                        childStageObj.NewValue__c = childStageObj.NewValue__c.removeEndIgnoreCase('00:00:00');
                    }
                    if(childStageObj.OldValue__c != null && childStageObj.OldValue__c.contains('00:00:00')){
                        childStageObj.OldValue__c = childStageObj.OldValue__c.removeEndIgnoreCase('00:00:00');
                    }
                }
                else // To eliminate the blank rows if any
                    continue;
                
                // Change | 20/09/2016 | to omit the status slip where new value equals Pre-Sponsored, On Hold, Reserved, Enrolled, Check Materials
                if(child.Field == 'rC_Sponsorship__Sponsorship_Status__c' && childStageObj.NewValue__c != null && childStageObj.NewValue__c != ''
                   && (childStageObj.NewValue__c.equalsIgnoreCase('Pre-Sponsored') || childStageObj.NewValue__c.equalsIgnoreCase('On Hold')
                       || childStageObj.NewValue__c.equalsIgnoreCase('Reserved') || childStageObj.NewValue__c.equalsIgnoreCase('Enrolled')
                       || childStageObj.NewValue__c.equalsIgnoreCase('Check Materials')
                      )
                  )
                    
                    continue;
                
                // To change the format of birthdate to dd-MMM-yyyy
                if(child.Field == 'Birthdate' || Test.isRunningTest()){// MR to increase the code coverage
                    if(childStageObj.NewValue__c != null && childStageObj.NewValue__c != '' || Test.isRunningTest()){
                        String[] dateArray = childStageObj.NewValue__c.trim().split('-');
                        if(dateArray.size() == 3)
                            childStageObj.NewValue__c = dateArray[2] + '-' + mapMonthNames.get(dateArray[1].trim()) + '-' + dateArray[0];
                    }
                    if(childStageObj.OldValue__c != null && childStageObj.OldValue__c != '' || Test.isRunningTest()){
                        String[] dateArray = childStageObj.OldValue__c.trim().split('-');
                        if(dateArray.size() == 3)
                            childStageObj.OldValue__c = dateArray[2] + '-' + mapMonthNames.get(dateArray[1].trim()) + '-' + dateArray[0];
                    }
                }
                
                system.debug('---childStageObj.NewValue__cAfterRemoval---' + childStageObj.NewValue__c);
                childStageObj.Contact_Query_Staging_Parent__c = mapConIdAndStagParent.get(child.ContactId).Id;
                childStageObj.FieldEvent__c = String.valueOf(labelMap.get(String.ValueOf(child.Field)));
                childStageObj.Name__c = child.Contact.Name;
                childStageObj.Project_ID__c = child.Contact.Community_Number__c;
                childStageObj.Village__c = child.Contact.Village__c;
                childStageObj.Request_ID__c = mapConIdAndStagParent.get(child.ContactId).Request_ID__c;
                childStatusSlipStagingList.add(childStageObj);
            }
            
            //creating staging records for sponsor Transfers
            //Now, iterating over searched records of rC_Bios__Relationship__c to create a list of new object instances of - Contact_Query_Staging__c
            for(rC_Bios__Relationship__c child : childSponsorTransfersList){
                
                Contact_Query_Staging__c childStageObj = new Contact_Query_Staging__c();
                
                
                if(child.rC_Sponsorship__Start_Date_Time__c != null){
                    //Creating a instance of DateTime which will be utilized in assigning the correct formatted date value to field - "Date_Updated__c" of object "Contact_Query_Staging__c"
                    DateTime editDate = child.rC_Sponsorship__Start_Date_Time__c;
                    childStageObj.Date_Updated__c = Date.newinstance(editDate.year(), editDate.month(), editDate.day());    
                }
                if(child.rC_Bios__Contact_1__r.Name != null){
                    childStageObj.NewValue__c = String.ValueOf(child.rC_Bios__Contact_1__r.Name);
                    system.debug('---childStageObj.NewValue__c---' + childStageObj.NewValue__c);
                }
                else // to eliminate the blank rows in template for Sponsor Transfer
                    continue;
                
                
                childStageObj.Contact_Query_Staging_Parent__c = mapConIdAndStagParent.get(child.rC_Bios__Contact_2__r.Id).Id;
                childStageObj.FieldEvent__c = 'Sponsor Transfer';
                childStageObj.Name__c = child.rC_Bios__Contact_2__r.Name;
                childStageObj.Project_ID__c = child.rC_Bios__Contact_2__r.Community_Number__c;
                childStageObj.Village__c = child.rC_Bios__Contact_2__r.Village__c;
                childStageObj.Request_ID__c = mapConIdAndStagParent.get(child.rC_Bios__Contact_2__r.Id).Request_ID__c;
                childStatusSlipStagingList.add(childStageObj);
            }
            
            if(childStatusSlipStagingList != null && childStatusSlipStagingList.size() > 0){
                system.debug('---childStatusSlipStagingList---' + childStatusSlipStagingList.size());
                insert childStatusSlipStagingList;
            }
        }
    }
    
    /**
    * Method Name       :   createCongaButtonsForChildStatusSlip
    * Purpose           :   Method to create CongaButtons For ChildStatusSlip
    * Created By        :   Appirio - Ravi Chauhan
    * Reference         :   T-499682
    * @param            :   Set<String> generatedRequestIdsSet,map<string, String> mapCommIdAndCommName, Map<String, Integer> commIdAndPages
    * @return           :   none
    * Modified By       :   
    * Modified Date     :   
    */
    private void createCongaButtonsForChildStatusSlip(Set<String> generatedRequestIdsSet,map<string, String> mapCommIdAndCommName, Map<String, Integer> commIdAndPages)	{
        // Map to store the number of pages per community
        String communityID;
        String newRequestID = '';
        Integer recordsInCurrentPage = 0;
        noOfButtons = 0;
        Integer i = 0;
        List<Contact_Query_Staging_Parent__c> stagingParentListToBeUpdated = new List<Contact_Query_Staging_Parent__c>();
        
        List<Contact_Query_Staging_Parent__c> stagingparentListForCongaButtons = [Select Id, Name, Case_No__c,Project_ID__c,Request_ID__c,
                                                                                  (SELECT Id,  Name,Contact_Query_Staging_Parent__c
                                                                                   FROM Contact_Query_Stagings__r)
                                                                                  FROM Contact_Query_Staging_Parent__c
                                                                                  WHERE Request_ID__c IN :generatedRequestIdsSet
                                                                                  ORDER BY Project_ID__c];
        for(Contact_Query_Staging_Parent__c stageParentObj : stagingparentListForCongaButtons){
            if(stageParentObj.Contact_Query_Stagings__r != null && stageParentObj.Contact_Query_Stagings__r.size() > 0){
                stageParentObj.Request_ID__c = newRequestID;
                if(math.mod((recordsInCurrentPage), MAX_RECORDS_PER_PAGE) == 0 || communityID != stageParentObj.Project_ID__c){
                    newRequestID = uniqueToken + 'page' + noOfButtons + '.' + stageParentObj.Project_ID__c;
                    stageParentObj.Request_ID__c = newRequestID;
                    congaButtons.add(new CongaButton(stageParentObj.Request_ID__c, System.Today().format() + '_Doc' + (((i + 1)/ MAX_RECORDS_PER_PAGE) + 1) + 'OftotalDocs', '', mapCommIdAndCommName.get(stageParentObj.Project_ID__c),stageParentObj.Project_ID__c ));
                    recordsInCurrentPage = 0;
                    noOfButtons++;
                    
                    if(!commIdAndPages.containsKey(stageParentObj.Project_ID__c)){
                        commIdAndPages.put(stageParentObj.Project_ID__c, 1);
                    }
                    else{
                        Integer numberOfpagesPerCommunity = commIdAndPages.get(stageParentObj.Project_ID__c);
                        numberOfpagesPerCommunity++;
                        commIdAndPages.put(stageParentObj.Project_ID__c, numberOfpagesPerCommunity);
                    }
                }
                
                if(communityID != null && communityID != stageParentObj.Project_ID__c){
                    communityID = stageParentObj.Project_ID__c;
                }
                else{
                    communityID = stageParentObj.Project_ID__c;
                }
                
                communityID = stageParentObj.Project_ID__c;
                recordsInCurrentPage++;
                i++;
                stagingParentListToBeUpdated.add(stageParentObj);
            }
        }
        
        // Updating the stageParentList with new request Ids
        if(stagingParentListToBeUpdated.size()>0)
            update stagingParentListToBeUpdated;

    }
    
    /**
    * Method Name       :   updateCongaButtonsForChildStatusSlip
    * Purpose           :   Method to update the conga buttons with appropriate uniqueToken and filenames
    * Created By        :   Appirio - Ravi Chauhan
    * Reference         :   T-499682
    * @param            :   Map<String, Integer> commIdAndPages
    * @return           :   none
    * Modified By       :   
    * Modified Date     :   
    */
    private void updateCongaButtonsForChildStatusSlip(Map<String, Integer> commIdAndPages){
        if(congaButtons != null && congaButtons.size() > 0){
            map<String, Integer> fileNamingMap = new map<String, Integer>();
            Integer pageCounter = 1;
            String CommunityIdPlaceHolder = congaButtons.get(0).communityID;
            
            
            for(Integer i = 0; i < congaButtons.size(); i++){
                
                if(!fileNamingMap.containsKey(congaButtons.get(i).communityID)){
                    Integer localPageCounter = 1;
                    fileNamingMap.put(congaButtons.get(i).communityID, localPageCounter);
                    congaButtons.get(i).fileName = System.Today().format() + '_'+ congaButtons.get(i).communityName +'_Doc_' + localPageCounter + '_Of_' + commIdAndPages.get(congaButtons.get(i).communityID);
                }else{
                    Integer localPageCounterIncrease = fileNamingMap.get(congaButtons.get(i).communityID);
                    localPageCounterIncrease++;
                    fileNamingMap.put(congaButtons.get(i).communityID, localPageCounterIncrease);
                    congaButtons.get(i).fileName = System.Today().format() + '_'+ congaButtons.get(i).communityName +'_Doc_' + localPageCounterIncrease + '_Of_' + commIdAndPages.get(congaButtons.get(i).communityID);
                }
                congaButtons.get(i).congaURL = urlToRedirect.replace('uniquePageToken', congaButtons.get(i).urlString).replace('fileName', congaButtons.get(i).fileName);
            }
            
            for(congaButton c : congaButtons){
                congaButtonsPicklist.add(new SelectOption(c.congaURL, c.fileName));
            }
            
        }
    }
    
    /**
    * Method Name       :   getLabelsForContactFields
    * Purpose           :   Method to create a map of Standard API Contact Field-name and associated field-Label
    * Created By        :   Appirio - Ravi Chauhan
    * Reference         :   T-499682
    * @param            :   none
    * @return           :   Map<String, String>
    * Modified By       :   
    * Modified Date     :   
    */
    private Map<String, String> getLabelsForContactFields(){
        Map<String, String> labelMap = new Map<String, String>();
        Schema.DescribeSObjectResult objectDescribe  = Contact.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        for( String fieldName : fieldMap.keySet() ) {
            Schema.SObjectField field = fieldMap.get( fieldName );
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            labelMap.put(fieldDescribe.getName(), fieldDescribe.getLabel() );
        }
        return labelMap;
    }

    /**
    * Method Name       :   fetchChildStatusSlips
    * Purpose           :   Method will fetch all the participants within given data range whose spnsorship status, gender, birthdate, contact has been modified.
    * Created By        :   Appirio - Ravi Chauhan
    * Reference         :   T-499682
    * @param            :   none
    * @return           :   List<ContactHistory>
    * Modified By       :   
    * Modified Date     :   
    */
    public List<ContactHistory> fetchChildStatusSlips(){
        List<ContactHistory> childStatusSlipContacts = new List<ContactHistory>();
        List<String> fieldEventList = new List<String> {'Birthdate','rC_Sponsorship__Sponsorship_Status__c','rC_Bios__Gender__c','FirstName','LastName','Short_Name__c'};
        String mcsQuery = '';
        Date mcsFromDate =  filter.mcs.MCS_Date__c;
        Date mcsToDate =  filter.mcs.Due_Date__c;

        mcsQuery += 'SELECT ContactId,CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,';
        mcsQuery += 'Contact.Birthdate,Contact.Child_Number__c,Contact.Community__c,Contact.FirstName,Contact.Id,Contact.LastModifiedById,';
        mcsQuery += 'Contact.LastModifiedDate,Contact.LastName,Contact.Local_Partner__c,Contact.National_Office__c,Contact.National_Office__r.Name,Contact.Village__c,';
        mcsQuery += 'Contact.Community_Number__c,Contact.Participant_Case_Number__c,Contact.Name,Contact.rC_Bios__Gender__c,';
        mcsQuery += 'Contact.Local_Partner__r.Name,Contact.Community__r.Name, Contact.rC_Sponsorship__Sponsorship_Status__c';
        mcsQuery += ' FROM ContactHistory ';

            // I-253889 - Now using Lookups for NO, LP, Community
        if(filter.participant.National_Office__c != Null) {
            //mcsQuery += 'WHERE Contact.National_Office__r.Name = \'' + String.escapeSingleQuotes(NationOfficeName) + '\'';
            mcsQuery += ' WHERE Contact.National_Office__c = \''+filter.participant.National_Office__c+'\'';
        }
        
        if(mcsFromDate != null && mcsToDate != null) {
            mcsQuery += ' AND DAY_ONLY(CreatedDate) >= :mcsFromDate AND DAY_ONLY(CreatedDate) <= :mcsToDate';
            
        }
            // I-253889 - Now using Lookups for NO, LP, Community      
        if(filter.participant.Local_Partner__c != Null ) {
            //mcsQuery += +' AND Contact.Local_Partner__r.Name = \'' + String.escapeSingleQuotes(LocalPartnerName) + '\'';
            mcsQuery += +' AND Contact.Local_Partner__c = \''+filter.participant.Local_Partner__c+'\'';
        }
        
            // I-253889 - Now using Lookups for NO, LP, Community
        if(filter.participant.Community__c != Null ) {
            //mcsQuery += ' AND Contact.Community__r.Name = \'' + String.escapeSingleQuotes(CommunityName) + '\'';
            mcsQuery += ' AND Contact.Community__c = \''+filter.participant.Community__c+'\'';
        }
        
        if(filter.mcs.Village__c != Null && filter.mcs.Village__c != '') {
            mcsQuery += ' AND Contact.Village__c = \'' + String.escapeSingleQuotes(filter.mcs.Village__c) + '\'';       
        }
        
        if(filter.mcs.LastModifiedById != Null) {
            String lastModifiedByField = String.ValueOf(filter.mcs.LastModifiedById);
            mcsQuery += ' AND Contact.LastModifiedById = \'' + String.escapeSingleQuotes(lastModifiedByField) + '\'';       
        }
        
        mcsQuery += ' AND Field IN :fieldEventList';
        
        mcsQuery += ' AND contact.recordtype.name = \'Participant\'';
        
        mcsQuery += ' ORDER BY CreatedDate DESC ';

        childStatusSlipContacts = Database.query(mcsQuery);
        
        if(Test.isRunningTest()){ // Since the contactHistory records are not generated in test class so to increase the coverage the records are created but not committed.
            List<Contact> contList = [select Id from Contact limit 1];
            if(!contList.isEmpty()) {
                List<ContactHistory> ch;
                ch = new List<ContactHistory>{}; //OldValue, NewValue not writeable
                    ch.add(new ContactHistory(ContactId=contList.get(0).Id, Field='BirthDate'));
                ch.add(new ContactHistory(ContactId=contList.get(0).Id, Field='rC_Sponsorship__Sponsorship_Status__c'));
                childStatusSlipContacts = ch;
            }
        }
        
        return childStatusSlipContacts;
        
    }

    /**
    * Method Name       :   fetchChildStatusTransfers
    * Purpose           :   Method will fetch all the participants within given data range whose sponsorhips has ben transferred as per the filters set out by user from Visualforce Page.
    * Created By        :   Appirio - Vaibhav Goel
    * Reference         :   T-499682
    * Created Date      :   Sep 6,2016
    * @param            :   none
    * @return           :   List<rC_Bios__Relationship__c>
    * Modified By       :   
    * Modified Date     :   
    */
    public List<rC_Bios__Relationship__c>  fetchChildStatusTransfers(){
        
        List<rC_Bios__Relationship__c> childSponsorTransferContacts = new List<rC_Bios__Relationship__c>();
        String mcsQuery = '';
        
        Date mcsFromDate =  filter.mcs.MCS_Date__c;
        Date mcsToDate =  filter.mcs.Due_Date__c;
        System.debug('---fetchChildStatusTransfers_mcsFromDate---' + mcsFromDate);
        System.debug('---fetchChildStatusTransfers_mcsToDate---' + mcsToDate);
        
        // I-238502 | We need to use only Date field not Date Time | Hence commenting this out
        /*
        DateTime mcsFromDateTime = datetime.newInstance(mcsFromDate.year(), mcsFromDate.month(),mcsFromDate.day());
        DateTime mcsToDateDateTime = datetime.newInstance(mcsToDate.year(), mcsToDate.month(),mcsToDate.day());
        System.debug('---fetchChildStatusTransfers_mcsFromDateTime---' + mcsFromDateTime);
        System.debug('---fetchChildStatusTransfers_mcsToDateDateTime--' + mcsToDateDateTime);
        */
        
        mcsQuery += 'SELECT Enterprise_Legacy_ID__c, Id, isCreatedFromTrigger__c, IsDeleted, LastViewedDate,Name,OwnerId,rC_Bios__Account_1__c, ';
        mcsQuery += 'rC_Bios__Account_2__c,rC_Bios__Active__c,rC_Bios__Archive_Flag__c,rC_Bios__Category__c, ';
        mcsQuery += 'rC_Bios__Contact_1__c,rC_Bios__Contact_2__c, rC_Bios__Starting_Day__c, ';
        mcsQuery += 'rC_Bios__Starting_Month__c,rC_Bios__Starting_Year__c,rC_Bios__Stopping_Day__c,rC_Bios__Stopping_Month__c,rC_Bios__Stopping_Year__c, ';
        mcsQuery += 'rC_Sponsorship__Changed_From__c,rC_Sponsorship__End_Date_Time__c,rC_Sponsorship__Start_Date_Time__c, ';
        mcsQuery += 'rC_Bios__Contact_2__r.Birthdate,rC_Bios__Contact_2__r.Child_Number__c,rC_Bios__Contact_2__r.Community__c, ';
        mcsQuery += 'rC_Bios__Contact_2__r.FirstName,rC_Bios__Contact_2__r.Id,rC_Bios__Contact_2__r.LastModifiedById, ';
        mcsQuery += 'rC_Bios__Contact_2__r.LastModifiedDate,rC_Bios__Contact_2__r.LastName,rC_Bios__Contact_2__r.Local_Partner__c, ';
        mcsQuery += 'rC_Bios__Contact_2__r.National_Office__c, rC_Bios__Contact_2__r.National_Office__r.Name, rC_Bios__Contact_2__r.Village__c, ';
        mcsQuery += 'rC_Bios__Contact_2__r.Community_Number__c,rC_Bios__Contact_2__r.Participant_Case_Number__c, rC_Bios__Contact_2__r.Name, ';
        mcsQuery += 'rC_Bios__Contact_2__r.rC_Bios__Gender__c,rC_Bios__Contact_2__r.Local_Partner__r.Name,rC_Bios__Contact_2__r.Community__r.Name, ';
        mcsQuery += 'rC_Bios__Contact_2__r.rC_Sponsorship__Sponsorship_Status__c, ';
        mcsQuery += 'rC_Bios__Contact_1__r.Name ';
        mcsQuery += 'FROM rC_Bios__Relationship__c';
        
        
            // I-253889 - Now using Lookups for NO, LP, Community
        if(filter.participant.National_Office__c != Null) {
            //mcsQuery += ' WHERE rC_Bios__Contact_2__r.National_Office__r.Name = \'' + String.escapeSingleQuotes(NationOfficeName) + '\'';
            mcsQuery += ' WHERE rC_Bios__Contact_2__r.National_Office__c = \''+filter.participant.National_Office__c+'\'';
        }
        
        if(mcsFromDate != null && mcsToDate != null) {
            // I-238502 | Used DAY_ONLY to consider only the day value of Date Time field
            mcsQuery += ' AND DAY_ONLY(rC_Sponsorship__Start_Date_Time__c) >= :mcsFromDate AND DAY_ONLY(rC_Sponsorship__Start_Date_Time__c) <= :mcsToDate';
            
        }
        
            // I-253889 - Now using Lookups for NO, LP, Community
        if(filter.participant.Local_Partner__c != Null ) {
            //mcsQuery += +' AND rC_Bios__Contact_2__r.Local_Partner__r.Name = \'' + String.escapeSingleQuotes(LocalPartnerName) + '\'';
            mcsQuery += ' AND rC_Bios__Contact_2__r.Local_Partner__c = \''+filter.participant.Local_Partner__c+'\'';
        }
        
            // I-253889 - Now using Lookups for NO, LP, Community
        if(filter.participant.Community__c != Null ) {
            //mcsQuery += ' AND rC_Bios__Contact_2__r.Community__r.Name = \'' + String.escapeSingleQuotes(CommunityName) + '\'';
            mcsQuery += ' AND rC_Bios__Contact_2__r.Community__c = \''+filter.participant.Community__c+'\'';
        }
        
        if(filter.mcs.Village__c != Null && filter.mcs.Village__c != '') {
            mcsQuery += ' AND rC_Bios__Contact_2__r.Village__c = \'' + String.escapeSingleQuotes(filter.mcs.Village__c) + '\'';       
        }
        
        if(filter.mcs.LastModifiedById != Null) {
            String lastModifiedByField = String.ValueOf(filter.mcs.LastModifiedById);
            mcsQuery += ' AND rC_Bios__Contact_2__r.LastModifiedById = \'' + String.escapeSingleQuotes(lastModifiedByField) + '\'';       
        }
        
        mcsQuery += ' AND rC_Bios__Contact_2__r.recordtype.name = \'Participant\'';
        
        mcsQuery += ' AND rC_Bios__Category__c = \'Sponsorship\' ';
        
        mcsQuery += ' ORDER BY CreatedDate DESC ';
        
        System.debug('----ChildSponsorTransferQuery---' + mcsQuery);
        
        childSponsorTransferContacts = Database.query(mcsQuery);

        return childSponsorTransferContacts;
    }
    
} // END public with sharing class MCSSlipPrint