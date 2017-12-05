/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TestCustomSearchController
 * Purpose      : Test class for CustomSearchController class

 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/21/2017                  Suminder Singh(Appirio)  fixed for code coverage and errors
**********************************************************************************************************/
@isTest
private class TestCustomSearchController {
	static Account acc;
	static Opportunity opp;
	static final String sObjectName = 'Project__c';
	static List<Project__c> projects;
	
	static void setup(){
		acc = TestUtils.createAccount('Test Acc', true);
		opp = TestUtils.createOpportunity(acc, 'Test Opp', 100000, true);
		//Create Projects
        projects = new List<Project__c>();
        for(Integer i=0; i<20; i++){
        	projects.add(TestUtils.createProject('Test Proj '+i, 'Kenya', 'Available', false));
        }
        insert projects;
	}
	
    static testMethod void testCustomSearchForProjects() {
    	//Create Acc, Opp and Projects
    	setup();
    	ApexPages.StandardController stdCon = new ApexPages.StandardController(opp); 
        //Create a controller extension that implements the CustomSearchInterface
        CustomSearchInterface ext = new AddProjectsToOpportunityControllerExt(stdCon);
        CustomSearchController customSrchCtr = new CustomSearchController();
        customSrchCtr.customSearchController = ext;
        customSrchCtr.sObjectName = sObjectName;
        List<Wrapper.SearchFilterWrapper> searchFilters = customSrchCtr.searchFilters;
        //No results should be displayed on page load 
        System.assertNotEquals(null, searchFilters);
        //Default Search Filter Rows = 5
        System.assertEquals(5, searchFilters.size());
        //Make sure all the filter rows have the fields from the SObj
        Map<String, Schema.SobjectField> descFieldMap = SObjectServices.getFieldsForSObject(sObjectName);
        List<SelectOption> objFields = CustomSearchUtility.sortAndAddFieldsToSearchFilter(descFieldMap);
        for(Wrapper.SearchFilterWrapper wrapper : searchFilters){
        	System.assertNotEquals(null, wrapper.objFields);
        	System.assertEquals(objFields.size(), wrapper.objFields.size());
        }
        //Add 5 more rows
        customSrchCtr.addRow();customSrchCtr.addRow();customSrchCtr.addRow();customSrchCtr.addRow();customSrchCtr.addRow();
        System.assertEquals(10, searchFilters.size());
        //Max rows is 10. Clicking on Add Row should not add an 11th row 
        customSrchCtr.addRow();
        System.assertEquals(10, searchFilters.size());
        //Remove a row
        customSrchCtr.removeRow();
        System.assertEquals(9, searchFilters.size());
        //Set the filter to Country = Kenya
        Wrapper.SearchFilterWrapper wrapper = searchFilters.get(0);
        wrapper.selectedField = 'Country__c';
        customSrchCtr.setFieldTypeAndValues();
        wrapper.selectedOperator = '=';
        wrapper.selectedPicklistValue = 'Kenya';
		//Search should return all 20 projects that were created in setup 
		customSrchCtr.doSearch();
		AddProjectsToOpportunityControllerExt addProjectsCtr = (AddProjectsToOpportunityControllerExt)ext;
		System.assertEquals(10, addProjectsCtr.projectWrapper.size());
		System.assertEquals(true, addProjectsCtr.hasNext);
		addProjectsCtr.next();
		System.assertEquals(10, addProjectsCtr.projectWrapper.size());
    }
    
