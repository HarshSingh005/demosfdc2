/***********************************************************************************************************
 * Appirio, Inc
 * Name         : LookupServiceTest
 * Created By   : Jagjeet Singh(Appirio)
 * Purpose      : Test class of LookupService Class
 * Created Date : 04/Mar/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/08/2016                    Jagjeet Singh          Created additional test methods.
 * 04/05/2016                    Jagjeet Singh          Created HouseHoldMatchTest unit test method.
 * 07/21/2016                    Ravi Chauhan           Modified | used TestUtil for Data Creation
 * 08/08/2016                    Ravi Chauhan           Assertions
 * 09/08/2016                    Vaibhav Goel           Added code to cover exception block by forcefully throwing exceptions to ramp up code-coverage.
 * 03/21/2017					 Suminder Singh			Fixed for errors
 **********************************************************************************************************/
@isTest
private class LookupServiceTest {
    Final Static Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id CON_HD_RT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Final Static Id ACC_HH_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    
    static CountriesRefCodes__c refCode1, refCode2;
    static List<StateTerrProvRefCodes__c> stateTerrCodesList;
    static List<WebTitlesRefCodes__c> webTitRefCodeList;
    static List<WebSuffixRefCodes__c> webSuffixRefCodeList;
    
    //method to test the getCountries functionality of lookup Service
    static testMethod void getCountriesTest(){
        //start Test
        Test.StartTest();
        
        //creates the test Data.
        createTestData();
        
        //invoke the lookup service Get Countries Method.
        List<RefCodeInfo> codeList = LookupService.GetCountries();
        
        system.debug('===>codeList' +codeList);
        
        //asserts
        system.assert(codeList.size() > 0);
        system.assert(codeList[0].rvlowvalue == 'IND');
        List<CountriesRefCodes__c> refCodes = [Select Id, Description__c from CountriesRefCodes__c];
        
        refCodes.get(0).Description__c = null;
        List<RefCodeInfo> contInstanceResult =   LookupService.GetCountries();
        
        //throwing exception 
        LookupService.shouldThrowException = true;
        List<RefCodeInfo> exceptionList = LookupService.GetCountries();
        system.assert(exceptionList.size() > 0);
        //exception code ends
        
        //stop Test
        Test.stopTest();
    }
    
    //method to test the getWebCountries functionality of lookup Service
    static testMethod void getWebCountriesTest(){
        //start Test
        Test.StartTest();
        
        //creates the test Data.
        createTestData();
        
        //invoke the lookup service GetWebCountries Method.
        List<RefCodeInfo> codeList = LookupService.GetWebCountries();
        system.debug('===>codeList' +codeList);
        
        //asserts
        system.assert(codeList.size() > 0);
        system.assert(codeList[0].rvlowvalue == 'IND');
        
        //throwing exception 
        LookupService.shouldThrowException = true;
        List<RefCodeInfo> exceptionList = LookupService.GetWebCountries();
        system.assert(exceptionList.size() > 0);
        //exception code ends
        
        //stop Test
        Test.stopTest();
    }
    
    
    //method to test the States functionality of lookup Service
    static testMethod void getStatesTest(){
        //start Test
        Test.StartTest();
        
        //creates the test Data.
        createTestData();
        
        //invoke the lookup service GetStates Method.
        List<CodeInfo> codeList = LookupService.GetStates();
        system.debug('===>codeList' +codeList);
        
        //asserts
        system.assert(codeList.size() > 0);
        system.assert(codeList[0].code == 'RJ');
        
        //throwing exception 
        LookupService.shouldThrowException = true;
        List<CodeInfo> exceptionList = LookupService.GetStates();
        system.assert(exceptionList.size() > 0);
        //exception code ends
        
        //stop Test
        Test.stopTest();
    }
    
    
    
    //method to test the Check for the PrankPhone functionality of lookup Service
    static testMethod void isPrankPhonTest(){
        //start Test
        Test.StartTest();
        
        //creates the test Data.
        createTestData();
        
        //invoke the lookup service Is Prank Phone Method.
        Boolean isPrankPhn = LookupService.IsPrankPhone('909','0909');
        system.debug('===>isPrankPhn' +isPrankPhn);
        
        //asserts
        system.assert(!isPrankPhn);
        
        isPrankPhn = LookupService.IsPrankPhone('804','5551212');
        
        //asserts
        system.assert(isPrankPhn);
        
        //stop Test
        Test.stopTest();
    }
    
    
    
