/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MultiselectControllerTest 
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class of MultiselectController class
 * Created Date : July 28,2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
@isTest
private class MultiselectControllerTest {
    static List<SelectOption> leftList,rightList;
    
	private static testMethod void test() {
	    createTestData();
	    test.startTest();
	    MultiselectController controller = new MultiselectController();
	   
	    controller.leftOptions = leftList;
	    controller.leftOptionsHidden = 'App&le';
	    System.assertEquals(controller.leftOptions.get(0), new SelectOption('App','le'));
	    
	    controller.rightOptions = rightList;
	    controller.rightOptionsHidden = 'frui&t';
	    System.assertEquals(controller.rightOptions.get(0), new SelectOption('frui','t'));
	    
	    test.stopTest();

	}
	//creates the test data
	static void createTestData(){
	    leftList = new List<SelectOption>();
	    leftList.add(new SelectOption('testA','Testaaa'));
	    
	    rightList = new List<SelectOption>();
	    rightList.add(new SelectOption('Testr','Testrrrr'));
	}

}