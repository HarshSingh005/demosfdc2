/***********************************************************************************************************
 * Appirio, Inc
 * Name         : Related_ListController 
 * Created By   : Vaibhav Goel (Appirio)
 * Purpose      : Controller class for "Related_List" component
 * Created Date : 22/Dec/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 06/Apr/2016                  Rohit B.                Added some conditions for Null check
 **********************************************************************************************************/
public with sharing class Related_ListController {
    String objectLabel;
    String objectLabelPlural;
    Boolean showNewButton;
    public ApexPages.StandardSetController ssc {get; set;}
    public List<String> fieldNames {get; set;}
    public Map<String,String> fieldAlignMap {get; set;}
    public Map<String,String> nameLabelMap {get; set;}
    transient Schema.DescribeSObjectResult objectDescribe;
    public Id deleteRecordId {get; set;}
    public String sortByField {get; set;}
    public Map<String,String> fieldSortDirectionMap {get; set;}
    public Integer pageNumber {get;set;}
    
    //----Variables set from attributes defined in the component----
    public String objectName {get; set;}
    public String fieldsCSV {get; set;}
    public List<String> fieldsList {get; set;}
    public String searchFieldName {get; set;}
    public String searchFieldValue {get; set;}
    public String filter {get; set;}
    public String orderByFieldName {get; set;}
    public String sortDirection {get; set;}
    public Integer pageSize {get; set;}
    public String title {get;set;}
    public String returnUrl {get;set;}
    public String moreLink {get;set;}
    public String showMoreLink {get;set;}
    public Boolean showAsStandardRelatedList {get;set;}
    
    public Related_ListController(){
    }
    
    public List<sObject> getRecords(){
        if(ssc == null){    
        //Do validation to ensure required attributes are set and attributes have correct values
        //fieldList or fieldsCSV must be defined
        Boolean validationPass = true;
        
        if(fieldsList == null && fieldsCSV == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'fieldList or fieldsCSV attribute must be defined.'));
            validationPass = false;
        }
        
        //Ensure sortDirection attribute has value of 'asc' or 'desc'
        if(sortDirection != null && sortDirection != 'asc' && sortDirection != 'desc'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'sortDirection attribute must have value of "asc" or "desc"'));
            validationPass = false;
        }
        
        //Proceed with returning the related list if validation passed
        if(validationPass == false || String.isBlank(objectName)){
            return null;
        }else{
            //Build the query string dynamically
            String queryString = 'SELECT ';
            
            /*If field CSV was defined use this and also add fields to the fieldNames
            List so they can be used with Visualforce dynamic binding to define coloumns*/
            if(fieldsCSV != null){
                queryString += fieldsCSV;       
                fieldNames = fieldsCSV.split(',');
            }else{
                //Add fields to fieldNames list so it can be used with VF dynamic binding to define coloumns
                fieldNames = fieldsList.clone();
                
                //Loop through list of field names in fieldList and add to query
                for(String fld : fieldsList){
                    queryString += fld + ',';
                }
                
                //Remove the very last comma that was added to the end of the field selection part of the query string
                queryString = queryString.substring(0,queryString.length() - 1);
            }
            
            if(String.isBlank(searchFieldValue) && String.isBlank(filter)){
                queryString += ' FROM ' + objectName + ' LIMIT 0 ';
            }
            else{
                
                //add from object and parent criteria
                queryString += ' FROM ' + objectName + ' WHERE ';
                
                String filterCriteria = ''; 
                if(String.isNotBlank(searchFieldValue) && String.isNotBlank(searchFieldName)){
                    filterCriteria += searchFieldName + ' = \'' + searchFieldValue.trim() + '\'';
                }
                
                //Add any addtional filter criteria to query string if it was defined in component
                if(filter != null && filter.length() > 0 ){
                    filterCriteria += ( String.isBlank(filterCriteria) ? '' : ' AND ' ) + filter;             
                }
                
                queryString += filterCriteria;
                
                //Add order by field to query if defined in component
                //If sortByField != null then user has clicked a header and sort by this field
                if(sortByField != null){
                    queryString += ' order by ' + sortByField;
                }else if(orderByFieldName != null){
                    queryString += ' order by ' + orderByFieldName;
                }
                
                //If sortByField != null then user has clicked a header, sort based on values stored in map
                if(sortByField != null){
                    /*Use a map to store the sort direction for each field, on first click of header sort asc
                    and then alternate between desc*/
                    if(fieldSortDirectionMap == null){
                        fieldSortDirectionMap = new Map<String,String>();                   
                    }
                    
                    String direction = '';
                    
                    //check to see if field has direction defined, if not or it is asc, order by asc 
                    if(fieldSortDirectionMap.get(sortByField) == null || fieldSortDirectionMap.get(sortByField) == 'desc' ){
                        direction = 'asc';
                        fieldSortDirectionMap.put(sortByField,'asc');
                    }else{
                        direction = 'desc';
                        fieldSortDirectionMap.put(sortByField,'desc');
                    }
                    
                    queryString += ' ' + direction; 
                }else if(sortDirection != null){
                    //Add sort direction to query if defined in component
                    queryString += ' ' + sortDirection;             
                }
                
                //Add limit clause to end of the query
                queryString += ' limit ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());  
            }      
            System.debug('Related List Component Query String: ' + queryString);
            
            //Query records and setup standard set controller for pagination
            ssc = new ApexPages.StandardSetController(Database.query(queryString));
            
            //Check to see if more than 10,000 records where return, if so display warning as standard set controller can only process 10,000 recores
            if(ssc.getCompleteResult() == false){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There were more related records than could be processed. This is a partially complete list.'));
            }
            //Set pagination size based on value set in component
            if(pageSize != null){
                ssc.setPageSize(pageSize);
            }       
                
            /*For the fields that will be displayed identify the field type and set styleClass for
            cell alignment. Numbers, Currency, %, etc should align right in table. put in map FieldName -> class name*/
                //Get the meta data info for the fields is the related object
                Map<String, Schema.SObjectField> fieldMap = getObjectDescribe().fields.getMap(); 
                Map<String,String> mapReferenceFields = new Map<String,String>();
                Map<String, Map<String, Schema.SObjectField>> mapReferenceObjectsFieldMap = new Map<String, Map<String, Schema.SObjectField>>(); 
                
                for(Schema.SObjectField field : fieldMap.values()){
                    Schema.DescribeFieldResult fieldResult = field.getDescribe();
                    if(fieldResult.getType() == Schema.DisplayType.Reference){
                        mapReferenceFields.put(fieldResult.getRelationshipName(), String.valueOf(fieldResult.getReferenceTo()[0]));
                    }
                }
                
                //For the fields in the related list populate fieldAlignMap map with the name of the correct style class. Also populate name->label map for header display
                fieldAlignMap = new Map<String,String>();
                nameLabelMap = new Map<String,String>();
                for(String fld : fieldNames){
                    fld = fld.trim();
                    if(fieldMap.containsKey(fld)){
                        populateFieldMaps(fld, fieldMap, fld);
                    }
                    else if(fld.contains('.')){
                        populateReferenceFields(fld, fld, mapReferenceFields, mapReferenceObjectsFieldMap);
                    }
                    else{
                        fieldAlignMap.put(fld,'alignLeft');
                        nameLabelMap.put(fld,fld);
                    }
                    
                }
            }
        
        }
        
        calculateMoreRecords(false);
        return ssc.getRecords();
    }
    
    private void populateReferenceFields(String fld, String fieldName, Map<String,String> mapReferenceFields, Map<String, Map<String, Schema.SObjectField>> mapReferenceObjectsFieldMap){
        
        List<String> fieldParts = fieldName.split('\\.', 2);
        
        if(mapReferenceFields.containskey(fieldParts[0])){
            String refObjectName = mapReferenceFields.get(fieldParts[0]);
            Map<String, Schema.SObjectField> refObjFieldMap;
            if(mapReferenceObjectsFieldMap.containskey(refObjectName)){
                refObjFieldMap = mapReferenceObjectsFieldMap.get(refObjectName);
            }
            else{
                refObjFieldMap = Schema.getGlobalDescribe().get(refObjectName).getDescribe().Fields.getMap();
                mapReferenceObjectsFieldMap.put(refObjectName, refObjFieldMap);
            }
            
            if(fieldParts[1].contains('.')){
                 mapReferenceFields = new Map<String,String>();
                 for(Schema.SObjectField field : refObjFieldMap.values()){
                    Schema.DescribeFieldResult fieldResult = field.getDescribe();
                    if(fieldResult.getType() == Schema.DisplayType.Reference){
                        mapReferenceFields.put(fieldResult.getRelationshipName(), String.valueOf(fieldResult.getReferenceTo()[0]));
                    }
                }
                populateReferenceFields(fld, fieldParts[1],  mapReferenceFields, mapReferenceObjectsFieldMap);
            }
            else{
                if(refObjFieldMap.containskey(fieldParts[1])){
                    populateFieldMaps(fld, refObjFieldMap, fieldParts[1]);
                }
                else{
                    fieldAlignMap.put(fld,'alignLeft');
                    nameLabelMap.put(fld,fld);
                }
            }
        }
    }
    
    private void populateFieldMaps(String fld, Map<String, Schema.SObjectField> field_map, String fieldApi){
        
        String fieldType = field_map.get(fieldApi).getDescribe().getType().name();    

        if(fieldType == 'CURRENCY' || fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'INTEGER'){
            fieldAlignMap.put(fld,'alignRight');
        }else{
            fieldAlignMap.put(fld,'alignLeft');
        }   
        
        //Add to name->label map
        String label = field_map.get(fieldApi).getDescribe().getLabel();
        nameLabelMap.put(fld,label);
    }
    
    
    public Boolean getShowNewButton(){
        //Display new button if user has create permission for related object
        return getObjectDescribe().isCreateable();
    }
    
    public DescribeSObjectResult getObjectDescribe(){
        /*Returns object describe for list object. This is used in many places so we are using a dedicated method that only invokes 
        Schema describe calls once as these count against Apex limits. Because this method returns a DescribeSObjectResult all the get 
        methods for this object can be used directly in Visualforce: {!objectDescribe.label}*/
        if(objectDescribe == null){
            objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();  
        }
        return objectDescribe;
    }
    
    public void sortByFieldAction(){
        
        //Making ssc variable null will cause getRecords method to requery records based on new sort by field clicked by user
        ssc = null;
    }
      
    public void deleteRecord(){
        //Delete the selected object
        for(sObject obj : ssc.getRecords()){
            if(obj.get('Id') == deleteRecordId){
                delete obj;
                break;              
            }
        }
        
        /*There is no way to modify the collecton used in a standard set controller so we will make it null and call getRecord
        method. This will reload the set of records*/
        //Save the current page number so we can keep user on same page in the set after delete
        Integer pageNumber = ssc.getPageNumber();
        
        //Make ssc variable null and execute get method
        ssc = null;
        getRecords();
        
        /*Set the correct page number. If record deleted was a single record on the last page set the number of pages in 
        the new set will decrease by 1, need to check for this. If the total number of pages is less than than the previous 
        page number set the current page to the previous last page - 1 */
        Decimal rSize = ssc.getResultSize();
        Decimal pageSize = ssc.getPageSize();
        
        if(( rSize / pageSize).round(System.RoundingMode.UP) < pageNumber){
            ssc.setPageNumber(pageNumber - 1);
        }else{
            ssc.setPageNumber(pageNumber);
        }
    }
    
    public void showMore(){
        calculateMoreRecords(true);
    }
    
    private void calculateMoreRecords(Boolean isSetPageSize){
        Integer totalRecord = ssc.getResultSize();
        System.debug('-------------totalRecord============'+totalRecord);
        Integer page_size = ssc.getPageSize();
        Integer pageNumber = ssc.getPageNumber();
        Integer currentRecords = page_size * pageNumber;
        
        if(currentRecords < totalRecord){
            Integer remainingRecords = totalRecord - currentRecords;
            showMoreLink = 'Show ' + (remainingRecords < page_size ? remainingRecords : page_size) + ' more »';
            if(isSetPageSize){
                pageSize = page_size + page_size;
                ssc.setPageSize(pageSize);
            }
        }
        else {
            showMoreLink = '';
        }
    }
}