    //method to test the getCurrentPreSponsors functionality of lookup Service
    static testMethod void GetCurrentPresponsorsTest(){
        //start Test
        Test.StartTest();
        
        //creates the test Data.
        createTestData();
        
        //invoke the lookup service GetCurrentPresponsors with a fake contactId.
        Integer spnsrCount = LookupService.GetCurrentPresponsors(00356000003);
        system.debug('===>spnsrCount' +spnsrCount);
        
        //asserts
        system.assert(spnsrCount == 0);
         
        spnsrCount = LookupService.GetCurrentPresponsors(null);
        
        //stop Test
        Test.stopTest();
    }
    
    
    //method to test the getMaxPreSponsors functionality of lookup Service    
    static testMethod void getMaxPresponsorsTest(){
        //start Test
        Test.StartTest();
        
        //invoke the lookup service GetMaxPresponsors .
        Integer getMaxCount1 = LookupService.GetMaxPresponsors();
        system.debug('-----getMaxCount1---' + getMaxCount1);
        
        //create the SponsorshipSetting Org Wide data.
        SponsorshipSettings__c sponSettObj = new SponsorshipSettings__c();
        sponSettObj.Name = 'test';
        sponSettObj.Max_Pre_Sponsors__c = 5;
        insert sponSettObj;
        
        //invoke the lookup service GetMaxPresponsors .
        Integer getMaxCount2 = LookupService.GetMaxPresponsors();
        
        system.assert(getMaxCount2 == 5); 
        
        sponSettObj.Max_Pre_Sponsors__c = null;
        update sponSettObj;
        LookupService.GetMaxPresponsors();
        
        //testing for exception block by forcefully generation exception
        LookupService.shouldThrowException = true;
        Integer exceptionResult = LookupService.GetMaxPresponsors();
        system.assertEquals(exceptionResult, 0);
        //testing for exception block ends 
        
        LookupService.GetMaxPresponsors();
        //stop Test
        Test.stopTest();
    }
    
    
    
    
    //method to test the HouseHoldMatch functionality of lookup Service    
    static testMethod void HouseHoldMatchTest(){
        //start Test
        Test.StartTest();
        createTestData();
        Contact conDb = [select Id,Donor_Number__c,MailingState,MailingStreet,MailingCity,MailingCountry,MailingPostalCode,FirstName,LastName from Contact limit 1];
        
        ContactInfo info = new ContactInfo();
        info.clstnmtitleid = 2;
        info.street1 = conDb.MailingStreet;
        info.city = conDb.MailingCity;
        info.postalcode = conDb.MailingPostalCode;
        info.name = conDb.LastName;
        info.firstname = 'test';
        info.cdesstatprovterrid = 12;
        info.ctrycode = 'IND';
        
        //update the info.Id so that we do not get any house hold record.
        info.Id = 12;
        Envelope env = LookupService.HouseHoldMatch(info);
        //asserts
        //system.assertEquals(106,env.ReturnCode);
        
        info.firstname = conDb.FirstName;
        env = LookupService.HouseHoldMatch(info);
        
        //update the value of Id to the proper Donor Number.
        info.id = Integer.valueOf(conDb.Donor_Number__c);
        
        //invoke the lookup service HouseHoldMatch .
        env = LookupService.HouseHoldMatch(info);       
        info.name = conDb.LastName;
        info.firstname = conDb.FirstName;
        env = LookupService.HouseHoldMatch(info);        
        conDb.MailingState = 'junk stat';
        update conDb;
        
        info.firstname = 'junk name'; 
        info.name = 'junk name';
        env = LookupService.HouseHoldMatch(info);
        
        
        info.name = 'test first name';
        env = LookupService.HouseHoldMatch(info);
        
        
        info.firstName = conDb.FirstName;
        info.name = 'junk Name';
        env = LookupService.HouseHoldMatch(info);
        
        info.firstName = conDb.FirstName;
        info.name = conDb.LastName;
        env = LookupService.HouseHoldMatch(info);
        
        conDb.MailingStreet = 'street1 \n street2';
        update conDb;
        env = LookupService.HouseHoldMatch(info);
        //update the info.Id so that we do not get any house hold record.
        info.Id = 0;
        env = LookupService.HouseHoldMatch(info);
        //asssert
        //system.assertEquals(0, env.ReturnCode);
        
        info.firstname = conDb.FirstName;
        info.name = conDb.LastName;
        info.street1 = conDb.MailingStreet;
        info.city = conDb.MailingCity;
        info.postalCode = conDb.MailingPostalCode;
        conDb.MailingCountry = 'test description';
        conDb.MailingState = 're';
        update conDb;
        
        env = LookupService.HouseHoldMatch(info);
         //asssert
        //system.assertEquals(0, env.ReturnCode);
        Account NO_Acc2 = TestUtils.createAccountWithRT('1st National Account test1',ACC_HH_RT, null, '799', '22246', false);
        //No_Acc2.Routing_Number__c = '666666666';
        insert No_Acc2;
        Contact con = TestUtils.createContact(NO_Acc2, 'test first name1', 'test last name1', false);
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        con.MailingStreet = 'test street1';
        con.MailingCity = 'test City1';
        con.Salutation = 'test salutation1';
        insert con;
        
        info = new ContactInfo();
        info.street1 = con.MailingStreet;
        info.name = con.LastName;
        info.firstname = con.FirstName;
        info.city = con.MailingCity;
        info.Id = 23;
        LookupService.HouseHoldMatch(info);
        
        
        //testing for exception block by forcefully generation exception
        LookupService.shouldThrowException = true;
        env = LookupService.HouseHoldMatch(info);
        system.assertNotEquals(env.ErrorMessage, null);
        //testing for exception block ends 
        
        
        //stop Test
        Test.stopTest();
    }
    
