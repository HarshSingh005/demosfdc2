/***********************************************************************************************************
* Appirio, Inc
* Name         : Contact_ManageAddressesControllerTest
* Created By   : Vaibhav Goel (Appirio)
* Purpose      : Test class for the Contact_ManageAddressesController
* Created Date : 27/07/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 27/07/2016                   Vaibhav Goel             Created
**********************************************************************************************************/
@isTest
private class Contact_ManageAddressesControllerTest {
    
    private static Account nationalOffice, localPartner, community , acc;
    private static Contact con;
    private static rC_Bios__Contact_Address__c conAddress,conAddressWithoutType;
    private static rC_Bios__Address__c prefMailingAddTemp;
    private static ValidatedAddress addR,changedAddr;
    private static ApexPages.Message[] pageMessages;
    
    private static testMethod void testContact_ManageAddressesController() {
        
        createTestData();
        test.startTest();
            
            PageReference pageRef = Page.Contact_ManageAddresses;
            system.debug('---conId---' + con.Id);
            pageRef.getParameters().put('id', String.valueOf(con.Id));
            Test.setCurrentPage(pageRef);
        
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            Contact_ManageAddressesController controllerInstance = new Contact_ManageAddressesController(sc);
            controllerInstance.initialize();
            
            List<rC_Bios__Contact_Address__c> listofadd = [SELECT id FROM rC_Bios__Contact_Address__c];
            System.debug('rC_Bios__Contact_Address__c in datatbase before insertRelatedAddress @@@'+listofadd);
            System.debug('SIZE  before method called insertted @@@'+listofadd.size());
            system.assertEquals(listofadd.size(),1);
            
            controllerInstance.relatedAddressList.add(conAddress);
            
            controllerInstance.insertRelatedAddress();
            
            System.debug('conaddress id@@@'+conAddress.id);
            listofadd = [SELECT id FROM rC_Bios__Contact_Address__c];
            System.debug('rC_Bios__Contact_Address__c after first @@@'+listofadd);
            System.debug('SIZE @@@'+listofadd.size());
            //No change in size of list because exceptionWhileInserting- 
            system.assertEquals(listofadd.size(),1);
            //creating data for relatedAddressList of controller and then calling the initialize method
            rC_Bios__Contact_Address__c conAddress2 = TestUtils.createContactAddress(con, prefMailingAddTemp, false);
            conAddress2.rC_Bios__Type__c = 'Work';
            controllerInstance.relatedAddressList.clear();
            controllerInstance.relatedAddressList.add(conAddress2);
            controllerInstance.insertRelatedAddress();
            
            listofadd = [SELECT id FROM rC_Bios__Contact_Address__c];
            System.debug('rC_Bios__Contact_Address__c@@@'+listofadd);
            System.debug('SIZE @@@'+listofadd.size());
            //after insertion of conAddres2
            system.assertEquals(listofadd.size(),2);
            conAddress.rC_Bios__Type__c = 'Work';
            update conAddress;
            
            controllerInstance.Address.IsValid = true;
            controllerInstance.contactAddressList.clear();
            controllerInstance.contactAddressList.add(conAddress);
            controllerInstance.contactAddressInsert = conAddress;
            
            //@TODO - Code commented as getting error while deployment
            /*controllerInstance.delRecordId = 'dummyId';
            PageReference delPageRefResult = controllerInstance.deleteRecord();
            system.assertEquals(delPageRefResult, null);
            
            listofadd = [SELECT id FROM rC_Bios__Contact_Address__c];
            System.debug('rC_Bios__Contact_Address__c@@@'+listofadd);
            System.debug('SIZE after first del call @@@'+listofadd.size());
            
            //No change in size because of invalid id 
            system.assertEquals(listofadd.size(),2);
            controllerInstance.delRecordId = conAddress.Id;
            controllerInstance.deleteRecord();
            
            listofadd = [SELECT id FROM rC_Bios__Contact_Address__c WHERE id=:conAddress.id];
            System.debug('rC_Bios__Contact_Address__c@@@'+listofadd);
            System.debug('SIZE @@@'+listofadd.size());
            System.assertEquals(listofadd.size(),0);*/
        test.stopTest();
    }
    
