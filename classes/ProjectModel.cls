/*
 * Class        : ProjectModel
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 9, 2013
 * Objective    : Model class for the Project__c object. Any DML on Project__c or SOQL queries to retrieve child objects should be done in this class. 
*/
public with sharing class ProjectModel {
	
	//Properties
	public Project__c project{get; set;}
	
	//Constructor
	public ProjectModel(Project__c project){
		this.project = project;
	}
	
	/**
     * Save this Project record 
     * @parm
     * @return
    */
	public void saveProject(){
		try{
			insert project;
		}catch(DMLException dmlEx){
			throw new ChildFundException.CustomDMLException('There was an error creating the Project. ' + dmlEx.getMessage());
		}
	}	
}