    //method to test the HouseHoldMatchList functionality of lookup Service    
    static testMethod void HouseHoldMatchListTest(){
        //start Test
        String country = '';
        Test.StartTest();
        createTestData();
        Contact conDb = [select Id,Donor_Number__c,MailingState,MailingStreet,MailingCity,MailingCountry,MailingPostalCode,FirstName,LastName from Contact limit 1];
        
        ContactInfo info = new ContactInfo();
        info.clstnmtitleid = 2;
        info.street1 = conDb.MailingStreet;
        info.city = conDb.MailingCity;
        info.postalcode = conDb.MailingPostalCode;
        info.name = conDb.LastName;
        info.firstname = conDb.FirstName;
        info.cdesstatprovterrid = 12;
        info.ctrycode = 'IND';
        info.Id = 12;

        //update the info.Id so that we do not get any house hold record.
        
        List<ContactInfo> coninfo = LookupService.HouseHoldMatchList(info);

        Account NO_Acc2 = TestUtils.createAccountWithRT('1st National Account test1',ACC_HH_RT, null, '799', '22246', false);
        //No_Acc2.Routing_Number__c = '666666666';
        insert No_Acc2;
        Contact con = TestUtils.createContact(NO_Acc2, 'test first name1', 'test last name1', false);
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        con.MailingStreet = 'test street1';
        con.MailingCity = 'test City1';
        con.Salutation = 'test salutation1';
        insert con;
        
        info = new ContactInfo();
        info.street1 = con.MailingStreet;
        info.name = con.LastName;
        info.firstname = con.FirstName;
        info.city = con.MailingCity;
        List<ContactInfo> listCodeInfo = LookupService.HouseHoldMatchList(info);
        
        // Assertion
        System.assertEquals(con.FirstName, listCodeInfo.get(0).firstname);
        
        info.city = null;
        LookupService.HouseHoldMatchList(info);
        
        //testing for exception block by forcefully generation exception
        LookupService.shouldThrowException = true;
        List<ContactInfo> listCodeInfoException = LookupService.HouseHoldMatchList(info);
        system.assertEquals(listCodeInfoException.size(), 0);
        //testing for exception block ends 
        
        Test.stopTest();
    }
    
    //Method Name                   : GetAllCountriesTest
    //Purpose                       : testMethod for method 'GetAllCountries' of class 'LookupService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-493534; T-493527
    //Date                          : May 5,2016
    static testMethod void GetAllCountriesTest(){
        Test.StartTest();
            createTestData();
            List<RefCodeInfo> countriesRefCodesList = LookupService.GetAllCountries();
            system.assertEquals(countriesRefCodesList.get(0).rvlowvalue, refCode1.Name);
            
            //testing for exception block by forcefully generation exception
            LookupService.shouldThrowException = true;
            List<RefCodeInfo> countriesRefCodesListException = LookupService.GetAllCountries();
            system.assertNotEquals(countriesRefCodesListException.size(), 0);
            //testing for exception block ends 
            
        Test.StopTest();
    }
    