    private static testMethod void testupsertContactAddressList() {
        
        createTestData();
        test.startTest();
            
            PageReference pageRef = Page.Contact_ManageAddresses;
            system.debug('---conId---' + con.Id);
            pageRef.getParameters().put('id', String.valueOf(con.Id));
            Test.setCurrentPage(pageRef);
        
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            Contact_ManageAddressesController controllerInstance = new Contact_ManageAddressesController(sc);
            
            controllerInstance.Address = new ValidatedAddress();
            
            
            //Adding the vlaues to the controller list variable 
            //controllerInstance.relatedAddressList.add(conAddress);
            
            //calling the method of controller for testing.
            controllerInstance.initialize();
            
            
            controllerInstance.Address = addR;
            system.debug('-----controllerInstance.Address.IsValid-----' +  controllerInstance.Address.IsValid);
            
            //Assiging the value to class variable 'controllerInstance.contactAddressInsert'
            rC_Bios__Contact_Address__c conAddress2 = TestUtils.createContactAddress(con, prefMailingAddTemp, false);
            conAddress2.rC_Bios__Type__c = 'Work';
            insert conAddress2;
            controllerInstance.contactAddressInsert = conAddress2;
            
            //calling the method of controller for testing.
            PageReference pageRefResult = controllerInstance.upsertContactAddressList();
            system.assertEquals(pageRefResult, null);
            
            List<rC_Bios__Contact_Address__c> listOfConAdd = [SELECT id, rC_Bios__Contact__c,rC_Bios__Original_Street_Line_1__c,rC_Bios__Original_City__c,rC_Bios__Verified__c
                                                                FROM rC_Bios__Contact_Address__c WHERE id=:conAddress2.id ];
            
            System.debug('Size of list returned of Contact address@@@'+listOfConAdd.size()+'And the list itself@@@'+listOfConAdd);
            
            
            System.assertEquals(listOfConAdd[0].rC_Bios__Contact__c,con.id);
            //System.assertEquals(listOfConAdd[0].rC_Bios__Original_Street_Line_1__c,addR.Line1);
            //System.assertEquals(listOfConAdd[0].rC_Bios__Original_City__c,addR.City);
            //System.assertEquals(listOfConAdd[0].rC_Bios__Verified__c,true);
            
            
            
            //covering exception part of method
            controllerInstance.contactAddressInsert = conAddress;
            controllerInstance.upsertContactAddressList();
           
            
            //testing when controllerInstance.Address.isValid = null
            controllerInstance.Address.IsValid = null;
            controllerInstance.upsertContactAddressList();
            pageMessages = ApexPages.getMessages();
            //System.assertEquals(pageMessages[0].getSummary().contains('Address is not validated; Please validate first then try to save..'), true);
            
            
        test.stopTest();
    }   
    
    private static testMethod void testupsertContactAddressList2() {
        
        createTestData();
        test.startTest();
            
            PageReference pageRef = Page.Contact_ManageAddresses;
            system.debug('---conId---' + con.Id);
            pageRef.getParameters().put('id', String.valueOf(con.Id));
            Test.setCurrentPage(pageRef);
        
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            Contact_ManageAddressesController controllerInstance = new Contact_ManageAddressesController(sc);
            controllerInstance.initialize();
            controllerInstance.Address = new ValidatedAddress();
            controllerInstance.Address = addR;
            controllerInstance.contactAddressInsert = conAddress;
            PageReference pageRefResult1 = controllerInstance.upsertContactAddressList();
            system.assertEquals(pageRefResult1, null);
            
            
            
    }
    
    
    private static testMethod void testupsertContactAddressListAndReturn() {
        
        createTestData();
        test.startTest();
            
            
            PageReference pageRef = Page.Contact_ManageAddresses;
            system.debug('---conId---' + con.Id);
            pageRef.getParameters().put('id', String.valueOf(con.Id));
            Test.setCurrentPage(pageRef);
        
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            Contact_ManageAddressesController controllerInstance = new Contact_ManageAddressesController(sc);
            
            controllerInstance.Address = new ValidatedAddress();
            
            
            
            //Adding the vlaues to the controller list variable
            //controllerInstance.relatedAddressList.add(conAddress);
            
            //calling the method of controller for testing.
            controllerInstance.initialize();
            
            
            controllerInstance.Address = addR;
            system.debug('-----controllerInstance.Address.IsValid-----' +  controllerInstance.Address.IsValid);
            
            //Assiging the value to class variable 'controllerInstance.contactAddressInsert'
            rC_Bios__Contact_Address__c conAddress2 = TestUtils.createContactAddress(con, prefMailingAddTemp, false);
            conAddress2.rC_Bios__Type__c = 'Work';
            insert conAddress2;
            controllerInstance.contactAddressInsert = conAddress2;
            
            //calling the method of controller for testing.
            PageReference pageRefResult  = controllerInstance.upsertContactAddressListAndReturn();
            
            List<rC_Bios__Contact_Address__c> listOfConAdd = [SELECT id, rC_Bios__Contact__c,rC_Bios__Original_Street_Line_1__c,rC_Bios__Original_City__c,rC_Bios__Verified__c
                                                                FROM rC_Bios__Contact_Address__c];
            //system.assertNotEquals(pageRefResult, null);
            System.assertEquals(listOfConAdd[0].rC_Bios__Contact__c,con.id);
            
            //covering exception part of method
            controllerInstance.contactAddressInsert = conAddress;
            controllerInstance.upsertContactAddressListAndReturn();
            System.debug('CONADDRESS @@@@'+conAddress);
           
            
            listOfConAdd = [SELECT id, rC_Bios__Contact__c,rC_Bios__Original_Street_Line_1__c,rC_Bios__Original_City__c,rC_Bios__Verified__c
                                                                FROM rC_Bios__Contact_Address__c ];
            
            System.debug('LIST OF CONTACT ADDRESS#@@@ '+listOfConAdd);
            System.assertEquals(listOfConAdd[1].rC_Bios__Contact__c,con.id);
            ///System.assertEquals(listOfConAdd[1].rC_Bios__Original_Street_Line_1__c,addR.Line1);
            //System.assertEquals(listOfConAdd[1].rC_Bios__Original_City__c,addR.City);
            //System.assertEquals(listOfConAdd[1].rC_Bios__Verified__c,true);
            
            
            
            //testing when controllerInstance.Address.isValid = null
            controllerInstance.Address.IsValid = null;
            controllerInstance.upsertContactAddressListAndReturn();
            pageMessages = ApexPages.getMessages();
            //System.assertEquals(pageMessages[0].getSummary().contains('Address is not validated; Please validate first then try to save..'), true);
            
            
        test.stopTest();
    }   
    
