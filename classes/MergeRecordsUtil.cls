/*******************************************************************************
Name                : MergeRecordsUtil

Modified By : Basant Kumar Verma(Appirio JDC)
Date                : 15th May, 2014
Task                : T-278839

Modified By         Reason
Jagjeet Singh       T-480686 - Added a check to avoid the GPS geolocation field on the search result.
*******************************************************************************/
public without sharing class MergeRecordsUtil {
    
    //this guides the number of merged records
    public final static Integer MERGED_RECORDS_COUNT = 3;
    //Utility class to handle the master/loosers selection
    public class SelectMasterResult
    {
        public List<SOBject> loserObjs = new List<SObject>();
        public SObject masterObject = null;
    }
    
    //Utility class to handle the single cell
    public class InputHiddenValue
    {
        public InputHiddenValue(String name, Boolean isChecked, Boolean isSelectable)
        {
            this.isChecked = isChecked;
            this.isSelectable = isSelectable;
            this.name = name;
        }
        //checked or not to merge into che master record
        public Boolean isChecked{get;set;}
        //avoid formula/unchangeble fields
        public Boolean isSelectable{get;set;}
        //field name
        public String name{get;set;}
    }   
    
    //Utility class to handle field specs
    public class Field
    {
        public Field(String name, String label, Boolean isWritable)
        {
            this.name = name;
            this.label = label;
            this.isWritable = isWritable;
        }
        public String name{get;set;}
        public String label{get;set;}
        public Boolean isWritable{get;set;}
    }
    
    
    
    public static SelectMasterResult mergeRecords(List<SObject> merginObjects, String masterId)
    {
        SelectMasterResult res = new SelectMasterResult();
        
        //select the master record and the looser ones
        for(SObject sobj : merginObjects)
        {
            String id = (String)sobj.get('Id');
            if(id==null) continue;
            
            if(id == masterId)
            {
                res.masterObject = sobj;
            }
            else
            {
                res.loserObjs.add(sobj);
            }
        }
        return res;
        
    }
    
    /*
        Copy looser records data into master record using the "selectedObjFields" (map of map of InputHddenValue)
    */
    
    
    public static void copyDataIntoMasterRecord(SelectMasterResult recordSet, Map<ID,Map<String,InputHiddenValue>> selectedObjFields,String objType)
    {   
        System.assert(recordset != null, 'RecordSet should not be null.');
        System.assert(recordset.masterObject != null, 'Master object should not be null.');
        System.assert(recordset.loserObjs != null && recordset.loserObjs.size()>0, 'Looser objects should not be null and should be more than 0.');
        for(Sobject sobj : recordSet.loserObjs)
        {
            Map<String, InputHiddenValue> flds = selectedObjFields.get((ID)sobj.get('Id'));
            System.assert(flds!=null,'Field Selection Map should not be null');
            //inv.name
            
            for(InputHiddenValue inv : flds.values())
            {
                if(inv.isSelectable==false)continue;
                if(inv.isChecked==false) continue;
                recordSet.masterObject.put(inv.name, sobj.get(inv.name));
            }
            
        }
        
        Sobject masterRec;
        if(objType == 'Account'){
            masterRec = new Account(id = recordSet.masterObject.id);
            
        }
        if(objType == 'Contact'){
            masterRec = new Contact(id = recordSet.masterObject.id);
        }
        
       // masterRec = recordSet.masterObject.clone(true, true, true, true);
        
        Database.MergeResult[] results = Database.merge(masterRec, recordSet.loserObjs, false);
        for(Database.MergeResult res : results){
            if(!res.isSuccess()){
                for(Database.Error err : res.getErrors()){
                    system.debug('----err---' + err.getMessage());
                    throw new ChildFundException(err.getMessage());
                }
            }
                
        }        
        update recordSet.masterObject;
    }
    
    public class DescribeResult
    {
        public DescribeResult()
        {
            this.allFields = new Map<String,Field>();
            this.uniqueFields = new Map<String,String>();
        }
        //name fields map (API name / label)
        public String nameField {get;set;}
        public String nameFieldLabel {get;set;}

        //all fields
        public Map<String, MergeRecordsUtil.Field> allFields{get;set;}
        //sorted keyset
        public List<String> allFieldsKeySet{
            get{
    
                List<String> output = new List<String>(allFields.keySet());
                output.sort();
                return output;
            }
        }
        
        //unique fields to show in the search results
        public Map<String,String> uniqueFields {get;set;}
        //returns an ordered "unique fields" keyset
        public List<String> uniqueFieldsKeySet{
            get{
                List<String> ufl = new List<String>(uniqueFields.keySet());
                ufl.sort();
                return ufl;
            }
        }
        public Schema.SobjectType sOType = null;
    }
    
    public static DescribeResult initDescribes(String sObjectType)
    {
        Map<String, String> contactMap = new Map<String, String>();
        Map<String, String> accountMap = new Map<String, String>();
        DescribeResult result = new DescribeResult();
        result.sOType = Schema.getGlobalDescribe().get(sObjectType);
        System.assert(result.sOType!=null ,'No describe for SObject '+result.sOType);
        Map<String, Schema.SObjectField> fieldMap = result.sOType.getDescribe().fields.getMap();
        result.nameField = 'Id';
        result.nameFieldLabel = 'Id';
        //search for "name" fields
        for(String name : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(name);
            Schema.DescribeFieldResult dfs = field.getDescribe();
            
            //all fields to display
            Boolean isWritable = dfs.isUpdateable();
            //T-480686 : Additional Condition for GPS field
            if(dfs.getName() == 'BillingAddress' || dfs.getName() == 'ShippingAddress' || dfs.getName() == 'IsPartner' || dfs.getName() == 'MailingAddress' || dfs.getName() == 'Address' || dfs.getName() == 'OtherAddress' || dfs.getName() == 'GPS__c') {
                continue;
            }
            //result.allFields.put(dfs.getName(),new Field(dfs.getName(),dfs.getlabel(),isWritable));
            //if(isWritable) {
            	result.allFields.put(dfs.getName(),new Field(dfs.getName(),dfs.getlabel(),isWritable));
           // } 
            if(dfs.isNameField()){
                result.nameField = dfs.getName();
                result.nameFieldLabel = dfs.getlabel();
            }
        }
        
        /*
        if(sObjectType == 'Account'){
            result.uniqueFields = accountMap;
        } else if(sObjectType == 'Contact'){
            result.uniqueFields = contactMap;
        } */
        System.debug('jjjjjjjjjjjjjjjjjjjjjjjjj'+result.uniqueFields);
        return result;
    }
}