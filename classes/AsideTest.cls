/**
 * @author      Phil Rymek
 * @date     	6/24/2012
 * @description Tests all of aside's apex code.
 **/
@isTest
private class AsideTest {
    
    /**
     * @description Tests AsideCodeUpdateTrigger and related code
     * @toChange    There should be classes that exist specifically for these tests to
     *              produce a more meaningful test (e.g. verify body is split properly on code file)
     **/
    private static testMethod void testCodeUpdateTrigger() {
        List<ApexClass> classes        = [SELECT Id, Name, NamespacePrefix FROM ApexClass ORDER BY CreatedDate ASC LIMIT 1];
        List<ApexPage> pages           = [SELECT Id, Name, NamespacePrefix FROM ApexPage ORDER BY CreatedDate ASC LIMIT 1];
        List<ApexComponent> components = [SELECT Id, Name, NamespacePrefix FROM ApexComponent ORDER BY CreatedDate ASC LIMIT 1];
        List<ApexTrigger> triggers     = [SELECT Id, Name, NamespacePrefix FROM ApexTrigger ORDER BY CreatedDate ASC LIMIT 1];
         
        List<Aside_Code_Update__c> codeUpdates = new List<Aside_Code_Update__c>();
        String namespace;
        
        if(!classes.isEmpty()) {
            namespace = String.isEmpty(classes.get(0).NamespacePrefix) ? '' : classes.get(0).NamespacePrefix + '.';
            codeUpdates.add(new Aside_Code_Update__c(Filename__c = namespace + classes.get(0).Name + '.Class', Type__c = AsideUtil.APEX_CLASS));
        }
        
        if(!pages.isEmpty()) {
            namespace = String.isEmpty(pages.get(0).NamespacePrefix) ? '' : pages.get(0).NamespacePrefix + '.';
            codeUpdates.add(new Aside_Code_Update__c(Filename__c = namespace + pages.get(0).Name + '.Page', Type__c = AsideUtil.VF_PAGE));
        }
        
        if(!components.isEmpty()) {
            namespace = String.isEmpty(components.get(0).NamespacePrefix) ? '' : components.get(0).NamespacePrefix + '.';
            codeUpdates.add(new Aside_Code_Update__c(Filename__c = namespace + components.get(0).Name + '.Component', Type__c = AsideUtil.VF_COMP));
        }
        
        if(!triggers.isEmpty()) {
            namespace = String.isEmpty(triggers.get(0).NamespacePrefix) ? '' : triggers.get(0).NamespacePrefix + '.';
            codeUpdates.add(new Aside_Code_Update__c(Filename__c = namespace + triggers.get(0).Name + '.Trigger', Type__c = AsideUtil.APEX_TRIGGER));
        }
        
        insert codeUpdates;
        
        List<Aside_Code_File__c> codeFiles = [SELECT Name, Type__c FROM Aside_Code_File__c];
        System.assertEquals(codeUpdates.size(), codeFiles.size());
        for(Aside_Code_File__c codeFile : codeFiles) {
            if(codeFile.Type__c == AsideUtil.APEX_CLASS) {
                namespace = String.isEmpty(classes.get(0).NamespacePrefix) ? '' : classes.get(0).NamespacePrefix + '.';
                System.assertEquals(namespace + classes.get(0).Name, codeFile.Name);
            } else if(codeFile.Type__c == AsideUtil.APEX_TRIGGER) {
                namespace = String.isEmpty(triggers.get(0).NamespacePrefix) ? '' : triggers.get(0).NamespacePrefix + '.';
                System.assertEquals(namespace + triggers.get(0).Name, codeFile.Name);
            } else if(codeFile.Type__c == AsideUtil.VF_PAGE) {
                namespace = String.isEmpty(pages.get(0).NamespacePrefix) ? '' : pages.get(0).NamespacePrefix + '.';
                System.assertEquals(namespace + pages.get(0).Name, codeFile.Name);
            } else if(codeFile.Type__c == AsideUtil.VF_COMP) {
                namespace = String.isEmpty(components.get(0).NamespacePrefix) ? '' : components.get(0).NamespacePrefix + '.';
                System.assertEquals(namespace + components.get(0).Name, codeFile.Name);
            }
        }
    }

    /**
     * @description Tests AsideCodeArchiveBatch for classes
     **/
    private static testMethod void testCodeArchiveBatchForClasses() {
        List<ApexClass> classes = 
            [SELECT Id, Name, NamespacePrefix
               FROM ApexClass
           ORDER BY CreatedDate ASC
              LIMIT 2];
              
        if(!classes.isEmpty()) {
            String apexQuery = 'SELECT Id, Name, Body, NamespacePrefix FROM ApexClass WHERE Id = \'' + classes.get(0).Id + '\'';
            if(classes.size() == 2) {
                apexQuery += ' OR Id = \'' + classes.get(1).Id + '\'';
            }

            Test.startTest();
            Database.executeBatch( new AsideCodeArchiveBatch( apexQuery ), AsideCodeArchiveBatch.BATCH_SIZE );
            Test.stopTest();

            List<Aside_Code_File__c> codeFiles = [SELECT Filename__c, Type__c FROM Aside_Code_File__c WHERE Type__c = :AsideUtil.APEX_CLASS];
            System.assertEquals(classes.size(), codeFiles.size());
            String namespace;
            Integer assertCount;
            for(Aside_Code_File__c codeFile : codeFiles) {
                assertCount = 0;
                for(ApexClass currentClass : classes) {
                    namespace = String.isEmpty(currentClass.NamespacePrefix) ? '' : currentClass.NamespacePrefix + '.';
                    
                    if((namespace + currentClass.Name + '.Class') == codeFile.Filename__c) {
                        assertCount++;
                    }
                }
                
                System.assertEquals(1, assertCount);
            }
        }
    }

