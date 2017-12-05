/***********************************************************************************************************
 * Appirio, Inc
 * Name         : OpportunityDFCRecievedbyNOTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test Class for OpportunityDFCRecievedbyNO
 * Created Date : 04/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 04/07/2016                   Munib Ur Rehman        Created
 * 08/12/2016                   Munib Ur Rehman        Created
 * 26/09/2016                   Sahil Rathore          Modified increased code coverage and removed failure
 **********************************************************************************************************/
 @isTest
 public with sharing class OpportunityDFCRecievedbyNOTest {
     public static Account NO_Acc;
    @isTest
    public static void OpportunityDFCRecievedbyNOTestTest(){
        Test.StartTest();
        //Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
        //Account NO_Acc = TestUtils.createAccountWithRT('1st National Account test', ACC_NO_RT, null, '209', '21245', false);
        //insert NO_Acc;
       
        //added 26sept sahil rathore
       /// Contact con=TestUtils.createContact(NO_Acc, 'tstfirst', 'tstlast', false);
       // con.RecordTypeId='012E000000021zj';
        //con.Date_Anniversary__c=System.today();
       // insert con;
       // 
       Account acc = TestUtils.createAccount('testAcc', true);
        Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        NO_Acc = TestUtils.createAccountWithRT('1st National Account test', ACC_NO_RT, null, '209', '21245', false);
        insert NO_Acc;
        List<String> noList = new List<String>();
        noList.add(NO_Acc.Id);
        
         Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        Contact kid = TestUtils.createContact(acc, 'Good1', 'Kid1', false);
        kid.RecordTypeId = participantRecordTypeId;
        kid.Participant_Case_Number__c = '12345';
        kid.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        kid.Date_Anniversary__c=System.today();
        insert kid;
        
        
        rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('testGAU',true);
        List<GL_Allocation__c> allocationList = new List<GL_Allocation__c>();
        GL_Allocation__c allocation = new GL_Allocation__c();
        allocation.GL_Account__c = gau.Id;
        allocationList.add(allocation);
        insert allocationList;
        
        
       //currency for obligation2 added by sahil rathore
       
       Currency__c cur=TestUtils.createCurrency('CAD','Canada',false);
       insert cur;
       
        List<Obligation__c> obligationList = new List<Obligation__c>();
        Obligation__c obligation = TestUtils.createObligation(NO_Acc , false);
        //obligation.Release_Date__c = System.today().addDays(-2);
        obligation.Release_Date__c=kid.Date_Anniversary__c;
        obligationList.add(obligation);
        
        Obligation__c obligation1 = TestUtils.createObligation(NO_Acc , false);
        obligation1.Release_Date__c = null;
        //obligation1.Release_Date__c=kid.Date_Anniversary__c;
        obligation1.Received_by_NO_Date__c = System.today();
        obligation1.CreatedDate = System.today().addDays(-1);
        obligation1.Exchange_Rate__c=0.750000000;
        
        obligationList.add(obligation1);
        
        obligation__c obligation2 = TestUtils.createObligation(NO_ACC, false);
        obligation2.Release_Date__c=kid.Date_Anniversary__c;
        obligation2.Exchange_Rate__c=0.750000000;
        obligation2.Local_Currency__c=cur.id;
        
        obligationList.add(obligation2);
        
        insert obligationList;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(allocationList);
        OpportunityDFCReceivedbyNO recivedNO = new OpportunityDFCReceivedbyNO(sc);
        
        recivedNO.mycon=kid;
        
        recivedNO.nationalOffice = NO_ACC.Id;
        recivedNO.myObligation = obligation1;
        recivedNO.submitDFCSenttoNO();
        recivedNO.submitDFCReceived();
        recivedNO.myObligation = obligation2;
        recivedNO.submitDFCReceived();
        System.assertEquals(recivedNO.isJobStatusRendered, true);
        System.assertEquals(recivedNO.isTimerEnabled, true);
        Test.StopTest();
       
    }

}