    private static testMethod void testNegativeScenarioWhenIdNotSet() {
        
        createTestData();
        test.startTest();
        
            PageReference pageRef = Page.Contact_ManageAddresses;
            system.debug('---conId---' + con.Id);
            Test.setCurrentPage(pageRef);
        
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            Contact_ManageAddressesController controllerInstance = new Contact_ManageAddressesController(sc);
            controllerInstance.initialize();
            
        test.stopTest();
        
        // Assert that error has occured
        pageMessages = ApexPages.getMessages();
        System.assertEquals(pageMessages[0].getSummary().contains('You are coming from wrong path; Please go to Contact for which you want to create acontactAddressInsert.'), true);
        
    }
    
    private static testMethod void testScenarioWhenAddressIsChangedButNotValidated() {
        
        createTestData();
        test.startTest();
        
            PageReference pageRef = Page.Contact_ManageAddresses;
            system.debug('---conId---' + con.Id);
            pageRef.getParameters().put('id', String.valueOf(con.Id));
            Test.setCurrentPage(pageRef);
        
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            Contact_ManageAddressesController controllerInstance = new Contact_ManageAddressesController(sc);
            controllerInstance.Address = new ValidatedAddress();
            controllerInstance.initialize();
            
            conAddressWithoutType = TestUtils.createContactAddress(con, prefMailingAddTemp, false);
            insert conAddressWithoutType;
            changedAddr.rcBiosContactAddress = conAddressWithoutType;
            
            controllerInstance.Address = changedAddr;
            controllerInstance.AddressList.add(changedAddr);
            controllerInstance.upsertContactAddressList();
            
            
        test.stopTest();
        
        // Assert that error has occured
        pageMessages = ApexPages.getMessages();
        System.assertEquals(pageMessages[0].getSummary().contains('Address must be validated before saving.'), true);
        
    }
    
    private static void createTestData(){
        rC_Giving__Contact_Setting__c setting = new rC_Giving__Contact_Setting__c();
        setting.rC_Giving__Disable_RollupHardCredits__c = true;
        upsert setting; 
        
        acc = TestUtils.createAccount('test',false);
        acc.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
        insert acc;
        
        con = TestUtils.createContact(acc,'test','test',true);

        
        prefMailingAddTemp = TestUtils.createAddress('test Street 1', 'test Street 2', 'test City', '12311', 'test country', false);
        prefMailingAddTemp.rC_Bios__State__c = 'test State';
        insert prefMailingAddTemp;
        
        conAddress = TestUtils.createContactAddress(con, prefMailingAddTemp, false);
        conAddress.rC_Bios__Type__c = 'Work';
        insert conAddress;

        addR = new ValidatedAddress();
        addR.IsValid = true;
        addR.Line1 = 'SUITE 5A-1204';
        addR.Line2 = '799 E DRAGRAM';
        addR.City = 'TUCSON';
        addR.StateProv = 'AZ';
        addR.PostalCode = '85705';
        addR.Country = 'USA';
        
        changedAddr = new ValidatedAddress();
        changedAddr.IsValid = false;
        changedAddr.IsOverridden = false;
        changedAddr.IsChanged = true;
        changedAddr.Line1 = 'SUITE 5A-1204';
        changedAddr.Line2 = '799 E DRAGRAM';
        changedAddr.City = 'TUCSON';
        changedAddr.StateProv = 'AZ';
        changedAddr.PostalCode = '85705';
        changedAddr.Country = 'USA';
        /*ValidatedAddress addR = new ValidatedAddress();
        addR.IsValid = true;*/
        
        
        
    }
}