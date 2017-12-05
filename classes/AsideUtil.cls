/**
 * @author      Phil Rymek
 * @date 		2/19/2012
 * @description Aside util class.
 **/
public without sharing class AsideUtil {
	
    private static final Integer SPLIT_SIZE  = 30000;
    private static final String OR_OP        = ' OR ';
    public  static final String APEX_CLASS   = 'Class';
    public  static final String APEX_TRIGGER = 'Trigger';
    public  static final String VF_PAGE      = 'Page';
    public  static final String VF_COMP      = 'Component';
    public  static final String APEX         = 'Apex';
    
    /**
	 * @description Turns a list of filenames into a where clause
	 * @param		List<string> filenames - filenames to turn into a string
	 * @return		String - the where clause
	 **/
	public static String filenamesToClause(List<String> filenames) {
	    if(filenames.isEmpty()) {
	        return '';
	    }
	    
        List<String> fnSplit;
        String clause = '';
        String orOperator = ' OR ';
        
        for(String fn : filenames) {
            fnSplit = fn.split('\\.');
            
            if(fnSplit.size() == 1) {
                clause += '(Name = \'' + fnSplit.get(0) + '\')' + OR_OP;
            } else if(fnSplit.size() == 2) {
                clause += '(Name = \'' + fnSplit.get(1) + '\' AND NamespacePrefix = \'' + fnSplit.get(0) + '\')' + OR_OP;
            }
        }
        
        Integer clauseLength = clause.length();
        if(clauseLength > OR_OP.length()) {
            clause = clause.substring(0, clauseLength - OR_OP.length());
        }

	    return clause;
	}

    /**
     * @description Handles a code update, writing a copy of the code to Aside_Code_File__c
     * @param       List<String> filenames - files to save a copy of
     * @param       String type            - Class|Page|Trigger|Component
     **/
    public static void processCodeUpdates(List<String> filenames, String type) {
        if(filenames.isEmpty()) {
            return;
        }
        
        String fieldType = (type == APEX_CLASS || type == APEX_TRIGGER) ? 'Body' : 'Markup';
        String query     = 'SELECT Id, Name, NamespacePrefix, ' + fieldType +  ' FROM ' + APEX + type + 
                           ' WHERE ' + filenamesToClause(filenames);
                           
        upsert generateCodeUpdateList(query, type) Filename__c;
    }
    
    /**
     * @description Generates a Aside_Code_File__c for a given ApexClass
     * @param       ApexClass rec    - class to generate code file from
     * @return      Aside_Code_File__c - the generated code file
     **/
    public static Aside_Code_File__c generateCodeFileFromClass(ApexClass rec) {
        String filename = String.isEmpty(rec.NamespacePrefix) ? rec.Name : rec.NamespacePrefix + '.' + rec.Name;
        Aside_Code_File__c codeFile = new Aside_Code_File__c(
            Name = filename, Type__c = APEX_CLASS, Filename__c = filename + '.' + APEX_CLASS);
        splitUpCode(rec.Body, codeFile);
        return codeFile;
    }

    /**
     * @description Generates a Aside_Code_File__c for a given ApexPage
     * @param       ApexPage rec     - page to generate code file from
     * @return      Aside_Code_File__c - the generated code file
     **/
    public static Aside_Code_File__c generateCodeFileFromPage(ApexPage rec) {
        String filename = String.isEmpty(rec.NamespacePrefix) ? rec.Name : rec.NamespacePrefix + '.' + rec.Name;
        Aside_Code_File__c codeFile = new Aside_Code_File__c(
            Name = filename, Type__c = VF_PAGE, Filename__c = filename + '.' + VF_PAGE);
        splitUpCode(rec.Markup, codeFile);
        return codeFile;
    }

    /**
     * @description Generates a Aside_Code_File__c for a given ApexTrigger
     * @param       ApexTrigger rec  - trigger to generate code file from
     * @return      Aside_Code_File__c - the generated code file
     **/
    public static Aside_Code_File__c generateCodeFileFromTrigger(ApexTrigger rec) {
        String filename = String.isEmpty(rec.NamespacePrefix) ? rec.Name : rec.NamespacePrefix + '.' + rec.Name;
        Aside_Code_File__c codeFile = new Aside_Code_File__c(
            Name = filename, Type__c = APEX_TRIGGER, Filename__c = filename + '.' + APEX_TRIGGER);
        splitUpCode(rec.Body, codeFile);
        return codeFile;
    }

    /**
     * @description Generates a Aside_Code_File__c for a given ApexComponent
     * @param       ApexComponent rec - component to generate code file from
     * @return      Aside_Code_File__c  - the generated code file
     **/
    public static Aside_Code_File__c generateCodeFileFromComponent(ApexComponent rec) {
        String filename = String.isEmpty(rec.NamespacePrefix) ? rec.Name : rec.NamespacePrefix + '.' + rec.Name;
        Aside_Code_File__c codeFile = new Aside_Code_File__c(
            Name = filename, Type__c = VF_COMP, Filename__c = filename + '.' + VF_COMP);
        splitUpCode(rec.Markup, codeFile);
        return codeFile;
    }
    
    /**
     * @description Splits up a block of code so it can fit into long text areas.
     * @param       String body - code to split up
     * @param       Aside_Code_File__c codeFile - record to update with split up cde
     **/
    private static void splitUpCode(String body, Aside_Code_File__c codeFile) {
        Integer fileLength = body.length();
        codeFile.Code_1__c = '';
        codeFile.Code_2__c = '';
        codeFile.Code_3__c = '';
        codeFile.Code_4__c = '';
        
        Integer splitMax  = 4;
        Integer actualMax = Integer.valueOf(Math.ceil(Decimal.valueOf(fileLength) / SPLIT_SIZE));
        actualMax         = actualMax > splitMax ? splitMax : actualMax;
        Integer currentMin;
        Integer currentMax;
        
        for(Integer i = 1; i <= actualMax; i++) {
            currentMin = (i-1) * SPLIT_SIZE;
            currentMax = i * SPLIT_SIZE;
            currentMax = currentMax > fileLength ? fileLength : currentMax;
            
            codeFile.put('Code_' + i + '__c', body.substring(currentMin, currentMax));
        }
    }
    
    /**
     * @description Generates the list of updates to Aside Code Files.
     * @param       String query - query to generate code files based off of
     * @param       String type  - Class|Page|Component|Trigger
     **/
    private static List<Aside_Code_File__c> generateCodeUpdateList(String query, String type) {
        List<Aside_Code_File__c> codeFiles = new List<Aside_Code_File__c>();
        
        if(type == APEX_CLASS) {
            for(ApexClass rec : Database.query(query)) {
                codeFiles.add(generateCodeFileFromClass(rec));
            }
        } else if(type == VF_PAGE) {
            for(ApexPage rec : Database.query(query)) {
                codeFiles.add(generateCodeFileFromPage(rec));
            }
        } else if(type == VF_COMP) {
            for(ApexComponent rec : Database.query(query)) {
                codeFiles.add(generateCodeFileFromComponent(rec));
            }
        } else if(type == APEX_TRIGGER) {
            for(ApexTrigger rec : Database.query(query)) {
                codeFiles.add(generateCodeFileFromTrigger(rec));
            }
        }    
        
        return codeFiles;
    }
}