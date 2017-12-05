/***********************************************************************************************************
 * Appirio, Inc
 * Name         : BatchUploadTriggerHandlerTest
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Test class for BatchUploadTrigger
 * Created Date : 03/11/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
* 03/11/2016                    Karl Houseknecht        Created
* 07/13/2016                    Ashu Gupta              Increased code coverage
* * 08/10/2016                  Munib Ur Rehman             Increased code coverage
 **********************************************************************************************************/
@isTest
private class BatchUploadTriggerHandlerTest {
    static rC_Connect__Batch_Upload__c upload;
    static Contact con;
    static Account national_Office_Acc,local_Part_Acc,communityAccount;
    static Standard_Allocation__c testStaAll;
    static rC_Giving__GAU__c testGAU;
    static Web_Transaction__c webTrans;
    private static testMethod void lookupParticipantFromNumberTest() {
        
        //test data
        createTestData();
       
        con = [select id, Contact_Number__c from Contact where id = :con.id LIMIT 1];
        
        upload = [select id, Participant__c, Participant_Number__c from rC_Connect__Batch_Upload__c where id = :upload.id LIMIT 1];
        
        Test.startTest();
        system.assertEquals(con.Contact_Number__c, upload.Participant_Number__c,'Participant number should be equal to child number');
       
       //System.assert(false,'Inside method $$$'+upload.participant__c);
       
       //system.assertEquals(con.id, upload.Participant__c, 'Participant should equal test child');
       
       
        
        upload.rC_Connect__Batch_Upload_Status__c = 'Committed';
        update upload;
        //upload = [select id, Participant__c from rC_Connect__Batch_Upload__c where id = :upload.id];
        //system.assertEquals(con.id, upload.Participant__c, 'Participant should not change on update if not null');
          
        test.stopTest();
    }
    
     private static testMethod void updateWebTransactionToFlaggedTest() {        
        //test data
        createTestData();
        upload.rC_Connect__Batch_Upload_Status__c = 'Flagged';
        upload.Web_Transaction__c = webTrans.Id;
        Test.startTest(); 
        update upload;        
        upload.Web_Transaction__c = null;
        upload.rC_Connect__Giving_Giving_Amount__c  = 200;
        update upload;        
        Test.stopTest();
     }
    
     private static testMethod void createFinanceOriginCodeAllocationsTest() {
        
        //test data
        createTestData();
        list<FOC__c> lstFOCs=new list<FOC__c>();//bulk List of custom setting object for bulk insert 
        FOC__c focRecord=new FOC__c(); //Custom Setting for Contact Fields 
        focRecord.Name='ACC';//Static record 1 of custom setting 
        focRecord.Active__c = true;
        focRecord.Cash__c = true;
        focRecord.Description__c = 'desc';
        focRecord.GAU_Id__c = testGAU.Id;
        lstFOCs.add(focRecord); 
        insert lstFOCs ;
        con = [select id, Contact_Number__c from Contact where id = :con.id LIMIT 1];
        
        upload = [select id, Participant__c, Participant_Number__c from rC_Connect__Batch_Upload__c where id = :upload.id LIMIT 1];
        
        Test.startTest();
        system.assertEquals(con.Contact_Number__c, upload.Participant_Number__c,'Participant number should be equal to child number');
       
       //System.assert(false,'Inside method $$$'+upload.participant__c);
       
       //system.assertEquals(con.id, upload.Participant__c, 'Participant should equal test child');
       
       
        upload.FOC__c = 'ACC - Automatic Credit Card';
        upload.rC_Connect__Batch_Upload_Status__c = 'Flagged';
        update upload;
         upload.rC_Connect__Batch_Upload_Status__c = 'Committed';
         update upload;
        List<GL_Allocation__c> glAllocationList = [select id from GL_Allocation__c];
        system.assert(glAllocationList.size() > 0 );
          
        test.stopTest();
    }
    private static testMethod void createAllocationsForGivingAmountUpdate() {
        
        //test data
        createTestData();
        list<FOC__c> lstFOCs=new list<FOC__c>();//bulk List of custom setting object for bulk insert 
        FOC__c focRecord=new FOC__c(); //Custom Setting for Contact Fields 
        focRecord.Name='ACC';//Static record 1 of custom setting 
        focRecord.Active__c = true;
        focRecord.Cash__c = true;
        focRecord.Description__c = 'desc';
        focRecord.GAU_Id__c = testGAU.Id;
        lstFOCs.add(focRecord); 
        insert lstFOCs ;
        con = [select id, Contact_Number__c from Contact where id = :con.id LIMIT 1];
        
        upload = [select id, Participant__c, rC_Connect__Batch_Upload_Status__c, Participant_Number__c from rC_Connect__Batch_Upload__c where id = :upload.id LIMIT 1];
        
        Test.startTest();
        system.assertEquals(con.Contact_Number__c, upload.Participant_Number__c,'Participant number should be equal to child number');
       
       //System.assert(false,'Inside method $$$'+upload.participant__c);
       
       //system.assertEquals(con.id, upload.Participant__c, 'Participant should equal test child');
       System.assertEquals(upload.rC_Connect__Batch_Upload_Status__c ,'New');
       
        upload.FOC__c = 'ACC - Automatic Credit Card';
        upload.rC_Connect__Batch_Upload_Status__c = 'Flagged';
        //upload.rC_Connect__Giving_Giving_Amount__c = 200;
        update upload;
        List<GL_Allocation__c> glAllocationList = [select id from GL_Allocation__c];
        system.assert(glAllocationList.size() > 0 );
        test.stopTest();
    }
    
