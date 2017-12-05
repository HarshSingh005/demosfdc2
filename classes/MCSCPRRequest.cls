public with sharing class MCSCPRRequest {
	
	private ApexPages.StandardSetController standardController;
    public boolean sendCPROnlyToSponsored{get;set;}

	public Id batchProcessId{get;set;}
	public List<AsyncApexJob> jobs{get;set;}
	public boolean isProcessButtonRendered{get;set;}
    public boolean isReturnButtonRendered{get;set;}
    public boolean isJobStatusRendered{get;set;}
    public boolean isTimerEnabled{get;set;}	

	public MCSCPRRequest(ApexPages.StandardSetController stdController) {
		this.standardcontroller = stdController;
		this.isTimerEnabled = true;
        this.sendCPROnlyToSponsored = true;
	}

	public PageReference submitCPRRequest() {
		
		List<Account> selected = (List<Account>) standardController.getSelected();

		//List<Account> selected = [select id from Account where recordType.Name = 'Community'];
        
        batchprocessid = Database.executeBatch(new MCSCPRRequestBatch(selected,sendCPROnlyToSponsored));
        this.refreshJobInfo();
        
        //display a message with status of the job
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Batch job with id ' + batchProcessId + ' submitted.'));
        
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
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'CPR Request batch job has completed.'));
        
            }        
        }
    }
}