    /**
     * @description Tests AsideCodeArchiveBatch for pages
     **/
    private static testMethod void testCodeArchiveBatchForPages() {
        List<ApexPage> pages =
            [SELECT Id, Name, NamespacePrefix
               FROM ApexPage
           ORDER BY CreatedDate ASC
              LIMIT 2];    
              
        if(!pages.isEmpty()) {
            String vfQuery = 'SELECT Id, Name, Markup, NamespacePrefix FROM ApexPage WHERE Id = \'' + pages.get(0).Id + '\'';
            if(pages.size() == 2) {
                vfQuery += ' OR Id = \'' + pages.get(1).Id + '\'';
            }

            Test.startTest();
            Database.executeBatch( new AsideCodeArchiveBatch( vfQuery ), AsideCodeArchiveBatch.BATCH_SIZE );
            Test.stopTest();

            List<Aside_Code_File__c> codeFiles = [SELECT Filename__c, Type__c FROM Aside_Code_File__c WHERE Type__c = :AsideUtil.VF_PAGE];
            System.assertEquals(pages.size(), codeFiles.size());
            Integer assertCount;
            String namespace;
            
            for(Aside_Code_File__c codeFile : codeFiles) {
                assertCount = 0;
                for(ApexPage currentPage : pages) {
                    namespace = String.isEmpty(currentPage.NamespacePrefix) ? '' : currentPage.NamespacePrefix + '.';
                    if((namespace + currentPage.Name + '.Page') == codeFile.Filename__c) {
                        assertCount++;
                    }
                }
                
                System.assertEquals(1, assertCount);
            }
        }      
    }

    /**
     * @description Tests AsideCodeArchiveBatch for triggers
     **/
    private static testMethod void testCodeArchiveBatchForTriggers() {
        List<ApexTrigger> triggers =
            [SELECT Id, Name, NamespacePrefix
               FROM ApexTrigger
           ORDER BY CreatedDate ASC
              LIMIT 2];   
              
        if(!triggers.isEmpty()) {
            String apexQuery = 'SELECT Id, Name, Body, NamespacePrefix FROM ApexTrigger WHERE Id = \'' + triggers.get(0).Id + '\'';
            if(triggers.size() == 2) {
                apexQuery += ' OR Id = \'' + triggers.get(1).Id + '\'';
            }

            Test.startTest();
            Database.executeBatch( new AsideCodeArchiveBatch( apexQuery ), AsideCodeArchiveBatch.BATCH_SIZE );
            Test.stopTest();

            List<Aside_Code_File__c> codeFiles = [SELECT Filename__c, Type__c FROM Aside_Code_File__c WHERE Type__c = :AsideUtil.APEX_TRIGGER];
            System.assertEquals(triggers.size(), codeFiles.size());
            Integer assertCount;
            String namespace;
            for(Aside_Code_File__c codeFile : codeFiles) {
                assertCount = 0;
                for(ApexTrigger currentTrigger : triggers) {
                    namespace = String.isEmpty(currentTrigger.NamespacePrefix) ? '' : currentTrigger.NamespacePrefix + '.';
                    
                    if((namespace + currentTrigger.Name + '.Trigger') == codeFile.Filename__c) {
                        assertCount++;
                    }
                }
                
                System.assertEquals(1, assertCount);
            }
        }        
    }

    /**
     * @description Tests AsideCodeArchiveBatch for components
     **/
    private static testMethod void testCodeArchiveBatchForComponents() {
        List<ApexComponent> components = [SELECT Id, Name, NamespacePrefix FROM ApexComponent ORDER BY CreatedDate ASC LIMIT 2];

        if(!components.isEmpty()) {
            String vfQuery = 'SELECT Id, Name, Markup, NamespacePrefix FROM ApexComponent WHERE Id = \'' + components.get(0).Id + '\'';
            if(components.size() == 2) {
                vfQuery += ' OR Id = \'' + components.get(1).Id + '\'';
            }

            Test.startTest();
            Database.executeBatch( new AsideCodeArchiveBatch( vfQuery ), AsideCodeArchiveBatch.BATCH_SIZE );
            Test.stopTest();

            List<Aside_Code_File__c> codeFiles = [SELECT Filename__c, Type__c FROM Aside_Code_File__c WHERE Type__c = :AsideUtil.VF_COMP];
            System.assertEquals(components.size(), codeFiles.size());
            Integer assertCount;
            String namespace;
            for(Aside_Code_File__c codeFile : codeFiles) {
                assertCount = 0;
                for(ApexComponent currentComponent : components) {
                    namespace = String.isEmpty(currentComponent.NamespacePrefix) ? '' : currentComponent.NamespacePrefix + '.';
                    
                    if((namespace + currentComponent.Name + '.Component') == codeFile.Filename__c) {
                        assertCount++;
                    }
                }
                
                System.assertEquals(1, assertCount);
            }
        }        
    }    
    
    /**
     * @description Tests variations of the filenamesToClause method
     **/
    private static testMethod void testFilenamesToClause() {
       System.assertEquals('', AsideUtil.filenamesToClause(new List<String>()));
       System.assertEquals('(Name = \'a\')', AsideUtil.filenamesToClause(new List<String>{'a'}));
       System.assertEquals('(Name = \'a\') OR (Name = \'c\' AND NamespacePrefix = \'b\')', 
                           AsideUtil.filenamesToClause(new List<String>{'a', 'b.c'}));
    }
}