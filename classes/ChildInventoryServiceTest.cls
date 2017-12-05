/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ChildInventoryServiceTest
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class of ChildInventoryService Class
 * Created Date : Feb/17/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * July/19/2016                 Kanika Mathur           Modified code to create data using TestUtil class
 * July/21/2016                 Ravi Chauhan            Modified | Used TestUtil method for creating contact
 * July/29/2016                 Ravi Chauhan            Modified | Ramp Up Code Coverage
 * Aug/02/2016                  Munib Ur Rehman         Modified | Ramp Up Code Coverage
 **********************************************************************************************************/
@isTest
public class ChildInventoryServiceTest {
    static Contact testCont1;
    
    public Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    public Final Static String childFundRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
    public Final Static Id ACC_LP_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    public Final Static Id ACC_COM_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    public Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    final static String CON_HH_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    public Final Static Id CON_PART_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId(); 
    //Static Contact cont;
    
    @isTest
    static void test_IsChildLocked() {
        createTestData();
        System.debug('[RB] - ChildInventoryServiceTest.test_IsChildLocked :: Method Start..');
        Boolean isChildLocked;
    //  Contact con1 = [SELECT Id,Contact_Number__c,RecordType.Name ,Child_Number__c, National_Office_Number__c FROM Contact WHERE rC_Sponsorship__Sponsorship_Status__c = 'Available' and Participant_Case_Number__c = '55555' ][0];
   // Contact con1 = [SELECT Id,Contact_Number__c,RecordType.Name ,Child_Number__c, National_Office_Number__c FROM Contact WHERE RecordTypeID=:CON_PART_RT ][0];
   Contact con1 = [SELECT Id,Contact_Number__c,RecordType.Name ,Child_Number__c, National_Office_Number__c FROM Contact][0];
        System.debug('[RB] - ChildInventoryServiceTest.test_IsChildLocked :: con1 => ' + con1);
        con1.RecordTypeID=CON_PART_RT;
        update con1;
      system.assertEquals(con1.RecordType.Name,null);
      System.assertEquals(Integer.valueOf(con1.Child_Number__c), 199);
      System.assertEquals(Integer.valueOf(con1.National_Office_Number__c),9393);
        isChildLocked =  ChildInventoryService.IsChildLocked(Integer.valueOf(con1.National_Office_Number__c), Integer.valueOf(con1.Child_Number__c));
        System.assertEquals(false, isChildLocked);
        
        Id resId = [SELECT Id, Name FROM rC_Sponsorship__Reserve__c WHERE Name = 'Website Shopping Cart Reserve'][0].Id;
        
        
        Contact con2 = [SELECT Id, Child_Number__c, National_Office_Number__c FROM Contact WHERE rC_Sponsorship__Reserve__c = :resId][0];
        System.debug('Contact @@@'+con2);
        con2.AccountId = Null;
        con2.RecordTypeId = CON_PART_RT;
        con2.rC_Sponsorship__Reserve__c = resId;
        con2.rC_Sponsorship__Sponsorship_Status__c = 'Reserved';
        System.debug('[RB] - ChildInventoryServiceTest.test_IsChildLocked :: con2 => ' + con2);
        isChildLocked =  ChildInventoryService.IsChildLocked(Integer.valueOf(con2.National_Office_Number__c), Integer.valueOf(con2.Child_Number__c));
        System.assertEquals(true, isChildLocked);
        isChildLocked =  ChildInventoryService.IsChildLocked(160, Integer.valueOf(con2.Child_Number__c));  //Passing wrong data to cover error catch part
        isChildLocked =  ChildInventoryService.IsChildLocked(200, 2090);        //Passing wrong data to cover error catch part
        System.assertEquals(false, isChildLocked);
        System.debug('[RB] - ChildInventoryServiceTest.test_IsChildLocked :: Method End..');
    } // END static void test_IsChildLocked() {
    
