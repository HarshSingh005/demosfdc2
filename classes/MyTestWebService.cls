@RestResource(urlMapping='/MyTest/*/Testing')
global with sharing class MyTestWebService {

	@HttpPost
	global static Id createnewAcc(String name, String type)
	{
		Account a = new Account();
		a.OwnerId = '005E0000005yoQH';
	    a.Name = name + ' - '+type;
	    //c.Status = 'Open';
	    insert a;

	    return a.id;
	}

}