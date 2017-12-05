/*
 * Class        : StandardAllocationService
 * Developer/Org: Munib Ur Rehman
 * Created      : Feb 11, 2015
 * Objective    : This class contains static methods for the Standard Allocation object
*/
public with sharing class StandardAllocationService {
	
	public static void onAfterUpdate(Map<Id, Standard_Allocation__c> oldMap, Map<Id, Standard_Allocation__c> newMap) {
		//functionality should work only on change of either of the 2 fields
		for(Id allocate : newMap.keySet()){
			if(oldMap.get(allocate).Credit__c != newMap.get(allocate).Credit__c || oldMap.get(allocate).Debit__c != newMap.get(allocate).Debit__c
			    // I-263460 - to calculate the balanced falg in case of start date or end date changes as well
			    || oldMap.get(allocate).Start_Date__c != newMap.get(allocate).Start_Date__c || oldMap.get(allocate).End_Date__c != newMap.get(allocate).End_Date__c){
		     checkBalancedAllocations(newMap);
		  	}
		}
    } // END public static onAfterInsert(list<Standard_Allocation__c> saList) 
    
    //
    //method to check balanced GAUs 
    public static void checkBalancedAllocations(Map<Id, Standard_Allocation__c> newMap){
    	 //extracting Ids of GAUs to process
        List<Id> listIds = new List<Id>();
        for (Standard_Allocation__c childObj : newMap.values()) {
    			listIds.add(childObj.GAU__c);
  		}
  		// All IUs are then processed individually to check for the sum of corresponding credit and debit allocations 
  		// I-263460 - Added WHERE Start_Date__c  <= TODAY AND End_Date__c >= TODAY clause in Query
  		List<rC_Giving__GAU__c> GAUList = [SELECT Id, Balanced__c, (SELECT Id, Credit__c, Debit__c FROM Standard_Allocations__r WHERE Start_Date__c  <= TODAY AND End_Date__c >= TODAY) FROM rC_Giving__GAU__c WHERE Id IN :listIds];
  		for (rC_Giving__GAU__c gau : GAUList){
  			List<Standard_Allocation__c> allocations = gau.Standard_Allocations__r;
  			Decimal sumOfCredits = 0;
  			Decimal sumOfDebits = 0;
  			for(Standard_Allocation__c allocation : allocations){
  				if(allocation.Credit__c!=null){
  					sumOfCredits += allocation.Credit__c;
  				}
  				if(allocation.Debit__c!=null){
  					sumOfDebits += allocation.Debit__c;
  				}
  			}
  			if(sumOfCredits == sumOfDebits){
  				gau.Balanced__c = true;
  			} else {
  				gau.Balanced__c = false;
  			}
  		}
  		update GAUList;
    }// End method 
}