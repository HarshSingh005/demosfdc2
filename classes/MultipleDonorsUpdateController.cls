/*********************************************************************************************************************
 * Appirio, Inc
 * Name         : MultipleDonorsUpdateController
 * Created By   : Vaibhav Goel (Appirio)
 * Purpose      : Extension class for MultipleDonorsUpdate page, This class will call the batch and update the donors.
 * Created Date : 02/25/2016
 *
 * Date Modified                Modified By             Description of the update
 * --------------------------------------------------------------------------------------------------------------------
 * 11/22/2016                   Ravi Chauhan            I-244879 | Updated the batch size to 50 to avoid Apex CPU Limit
 * 11/23/2016                   Ravi Chauhan            Proper commentary on code
 **********************************************************************************************************************/
public class MultipleDonorsUpdateController {
    
    //public Contact donorAlliacneConObj{get;set;}
    public Contact childConObj{get;set;}
    public Opportunity sponsorOppty{get;set;}
    public rC_Bios__Preference__c prfrncObj{get;set;}
    public String oppQuery;
    private String OppObjectType = 'Opportunity';
    public boolean allowToRunBatch{get;set;}
    public Id batchProcessId{get;set;}
    public List<AsyncApexJob> jobs{get;set;}
    public boolean isTimerEnabled{get;set;} 
    public boolean preferenceoverride{get;set;}
    
    // Constructor to initailize the instance variables
    public MultipleDonorsUpdateController(ApexPages.StandardController stdController){
        this.childConObj = new Contact();
        this.sponsorOppty = new Opportunity();
        this.prfrncObj = new rC_Bios__Preference__c();
        this.allowToRunBatch = true;
        this.isTimerEnabled = true;
        this.preferenceoverride = false;
        system.debug('---allowToRunBatch---' + allowToRunBatch);
    }
    
    /**
     *  @Method      : callbatch
     *  
     *  @description : This function is called when the update button on MultipleDonorsUpdate page is clicked.
     *                 It updates all the donors which fits into the criterie selected in the MultipleDonorsUpdate page.
     * 
     *  @CreatedDate : 02/25/2016
     *  @CreatedBy   : Vaibhav Goel
     * 
     *  @return      : PageReference
     */
    public PageReference callbatch(){
        system.debug('---callbatch---');
        createQuery();
        
        MultipleDonorsUpdateBatch oppUpdateBatch = new MultipleDonorsUpdateBatch(OppObjectType, oppQuery, sponsorOppty, prfrncObj, childConObj);
        batchProcessId = Database.executeBatch(oppUpdateBatch,50);//I-244879 | To resolve CPU Apex Limit Exceed decreased batch size to 50
        system.debug('--Returned Opportunity batch process ID--- ' + batchProcessId);
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, 'Your update request has been submitted, batch update is in progress.'));
        allowToRunBatch = false;
        refreshJobInfo();
        return null;
    }
    
    /**
     *  @Method      : createQuery
     *  
     *  @description : This function creates the query to be passed to the MultipleDonorsUpdateBatch based on the various filter criterias
     *                 selected in the MultipleDonorsUpdate page
     * 
     *  @CreatedDate : 02/25/2016
     *  @CreatedBy   : Vaibhav Goel
     *
     */
    public void createQuery(){
        
        oppQuery = 'Select ID, Name, rC_Giving__Hard_Credit_Contact__c, CFI_Do_Not_Substitute__c, Donor_Response_Received__c,All_Child_Correspondence__c,   ' ;
        oppQuery += ' (SELECT Id, rC_Bios__Category__c, rC_Bios__Subcategory__c, rC_Bios__Type__c, rC_Bios__Subtype__c FROM rC_Sponsorship__Preferences__r ' ;
        oppQuery += ' WHERE rC_Bios__Category__c = \'Sponsorship\' AND rC_Bios__Subcategory__c = \'Contact Search\' AND rC_Bios__Type__c IN (\'National Office\', \'Local Partner\', \'Community\')';
        if(preferenceoverride == true){
            oppQuery += ' ), ';    
        }else{
            oppQuery += 'AND Auto_Assign_Preference__c = true), ';    
        }
        
        oppQuery += 'rC_Giving__Hard_Credit_Contact__r.Id, rC_Giving__Hard_Credit_Contact__r.Name, rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__c, rC_Giving__Hard_Credit_Contact__r.National_Office__c, rC_Giving__Hard_Credit_Contact__r.Local_Partner__c, rC_Giving__Hard_Credit_Contact__r.Community__c, ';
        oppQuery += ' rC_Giving__Hard_Credit_Contact__r.MailingStreet, rC_Giving__Hard_Credit_Contact__r.MailingCity, ';
        oppQuery += 'rC_Giving__Hard_Credit_Contact__r.MailingState, rC_Giving__Hard_Credit_Contact__r.MailingPostalCode, rC_Giving__Hard_Credit_Contact__r.MailingCountry, rC_Giving__Hard_Credit_Contact__r.Standard_Pay_Opt_Out__c ';
        oppQuery += ' FROM Opportunity WHERE rC_Giving__Hard_Credit_Contact__r.Donor_Alliance__c = \'' + childConObj.Donor_Alliance__c + '\'';
        oppQuery += 'AND rC_Giving__Hard_Credit_Contact__r.Id != null';
        if(childConObj.Local_Partner__c != null && childConObj.Community__c != null){
            oppQuery += ' AND rC_Giving__Hard_Credit_Contact__r.Local_Partner__c = \''+ childConObj.Local_Partner__c + '\' AND rC_Giving__Hard_Credit_Contact__r.Community__c = \'' + childConObj.Community__c + '\'';
        }else if(childConObj.Local_Partner__c != null && childConObj.Community__c == null){
            oppQuery += ' AND rC_Giving__Hard_Credit_Contact__r.Local_Partner__c = \''+ childConObj.Local_Partner__c + '\'';
        }
        else if(childConObj.Local_Partner__c == null && childConObj.Community__c != null){
            oppQuery += ' AND rC_Giving__Hard_Credit_Contact__r.Community__c = \''+ childConObj.Community__c + '\'';
        }
        
        system.debug('----oppQuery----' + oppQuery);
        system.debug('----oppQueryResult----' + Database.query(oppQuery));
    }
    
    /**
     *  @Method      : refreshJobInfo
     *  
     *  @description : This function keeps on updating the batch job info on the MultipleDonorsUpdate page.
     * 
     *  @CreatedDate : 02/25/2016
     *  @CreatedBy   : Vaibhav Goel
     *
     */
    public void refreshJobInfo(){
        jobs = [SELECT Id, Status, ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors
              FROM AsyncApexJob WHERE Id =: batchprocessid ];
        if(jobs.size() > 0){
            if(jobs[0].Status == 'Aborted' || jobs[0].Status == 'Completed' || jobs[0].Status == 'Failed'){
                this.isTimerEnabled = false;
            }
            
            if(jobs[0].Status == 'Aborted' || jobs[0].Status == 'Failed'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Job ' + jobs[0].Status + '. Message: \'' + jobs[0].ExtendedStatus + '\'.'));
            }
            else if(jobs[0].Status == 'Completed'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'CPR Request batch job has completed.'));
            }        
        }
    }
}