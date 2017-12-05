/*
 * Class        : AccountLookupController
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 26, 2013
 * Objective    : Controller for looking up Accounts
*/
public with sharing class AccountLookupController {
	
	//Properties
	public String searchTxt{get;set;}
	public Boolean doneSearch { get; set; }
	public List<Account> accList{
		get{
			if(accList == null)
				accList = new List<Account>();
			return accList;	
		}
		set;
	}
	
	//Constructor
	public AccountLookupController(){
        doneSearch = false;
    }
	
	/**
     * Search for Accounts based on the search input  
     * @parm 
     * @return PageReference
    */
	public PageReference doSearch(){
		accList.clear();
		if(searchTxt != null){
			searchTxt = '%' + String.escapeSingleQuotes(searchTxt) + '%';
			for(Account acc : Database.query('SELECT Id, Name, Office_Type__c, NO_Country__c FROM Account WHERE Type = \'Internal\' AND Name LIKE: searchTxt LIMIT 10')){
				accList.add(acc);
			}
                    doneSearch = true;

		}
		return null;
	}
	
}