/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountMergeController
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Controller class for page "AccountMerge"
 * Created Date : 11/Jan/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]						[Person Name]			[Short Description]
 **********************************************************************************************************/
public with sharing class AccountMergeController {
	public String from_AccID {get; set;}
	public String from_AccName {get; set;}
	public String to_AccID {get; set;}
	public String to_AccName {get; set;}
	public Boolean isActive {get; set;}

	public AccountMergeController() {
		from_AccID  = Apexpages.currentPage().getParameters().get('fromAcc');
		to_AccID = Apexpages.currentPage().getParameters().get('toAcc');
		isActive = true;
		String accRT1, accRT2;
		List<Account> lstAcc = [SELECT Name, RecordTypeID FROM Account WHERE Id =: from_AccID];
		if(lstAcc.size() > 0) {
			from_AccName = lstAcc[0].Name;
			accRT1 = lstAcc[0].RecordTypeID;
		} else {
			isActive = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.Error_Invalid_Id_for_Account_Merge));
		}
		
		lstAcc = [SELECT Name, RecordTypeID FROM Account WHERE Id =: to_AccID];
		if(lstAcc.size() > 0) {
			to_AccName = lstAcc[0].Name;
			accRT2 = lstAcc[0].RecordTypeID;
		} else {
			isActive = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.Error_Invalid_To_Account_Id_for_Account_Merge));
		}

		if(accRT1!=accRT2 && isActive) {
			isActive = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.Error_Account_Type_for_Account_Merge));
		}
	} // END public AccountMergeController() {

	public PageReference mergeAccounts() {
		try {
			List<Account> lstAccToUpdate = new List<Account>();
			for(Account acc : [SELECT Id, Name, ParentId FROM Account WHERE ParentId =: from_AccID]) {
				Account new_Acc = new Account();
				new_Acc.Id = acc.Id;
				new_Acc.ParentId = to_AccID;
				lstAccToUpdate.add(new_Acc);
			}
			if(lstAccToUpdate.size() > 0) {
				update lstAccToUpdate;
			}
			//return (new PageReference('/merge/accmergewizard.jsp?goNext&cid=' + from_AccID + '&cid=' + to_AccID));
		}
		catch(Exception e) {
			System.debug('[RB] - AccountMergeController.mergeAccounts :: Error(Update) = ' + e.getMessage() + '; Line No = ' + e.getLineNumber());
		}
		return Null;
	} // END public PageReference mergeAccounts() {

	public PageReference cancel() {
		String retURL = Apexpages.currentPage().getParameters().get('retURL');
		if(retURL == Null)
			retURL = '001/o';
		return (new PageReference('/' + retURL));
	} // END public PageReference cancel() {
} // END public with sharing class AccountMergeController {