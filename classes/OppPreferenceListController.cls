/***********************************************************************************************************
 * Appirio, Inc
 * Name         : OppPreferenceListController
 * Created By   : Vaibhav Goel (Appirio)
 * Purpose      : Extension class for page "OppPreferenceList"
 * Created Date : 22/Dec/2015
 * Task Number   : T-460209
 * 
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]						[Person Name]			[Short Description]
 **********************************************************************************************************/
public with sharing class OppPreferenceListController {

	public List<OppPreferenceWrapper> oppPrefList{get;set;}
	public list<rC_Bios__Preference__c> prefList;
	public String opptyId;
	public List<SelectOption> prefCodePicklist;
	public String prefSponsorshipRecTypeId;
	public static String errorMsg {get; set;}
	
	public OppPreferenceListController(ApexPages.StandardController stdCon) {
		opptyId = stdCon.getId();
		system.debug('---opptyId---' + opptyId);
		prefSponsorshipRecTypeId = Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName().get('Sponsorship').getRecordTypeId();
		
		prefList = new List<rC_Bios__Preference__c>();
		prefList.clear();
	    prefList = [Select Id, rC_Sponsorship__Opportunity__c, RecordType.Name, rC_Bios__Category__c, rC_Bios__Subcategory__c, 
	    			rC_Bios__Type__c, rC_Bios__Subtype__c, rC_Bios__Start_Date__c, rC_Bios__End_Date__c, rC_Bios__Active__c, 
	    			Legacy_Created_Date__c, rC_Bios__Account__c, National_Office__c, National_Office__r.Name, Local_Partner__c, Local_Partner__r.Name, 
	    			Community__c, Community__r.Name FROM rC_Bios__Preference__c WHERE rC_Sponsorship__Opportunity__c = :opptyId order by createdDate ASC];
		system.debug('---prefList---' + prefList.size());
		prefCodePicklist = getSelCodeValues();
		prepareWrapperList();
	}
	
	/**
 	* Name : 		getSelCodeValues()
 	* Type : 		List<SelectOption>
 	* Parameters : 	None
	* Description : method to create the picklist of Prefernce code record valaues as picklist
	**/	
	public List<SelectOption> getSelCodeValues() {
        List<SelectOption> options = new List<SelectOption>();
        Set<String> setOptions = new Set<String>();
        for(rC_Bios__Preference_Code__c pc : [SELECT rC_Bios__Category__c, rC_Bios__Subcategory__c, 
        										rC_Bios__Type__c, rC_Bios__Subtype__c FROM rC_Bios__Preference_Code__c]) {
        	setOptions.add(pc.rC_Bios__Category__c + '-' + pc.rC_Bios__Subcategory__c + '-' + 
        					pc.rC_Bios__Type__c + '-' + pc.rC_Bios__Subtype__c);
        }

        options.add(new SelectOption('--None--','--None--'));
        for(String strVal : setOptions) {
        	options.add(new SelectOption(strVal, strVal));
        }
        return options;
	} // END public List<SelectOption> getSelCodeValues() {
    
    
    /**
 	* Name : 		OppPreferenceWrapper
 	* Type : 		Class
 	* Parameters : 	N/A
	* Description : wrapper class to show on VF as table
	**/	
	public class OppPreferenceWrapper{
		public rC_Bios__Preference__c prefObj{get; set;}
		public List<SelectOption> prefCodeWrapperPicklist{get;set;}
		public String selectedPrefCode{get;set;}
		public String needsToBeDeleted{get;set;}
		
		public OppPreferenceWrapper(){
			needsToBeDeleted = 'false';
			//this.prefCodeWrapperPicklist = prefCodePicklist;
		}
		
	}
	
	/**
 	* Name : 		prepareWrapperList
 	* Type : 		None
 	* Parameters : 	None
	* Description : method to prepare the list of wrapper class elements 
	**/	
	public void prepareWrapperList(){
		system.debug('---prefList---' + prefList.size());
		oppPrefList = new List<OppPreferenceWrapper>();
		system.debug('---oppPrefList---' + oppPrefList.size());
		for(rC_Bios__Preference__c prefObj : prefList){
			OppPreferenceWrapper wrapObj = new OppPreferenceWrapper();
			wrapObj.prefObj = prefObj;
			wrapObj.prefCodeWrapperPicklist = prefCodePicklist;
			oppPrefList.add(wrapObj);
		}
	}
	
	/**
 	* Name : 		saveRecords
 	* Type : 		PageReference
 	* Parameters : 	None
	* Description : method to iterate through the list of wrapper class elements and 
	*				upert(add + update) rC_Bios__Preference__c records in database.
	**/	
	public PageReference saveRecords() {
		if(performValidation() == false){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMsg));
			return null;
		}
		List<rC_Bios__Preference__c> prefListToUpdate = new List<rC_Bios__Preference__c>();
		for(OppPreferenceWrapper wrapObj : oppPrefList){
			system.debug('---wrapObj.prefObj---'  + wrapObj.prefObj);
			if(wrapObj.prefObj.National_Office__c != null){
				system.debug('---natId---'  + wrapObj.prefObj.National_Office__c);
				wrapObj.prefObj.rC_Bios__Subtype__c = wrapObj.prefObj.National_Office__c;
			}
			if(wrapObj.prefObj.Local_Partner__c != null){
				system.debug('---lpId---'  + wrapObj.prefObj.Local_Partner__c);
				wrapObj.prefObj.rC_Bios__Subtype__c = wrapObj.prefObj.Local_Partner__c;
			}
			if(wrapObj.prefObj.Community__c != null){
				system.debug('---comId---'  + wrapObj.prefObj.Community__c);
				wrapObj.prefObj.rC_Bios__Subtype__c = wrapObj.prefObj.Community__c;
			}
			if(wrapObj.prefObj.Legacy_Created_Date__c != null){
	    		wrapObj.prefObj.rC_Bios__Subtype__c = String.valueOf(wrapObj.prefObj.Legacy_Created_Date__c);
			}
			prefListToUpdate.add(wrapObj.prefObj);
			
		}
		try{
			upsert prefListToUpdate;	
		}
		catch(Exception e) {
			System.debug('[RB] - PreferencesController.saveRecord :: Error(Save) = ' + e.getMessage() + '; Line No = ' + e.getLineNumber());
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
		} // END catch(Exception e) {
		PageReference pRef = Page.OppPreferenceList;
		pRef.setRedirect(true);
		pRef.getParameters().put('Id',opptyId);
		return pRef;
	}
	
	/**
 	* Name : 		performValidation
 	* Type : 		Boolean
 	* Parameters : 	None
	* Description : method to Check and perform validations before saving/updating records to database 
	**/	
	private Boolean performValidation() {
		//System.debug('[RB] - PreferencesController.performValidation :: Start..');
		Boolean flag = true;
		errorMsg = '';
		for(OppPreferenceWrapper wrapObj : oppPrefList){
			if(wrapObj.prefObj.rC_Bios__Type__c == Null) {
				errorMsg = 'Please select Type.';
				flag = false;
				break;
			}
			if( (wrapObj.prefObj.rC_Bios__Type__c == 'National Office'  && wrapObj.prefObj.National_Office__c == null) ||
				(wrapObj.prefObj.rC_Bios__Type__c == 'Local Partner'  && wrapObj.prefObj.Local_Partner__c == null) ||
				(wrapObj.prefObj.rC_Bios__Type__c == 'Community'  && wrapObj.prefObj.Community__c == null) ) {
				errorMsg += 'Please choose Account of ' + wrapObj.prefObj.rC_Bios__Type__c + ' record type.';
				flag = false;
				break;
			}
			if(wrapObj.prefObj.rC_Bios__Type__c == 'Birthdate' && wrapObj.prefObj.Legacy_Created_Date__c == Null) {
				errorMsg += 'Please Enter Birth Date.';
				flag = false;
				break;
			}
		}
		return flag;		
		
	} // END Boolean performValidation() {
	
	
	/**
 	* Name : 		deletePreference
 	* Type : 		PageReference
 	* Parameters : 	None
	* Description : method to iterate through the list of wrapper class elements and 
	*				check for which row to delete from the table shown in VF. 
	**/	
	public PageReference deletePreference() {
		string myParam = apexpages.currentpage().getparameters().get('myParam');
		system.debug('---myParam---' + myParam);
		system.debug('---oppPrefList---' + oppPrefList.size());
		List<OppPreferenceWrapper> tempListWrapper = new List<OppPreferenceWrapper>();
		rC_Bios__Preference__c prefToBeDeleted = new rC_Bios__Preference__c();
		
		for(OppPreferenceWrapper wrapObj : oppPrefList){
			system.debug('---wrapObj.needsToBeDeleted---' + wrapObj.needsToBeDeleted);
			if(wrapObj.needsToBeDeleted == 'false'){
				tempListWrapper.add(wrapObj);
			}
			if(wrapObj.prefObj.Id != null && wrapObj.needsToBeDeleted == 'true'){
				prefToBeDeleted = wrapObj.prefObj;
			}
		}
		system.debug('---tempListWrapper---' + tempListWrapper.size());
		oppPrefList.clear();
		oppPrefList.addAll(tempListWrapper);
		if(prefToBeDeleted != null && prefToBeDeleted.Id != null) {
			delete prefToBeDeleted;
		}
		return null;
	}
	
	/**
 	* Name : 		editPreference
 	* Type : 		PageReference
 	* Parameters : 	None
	* Description : method to iterate through the list of wrapper class elements and 
	*				check for which row Edit link is clicked and redirect the user to the detailed VF : Preferences
	*					for that  rC_Bios__Preference__c record.
	**/
	public PageReference editPreference() {
		string myParam = apexpages.currentpage().getparameters().get('myEditParam');
		system.debug('---myParam--' + myParam);
		PageReference pRef = new PageReference('/apex/Preferences?Id='+myParam);
		pRef.setRedirect(true);
		return pRef;
	}
	
	/*
	public PageReference addRow() {
		rC_Bios__Preference__c prefObj = new rC_Bios__Preference__c();
		prefObj.recordTypeId = prefSponsorshipRecTypeId;
		prefObj.rC_Bios__Category__c = 'Sponsorship';
		prefObj.rC_Sponsorship__Opportunity__c = opptyId;
		insert prefObj;
		rC_Bios__Preference__c tempPrefObj = [Select Id, rC_Sponsorship__Opportunity__c, RecordType.Name, rC_Bios__Category__c, rC_Bios__Subcategory__c, 
	    										rC_Bios__Type__c, rC_Bios__Subtype__c, rC_Bios__Start_Date__c, rC_Bios__End_Date__c, 
	    										rC_Bios__Active__c, rC_Bios__Account__c, National_Office__r.Name, Local_Partner__c, Local_Partner__r.Name, 
	    			 							Community__c, Community__r.Name FROM rC_Bios__Preference__c 
	    										WHERE Id = :prefObj.id];
		system.debug('---prefObj.recordType.Name---' + prefObj.recordType.Name);
		system.debug('---prefObj.recordTypeId---' + prefObj.recordTypeId);
		OppPreferenceWrapper wrapObj = new OppPreferenceWrapper();
		wrapObj.prefObj = tempPrefObj;
		wrapObj.prefCodeWrapperPicklist = prefCodePicklist;
		
		oppPrefList.add(wrapObj);
		return null;
	} */
	
	/**
 	* Name : 		addRow()
 	* Type : 		PageReference
 	* Parameters : 	None
	* Description : method to add new element in the wrapper list and show it to the user on VF.
	*				The record is only added at VF level ( not at database level)
	**/
	public PageReference addRow() {
		rC_Bios__Preference__c prefObj = new rC_Bios__Preference__c();
		prefObj.recordTypeId = prefSponsorshipRecTypeId;
		prefObj.rC_Bios__Category__c = 'Sponsorship';
		prefObj.rC_Sponsorship__Opportunity__c = opptyId;
		system.debug('---prefObj.recordType.Name---' + prefObj.recordType.Name);
		system.debug('---prefObj.recordTypeId---' + prefObj.recordTypeId);
		OppPreferenceWrapper wrapObj = new OppPreferenceWrapper();
		wrapObj.prefObj = prefObj;
		wrapObj.prefCodeWrapperPicklist = prefCodePicklist;
		oppPrefList.add(wrapObj);
		return null;
	}
}