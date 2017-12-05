/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ProcessExchangeRatesController
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Controller class of Process Exchange Rates listview selection/confirmation page
 * Created Date : 01/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/07/2016					Karl Houseknecht		Created
 **********************************************************************************************************/
public class ProcessExchangeRatesController 
{
    private ApexPages.StandardSetController standardController;
    public string retURL{get;set;}
    public boolean isProcessButtonRendered{get;set;}
    public boolean isReturnButtonRendered{get;set;}
    public boolean isJobStatusRendered{get;set;}
    public boolean isTimerEnabled{get;set;}
    public Id batchProcessId{get;set;}
    public List<AsyncApexJob> jobs{get;set;}
    
	public ProcessExchangeRatesController(ApexPages.StandardSetController standardController)
    {
        this.retURL = ApexPages.currentPage().getParameters().get('retURL');
        this.standardController = standardController;
        this.isProcessButtonRendered = true;
        this.isReturnButtonRendered = false;
        this.isJobStatusRendered = false;
        this.isTimerEnabled = false;
    }
    
    //set all the statuses to 'Process'
    public PageReference updateExchangeRateStatus()
    {
        List<Exchange_Rate__c> selectedRates = (List<Exchange_Rate__c>) standardController.getSelected();
        
        for(Exchange_Rate__c rate : selectedRates)
            rate.Status__c = 'Process';
        
        return null;
    }
    
    //Save the Exchange Rate records to process and begin batch job
    //Batch job will process all rates with status of 'Process'
    public PageReference processExchangeRates()
    {
        standardController.save();
        
        //submit batch job
        batchprocessid = Database.executeBatch(new ProcessExchangeRatesBatch());
        this.refreshJobInfo();
        
        //display a message with status of the job
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Exchange Rate batch job with id ' + batchProcessId + ' submitted.'));
        
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
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Exchange Rate batch job has completed.'));
        
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