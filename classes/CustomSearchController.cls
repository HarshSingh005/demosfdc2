/*
 * Class        : CustomSearchController
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 14, 2013
 * Objective    : Controller for the CustomSearch Visualforce component. Provides Search filtering functionality.
*/
public with sharing class CustomSearchController {
	
	//Properties
	private List<SelectOption> objFields{
		get{
			if(objFields == null)
				objFields = new List<SelectOption>();
			return objFields;	
		} 
		set;
	}
	private Map<String, Schema.SobjectField> descFieldMap{
		get{
			//get all the fields for the specified SObject
			if(descFieldMap == null)
				descFieldMap =  SObjectServices.getFieldsForSObject(sObjectName);
			return descFieldMap;
		}
		set;
	}
	public CustomSearchInterface customSearchController{get;set;}
	public String sObjectName{
		get;
		set{
			sObjectName = value;
			if(objFields.isEmpty()){
				//Add all the searchable fields on the SObject to the objFields SelectOption List
				objFields = CustomSearchUtility.sortAndAddFieldsToSearchFilter(descFieldMap);
			}
		}
	}
	
	public List<Wrapper.SearchFilterWrapper> searchFilters{ 
		get{
			if(searchFilters == null)
				constructSearchFilters();
			return searchFilters;	
		}
		set;
	}
	
	private List<Selectoption> operators{ 
		get{
			if(operators == null){
				//Get the Search Operators
				operators = CustomSearchUtility.getSearchOperators(Schema.DisplayType.String);
			}
	    	return operators;
		}
		set;
	}
	
	private List<Selectoption> logicalOperators{ 
		get{
			if(logicalOperators == null){
				//Get the Logical Operators
				logicalOperators = CustomSearchUtility.getlogicalOperators();
			}
	    	return logicalOperators;
		}
		set;
	}
	private static final Integer NUM_FILTER_ROWS = 5;
	private static final Integer MAX_FILTER_ROWS = 10;
	
	public String fieldName{get;set;}
		
	//Constructor
	public CustomSearchController(){
		
	}
	
	/**
     * construct the initial filter rows  
     * @parm 
     * @return
    */
	private void constructSearchFilters(){
		searchFilters = new List<Wrapper.SearchFilterWrapper>();
		for(Integer i=0; i<NUM_FILTER_ROWS; i++){addFilterRow();}
	}
	
	/**
     * Add a filter row  
     * @parm 
     * @return
    */
	private void addFilterRow(){ 
    	Wrapper.SearchFilterWrapper wrapper = new Wrapper.SearchFilterWrapper(objFields, operators, null, logicalOperators); 
    	searchFilters.add(wrapper);
	}
		
	/**
     * Perform Search on the SObject with the specified search filters  
     * @parm 
     * @return PageReference
    */
	public PageReference doSearch(){
		Boolean validationError = CustomSearchUtility.validateNumericFields(searchFilters, descFieldMap);
		if(validationError)
			return null;
		String filterStr = CustomSearchUtility.getSearchFilters(searchFilters, descFieldMap);
		System.debug('*********** filterStr: ' + filterStr);
		customSearchController.doSearch(filterStr);		
		return null;
	}
	
	/**
     * Add a search filter row  
     * @parm 
     * @return PageReference
    */
	public PageReference addRow(){
		if(searchFilters.size() < MAX_FILTER_ROWS)
			addFilterRow();
		return null;
	}
	
	/**
     * Remove a search filter row  
     * @parm 
     * @return PageReference
    */	
	public PageReference removeRow(){
		if(!searchFilters.isEmpty())
			searchFilters.remove(searchFilters.size()-1);
		return null;
	}
	
	public PageReference setFieldTypeAndValues(){
		CustomSearchUtility.setFieldTypeAndValues(searchFilters, descFieldMap);
		return null;
	}	
}