    //Method Name                   : GetNationalOfficesTest
    //Purpose                       : testMethod for method 'GetNationalOffices' of class 'LookupService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-493536; T-493527
    //Date                          : May 5,2016
    static testMethod void GetNationalOfficesTest(){
        Test.StartTest();
        
            createTestData();
            Account NO_Acc = [Select Id, name, National_Office_ID__c from Account where name = '1st National Account' limit 1];
            List<NationalOfficeInfo> natOfficeList = LookupService.GetNationalOffices();
            system.assertEquals(natOfficeList.get(0).Id, Integer.ValueOf(NO_Acc.National_Office_ID__c));
            
            //testing for exception block by forcefully generation exception
            LookupService.shouldThrowException = true;
            List<NationalOfficeInfo> natOfficeListException = LookupService.GetNationalOffices();
            system.assertNotEquals(natOfficeListException.size(), 0);
            //testing for exception block ends 
            
        Test.StopTest();
    }
    
    
    
    //Method Name                   : GetNationalOfficeByIdTest
    //Purpose                       : testMethod for method 'GetNationalOfficeById' of class 'LookupService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-493537; T-493527
    //Date                          : May 5,2016
    static testMethod void GetNationalOfficeByIdTest(){
        Test.StartTest();
        
            createTestData();
            Account NO_Acc = [Select Id, name, National_Office_ID__c from Account where name = '1st National Account' limit 1];
            NationalOfficeInfo natOfficeInfoInstance = LookupService.GetNationalOfficeById(Integer.ValueOf(NO_Acc.National_Office_ID__c));
            system.assertEquals(natOfficeInfoInstance.Id, Integer.ValueOf(NO_Acc.National_Office_ID__c));
            
            NationalOfficeInfo natOfficeInfoInstance1 = LookupService.GetNationalOfficeById(1);
            system.assertEquals(natOfficeInfoInstance1, null); //testing for exception block of method.
            
            
        Test.StopTest();
    }
    
    
    
    //Method Name                   : GetStatesAndProvincesTest
    //Purpose                       : testMethod for method 'GetStatesAndProvinces' of class 'LookupService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-493538; T-493527
    //Date                          : May 5,2016
    static testMethod void GetStatesAndProvincesTest(){
        Test.StartTest();
            
            StateTerrProvRefCodes__c stateTerrCodes1 = new StateTerrProvRefCodes__c();
            stateTerrCodes1.Active__c = true;
            stateTerrCodes1.Name = 'US';
            stateTerrCodes1.Description__c = 'test Description 1';
            stateTerrCodes1.Code_Type__c = 'USA';
            stateTerrCodes1.Code__c = 'us';
            insert stateTerrCodes1;
            List<CodeInfo> codeInfoResultList = LookupService.GetStatesAndProvinces();
            system.assertEquals(codeInfoResultList.get(0).Name, stateTerrCodes1.Description__c);
            
            createTestData();
            List<CodeInfo> codeInfoResultList1 = LookupService.GetStatesAndProvinces();
            
            //testing for exception block by forcefully generation exception
            LookupService.shouldThrowException = true;
            List<CodeInfo> codeInfoResultListException = LookupService.GetStatesAndProvinces();
            //testing for exception block ends 
            
        Test.StopTest();
    }
    
