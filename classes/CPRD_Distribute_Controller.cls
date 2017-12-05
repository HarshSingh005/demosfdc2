/*******************************************************************************************************************
 * Appirio, Inc
 * Name         : CPRD_Distribute_Controller
 * Created By   :  
 * Purpose      : Controller class of CPRD_Distribute Page
 * Created Date : 12/Apr/2016
 *
 * Date Modified                Modified By             Description of the update
  ------------------------------------------------------------------------------------------------------------------
 * 8.31.2016                    John Hecker				Replaced references to Finance_Origin_Code__c with FOC__c
 * Multiple						Rohit B					apply method for Task T-501837.
 * 11/Nov/2016					Rohit B					Made some changes in method changeDonor for issue I-243574
 * 11/Nov/2016					Rohit B					Made some changes in methods autoSponsor & autoDF for issue I-243573.
 * 15/Nov/2015					Rohit B					Made change in "CPRD_Distribute_Controller". 
														Added a query for recently viewed records.
 * 16/Nov/2016					Rohit B					Made some changes in method "updateBatch_BatchUpload" for I-244239.
 * 17/Nov/2016					Rohit B					Changed logic of getting next open BU record in apply method for I-244234.
 * 03/09/2017                   Suminder Singh          update the apply method as a fix to Issue I-262105
 * 03/21/2017                   Suminder Singh          update the apply method as a fix to Test class failure
 *******************************************************************************************************************/

