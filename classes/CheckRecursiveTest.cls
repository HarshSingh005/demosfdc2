/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CheckRecursiveTest.cls
 * Created By   : Vaibhav Goel (Appirio JDC)
 * Purpose      : Provide test covergae for CheckRecursive 
 * Created Date : 22nd July, 2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 5/Apr/2017					Suminder Singh			Increased Code coverage

 **********************************************************************************************************/
 
@isTest
private class CheckRecursiveTest {
    
    //Test Method to cover the class method - runOnce()
	private static testMethod void runOnceTest() {
        Boolean runOnceResult = CheckRecursive.runOnce();
        system.assertEquals(true, runOnceResult);
        Boolean runOnceResultFalse = CheckRecursive.runOnce();
        system.assertEquals(false, runOnceResultFalse);
	}
	
	//Test Method to cover the class method - runAccountOnce()
	private static testMethod void runAccountOnceTest() {
        system.debug('@@@Enterred Acc once');
        Boolean runAccOnceResult = CheckRecursive.runAccountOnce();
        system.assertEquals(true, runAccOnceResult);
        Boolean runAccOnceResult2 = CheckRecursive.runAccountOnce();
        system.assertEquals(false, runAccOnceResult2);
	}
	
	//Test Method to cover the class method - runContactOnce()
	private static testMethod void runContactOnceTest() {
	    system.debug('@@@Enterred contact once');
        Boolean runConOnceResult = CheckRecursive.runContactOnce();
        system.assertEquals(true, runConOnceResult);
        Boolean runConOnceResult2 = CheckRecursive.runContactOnce();
        system.assertEquals(false, runConOnceResult2);
	}
	
	//Test Method to cover the class method - runOpportunityOnce()
	private static testMethod void runOpportunityOnceTest() {
        Boolean runOppOnceResult = CheckRecursive.runOpportunityOnce();
        system.assertEquals(true, runOppOnceResult);
        Boolean runOppOnceResult2 = CheckRecursive.runOpportunityOnce();
        system.assertEquals(false, runOppOnceResult2);
	}
	
	//Test Method to cover the class method - runOppNameUpdate()
	private static testMethod void runOppNameUpdateTest() {
	    // Returns True for the first time
	    system.assertEquals(true, CheckRecursive.runOppNameUpdate());
	    // Returns false if called again
        system.assertEquals(false, CheckRecursive.runOppNameUpdate());
	}
	
	//Test Method to cover the class method - checkCounter()
	private static testMethod void checkCounterTest() {
	    // Returns 0 for the first time
	    system.assertEquals(0, CheckRecursive.checkCounter());
	    // Returns increamented value every time
        system.assertEquals(1, CheckRecursive.checkCounter());
	}
	
	//Test Method to cover the class method - ifClawbackRunningRecursively()
	private static testMethod void ifClawbackRunningRecursively() {
	    // Returns true when function is called for 6 times
	    for(Integer i=0;i<6;i++)
	        system.assertEquals(true, CheckRecursive.ifClawbackRunningRecursively());
	    // Returns false after 6 times
        system.assertEquals(false, CheckRecursive.ifClawbackRunningRecursively());
	}
	
	//Test Method to cover the class method - runUpdateOppOwnerOnce()
	private static testMethod void runUpdateOppOwnerOnceTest() {
	    // Returns True for the first time
	    system.assertEquals(true, CheckRecursive.runUpdateOppOwnerOnce());
	    // Returns false if called again
        system.assertEquals(false, CheckRecursive.runUpdateOppOwnerOnce());
	}
	

}