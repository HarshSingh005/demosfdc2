/**
 * @author      Phil Rymek
 * @date        3/15/2012
 * @description Archives all code of a single type into the Aside_Code_File__c object.
 **/
global without sharing class AsideCodeArchiveBatch implements Database.Batchable<SObject> {
    
    public static final Integer BATCH_SIZE = 20;
    
    private String query;
    private String objectType;
    
    /**
     * @description Initialize batch by telling it what to operate on
     * @param       String soqlQuery - what to operate on
     **/
    global AsideCodeArchiveBatch(String soqlQuery) {
        query = soqlQuery;
        String lcQuery = query.toLowerCase();
        List<String> querySplit = lcQuery.split(' from ');
        String postFrom = querySplit[1];
        objectType = postFrom.contains(' ') ? querySplit[1].split(' ')[0] : postFrom;
	} 

    /**
     * @description Generic batch apex start method
     **/
	global Database.QueryLocator start(Database.BatchableContext bc) {
			return Database.getQueryLocator(query);
	}

    /**
     * @description Archives a single batch of code.
     * @param       Database.BatchableContext bc - contains info about this batch
     * @param       List<SObject> scope - code files to archive
     **/
	global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Aside_Code_File__c> codeFiles = new List<Aside_Code_File__c>();
        
        if(objectType == (AsideUtil.APEX + AsideUtil.APEX_CLASS).toLowerCase()) {
            List<ApexClass> classes = (List<ApexClass>) scope;
            for(ApexClass rec : classes) {
                codeFiles.add(AsideUtil.generateCodeFileFromClass(rec));
            }        
        } else if(objectType == (AsideUtil.APEX + AsideUtil.VF_PAGE).toLowerCase()) {
            List<ApexPage> pages = (List<ApexPage>) scope;
            for(ApexPage rec : pages) {
                codeFiles.add(AsideUtil.generateCodeFileFromPage(rec));
            }            
        } else if(objectType == (AsideUtil.APEX + AsideUtil.VF_COMP).toLowerCase()) {
            List<ApexComponent> components = (List<ApexComponent>) scope;
            for(ApexComponent rec : components) {
                codeFiles.add(AsideUtil.generateCodeFileFromComponent(rec));
            }           
        } else if(objectType == (AsideUtil.APEX + AsideUtil.APEX_TRIGGER).toLowerCase()) {
            List<ApexTrigger> triggers = (List<ApexTrigger>) scope;
            for(ApexTrigger rec : triggers) {
                codeFiles.add(AsideUtil.generateCodeFileFromTrigger(rec));
            }          
        }
        
        upsert codeFiles Filename__c;
	}

    /**
     * @description Generic batch apex finish method
     **/
	global void finish(Database.BatchableContext bc) {
        
	}
	
}