public with sharing class CPRD_Distribute_Controller {
	public String buID { get; set; }
    public rC_Connect__Batch_Upload__c batchUpload { get; set; }
    public rC_Giving__Batch__c batch { get; set; }
    public List<Payment> payments { get; set; }
    public List<Opportunity> histories { get; set; }
    public Opportunity Opp { get; set; } // Added by Rohit B on 18/Apr/2016 for adding two fields on the page "GAU" & "Amount".
    public String batchUploadsJSON { get; set; }
    public Boolean isVerified { get;set; }
    public Decimal totalAmount;
    public Integer recordNoToDelete { get; set; }
    public Integer recordIndex { get; set; }
	public Boolean isLocked { get; set; } //set true when donor is not defined or batch upload record is committed 
    public String btnSaveAndVerifyName { get;set; }
    String buHCC, buHCCAccountId;
    Final String RT_OPP_TRANSACTION = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    Final String RT_OPP_DONATION = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
	Final String GAU_600_ID = [SELECT Id FROM rC_Giving__GAU__c WHERE Receipt_Category__c = '0600'][0].Id;

	/**
    * @description - class constructor.
	* @parameter - none
    * @return - none
    */
    public CPRD_Distribute_Controller() {
        //initially the verfication will be false
		buID = ApexPages.currentPage().getParameters().get('id');
		//This query is Added by Rohit B on 15/Nov/2015 for make current records recently viewed for issue I-243580.
		Database.query('SELECT Id, Name FROM rC_Connect__Batch_Upload__c Where Id = :buID FOR VIEW');
        init();
        //budRecordsToDelete = new List<Batch_Upload_Distribution__c>();
    }

	/**
    * @description - Method to initialize variables and assigning memory to new variables.
	* @parameter - none
    * @return - none
    */
    //Added by Rohit B on 05/May/2016 to call from contructor of class;
    void init() {
		System.debug('[RB] - CPRD_Distribute_Controller.init :: Method Start..');
		Opp = new Opportunity();
        
		checkVerifiedAndLock();
		payments = new List<Payment>();
		histories = new List<Opportunity>();
        Boolean isRecordFound = getBUDRecords();

        if(!isRecordFound) {
            addPayment();
        }

        changeDonor();
		System.debug('[RB] - CPRD_Distribute_Controller.init :: Method End..');
    } // END public PageReference init() {
    
	/**
    * @description - Method to check whether Batch Upload is verified or not.
	* @parameter - none
    * @return - none
    */
	void checkVerifiedAndLock() {
		isVerified = false;
		isLocked = false;
		btnSaveAndVerifyName = 'Save and Verify';

		batchUpload = [SELECT Id, rC_Connect__Batch_Upload_Batch__r.Id, Amount_Distributed__c, Verification_Status__c, FOC__c, DF_Campaign__c, 
						Amount_Remaining_to_Distribute__c, rC_Connect__HardCreditContact__c, rC_Connect__HardCreditContact__r.AccountId, 
						rC_Connect__Giving_Close_Date__c, rC_Connect__Batch_Upload_Sequence_Number__c, rC_Connect__Giving_Giving_Amount__c, 
						CreatedDate, rC_Connect__HardCreditContact__r.Name, rC_Connect__HardCreditContact__r.Donor_Number__c, 
						rC_Connect__Batch_Upload_Batch__c, rC_Connect__Batch_Upload_Status__c 
						FROM rC_Connect__Batch_Upload__c WHERE Id = :buID];
        System.debug('[RB] - CPRD_Distribute_Controller.checkVerifiedAndLock :: BatchUpload =>' + batchUpload);
        if(batchUpload.Verification_Status__c == 'Verified')
        	isVerified = true;
		
		buHCC = batchUpload.rC_Connect__HardCreditContact__c;
		buHCCAccountId = batchUpload.rC_Connect__HardCreditContact__r.AccountId;
		if(batchUpload.rC_Connect__Batch_Upload_Status__c == 'Committed' || buHCC == null) {
			isLocked = true; 
			//btnSaveAndVerifyName = 'Change Donor';
		}

		batch = [SELECT Id, Batch_Number__c, FOC__c, rC_Connect__Distribution_End_Date__c, rC_Giving__Current_Number__c, 
					rC_Giving__Current_Value__c, rC_Giving__Total_Value__c, rC_Giving__Remaining_Value__c 
					FROM rC_Giving__Batch__c WHERE Id = :batchUpload.rC_Connect__Batch_Upload_Batch__r.Id];
        totalAmount = batch.rC_Giving__Total_Value__c;
        batchUploadsJSON = Json.serialize([SELECT rC_Connect__Batch_Upload_Sequence_Number__c FROM rC_Connect__Batch_Upload__c WHERE rC_Connect__Batch_Upload_Batch__r.Id = :batch.Id ORDER BY rC_Connect__Batch_Upload_Sequence_Number__c]);
	} // END void checkVerifiedAndLock() { 

	/**
    * @description - Method to fetch BUD records on the basis of batch upload id.
	* @parameter - none
    * @return - Boolean
    */
	Boolean getBUDRecords() {
		List<Payment> lstTempPayments = new List<Payment>();
		for(Batch_Upload_Distribution__c BUD : [SELECT Id, Opportunity__c, Opportunity__r.AccountId, Batch_Upload__c, Hard_Credit_Contact__c, 
												Hard_Credit_Contact__r.Name, Hard_Credit_Contact__r.AccountId, Giving_Amount__c, 
                                                Campaign__c, Campaign__r.Name, GAU__c, GAU__r.Name, GAU__r.Receipt_Category__c, Suspense_Reason__c, 
                                                Participant__c, FOC__c, Product_Type__c, Product_Sub_Type__c,  Batch_Number__c,
                                                Participant__r.Child_Number__c, Participant__r.National_Office_Number__c, 
												Participant__r.Community_Number__c, Sequence_Number__c, Close_Date__c, DF_Message__c, 
												Credit__c, Credit_Contact__c, Credit_Contact__r.AccountId, Opportunity__r.Participant__c, 
                                                Credit_Contact__r.Name, Credit_Contact__r.Donor_Number__c, Status__c  
                                                FROM Batch_Upload_Distribution__c WHERE Batch_Upload__c =: batchUpload.Id]) {
            //System.debug('[RB] - CPRD_Distribute_Controller.getBUDRecords :: BUD =>' + BUD);
            Payment payment = new Payment(Opp, BUD);
            payment.campaignName = BUD.Campaign__r.Name;
            //payment.gauName = BUD.GAU__r.Name;
			payment.gauName = BUD.GAU__r.Receipt_Category__c;
            payment.childNumber = BUD.Participant__r.Child_Number__c;
            payment.NationalOfficeNumber = BUD.Participant__r.National_Office_Number__c;
            payment.CommunityNumber = BUD.Participant__r.Community_Number__c;
            lstTempPayments.add(payment);
        } // END for(Batch_Upload_Distribution__c BUD : [SELECT Id...
		if(lstTempPayments.size() > 0) {
			payments = new List<Payment>(lstTempPayments);
			//system.assert(false, '====>' + payments);
			return true;
		}
		else
			return false;
	} // END Boolean getBUDRecords() { 

	/**
    * @description - Method to add one record of Wrapper Class in its list named 'payments'.
	* @parameter - none
    * @return - PageReference
    */
    public PageReference addPayment() { 
        Opportunity opp = new Opportunity();
        Batch_Upload_Distribution__c BUD = new Batch_Upload_Distribution__c(); 
        Payment payment = new Payment(opp, BUD);
        payments.add(payment);
        return null;
    }

	/**
    * @description - Method to fetch opportunities if Donor gets change.
	* @parameter - none
    * @return - PageReference
    */
    public PageReference changeDonor() {
        List<String> rtList = new List<String>{'Transaction'};
        List<String> stageList = new List<String>{'Completed'};
        if (!String.isBlank(batchUpload.rC_Connect__HardCreditContact__c)) {
            histories = [SELECT Date_of_Distribution__c, rC_Giving__Close_Date_Time__c, Amount, Release_Date__c, DFC_Release_Date__c,  
                            rC_Giving__GAU__r.Name, rC_Giving__GAU__r.Receipt_Category__c, rC_Giving__GAU__r.rC_Giving__Description__c, 
                            Participant__r.National_Office_Number__c, Participant__r.Child_Number__c, Participant__r.Community_Number__c 
                            FROM Opportunity 
                            WHERE rC_Giving__Hard_Credit_Contact__c=:batchUpload.rC_Connect__HardCreditContact__c AND 
                            RecordType.Name in :rtList AND StageName in :stageList 
                            Order By CloseDate DESC];
        } else 
			histories = new List<Opportunity>();
		checkVerifiedAndLock();
        return null;
    }
    
	/**
    * @description - Method to fetch value and auto fill the empty fields (Campaign, GAU, Product Type & Sub Type) on the basis of Opportunity change.
	* @parameter - none
    * @return - PageReference
    */
    //updates the related values based on selected opportunity.
    public PageReference updateFieldsOnOppChange() {
        Integer paymentIndex = Integer.ValueOf(Apexpages.currentPage().getParameters().get('paymentIndex')); 
        String OppID = payments[paymentIndex].bud.Opportunity__c;
        //soql query to fetch the GAU From Camapign
        Opportunity oppResult = [select Id, Name, CampaignId, Campaign.Name, Product_Type__c, Product_Sub_Type__c, 
								 rC_Giving__GAU__c, rC_Giving__GAU__r.Name, rC_Giving__GAU__r.Receipt_Category__c 
                                 FROM Opportunity 
                                 WHERE Id = :OppID]; 
        
        if(payments[paymentIndex].bud.Campaign__c==null) {
            payments[paymentIndex].bud.Campaign__c = oppResult.CampaignId;
            payments[paymentIndex].campaignName = oppResult.Campaign.Name;
        }
        if(payments[paymentIndex].bud.GAU__c==null) {
            //payments[paymentIndex].gauName = oppResult.rC_Giving__GAU__r.Name;
			payments[paymentIndex].gauName = oppResult.rC_Giving__GAU__r.Receipt_Category__c;
            payments[paymentIndex].bud.GAU__c = oppResult.rC_Giving__GAU__c;
        }
        if(payments[paymentIndex].bud.Product_Type__c==null) {
            payments[paymentIndex].bud.Product_Type__c = oppResult.Product_Type__c;
            payments[paymentIndex].bud.Product_Sub_Type__c = oppResult.Product_Sub_Type__c;
        }
        if(payments[paymentIndex].bud.Product_Sub_Type__c==null)
            payments[paymentIndex].bud.Product_Sub_Type__c = oppResult.Product_Sub_Type__c;   
        
        return null;
    }

	/**
    * @description - Method to fetch value and auto fill the empty fields (GAU, Product Type & Sub Type) on the basis of Campaign change.
	* @parameter - none
    * @return - PageReference
    */
    //updates the related values based on selected campaign.
    public PageReference updateFieldsOnCampaignSelect() {
        Integer paymentIndex = Integer.ValueOf(Apexpages.currentPage().getParameters().get('paymentIndex')); 
        //system.debug('==>paymentIndex' +paymentIndex);
        system.debug('==>recordIndex' +recordIndex);
        String campaignID = payments[paymentIndex].bud.Campaign__c;
        //soql query to fetch the GAU From Camapign
        Campaign camp = [select Id, Name, rC_Giving__GAU__c, rC_Giving__GAU__r.Name, rC_Giving__GAU__r.Receipt_Category__c, 
						 Product_Type__c, Product_Sub_Type__c
                         FROM Campaign 
                         WHERE Id = :campaignID]; 
        
        //payments[paymentIndex].gauName = camp.rC_Giving__GAU__r.Name;
		payments[paymentIndex].gauName = camp.rC_Giving__GAU__r.Receipt_Category__c;
        payments[paymentIndex].bud.GAU__c = camp.rC_Giving__GAU__c;
        if(payments[paymentIndex].bud.Product_Type__c==null) {
            payments[paymentIndex].bud.Product_Type__c = camp.Product_Type__c;
            payments[paymentIndex].bud.Product_Sub_Type__c = camp.Product_Sub_Type__c;
        }
        if(payments[paymentIndex].bud.Product_Sub_Type__c==null)
            payments[paymentIndex].bud.Product_Sub_Type__c = camp.Product_Sub_Type__c;   
        payments[paymentIndex].bud.Campaign__c = camp.Id;
        payments[paymentIndex].campaignName = camp.Name;
        return null;
    }
    
	/**
    * @description - Method to fetch value and auto fill the empty fields (Product Type & Sub Type) on the basis of GAU change.
	* @parameter - none
    * @return - PageReference
    */
    //Updates the related values based on selected GAU   
    public PageReference updateFieldsOnGAUSelect() {
        Integer paymentIndex = Integer.ValueOf(Apexpages.currentPage().getParameters().get('paymentIndex'));
        system.debug('==>paymentIndex' + paymentIndex);
        String gauID = payments[paymentIndex].bud.GAU__c;
        //soql query to fetch the GAU From Campaign
        rC_Giving__GAU__c gau = [select Id, Name, Receipt_Category__c, Product_Type__c, Product_Sub_Type__c FROM rC_Giving__GAU__c WHERE Id = :gauID];
		system.debug('[RB] - CPRD_Distribute_Controller.updateFieldsOnGAUSelect :: GAU Name => ' + gau.Name);
		//payments[paymentIndex].gauName = gau.Name;
		payments[paymentIndex].gauName = gau.Receipt_Category__c;
		if(gau.Product_Type__c != null && gau.Product_Sub_Type__c != null) {
			payments[paymentIndex].bud.Product_Type__c = gau.Product_Type__c;
			payments[paymentIndex].bud.Product_Sub_Type__c = gau.Product_Sub_Type__c;
        }
        return null;
    }
    
	/**
    * @description - Method to auto Sponsor of Batch Upload Distribution records.
	* @parameter - none
    * @return - PageReference
    */
    //Added by Rohit B on 21/Apr/2016 under task T-492439           --START--
    public PageReference autoSponsor() {
        system.debug('[RB] - CPRD_Distribute_Controller.autoSponsor :: Method Start..');
        List<String> rtList = new List<String>{'Donation'};
        //Added as per Issue I-260453
        //List<String> openStageList = new List<String>{'Open'};
        List<String> activeStageList = new List<String>{'Active'};
        List<String> sponsOppList = new List<String>{'Sponsorship'};
        //List<String> stageList = new List<String>{'Open', 'Active'};
        String hccName = batchUpload.rC_Connect__HardCreditContact__r.Name;
        String hccID = batchUpload.rC_Connect__HardCreditContact__c;
        system.debug('@@@[RB] - CPRD_Distribute_Controller.autoSponsor :: Donor Name => ' + hccName);
       // system.debug('@@@[RB] - CPRD_Distribute_Controller.autoSponsor :: Donor Id => ' + hccID);
        Double oppAmount = Opp.Amount;
        Boolean isAOFound = true;
        List<AggregateResult> lstAR = [SELECT sum(Amount_Owed__c)sumAmt, Count(Id)cntRecords FROM Opportunity WHERE rC_Giving__Hard_Credit_Contact__c = :hccID 
                                    AND RecordType.Name in :rtList AND rC_Sponsorship__Sponsorship_Status__c in :activeStageList AND Product_Type__c IN :sponsOppList];
        if(lstAR.size() < 1 || lstAR[0].get('sumAmt')==Null || lstAR[0].get('sumAmt') == 0) {
            lstAR = [SELECT sum(Monthly_Standard_Pay__c)sumAmt, Count(Id)cntRecords FROM Opportunity WHERE rC_Giving__Hard_Credit_Contact__c = :hccID 
                                    AND RecordType.Name in :rtList AND rC_Sponsorship__Sponsorship_Status__c in :activeStageList AND Product_Type__c IN :sponsOppList];
            isAOFound = false;
        }
        Double sumAmt = (Double)lstAR[0].get('sumAmt');
        Integer cntRecords = (Integer)lstAR[0].get('cntRecords');
        system.debug('[RB] - CPRD_Distribute_Controller.autoSponsor :: sumAmt => ' + sumAmt);
        system.debug('[RB] - CPRD_Distribute_Controller.autoSponsor :: cntRecords => ' + cntRecords);
        
        String query = 'SELECT Id, Name, ' + (isAOFound==true?'Amount_Owed__c':'Monthly_Standard_Pay__c') + ', rC_Giving__Giving_Amount__c, CampaignId, Campaign.Name, ';
        query += 'rC_Giving__GAU__c, rC_Giving__GAU__r.Name, rC_Giving__GAU__r.Receipt_Category__c, Product_Type__c, Product_Sub_Type__c, Participant__c, Participant__r.National_Office_Number__c, ';
        query += 'Participant__r.Child_Number__c, Participant__r.Community_Number__c, rC_Sponsorship__Credited__c, rC_Giving__Hard_Credit_Contact__c ';
        query += 'FROM Opportunity WHERE rC_Giving__Hard_Credit_Contact__c = :hccID '; 
        query += 'AND RecordType.Name in :rtList AND rC_Sponsorship__Sponsorship_Status__c in :activeStageList  AND Product_Type__c IN :sponsOppList';
        
        system.debug('[RB] - CPRD_Distribute_Controller.autoSponsor :: query => ' + query);
        //payments = new List<Payment>();
        for(Opportunity opp : Database.query(query)) {
            Batch_Upload_Distribution__c bud = new Batch_Upload_Distribution__c();
            if(sumAmt == oppAmount)
                if (isAOFound==true)
                    bud.Giving_Amount__c = opp.Amount_Owed__c;
                else
                    bud.Giving_Amount__c = opp.Monthly_Standard_Pay__c;
            else
                bud.Giving_Amount__c = oppAmount/cntRecords;
            bud.Campaign__c = Opp.CampaignId;
            bud.Opportunity__c = Opp.Id;
            bud.GAU__c = Opp.rC_Giving__GAU__c;
            bud.Product_Type__c = Opp.Product_Type__c;
            bud.Product_Sub_Type__c = Opp.Product_Sub_Type__c;
            bud.Participant__c = Opp.Participant__c;
            bud.Credit__c = Opp.rC_Sponsorship__Credited__c;
            bud.Status__c = 'Open';
            Payment payment = new Payment(opp, bud);
            if(opp.rC_Giving__GAU__c != Null) {
                //payment.gauName = opp.rC_Giving__GAU__r.Name;
				payment.gauName = opp.rC_Giving__GAU__r.Receipt_Category__c;
			}
            if(opp.CampaignId != Null)
                payment.campaignName = opp.Campaign.Name;
            if(opp.Participant__c != Null) {
                payment.childNumber = opp.Participant__r.Child_Number__c;
                payment.NationalOfficeNumber = opp.Participant__r.National_Office_Number__c;
                payment.CommunityNumber = opp.Participant__r.Community_Number__c;
            }
            payments.add(payment);
        }
        
        if(payments.size()==0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'No Record Found..'));
            addPayment();
        }
        system.debug('[RB] - CPRD_Distribute_Controller.autoSponsor :: sumAmt => ' + sumAmt);
        system.debug('[RB] - CPRD_Distribute_Controller.autoSponsor :: Method End..');
        return null;
    }
    //Added by Rohit B on 21/Apr/2016 under task T-492439           --END--
    
	/**
    * @description - Method to auto DF of Batch Upload Distribution records.
	* @parameter - none
    * @return - PageReference
    */
    //Added by Rohit B on 21/Apr/2016 under task T-492438           --START--
    public PageReference autoDF() {
        system.debug('[RB] - CPRD_Distribute_Controller.autoDF :: Method Start..');
        List<String> rtList = new List<String>{'Donation'};
        List<String> stageList = new List<String>{'Open', 'Active'};
        List<String> statusList = new List<String>{'Active'};
        String hccName = batchUpload.rC_Connect__HardCreditContact__r.Name;
        String hccID = batchUpload.rC_Connect__HardCreditContact__c;
        Opp.CampaignId = batchUpload.DF_Campaign__c;//Added as per Issue - I-260457
        if (Opp.CampaignId == null || Opp.Amount == null || Opp.Amount == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must first enter an Amount and Campaign..'));
        } 
        else {
            String campId = Opp.CampaignId;
            Double amount = Opp.Amount;         
            
            system.debug('[RB] - CPRD_Distribute_Controller.autoDF :: Donor Name => ' + hccName);
            system.debug('[RB] - CPRD_Distribute_Controller.autoDF :: Donor Id => ' + hccID);
            system.debug('[RB] - CPRD_Distribute_Controller.autoDF :: campId => ' + campId);
            system.debug('[RB] - CPRD_Distribute_Controller.autoDF :: amount => ' + amount);
            Boolean isAOFound = true;
            Integer cntRecords = (Integer)[SELECT count(Id)cntRecords FROM Opportunity WHERE rC_Giving__Hard_Credit_Contact__c = :hccID 
                                        AND RecordType.Name in :rtList AND rC_Sponsorship__Sponsorship_Status__c in :statusList][0].get('cntRecords');
            String query = 'SELECT Id, Name, rC_Giving__Giving_Amount__c, CampaignId, Campaign.Name, ';
            query += 'rC_Giving__GAU__c, Product_Type__c, Product_Sub_Type__c, Participant__c, Participant__r.National_Office_Number__c, ';
            query += 'Participant__r.Child_Number__c, Participant__r.Community_Number__c, rC_Sponsorship__Credited__c, rC_Giving__Hard_Credit_Contact__c ';
            query += 'FROM Opportunity WHERE rC_Giving__Hard_Credit_Contact__c = :hccID '; 
            query += 'AND RecordType.Name in :rtList AND rC_Sponsorship__Sponsorship_Status__c in :statusList';
            
            system.debug('[RB] - CPRD_Distribute_Controller.autoDF :: query => ' + query);
            
            Campaign camp = [SELECT Id, Name, rC_Giving__GAU__c, rC_Giving__GAU__r.Name, rC_Giving__GAU__r.Receipt_Category__c, 
							Product_Type__c, Product_Sub_Type__c 
                            FROM Campaign WHERE Id = :campId];
            //payments = new List<Payment>();
            for(Opportunity Opp : Database.query(query)) {
                Batch_Upload_Distribution__c bud = new Batch_Upload_Distribution__c();
                bud.Opportunity__c = Opp.Id;
                if(amount!=null && cntRecords!=null) {
                    bud.Giving_Amount__c = amount/cntRecords;
                }
                bud.GAU__c = camp.rC_Giving__GAU__c;
                if(amount!=null && cntRecords!=null) {
                    Opp.rC_Giving__Giving_Amount__c = amount/cntRecords;
                }
                Opp.rC_Giving__GAU__c = camp.rC_Giving__GAU__c;
                Opp.CampaignId = campId;
                bud.Campaign__c = campId;
                Opp.Product_Type__c = camp.Product_Type__c;
                Opp.Product_Sub_Type__c = camp.Product_Sub_Type__c;
                bud.Product_Type__c = camp.Product_Type__c;
                bud.Product_Sub_Type__c = camp.Product_Sub_Type__c;
                //Added as per Issue I-260975
                bud.Participant__c = Opp.Participant__c;
                bud.Status__c = 'Open';
                Payment payment = new Payment(Opp, bud);
                //payment.gauName = camp.rC_Giving__GAU__r.Name;
				payment.gauName = camp.rC_Giving__GAU__r.Receipt_Category__c;
                payment.campaignName = camp.Name;
                payment.ChildNumber = Opp.Participant__r.Child_Number__c;
                payment.NationalOfficeNumber = Opp.Participant__r.National_Office_Number__c;
                payment.CommunityNumber = Opp.Participant__r.Community_Number__c;
                payments.add(payment);
            }
        }

        if(payments.size()==0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'No Record Found..'));
            addPayment();
        }
        system.debug('[RB] - CPRD_Distribute_Controller.autoDF :: Method End..');
        return null;
    }
    //Added by Rohit B on 21/Apr/2016 under task T-492438           --END--
    
	/**
    * @description - Method to save values of Batch Upload Distribution records.
	* @parameter - none
    * @return - PageReference
    */
    //Added by Rohit B on 21/Apr/2016 under task T-499186           --START--
    public PageReference saveAll() {
        system.debug('[RB] - CPRD_Distribute_Controller.saveAll :: Method Start..');
        List<Batch_Upload_Distribution__c> lstBUDtoUpsert = new List<Batch_Upload_Distribution__c>();
        Integer rowCount = 0;
		Boolean rowExistsButAmtNull = false;
		List<Integer> rowsSuccessfullNos = new List<Integer>();
		List<Integer> rowsUnsuccessfullNos = new List<Integer>();
		System.debug('[RB] - CPRD_Distribute_Controller.saveAll :: payments => ' + payments);
        for(Payment pay : payments) {
			rowCount++;
            if (pay.bud.Giving_Amount__c != null || pay.BUD.Id != Null) {
                Batch_Upload_Distribution__c bud = pay.BUD;
                if(bud.Id == Null)
                    bud.Batch_Upload__c = batchUpload.Id;
                bud.Hard_Credit_Contact__c = batchUpload.rC_Connect__HardCreditContact__c;
                bud.Batch_Number__c = batch.Batch_Number__c;
                bud.FOC__c = batchUpload.FOC__c;
                bud.Sequence_Number__c = batchUpload.rC_Connect__Batch_Upload_Sequence_Number__c;
                bud.Close_Date__c = batchUpload.rC_Connect__Giving_Close_Date__c;
                bud.Status__c = 'Open';
                lstBUDtoUpsert.add(bud);
				rowsSuccessfullNos.add(rowCount);
				System.debug('[RB] - CPRD_Distribute_Controller.saveAll :: Row No => ' + rowCount + '; Participant => ' + bud.Participant__c);
            }
			else {
				rowExistsButAmtNull = true;
				rowsUnsuccessfullNos.add(rowCount);
			}
        } // END for(Payment pay : payments) {
		System.debug('[RB] - CPRD_Distribute_Controller.saveAll :: Total Row => ' + rowCount + '; lstBUDtoUpsert => ' + lstBUDtoUpsert);
        try {
			Boolean isRecordsUpdated = false;
			if(lstBUDtoUpsert.size() > 0 && isLocked==false) {
                upsert lstBUDtoUpsert;
				isRecordsUpdated = true;
				System.debug('[RB] - CPRD_Distribute_Controller.saveAll :: Batch Upload Distribution Records Saved Successfully.');
			}

			Boolean isDonorChanged = false;
			if(buHCC != batchUpload.rC_Connect__HardCreditContact__c) {
                rC_Connect__Batch_Upload__c bu = batchUpload;
                update bu;
				isDonorChanged = true;
				changeDonor();
            }
			//system.assert(false, 'isLocked = > ' + isLocked );
			if (isRecordsUpdated && isDonorChanged && !rowExistsButAmtNull) 
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Donor has been changed successfully & All rows saved successfully'));
			else if(isRecordsUpdated && !rowExistsButAmtNull) 
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'All rows saved successfully.'));
			else if(isDonorChanged && !rowExistsButAmtNull) 
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Donor has been changed successfully.'));
			else if(rowExistsButAmtNull && isRecordsUpdated && isDonorChanged) 
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Donor has been changed successfully & Row ' + rowsSuccessfullNos +' saved successfully but Rows ' + rowsUnsuccessfullNos +' was not saved because amount is not specified. Please fill amount then try to save.'));
			else if(rowExistsButAmtNull && isRecordsUpdated) 
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Row ' + rowsSuccessfullNos +' saved successfully but Row ' + rowsUnsuccessfullNos +' was not saved because amount is not specified. Please fill amount then try to save.'));
			else if(rowExistsButAmtNull && isDonorChanged) 
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Donor has been changed successfully but Row ' + rowsUnsuccessfullNos +' was not saved because amount is not specified. Please fill amount then try to save.'));
			else if(rowExistsButAmtNull) 
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Row ' + rowsUnsuccessfullNos +' was not saved because amount is not specified. Please fill amount then try to save.'));
			else 
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Something went wrong, please try with some other record if you encounter same error again please contact to developer.'));
			
			checkVerifiedAndLock();
			getBUDRecords();
        }
        catch(Exception ex) {
            System.debug('[RB] - CPRD_Distribute_Controller.saveAll :: Row No => ' + rowCount);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }
        System.debug('[RB] - CPRD_Distribute_Controller.saveAll :: Method End..');
        return null;
    } // END public PageReference saveAll() {
    
	/**
    * @description - method to perform delete whenever it is called on the basis of recordNoToDelete (Index No of record).
	* @parameter 1 - none
    * @return - PageReference
    */
    public PageReference deleteRecord() {
        System.debug('[RB] - CPRD_Distribute_Controller.deleteRecord :: Method Start..');
		
        if(payments[recordNoToDelete].BUD.Id != null) {
			delete payments[recordNoToDelete].BUD;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Record deleted successfully.'));
		}
		
		payments.remove(recordNoToDelete);

		checkVerifiedAndLock();
		getBUDRecords();
        System.debug('[RB] - CPRD_Distribute_Controller.deleteRecord :: Method End..');
        return Null;
    } // END public PageReference deleteRecord() {
    //Added by Rohit B on 21/Apr/2016 under task T-499186           --END--
    
	/**
    * @description - Method to apply funds to Opportunity from Batch Upload Distribution records.
	* @parameter - none
    * @return - PageReference
    */
    //Method added by Rohit B on 02/Jun/2016 to perform apply button logic 
    public PageReference apply() {
        System.debug('[RB] - CPRD_Distribute_Controller.apply :: Method Start..');
        if(isVerified == false) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You must have successful verification before distributing funds.'));
        } else { // When BUD is verified. 
            List<Opportunity> lstOppToUpsert = new List<Opportunity>();
            Set<String> sponsorOpps = new Set<String>();
            Set<String> setAcc = new Set<String>();
            Set<String> setSponsProdSubType = new Set<String>();
            Set<String> setSponsParticipant = new Set<String>();
            Set<String> setSponsHCC = new Set<String>();
            Set<String> setDFParticipant = new Set<String>();
            Set<String> setDFHCC = new Set<String>();
            Map<String, Payment> mapPayment = new Map<String, Payment>();
            System.debug('[RB] - CPRD_Distribute_Controller.apply :: Payments => ' + payments);
            for(Payment pay : payments) {
                String mapKey;
                if(pay.bud.Opportunity__c != null) { // if opportunity field is not blank on BUD then identify which type of opp is.
                    if(pay.bud.Product_Type__c == 'Sponsorship')
                        sponsorOpps.add(pay.bud.Opportunity__c);

					mapKey = pay.bud.Opportunity__c + ';' + pay.bud.Product_Type__c + ';' + 
							pay.bud.Product_Sub_Type__c + ';' + pay.bud.Giving_Amount__c + ';' + 
							pay.bud.Campaign__c + ';' + pay.bud.GAU__c + ';' + pay.bud.Participant__c;
                } else {    //else block if opportunity on BUD is blank then we need to query existing opps on the basis of following fields.
                    if(pay.bud.Product_Type__c == 'Sponsorship') {
                        setSponsProdSubType.add(pay.bud.Product_Sub_Type__c);
                        setSponsParticipant.add(pay.bud.Participant__c);
                        setSponsHCC.add(pay.bud.Hard_Credit_Contact__c);
                        mapKey = pay.bud.Product_Type__c + ';' + pay.bud.Product_Sub_Type__c + ';' + pay.bud.Participant__c + ';' + pay.bud.Hard_Credit_Contact__c;
                    } else if(pay.bud.Product_Type__c == 'Designated Fund') {
                        setDFParticipant.add(pay.bud.Participant__c);
                        setDFHCC.add(pay.bud.Hard_Credit_Contact__c);
                        mapKey = pay.bud.Participant__c + ';' + pay.bud.Hard_Credit_Contact__c;
                    } else  { //We want to created parent opportunity whenever opportunity is found on BAU and type is not sponsorship and DF
						mapKey = pay.bud.Giving_Amount__c + ';' + pay.bud.Campaign__c + ';' + 
								pay.bud.GAU__c + ';' + pay.bud.Product_Type__c + ';' + pay.bud.Product_Sub_Type__c + ';' + 
								pay.bud.Participant__c;
					}
                } // END else {
                mapPayment.put(mapKey, pay);
				setAcc.add(pay.bud.Hard_Credit_Contact__r.AccountId);
            } // END for(Payment pay : payments) {
            System.debug('[RB] - CPRD_Distribute_Controller.apply :: sponsorOpps => ' + sponsorOpps);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: setSponsProdSubType => ' + setSponsProdSubType);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: setSponsParticipant => ' + setSponsParticipant);
            System.debug('[RB] - CPRD_Distribute_Controller.apply :: setSponsHCC => ' + setSponsHCC);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: setDFParticipant => ' + setDFParticipant);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: setDFHCC => ' + setDFHCC);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: mapPayment => ' + mapPayment);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: setAcc => ' + setAcc);

			
			Map<String, rC_Giving__Payment_Method__c> mapAccPM = new Map<String, rC_Giving__Payment_Method__c>();
			if(setAcc.size() > 0 ) {	//we need to query only when setAcc is not empty; This check will save our 1 soql.
				//Fetching Cash/Check payment method against account and Creating map of Account & Cash/Check Payment Method..
				for(rC_Giving__Payment_Method__c pm : [SELECT Id, Name, rC_Giving__Account__c, rC_Giving__Payment_Type__c
														FROM rC_Giving__Payment_Method__c 
														WHERE rC_Giving__Account__c in :setAcc AND rC_Giving__Payment_Type__c = 'Cash/Check']) {
					mapAccPM.put(pm.rC_Giving__Account__c, pm);
				} // END for(rC_Giving__Payment_Method__c pm : [SELECT Id, Name,...
			}
            
            //If Cash/Check payment method doesn't exists on the account then create new one            --START--
            List<rC_Giving__Payment_Method__c> lstPMtoInsert = new List<rC_Giving__Payment_Method__c>();
            for(String accID : setAcc) {
                if(accID != null && !mapAccPM.containsKey(accID)) {
                    rC_Giving__Payment_Method__c pm = new rC_Giving__Payment_Method__c();
                    pm.Name = 'Cash/Check';
                    pm.rC_Giving__Account__c = accID;
                    pm.rC_Giving__Payment_Type__c = 'Cash/Check';
                    pm.rC_Giving__Is_Active__c = true;
                    lstPMtoInsert.add(pm);
                }
            } // END for(String accID : setAcc) {
            System.debug('[RB] - CPRD_Distribute_Controller.apply :: lstPMtoInsert => ' + lstPMtoInsert);
            
			try {
				//Inserting Cash/Check payment method against account if not found any cash/check payment method on the account.
				if(lstPMtoInsert.size()>0) {
					//if(!Test.isRunningTest()){
						insert lstPMtoInsert;
					//}
				} // END if(lstPMtoInsert.size()>0) {
			} Catch(Exception ex) {
				System.debug('[RB] - CPRD_Distribute_Controller.apply :: Error (First Catch) => ' + ex.getMessage());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
				return null;
			}
			
			//Creating map of Account and Cash/Check Payment Method.
            for(rC_Giving__Payment_Method__c pm : lstPMtoInsert) {
                mapAccPM.put(pm.rC_Giving__Account__c, pm);
            }
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: mapAccPM => ' + mapAccPM);
            //If Cash/Check payment method doesn't exists on the account then create new one            --END--

			Map<String, List<Opportunity>> mapSponsOpps = new Map<String, List<Opportunity>>();
            if(sponsorOpps.size() > 0) { //we need to query only when sponsorOpps is not empty; This check will save our 1 soql.
				//Query to update earliest open transaction to Complete with some other details for existing spons. optys
				for(Opportunity opp : [SELECT Id, Name, AccountId, (SELECT Id, Name, Batch_Number__c, FOC__c, Sequence_Number__c, CloseDate, Amount, 
										CampaignId, rC_Giving__GAU__c, Adjustment_Comments__c, Product_Type__c, Product_Sub_Type__c, DFC_Description__c, 
										rC_Giving__Hard_Credit_Contact__c, rC_Giving__Primary_Contact__c, rC_Sponsorship__Sponsorship_Status__c,  
										Participant__c, rC_Giving__Parent__c, RecordTypeId  
										FROM rc_Giving__Opportunities__r WHERE StageName='Open') FROM Opportunity WHERE Id in :sponsorOpps]) {
					if(opp.rc_Giving__Opportunities__r.size() > 0) {
						mapSponsOpps.put(opp.Id, opp.rc_Giving__Opportunities__r);
					} else {
						mapSponsOpps.put(opp.Id, (new List<Opportunity>()));
					}
				} 
			} // END if(sponsorOpps.size() > 0) {
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: mapSponsOpps  => ' + mapSponsOpps);

			Boolean isActive = false;//added as a fix to Issue I-258451
			Map<String, Integer> mapSearchedOppCount = new Map<String, Integer>();
			Map<String, List<Opportunity>> mapSearchedOpps = new Map<String, List<Opportunity>>();
			Map<String, List<Opportunity>> mapSearchedOppTrans = new Map<String, List<Opportunity>>();
			Set<String> setProdSubTypeNext = new Set<String>();
            Set<String> setHCCNext = new Set<String>();
            Set<Decimal> setOppGroupId = new Set<Decimal>();
			if(setSponsProdSubType.size() > 0 || setSponsParticipant.size() > 0 || setSponsHCC.size() > 0) {	//we need to query only when setSponsProdSubType or setSponsParticipant or setSponsHCC is not empty; This check will save our 1 soql.
				//Query on the basis of Prod Type, Prod Sub Type, Participant & HCC for BUD whose opty is blank.
				for(Opportunity opp : [SELECT Id, Name, rC_Sponsorship__Sponsorship_Status__c, Product_Type__c, Product_Sub_Type__c, Participant__c, 
										rC_Giving__Hard_Credit_Contact__c, rC_Sponsorship__Opportunity_Group_Id__c, AccountId, RecordTypeId, 
										(SELECT Id, Name, RecordTypeId, Batch_Number__c, FOC__c, Sequence_Number__c, CloseDate, Amount, rC_Giving__Parent__c, 
										CampaignId, rC_Giving__GAU__c, Adjustment_Comments__c, Product_Type__c, Product_Sub_Type__c, 
										DFC_Description__c, rC_Giving__Hard_Credit_Contact__c, rC_Giving__Primary_Contact__c, 
										rC_Sponsorship__Sponsorship_Status__c, rC_Sponsorship__Opportunity_Group_Id__c, Participant__c 
										FROM rc_Giving__Opportunities__r WHERE StageName='Open' ORDER BY CloseDate ASC) 
										FROM Opportunity 
										WHERE RecordTypeId = :RT_OPP_DONATION AND Product_Type__c = 'Sponsorship' AND 
										Product_Sub_Type__c in :setSponsProdSubType AND Participant__c in: setSponsParticipant AND 
										rC_Giving__Hard_Credit_Contact__c in :setSponsHCC]) {
					String mapKey = opp.Product_Type__c + ';' + opp.Product_Sub_Type__c + ';' + opp.Participant__c + ';' + opp.rC_Giving__Hard_Credit_Contact__c;
					
					if(mapSearchedOppCount.get(mapKey) == null) {
						mapSearchedOppCount.put(mapKey, 1);
						if(opp.rC_Sponsorship__Sponsorship_Status__c != 'Active') {
							setProdSubTypeNext.add(opp.Product_Sub_Type__c);
							setHCCNext.add(opp.rC_Giving__Hard_Credit_Contact__c);
							setOppGroupId.add(opp.rC_Sponsorship__Opportunity_Group_Id__c);
						}
						else{
							isActive = true;//added as a fix to Issue I-258451
						}
					}
					else
						mapSearchedOppCount.put(mapKey, mapSearchedOppCount.get(mapKey)+1);

					if(mapSearchedOpps.get(mapKey) == null) {
						mapSearchedOpps.put(mapKey, (new List<Opportunity> {opp}));
						if(opp.rC_Sponsorship__Sponsorship_Status__c == 'Active') 
							mapSearchedOppTrans.put(mapKey, opp.rc_Giving__Opportunities__r);
					}
					else {
						mapSearchedOpps.get(mapKey).add(opp);
						if(opp.rC_Sponsorship__Sponsorship_Status__c == 'Active') {
							if(mapSearchedOpps.get(mapKey) == null) 
								mapSearchedOppTrans.put(mapKey, opp.rc_Giving__Opportunities__r);
							else if(mapSearchedOppTrans.containsKey(mapKey)) 
								mapSearchedOppTrans.get(mapKey).addAll(opp.rc_Giving__Opportunities__r);
						}
					}
				}
            } // END for(Opportunity opp : [SELECT Id, Name, ...
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: After 2nd step (Opp==null && Type=Sponsorship) :: mapSearchedOppCount  => ' + mapSearchedOppCount);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: After 2nd step (Opp==null && Type=Sponsorship) :: mapSearchedOpps  => ' + mapSearchedOpps);
            
			Set<String> setDFKeyNext = new Set<String>();
			if(setDFParticipant.size() > 0 || setDFHCC.size() > 0) {	//we need to query only when setDFParticipant or setDFHCC is not empty; This check will save our 1 soql.
				//Query sponsorship oppties on the basis of Participant & HCC for BUD whose opty is blank.
				for(Opportunity opp : [SELECT Id, Name, rC_Sponsorship__Sponsorship_Status__c, Product_Type__c, Product_Sub_Type__c, Participant__c, 
										rC_Giving__Hard_Credit_Contact__c, rC_Sponsorship__Opportunity_Group_Id__c, AccountId, RecordTypeId, 
										(SELECT Id, Name, RecordTypeId, Batch_Number__c, FOC__c, Sequence_Number__c, Amount, CampaignId, CloseDate, 
										rC_Giving__GAU__c, Adjustment_Comments__c, Product_Type__c, Product_Sub_Type__c, DFC_Description__c, 
										rC_Giving__Hard_Credit_Contact__c, rC_Giving__Primary_Contact__c, rC_Sponsorship__Sponsorship_Status__c, 
										rC_Sponsorship__Opportunity_Group_Id__c, Participant__c, rC_Giving__Parent__c 
										FROM rc_Giving__Opportunities__r WHERE StageName='Open' ORDER BY CloseDate ASC) 
										FROM Opportunity 
										WHERE RecordTypeId = :RT_OPP_DONATION AND Product_Type__c = :'Sponsorship' AND 
										Participant__c in: setDFParticipant AND rC_Giving__Hard_Credit_Contact__c in :setDFHCC]) {
					String mapKey = opp.Participant__c + ';' + opp.rC_Giving__Hard_Credit_Contact__c;
					
					if(mapSearchedOppCount.get(mapKey) == null) {
						mapSearchedOppCount.put(mapKey, 1);
						if(opp.rC_Sponsorship__Sponsorship_Status__c != 'Active') {
							setProdSubTypeNext.add(opp.Product_Sub_Type__c);
							setHCCNext.add(opp.rC_Giving__Hard_Credit_Contact__c);
							setOppGroupId.add(opp.rC_Sponsorship__Opportunity_Group_Id__c);
							setDFKeyNext.add(opp.rC_Giving__Hard_Credit_Contact__c);
						}
						else{
							isActive = true;//added as a fix to Issue I-258451
						}
					}
					else
						mapSearchedOppCount.put(mapKey, mapSearchedOppCount.get(mapKey)+1);

					if(mapSearchedOpps.get(mapKey) == null) {
						mapSearchedOpps.put(mapKey, (new List<Opportunity> {opp}));
						if(opp.rC_Sponsorship__Sponsorship_Status__c == 'Active')
							mapSearchedOppTrans.put(mapKey, opp.rc_Giving__Opportunities__r);
					}
					else {
						mapSearchedOpps.get(mapKey).add(opp);
						if(opp.rC_Sponsorship__Sponsorship_Status__c == 'Active') {
							if(mapSearchedOpps.get(mapKey) == null) 
								mapSearchedOppTrans.put(mapKey, opp.rc_Giving__Opportunities__r);
							else 
								mapSearchedOppTrans.get(mapKey).addAll(opp.rc_Giving__Opportunities__r);
						}
					}
				}
			}
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: After 2nd step (Opp==null && Type=DF) :: mapSearchedOppCount  => ' + mapSearchedOppCount);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: After 2nd step (Opp==null && Type=DF) :: mapSearchedOpps  => ' + mapSearchedOpps);

			Map<String, List<Opportunity>> mapSponsOpenTrans = new Map<String, List<Opportunity>>();
			Map<String, Integer> mapRepOppCount = new Map<String, Integer>();
			Map<String, List<Opportunity>> mapOpenDFSecond = new Map<String, List<Opportunity>>();
			if(setProdSubTypeNext.size() > 0 || setHCCNext.size() > 0 || setOppGroupId.size() > 0) {
				//Query on the basis of Prod Type, Prod Sub Type, HCC & Opty Grounp Id whose spon. status is Active
				for(Opportunity opp : [SELECT Id, Name, Product_Type__c, Product_Sub_Type__c, Participant__c,  
										rC_Giving__Hard_Credit_Contact__c, RecordTypeId, 
										(SELECT Id, Name, RecordTypeId, Batch_Number__c, FOC__c, Sequence_Number__c, CloseDate, Amount, AccountId, 
										CampaignId, rC_Giving__GAU__c, Adjustment_Comments__c, Product_Type__c, Product_Sub_Type__c, DFC_Description__c, 
										rC_Giving__Hard_Credit_Contact__c, rC_Giving__Primary_Contact__c, rC_Sponsorship__Sponsorship_Status__c, 
										rC_Sponsorship__Opportunity_Group_Id__c, Participant__c, rC_Giving__Parent__c 
										FROM rc_Giving__Opportunities__r WHERE StageName='Open' ORDER BY CloseDate ASC)  
										FROM Opportunity 
										WHERE RecordTypeId = :RT_OPP_DONATION AND Product_Type__c = :'Sponsorship' AND 
										Product_Sub_Type__c in :setProdSubTypeNext AND rC_Giving__Hard_Credit_Contact__c in: setHCCNext AND 
										rC_Sponsorship__Opportunity_Group_Id__c in :setOppGroupId AND rC_Sponsorship__Sponsorship_Status__c='Active']) {
					// We are not maintaining Participant in the below keys because we'll find different participant in many of cases, so it won't match in subsequent processing.
					String mapKeySpons = opp.Product_Type__c + ';' + opp.Product_Sub_Type__c + ';' + opp.rC_Giving__Hard_Credit_Contact__c;
					String mapKeyDF = opp.rC_Giving__Hard_Credit_Contact__c;
					if(opp.rc_Giving__Opportunities__r.size() > 0) {						
						if(mapSearchedOppTrans.get(mapKeySpons) == null) {
							mapSearchedOppTrans.put(mapKeySpons, opp.rc_Giving__Opportunities__r);
						}
						else
							mapSearchedOppTrans.get(mapKeySpons).addAll(opp.rc_Giving__Opportunities__r);
					}

					if(mapRepOppCount.get(mapKeySpons) == null) {
						mapRepOppCount.put(mapKeySpons, 1);
					}
					else
						mapRepOppCount.put(mapKeySpons, mapRepOppCount.get(mapKeySpons)+1);

					if(mapRepOppCount.get(mapKeyDF) == null) {
						mapRepOppCount.put(mapKeyDF, 1);
					}
					else
						mapRepOppCount.put(mapKeyDF, mapRepOppCount.get(mapKeyDF)+1);

					if(setDFKeyNext.contains(mapKeyDF)) {
						if(mapOpenDFSecond.get(mapKeyDF) == null) 
							mapOpenDFSecond.put(mapKeyDF, (new List<Opportunity>{opp}));
						else
							mapOpenDFSecond.get(mapKeyDF).add(opp);
					}
				} // END for(Opportunity opp : [SELECT Id, Name, Product_Type__c...
			}
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: After 3rd step (Opp==null && Type=DF/Spons) :: mapRepOppCount  => ' + mapRepOppCount);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: After 3rd step (Opp==null && Type=DF/Spons) :: mapOpenDFSecond  => ' + mapOpenDFSecond);

			//We are maintaining this map of count against oppId because there may have same opportunity multiple times 
			//on multiple BUD record with the same product type i.e. sponsorship. Well in this case we need to update 
			//open transaction opportunity every time for each BUD record.
			Map<String, Integer> mapOppCount = new Map<String, Integer>();
			Map<String, Opportunity> mapBUDOpportunity = new Map<String, Opportunity>();
			Set<String> setTempOpp = new Set<String>();
			for(Payment pay : payments) { 
                String mapKey;
				String prodType = pay.bud.Product_Type__c;
				String prodSubType = pay.bud.Product_Sub_Type__c;
				String participant = pay.bud.Participant__c;
				String buHCC = pay.bud.Hard_Credit_Contact__c;

				// When Opportunity is not blank on BUD then we need to perform below if logic.
				if(pay.bud.Opportunity__c != null) { 
					String oppID = pay.bud.Opportunity__c;
					mapKey = oppID + ';' + prodType + ';' + prodSubType + ';' + pay.bud.Giving_Amount__c + ';' + 
								pay.bud.Campaign__c + ';' + pay.bud.GAU__c + ';' + participant;

                    if(prodType == 'Sponsorship') {
						Boolean tempOppNotFound = false;
						if(mapOppCount.get(oppID) == null) 
							mapOppCount.put(oppID, 0);
						//Getting open transaction opportunity of Sponsorship opportunity to mark as 'Complete'.
						Opportunity transOpp = setOppValues(RT_OPP_TRANSACTION, mapPayment.get(mapKey).bud);
						// we are running this loop over transaction opportunities because we may have already considered the earliest open transaction for other BUD record
						// thus there will be duplicate earliest open transaction in the list to insert/update
						for(Opportunity txnOpp : mapSponsOpps.get(oppID)) {
							if(!setTempOpp.contains(txnOpp.Id)) {
								transOpp.Id = txnOpp.Id;
								setTempOpp.add(txnOpp.Id);
								transOpp.rC_Giving__Transaction_Type__c = 'Payment';
								transOpp.StageName = 'Completed';
								transOpp.rC_Giving__Parent__c = txnOpp.rC_Giving__Parent__c;
								if(mapPayment.get(mapKey).bud.Credit__c)
									transOpp.rC_Giving__Is_Giving__c = true;
								lstOppToUpsert.add(transOpp);
								mapBUDOpportunity.put(pay.bud.Id, transOpp);
								mapOppCount.put(oppID, mapOppCount.get(oppID)+1);
								tempOppNotFound = true;
								System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp!=null && prodType == Sponsorship && Earliest Trans Opp :: Line No 809.');
								break;
							}
						}
						if(!tempOppNotFound) { // If no open transaction opportunity is found then need to create one complete transaction opportunity.
							Opportunity opp_new = setOppValues(RT_OPP_TRANSACTION, mapPayment.get(mapKey).bud);
							//system.assert(false, '==>' + opp_new);
							opp_new.rC_Giving__Giving_Amount__c = opp_new.Amount;
							opp_new.rC_Giving__is_Completed__c = true;
							opp_new.FOC__c = pay.bud.FOC__c;//Added as a fix to Issue I-262105
							opp_new.StageName = 'Completed';
							//system.assert(false, '===>850 - ' + opp_new.FOC__c);
							opp_new.rC_Giving__Parent__c = oppID;
							if(mapPayment.get(mapKey).bud.Credit__c)
								opp_new.rC_Giving__Is_Giving__c = true;
							lstOppToUpsert.add(opp_new);
							mapBUDOpportunity.put(pay.bud.Id, opp_new);
							System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp!=null && prodType == Sponsorship && New Trans Opp :: Line No 823.');
						}
					} else if(prodType == 'Designated Fund') { //Creating new one time DFs on the basis of existing DF opportunities.
						Opportunity opp_new = setOppValues(RT_OPP_DONATION, mapPayment.get(mapKey).bud);
						opp_new.rC_Giving__Giving_Amount__c = opp_new.Amount;
						opp_new.rC_Giving__Is_Giving_Transaction__c = false; //because we are setting this value true in setOppValues method and we don't want this value to be true on this record.
						opp_new.Batch_Number__c = null;  //we are setting null because this value is being set in "setOppValues" method and we don't want to set this value for this record.
						opp_new.Sequence_Number__c = null;	//we are setting null because this value is being set in "setOppValues" method and we don't want to set this value for this record.
						opp_new.rC_Giving__Is_Giving__c = true;
						opp_new.rC_Giving__Giving_Frequency__c = 'One Payment'; // Update by Niraj 10/13/2016
						opp_new.rC_Giving__is_Completed__c = true;
						opp_new.StageName = 'Open';
						opp_new.Participant__c = pay.bud.Opportunity__r.Participant__c;
						opp_new.DFC_Related_Opportunity__c = oppID;
						lstOppToUpsert.add(opp_new);
						mapBUDOpportunity.put(pay.bud.Id, opp_new);
						System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp!=null && prodType == DF && New Child DF Opp :: Line No 839.');
					} else { //Creating new parent opportunity on the basis of existing opportunities.
						Opportunity opp_new = setOppValues(RT_OPP_DONATION, mapPayment.get(mapKey).bud);
						opp_new.rC_Giving__Giving_Amount__c = opp_new.Amount;
						opp_new.rC_Giving__is_Completed__c = true;
						opp_new.rC_Giving__Giving_Frequency__c = 'One Payment';
						opp_new.StageName = 'Open';
						if(mapPayment.get(mapKey).bud.Credit__c)
								opp_new.rC_Giving__Is_Giving__c = true;
						lstOppToUpsert.add(opp_new);
						mapBUDOpportunity.put(pay.bud.Id, opp_new);
						System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp!=null && prodType != Sponsorship/DF && New Donation Opp :: Line No 850.');
					}
                } // END if(pay.bud.Opportunity__c != null) { 
				System.debug('[RB] - CPRD_Distribute_Controller.apply :: After 1st step In Loop (Opp!=null) :: mapBUDOpportunity  => ' + mapBUDOpportunity);
				// When Opportunity is null on BUD then we need to perform below if logic.
                if(pay.bud.Opportunity__c == null) {
					if(prodType == 'Sponsorship' || prodType == 'Designated Fund') {
						String mapKeyNonParticipant; 
						if(prodType == 'Sponsorship') {
							mapKey = prodType + ';' + prodSubType + ';' + participant + ';' + buHCC;
							mapKeyNonParticipant = prodType + ';' + prodSubType + ';' + buHCC;
						}
						else {
							mapKey = participant + ';' + buHCC;
							mapKeyNonParticipant = buHCC;
						}
						System.debug('[RB] - CPRD_Distribute_Controller.apply :: In 2nd step In Loop (Opp==null) :: mapKey  => ' + mapKey);
						System.debug('[RB] - CPRD_Distribute_Controller.apply :: In 2nd step In Loop (Opp==null) :: mapKeyNonParticipant  => ' + mapKeyNonParticipant);
						System.debug('[RB] - CPRD_Distribute_Controller.apply :: In 2nd step In Loop (Opp==null) :: mapSearchedOppCount.get(mapKey)  => ' + mapSearchedOppCount.get(mapKey));
						System.debug('[RB] - CPRD_Distribute_Controller.apply :: In 2nd step In Loop (Opp==null) :: mapRepOppCount.get(mapKeyNonParticipant)  => ' + mapRepOppCount.get(mapKeyNonParticipant));
						//This below condition checking is for whether we found No/multiple opportunity in primary search
						Boolean isNoOrMultipleOppFound = (mapSearchedOppCount.get(mapKey) == null || (mapSearchedOppCount.get(mapKey) != null && mapSearchedOppCount.get(mapKey) > 1));
						//This below condition is for whether we found No/multiple opportunity in search of replacement opportunity (second search).
						//updated as a fix to Issue I-258451
						Boolean isNoOrMultipleRepOppFound = (mapSearchedOppCount.get(mapKey) != null && mapSearchedOppCount.get(mapKey) == 1 && !isActive && (mapRepOppCount.get(mapKeyNonParticipant) == null || (mapRepOppCount.get(mapKeyNonParticipant) != null && mapRepOppCount.get(mapKeyNonParticipant) > 1)));
						System.debug('[RB] - CPRD_Distribute_Controller.apply :: In 2nd step In Loop (Opp==null) :: isNoOrMultipleOppFound  => ' + isNoOrMultipleOppFound);
						System.debug('[RB] - CPRD_Distribute_Controller.apply :: In 2nd step In Loop (Opp==null) :: isNoOrMultipleRepOppFound  => ' + isNoOrMultipleRepOppFound);
						// When we found no/multiple opportunities for both Sponsorship & DF Type on the basis of search criteria
						if(isNoOrMultipleOppFound || isNoOrMultipleRepOppFound) { 
							Opportunity oneTimeOpp = setOppValues(RT_OPP_DONATION, mapPayment.get(mapKey).bud);
							oneTimeOpp.rC_Giving__GAU__c = GAU_600_ID;
							oneTimeOpp.rC_Giving__Giving_Amount__c = oneTimeOpp.Amount;
							oneTimeOpp.rC_Giving__Is_Giving__c = true;
							oneTimeOpp.rC_Giving__is_Completed__c = true;
							oneTimeOpp.Product_Type__c = 'One Time Gift';
							oneTimeOpp.Product_Sub_Type__c = 'Standard';
							oneTimeOpp.rC_Giving__Giving_Frequency__c = 'One Payment';
							oneTimeOpp.rC_Giving__Transaction_Type__c = 'Payment';
							oneTimeOpp.StageName = 'Completed'; 
							lstOppToUpsert.add(oneTimeOpp);
							//system.assert(false, '===> 923 - '  + mapRepOppCount + '===2' + mapKeyNonParticipant);
							mapBUDOpportunity.put(pay.bud.Id, oneTimeOpp);
							System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp==null && prodType == Sponsorship/DF && Multiple/No Opp Found :: New Donation Opp (600) :: Line No 890.');
						} else { // When we found only 1 Active/Inactive opportunity for Sponsorship/DF type.
							System.debug('[RB] - CPRD_Distribute_Controller.apply :: In 2nd step In Loop (Opp==null) :: mapSearchedOppCount.get(mapKey)  => ' + mapSearchedOppCount.get(mapKey));
							System.debug('[RB] - CPRD_Distribute_Controller.apply :: In 2nd step In Loop (Opp==null) :: mapSearchedOpps.get(mapKey)  => ' + mapSearchedOpps.get(mapKey));
							if(mapOppCount.get(mapKey) == null) 
								mapOppCount.put(mapKey, 0);
							//We are checking condition whether we found 1 active opportunity or not.
							if(mapSearchedOpps.size() == 1 && mapSearchedOpps.get(mapKey)[0].rC_Sponsorship__Sponsorship_Status__c == 'Active') {
								if(prodType == 'Sponsorship') { // When we found only 1 active opportunity for Sponsorship Type on the basis of search criteria
									Boolean tempOppNotFound = false;
									Opportunity OppToUpdateCreate = setOppValues(RT_OPP_TRANSACTION, mapPayment.get(mapKey).bud);
									OppToUpdateCreate.StageName = 'Completed';
									//system.assert(false, '===>935 - ');
									// If we found open transaction then we need to update found opportunity.
									//if(mapSearchedOpps.get(mapKey).size() > mapOppCount.get(mapKey)) {
										// we are running this loop over transaction opportunities because we may have already considered the earliest open transaction for other BUD record
										// thus there will be duplicate earliest open transaction in the list to insert/update
										for(Opportunity txnOpp : mapSearchedOppTrans.get(mapKey)) {
											if(!setTempOpp.contains(txnOpp.Id)) {
												OppToUpdateCreate.Id = txnOpp.Id;
												OppToUpdateCreate.RecordTypeId = txnOpp.RecordTypeId;
												OppToUpdateCreate.rC_Giving__Parent__c = txnOpp.rC_Giving__Parent__c;
												if(mapPayment.get(mapKey).bud.Credit__c)
													OppToUpdateCreate.rC_Giving__Is_Giving__c = true;
												setTempOpp.add(txnOpp.Id);
												mapOppCount.put(mapKey, mapOppCount.get(mapKey)+1);
												tempOppNotFound = true;
												System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp==null && prodType == Sponsorship && 1 Active Opp Found :: Earliest Trans Opp :: Line No 915.');
												break;
											}	
										}
									//} 
									if(!tempOppNotFound) {
										OppToUpdateCreate.rC_Giving__Transaction_Type__c = 'Payment';
										OppToUpdateCreate.rC_Giving__Is_Giving__c = true;
										OppToUpdateCreate.rC_Giving__Parent__c = mapSearchedOpps.get(mapKey)[0].Id;
										System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp==null && prodType == Sponsorship && 1 Active Opp Found :: New Trans Opp :: Line No 923.');
									}

									lstOppToUpsert.add(OppToUpdateCreate); 
									mapBUDOpportunity.put(pay.bud.Id, OppToUpdateCreate);
								} else { // When we found only 1 active opportunity for DF Type on the basis of search criteria
									Opportunity oneTimeDFOpp = setOppValues(RT_OPP_DONATION, mapPayment.get(mapKey).bud);
									oneTimeDFOpp.DFC_Related_Opportunity__c = mapSearchedOpps.get(mapKey)[0].Id;
									oneTimeDFOpp.rC_Giving__Giving_Amount__c = oneTimeDFOpp.Amount;
									oneTimeDFOpp.rC_Giving__is_Completed__c = true;
									oneTimeDFOpp.StageName = 'Completed';
									oneTimeDFOpp.rC_Giving__Giving_Frequency__c = 'One Payment';
									if(mapPayment.get(mapKey).bud.Credit__c)
										oneTimeDFOpp.rC_Giving__Is_Giving__c = true;
									lstOppToUpsert.add(oneTimeDFOpp);
									mapBUDOpportunity.put(pay.bud.Id, oneTimeDFOpp);
									System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp==null && prodType == DF && 1 Active Opp Found :: New Child DF Opp :: Line No 939.');
								}
							} else { // This else is for 1 Inactive opportunity for Sponsorship/DF Type on the basis of search criteria.
								if(prodType == 'Sponsorship') { // When we found only 1 Inactive opportunity for Sponsorship Type on the basis of search criteria
									Boolean tempOppNotFound = false;
									Opportunity OppToUpdateCreate = setOppValues(RT_OPP_DONATION, mapPayment.get(mapKey).bud);
									String tempKey = prodType + ';' + prodSubType + ';' + buHCC;
									if(mapSearchedOppTrans.get(tempKey) != null && mapSearchedOppTrans.get(tempKey).size() > mapOppCount.get(mapKey)) {
										// we are running this loop over transaction opportunities because we may have already considered the earliest open transaction for other BUD record
										// thus there will be duplicate earliest open transaction in the list to insert/update
										for(Opportunity txnOpp : mapSearchedOppTrans.get(tempKey)) {
											if(!setTempOpp.contains(txnOpp.Id)) {
												OppToUpdateCreate.Id = txnOpp.Id;
												OppToUpdateCreate.RecordTypeId = txnOpp.RecordTypeId;
												OppToUpdateCreate.Participant__c = txnOpp.Participant__c;
												OppToUpdateCreate.StageName = 'Completed';
												//system.assert(false, '===>990 - ');
												if(mapPayment.get(mapKey).bud.Credit__c)
													OppToUpdateCreate.rC_Giving__Is_Giving__c = true;
												setTempOpp.add(txnOpp.Id);
												mapOppCount.put(mapKey, mapOppCount.get(mapKey)+1);
												tempOppNotFound = true;
												System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp==null && prodType == Sponsorship && 1 InActive Opp Found :: Earliest Trans Opp :: Line No 960.');
												break;
											}
										}
									} 
									if(!tempOppNotFound) {
										OppToUpdateCreate.RecordTypeId = RT_OPP_DONATION;
										OppToUpdateCreate.rC_Giving__GAU__c = GAU_600_ID;
										OppToUpdateCreate.rC_Giving__Is_Giving__c = true;
										OppToUpdateCreate.rC_Giving__Giving_Amount__c = OppToUpdateCreate.Amount;
										OppToUpdateCreate.Product_Type__c = 'One Time Gift';
										OppToUpdateCreate.Product_Sub_Type__c = 'Standard';
										OppToUpdateCreate.rC_Giving__Transaction_Type__c = 'Payment';
										OppToUpdateCreate.StageName = 'Completed';
										OppToUpdateCreate.rC_Giving__is_Completed__c = true;
										OppToUpdateCreate.rC_Giving__Giving_Frequency__c = 'One Payment';
										//system.assert(false, '===> 1015');
										System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp==null && prodType == Sponsorship && No Active Opp Found :: New Donation Opp (600) :: Line No 976.');
									}
									
									lstOppToUpsert.add(OppToUpdateCreate);
									mapBUDOpportunity.put(pay.bud.Id, OppToUpdateCreate);
								} else { // When we found only 1 Inactive opportunity for DF Type on the basis of search criteria

									Opportunity Opp_new = setOppValues(RT_OPP_DONATION, mapPayment.get(mapKey).bud);
									String tempKey = buHCC;
									if(mapOpenDFSecond.get(tempKey) != null && mapOpenDFSecond.get(tempKey).size() > mapOppCount.get(mapKey)) {
										Opp_new.DFC_Related_Opportunity__c = mapOpenDFSecond.get(tempKey)[mapOppCount.get(mapKey)].Id;
										Opp_new.Participant__c = mapOpenDFSecond.get(tempKey)[mapOppCount.get(mapKey)].Participant__c;
										mapOppCount.put(mapKey, mapOppCount.get(mapKey)+1);
										System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp==null && prodType == DF && 1 InActive Opp Found :: New Child DF Opp :: Line No 989.');
									} else {
										Opp_new.rC_Giving__GAU__c = GAU_600_ID;
										Opp_new.rC_Giving__is_Completed__c = true;
										Opp_new.Product_Type__c = 'One Time Gift';
										Opp_new.Product_Sub_Type__c = 'Standard';
										//system.assert(false, '===> 1035');
										System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp==null && prodType == DF && No Active Opp Found :: New Child DF Opp :: Line No 995.');
									}
									Opp_new.rC_Giving__Giving_Amount__c = Opp_new.Amount;
									Opp_new.rC_Giving__Transaction_Type__c = 'Payment';
									Opp_new.StageName = 'Completed';
									Opp_new.rC_Giving__Giving_Frequency__c = 'One Payment';
									Opp_new.rC_Giving__Is_Giving__c = true;

									lstOppToUpsert.add(Opp_new);
									mapBUDOpportunity.put(pay.bud.Id, Opp_new);
								}
							} // END else { // This else is for 1 Inactive opportunity for Sponsorship/DF Type on the basis of search criteria.
						} // END else { // When we found only 1 Active/Inactive opportunity for Sponsorship/DF type.
					} else { // If Type is other then Sponsorship & DF, then we need to create new Donation opty.
						mapKey = pay.bud.Giving_Amount__c + ';' + pay.bud.Campaign__c + ';' + 
								pay.bud.GAU__c + ';' + prodType + ';' + prodSubType + ';' + participant;
						Opportunity opp_new = setOppValues(RT_OPP_DONATION, mapPayment.get(mapKey).bud);
						opp_new.rC_Giving__Giving_Amount__c = opp_new.Amount;
						opp_new.rC_Giving__is_Completed__c = true;
						opp_new.rC_Giving__Giving_Frequency__c = 'One Payment';
						opp_new.StageName = 'Open';
						if(mapPayment.get(mapKey).bud.Credit__c)
							opp_new.rC_Giving__Is_Giving__c = true;
						lstOppToUpsert.add(opp_new);
						mapBUDOpportunity.put(pay.bud.Id, opp_new);
						System.debug('[RB] - CPRD_Distribute_Controller.apply :: Opp== null && prodType != Sponsorship/DF && New Donation Opp :: Line No 1020.');
					}
				} // END if(pay.bud.Opportunity__c == null) {
				System.debug('[RB] - CPRD_Distribute_Controller.apply :: After 2nd step In Loop (Opp==null) :: mapBUDOpportunity  => ' + mapBUDOpportunity);
			} // END for(Payment pay : payments) { 

			for(Opportunity opp : mapBUDOpportunity.values()) {
				String accID = opp.AccountId;
				if(accID != null) {
					if(mapAccPM.get(accID) != null && mapAccPM.get(accID).rC_Giving__Payment_Type__c != null){
						opp.rC_Giving__Payment_Method__c = mapAccPM.get(accID).rC_Giving__Payment_Type__c;
					}
					if(mapAccPM.get(accID) != null && mapAccPM.get(accID).Id != null){
						opp.rC_Giving__Payment_Method_Selected__c = mapAccPM.get(accID).Id;
					}
				}	
			}
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: Final :: lstOppToUpsert =>' + lstOppToUpsert);
			System.debug('[RB] - CPRD_Distribute_Controller.apply :: Final :: mapBUDOpportunity =>' + mapBUDOpportunity);

			//We are saving SavePoint because we want to rollback whole operation if any of DML operation fails.
			System.SavePoint trans = database.setSavepoint();
            try {
                if(mapBUDOpportunity.values().size()>0) {
					System.debug('[RB] - CPRD_Distribute_Controller.apply :: Upsertion Starts...');
                    upsert mapBUDOpportunity.values();
					//system.assert(false, '[RB] - CPRD_Distribute_Controller.apply :: After upsert mapBUDOpportunity.values() => ' + mapBUDOpportunity.values());
					
					setBatch_SequenceNumber(mapBUDOpportunity.values());
					System.debug('[RB] - CPRD_Distribute_Controller.apply :: After updating Batch Number, Sequence NsetBatch_SequenceNumber, etc..');

					insertSoftCredit(mapBUDOpportunity);
					System.debug('[RB] - CPRD_Distribute_Controller.apply :: After insert lstCredit..');

					updateBatch_BatchUpload();
					System.debug('[RB] - CPRD_Distribute_Controller.apply :: After update Batch Upload Distribution records..');

					//Changed the logic of getting next open BU record on 17/Nov/2016 for issue I-244234		--START--
					String currSEQNo = batchUpload.rC_Connect__Batch_Upload_Sequence_Number__c;
					String queryNextBU = 'SELECT Id, Name, rC_Connect__Batch_Upload_Status__c, rC_Connect__Batch_Upload_Sequence_Number__c ' +
										' FROM rC_Connect__Batch_Upload__c ' +
										' WHERE rC_Connect__Batch_Upload_Batch__c = \'' + batchUpload.rC_Connect__Batch_Upload_Batch__c + '\' AND ' +
										' rC_Connect__Batch_Upload_Status__c != \'Committed\' ORDER BY rC_Connect__Batch_Upload_Sequence_Number__c';
					//Querying next Batch Upload record Whose status id not committed
					String nextBUId = '';
					Boolean gotFirstOpenBU = false;
					Boolean gotNextOpenBU = false;
					//I'm maintaining this list because I need to access next record in line, 
					//if I put directly in loop then I won't be able to fetch next record.
					List<rC_Connect__Batch_Upload__c> openBUs = Database.query(queryNextBU);
					Integer i = 0;
					for(rC_Connect__Batch_Upload__c bu : openBUs) {
						i++;	//to fetch next BU record in line.
						if(!gotFirstOpenBU) {
							nextBUId = bu.Id;
							gotFirstOpenBU = true;
						}
						if(bu.rC_Connect__Batch_Upload_Sequence_Number__c == currSEQNo && !gotNextOpenBU) {
							if(i < openBUs.size()) {
								nextBUId = openBUs[i].Id;
								gotNextOpenBU = true;
								break;
							}
						}
					}

					String nextURL;
					if(nextBUId != '')
						nextURL = '/apex/CPRD_Distribute?id=' + nextBUId;
					else 
						nextURL = '/apex/CPRD_Distribute?id=' + batchUpload.Id;
					//Changed the logic of getting next open BU record on 17/Nov/2016 for issue I-244234		--END--

					System.debug('[RB] - CPRD_Distribute_Controller.apply :: nextURL => ' + nextURL);
					System.debug('[RB] - CPRD_Distribute_Controller.apply :: All Done..');
					
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'All records has been committed successfully..'));
					
					PageReference nextPegRef = new PageReference(nextURL);
					nextPegRef.setRedirect(true);
					return nextPegRef;
                } // END if(mapBUDOpportunity.values().size()>0) {
				else {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No record is found to update..'));
				}
            } // END try {
            catch(Exception ex) {
                System.debug('[RB] - CPRD_Distribute_Controller.apply :: Line No => ' + ex.getLineNumber() + '; Error => ' + ex.getMessage());
				database.rollback(trans);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
            } // END catch(Exception ex) {
            system.debug('[RB] - CPRD_Distribute_Controller.apply :: Method End..');
        } // END else { // When BUD is verified. 
        return null;
    } // END public PageReference apply() {

	/**
    * @description - Method to assigning value from passed value in parameters to new opportunity. Called from apply method.
	* @parameter 1 - recTypeID : Recordtype of New opportunity. 
	* @parameter 2 - bud : Batch Upload Distribution record whose value we are going to assign to new Opty. 
    * @return - Opportunity
    */
    //Common mapping of opportunity & batch distribution upload (bud). Method is being used in "apply" method.
    Opportunity setOppValues(String recTypeID, Batch_Upload_Distribution__c bud) {
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = recTypeID;
        opp.Batch_Number__c = bud.Batch_Number__c;  
		opp.Sequence_Number__c = bud.Sequence_Number__c;
		if(bud.FOC__c != null)      
			opp.FOC__c = bud.FOC__c;
		if(bud.Close_Date__c != null)
			opp.CloseDate = bud.Close_Date__c;
		else 
			opp.CloseDate = System.today();
		if(bud.Giving_Amount__c != null) {
			opp.Amount = bud.Giving_Amount__c;
		}
		else { 
			opp.Amount = 0;
		}
		if(bud.Participant__c != null)
			opp.Participant__c = bud.Participant__c;
		opp.AccountId = bud.Hard_Credit_Contact__r.AccountId;
        opp.CampaignId = bud.Campaign__c;
        opp.rC_Giving__GAU__c = bud.GAU__c;
		if(bud.Suspense_Reason__c != '' && bud.Suspense_Reason__c != null)
			opp.Adjustment_Comments__c = bud.Suspense_Reason__c;
		/*else 
			opp.Adjustment_Comments__c = null;*/
        opp.Product_Type__c = bud.Product_Type__c;
        opp.Product_Sub_Type__c = bud.Product_Sub_Type__c;
		if(bud.DF_Message__c !='' && bud.DF_Message__c != null)
			opp.DFC_Description__c = bud.DF_Message__c;
		/*else
			opp.DFC_Description__c = null;*/
		if(bud.Hard_Credit_Contact__c != null)
			opp.rC_Giving__Hard_Credit_Contact__c = bud.Hard_Credit_Contact__c;
		if(bud.Hard_Credit_Contact__c != null)
			opp.rC_Giving__Primary_Contact__c = bud.Hard_Credit_Contact__c;
        opp.rC_Giving__Is_Giving_Transaction__c = true;
		//opp.rC_Giving__is_Completed__c = true;
		if(bud.Giving_Amount__c != null)
			opp.Remaining_Non_Adjusted__c = bud.Giving_Amount__c;
		else 
			opp.Remaining_Non_Adjusted__c = 0;
        return opp;
    } // END Opportunity setOppValues(String recTypeID, Batch_Upload_Distribution__c bud) {

	/**
    * @description - Method to query transaction records of newly inserted DF or Suspense GAU (600) records and set Batch & Sequence Number on them. Called from 'apply' method.
	* @parameter 1 - lstOpps : List of newly inserted DF Opps.
    * @return - void
    */
	void setBatch_SequenceNumber(List<Opportunity> lstOpps) {
		//system.assert(false, '====>' + lstOpps);
		System.debug('[RB] - CPRD_Distribute_Controller.setBatch_SequenceNumber :: Method Start..');
		Set<Opportunity> setOpps = new Set<Opportunity>();
		//Considering newly inserted DF or Suspense GAU (600) Opportunities to set Batch & Sequence Number, FOC and other details to their transactions
		for(Opportunity opp : lstOpps) {
			if(opp.Product_Type__c== 'Designated Fund' || opp.rC_Giving__GAU__c == GAU_600_ID) { 
				setOpps.add(opp);
			}
		}
		System.debug('[RB] - CPRD_Distribute_Controller.setBatch_SequenceNumber :: setOpps => ' + setOpps);
		List<Opportunity> lstTransOppToUpdate = new List<Opportunity>();
		if(setOpps.size() > 0) {
			for(Opportunity opp : [SELECT Id, rC_Giving__Parent__r.rC_Giving__Giving_Amount__c, rC_Giving__Parent__r.FOC__c, 
									rC_Giving__Parent__r.DFC_Description__c, Batch_Number__c, Sequence_Number__c, StageName 
									FROM Opportunity
									WHERE rC_Giving__Parent__c IN :setOpps AND RecordTypeId = :RT_OPP_TRANSACTION]) {
				opp.Batch_Number__c = batch.Batch_Number__c;
				opp.Sequence_Number__c = batchUpload.rC_Connect__Batch_Upload_Sequence_Number__c;
				//system.assert(false, '==>' + opp.Stagename);
				//opp.FOC__c = opp.rC_Giving__Parent__r.FOC__c;
				opp.DFC_Description__c = opp.rC_Giving__Parent__r.DFC_Description__c;
				opp.Remaining_Non_Adjusted__c = opp.rC_Giving__Parent__r.rC_Giving__Giving_Amount__c;
				lstTransOppToUpdate.add(opp);
			}
		}
					
		if(lstTransOppToUpdate.size() > 0)
			update lstTransOppToUpdate;
		System.debug('[RB] - CPRD_Distribute_Controller.setBatch_SequenceNumber :: Method End..');
	} // END void setBatch_SequenceNumber(List<Opportunity> lstOpps) {

	/**
    * @description - Method to insert soft credit contact. Called from 'apply' method.
	* @parameter 1 - mapBUDOpportunity : Map of BUD Id and corresponding inserted/updated Opportunity.
    * @return - void
    */
	void insertSoftCredit(Map<String, Opportunity> mapBUDOpportunity) {
		System.debug('[RB] - CPRD_Distribute_Controller.insertSoftCredit :: Method Start..');
		List<rC_Giving__Opportunity_Credit__c> lstCredit = new List<rC_Giving__Opportunity_Credit__c>();
		for(Payment pay : payments) {
			if(pay.bud.Credit__c) {
				rC_Giving__Opportunity_Credit__c cr = new rC_Giving__Opportunity_Credit__c();
				cr.rC_Giving__Contact__c = pay.bud.Credit_Contact__c;
				cr.rC_Giving__Account__c = pay.bud.Credit_Contact__r.AccountId;
				cr.rC_Giving__Contact_Role__c = 'Donor';
				cr.rC_Giving__Type__c = 'Account & Contact';
				if(mapBUDOpportunity.get(pay.bud.Id).RecordTypeId == RT_OPP_TRANSACTION)
					cr.rC_Giving__Opportunity__c = mapBUDOpportunity.get(pay.bud.Id).rC_Giving__Parent__c;	
				else
					cr.rC_Giving__Opportunity__c = mapBUDOpportunity.get(pay.bud.Id).Id;	
				if(pay.bud.Giving_Amount__c > 0)
					cr.rC_Giving__Distribution__c = (pay.bud.Giving_Amount__c*100)/batchUpload.rC_Connect__Giving_Giving_Amount__c;
				else 
					cr.rC_Giving__Distribution__c = 0;
				cr.rC_Giving__Amount__c = pay.bud.Giving_Amount__c;
				lstCredit.add(cr);
			}
		}
		System.debug('[RB] - CPRD_Distribute_Controller.insertSoftCredit :: lstCredit  => ' + lstCredit);
        if(lstCredit.size()>0)
            insert lstCredit;

		System.debug('[RB] - CPRD_Distribute_Controller.insertSoftCredit :: Method End..');
	} // END void insertSoftCredit(Map<String, Opportunity> mapBUDOpportunity) {

	/**
    * @description - Method to update Batch, Batch Upload and Batch Upload Distribution records. Called from 'apply' method.
	* @parameter 1 - none.
    * @return - void
    */
	void updateBatch_BatchUpload() {
		System.debug('[RB] - CPRD_Distribute_Controller.updateBatch_BatchUpload :: Method Start..');
		Decimal amountDistributed = 0;
        List<Batch_Upload_Distribution__c> lstBUDToUpsert = new List<Batch_Upload_Distribution__c>();
        for(Payment pay : payments) {
            Batch_Upload_Distribution__c bud = pay.BUD;
            if(bud.Id == Null) {
                bud.Batch_Upload__c = batchUpload.Id;
                bud.Hard_Credit_Contact__c = batchUpload.rC_Connect__HardCreditContact__c;
                bud.Batch_Number__c = batch.Batch_Number__c;
                bud.FOC__c = batchUpload.FOC__c;
                bud.Sequence_Number__c = batchUpload.rC_Connect__Batch_Upload_Sequence_Number__c;
                bud.Close_Date__c = batchUpload.rC_Connect__Giving_Close_Date__c;
            }
			amountDistributed += bud.Giving_Amount__c;
            bud.Status__c = 'Committed';
            lstBUDtoUpsert.add(bud);
        } // END for(Payment pay : payments) {
		System.debug('[RB] - CPRD_Distribute_Controller.updateBatch_BatchUpload :: After insert lstCredit :: lstBUDtoUpsert  => ' + lstBUDtoUpsert);

        if(lstBUDtoUpsert.size() > 0) {
            upsert lstBUDtoUpsert;
						
			batchUpload.rC_Connect__Batch_Upload_Status__c = 'Committed';
			update batchUpload;
        }

		if(batch == null) {
			batch = [SELECT Id, rC_Giving__Current_Value__c, rC_Giving__Current_Number__c  
					FROM rC_Giving__Batch__c WHERE Id = :batchUpload.rC_Connect__Batch_Upload_Batch__r.Id];
		}
		batch.rC_Giving__Current_Value__c += amountDistributed;
		batch.rC_Giving__Current_Number__c += 1;
		System.debug('[RB] - CPRD_Distribute_Controller.updateBatch_BatchUpload :: After upsert lstBUDtoUpsert :: batch  => ' + batch);
		update batch;

		System.debug('[RB] - CPRD_Distribute_Controller.updateBatch_BatchUpload :: Method End..');
	} // END void updateBatch_BatchUpload() {

	/**
    * @description - Wrapper class for holding information about whole payment/fund like opportunity, batch upload distribution, etc.
	* @parameter 1 - na
    * @return - na
    */
    public class Payment{
        public Opportunity Opp{ get; set; }
        public Batch_Upload_Distribution__c BUD {get; set;}
        public String gauName {get; set;}
        public String campaignName {get; set;}
        public String childNumber {get; set;}
        public String NationalOfficeNumber {get; set;}
        public String CommunityNumber {get; set;}
        public Contact softCredit{ get; set; }

        public Payment(Opportunity o, Batch_Upload_Distribution__c b){
            opp = o;
            BUD = b;
            //gauName = b.GAU__r.Name;
			gauName = b.GAU__r.Receipt_Category__c;
            campaignName = b.Campaign__r.Name;
            softCredit = new Contact();
            softCredit.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        }
    } // END class Payment{
}