	static testMethod void testCustomSearchWithDifferentFieldTypes() {
		//Create Acc, Opp and Projects
    	setup();
    	ApexPages.StandardController stdCon = new ApexPages.StandardController(opp); 
        //Create a controller extension that implements the CustomSearchInterface
        CustomSearchInterface ext = new AddProjectsToOpportunityControllerExt(stdCon);
        CustomSearchController customSrchCtr = new CustomSearchController();
        customSrchCtr.customSearchController = ext;
        customSrchCtr.sObjectName = sObjectName;
        Wrapper.SearchFilterWrapper filter1 = customSrchCtr.searchFilters.get(0);
        Wrapper.SearchFilterWrapper filter2 = customSrchCtr.searchFilters.get(1);
        Wrapper.SearchFilterWrapper filter3 = customSrchCtr.searchFilters.get(2);
        Wrapper.SearchFilterWrapper filter4 = customSrchCtr.searchFilters.get(3);
        Wrapper.SearchFilterWrapper filter5 = customSrchCtr.searchFilters.get(4);
		//Fixed for data error
		acc.RecordTypeId = TestUtils.getRecordTypeId('National_Office', 'Account');
        acc.National_Office_ID__c = '123';
		update acc; 		

 		Project__c proj = projects.get(0);
 		proj.Core_Program_Children__c = true;
		proj.Focus_Area_Children__c = 'Child Friendly Schools;Participatory School Governance';
		proj.Start_Date__c = Date.today().addDays(10);
		proj.ChildFund_Office__c = acc.Id;
		proj.Name = 'Test Project';
		update proj;
		
		filter1.selectedField = 'Focus_Area_Children__c';
		customSrchCtr.setFieldTypeAndValues();
		filter1.selectedOperator = 'INCLUDES';
		filter1.selectedMultiPicklistValues = new List<String>{'Child Friendly Schools', 'Participatory School Governance'};
       	filter1.selectedLogicalOp = 'AND';
       	
       	filter2.selectedField = 'Start_Date__c';
       	customSrchCtr.setFieldTypeAndValues();
		filter2.selectedOperator = '=';
		filter2.customSearch.Date__c = Date.today().addDays(10);
		filter2.selectedLogicalOp = 'AND';
		
		filter3.selectedField = 'Core_Program_Children__c';
       	customSrchCtr.setFieldTypeAndValues();
		filter3.selectedOperator = '=';
		filter3.selectedPicklistValue = 'True';
		filter3.selectedLogicalOp = 'AND';
		
		filter4.selectedField = 'ChildFund_Office__c';
       	customSrchCtr.setFieldTypeAndValues();
		filter4.selectedOperator = '=';
		filter4.lookupId = acc.Id;
		filter4.selectedLogicalOp = 'AND';
		
		filter5.selectedField = 'Name';
       	customSrchCtr.setFieldTypeAndValues();
		filter5.selectedOperator = '=';
		filter5.value = 'Test Project';
				
				
		customSrchCtr.doSearch();
		
		AddProjectsToOpportunityControllerExt addProjectsCtr = (AddProjectsToOpportunityControllerExt)ext;
		System.assertEquals(1, addProjectsCtr.projectWrapper.size());
       		
	}   
	
	static testMethod void testCustomSearchWithNumericFieldTypes() {
		//Create Acc, Opp and Projects
    	setup();
    	ApexPages.StandardController stdCon = new ApexPages.StandardController(opp); 
        //Create a controller extension that implements the CustomSearchInterface
        CustomSearchInterface ext = new AddProjectsToOpportunityControllerExt(stdCon);
        CustomSearchController customSrchCtr = new CustomSearchController();
        customSrchCtr.customSearchController = ext;
        customSrchCtr.sObjectName = sObjectName;
        Wrapper.SearchFilterWrapper filter1 = customSrchCtr.searchFilters.get(0);
 		
 		Project__c proj = projects.get(0);
 		proj.Project_Duration_months__c = 12;
		update proj;
		
		filter1.selectedField = 'Project_Duration_months__c';
		customSrchCtr.setFieldTypeAndValues();
		filter1.selectedOperator = '>';
		filter1.value = '';
       	
       	customSrchCtr.doSearch();
       	System.assertEquals('Invalid Value for this field', filter1.errorMsg);
       	
       	filter1.value = '10';
       	customSrchCtr.doSearch();
 		AddProjectsToOpportunityControllerExt addProjectsCtr = (AddProjectsToOpportunityControllerExt)ext;
		System.assertEquals(1, addProjectsCtr.projectWrapper.size());
  
	} 
}