    //Method Name                   : GetWebTitlesTest
    //Purpose                       : testMethod for method 'GetWebTitles' of class 'LookupService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-493539; T-493527
    //Date                          : May 5,2016
    static testMethod void GetWebTitlesTest(){
        Test.StartTest();
            
            WebTitlesRefCodes__c webTitRefCode1 = new WebTitlesRefCodes__c();
            webTitRefCode1.Active__c = true;
            webTitRefCode1.Name = '1';
            webTitRefCode1.Description__c = 'test salutation 1';
            insert webTitRefCode1;
            List<CodeInfo> codeInfoResultList1 = LookupService.GetWebTitles();
            system.assertEquals(codeInfoResultList1.get(0).Name, webTitRefCode1.Description__c);
                        
            createTestData();
            List<CodeInfo> codeInfoResultList = LookupService.GetWebTitles();
            
            //testing for exception block by forcefully generation exception
            LookupService.shouldThrowException = true;
            List<CodeInfo> codeInfoResultListException = LookupService.GetWebTitles();
            system.assertNotEquals(codeInfoResultListException.size(), 0);
            //testing for exception block ends
            
        Test.StopTest();
    }
    
    
    //Method Name                   : GetWebSuffixesTest
    //Purpose                       : testMethod for method 'GetWebSuffixes' of class 'LookupService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-493540; T-493527
    //Date                          : May 5,2016
    static testMethod void GetWebSuffixesTest(){
        Test.StartTest();
            
            WebSuffixRefCodes__c webSuffixRefCodeTest = new WebSuffixRefCodes__c();
            webSuffixRefCodeTest.Name = '300';
            webSuffixRefCodeTest.Active__c = true;
            webSuffixRefCodeTest.Description__c = 'Jr.';
            insert webSuffixRefCodeTest;
            
            List<CodeInfo> codeInfoResultList1 = LookupService.GetWebSuffixes();
            system.debug('---codeInfoResultList1--' + codeInfoResultList1);
            system.assert(codeInfoResultList1 != null);
            
            createTestData();
            List<CodeInfo> codeInfoResultList = LookupService.GetWebSuffixes();
            List<WebSuffixRefCodes__c> webSuffixRefAfterInsertList = WebSuffixRefCodes__c.getAll().values();
            
            // Assertions
            System.assertEquals('Jr.', webSuffixRefAfterInsertList.get(0).Description__c);
            
            system.debug('---webSuffixRefAfterInsertList--' + webSuffixRefAfterInsertList);
            system.debug('---webSuffixRefAfterInsertList--' + webSuffixRefAfterInsertList.get(0).Description__c);
            system.debug('---codeInfoResultList--' + codeInfoResultList);
            //system.assertEquals(codeInfoResultList.get(0).Name, webSuffixRefAfterInsertList.get(0).Description__c);
            
            //testing for exception block by forcefully generation exception
            LookupService.shouldThrowException = true;
            List<CodeInfo> codeInfoResultListException = LookupService.GetWebSuffixes();
            system.assertNotEquals(codeInfoResultListException.size(), 0);
            //testing for exception block ends
            
        Test.StopTest();
    }
    
    
    //Method Name                   : GetHearAboutUsTest
    //Purpose                       : testMethod for method 'GetHearAboutUs' of class 'LookupService'
    //@param                        : none
    //@return                       : none
    //Developer name                : Vaibhav Goel
    //Reference                     : T-493541
    //Date                          : May 26,2016
    static testMethod void GetHearAboutUsTest(){
        
        createTestData();
        
        test.startTest();
            
            //craeting test record for custom setting - HearAboutUsRefCodes__c
            HearAboutUsRefCodes__c hearAboutUsRefCodesInstance = new HearAboutUsRefCodes__c();
            hearAboutUsRefCodesInstance.name = 'testCustomSetting';
            hearAboutUsRefCodesInstance.Active__c = true;
            hearAboutUsRefCodesInstance.Description__c = 'testDescription';
            insert hearAboutUsRefCodesInstance;
            
            List<CodeInfo> hearaAboutUsCodesList = LookupService.GetHearAboutUs();
            // Assertion | if hear about us codes are same as we set
            System.assertEquals('testCustomSetting', hearaAboutUsCodesList.get(0).code);
            System.assertEquals('testDescription', hearaAboutUsCodesList.get(0).name);

            LookupService.GetStateAbbreviationFromCode(11);
            LookupService.GetStateCodeFromAbbreviation('IND');
            
            //testing for exception block by forcefully generation exception
            LookupService.shouldThrowException = true;
            List<CodeInfo> hearaAboutUsCodesListException = LookupService.GetHearAboutUs();
            system.assertNotEquals(hearaAboutUsCodesListException.size(), 0);
            //testing for exception block ends
            
            
        test.stopTest();
    }
    