    @isTest
    static void test_LockChild() {
        createTestData();
        System.debug('[RB] - ChildInventoryServiceTest.test_LockChild :: Method Start..');
        Integer response;

        Contact con = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Child_Number__c, National_Office_Number__c FROM Contact WHERE rC_Sponsorship__Sponsorship_Status__c = 'Available' and Participant_Case_Number__c = '55555'][0];
        //System.debug('[RB] - ChildInventoryServiceTest.test_LockChild :: con => ' + con);
        response =  ChildInventoryService.LockChild(Integer.valueOf(con.National_Office_Number__c), Integer.valueOf(con.Child_Number__c));
        //System.assertEquals(0, response);
        System.debug('[RB] - ChildInventoryServiceTest.test_LockChild :: Exception => ' + [SELECT Name, Status_Code__c, Message__c FROM Apex_Log__c WHERE Class_Name__c='ChildInventoryService' AND Method_Name__c='LockChild']);
        response =  ChildInventoryService.LockChild(200, 2090);     //Passing wrong data to cover error catch part
        System.assertEquals(0, response);
        
        Contact cont = [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Child_Number__c, National_Office_Number__c FROM Contact 
                        WHERE rC_Sponsorship__Sponsorship_Status__c = 'Available' and Participant_Case_Number__c = '55555'][0];
        response =  ChildInventoryService.LockChild(Integer.valueOf(cont.National_Office_Number__c), Integer.valueOf(cont.Child_Number__c));

