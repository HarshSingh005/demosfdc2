/*
 * Class        : OpportunityControllerExt
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 14, 2013
 * Objective    : Controller extension for the Opportunity object
*/
public with sharing class OpportunityControllerExt {
	
	//Properties
	private OpportunityModel oppModel{get; set;}
	public ProjectModel projModel{get; set;}
	public FundingModel fundingModel{get; set;}
	public Boolean isError{get; private set;}
	
	private RecordType projectRecType{
		get{
			if(projectRecType == null){
				projectRecType = SObjectServices.getRecordType(Constants.PROJECT_REC_TYPE_SINGLE_NO, Constants.PROJECT_SOBJECT_TYPE);
			}
			return projectRecType;
		}set;
	}
	
	//Constructor
	public OpportunityControllerExt(ApexPages.StandardController stdCon){
		if(stdCon.getId() == null){
			isError = true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Invalid invocation. Go to the Opportunity detail page and click \'Create Project\''));
			return;	
		}
		oppModel = new OpportunityModel((Opportunity)stdCon.getRecord());
		projModel = new ProjectModel(new Project__c());
		if(projectRecType != null)
			projModel.project.RecordTypeId = projectRecType.Id;
		fundingModel = new FundingModel(new Funding__c());
	}
	
	/**
     * Create the Project and Funding records 
     * @parm 
     * @return PageReference
    */
	public PageReference save(){
		SavePoint sp = Database.setSavepoint();
		try{
			projModel.project.ChildFund_Office__c = fundingModel.funding.ChildFund_Office__c;
			projModel.project.Country__c = fundingModel.funding.Country__c;
			projModel.project.Region__c = fundingModel.funding.Region__c;
			//Create the Project
			projModel.saveProject();
			//Create the Funding record and associate the Opportunity to the Project
			fundingModel.saveFunding(oppModel.opp, projModel.project);
		}catch(ChildFundException.CustomDMLException cfe){
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, cfe.getMessage()));
			return null;
		}
		//if the funding is created successfully return to the Project detail page
		return new Apexpages.Standardcontroller(oppModel.opp).view();
	}
}