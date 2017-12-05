/*
 * Class        : ProjectControllerExt
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 9, 2013
 * Objective    : Controller extension for the Project__c object
*/
public with sharing class ProjectControllerExt {
	
	//Properties
	private ProjectModel projModel{get; set;}
	public OpportunityModel oppModel{get; set;}
	public FundingModel fundingModel{get; set;}
	public Boolean isError{get; private set;}
	private RecordType oppRecType{
		get{
			if(oppRecType == null){
				oppRecType = SObjectServices.getRecordType(Constants.OPP_REC_TYPE_PROPOSAL, Constants.OPP_SOBJECT_TYPE);
			}
			return oppRecType;
		}set;
	}
	
	//Constructor
	public ProjectControllerExt(ApexPages.StandardController stdCon){
		if(stdCon.getId() == null){
			isError = true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Invalid invocation. Go to the Project detail page and click \'Create Funding Opportunity\''));
			return;	
		}
		projModel = new ProjectModel((Project__c)stdCon.getRecord());
		oppModel = new OpportunityModel(new Opportunity());
		if(oppRecType != null)
			oppModel.opp.RecordTypeId = oppRecType.Id;
		fundingModel = new FundingModel(new Funding__c());
	}
	
	/**
     * Create the Opportunity and Funding records 
     * @parm 
     * @return PageReference
    */
	public PageReference save(){
		SavePoint sp = Database.setSavepoint();
		try{
			//oppModel.opp.National_Office__c = fundingModel.funding.National_Office__c;
			//Create the Funding Opp
			oppModel.saveOpp();
			//Create the Funding record and associate the Opportunity to the Project
			fundingModel.saveFunding(oppModel.opp, projModel.project);
		}catch(ChildFundException.CustomDMLException cfe){
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, cfe.getMessage()));
			return null;
		}
		//if the funding is created successfully return to the Project detail page
		return new Apexpages.Standardcontroller(projModel.project).view();
	}
		
}