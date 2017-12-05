/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MergeRecordsControllerTest.cls
 * Created By   : Basant Kumar Verma (Appirio JDC)
 * Purpose      : Provide test covergae for MergeRecordsController [S-213685/T-277614]
 * Created Date : 21st May, 2014
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 06/27/2016                   Ashu Gupta              Increased code coverage and impemented coding standards
 * 22/07/2016                   Vaibhav Goel            Increased code coverage and impemented coding standards 

 **********************************************************************************************************/

@isTest
private class MergeRecordsControllerTest {
    static list<account> accountlist,listOfAccount;
    static Account acc1,acc2,acc3,acc4,acc5,acc6,acc12,accA1,accA2,accA3;
    static  List<SObject> merginObjects;



   static testMethod  void testUtils() { 
        
        createTestData();
        Map<String, MergeRecordsUtil.InputHiddenValue> flist =  null;
        Map<ID,Map<String,MergeRecordsUtil.InputHiddenValue>> selectedObjFields = new Map<ID,Map<String,MergeRecordsUtil.InputHiddenValue>>();
        
        Test.startTest();
        
        MergeRecordsUtil.InputHiddenValue ihv = new MergeRecordsUtil.InputHiddenValue(null,false,false);
        MergeRecordsUtil.SelectMasterResult smr = new MergeRecordsUtil.SelectMasterResult();
        MergeRecordsUtil.Field tmoF = new MergeRecordsUtil.Field(null,null,false);
        MergeRecordsUtil.DescribeResult describe = new MergeRecordsUtil.DescribeResult();
        
        describe = MergeRecordsUtil.initDescribes('Account');
        System.assert(describe.allFieldsKeySet.size()>0,'All fields set is null');
        System.assert(describe.uniqueFieldsKeySet!=null,'unique fields set is null');
        
        smr = MergeRecordsUtil.mergeRecords(merginObjects,accA1.Id);
        
        //"select" the fields 
        flist =  new Map<String,MergeRecordsUtil.InputHiddenValue>();
        selectedObjFields.put(accA2.Id, flist);
        for( MergeRecordsUtil.Field f : describe.allFields.values()) flist.put(f.name,new MergeRecordsUtil.InputHiddenValue(f.name,true,f.isWritable));
        flist =  new Map<String,MergeRecordsUtil.InputHiddenValue>();
        selectedObjFields.put(accA1.Id, flist);
        for( MergeRecordsUtil.Field f : describe.allFields.values()) flist.put(f.name,new MergeRecordsUtil.InputHiddenValue(f.name,false,f.isWritable));
        flist =  new Map<String,MergeRecordsUtil.InputHiddenValue>();
        selectedObjFields.put(accA3.Id, flist);
        for( MergeRecordsUtil.Field f : describe.allFields.values()) flist.put(f.name,new MergeRecordsUtil.InputHiddenValue(f.name,false,f.isWritable));
        
        //MergeRecordsUtil.copyDataIntoMasterRecord(smr, selectedObjFields,'Account');
        
        
        
        Test.stopTest();
    }
    
