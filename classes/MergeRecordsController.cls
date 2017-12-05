/*******************************************************************************
Name                    : MergeRecordsController.cls

Modified By     :   Basant Kumar Verma (Appirio JDC), Jagjeet Singh T-474754
Story/Task      : S-213685/T-277614
Date                    : 21st May, 2014
Description     : Modified to allow merge functionality only on Contact Object

*******************************************************************************/
public without sharing class MergeRecordsController {
    
    // START : Changed for S-213685/T-277614 - By Basant Verma (Appirio JDC) - 21st May, 2014
    public boolean isForSingleObject {get; set;}
    public String objId {get; set;}
    public String objLabel {get; set;}
    // END : Changed for S-213685/T-277614 - By Basant Verma (Appirio JDC) - 21st May, 2014
    //this guides the number of merged records
    public Integer getMaxRecordsCount(){return MergeRecordsUtil.MERGED_RECORDS_COUNT;}
    public String sObjectName {get;set;}
    
    //choosen sobject
    public String sObjectType{get;Set;}
    //sobject has changed
    public String sObjectTypeOld = null;
    public List<SObject> objList;
    //search text
    public String searchText{get;Set;}
    //results of the search SOSL query
    public List<SObject> foundRecordList{get;set;}
    
    // field selected to show in the table
    public String fieldSelected{
        get { return fieldSelected; }
    set { fieldSelected = value; }
    
    }  
  // selected page in the table
  public string selectedPage{
    get;
    set{selectedPage=value;}  //set from the parameter in actionFunction
  }
  //SObject list
  public List<SelectOption> sobjectsSlctOpt{get;Set;}
  public String soslFields;
  //merging objects
  public List<SObject> merginObjects{get;set;}
  public List<String> mergingIds{get;set;}
  public Map<ID,Map<String,MergeRecordsUtil.InputHiddenValue>>selectedObjFields {get;set;}
  //Describe information for the selected sobject
  public MergeRecordsUtil.DescribeResult describe{get;set;}
  //Move an object form the search list to the "merge table"
  public String selectMergetObjectId{get;set;}
  public Integer selectMergetObjectPosition{get;set;}
  //selected master object
  public String masterObjectId{get;set;}
    
    public MergeRecordsController() { 
        this.objList = new List<sObject>();
        this.describe = new MergeRecordsUtil.DescribeResult();   
        this.foundRecordList = new List<Sobject>();
        this.sobjectsSlctOpt = new List<SelectOption>();
        //this.uniqueFields = new Map<String,String>();
        this.merginObjects = new List<SObject>();
        //this.allFields = new Map<String,MergeRecordsUtil.Field>();
        this.selectedObjFields = new  Map<ID,Map<String,MergeRecordsUtil.InputHiddenValue>>();
        //set ot store an ordered list of sobjects (by name)
        Set<String> objsOrderName = new Set<String>();
        //search for the "searchable" sobjects and stores the describes
        Map<String,String> sobjNamesLabels = new Map<String,String>();
        
        // START : Changed for S-213685/T-277614 - By Basant Verma (Appirio JDC) - 21st May, 2014
        if(Apexpages.currentPage().getParameters().containsKey('sObject')){
            isForSingleObject = true;
            sObjectType = Apexpages.currentPage().getParameters().get('sObject');
            if(Apexpages.currentPage().getParameters().containsKey('sObjectId')){
            objId = Apexpages.currentPage().getParameters().get('sObjectId');
            String objFld = 'Name';
            if(Apexpages.currentPage().getParameters().containsKey('sObjectField')){
                objFld = Apexpages.currentPage().getParameters().get('sObjectField');
            }
            String soql = 'Select Id, '+objFld+' From '+sObjectType+' Where Id = \''+objId+'\'';
            searchText = (String)(Database.query(soql)).get(0).get(objFld);
            system.debug('----searchText----' + searchText);
            }
        }else{
            isForSingleObject = false;
        }
        //Jagjeet Singh : Filter Added for the allowed objects. Task # - T-474754
        Set<String> allowedObjects = new Set<String>{'Account','Contact'}; 
            
        for(Schema.Sobjecttype sot : Schema.getGlobalDescribe().values()){
            Schema.Describesobjectresult dr = sot.getDescribe();
            if(allowedObjects.contains(dr.getName()) && dr.isSearchable() && dr.isAccessible() && dr.isCustomSetting()==false  && dr.isDeprecatedAndHidden()==false
            && dr.isQueryable() && dr.isUpdateable() && dr.isDeletable()){
                if( (isForSingleObject && dr.getName().trim().equalsIgnoreCase(sObjectType)) || !isForSingleObject){
                sobjNamesLabels.put(dr.getName(), dr.getlabel());
                objsOrderName.add(dr.getName());
                }
            }
        }
        System.debug('objsOrderName..................'+objsOrderName);
        System.assert(objsOrderName.size()>0,'No object found.');
        if(isForSingleObject){
            objLabel = sobjNamesLabels.get(sObjectType);
        }
        // END : Changed for S-213685/T-277614 - By Basant Verma (Appirio JDC) - 21st May, 2014
        
        //creates a list to make it order its elements
        List<String> nameList = new List<String>(objsOrderName);
        nameList.sort();
        System.debug('nameList..................'+nameList);
        // List of Merge object Ids
        mergingIds = new List<String>{'0','0','0'};        
        for(String name : nameList){
            this.sobjectsSlctOpt.add(new SelectOption(name,sobjNamesLabels.get(name)));
        }
        selectedPage = '0' ;
        
        // START : Changed for S-213685/T-277614 - By Basant Verma (Appirio JDC) - 21st May, 2014
        if(isForSingleObject){
            searchRecords();
            selectMergetObjectPosition = 0;
            selectMergetObjectId = objId;
            selectMergetObject();
        }
        sObjectName = '';
                // END : Changed for S-213685/T-277614 - By Basant Verma (Appirio JDC) - 21st May, 2014
    }
    

        
  public void initDescribe(){   
        this.masterObjectId = null;
        this.foundRecordList = new List<Sobject>();
        this.selectedObjFields = new  Map<ID,Map<String,MergeRecordsUtil.InputHiddenValue>>();
        this.merginObjects = new List<Sobject>();
        this.objlist = new List<sObject>();    
        System.debug('aaaaaaaaaaaaaaaaaaaaaaaa'+this.sObjectType);
        this.describe = MergeRecordsUtil.initDescribes(this.sObjectType);
    //fills with blank objects
    for(Integer i = this.merginObjects.size(); i < getMaxRecordsCount(); i++){
    	System.debug('bbbbbbbbbbbbbbbbbbb'+this.describe.sOType.newsobject());
        this.merginObjects.add(this.describe.sOType.newsobject());
    }
    System.debug('ccccccccccccccccc'+this.merginObjects);
    System.debug('ddddddddddddddddddddddd'+getMaxRecordsCount());
    System.assert(this.merginObjects.size()== getMaxRecordsCount() ,'Initialization of mergeing object incorrect. Must be exactly '+getMaxRecordsCount()+' void objects');
    }
    
  /**
    Record search
  **/
  
  public void searchRecords(){
        selectedPage = '0';
        if(this.searchText==null || this.searchText.trim().length()==0){ 
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Search non void text.'));
        return;
        }
        
    System.assert(sObjectType!=null && sObjectType.length()>0,'Object Type should not be blank.');
    //if the sobject changes, need for refresh
    if(sObjectTypeOld != sObjectType){
        sObjectTypeOld = this.sObjectType;
        initDescribe();
        }
        
    soslFields = '';
    if(this.describe.allFields.size()>0){
            for(String s : this.describe.allFields.keySet()){
                
                soslFields+=s+',';
            }
                //TODO here we can filter the fields
        }
    soslFields = soslFields.substring(0,soslFields.length()-1);
    System.debug('soslFields..................'+soslFields);
    selectedPage='0';
    
    list<String> accountRecordTypeIds = new List<String>();
    if(sObjectType != '' && sObjectType == 'Account'){
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        accountRecordTypeIds.add(rtMapByName.get('Community').getRecordTypeId());
        accountRecordTypeIds.add(rtMapByName.get('Local Partner').getRecordTypeId());
        accountRecordTypeIds.add(rtMapByName.get('National Office').getRecordTypeId());
        system.debug('-----list---' +  accountRecordTypeIds);
    }
    String searchquery = '';
    if(accountRecordTypeIds != null && accountRecordTypeIds.size() > 0){
        searchquery='FIND \''+this.searchText.trim()+'\' IN ALL FIELDS RETURNING '+sObjectType+' ('+soslFields+' where Id not in :mergingIds AND recordtypeID NOT IN :accountRecordTypeIds ORDER BY '+this.describe.nameField+' limit 200)';
        System.debug('Search query: '+searchquery);
        
    }else{
        searchquery='FIND \''+this.searchText.trim()+'\' IN ALL FIELDS RETURNING '+sObjectType+' ('+soslFields+' where Id not in :mergingIds ORDER BY '+this.describe.nameField+' limit 200)';
        System.debug('Search query: '+searchquery);
        
    }
    
    try{  
            List<List<SObject>> result = search.query(searchquery);
      objList =new List<SObject>(); 
      for(List<SObject> lst : result) 
        objList = lst;    
        if(objList.size()==0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'No record found.')); 
                    foundRecordList = new List<sObject>();
                    return;
        }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
    }
    
    cont = new ApexPages.StandardSetController(objList);
    // sets the number of records in each page set
    cont.setPageSize(5);
    cont.setpageNumber(1);
    system.debug('---cont---' + cont.getResultSize());
    
    if(cont.getResultSize() > 0){
        foundRecordList = cont.getRecords();
    }
    
  }
  
    /*
        Modied Code logic Starts
        Date : Feb 16,2016 
        Task : T-474754
        Purpose : Adding simplified Pagination Logic and removing custom pagination logic provided by Asset
        Developer : Vaibhav Goel 
  
    */
    
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController cont {get;set;}
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return cont.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return cont.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return cont.getPageNumber();
        }
        set;
    }

    // returns the first page of records
    public void first() {
        cont.first();
        
        foundRecordList = cont.getRecords();
    }

    // returns the last page of records
    public void last() {
        cont.last();
     
        foundRecordList = cont.getRecords();
    }

    // returns the previous page of records
    public void previous() {
        cont.previous();
    
        foundRecordList = cont.getRecords();
    }

    // returns the next page of records
    public void next() {
        cont.next();
        foundRecordList = cont.getRecords();
    }
  
  /*
    Code logic ends
    Date : Feb 16,2016 
    Task : T-474754
    Purpose : Pagination Logic
    Developer : Vaibhav Goel 
  
  */
  
    
    //Moves an object from the search list to the marging list
  public void selectMergetObject(){
        if(selectMergetObjectId == null || selectMergetObjectPosition == null 
            || selectMergetObjectPosition<0 || selectMergetObjectPosition >= getMaxRecordsCount())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No object selected or error in position.'));
            return;
        }
        System.debug(' select Merget Object Id '+selectMergetObjectId +' selectMergetObjectPosition '+selectMergetObjectPosition);
        for(SObject obj : this.foundRecordList)
        {
            if((String)obj.get('ID') == this.selectMergetObjectId)
            {
                String prevObjId = (String)this.merginObjects[this.selectMergetObjectPosition].get('Id');
                
                //if current position object is the master object, it is "deselected"
                if(prevObjId == this.masterObjectId){ 
                    this.masterObjectId = null;
                }
                
                //remove previous "field selection" informations
                if(prevObjId != null){ 
                    this.selectedObjFields.remove(prevObjId);
                }
                
                //previous object replaced by current selected object
                this.merginObjects[this.selectMergetObjectPosition] = obj;
                //mergingIds.add(obj.Id); 
                mergingIds[this.selectMergetObjectPosition] = obj.Id;
                //init the map of "selected" fields
                Map<String, MergeRecordsUtil.InputHiddenValue> flist =  new Map<String,MergeRecordsUtil.InputHiddenValue>();
                selectedObjFields.put((ID)selectMergetObjectId, flist);
                for( MergeRecordsUtil.Field f : this.describe.allFields.values()){
                    flist.put(f.name,new MergeRecordsUtil.InputHiddenValue(f.name,false,f.isWritable));
                }
                sObjectName = (String)obj.get('Name');
                System.debug('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+sObjectName);
                break;
            }
        }
        searchRecords();
        System.debug('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'+sObjectName);
    }
    
    //merge records into one
    public PageReference mergeRecords()
    {
        if(this.masterObjectId == null || this.masterObjectId.trim().length()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select a Survivor record.'));
            return null;
        }
 
        MergeRecordsUtil.SelectMasterResult smr = MergeRecordsUtil.mergeRecords(this.merginObjects, this.masterObjectId);
        if(smr.masterObject == null || smr.loserObjs.size()==0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You need more than one record to merge.'));
            return null;
        }
        
        try{
            MergeRecordsUtil.copyDataIntoMasterRecord(smr,this.selectedObjFields,this.sObjectType);
            PageReference page = new PageReference('/'+smr.masterObject.Id);
            page.setRedirect(true);
            return page;
        }
        catch(DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An unexpected error occurred: '+e.getMessage()));
        }
        initDescribe();
            
            
        return null;
    }
    
}