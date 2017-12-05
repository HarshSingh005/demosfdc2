/*
Class : OpportunityRelatedContents 
Description : Shows related Allocations for Opportunity
Developed by : Munib Ur Rehman
Created Date : June 27, 2012
*/

public without sharing class OpportunityRelatedContents {
    public Opportunity opportunity{get;set;}
    public List<GL_Allocation__c> allocationsList{get;set;}
    public String selectedContent{get;set;}
    public Map<Id, String> pendingStatusMap{get;set;}
    public String selectedDFCOverrideStatus{get;set;}
    public String redirectUrl {public get; private set;}
     public String status {get; set;}
     public String setStatus {get; set;}
    public Boolean userHasAccess {get;set;}
    public List<String> statusList{get; set;}
    
    //constructor to initiate the different variables and to prepare allocation List
    // To be done only foir Field Office Sponsor Relations profile
    public OpportunityRelatedContents(ApexPages.StandardController controller){
        userHasAccess = false;
        statusList = new List<String>();
        setStatus = '';
        pendingStatusMap = new Map<Id, String>();
        opportunity = (Opportunity)controller.getRecord();
        System.debug('opportunity==============='+opportunity);
        prepareAllocationsList();
        redirectUrl = controller.view().getUrl();
        if(opportunity==null) {
            opportunity = new Opportunity();
        }
        List<Profile> fieldProfiles = [SELECT Id, Name FROM Profile where Name like 'Field Office Sponsor Relations%'];
        Set<Id> profIdSet = new Set<Id>();
        for(Profile pro: fieldProfiles){
            profIdSet.add(pro.Id);
        }
        Id userProfId = [SELECT Id, Name FROM Profile WHERE Name like 'System Administrator'].get(0).Id;
        profIdSet.add(userProfId);
        userProfId = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() limit 1].get(0).Id;
        if((profIdSet).contains(userProfId)){
            userHasAccess = true;
        }
    }
    
    //preparing custom picklist for DFC Status for the User to override
    public List<SelectOption> getdfcOverRidePicklist(){
        
        List<SelectOption> picklist = new List<SelectOption>();
        picklist.add(new SelectOption('none', '--none--'));
        picklist.add(new SelectOption('Received by Child', 'Received by Child'));
        picklist.add(new SelectOption('Kept by LP/Community', 'Kept by LP/Community'));
        picklist.add(new SelectOption('Undeliverable - Project Closed', 'Undeliverable - Project Closed'));
        picklist.add(new SelectOption('Undeliverable - Over $100', 'Undeliverable - Over $100'));
        return picklist;
    }
    
    // T-545018 MR Enhance: OpportunityRelatedContents vf page. Add a new 'calculated' dfc status.
    //preparing list of related Allocations and custom map to fill out calculated statuses on the basis of different criteria
    public void prepareAllocationsList(){
        allocationsList = new List<GL_Allocation__c>();
        for(GL_Allocation__c gla : [Select c.ID, IsObligation__c, Obligation__c, Obligation__r.Exchange_Rate__c , Received_by_NO_Date__c,
         Local_Currency_Amount__c, Release_Date__c, Name , Transaction__r.DFC_Status__c,Transaction__r.DFC_Release_Month__c,
         Transaction__r.On_Financial_Hold__c From GL_Allocation__c c  where c.Transaction__c = :opportunity.ID AND IsObligation__c = true limit 1])
        {
            if(gla.Obligation__c != null)
            {
	             if(gla.Transaction__r.DFC_Status__c !=null && gla.Transaction__r.DFC_Status__c== 'Pending' && gla.Received_by_NO_Date__c ==null && gla.Release_Date__c==null){
	                pendingStatusMap.put(gla.Id, 'In Process');
	                status = 'In Process';
	            } else if(gla.Transaction__r.DFC_Status__c !=null && gla.Transaction__r.DFC_Status__c== 'Pending' && gla.Received_by_NO_Date__c!=null && gla.Release_Date__c!=null){
	                pendingStatusMap.put(gla.Id, 'Received by NO');
	                status = 'Recieved by NO';
	            } else if(gla.Transaction__r.DFC_Status__c !=null && gla.Transaction__r.DFC_Status__c== 'Pending' && gla.Received_by_NO_Date__c ==null && gla.Release_Date__c!=null){
	                pendingStatusMap.put(gla.Id, 'Sent to NO');
	                status = 'Sent to NO';  
	            } else {
	            		pendingStatusMap.put(gla.Id, gla.Transaction__r.DFC_Status__c);
	            		status = gla.Transaction__r.DFC_Status__c;
	             }
            }
            else {
                pendingStatusMap.put(gla.Id, 'Pending');
                status = 'Pending';
                System.debug('pendingStatusMap.......else');
            }
            System.debug('pendingStatusMap==============='+pendingStatusMap);
            allocationsList.add(gla);
        }
        if(allocationsList.isEmpty()){
        	statusList.add('Pending');
            status = 'Pending';
        }
    }
    
    //method called on saving the contents used to save the dfc status selected by user from picklist. 
    public Pagereference saveContent(){
        setStatus = 'true';
        if(selectedDFCOverrideStatus != 'none'){
            pendingStatusMap.clear();    
        
            for(GL_Allocation__c gla : allocationsList){
                if(gla.Received_by_NO_Date__c!=null && gla.Release_Date__c!=null){
                   pendingStatusMap.put(gla.Id, 'Recieved by NO');
                    status = 'Recieved by NO';        
                }else if(gla.Received_by_NO_Date__c ==null && gla.Release_Date__c!=null){
                    pendingStatusMap.put(gla.Id, 'Sent to NO');
                    status = 'Sent to NO';    
                }else{
                    pendingStatusMap.put(gla.Id, gla.Transaction__r.DFC_Status__c);
                    status = gla.Transaction__r.DFC_Status__c;
                }
                opportunity.DFC_Status__c = selectedDFCOverrideStatus;    
                
            }
            try{
                update  this.opportunity;
                update allocationsList;   
                 
            }catch(Exception e){
                
            }
            
        }
        return null;
        
        
    }
    public Pagereference deleteContent(){
        delete new GL_Allocation__c(id = selectedContent);
        return null;
    }
    public void renderVF(){
    	
    }
    
}