     static testMethod void testController() {
        
        createTestData();
        Test.startTest();
        Id [] fixedSearchResults= new Id[1];
        Account acc = [select Id from Account where name like '%TEST12%' limit 1];
       fixedSearchResults[0] = acc.Id;
       Test.setFixedSearchResults(fixedSearchResults);
        List<List<sObject>> listAcc = [FIND 'TEST12' IN ALL FIELDS RETURNING Account(id, name WHERE name = 'TEST12' LIMIT 1)];
        System.debug('nnnnnnnnnnnnnn'+listAcc);
        Account[] searchAccounts = (Account[])listAcc[0];
        System.debug('Found the following accounts.');
		for (Account a : searchAccounts) {
		    System.debug('nnnnnnnnnnnnnn'+a.Name);
		}
        
        List<List<sObject>> listAcc1 = [FIND 'Apple' IN ALL FIELDS RETURNING Account (Id, Name WHERE Name = 'TEST12')];
        Account[] searchAccounts1 = (Account[])listAcc1[0];


        MergeRecordsController con = new MergeRecordsController();
        con.sObjectType = 'Account';
        system.debug('sObjectType>>> '+con.sObjectType);
        system.debug('sobjectsSlctOpt>>> '+con.sobjectsSlctOpt);
        //con.searchRecords();
        con.searchText = 'TEST';
       // con.searchRecords();
        con.foundRecordList = new List<SObject>();

         con.masterObjectId = accountlist[0].id;
         for(integer i=0;i<3;i++){
            con.selectMergetObjectPosition = i;
            con.selectMergetObjectId = accountlist[i].id;
            con.selectMergetObject();
        }
        con.searchRecords();
        
        System.assertEquals(listAcc.size(),1);
        //con.getMyCommandButtons();
         con.mergeRecords();
         con.masterObjectId = accountlist[0].id;
         con.mergeRecords();
         //con.getFieldRendering();
         //con.getFieldOptions();
         
          con.fieldSelected = 'National_Office_ID__c';
          Boolean hasNExt = false;
          try{
          if(con.hasNext!=null){
          	hasNExt = con.hasNext;
          }
          }catch(Exception e){
          	
          }
           try{
           Boolean hasPrev = false;
          if(con.hasPrevious!=null){
          	hasPrev = con.hasPrevious;
          }
          }catch(Exception e){
          	
          }
         Integer pageNum = 1;
          try{
         if(con.pageNumber!=null){
         	pageNum = con.pageNumber;
         }
         }catch(Exception e){
          	
          }
           try{
          con.last();
          }catch(Exception e){
          	
          }
          try{
          con.first();

          }catch(Exception e){
          	
          }

          try{
          con.previous();
          }catch(Exception e){
            
          }
          try{
          con.next();
          }catch(Exception e){
            
          }
          

		Test.stopTest();
          //con.find();

    }
    
    
    public static testMethod void unitTest1 () {
    
        createTestData();
        MergeRecordsController con = new MergeRecordsController();
        con.sObjectType = 'Account';
        con.searchText ='tPrak';
        con.searchRecords();
        
        
        //con.searchRecords();
        
        con.objList = new List<SObject>();
        con.objList.add(acc1);
        con.objList.add(acc2);
        con.objList.add(acc3);
      //  con.objList.add(acc4);
      //  con.objList.add(acc5);
        
        //con.setTableList(0);
        
        con.selectMergetObjectPosition =0;
        con.selectMergetObjectId = acc1.Id;
        con.selectMergetObject();
        
        con.selectMergetObjectPosition =1;
        con.selectMergetObjectId = acc2.Id;
        con.selectMergetObject();
        
        con.selectMergetObjectPosition =2;
        con.selectMergetObjectId = acc3.Id;
        con.selectMergetObject();
        
        con.objList.add(acc1);
        con.objList.add(acc2);
        con.objList.add(acc3);
        Map<String, MergeRecordsUtil.InputHiddenValue> flist =  new Map<String,MergeRecordsUtil.InputHiddenValue>();
       
       con.selectedObjFields.put(acc1.id,flist);
       con.selectedObjFields.put(acc2.id,flist);
       con.selectedObjFields.put(acc3.id,flist);
       
        con.merginObjects.add(acc1);
        con.merginObjects.add(acc2);
        con.merginObjects.add(acc3);
        
        con.masterObjectId = acc1.Id;
        con.selectMergetObject();
        con.mergeRecords();
        //Account Records Are Merged So loserObjs Were Deleted.
        system.assertEquals(0, [select count() from account where id=:acc2.id or id=:acc2.id]);
        //con.getMyCommandButtons();
        //con.Previous();
        //con.Next();
        con.fieldSelected = 'AccountNumber';
    }
    
    // START : Changed for S-213685/T-277614 - By Basant Verma (Appirio JDC) - 21st May, 2014
    public static testMethod void testForSingleObject () {
    
        createTestData();
        Test.startTest();
        Id [] fixedSearchResults= new Id[1];
        Account acc = [select Id from Account where name like '%tprak1%' limit 1];
        fixedSearchResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        List<List<sObject>> listAcc = [FIND 'tprak1' IN ALL FIELDS RETURNING Account(id, name WHERE name = 'tprak1' LIMIT 1)];
        System.debug('nnnnnnnnnnnnnn'+listAcc);
        
        String url = '/apex/MergeRecords?sObject=Account&sObjectId='+acc1.id+'&sObjectField=Name';
        Pagereference pg = new Pagereference(url);
        Test.setCurrentPageReference(pg);
        MergeRecordsController con = new MergeRecordsController();
        //con.foundRecordList = []
        System.assertEquals(con.sObjectType,'Account');
        System.assertEquals(con.ObjId,acc1.Id);
        System.assert(con.isForSingleObject);
        
    }
    