    static testMethod void GetCountryCodeFromAbbreviationTest(){
        createTestData();
        WebSuffixRefCodes__c wsufref=new WebSuffixRefCodes__c();
        wsufref.name='123';
        wsufref.Active__c=true;
        wsufref.Description__c='testdesc';
        insert wsufref;
        
        CountriesRefCodes__c conref=new CountriesRefCodes__c();
        conref.name='01';
        conref.Description__c='IND';
        conref.Code__c='IND';
        insert conref;
        
        WebTitlesRefCodes__c wt=new WebTitlesRefCodes__c();
        wt.Name='123';
        wt.Active__c=true;
        wt.Description__c='desc';
        insert wt;
        
        Campaign cmp=testUtils.createCampaign('testCampaign',false);
        cmp.rC_Giving__Source_Code__c='1234567';
        insert cmp;
        
        Account acc=[Select ID,Alliance__C from ACCOUNT Limit 1];
        test.startTest();
        
        Integer desccrp= LookupService.GetCountryCodeFromAbbreviation(conref.Description__c);
        System.assertEquals(desccrp,01);
        string  gsufcode= LookupService.GetSuffixFromCode(123);
        System.assertEquals(gsufcode,wsufref.Description__c);
        Integer gsufcod=LookupService.GetSuffixCodeFromSuffix('testdesc');
         System.assertEquals(gsufcod,Integer.valueOf(wsufref.Name));
        String  gtfc=LookupService.GetTitleFromCode(123);//need to check 
        System.assertEquals(wt.Description__c,gtfc);
        integer gtcode= LookupService.GetTitleCodeFromTitle(wt.Description__c);
        System.assertEquals(123,gtcode);
        String  FrequencyFromCode1= LookupService.GetPaymentFrequencyFromCode('O');
        System.assertEquals('One Payment', FrequencyFromCode1);
        String  FrequencyFromCode2= LookupService.GetPaymentFrequencyFromCode('M');
        System.assertEquals('Monthly', FrequencyFromCode2);
        String  FrequencyFromCode3= LookupService.GetPaymentFrequencyFromCode('Q');
        System.assertEquals('Quarterly', FrequencyFromCode3);
        String  FrequencyFromCode4= LookupService.GetPaymentFrequencyFromCode('S');
        System.assertEquals('Semi-Annually', FrequencyFromCode4);
        String  FrequencyFromCode5= LookupService.GetPaymentFrequencyFromCode('A');
        System.assertEquals('Annually', FrequencyFromCode5);
        //Fixed for test class errors
        String  pymnt1=LookupService.GetPaymentFrequencyCodeFromFrequency('One Payment');
        System.assertEquals('O', pymnt1);
        String  pymnt2=LookupService.GetPaymentFrequencyCodeFromFrequency('Monthly');
        System.assertEquals('M', pymnt2);
        String  pymnt3=LookupService.GetPaymentFrequencyCodeFromFrequency('Quarterly');
        System.assertEquals('Q', pymnt3);
        String  pymnt4=LookupService.GetPaymentFrequencyCodeFromFrequency('Semi-Annually');
        System.assertEquals('S', pymnt4);
        String  pymnt5=LookupService.GetPaymentFrequencyCodeFromFrequency('Annually');
        System.assertEquals('A', pymnt5);
        Contact con=[Select Id,contact_number__c from contact where contact_number__c!=null];
        Integer donr= LookupService.GetDonorId(con.ID);
        String s = String.valueOF(donr);
        System.assertEquals(con.contact_number__c, s);
        TransactionInfo tinfo=new TransactionInfo();
        List<DonationInfo> Listdinfo=new List<DonationInfo>();
        DonationInfo dinfo=new DonationInfo();
        dinfo.FinCode=1231;
        Listdinfo.add(dinfo);
        tinfo.PurchasedDonations=Listdinfo;
        rC_Giving__GAU__c ggau= TestUtils.createGeneralAccountingUnit('tstGau' , false);
        acc.Alliance__c=true;        
        update acc;
        ggau.Receipt_Category__c='1231';
        ggau.Funding_Source__c=acc.ID;
        insert ggau;
        //Map<integer,rC_Giving__GAU__c> ggaumap=LookupService.GetGAUsByDonations(tinfo);
        //System.assertEquals(ggaumap.values().ID, ggau.ID);
        //Account acc=[Select Id from Account Limit 1];
        
       // rC_Giving__Payment_Method__c paymethd= testUtils.createPaymentMethod('test', 'EFT', true, acc, false);
       // paymethd.rC_Connect__Merchant_Name__c='testMrchnt';
       // insert paymethd;
     //    system.assertEquals(cmp.Source_Code_Autonumber__c, '7679');
     //   ID ids=LookupService.GetCampaignId(Integer.valueOf(cmp.Source_Code_Autonumber__c));
     //   System.assertEquals(ids,cmp.ID);      
        test.stopTest();
    }
    //creates the test data
    static void createTestData(){
        //CountryRefCodes data.
        refCode1 = TestUtils.createCountriesRefCodes('IND',true,'IND',false);
        refCode1.Description__c = 'test description';
        insert refCode1;
        
        //CountryRefCodes data.
        refCode2 = TestUtils.createCountriesRefCodes('USA',true,'IND',false);
        refCode2.Description__c = 'test description 2';
        insert refCode2;
        
        //Partner Country Ref Codes data1.
        PartnerCountriesRefCodes__c partnerRefCodes = TestUtils.createPartnerCountriesRefCodes('CAN',true,'CAN Desc',true);

        //Partner Country Ref Codes data1.
        PartnerCountriesRefCodes__c partnerRefCodes2 = TestUtils.createPartnerCountriesRefCodes('USA',true,'USA Desc',true);

        //create the web account data.
        Account NO_Acc1 = TestUtils.createAccountWithRT('1st National Account', ACC_NO_RT, null, '199', '12245', false);
        NO_Acc1.BillingCountry = 'IN';
        NO_Acc1.Used_On_Web__c = true;
        NO_Acc1.rC_Bios__Active__c = true;
        NO_Acc1.NO_Country__c = 'test description';
        //NO_Acc1.Routing_Number__c = '999999999';
        insert NO_Acc1;
        
        //creates the state territory codes.
        stateTerrCodesList = new List<StateTerrProvRefCodes__c>();
        
        StateTerrProvRefCodes__c stateTerrCodes = TestUtils.createStateTerrProvRefCodes('RJ',true,'11','RJA',false);
        stateTerrCodes.Description__c = 'test Description';
        stateTerrCodesList.add(stateTerrCodes);
        insert stateTerrCodesList;
        
        StateTerrProvRefCodes__c stateTerrCodesAfterInsert = [Select Id, Name, Code__c from StateTerrProvRefCodes__c order by createdDate DESC LIMIT 1];
        
        //creates the Prank Phone data.
        Prank_Phone__c prankPhnObj = TestUtils.createPrankPhone('(804) 555-1212',true);

        Account NO_Acc2 = TestUtils.createAccountWithRT('1st National Account test',ACC_HH_RT, null, '299', '22245', false);
        //No_Acc2.Routing_Number__c = '666666666';
        insert No_Acc2;
        //create the contact data
        Contact con = TestUtils.createContact(NO_Acc2, 'test first name', 'test last name', false);
        con.RecordTypeId = CON_HD_RT;
        con.MailingStreet = 'test street';
        con.MailingCountry = refCode1.Description__c;
        con.MailingCity = 'test City';
        con.MailingState = stateTerrCodesAfterInsert.Code__c;
        con.MailingPostalCode = 'test postal Code';
        con.Salutation = 'test salutation';
        insert con;
        
        webTitRefCodeList = new List<WebTitlesRefCodes__c>();
        WebTitlesRefCodes__c webTitRefCode = TestUtils.createWebTitlesRefCodes('2',true,false);
        webTitRefCode.Description__c = 'test salutation';
        webTitRefCodeList.add(webTitRefCode);
        insert webTitRefCodeList;
        
        webSuffixRefCodeList = new List<WebSuffixRefCodes__c>();
        
        WebSuffixRefCodes__c webSuffixRefCode1 = TestUtils.createWebSuffixRefCodes('301',true,false);
        webSuffixRefCode1.Description__c = 'I';
        webSuffixRefCodeList.add(webSuffixRefCode1);
        
        WebSuffixRefCodes__c webSuffixRefCode2 = TestUtils.createWebSuffixRefCodes('302',true,false);
        webSuffixRefCode2.Description__c = 'Jr.';
        webSuffixRefCodeList.add(webSuffixRefCode2);
        insert webSuffixRefCodeList;
    }

}