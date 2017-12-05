/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CorrespondenceReminderController
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Controller class of CorrespondenceReminder page
 * Created Date : 01/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/04/2016					Karl Houseknecht		Created
 **********************************************************************************************************/
public class CorrespondenceReminderController 
{
	public string retURL{get;set;}
    public boolean isProcessButtonRendered{get;set;}
    public boolean isReturnButtonRendered{get;set;}
    public boolean isJobStatusRendered{get;set;}
    public boolean isTimerEnabled{get;set;}
    public Id batchProcessId{get;set;}
    public List<AsyncApexJob> jobs{get;set;}
    public Id nationalOfficeId{get;set;}
    public List<SelectOption> nationalOffices{get;set;}
    public integer numberOfMonths{get;set;}
    
    public CorrespondenceReminderController()
    {
        this.retURL = ApexPages.currentPage().getParameters().get('retURL');
        this.nationalOfficeId = ApexPages.currentPage().getParameters().get('id');
        this.isProcessButtonRendered = true;
        this.isReturnButtonRendered = false;
        this.isJobStatusRendered = false;
        this.isTimerEnabled = false;
        this.numberOfMonths = 6;
        this.createNationalOfficePicklist();
    }
    
    private void createNationalOfficePicklist()
    {
        Id nationalOfficeRecordtypeId = 
            Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        
        List<Account> offices = 
            [select id, 
             name, 
             National_Office_ID__c 
             from account 
             where recordtypeid = :nationalOfficeRecordtypeId 
             order by name asc];
        
        this.nationalOffices = new List<SelectOption>();
        for(Account office : offices)
            this.nationalOffices.add(new SelectOption(office.id,office.National_Office_Id__c + ' - ' + office.name));
    }
    
    public PageReference returnToRecord()
    {
        PageReference recordPage = new PageReference(retURL);
        return recordPage;
    }
    
    public PageReference processReminders()
    {
        //standardController.save();
        
        //submit batch job
        batchprocessid = Database.executeBatch(new MCSGenerationCIL_Batch(this.nationalOfficeId,this.numberOfMonths));
        this.refreshJobInfo();
        
        //display a message with status of the job
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Correspondence Reminder batch job with id ' + batchProcessId + ' submitted.'));
        
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
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Correspondence Reminder batch job has completed.'));
        
            }        
        }
    }
     
    //navigates back to the Exchange Rate listview
    public PageReference returnToListView()
    {
        PageReference listViewPage = new PageReference(retURL);
        return listViewPage;
    }
}