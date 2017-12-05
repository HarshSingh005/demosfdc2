/*
* Modified By                   Modified On                      Description
* Sahil Rathore                 22 Sept 2016                     I-234965 Field Office Sponsor Relations Manager (NO) did not have create permission on obligation account solved that
* Ravi Chauhan                  30 Sep 2016                      I-237732
*/

public with sharing class OpportunityDFCReceivedbyNO {
    
    private ApexPages.StandardSetController standardController;
    
    public Obligation__c myObligation {get;set;}
    public List<SelectOption> currencies {get;set;}
    public id selectedCurrency {get;set;}
    
    public Id batchProcessId{get;set;}
    public List<AsyncApexJob> jobs{get;set;}
    public boolean isProcessButtonRendered{get;set;}
    public boolean isReturnButtonRendered{get;set;}
    public boolean isJobStatusRendered{get;set;}
    public boolean isTimerEnabled{get;set;}  
    //for accountlist on page I-234965 Sahil Rathore
    public List<SelectOption> Accountlist {get;set;}    
    public String nationaloffice {get;set;}    
    //for date on page
    public Contact mycon{get;set;}
    
    
    public OpportunityDFCReceivedbyNO(ApexPages.StandardSetController stdController) {
        this.standardcontroller = stdController;
        this.isTimerEnabled = false;
        this.myObligation = new Obligation__c();
        
        currencies = new List<SelectOption>();
        currencies.add(new SelectOption('select','select'));
        for (Currency__c cur : [select id, Name, Code__c from Currency__c where Finance_Supported__c = 'Yes'])
        {
            currencies.add(new SelectOption(cur.id,cur.Name));
        }
        
        AccountList = getaccts();
        System.debug('RSC >> ' + AccountList);
        nationaloffice = '';
        this.mycon= new Contact();
        //releaseDate=Date.today();
        
        
    }
    // Added By Sahil Rathore 22Sept 2016 I-234965
    public List<selectOption> getaccts() {
        List<selectOption> options = new List<selectOption>(); 
        //new list for holding all of the picklist options
        options.add(new selectOption('', '- None -')); 
        //add the first option of '- None -' in case the user doesn't
        //want to select a value or in case no values are
        //returned from query below
        for (Account account : [SELECT Id, Name FROM Account WHERE RecordType.Name like '%national%']) { 
            //query for Account records 
            options.add(new selectOption(account.id, account.Name)); 
            //for all records found - add them to the picklist options
        }
        return options; //return the picklist options
    }
    
    
    public PageReference submitDFCSenttoNO() {
        
        System.debug('#####testing function');
        //commented by Sahil as new national office created 
        //String nationalOffice = String.valueof(myObligation.National_Office__c);
        ID nationalOffice = myObligation.National_Office__c;
        Date createdDate = (Date) myObligation.Received_by_NO_Date__c;  // note: this is an intential mis-mapping, used to get date from UI
        Date releaseDate = (Date) myObligation.Release_Date__c;
        //changed by sahil as per issue I-234965
        //as obligation has no create permission for issue so update date with contact of random field so as to intialize date
        System.debug('####CreatedDate'+createdDate); 
        System.debug('####NationalOffice'+nationalOffice);    
        //Date releaseDate = (Date) mycon.Date_Anniversary__c;
        System.debug('####releaseDate'+releaseDate);
        decimal exchangeRate = (Decimal) myObligation.Exchange_Rate__c;
        System.debug('@@@exchangerate'+exchangeRate);
        System.debug('@@123abcbabc');
        List<Obligation__c> listObligations = [select id, Release_Date__c, Exchange_Rate__c
                                               FROM Obligation__c
                                               WHERE Release_Date__c = null
                                               AND CreatedDate < :createdDate.AddDays(1)
                                               AND National_Office__c = :nationalOffice
                                              ];
        System.debug('222abcbabc');
        System.debug('@@@@@@@obligationlistt'+listObligations);
        
        for (Obligation__c thisOb : listObligations)
        {
            thisOb.Release_Date__c = releaseDate;
            thisOb.Exchange_Rate__c = exchangeRate;
            thisOb.Local_Currency__c = selectedCurrency;
        }
        
        update listObligations;
        
        
        // Insert Exchange Rate record based on FX entered
        
        //Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
        //Date lastDayOfMonth = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
        
        Exchange_Rate__c ERentry = new Exchange_Rate__c();
        ERentry.Convert_From__c = 'USD --> Local Currency';
        ERentry.Currency__c = selectedCurrency;
        ERentry.Exchange_Rate__c = exchangeRate;
        ERentry.Start_Date__c = system.today();
        ERentry.End_Date__c = System.Date.today().toStartOfMonth().addMonths(1).addDays(-1);
        
        try {
            insert ERentry;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Sent to NO Update Complete.  Exchange Rate captured. ' + listObligations.size() + ' Obligation Records Updated.'));
        } 
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }
    
    public PageReference submitDFCReceived() {
        //String nationalOffice = String.valueof(myObligation.National_Office__c);
        String nationalOffice = String.valueof(nationaloffice);
        //ID nationalOffice = myObligation.National_Office__c;
        //date releaseDate = (Date) myObligation.Release_Date__c;
        date releaseDate = mycon.Date_Anniversary__c;

        system.debug('> trigger >>>>>>>>releaseNO  :'+nationalOffice);
        system.debug('>>>>>>>>>releaseDate  :'+releaseDate);

        List<Obligation__c> listObligations = [SELECT id, Received_by_NO_Date__c
                                               FROM Obligation__c 
                                               WHERE Release_Date__c = :releaseDate
                                               AND Received_by_NO_Date__c = null
                                               AND National_Office__c = :nationalOffice ];
        
        //CALENDAR_MONTH(Release_Date__c) = :releaseDate.Month()
        //AND DAY_IN_MONTH(Release_Date__c) = :releaseDate.day()
        //AND CALENDAR_YEAR(Release_Date__c) = :releaseDate.Year()
        
        for (Obligation__c thisOb : listObligations)
        {
            thisOb.Received_by_NO_Date__c = Date.today();
        }
        
        update listObligations;
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Received by NO Update Complete. ' + listObligations.size() + ' Obligation Records Updated.'));
        
        batchprocessid = Database.executeBatch(new OpportunityDFCReceivedbyNOBatch( nationalOffice, releaseDate));
        this.refreshJobInfo();
        
        //display a message with status of the job
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Submitting MCS TYL Creation Batch, id: ' + batchProcessId));
        
        //hide submit button and display a button to return to listview
        this.isProcessButtonRendered = false;
        this.isReturnButtonRendered = true;
        this.isJobStatusRendered = true;
        this.isTimerEnabled = true;
        
        return null;
    }
    
    //gets batch job status info for display
    public void refreshJobInfo()
    {
        jobs = [SELECT Id, Status, ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors
                FROM AsyncApexJob WHERE Id =: batchprocessid ];
        if(jobs.size() > 0)
        {
            if(jobs[0].Status == 'Aborted' ||
               jobs[0].Status == 'Completed' ||
               jobs[0].Status == 'Failed')
            {
                this.isTimerEnabled = false;
            }
            
            if(jobs[0].Status == 'Aborted' ||
               jobs[0].Status == 'Failed')
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Job ' + jobs[0].Status + '. Message: \'' + jobs[0].ExtendedStatus + '\'.'));
            }
            else if(jobs[0].Status == 'Completed')
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'MCS TYL Creation Batch has completed.'));
                
            }        
        }
    }
}