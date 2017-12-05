/***********************************************************************************************************
* Appirio, Inc
* Name         : AccountPredirectController 
* Created By   : Ravi Chauhan (Appirio Inc.)
* Purpose      : Extension class of AccountPredirect page.
* Created Date : January 24,2017
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
*
**********************************************************************************************************/
public with sharing class AccountPredirectController {
    
    /**
	* @description - Constructor
	* @param - ApexPages.StandardController
	* @return - null
	*/
    public AccountPredirectController(ApexPages.standardController std){
        
    }
    
    /**
	* @description - predirectToAccountRedirect
	*				 - this method would handle the case when a profile has only access to one recordtype (Due to which the RecordType parameter remains null)
	* @param - ApexPages.StandardController
	* @return - null
	*/
    public PageReference predirectToAccountRedirect(){
        PageReference result_page = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Account&retURL=%2F001%2Fo&save_new_url=%2F001%2Fe%3FretURL%3D%252F001%252Fo');
        String currentID = ApexPages.currentPage().getParameters().get('RecordType');
        List<String> availableAccountTypes = 
            GetEnabledRecordTypeUtility.GetAvailableRecordTypeIDsForSObject(Account.SObjectType);
        If(currentID != null && currentID.length() > 1){
            PageReference result_page1 = new PageReference(
                '/apex/ManageAccountContacts?retURL=%2F001%2Fo&RecordType='+ currentID +'&ent=Account&save_new=1&sfdc.override=1');
            return result_page1;
        }
        else if (availableAccountTypes.size() == 1){
            String rtid = availableAccountTypes[0];
            PageReference result_page2 = new PageReference(
                '/apex/ManageAccountContacts?retURL=%2F001%2Fo&RecordType='+ rtid +'&ent=Account&save_new=1&sfdc.override=1');
            return result_page2;
        }else{
            return result_page;
        }        
    }    
}