     private static testMethod void lookupParticipantFromNumberTest2() {
        
        //test data
        createTestData();
        testStaAll.Credit__c = null;
        update testStaAll;
       
        con = [select id, Contact_Number__c from Contact where id = :con.id LIMIT 1];
        
        upload = [select id, Participant__c, Participant_Number__c from rC_Connect__Batch_Upload__c where id = :upload.id LIMIT 1];
        
        Test.startTest();
        system.assertEquals(con.Contact_Number__c, upload.Participant_Number__c, 'Participant number should be equal to child number');
       
       
       //System.assert(false,'Inside method $$$'+upload.participant__c);
       
       //system.assertEquals(con.id, upload.Participant__c, 'Participant should equal test child');
       
       
        
        upload.rC_Connect__Batch_Upload_Status__c = 'Committed';
        update upload;
        //upload = [select id, Participant__c from rC_Connect__Batch_Upload__c where id = :upload.id];
        //system.assertEquals(con.id, upload.Participant__c, 'Participant should not change on update if not null');
          
        test.stopTest();
    }
    
     private static testMethod void lookupParticipantFromNumberTest3() {
        
        //test data
        createTestData();
        testStaAll.Credit__c = null;
        update testStaAll;
       
        con = [select id, Contact_Number__c from Contact where id = :con.id LIMIT 1];
         
             Contact cn = [SELECT Contact_Number__c, RecordTypeId FROM COntact where id =:con.id LIMIT 1];
        System.assert(true,'Contact number issss'+cn.Contact_Number__c);
        
        rC_Connect__Batch_Upload__c upload1 = new rC_Connect__Batch_Upload__c();
        upload1.name = 'Test';
        upload.Participant__c = null;
        upload1.rC_Connect__Giving_Giving_Amount__c = 100;
        upload1.FOC__c = 'ACC - Automatic Credit Card';
        upload1.Participant_Number__c = cn.Contact_Number__c;
        upload1.rC_Connect__Batch_Upload_Status__c = 'New';
        insert upload1;
         //System.assertEquals(upload1.rC_Connect__Batch_Upload_Status__c, null);
         
         
        
        //upload1 = [select id, Participant__c, Participant_Number__c from rC_Connect__Batch_Upload__c where rC_Connect__Batch_Upload_Status__c='New' LIMIT 1];
          //upload.rC_Connect__Batch_Upload_Status__c = 'To Process';
        //update upload;
        Test.startTest();
       
       //System.assert(false,'Inside method $$$'+upload.participant__c);       
       //system.assertEquals(con.id, upload.Participant__c, 'Participant should equal test child');
       
        upload1.rC_Connect__Giving_Giving_Amount__c=2000;
     //   upload1.rC_Connect__Batch_Upload_Status__c = 'New';
    //    update upload1;
     //    System.assertEquals(upload1.rC_Connect__Batch_Upload_Status__c, null);
        //upload = [select id, Participant__c from rC_Connect__Batch_Upload__c where id = :upload.id];
        //system.assertEquals(con.id, upload.Participant__c, 'Participant should not change on update if not null');
          
        test.stopTest();
    }
    
