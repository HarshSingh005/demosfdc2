public with sharing class CustomSearchUtility {	
	
	//Properties
	static Set<Schema.DisplayType> stringTypes{
		get{
			if(stringTypes == null){
				stringTypes = new Set<Schema.DisplayType>{Schema.DisplayType.String, Schema.DisplayType.TextArea, Schema.DisplayType.Picklist,Schema.DisplayType.MultiPicklist};
			}
			return stringTypes;	
		}
		set;
	} 
	
	static Set<Schema.DisplayType> numTypes{
		get{
			if(numTypes == null){
				numTypes = new Set<Schema.DisplayType>{Schema.DisplayType.Currency, Schema.DisplayType.Double, Schema.DisplayType.Integer,Schema.DisplayType.Percent};
			}
			return numTypes;	
		}
		set;
	}
	
	/**
     * Construct the WHERE clause of query string based on the search filters
     * @parm List<Wrapper.SearchFilterWrapper> searchFilters, Map<String, Schema.SobjectField> descFieldMap
     * @return String
    */
	public static String getSearchFilters(List<Wrapper.SearchFilterWrapper> searchFilters, Map<String, Schema.SobjectField> descFieldMap){
		String filterStr = '';
		if(descFieldMap != null && searchFilters != null && !searchFilters.isEmpty()){
			//go through each search filter
			for(Integer i=0; i<searchFilters.size(); i++){
				Wrapper.SearchFilterWrapper searchFilter = searchFilters.get(i);
				if(!String.isBlank(searchFilter.selectedField)){
					//Get the selected field type
					Schema.DescribeFieldResult fieldResult = descFieldMap.get(searchFilter.selectedField).getDescribe();
					String selectedOpertor = searchFilter.selectedOperator;
					//Escape the user entered search text value
					String selectedValue = searchFilter.value != null ? String.escapeSingleQuotes(searchFilter.value) : '';
					//If the selected field is a Boolean
					if(fieldResult.getType() == Schema.DisplayType.Picklist || fieldResult.getType() == Schema.DisplayType.Boolean)
						selectedValue = searchFilter.selectedPicklistValue;
					//If the selected field is a MultiPickList
					else if(fieldResult.getType() == Schema.DisplayType.MultiPicklist){
						if(selectedOpertor == 'INCLUDES' || selectedOpertor == 'EXCLUDES'){
							selectedValue = '(';
						}
						for(Integer countVar=0; countVar<searchFilter.selectedMultiPicklistValues.size(); countVar++){
							String selectedVal = searchFilter.selectedMultiPicklistValues.get(countVar);
							if(selectedOpertor == 'INCLUDES' || selectedOpertor == 'EXCLUDES'){
								selectedValue += '\'' + selectedVal + ';' + '\'';
								if(searchFilter.selectedMultiPicklistValues.size() > (countVar+1))
									selectedValue += ',';
							}
							else
								selectedValue += selectedVal + ';';
						}
						if(selectedOpertor == 'INCLUDES' || selectedOpertor == 'EXCLUDES'){
							selectedValue += ')';
						}
					}
					//If the selected field is a Date
					else if(fieldResult.getType() == Schema.DisplayType.Date){
						Date selectedDate = searchFilter.customSearch.Date__c;
						if(selectedDate != null)
							selectedValue = DateTime.newInstance(selectedDate.year(), selectedDate.month(), selectedDate.day()).format('yyyy-MM-dd'); 
					}
					//If the selected field is a Lookup
					else if(fieldResult.getType() == Schema.DisplayType.Reference){
						selectedValue = '\'' + searchFilter.lookupId + '\'';
					} 
					filterStr += searchFilter.selectedField + ' ' + selectedOpertor + ' ';		  
					if(stringTypes.contains(fieldResult.getType())){  
						if(fieldResult.getType() == Schema.DisplayType.MultiPicklist && (selectedOpertor == 'INCLUDES' || selectedOpertor == 'EXCLUDES'))
							filterStr += selectedValue;
						else
							filterStr += '\'' + selectedValue + '\'';
					}
					else
						filterStr += selectedValue;
					
					//If there is another search filter add the logical operator
					if(searchFilters.size() > (i+1)){
						Wrapper.SearchFilterWrapper nextFilter = searchFilters.get(i+1);
						if(!String.isBlank(nextFilter.selectedField)){
							filterStr += ' ' + searchFilter.selectedLogicalOp + ' ';
						}
					}		
				}
				
			}	
		}
		return filterStr;
	}
	
	/**
     * Sort the SObject fields and generate picklist values
     * @parm Map<String, Schema.SObjectField> descFieldMap
     * @return List<SelectOption>
    */
	public static List<SelectOption> sortAndAddFieldsToSearchFilter(Map<String, Schema.SObjectField> descFieldMap){
		List<SelectOption> objFields = new List<SelectOption>();
		//Sort the Fields
		List<String> sortedFields = new List<String>();
		Map<String, Schema.DescribeFieldResult> fieldMap = new Map<String, Schema.DescribeFieldResult>();
		for(String field : descFieldMap.keySet()){
			Schema.DescribeFieldResult fieldResult = descFieldMap.get(field).getDescribe();
			sortedFields.add(fieldResult.getLabel());
			fieldMap.put(fieldResult.getLabel(), fieldResult);
		}
		sortedFields.sort();
		objFields.add(new Selectoption('', '--None--'));
		//Create a SelectOption List for all the searchable fields
		for(String field : sortedFields){
			Schema.DescribeFieldResult fieldResult = fieldMap.get(field);
			//Only add the field if it's accessible and searchable
			if(fieldResult.isFilterable() && fieldResult.isAccessible() && fieldResult.isCreateable()){
				objFields.add(new Selectoption(fieldResult.getName(), field));
			}
		}
		return objFields;
	}
	
	/**
     * Generate Search Operators based on the specified field type
     * @parm Schema.DisplayType displayType
     * @return List<SelectOption>
    */	
	public static List<SelectOption> getSearchOperators(Schema.DisplayType displayType){
		List<Selectoption> operators= new List<Selectoption>();
    	operators.add(new Selectoption('=', 'Equals'));
    	operators.add(new Selectoption('!=', 'Not Equal To'));
    	if(!numTypes.contains(displayType) && displayType != Schema.DisplayType.Boolean && displayType != Schema.DisplayType.MultiPicklist &&
    			displayType != Schema.DisplayType.Date)
    		operators.add(new Selectoption('LIKE', 'Contains'));
    	if(displayType == Schema.DisplayType.MultiPicklist){
    		operators.add(new Selectoption('INCLUDES', 'Contains'));
    		operators.add(new Selectoption('EXCLUDES', 'Does Not Contain'));
    	}	
    	if(numTypes.contains(displayType) || displayType == Schema.DisplayType.Date){	
	    	operators.add(new Selectoption('<', 'Less Than'));
	    	operators.add(new Selectoption('<=', 'Less or Equal'));
	    	operators.add(new Selectoption('>', 'Greater Than'));
	    	operators.add(new Selectoption('>=', 'Greater or Equal'));
    	}
    	return operators;
	}
	
	/**
     * Generate Logical Operators
     * @parm
     * @return List<SelectOption>
    */
	public static List<SelectOption> getLogicalOperators(){
		List<Selectoption> operators= new List<Selectoption>();
    	operators.add(new Selectoption('AND', 'AND'));
    	operators.add(new Selectoption('OR', 'OR'));
    	return operators;
	}
	
	/**
     * Get Picklist values for the specified field
     * @parm Schema.DescribeFieldResult fieldResult
     * @return List<SelectOption>
    */
	public static List<SelectOption> getPickListOptions(Schema.DescribeFieldResult fieldResult){
		List<Selectoption> pickListOptions = new List<Selectoption>();
    	for(Schema.PicklistEntry ple : fieldResult.getPicklistValues()){
    		if(ple.isActive())
    			pickListOptions.add(new Selectoption(ple.getValue(), ple.getLabel()));
    	}
    	
    	return pickListOptions;
	}
	
	/**
     * Get Search Operators and Values for the specified field
     * @parm List<Wrapper.SearchFilterWrapper> searchFilters, Map<String, Schema.SobjectField> descFieldMap
     * @return
    */
	public static void setFieldTypeAndValues(List<Wrapper.SearchFilterWrapper> searchFilters, Map<String, Schema.SobjectField> descFieldMap){
		for(Wrapper.SearchFilterWrapper searchFilter : searchFilters){
			if(!String.isBlank(searchFilter.selectedField)){
				Schema.DescribeFieldResult fieldResult = descFieldMap.get(searchFilter.selectedField).getDescribe();
				searchFilter.fieldType = fieldResult.getType().name();  
				searchFilter.freeTextField = false;
				//Get the values for picklist/multipicklist
				if(fieldResult.getType() == Schema.DisplayType.Picklist || fieldResult.getType() == Schema.DisplayType.MultiPicklist){
					searchFilter.picklistValues = CustomSearchUtility.getPickListOptions(fieldResult);
				}
				//Get Values for Boolean fields
				else if(fieldResult.getType() == Schema.DisplayType.Boolean){
					searchFilter.picklistValues = new List<SelectOption>{new Selectoption('True', 'True'), new Selectoption('False', 'False')};
				}else if(fieldResult.getType() == Schema.DisplayType.Reference){
					searchFilter.lookupType = String.valueOf(fieldResult.getReferenceTo().get(0));
				}else if(fieldResult.getType() != Schema.DisplayType.Date && !numTypes.contains(fieldResult.getType())){
					searchFilter.freeTextField = true;
					searchFilter.picklistValues = null;
				}
				//Get search operators for the field type
				searchFilter.operators = getSearchOperators(fieldResult.getType());	
			}
		}
	}
	
	/**
     * Validate the numeric fields  
     * @parm List<Wrapper.SearchFilterWrapper> searchFilters, Map<String, Schema.SobjectField> descFieldMap
     * @return Boolean
    */
	public static Boolean validateNumericFields(List<Wrapper.SearchFilterWrapper> searchFilters, Map<String, Schema.SobjectField> descFieldMap){
		Boolean isError = false;
		Pattern numRegEx = Pattern.Compile('[0-9]{0,7}');
		
		for(Wrapper.SearchFilterWrapper searchFilter : searchFilters){
			if(!String.isBlank(searchFilter.selectedField)){
				Schema.DescribeFieldResult fieldResult = descFieldMap.get(searchFilter.selectedField).getDescribe();
				if(numTypes.contains(fieldResult.getType())){
					Matcher isMatch = numRegEx.matcher(searchFilter.value);
					if(String.isBlank(searchFilter.value) || !isMatch.Matches()){
					    searchFilter.errorMsg = 'Invalid Value for this field';
					    isError = true;
					}else
						searchFilter.errorMsg = '';	
				}
			}
		}
		return isError;
	}
}