    static testMethod void searchTextEmptyTest() {
        createTestData();
        
        
        MergeRecordsController con = new MergeRecordsController();
        con.sObjectType = 'Account';
        system.debug('sObjectType>>> '+con.sObjectType);
        system.debug('sobjectsSlctOpt>>> '+con.sobjectsSlctOpt);
        //con.searchRecords();
        con.searchText = '';
         con.masterObjectId = accountlist[0].id;
         List<Id> accListIds = new List<Id>();
         for(integer i=0;i<3;i++){
            con.selectMergetObjectPosition = i;
            con.selectMergetObjectId = accountlist[i].id;
            accListIds.add(accountlist[i].id);
            con.selectMergetObject();
        }
        con.searchRecords();
        con.mergeRecords();
        con.masterObjectId = accountlist[0].id;
        con.mergeRecords();
        List<Account> accList1 = [select Id from Account where Id in :accListIds];
        System.assert(accList1.size()==3);
        con.fieldSelected = 'Alt_Geo__c';
    }
    
    // END : Changed for S-213685/T-277614 - By Basant Verma (Appirio JDC) - 21st May, 2014
    static testMethod void testNegetiveScenarios(){
        
        createTestData();
        
        MergeRecordsController con = new MergeRecordsController();
        con.sObjectType = 'Account';
        con.searchText = '';
        con.selectMergetObjectPosition = null;
        con.selectMergetObject();
        con.mergeRecords();
        System.assertEquals(false, con.isForSingleObject);
        con.foundRecordList = accountlist;
        //con.searchRecords();
        con.selectMergetObject();        
        
    }
    
    static void createTestData(){
        accountlist = new list<account>();
        for(integer i=0;i<20;i++){
            Account accT1 = new Account();
            accT1.Name = 'TESTACCOUNT'+i;
            accT1.Phone = '12345';
            accT1.Website = 'http://cloudspokes.com';
            accountlist.add(accT1);
        }
        
        insert accountlist;

        listOfAccount = new List<Account>(); 
        acc1 = testUtils.createAccount('tprak1',false);
        acc1.Phone = '12345';
        acc1.Website = 'http://cloudspokes.com';
        listOfAccount.add(acc1);
        
        acc2 = testUtils.createAccount('tPrak2',false);
        acc2.Phone = '000000';
        acc2.Website = 'http://www.cloudspokes.com';
        listOfAccount.add(acc2);
        
        acc3 = testUtils.createAccount('tprak3',false);
        acc3.Phone = '11111';
        acc3.Website = 'https://cloudspokes.com';
        //acc3.Corrected_Country__c = 'test';
        listOfAccount.add(acc3);
        
        acc4 = testUtils.createAccount('tPrak4',false);
        acc4.Phone = '11111';
        acc4.Website = 'https://cloudspokes.com';
      
        listOfAccount.add(acc4);
        
        acc5 = testUtils.createAccount('tPrak4',false);
        acc5.Phone = '11111';
        acc5.Website = 'https://cloudspokes.com';
       
        listOfAccount.add(acc5);
        
        acc6 = testUtils.createAccount('tPrak6',false);
        acc6.Phone = '11111';
        acc6.Website = 'https://cloudspokes.com';
       
        listOfAccount.add(acc6);
        
        insert listOfAccount;

        acc12 = testUtils.createAccount('TEST12',false);
        acc12.Phone = '12345';
        acc12.Website = 'http://cloudspokes.com';
        accountlist.add(acc12);
        
        insert acc12;
        
        Account acc13 = testUtils.createAccount('tprak1',false);
        acc13.Phone = '12325';
        acc13.Website = 'http://cloudspoks.com';
        insert acc13;
        system.debug('---acc13--' + acc13);
        
        system.debug('---acc13--' + [Select recordtype.name from Account where id = :acc13.Id]);
        
        merginObjects = new List<SObject>();
        accA1 = testUtils.createAccount('test1',false);
        accA1.Phone = '12345';
        accA1.Website = 'http://cloudspokes.com';
        merginObjects.add(accA1);
        
        accA2 = testUtils.createAccount('test2',false);
        accA2.Phone = '000000';
        accA2.Website = 'http://www.cloudspokes.com';
        merginObjects.add(accA2);
        
        accA3 = testUtils.createAccount('test3',false);
        accA3.Phone = '11111';
        accA3.Website = 'https://cloudspokes.com';
        merginObjects.add(accA3);

        insert merginObjects;
        
        
        
        
    }
}