@isTest
private class TestAddProjectsToOpportunityContExt {
	
	static Opportunity opp;
	
	static void setup(){
		Account acc = TestUtils.createAccount('Test Acc', true);
		opp = TestUtils.createOpportunity(acc, 'Test Opp', 100000, true);
	}
	
    static testMethod void testSearchProjects() {
        //Create Acc and Opp
        setup(); 
        //Create Projects
        List<Project__c> projects = new List<Project__c>();
        for(Integer i=0; i<200; i++){
        	projects.add(TestUtils.createProject('Test Proj '+i, 'Kenya', 'Available', false));
        }
        insert projects;
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opp); 
        AddProjectsToOpportunityControllerExt ext = new AddProjectsToOpportunityControllerExt(stdCon);
        String filterStr = 'Country__c = \'Kenya\' AND Status__c = \'Available\'';
        //Before searching the set should have no records
        System.assertEquals(ext, ext.thisCon);
        System.assertEquals(false, ext.hasNext);
        System.assertEquals(false, ext.hasPrevious);
        //perform search
        ext.doSearch(filterStr);
        List<Wrapper.ProjectWrapper> projectWrapper = ext.projectWrapper; 
        //the search results should have the projects
        System.assertEquals(10, projectWrapper.size());
        Wrapper.ProjectWrapper selectedProjectWrapper = projectWrapper.get(0);
        //select a project to add to the Opp
        selectedProjectWrapper.isSelected = true;
        System.assertEquals(true, ext.hasNext);
        ext.next();
        System.assertEquals(true, ext.hasPrevious);
        ext.previous();
        System.assertEquals(false, ext.hasPrevious);
        ext.addSelectedProjectsToOpp();
        //The project should be associated to the opp through a funding record
        System.assertEquals(1, [SELECT COUNT() FROM Funding__c WHERE Opportunity_Name__c =: opp.Id AND Project__c =: selectedProjectWrapper.project.Id]);
    }
    
    
    static testMethod void testSearchProjectsWithInvalidFilter() {
        setup();
        List<Project__c> projects = new List<Project__c>();
        for(Integer i=0; i<200; i++){
        	projects.add(TestUtils.createProject('Test Proj '+i, 'Kenya', 'Available', false));
        }
        insert projects;
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opp); 
        AddProjectsToOpportunityControllerExt ext = new AddProjectsToOpportunityControllerExt(stdCon);
        String invalidFilterStr = 'Proposal_Expenses__c = ';
        //search with an invalid filter
        ext.doSearch(invalidFilterStr);
        //Ensure there is an error message added to the page
        System.assertEquals(true, !ApexPages.getMessages().isEmpty());
    }
    
    static testMethod void testRedirectToCreateProject() {
        setup();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opp); 
        AddProjectsToOpportunityControllerExt ext = new AddProjectsToOpportunityControllerExt(stdCon);
        PageReference pRef = ext.createProject();
        PageReference newProjRef = Page.CreateProjectForOpp;
        newProjRef.getParameters().put('Id',opp.Id);
        System.assertEquals(newProjRef.getUrl(), pRef.getUrl());
    }
}