    static void createTestData(){
        
        Id participantRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        Id transactionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id CommunityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        Id LocalPartnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        Id accNORTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        
        
        national_Office_Acc = TestUtils.createAccountWithRT('Test NO Account', accNORTId, null, '765', '9234', true);
        local_Part_Acc = TestUtils.createAccountWithRT('Test LP Account', LocalPartnerRecordTypeId, national_Office_Acc, '904', '3467', true);
        communityAccount = TestUtils.createAccountWithRT('Test Community Account', CommunityRecordTypeId, local_Part_Acc, '253', '5646', true);
        
        webTrans = TestUtils.createWebTransaction(false);
        webTrans.Contact_First_Name__c = 'Test';
        webTrans.Contact_Last_Name__c  = 'Last Name';
        webTrans.Contact_City__c = 'Test';
        webTrans.Contact_Country__c = 'TC';
        webTrans.Contact_Email__c = 't@test.com';
        webTrans.Contact_Phone__c = '238628332';
        webTrans.Contact_Postal_Code__c = '21313';
        webTrans.Contact_State_Prov_Terr__c = 'DL';
        webTrans.Contact_Street_1__c = 'Test S1';
        webTrans.Contact_Street_2__c = 'Test S2';
        webTrans.Contact_Suffix__c = 'Mr.';
        webTrans.Contact_Title__c = 'tt';
        insert webTrans;
        
        Account acc = TestUtils.createAccount('TestAcc', true);
      
        con = TestUtils.createContact(acc,'FirstName','Lastname',false);
        con.RecordTypeId = participantRecordTypeId;
        con.Community__c = communityAccount.id;
        con.Participant_Case_Number__c = '12345';
        con.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        insert con;
        
        Contact cn = [SELECT Contact_Number__c, RecordTypeId FROM COntact where id =:con.id LIMIT 1];
        System.assert(true,'Contact number issss'+cn.Contact_Number__c);
        
        upload = new rC_Connect__Batch_Upload__c();
        upload.name = 'Test';
        upload.Participant__c = null;
        upload.rC_Connect__Giving_Giving_Amount__c = 100;
        upload.FOC__c = 'ACC - Automatic Credit Card';
        upload.Participant_Number__c = cn.Contact_Number__c;
        upload.rC_Connect__Batch_Upload_Status__c = 'New';
        insert upload;
        
        //System.assert(true,'UPLOAD PARTICIPANT No. '+upload.Participant_Number__c);
        System.debug('Upload inserted #######'+upload);
        
        Campaign testCamp = TestUtils.createCampaign('Test Camp' , true);
        
        Opportunity parentOpp = TestUtils.createOpportunity(local_Part_Acc ,'testOpportunity' , 100 , false);
        parentOpp.Campaign = testcamp;
        insert parentOpp;
        
        Opportunity testOpp = TestUtils.createOpportunity(local_Part_Acc ,'testOpportunity' , 100 , false);
        testOpp.Campaign = testcamp; 
        testOpp.RecordTypeId = transactionRecordTypeId;
        testOpp.rC_Giving__Parent__c = parentOpp.Id;
        insert testOpp;
        
        testGAU = TestUtils.createGeneralAccountingUnit('testGAU',true);
        testStaAll = TestUtils.createStandardAllocation('0001', testGAU.Id, false);
        testStaAll.Credit__c = 100;
        testStaAll.Debit__c = 100 ;
        insert testStaAll;
        
        Opportunity testOpp2 = TestUtils.createOpportunity(local_Part_Acc ,'testOpportunity' , 100 , false);
        testOpp2.Campaign = testcamp;
        testOpp2.StageName = 'Completed';
        insert testOpp2;
        
        Undistributed_Funds_GAU__c ufGAU = TestUtils.createUndistributedFundsGAU('GAU 1111',testGAU.Id, true);        
        
    }

}