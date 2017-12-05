public without sharing class OpportunityRefundAdjustment {
  
	//public String refundType{get;set;}
	public Opportunity originalTransaction{get;set;}
	public Opportunity uiOpportunityFields{get;set;}
  
	public List<SelectOption> adjustmentTypes{get;set;}
	public String adjustmentType{get;set;}
	public List<SelectOption> negTransGAUoptions{get;set;}
	public String negTransGAU{get;set;}
	public List<SelectOption> posTransGAUoptions{get;set;}
	public String posTransGAU{get;set;}

	public List<SelectOption> listAdjustReasons{get;set;}
	public List<SelectOption> listReturnCodes{get;set;}
	public boolean showReturnCodes{get;set;}
	public boolean suppressFromStatement{get;set;}

	public Decimal totalBackOuts{get;set;}
	public string productType{get;set;}
	public String userProfile{get;set;}

	public boolean dfc_InProcess_Sent_ReceivedbyNO{get;set;}
	public string calculatedDFCStatus{get;set;}

	public boolean disableAdjustment{get;set;}

	private ApexPages.StandardController standardController;
	private ID currOppID;
	private Decimal totalTransAmt;
   
	public OpportunityRefundAdjustment(ApexPages.StandardController stdController) {

		currOppID = (id) ApexPages.currentPage().getParameters().get('id');
		if (currOppID == null) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Valid SFDC ID Defined'));
		    return;
		}

	    this.standardcontroller = stdController;
	    this.uiOpportunityFields = new Opportunity();

	    this.originalTransaction = [select id, Name, RecordTypeId, rC_Giving__Parent__r.RecordTypeId, AccountId,
	    	rC_Giving__Primary_Contact__c, rC_Giving__Hard_Credit_Contact__c, Payment_Hard_Credit_Contact__c, rC_Giving__Parent__c, 
	    	Parent_Product_Type__c, DFC_Status__c, CloseDate, Amount,
	    	rC_Giving__Transaction_Type__c, StageName, rC_Giving__GAU__r.Name,
	    	rC_Giving__GL_Batch_Number__c, Batch_Number__c,Sequence_Number__c,
	    	Participant__c, CampaignId,
			rC_Giving__Payment_Method_Selected__c,
			rC_Giving__Payment_Method_Selected__r.Name,
			rC_Giving__Payment_Method_Selected__r.RecordTypeId,			
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,
			rC_Giving__Payment_Method_Selected__r.rC_Connect__Authentication_Value__c,
	    	rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Postal_Code__c,
	    	rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Holder_Name__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Number_Last_4__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Expiration_Month__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Expiration_Year__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Number__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Security_Code__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number_Last_4__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Routing_Number__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Bank_Name__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Type__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Account__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Ticker_Symbol__c,
			rC_Giving__Payment_Method_Selected__r.Number_of_Shares__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Value_At_Gift__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_City__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Contact_Name__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Country__c,
			rC_Giving__Payment_Method_Selected__r.rC_Connect__Billing_Email__c,
			rC_Giving__Payment_Method_Selected__r.rC_Connect__Billing_Phone__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_State__c,
			rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Street__c
	    	FROM Opportunity where id = :currOppID];
	    this.totalTransAmt = this.originalTransaction.Amount;
		
		AggregateResult[] lstAR = [SELECT Sum(Amount)mysum FROM Opportunity 
								WHERE StageName IN ('Adj From')
								AND Adjusted_Transaction__c = :currOppID];
		this.totalBackOuts = 0.0;
		if(lstAR.size()>0 && lstAR[0].get('mysum')!=null) {
			this.totalBackOuts = (Decimal) lstAR[0].get('mysum');
		}

		userProfile = (String) [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()][0].get('Name');

    	// Initial Validations on original Transaction
		if (originalTransaction.StageName != 'Completed' && originalTransaction.StageName != 'Adj To')
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Transaction must be Completed or Adjusted in order to adjust.'));
	    	this.disableAdjustment = true;
		}
		else if (originalTransaction.rC_Giving__Payment_Method_Selected__c == null)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Transaction must have a selected payment method.'));
	    	this.disableAdjustment = true;		
		}
		else
	    	this.disableAdjustment = false;
	    			
			// Query GL Allocation record for Obligation Status: Sent to NO, REceived by NO
		List<GL_Allocation__c> lstGLA = [select Release_Date__c, Received_by_NO_Date__c, Obligation__c
			from GL_Allocation__c where
			IsObligation__c = true
			AND Transaction__c = :currOppID];

		if (lstGLA.size() == 0)
		{
				calculatedDFCStatus = 'Pending';
				dfc_InProcess_Sent_ReceivedbyNO = false;			
		}
		else if (lstGLA.size() == 1 && originalTransaction.DFC_Status__c == 'Pending')
		{
		
			if (lstGLA[0].Release_Date__c == null && lstGLA[0].Received_by_NO_Date__c == null
				&& lstGLA[0].Obligation__c == null)
			{
				calculatedDFCStatus = 'Pending';
				dfc_InProcess_Sent_ReceivedbyNO = false;
			}
			else if (lstGLA[0].Release_Date__c == null && lstGLA[0].Received_by_NO_Date__c == null
				&& lstGLA[0].Obligation__c != null)
			{
				calculatedDFCStatus = 'In Process';
				dfc_InProcess_Sent_ReceivedbyNO = true;
			}
			else if (lstGLA[0].Release_Date__c != null && lstGLA[0].Received_by_NO_Date__c == null)
			{
				calculatedDFCStatus = 'Sent to NO';
				dfc_InProcess_Sent_ReceivedbyNO = true;
			}
			else if (lstGLA[0].Release_Date__c != null && lstGLA[0].Received_by_NO_Date__c != null)
			{
				calculatedDFCStatus = 'Received by NO';
				dfc_InProcess_Sent_ReceivedbyNO = true;
			}
			else
			{	
				calculatedDFCStatus = 'ERROR: '+originalTransaction.DFC_Status__c;
			}
		}
		else
		{
				calculatedDFCStatus = originalTransaction.DFC_Status__c;
				dfc_InProcess_Sent_ReceivedbyNO = false;		
		}

		this.uiOpportunityFields.Amount = this.originalTransaction.Amount + this.totalBackOuts;
		
		listAdjustReasons = new List<SelectOption>();
		listAdjustReasons.add(new SelectOption('','-select-'));
		Schema.DescribeFieldResult fieldResult = Opportunity.Adjustment_Reason__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple)
		   listAdjustReasons.add(new SelectOption(f.getLabel(), f.getValue()));

		listReturnCodes = new List<SelectOption>();
		listReturnCodes.add(new SelectOption('','-select-'));
		Schema.DescribeFieldResult fieldResult2 = Opportunity.Return_Code__c.getDescribe();
		List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
		for( Schema.PicklistEntry f : ple2)
		   listReturnCodes.add(new SelectOption(f.getLabel(), f.getValue()));


		negTransGAUoptions = new List<SelectOption>();
		posTransGAUoptions = new List<SelectOption>();

		adjustmentTypes = new List<SelectOption>();
		adjustmentTypes.add(new SelectOption('-select-','-select-'));
		adjustmentTypes.add(new SelectOption('Adjustment','Adjustment'));
		adjustmentTypes.add(new SelectOption('Refund','Refund'));

		if (userProfile == 'Treasury User' || userProfile == 'System Administrator') {
			adjustmentTypes.add(new SelectOption('Return','Return'));
		}
		//if (userProfile == 'Sponsor Care Manager' || userProfile == 'System Administrator')

		suppressFromStatement = false;

		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Profile: '+userProfile));

	}


	public PageReference adjustmentTypeChange() {

		// Populate Picklists
		//

		negTransGAUoptions.clear();
		posTransGAUoptions.clear();
		showReturnCodes = false;

		if (adjustmentType == 'Refund')
		{
			if(originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c == 'Charge Card')
				posTransGAUoptions.add(new SelectOption('0151', '0151 - Credit Card Refund'));
			else
				posTransGAUoptions.add(new SelectOption('0150', '0150 - Refund'));
		}
		else if (adjustmentType == 'Return')
		{
			posTransGAUoptions.add(new SelectOption('0154', '0154 - Returns/Misc Debits'));
			posTransGAUoptions.add(new SelectOption('0157', '0157 - Money sent to CCF in error'));
			posTransGAUoptions.add(new SelectOption('0158', '0158 - Credit Card Chargeback'));
			posTransGAUoptions.add(new SelectOption('0160', '0160 - Manual Credit Card Refund'));
			posTransGAUoptions.add(new SelectOption('0161', '0161 - Blackbaud Return'));
			showReturnCodes = true;
		}
		else if (adjustmentType == 'Adjustment')
		{
			posTransGAUoptions.add(new SelectOption('Destination Opportunity','Destination Opportunity'));
			posTransGAUoptions.add(new SelectOption('0600', '0600 - Suspense'));
		}


		if (originalTransaction.Parent_Product_Type__c == 'Designated Fund')
		{
			// TBD: replace below: look at GL Allocation for these states
			if (dfc_InProcess_Sent_ReceivedbyNO == true || originalTransaction.DFC_Status__c == 'Received by Child' )
			{
				negTransGAUoptions.add(new SelectOption('0152', '0152 - CCF DFC Account'));
			}
			else if (originalTransaction.DFC_Status__c == 'Kept by LP/Community') //Undeliverable – Kept by Project
			{
				negTransGAUoptions.add(new SelectOption('0156', '0156 - Undeliverable DFC - Kept by Project'));
			}
			else if (originalTransaction.DFC_Status__c == 'Undeliverable - Project Closed')
			{
				negTransGAUoptions.add(new SelectOption('0155', '0155 - Undeliverable DFC - Project Closed'));
			}
			else  // Pending, Undeliverable - Over $100
				negTransGAUoptions.add(new SelectOption('Origin','Origin'));
		}
		else  // not a DFC
			negTransGAUoptions.add(new SelectOption('Origin','Origin'));


		return null;
	}


	public PageReference submitRefundAdjustment() {

		Opportunity destinationOpportunity = new Opportunity();
		
		if (adjustmentType == '-select-')
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Adjustment Type must be selected.'));
			return null;
		}

		if (uiOpportunityFields.Adjustment_Reason__c == null)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select an Adjustment Reason.'));
			return null;
		}

		if (uiOpportunityFields.Return_Code__c == null && adjustmentType == 'Return')
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Return Code for returns.'));
			return null;
		}

		if (uiOpportunityFields.Amount <= 0) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter in a postive amount in the amount field.'));
			return null;
		}

		// uiOpportunityFields.Amount is changeable in the UI
		if (uiOpportunityFields.Amount > (totalTransAmt + totalBackOuts)) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Amount entered exceeds the total transaction amount ('+totalTransAmt+') minus back outs ('+totalBackOuts+')'));
			return null;
		}

		// User needs to be in special permission set to adjust > $100
		if (uiOpportunityFields.Amount > 100) {

			system.debug('UserInfo.getUserId():'+UserInfo.getUserId());

			List<PermissionSetAssignment> listPSA = [SELECT PermissionSetId FROM PermissionSetAssignment
			 WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Special_Adjust_Permission'];

			system.debug('listPSA.size():'+listPSA.size());

			if (listPSA.size() < 1) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must be in the Special Adjustment Permission Set group to adjust amounts in excess of $100'));
				return null;
			}

		}

		// if adjustment reason = 'RTR - DF Returned to Richmond'
		// set DFC status = 'Return to Richmond'
		if (uiOpportunityFields.Adjustment_Reason__c == 'RTR - DF Returned to Richmond')
		{
						// TBD: replace below: look at GL Allocation for these states

			if (dfc_InProcess_Sent_ReceivedbyNO == true)
			{
				originalTransaction.DFC_Status__c = 'Return to Richmond';
				negTransGAU = 'Origin';
			}
			else
			{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'For Returns to Richmond: DFC status must be In Process, Sent to NO, or Received by NO.'));
				return null;
			}

		}


	//
	// Create Negative Transaction
	//

		Map<String, ID> mapGAU = new Map<String, ID>();
		for (rC_Giving__GAU__c r : [SELECT Receipt_Category__c, Id FROM rC_Giving__GAU__c
			where Receipt_Category__c IN ('0150', '0151', '0152', '0153', '0154', '0155', '0156', '0157', '0158', '0159', '0160', '0161', '0600')]) {
			mapGAU.put(r.Receipt_Category__c, r.id);
		}

		Opportunity backoutTransaction = new Opportunity();
	    Opportunity newtransaction = new Opportunity();
		List<Opportunity> insertTransactions = new List<Opportunity>();

		if (negTransGAU == 'Origin') {

			//if (originalTransaction.rC_Giving__GAU__r.Name == '600')
			//	backoutTransaction.rC_Giving__GAU__c = mapGAU.get('600'); // GAU inherited from parent, do not set
			//else

			backoutTransaction.rC_Giving__GAU__c = originalTransaction.rC_Giving__GAU__c; // GAU inherited from original transaction		
		}
		else {
			backoutTransaction.rC_Giving__GAU__c = mapGAU.get(negTransGAU); // GAU set in UI
		}

		backoutTransaction.StageName = 'Adj From';
		backoutTransaction.Amount = - uiOpportunityFields.Amount;  // uiOpportunityFields.Amount is changeable in the UI
		backoutTransaction.rC_Giving__Primary_Contact__c = originalTransaction.rC_Giving__Primary_Contact__c;
		backoutTransaction.rC_Giving__Hard_Credit_Contact__c = originalTransaction.rC_Giving__Hard_Credit_Contact__c;
		backoutTransaction.Payment_Hard_Credit_Contact__c = originalTransaction.rC_Giving__Hard_Credit_Contact__c;
		backoutTransaction.AccountId = originalTransaction.AccountId;

		backoutTransaction.Participant__c = originalTransaction.Participant__c;
		backoutTransaction.CampaignId = originalTransaction.CampaignId; // GAU inherited from NEW parent, do not set

		backoutTransaction.rC_Giving__Parent__c = originalTransaction.rC_Giving__Parent__c;
		backoutTransaction.rC_Giving__Payment_Method_Selected__c = originalTransaction.rC_Giving__Payment_Method_Selected__c;
		backoutTransaction.rC_Giving__Transaction_Type__c = 'Refund';
		backoutTransaction.CloseDate = originalTransaction.CloseDate;
		backoutTransaction.Date_of_Distribution__c = system.today();
		backoutTransaction.RecordTypeId = originalTransaction.RecordTypeId;
		backoutTransaction.Adjusted_Transaction__c = originalTransaction.id;

		backoutTransaction.rC_Giving__GL_Batch_Number__c = originalTransaction.rC_Giving__GL_Batch_Number__c;
        backoutTransaction.Batch_Number__c = originalTransaction.Batch_Number__c;
		backoutTransaction.Sequence_Number__c = originalTransaction.Sequence_Number__c;

		backoutTransaction.Adjustment_Reason__c = uiOpportunityFields.Adjustment_Reason__c;
		backoutTransaction.Return_Code__c = uiOpportunityFields.Return_Code__c;
		backoutTransaction.Adjustment_Comments__c = uiOpportunityFields.Adjustment_Comments__c;

	//
	// Create Positive Transaction
	//

		newtransaction.RecordTypeId = originalTransaction.RecordTypeId;

		if (adjustmentType == 'Adjustment') {

				// default values
			newtransaction.AccountId = originalTransaction.AccountId;
			newtransaction.StageName = 'Adj To';
			newtransaction.Remaining_Non_Adjusted__c = uiOpportunityFields.Amount;
			newtransaction.rC_Giving__Hard_Credit_Contact__c = originalTransaction.rC_Giving__Hard_Credit_Contact__c;
			newtransaction.Payment_Hard_Credit_Contact__c = originalTransaction.Payment_Hard_Credit_Contact__c;
			newtransaction.rC_Giving__Payment_Method_Selected__c = originalTransaction.rC_Giving__Payment_Method_Selected__c;


			boolean childDeparted = false;
			if (uiOpportunityFields.rC_Giving__Parent__c != null) {

				destinationOpportunity = [select id, Name, RecordTypeId, AccountId,
		    	rC_Giving__Primary_Contact__c, rC_Giving__Hard_Credit_Contact__c,
		    	rC_Giving__Payment_Method_Selected__c, rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c,
		    	rC_Giving__GAU__c, CampaignId, Participant__c,
		    	Participant__r.Sponsorship_Status__c
		    	FROM Opportunity where id = :uiOpportunityFields.rC_Giving__Parent__c LIMIT 1];

		    		// check if child = departed, if so, put $ into suspense
				if (destinationOpportunity.Participant__r.Sponsorship_Status__c  == 'Departed')
					childDeparted = true;
			}


				// if child = departed, put $ into suspense opportunity
			if (posTransGAU == 'Destination Opportunity' &&	childDeparted == false)
			{

				if (uiOpportunityFields.rC_Giving__Parent__c == null) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Destination Opportunity'));
					return null;
				}

		    	if (destinationOpportunity.RecordTypeId ==
		    	 (Id) Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId())
		    	{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not adjust to a transaction.  Must be a parent opportunity.'));
					return null;
				}


			//
			/// Cross contact adjustment ///////////////
			//

				if (destinationOpportunity.rC_Giving__Hard_Credit_Contact__c != originalTransaction.rC_Giving__Hard_Credit_Contact__c)
				{

					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'CROSS CONTACT ADJUSTMENT. '
						+'  Origin Payment Method Type:'+originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c
						+'  Desination Payment Method Type:'+destinationOpportunity.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c
						));

					// TBD: find any destination PM that matches origin PM

					List<rC_Giving__Payment_Method__c> DestPMs = [select id, rC_Giving__Payment_Type__c,rC_Giving__Billing_Postal_Code__c,
						rC_Giving__Card_Number_Last_4__c, Number_of_Shares__c, rC_Giving__Card_Expiration_Month__c, rC_Giving__Card_Expiration_Year__c,rC_Giving__Ticker_Symbol__c,
						rC_Giving__Account_Number_Last_4__c, rC_Giving__Routing_Number__c, rC_Giving__Bank_Name__c, rC_Giving__Account_Type__c
						from rC_Giving__Payment_Method__c
						where rC_Giving__Payment_Type__c = :originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c
						and rC_Giving__Account__c = :destinationOpportunity.AccountId ];

						// go through all destination PMs with same type
					boolean foundAMatch = true;
					id newSelectedPM = null;
					for (rC_Giving__Payment_Method__c thisPM : DestPMs )
					{
						if (thisPM.rC_Giving__Payment_Type__c == 'Cash/Check')
						{
							newSelectedPM = thisPM.id;
							break;
						}
						else if (thisPM.rC_Giving__Payment_Type__c == 'Charge Card' &&
							thisPM.rC_Giving__Billing_Postal_Code__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Postal_Code__c &&
							thisPM.rC_Giving__Card_Number_Last_4__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Number_Last_4__c &&
							thisPM.rC_Giving__Card_Expiration_Month__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Expiration_Month__c &&
							thisPM.rC_Giving__Card_Expiration_Year__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Expiration_Year__c )
						{
							newSelectedPM = thisPM.id;
							break;
						}
						else if (thisPM.rC_Giving__Payment_Type__c == 'EFT' &&
							thisPM.rC_Giving__Billing_Postal_Code__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Postal_Code__c &&
							thisPM.rC_Giving__Account_Number_Last_4__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number_Last_4__c &&
							thisPM.rC_Giving__Routing_Number__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Routing_Number__c &&
							thisPM.rC_Giving__Bank_Name__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Bank_Name__c &&
							thisPM.rC_Giving__Account_Type__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Type__c )
						{
							newSelectedPM = thisPM.id;
							break;
						}
						else if (thisPM.rC_Giving__Payment_Type__c == 'Securities' &&
							thisPM.rC_Giving__Ticker_Symbol__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Ticker_Symbol__c &&
							thisPM.Number_of_Shares__c == originalTransaction.rC_Giving__Payment_Method_Selected__r.Number_of_Shares__c )
						{
							newSelectedPM = thisPM.id;
							break;
						}
						else if (thisPM.rC_Giving__Payment_Type__c == 'Third Party Charge' ||
							thisPM.rC_Giving__Payment_Type__c == 'Paypal' ||
							thisPM.rC_Giving__Payment_Type__c == 'Other')
						{
								// match any remaining PMs simply on 'type'
							newSelectedPM = thisPM.id;
							break;
						}

					}

						// didn't find a match, need to create this PM
					if (newSelectedPM == null)
					{
						foundAMatch = false;

						rC_Giving__Payment_Method__c newPM = new rC_Giving__Payment_Method__c();

						newPM.rC_Giving__Account__c = destinationOpportunity.AccountId;
						newPM.rC_Giving__Contact__c = destinationOpportunity.rC_Giving__Hard_Credit_Contact__c;
						newPM.Name = originalTransaction.rC_Giving__Payment_Method_Selected__r.Name;
						newPM.rC_Giving__Payment_Type__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c;
						newPM.RecordTypeId = originalTransaction.rC_Giving__Payment_Method_Selected__r.RecordTypeId;

						newPM.rC_Connect__Authentication_Value__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Connect__Authentication_Value__c;
						newPM.rC_Giving__Card_Holder_Name__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Holder_Name__c;
						newPM.rC_Giving__Card_Number__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Number__c;
						newPM.rC_Giving__Card_Security_Code__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Security_Code__c;
						newPM.rC_Giving__Card_Number_Last_4__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Number_Last_4__c;
						newPM.rC_Giving__Card_Expiration_Month__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Expiration_Month__c;
						newPM.rC_Giving__Card_Expiration_Year__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Card_Expiration_Year__c;

						newPM.rC_Giving__Account_Number__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number__c;
						newPM.rC_Giving__Account_Number_Last_4__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number_Last_4__c;
						newPM.rC_Giving__Routing_Number__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Routing_Number__c;
						newPM.rC_Giving__Bank_Name__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Bank_Name__c;
						newPM.rC_Giving__Account_Type__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Type__c;

						newPM.rC_Giving__Ticker_Symbol__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Ticker_Symbol__c;
						newPM.Number_of_Shares__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.Number_of_Shares__c;
						newPM.rC_Giving__Value_At_Gift__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Value_At_Gift__c;

						newPM.rC_Giving__Billing_City__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_City__c ;
						newPM.rC_Giving__Billing_Contact_Name__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Contact_Name__c ;
						newPM.rC_Giving__Billing_Country__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Country__c ;
						newPM.rC_Connect__Billing_Email__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Connect__Billing_Email__c ;
						newPM.rC_Connect__Billing_Phone__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Connect__Billing_Phone__c ;
						newPM.rC_Giving__Billing_State__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_State__c ;
						newPM.rC_Giving__Billing_Street__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Street__c ;
						newPM.rC_Giving__Billing_Postal_Code__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Billing_Postal_Code__c;

						insert newPM;
						newSelectedPM = newPM.id;

						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Creating new Payment Method: '
							+originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c
							+' on destination Opportunity. '
							//+'  PMID:'+newSelectedPM
							//+'  Dest # PMs found w/ same PM Type:'+DestPMs.size()
						));

					} else {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'MATCHING PAYMENT METHOD FOUND. Matching payment to Payment Method on destination Opportunity. '
						//+'  PMID:'+newSelectedPM
						//+'  Dest # PMs found w/ same PM Type:'+DestPMs.size()
						));

					}


						// override defaults: new PM paid by destination donor
					newtransaction.AccountId = destinationOpportunity.AccountId;
					newtransaction.rC_Giving__Payment_Method_Selected__c = newSelectedPM;

					if (originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c == 'EFT' ||
						originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c == 'Charge Card')
						newtransaction.Selected_Payment_Method_EFT_CC__c = newSelectedPM;

					newtransaction.rC_Giving__Hard_Credit_Contact__c = destinationOpportunity.rC_Giving__Hard_Credit_Contact__c;
					newtransaction.rC_Giving__Payment_Method__c = originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c;

				}


			//
			/// Cross contact adjustment  - END ///////////////
			//


				newtransaction.rC_Giving__GAU__c = destinationOpportunity.rC_Giving__GAU__c; // GAU inherited from NEW parent, do not set
				newtransaction.rC_Giving__Parent__c = uiOpportunityFields.rC_Giving__Parent__c;
				newtransaction.rC_Giving__Primary_Contact__c = destinationOpportunity.rC_Giving__Primary_Contact__c;
				newtransaction.CampaignId = destinationOpportunity.CampaignId; // GAU inherited from NEW parent, do not set
				newtransaction.Participant__c = destinationOpportunity.Participant__c;
			}
			else  // adj to Suspense 600
			{
				newtransaction.rC_Giving__GAU__c = mapGAU.get('0600'); // 600 GAU set in UI

				//newtransaction.rC_Giving__Parent__c = originalTransaction.rC_Giving__Parent__c;
				newtransaction.rC_Giving__Parent__c = null;

				newtransaction.rC_Giving__Primary_Contact__c = originalTransaction.rC_Giving__Primary_Contact__c;
				newtransaction.CampaignId = originalTransaction.CampaignId; // GAU inherited from NEW parent, do not set
				newtransaction.Participant__c = null;

				// Create a PARENT Opportunity instead of a transaction, for GAU type 600
				//  leads to: System.LimitException: rC_Giving:Too many SOQL queries: 101
			
				newtransaction.RecordTypeId = originalTransaction.rC_Giving__Parent__r.RecordTypeId;
				newtransaction.rC_Giving__First_Payment_Date__c = System.today();
				newtransaction.rC_Giving__Payment_End_Date__c = System.today();
				newtransaction.rC_Giving__Payment_Day__c = '1st';
				newtransaction.rC_Giving__Giving_Amount__c = uiOpportunityFields.Amount;
				newtransaction.rC_Giving__Giving_Frequency__c = 'One Payment';
				newtransaction.Product_Type__c = 'One Time Gift';
                newtransaction.Product_Sub_Type__c = 'Standard';
                newtransaction.StageName = 'Completed';
           		newtransaction.Payment_Hard_Credit_Contact__c = null;

			}

		}
		else {

			if (adjustmentType == 'Return')
				newtransaction.StageName = 'Returned';
			else
				newtransaction.StageName = 'Refunded';

			newtransaction.rC_Giving__GAU__c = mapGAU.get(posTransGAU); // GAU set in UI
			newtransaction.rC_Giving__Parent__c = originalTransaction.rC_Giving__Parent__c;
			newtransaction.rC_Giving__Primary_Contact__c = originalTransaction.rC_Giving__Primary_Contact__c;
			newtransaction.CampaignId = originalTransaction.CampaignId; // GAU inherited from NEW parent, do not set
			newtransaction.Participant__c = originalTransaction.Participant__c;
		}

		newtransaction.Amount = uiOpportunityFields.Amount;  // uiOpportunityFields.Amount is changeable in the UI

		newtransaction.rC_Giving__Transaction_Type__c = 'Payment';
		newtransaction.CloseDate = originalTransaction.CloseDate;
		newtransaction.Date_of_Distribution__c = system.today();
		newtransaction.Adjusted_Transaction__c = originalTransaction.id;

		newtransaction.rC_Giving__GL_Batch_Number__c = originalTransaction.rC_Giving__GL_Batch_Number__c;
        newtransaction.Batch_Number__c = originalTransaction.Batch_Number__c;
		newtransaction.Sequence_Number__c = originalTransaction.Sequence_Number__c;

		newtransaction.Adjustment_Reason__c = uiOpportunityFields.Adjustment_Reason__c;
		newtransaction.Return_Code__c = uiOpportunityFields.Return_Code__c;
		newtransaction.Adjustment_Comments__c = uiOpportunityFields.Adjustment_Comments__c;


		if (suppressFromStatement == true)
		{
			originalTransaction.Suppress_From_Statement__c = true;
			update originalTransaction;

			backoutTransaction.Suppress_From_Statement__c = true;
		}


		insertTransactions.add(backoutTransaction);
		insertTransactions.add(newtransaction);
		//system.assert(false, '====>Backout' + originalTransaction.Product_Type__c + '====>New' + newTransaction.Product_type__c);
		insert insertTransactions; 

		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,
			'Refund/Adjustment Complete. $'
			+backoutTransaction.Amount
			+' backed out of:'
			+negTransGAU
			+', applied to:'
			+posTransGAU
			));

		totalBackOuts += backoutTransaction.Amount;
		uiOpportunityFields.Amount = originalTransaction.Amount + totalBackOuts;
		uiOpportunityFields.rC_Giving__Parent__c = null;
		insertTransactions = null;

		originalTransaction.Remaining_Non_Adjusted__c = originalTransaction.Amount + totalBackOuts;
		update originalTransaction;


			// finally: check if we should inactivate the original PM
		List<AggregateResult> arRNA = [select sum(Remaining_Non_Adjusted__c) rnaAmt from Opportunity where
			rC_Giving__Payment_Method_Selected__c = :originalTransaction.rC_Giving__Payment_Method_Selected__c
			and StageName IN ('Completed', 'Adj To')];

		if (originalTransaction.rC_Giving__Payment_Method_Selected__r.rC_Giving__Payment_Type__c != 'Cash/Check' &&
			(arRNA[0].get('rnaAmt') == null || arRNA[0].get('rnaAmt') == 0)
		)
		{
			rC_Giving__Payment_Method__c thisPM = new rC_Giving__Payment_Method__c();
			thisPM.id = originalTransaction.rC_Giving__Payment_Method_Selected__c;
			thisPM.rC_Giving__Is_Default__c = false;
			thisPM.rC_Giving__Is_Active__c = false;

			update thisPM;

			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Deactivated original Payment Method, no remaining charges.'));
		}


	    return null;
	}

}