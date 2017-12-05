/**
 * @author      Phil Rymek
 * @date     	3/15/2012
 * @description Contains Aside trigger code
 **/
public class AsideTriggerUtil {
    
    /**
     * @description Generates or updates a Aside code file based on the 
     *              create of a code update record.
     * @param       List<Aside_Code_Update__c> codeUpdates - updates to generate 
     *                                                     code files from
     **/
    public static void generateCodeFiles(List<Aside_Code_Update__c> codeUpdates) {
        //get list of classes, trigger, pages, component
        List<String> pages      = new List<String>();
        List<String> classes    = new List<String>();
        List<String> components = new List<String>();
        List<String> triggers   = new List<String>();
        String filename;
        
        for(Aside_Code_Update__c codeUpdate : codeUpdates) {
            filename = codeUpdate.Filename__c.substring(0, codeUpdate.Filename__c.lastIndexOf('.'));
            
            if(codeUpdate.Type__c == AsideUtil.APEX_CLASS) {
                classes.add(filename);
            } else if(codeUpdate.Type__c == AsideUtil.VF_PAGE) {
                pages.add(filename);
            } else if(codeUpdate.Type__c == AsideUtil.VF_COMP) {
                components.add(filename);
            } else if(codeUpdate.Type__c == AsideUtil.APEX_TRIGGER) {
                triggers.add(filename);
            }
        }
        
        //process each list, creating the Aside_Code_File__c
        if(!pages.isEmpty()) {
            AsideUtil.processCodeUpdates(pages, AsideUtil.VF_PAGE);
        }
        
        if(!classes.isEmpty()) {
            AsideUtil.processCodeUpdates(classes, AsideUtil.APEX_CLASS);
        }
        
        if(!components.isEmpty()) {
            AsideUtil.processCodeUpdates(components, AsideUtil.VF_COMP);
        }
        
        if(!triggers.isEmpty()) {
            AsideUtil.processCodeUpdates(triggers, AsideUtil.APEX_TRIGGER);
        }        
    }
}