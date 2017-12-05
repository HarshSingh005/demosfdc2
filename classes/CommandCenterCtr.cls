/**
 * Controller for CommandCenter VF component
 *
 * Ver No.     Developer/Org                 Date         Changes
 * -----------------------------------------------------------------------------
 *   1.0       Charlie Xie/Bluewolf        	02/03/2014    Created
 */ 
global with sharing class CommandCenterCtr {
    // Appirio Inc. Ravi Chauhan Aug 10,2016 | Added this variable to be visible in Test class to cover exception scenario
    @testVisible
    private static boolean shouldThrowException = false;
    
	@RemoteAction 
	global static AcceptNextCaseResult acceptNextCase(){
		Id currentUserId = UserInfo.getUserId();
		AcceptNextCaseResult ancResult = new AcceptNextCaseResult();
		//Get the public groups that the agent is a member of. Public Group has lookup relationship with group with type of 'Queue'
		Set<Id> publicGroupIdSet = SObjectServices.getGroupsForUser('Regular',currentUserId);
		Set<Id> queueIdSet = new Set<Id>();
		for(GroupMember gm:[SELECT Id, groupId FROM GroupMember WHERE userorgroupId IN:publicGroupIdSet AND Group.Type='Queue']){
			queueIdSet.add(gm.groupId);
		}

		if(queueIdSet.size()>0){
			try{
				//Get the skill set of the Agent
				User currentUser = [SELECT Id, Sponsor_Care_Skill_Set__c FROM User WHERE id = :currentUserId];
			    Set<String> agentSkillSet = new Set<String>();
			    //convert the multi-select picklist Sponsor_Care_Skill_Set__c to a set of strings.
			    if(!String.isBlank(currentUser.Sponsor_Care_Skill_Set__c)){
					agentSkillSet.addAll(currentUser.Sponsor_Care_Skill_Set__c.split(';'));
				}
				Case resultCase = CaseService.dequeueCase(queueIdSet, agentSkillSet);
				if(resultCase!=null){
				 	ancResult.isSuccess = true;
				 	ancResult.caseId = resultCase.Id;	
				 	ancResult.caseNum = resultCase.CaseNumber;		
					resultCase.ownerId = currentUserId;
					update resultCase;
				}else{
					ancResult.isSuccess = false;
					ancResult.errorMsg = 'There are no available cases to accept at this time.';
				}
				
				//Appirio Inc. Ravi Chauhan Aug 10,2016 Adding code to throw excpetion when test is running to cover up test-coverage for exception block
				if(Test.isRunningTest() && shouldThrowException){
				    Integer i = 1/0; //Assigning the non-integer value to variable to throw exception.
				}
			}catch(Exception e){ 
				ancResult.isSuccess = false;
				ancResult.errorMsg = 'The following exception has occurred: ' + e.getMessage();
				return ancResult;
			}
		}else{
			ancResult.isSuccess = false;
			ancResult.errorMsg = 'You are not in any queue to accept case.';
		}
		return ancResult;
	}
	//Inner Wrapper Class: Wrapping up result to deliver to VF page.
	global class AcceptNextCaseResult{
		public Boolean isSuccess {public get;private set;}
		public String caseId {public get;private set;}
		public String caseNum {public get;private set;}
		public String errorMsg {public get;private set;}
	}
}