        System.debug('[RB] - ChildInventoryServiceTest.test_LockChild :: Method End..');
    } // END static void test_LockChild() {
    
    @isTest
    static void test_GetKidsForWeb() {
        createTestData();
        System.debug('[RB] - ChildInventoryServiceTest.test_GetKidsForWeb :: Method Start..');
        Contact cont = [SELECT Id, recordtypeid, National_Office__r.Used_On_Web__c, Local_Partner__r.Used_On_Web__c, Community__r.Used_On_Web__c, 
                        National_Office__r.rC_Bios__Active__c, Local_Partner__r.rC_Bios__Active__c, Community__r.rC_Bios__Active__c, 
                        National_Office__r.PC_Available__c, Local_Partner__r.PC_Available__c, Community__r.PC_Available__c, 
                        National_Office__r.Web_Threshold__c, Local_Partner__r.Web_Threshold__c, Community__r.Web_Threshold__c, 
                        National_Office__r.Web_Threshold_OK__c, Local_Partner__r.Web_Threshold_OK__c, Community__r.Web_Threshold_OK__c, 
                        rC_Sponsorship__Reserve__c, National_Office__r.NO_Country__c, rC_Bios__Birth_Day__c, rC_Bios__Birth_Month__c, Birthdate, 
                        rC_Bios__Age__c, rC_Bios__Gender__c, rC_Sponsorship__Sponsorship_Status__c, Child_Number__c, Community_Number__c, National_Office_Number__c 
                        FROM Contact WHERE rC_Sponsorship__Sponsorship_Status__c = 'Available' and Participant_Case_Number__c = '55555'][0];
        /*Integer cnt = 1;
        for(Contact con : [SELECT Id, recordtypeid, National_Office__r.Used_On_Web__c, Local_Partner__r.Used_On_Web__c, Community__r.Used_On_Web__c, 
                        National_Office__r.rC_Bios__Active__c, Local_Partner__r.rC_Bios__Active__c, Community__r.rC_Bios__Active__c, 
                        National_Office__r.PC_Available__c, Local_Partner__r.PC_Available__c, Community__r.PC_Available__c, 
                        National_Office__r.Web_Threshold__c, Local_Partner__r.Web_Threshold__c, Community__r.Web_Threshold__c, 
                        National_Office__r.Web_Threshold_OK__c, Local_Partner__r.Web_Threshold_OK__c, Community__r.Web_Threshold_OK__c, 
                        rC_Sponsorship__Reserve__c, National_Office__r.NO_Country__c, rC_Bios__Birth_Day__c, rC_Bios__Birth_Month__c, Birthdate, 
                        rC_Bios__Age__c, rC_Bios__Gender__c, rC_Sponsorship__Sponsorship_Status__c, Child_Number__c, Community_Number__c, National_Office_Number__c 
                        FROM Contact WHERE rC_Sponsorship__Sponsorship_Status__c = 'Available' and Participant_Case_Number__c = '55555']) {
            String debug_Val = 'National_Office__r.Used_On_Web__c: ' + String.valueOf(con.National_Office__r.Used_On_Web__c) + '; ';
            debug_Val += 'Local_Partner__r.Used_On_Web__c: ' + String.valueOf(con.Local_Partner__r.Used_On_Web__c) + '; ';
            debug_Val += 'Community__r.Used_On_Web__c: ' + String.valueOf(con.Community__r.Used_On_Web__c) + '; ';
            debug_Val += 'National_Office__r.rC_Bios__Active__c: ' + String.valueOf(con.National_Office__r.rC_Bios__Active__c) + '; ';
            debug_Val += 'Local_Partner__r.rC_Bios__Active__c: ' + String.valueOf(con.Local_Partner__r.rC_Bios__Active__c) + '; ';
            debug_Val += 'Community__r.rC_Bios__Active__c: ' + String.valueOf(con.Community__r.rC_Bios__Active__c) + '; ';
            debug_Val += 'National_Office__r.PC_Available__c: ' + String.valueOf(con.National_Office__r.PC_Available__c) + '; ';
            debug_Val += 'Local_Partner__r.PC_Available__c: ' + String.valueOf(con.Local_Partner__r.PC_Available__c) + '; ';
            debug_Val += 'Community__r.PC_Available__c: ' + String.valueOf(con.Community__r.PC_Available__c) + '; ';
            debug_Val += 'National_Office__r.Web_Threshold__c: ' + String.valueOf(con.National_Office__r.Web_Threshold__c) + '; ';
            debug_Val += 'Local_Partner__r.Web_Threshold__c: ' + String.valueOf(con.Local_Partner__r.Web_Threshold__c) + '; ';
            debug_Val += 'Community__r.Web_Threshold__c: ' + String.valueOf(con.Community__r.Web_Threshold__c) + '; ';
            debug_Val += 'National_Office__r.Web_Threshold_OK__c: ' + String.valueOf(con.National_Office__r.Web_Threshold_OK__c) + '; ';
            debug_Val += 'Local_Partner__r.Web_Threshold_OK__c: ' + String.valueOf(con.Local_Partner__r.Web_Threshold_OK__c) + '; ';
            debug_Val += 'Community__r.Web_Threshold_OK__c: ' + String.valueOf(con.Community__r.Web_Threshold_OK__c) + '; ';
            debug_Val += 'National_Office__r.NO_Country__c: ' + String.valueOf(con.National_Office__r.NO_Country__c) + '; ';
            debug_Val += 'rC_Sponsorship__Reserve__c: ' + String.valueOf(con.rC_Sponsorship__Reserve__c) + '; ';
            debug_Val += 'rC_Bios__Birth_Day__c: ' + String.valueOf(con.rC_Bios__Birth_Day__c) + '; ';
            debug_Val += 'rC_Bios__Birth_Month__c: ' + String.valueOf(con.rC_Bios__Birth_Month__c) + '; ';
            debug_Val += 'Birthdate: ' + String.valueOf(con.Birthdate) + '; ';
            debug_Val += 'rC_Bios__Age__c: ' + String.valueOf(con.rC_Bios__Age__c) + '; ';
            debug_Val += 'rC_Bios__Gender__c: ' + String.valueOf(con.rC_Bios__Gender__c) + '; ';
            debug_Val += 'rC_Sponsorship__Sponsorship_Status__c: ' + String.valueOf(con.rC_Sponsorship__Sponsorship_Status__c) + '; ';
            debug_Val += 'Child_Number__c: ' + String.valueOf(con.Child_Number__c) + '; ';
            debug_Val += 'Community_Number__c: ' + String.valueOf(con.Community_Number__c) + '; ';
            debug_Val += 'National_Office_Number__c: ' + String.valueOf(con.National_Office_Number__c) + '; ';
            System.debug('[RB] - ChildInventoryServiceTest.test_GetKidsForWeb :: debug_Val(' + String.valueOf(cnt++) + ') => ' + debug_Val); 
        }*/
        
        System.debug('[RB] - ChildInventoryServiceTest.test_GetKidsForWeb :: cont => ' + cont);
        CountriesRefCodes__c crc = TestUtils.createCountriesRefCodes('356', true, '12', false);
        crc.Description__c = 'India';
        insert crc;
        
        ChildFilter cf = new ChildFilter();
        cf.NoId = Integer.valueOf(cont.National_Office_Number__c);
        cf.ProjectId = Integer.valueOf(cont.Community_Number__c);
        cf.KidsReturned = 0;
        cf.Birthday = String.valueOf(System.today().day());
        cf.BirthMonth = String.valueOf(System.today().month());
        cf.CountryCode = 356;
        
        for(Integer i=1; i<15; i++) {
            cf.Gender = Math.mod(i, 2)==0 ? 'M' : 'F';
            cf.FromAge = i;
            cf.ToAge = i+2;
            List<WebChildInfo> lstWCI = ChildInventoryService.GetKidsForWeb(cf);
        }
        //System.debug('[RB] - ChildInventoryServiceTest.test_GetKidsForWeb :: lstWCI => ' + lstWCI);
        //System.debug('[RB] - ChildInventoryServiceTest.test_GetKidsForWeb :: Exception => ' + [SELECT Name, Status_Code__c, Message__c FROM Apex_Log__c WHERE Class_Name__c='ChildInventoryService' AND Method_Name__c='GetKidsForWeb']);
        //System.assertNotEquals(lstWCI.size(), 0);
        
        // Ravi Chauhan | Covering the Exception Scenario
        ChildInventoryService.GetKidsForWeb(null);

        System.debug('[RB] - ChildInventoryServiceTest.test_GetKidsForWeb :: Method End..');
    } // END static void test_GetKidsForWeb() {
    
    @isTest
    static void test_UnLockChild() {
        createTestData();
        Test.startTest();           
        Account acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = ACC_HH_RT;
        insert acc;    
rC_Sponsorship__Reserve__c reserve = TestUtils.createSponsorshipReserve('Website Shopping Cart Reserve', false);
reserve.rC_Sponsorship__Status__c = 'Active';
reserve.rC_Sponsorship__Start_Date__c = System.now().date().addDays(-365);
reserve.rC_Sponsorship__Expiration_Date__c = System.now().date().addDays(365);
insert reserve;

        Contact cont2 = TestUtils.createContact(acc,'Vaibhav','Goel',False);
        cont2.Participant_Case_Number__c = '45665';
        cont2.rC_Sponsorship__Sponsorship_Status__c = 'Reserved';
        cont2.rC_Sponsorship__Reserve__c = reserve.Id;
        cont2.rC_Bios__Gender__c = 'Male';
        cont2.rC_Bios__Birth_Day__c = '07';
        cont2.rC_Bios__Birth_Month__c = '07';
        cont2.RecordTypeId = CON_PART_RT;
        insert cont2;
        System.debug('[RB] - ChildInventoryServiceTest.test_UnLockChild :: Method Start..');
        Integer response;
        Id resId = [SELECT Id, Name FROM rC_Sponsorship__Reserve__c WHERE Name = 'Website Shopping Cart Reserve'][0].Id;
        //System.debug('[RB] - ChildInventoryServiceTest.test_UnLockChild :: All Contacts => ' + [SELECT Id, rC_Sponsorship__Sponsorship_Status__c, Child_Number__c, National_Office_Number__c FROM Contact]);
        Contact con = [SELECT Id, RecordTypeId, Recordtype.Name, rC_Sponsorship__Sponsorship_Status__c, Contact_Number__c, Child_Number__c, National_Office_Number__c FROM Contact WHERE rC_Sponsorship__Reserve__c = :resId][0];        
        //con.AccountId = Null;
        //con.RecordTypeId = CON_PART_RT;
        //con.rC_Sponsorship__Sponsorship_Status__c = 'Reserved';
        //update con;
        //System.debug('[RB] - ChildInventoryServiceTest.test_UnLockChild :: con => ' + con);
        //system.assert(false, '==>' + con);
        response =  ChildInventoryService.UnLockChild(Integer.valueOf(con.National_Office_Number__c), Integer.valueOf(con.Child_Number__c));
        //System.assertEquals(1, response);
        //System.debug('[RB] - ChildInventoryServiceTest.test_UnLockChild :: Exception => ' + [SELECT Name, Status_Code__c, Message__c FROM Apex_Log__c WHERE Class_Name__c='ChildInventoryService' AND Method_Name__c='UnLockChild']);
        response =  ChildInventoryService.UnLockChild(200, 2090);   //Passing wrong data to cover error catch part
        System.assertEquals(0, response);

        System.debug('[RB] - ChildInventoryServiceTest.test_UnLockChild :: Method End..');
        Test.stopTest();
    } // END static void test_UnLockChild() {

    
    
    @isTest
    static void test_IsChildObtainable() {
        createTestData();
        Boolean isChildObtainable;
        //Scenario 1 : Unavailable Child.
        Contact con1 = [SELECT Id, Child_Number__c, National_Office_Number__c FROM Contact WHERE rC_Sponsorship__Sponsorship_Status__c = 'Sponsored'][0];
        isChildObtainable =  ChildInventoryService.IsChildObtainable(Integer.valueOf(con1.National_Office_Number__c), Integer.valueOf(con1.Child_Number__c));
        System.assertEquals(false, isChildObtainable); 
        
        //Scenario 2: Reserved Child
        Id resId = [SELECT Id, Name FROM rC_Sponsorship__Reserve__c WHERE Name = 'Website Shopping Cart Reserve'][0].Id;
        Contact con2 = [SELECT Id, Child_Number__c, National_Office_Number__c FROM Contact WHERE rC_Sponsorship__Reserve__c = :resId][0];
        con2.AccountId = Null;
        con2.RecordTypeId = CON_PART_RT;
        update con2;
        system.debug('===>con2' + con2);
        isChildObtainable =  ChildInventoryService.IsChildObtainable(Integer.valueOf(con2.National_Office_Number__c), Integer.valueOf(con2.Child_Number__c));
        System.assertEquals(true, isChildObtainable);
        
        //Scenario 3: Wrong Data Expecting the SOQL Query Exception
        try{
        isChildObtainable =  ChildInventoryService.IsChildObtainable(160, Integer.valueOf(con2.Child_Number__c));  //Passing wrong data to cover error catch part
        }catch(Exception Ex){
            
        }
        
    } // END static void test_IsChildObtainable() {
    
    
    // Ravi Chauhan >> Ramp Up Code Coverage
    @isTest
    static void testUnLockChildNew() {
        createTestData();
        Test.startTest();
        
        System.debug('[RB] - ChildInventoryServiceTest.testUnLockChildNew :: Method Start..');

        rC_Giving__Contact_Setting__c con_cust_setting = rC_Giving__Contact_Setting__c.getOrgDefaults();
        con_cust_setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert con_cust_setting;
        
        Account acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        insert acc;

        Integer response;
        rC_Sponsorship__Reserve__c res = [SELECT Id, Name FROM rC_Sponsorship__Reserve__c WHERE Name = 'Website Shopping Cart Reserve' LIMIT 1];
        System.debug('Res >> ' + res);
        
        rC_Sponsorship__Reserve__c reserve = TestUtils.createSponsorshipReserve('Website Shopping Cart Reserve', false);
        reserve.rC_Sponsorship__Status__c = 'Active';
        reserve.rC_Sponsorship__Start_Date__c = System.now().date().addDays(-365);
        reserve.rC_Sponsorship__Expiration_Date__c = System.now().date().addDays(365);
        insert reserve;
        Account acCF = TestUtils.createAccountWithRT('Test CF1',String.valueOf(childFundRT),null,'910',null,true);
        Account acNat = TestUtils.createAccountWithRT('Test National',String.valueOf(ACC_NO_RT),null,'909',null,true);
        Account acLoc = TestUtils.createAccountWithRT('Test Local',String.valueOf(ACC_LP_RT),acNat,null,null,true);
        Account acCom = TestUtils.createAccountWithRT('Test Comm',String.valueOf(ACC_COM_RT),acLoc,null,'9099',false);
        acCom.Dedicated_Reserve__c = reserve.Id;
        acCom.Dedicated_to_Alliance__c = acCF.Id;
        insert acCom;
        System.debug('acNat ' + [SELECT National_Office_ID__c FROM Account WHERE id =:acNat.Id]);
        Contact contLatest = TestUtils.createContact(acc,'Ravi','Chauhan',False);
        contLatest.Community__c = acCom.id;
        contLatest.rC_Sponsorship__Sponsorship_Status__c = 'Reserved';
        contLatest.rC_Sponsorship__Reserve__c = reserve.Id;
        contLatest.National_Office__c = acNat.Id;
        contLatest.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        contLatest.Participant_Case_Number__c = '44045';
        insert contLatest;
        Contact con = [SELECT Child_Number__c,Participant_Case_Number__c,rC_Sponsorship__Sponsorship_Status__c,Contact_Number__c,
                       rC_Sponsorship__Reserve__c,National_Office_Number__c,National_Office__r.National_Office_ID__c,RecordType.Name
                       FROM Contact WHERE id =:contLatest.Id];
        //system.assert(false,con.RecordType.Name);               
        //system.assert(false,con.National_Office_Number__c + '  ' + con.Child_Number__c);             
        //system.assert(false,'==1 '+ con.Child_Number__c + '==2 ' + con.Contact_Number__c);
        System.debug('[RB] - ChildInventoryServiceTest.testUnLockChildNew :: con => ' + con);
        System.debug('[RB] - ChildInventoryServiceTest.testUnLockChildNew :: con => ' + con.rC_Sponsorship__Sponsorship_Status__c);
        
        response =  ChildInventoryService.UnLockChild(Integer.valueOf(con.National_Office_Number__c), Integer.valueOf(con.Child_Number__c));
        //System.assertEquals(1, response);
        //System.debug('[RB] - ChildInventoryServiceTest.test_UnLockChild :: Exception => ' + [SELECT Name, Status_Code__c, Message__c FROM Apex_Log__c WHERE Class_Name__c='ChildInventoryService' AND Method_Name__c='UnLockChild']);
        response =  ChildInventoryService.UnLockChild(null, null);  //Passing wrong data to cover error catch part
        System.assertEquals(0, response);
        Test.stopTest();

        System.debug('[RB] - ChildInventoryServiceTest.test_UnLockChild :: Method End..');
    }
    // Ravi Chauhan >> Ramp Up Code Coverage
    
    
    static void createTestData() {
        System.debug('[RB] - ChildInventoryServiceTest.createTestData :: Method Start..');        
                
        //rC_Giving__Contact_Setting__c con_cust_setting = rC_Giving__Contact_Setting__c.getOrgDefaults();
        //con_cust_setting.rC_Giving__Disable_RollupHardCredits__c = true;
        //upsert con_cust_setting;
        
        List<Account> accList = new List<Account>();// List Of Accounts for National Offices
        
        Account acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = ACC_HH_RT;
        insert acc;
        
        Account NO_Acc1 = TestUtils.createAccountWithRT('1st National Account', ACC_NO_RT, null, '199', '1245', false);
        NO_Acc1.BillingCountry = 'IN';
        NO_Acc1.NO_Country__c = 'India';
        NO_Acc1.Used_On_Web__c = true;
        NO_Acc1.rC_Bios__Active__c = true;
        //NO_Acc1.Web_Threshold_OK__c = true;       //Field is not writeable
        NO_Acc1.PC_Available__c = 2;
        NO_Acc1.Web_Threshold__c = 1;
        NO_Acc1.Male_0_2__c = true;
        NO_Acc1.Male_3_5__c = true;
        NO_Acc1.Male_6_8__c = true;
        NO_Acc1.Male_9_10__c = true;
        NO_Acc1.Male_11_12__c = true;
        NO_Acc1.Female_0_2__c = true;
        NO_Acc1.Female_3_5__c = true;
        NO_Acc1.Female_6_8__c = true;
        NO_Acc1.Female_9_10__c = true;
        NO_Acc1.Female_11_12__c = true;
        accList.add(NO_Acc1);
       
        
        Account NO_Acc2 = TestUtils.createAccountWithRT('Brickbounce limited', ACC_NO_RT, null, '200', '1246', false);
        accList.add(NO_Acc2);
         insert accList;
         
        accList = new List<Account>();  // List Of Accounts for Local Partners
        Account LP_Acc1 = TestUtils.createAccountWithRT('Google Retail Partner', ACC_LP_RT, NO_Acc1, '149', '1346', false);
        LP_Acc1.Used_On_Web__c = true;
        LP_Acc1.rC_Bios__Active__c = true;
        //LP_Acc1.Web_Threshold_OK__c = true;       //Field is not writeable
        LP_Acc1.PC_Available__c = 2;
        LP_Acc1.Web_Threshold__c = 1;
        insert LP_Acc1;
        // accList.add(LP_Acc1);
        
        Account LP_Acc2 = TestUtils.createAccountWithRT('Amazon Services', ACC_LP_RT, NO_Acc2, '150', '3347', false);
        accList.add(LP_Acc2);
        insert accList;
        
        accList = new List<Account>();// List Of Accounts for Community Accounts
        
        Account Com_Acc1 = TestUtils.createAccountWithRT('Maheshwari Community Services', ACC_COM_RT, LP_Acc1, '159', '1247', false);
        Com_Acc1.Used_On_Web__c = true;
        Com_Acc1.rC_Bios__Active__c = true;
        //Com_Acc1.Web_Threshold_OK__c = true;      //Field is not writeable
        Com_Acc1.PC_Available__c = 2;
        Com_Acc1.Web_Threshold__c = 1;
        insert Com_Acc1;
        //accList.add(Com_Acc1);
        
        
        Account Com_Acc2 = TestUtils.createAccountWithRT('Bhargava Young', ACC_COM_RT, LP_Acc2, '160', '1448', false);
        //Account HH_Acc = TestUtils.createAccountWithRT('Test Household Account', ACC_HH_RT, Com_Acc1, '569', '21340', true);
        accList.add(Com_Acc2);
        insert accList; 
        
        Contact cont1 = TestUtils.createContact(acc,'Rohit','Bharagava',False);
        cont1.Community__c = Com_Acc1.id;
        cont1.Participant_Case_Number__c = '45645';
        cont1.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        cont1.rC_Bios__Gender__c = 'Male';
        cont1.rC_Bios__Birth_Day__c = '07';
        cont1.rC_Bios__Birth_Month__c = '07';
        cont1.RecordTypeId = CON_PART_RT;
        insert cont1;
        System.debug('contact number' +[SELECT Child_Number__c,Contact_Number__c FROM contact where id =: cont1.Id]);
        
        System.debug('[RB] - ChildInventoryServiceTest.createTestData :: cont1 => ' + cont1);
        
        Decimal thresholdNO = cont1.National_Office__r.Web_Threshold__c;
        Decimal thresholdComm = cont1.Community__r.Web_Threshold__c;
        String commNo = '';
        
        List<Contact> conList = [select Id, FirstName, Community_Number__c from Contact];
        for(Contact con : conList){
                commNo = con.Community_Number__c;
        }
        //Integer pcComm = cont3.Community__r.PC_Available__c;
        List<Contact> contList = [select id, FirstName , National_Office__c, Child_Number__c, Short_Name__c, Community_Number__c, rC_Sponsorship__Sponsorship_Status__c, rC_Bios__Gender__c, rC_Bios__Age__c, Description, rC_Bios__Birth_Day__c, rC_Bios__Birth_Month__c, rC_Bios__Birth_Year__c, National_Office__r.BillingCountry, Enterprise_Legacy_Id__c, National_Office__r.Male_0_2__c, National_Office__r.Male_3_5__c, National_Office__r.Male_6_8__c, National_Office__r.Male_9_10__c, National_Office__r.Male_11_12__c, National_Office__r.Female_0_2__c, National_Office__r.Female_3_5__c, National_Office__r.Female_6_8__c, National_Office__r.Female_9_10__c, National_Office__r.Female_11_12__c, National_Office__r.Web_Threshold__c  
        from contact 
        where recordtypeid = :CON_PART_RT AND National_Office__r.Used_On_Web__c = true 
        AND Community__r.Used_On_Web__c = true 
        AND National_Office__r.PC_Available__c >= :thresholdNO 
        AND Community__r.PC_Available__c >= :thresholdComm 
        AND rC_Sponsorship__Reserve__c = null 
        AND rC_Sponsorship__Sponsorship_Status__c = 'Available' 
        AND rC_Bios__Birth_Day__c = '07' 
        AND rC_Bios__Birth_Month__c = '07' 
        AND Community_Number__c = :commNo
        AND rC_Bios__Gender__c = 'Male' LIMIT 5];
        
        
        
        //System.assertEquals(contList.size(), 0);

        rC_Sponsorship__Reserve__c reserve = TestUtils.createSponsorshipReserve('Website Shopping Cart Reserve', false);
        reserve.rC_Sponsorship__Status__c = 'Active';
        reserve.rC_Sponsorship__Start_Date__c = System.now().date().addDays(-365);
        reserve.rC_Sponsorship__Expiration_Date__c = System.now().date().addDays(365);
        insert reserve;
        System.debug('[RB] - ChildInventoryServiceTest.createTestData :: reserve => ' + reserve);
        
        List<Contact> lstContacts = new List<Contact>();

        Contact cont2 = TestUtils.createContact(acc,'Vaibhav','Goel',False);
        cont2.Community__c = Com_Acc2.id;
        cont2.Participant_Case_Number__c = '45665';
        cont2.rC_Sponsorship__Sponsorship_Status__c = 'Reserved';
        cont2.rC_Sponsorship__Reserve__c = reserve.Id;
        cont2.rC_Bios__Gender__c = 'Male';
        cont2.rC_Bios__Birth_Day__c = '07';
        cont2.rC_Bios__Birth_Month__c = '07';
        cont2.RecordTypeId = CON_PART_RT;
        lstContacts.add(cont2);
        System.debug('[RB] - ChildInventoryServiceTest.createTestData :: cont2 => ' + cont2);
        
        Contact cont3 = TestUtils.createContact(acc,'Vaibhav','Goel', false);
        cont3.Community__c = Com_Acc2.id;
        cont3.Participant_Case_Number__c = '45665';
        cont3.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        cont3.rC_Bios__Gender__c = 'Male';
        cont3.rC_Bios__Birth_Day__c = '07';
        cont3.rC_Bios__Birth_Month__c = '07';
        cont3.RecordTypeId = CON_PART_RT;
        lstContacts.add(cont3);
        
        for(Integer i=1; i<15; i++) {
            testcont1 = new Contact(FirstName = 'Rohit', LastName = 'Bhargava ' + String.valueOf(i));
            testcont1.AccountId = acc.Id;
            //testcont1.Community__c = Com_Acc1.id;
            testcont1.Participant_Case_Number__c = '55555';
            testcont1.rC_Sponsorship__Sponsorship_Status__c = 'Available';
            testcont1.rC_Bios__Gender__c = Math.mod(i, 2)==0 ? 'Male' : 'Female';
            testcont1.rC_Bios__Birth_Day__c = String.valueOf(System.today().day());
            testcont1.rC_Bios__Birth_Month__c = String.valueOf(System.today().month());
            testcont1.rC_Bios__Birth_Year__c = String.valueOf(System.today().year()-i);
            testcont1.rC_Sponsorship__Reserve__c = null;
            testcont1.RecordTypeId = CON_PART_RT;
            testcont1.National_Office__c = NO_Acc2.Id;
            lstContacts.add(testcont1);
        }
        insert lstContacts;
      //  Contact ct=[Select ID,RecordType.Name from Contact where RecordTypeId=:CON_PART_RT];
      //  System.assertEquals(ct.RecordType.Name,'temp');
        System.debug('[RB] - ChildInventoryServiceTest.createTestData :: Method End..');
    } // END static void createTestData() {
} // END private class ChildInventoryServiceTest {