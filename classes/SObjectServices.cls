/*
 * Class        : SObjectServices
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 1, 2013
 * Objective    : Service class that provides utility methods on SObjects
*/
public with sharing class SObjectServices {
	
	/**
     * Update the List of sObjects. Parameter should be false for partial updates.
     * @parm List<SObject> sObjList, Boolean allowPartialUpdate
     * @return void
    */
	public static void updateSObjects(List<SObject> sObjList, Boolean allowPartialUpdate){
		if(sObjList != null && !sObjList.isEmpty()){
			List<Database.Saveresult> saveResults = Database.update(sObjList, allowPartialUpdate);
			if(saveResults != null){
				for(Database.Saveresult saveResult : saveResults){
					//if the DML on the record fails, log the error
					if(!saveResult.isSuccess()){
						//TODO: Consider implementing custom logging object. Log the error based on Custom Setting/Label
						for(Database.Error err : saveResult.getErrors()){
							System.debug('****** ERROR: ' + err.getMessage());
							System.debug('****** Fields that caused this Error: ' + err.getFields());
						}
					}
				}
			}
		}
	}
	
	/**
     * Insert the List of sObjects.
     * @parm List<SObject> sObjList
     * @return void
    */
	public static void insertSObjects(List<SObject> sObjList){
		if(sObjList != null && !sObjList.isEmpty()){
			try{
				insert sObjList;
			}catch(DMLException dmlEx){
				throw new ChildFundException.CustomDMLException('There was an error creating the SObject List. ' + dmlEx.getMessage());
			}
		}
	}
	
	
    /**
     * Set the value for the sObjects field 
     * @parm SObject sObj, String fieldName, Object value
     * @return Boolean
    */
	public static Boolean setSObjectFieldValue(SObject sObj, String fieldName, Object value){
		if(sObj != null && fieldName != null){
			try{
				sObj.put(fieldName, value);
			}catch(SObjectException sObjEx){
				//this Exception is thrown when the field is invalid. Continue with next teamMember.
				System.debug('****** Invalid field/value on sObject: ' + sObj + ' <==> ' + value);
				return false;	
			}
		}
		return true;
	}
	
	
	/**
     * Get the RecordType for the Specified SObject and Name 
     * @parm String recTypeName, String sObjName
     * @return Boolean
    */
	public static RecordType getRecordType(String recTypeName, String sObjName){
		RecordType rt;
		try{
			rt = [SELECT Id FROM RecordType WHERE DeveloperName =: recTypeName AND sObjectType =: sObjName];
		}catch(QueryException qe){
			System.debug('****** Could not find RecordType for SObject: ' + sObjName + ' with Name: ' + recTypeName);	
		}
		return rt;
	}
	
	/**
     * Get the fields on the specified SObject 
     * @parm SObject sObj, String fieldName, Object value
     * @return Map<String, Schema.SObjectField>
    */
	public static Map<String, Schema.SObjectField> getFieldsForSObject(String sObjectName){
		return Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getmap();
	}

	/**
     * Get the Queues that the Agent is a member of. An agent may belong to multiple group(queue)
     * @parm String groupType, Id userId
     * @return Set<Id>
    */
	public static Set<Id> getGroupsForUser(String groupType, Id userId){
		Set<Id> groupIdset = new Set<Id>();
		for(GroupMember gm: [SELECT Id, GroupId FROM GroupMember where userorgroupId = :userId AND Group.Type = :groupType]){
			groupIdset.add(gm.GroupId);
		}
		return groupIdset;
	}
	
	/**
     * Get the RecordType name/id map for the Specified SObject 
     * @parm String recTypeName, String recTypeId
     * @return Map<String, Id>
    */
	public static Map<String, Id> getRecordNameIdMap(Schema.DescribeSObjectResult descSObj){
	    Map<String, Id> recordTypeMap = new Map<String, Id>(); 
	    Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = descSObj.getRecordTypeInfosByName();
	    for(Schema.RecordTypeInfo recTypeInfo : recordTypeInfoMap.values()){
	    	recordTypeMap.put(recTypeInfo.getName(), recTypeInfo.getRecordTypeId());
	    }
		return recordTypeMap;
	}
}