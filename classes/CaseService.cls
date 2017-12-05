/**
 * CaseService: Service class that provides utility methods on Case sObject
 *
 * Ver No.     Developer/Org                 Date         Changes
 * -----------------------------------------------------------------------------
 *   1.0       Charlie Xie/Bluewolf          02/03/2014    Created
 */  
public with sharing class CaseService {
	
	//Added by KK: Property to get the default case assignment rule 
	public static Database.DMLOptions defaultAssignmentDBOptions{
        get{
            if(defaultAssignmentDBOptions == null){
                defaultAssignmentDBOptions = new Database.DMLOptions();
                defaultAssignmentDBOptions.assignmentRuleHeader.useDefaultRule = true;
            }
            return defaultAssignmentDBOptions;
        }
        private set;
    }
	/*
	* Get Cases that belong to the Queues and skill set of the agent
	* Priority Values: High, Standard  DESC: High > Standard
	*/
	public static Case dequeueCase(Set<Id> queueIdSet, Set<String> agentSkillSet){
		List<Case> caseLst = [SELECT Id, OwnerId, CaseNumber, Priority, SLA_Number__c FROM Case 
							  WHERE OwnerId IN:queueIdSet 
								  AND Agent_Skill__c IN :agentSkillSet FOR UPDATE];
		//Explicit ORDER BY not allowed when locking rows, therefore, the list should be sorted explicitly rather then using order by.
		//ORDER BY Priority DESC,SLA_Number__c ASC LIMIT 1
	    if(caseLst.size()>0){
	    	Map<String, List<Case>> priorityMap = new Map<String, List<Case>>();
	    	//seperate cases with different priority
	        for(Case c: caseLst){
	        	if(!priorityMap.containsKey(c.Priority)){
	        		List<Case> priorityCaseLst = new List<Case>();
	        		priorityCaseLst.add(c);
	        		priorityMap.put(c.Priority, priorityCaseLst);
	        	}else{
	        		priorityMap.get(c.Priority).add(c);	
	        	}
	        } 
	        Set<String> keys = priorityMap.keySet();    
	        String highestPriority;
	        for(String k :keys){
	        	if(String.isBlank(highestPriority)){
	        		highestPriority = k;
	        		continue;
	        	}
	        	if(k.compareTo(highestPriority) < 0)//DESC 'N'>'H' IF k.compareTo(highestPriority) < 0 THEN k is 'High'
					highestPriority = k;
	        } 
	        List<Case> highestPriorityCaseLst = priorityMap.get(highestPriority);
	        Case resultCase = null;
	        for(Case c: highestPriorityCaseLst){
	        	if(resultCase == null){
	        		resultCase = c; 
	        		continue;
	        	}else{
	        		if(c.SLA_Number__c < resultCase.SLA_Number__c){// SLA_Number__c ASC 
	        			resultCase = c;
	        		}
	        	}
	        }
			return resultCase;
	    }else{
	    	return null;
	    }
	}

	public static void setTargetSLATimes(Boolean isUpdate, List<Case> newCaseLst){
        try{
	        datetime d = datetime.now();
	        id defBusinessHours = [select id from BusinessHours where isDefault = true].id;
	        
	        for(case c : newCaseLst){
	            if(isUpdate){
	                d = c.createdDate;    
	            }
	            id bId = defBusinessHours;  

	            if(c.BusinessHoursId != null) 
	                bId = c.BusinessHoursId;
	            //Response_Business_Hours__c would be updated by workflow rules during insertion
	            if(c.Response_Business_Hours__c != null){
	                c.Target_Response_Time__c = BusinessHours.Add(bId, d, 
	                                                math.roundToLong(c.Response_Business_Hours__c * 3600000));
	            }
	            //Resolution_Business_Hours__c would be updated by workflow rules during insertion
	            if(c.Resolution_Business_Hours__c != null)
	                c.Target_Resolution_Time__c = BusinessHours.Add(bId, d, 
	                                                math.roundToLong(c.Resolution_Business_Hours__c * 3600000));          
	        }
        }catch(Exception e){
            System.debug('setTargetSLATimes Exception : '+e);
            System.debug('current User : '+UserInfo.getUserId());
        }
	}
	
	/** Added by KK
     * Get all the related case field sets and construct a unique set of field api names
     * @parm 
     * @return Set<String>
    */	
	public static Set<String> getCaseFieldsFromFieldSets(){
		Set<String> caseFields = new Set<String>();
		//get all the related case field sets and construct a unique set of field api names
		try{
			List<Schema.FieldSetMember> caseFieldSet = SObjectType.Case.FieldSets.Standard_Case.getFields();
			//caseFieldSet.addAll(SObjectType.Case.FieldSets.Standard_Case.getFields());
			caseFieldSet.addAll(SObjectType.Case.FieldSets.National_Office_Case.getFields());
			caseFieldSet.addAll(SObjectType.Case.FieldSets.NO_Project_Single_Column.getFields());
			caseFieldSet.addAll(SObjectType.Case.FieldSets.Child_Inquiry_Case.getFields());
			caseFieldSet.addAll(SObjectType.Case.FieldSets.NO_Participant_Single_Column.getFields());
			
			for(Schema.FieldSetMember fieldSet : caseFieldSet){
				caseFields.add(fieldSet.getFieldPath());	
			}
		}catch(Exception e){
			System.debug('Case Field Sets do not exist');
		}
		return caseFields;
	}
	
	/* 
	* Update status of Parent Case if all its childcaseS are updated to isClosed status
	*/
	public static void updateMasterCaseWithStatus(Map<Id, Case> oldMap, List<Case> caseNewLst){
		Set<Id> masterCaseIdSet = new Set<Id>();
		List<Case> masterCaseToUpdate = new List<Case>();
		//only child cases that were updated to 'isClosed' status trigger the next process: updating the status of parent case
		for(Case updatedCase : caseNewLst){
			//For those child case whose isClosed status is changed, add their master case Id to set
			if(updatedCase.Master_Case__c !=null && updatedCase.IsClosed!=oldMap.get(updatedCase.Id).IsClosed){
				masterCaseIdSet.add(updatedCase.Master_Case__c);
			}
		}
		//Stop Execution if there are no masterCase that need to be updated
		if(masterCaseIdSet.isEmpty())
			return;

		for(Case masterCase :[SELECT Id, Status, (SELECT Id, IsClosed,Master_Case__c FROM Related_Cases__r) 
								    FROM Case WHERE Id IN:masterCaseIdSet]){
			//Defaultly close masterCase unless it has non-MarkedComplete ChildCase
			Boolean closeMasterCase = true;
			for(Case childCase : masterCase.Related_Cases__r){
				if(childCase.IsClosed!=true){
					closeMasterCase = false;
					break;
				}
			}
			if(closeMasterCase==true){
				masterCase.Status = 'Closed';
				masterCaseToUpdate.add(masterCase);
			}
			else
			{
				if(masterCase.Status == 'Closed'){
					masterCase.Status = 'In Progress';
					masterCaseToUpdate.add(masterCase);
				}
			}
		}
		//Update MasterCase's status only if masterCaseToUpdate contains any master Case
		if(masterCaseToUpdate.size()>0){
			try{
				update masterCaseToUpdate;
			}catch(DmlException e){
				System.debug('updateMasterCaseWithStatus DmlException Exception');
			}
		}
	}
	/*
	 * Update the master-case to 'In Progress' after a new child-case is inserted to
	 * a master-case with a 'Closed' status
	 */
	 public static void updateClosedMasterCaseToInProgress(List<Case> caseLst)
	 {
	 	//Create a list to hold the Id's of the inserted cases that have a master
	 	Set<Id> masterCaseIdSet = new Set<Id>();
	 	//Create a list to store master cases that need to have their status updated
	 	List<Case> masterCaseToUpdate = new List<Case>();

	 	//Iterate through the inserted cases and check for any closed master cases
	 	for (Case insertedCase: caseLst)
	 	{
	 		if (insertedCase.isClosed == false && insertedCase.Master_Case__c != null)
	 		{
	 			masterCaseIdSet.add(insertedCase.Master_Case__c);
	 		}
	 	}

	 	//Stop execution if there are no master cases that need to be updated
	 	// i.e. if no open child cases have been added to a closed master cases
	 	if (masterCaseIdSet.isEmpty()) return;

	 	//Now iterate through all the master cases that need to be updated and set them to 'In Progress'
	 	for (Case masterCase: [SELECT Id, Status From Case WHERE Id IN:masterCaseIdSet])
	 	{
	 		if (masterCase.Status == 'Closed')
	 		{
	 			masterCase.Status = 'In Progress';
	 			masterCaseToUpdate.add(masterCase);
	 		}
	 	}

	 	//Check if any cases need to be updated, if so update them
	 	if (masterCaseToUpdate.size() > 0 )
	 	{
	 		try{
		 		update masterCaseToUpdate;
	 		}catch(DmlException e){
				System.debug('updateClosedMasterCaseToInProgress DmlException Exception');
			}
	 	}
	 }
	 
	
	public static void validateMasterCase(List<Case> cases){
		Map<Id, Case> masterCases = new Map<Id, Case>();
		RecordType rt = SObjectServices.getRecordType(Constants.CASE_REC_TYPE_MASTER, 'Case');
		for(Case c : cases){
			if(c.RecordTypeId == rt.Id && c.Status == 'Closed'){
				masterCases.put(c.Id, c);
			}
		}
		
		for(Case masterCase : [SELECT Id, (SELECT IsClosed FROM Related_Cases__r) FROM Case WHERE Id IN: masterCases.keySet()]){
			Boolean closeMasterCase = true;
			for(Case relatedCase : masterCase.Related_Cases__r){
				if(!relatedCase.IsClosed){
					closeMasterCase = false;
					break;
				}
			}
			if(!closeMasterCase){
				masterCases.get(masterCase.Id).addError('Please close all related cases before you close the master case.');
			}
		}
				 	
	}
	
}