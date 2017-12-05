@isTest
	global class AddressValidationMock implements HttpCalloutMock {
		
		global static Boolean isVerified; 
	    global HTTPResponse respond(HTTPRequest req) {
	    	
	    	system.debug('----req---' + req);
	    	
	    	//creating fake resposne.
	    	AddressValidateRestResponse addValRes = new AddressValidateRestResponse();
	    	if(isVerified){
	    		addValRes.verifyLevel = 'Verified';	
	    	}
	    	else{
	    		addValRes.verifyLevel = 'NonVerified';
	    	}
	    	
	    	addValRes.fields = new List<AddressValidateRestResponse.field>();
	    	
	    	AddressValidateRestResponse.field f0 = new AddressValidateRestResponse.field();
	    	f0.content = 'testResultStreet1';
	    	addValRes.fields.add(f0);
	    	
	    	AddressValidateRestResponse.field f1 = new AddressValidateRestResponse.field();
	    	addValRes.fields.add(f1);
	    	AddressValidateRestResponse.field f2 = new AddressValidateRestResponse.field();
	    	addValRes.fields.add(f2);
	    	
	    	AddressValidateRestResponse.field f3 = new AddressValidateRestResponse.field();
	    	f3.content = 'testResultCity';
	    	addValRes.fields.add(f3);
	    	AddressValidateRestResponse.field f4 = new AddressValidateRestResponse.field();
	    	f4.content = 'test State Description';
	    	addValRes.fields.add(f4);
	    	AddressValidateRestResponse.field f5 = new AddressValidateRestResponse.field();
	    	f5.content = '85705';
	    	addValRes.fields.add(f5);
	    	
	    	String responseBody = JSON.serialize(addValRes);
	    	system.debug('---responseBody---' + responseBody);
	    	HttpResponse res = new HttpResponse();
	    	res.setHeader('Content-Type', 'application/json');
	    	res.setBody(responseBody);
	    	res.setStatusCode(200);
	    	res.setStatus('OK');
	    	system.debug('---FakeResponse---' + res);
	    	return res;
	    	
	        // Set response values, and 
	        // return response.
	    }
	}