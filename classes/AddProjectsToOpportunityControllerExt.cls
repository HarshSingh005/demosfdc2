/*
 * Class        : AddProjectsToOpportunityControllerExt
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 20, 2013 
 * Objective    : Controller Extension for Opportunity to handle Searching and Adding Projects
*/
public with sharing class AddProjectsToOpportunityControllerExt implements CustomSearchInterface{
    
    //Properties
    //Reference to this Controller Extension. Used by Searc Component
    public AddProjectsToOpportunityControllerExt thisCon{
        get{
            return this;
        } 
        private set;
    }
    public OpportunityModel oppModel{get;set;}
    public List<Wrapper.ProjectWrapper> projectWrapper{
        get{
            if(projectWrapper == null)
                projectWrapper = new List<Wrapper.ProjectWrapper>();
            return projectWrapper;  
        }
        set;
    }
    //StandardSetController for Pagination
    private ApexPages.StandardSetcontroller projectSetCtr;
    public Boolean hasNext{
        get{
            if(projectSetCtr == null)
                return false;
            return projectSetCtr.getHasNext();
        }
        private set;
    }       
    public Boolean hasPrevious{
        get{
            if(projectSetCtr == null)
                return false;
            return projectSetCtr.getHasPrevious();
        }
        private set;
    }
    //Maintain all the Selected Projects in this Collection
    private Map<Id, Wrapper.ProjectWrapper> selectedProjects{
        get{
            if(selectedProjects == null)
                selectedProjects = new Map<Id, Wrapper.ProjectWrapper>();
            return selectedProjects;
        }
        set;
    }
    public Boolean isAllSelected{get;set;}
    private static final Integer PAGE_SIZE = 10;        
    //Constructor   
    public AddProjectsToOpportunityControllerExt(ApexPages.StandardController stdCon){
        oppModel = new OpportunityModel((Opportunity)stdCon.getRecord());
    }
    
    /**
     * Implementation of method from Interface. Search for Projects based on the Query String.  
     * @parm String queryStr
     * @return PageReference
    */
    public PageReference doSearch(String filterStr){
        String queryStr = 'SELECT Id, Name, Status__c, Country__c, Region__c FROM Project__c';
        if(!String.isBlank(filterStr)){
            queryStr += ' WHERE ' + filterStr;
        }
        System.debug('*********** queryStr: ' + queryStr);
        try{
            projectSetCtr = new ApexPages.StandardSetcontroller(Database.getQueryLocator(queryStr));
        }catch(QueryException qe){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Invalid Search Filters. \n' + queryStr));
            return null;
        }
        projectSetCtr.setPageSize(PAGE_SIZE);
        generateProjectWrapper();
        return null;
    }
    
    /**
     * Get the Next set of Project Records  
     * @parm 
     * @return 
    */
    public void next(){
        //Add the Selected Records to the List
        addSelectedProjectsToList();
        //Get the Next Set of Records and Generate Wrappers
        projectSetCtr.next();
        generateProjectWrapper();
        isAllSelected = false;
    }   
    
    /**
     * Get the Previous set of Project Records  
     * @parm 
     * @return 
    */
    public void previous(){
        //Add the Selected Records to the List
        addSelectedProjectsToList();
        //Get the Previous Set of Records and Generate Wrappers
        projectSetCtr.previous();
        generateProjectWrapper();
        isAllSelected = false;
    }
    
    /**
     * Generate Project Wrappers for the current Set of Records  
     * @parm 
     * @return 
    */
    private void generateProjectWrapper(){
        //Clear the List
        projectWrapper.clear();
        for(SObject proj : projectSetCtr.getRecords()){
            Boolean isSelected = false;
            Project__c p = (Project__c)proj;
            //If the Record was previously selected, set the flag to true 
            if(selectedProjects.containsKey(p.Id))
                isSelected = true;
            projectWrapper.add(new Wrapper.ProjectWrapper(p, isSelected));
        }
    }
    
    /**
     * Add Selected Records to a Map and Remove the ones that were deselected   
     * @parm 
     * @return 
    */
    private void addSelectedProjectsToList(){
        for(Wrapper.ProjectWrapper projWrapper : projectWrapper){
            Wrapper.ProjectWrapper wrapperinList = selectedProjects.get(projWrapper.project.Id);
            //If the Record was previously selected but is now unselected, remove it from the Map
            if(wrapperinList != null && projWrapper.isSelected != true){
                selectedProjects.remove(projWrapper.project.Id);
            }
            //If the record is selected, add it to the Map
            if(projWrapper.isSelected == true){
                selectedProjects.put(projWrapper.project.Id, projWrapper);
            }
        }
    }
    
    /**
     * Add Selected Projects to the Opportunity   
     * @parm 
     * @return PageReference
    */
    public PageReference addSelectedProjectsToOpp(){
        addSelectedProjectsToList();
        if(selectedProjects.isEmpty())
            return null;
        List<Funding__c> fundings = new List<Funding__c>();
        for(Wrapper.ProjectWrapper projWrapper : selectedProjects.values()){
            fundings.add(new Funding__c(Opportunity_Name__c = oppModel.opp.Id, Project__c = projWrapper.project.Id, Country__c = projWrapper.project.Country__c, 
                                            Region__c = projWrapper.project.Region__c));            
        }
        try{
            SObjectServices.insertSObjects(fundings);
        }catch(ChildFundException.CustomDMLException cfe){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, cfe.getMessage()));
            return null;
        }
        return new Apexpages.Standardcontroller(oppModel.opp).view(); 
    }
    
    /**
     * Redirect to Create Project VF page   
     * @parm 
     * @return PageReference
    */
    public PageReference createProject(){
        PageReference pRef = Page.CreateProjectForOpp;
        pRef.setRedirect(true);
        pRef.getParameters().put('Id',oppModel.opp.Id);
        return pRef;
    }
}