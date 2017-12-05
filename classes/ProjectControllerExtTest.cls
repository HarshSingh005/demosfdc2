/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ProjectControllerExtTest 
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class of ProjectControllerExt class
 * Created Date : July 28, 2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
@isTest
private class ProjectControllerExtTest {
    static Project__c proj;
	private static testMethod void test() {
	    createTestData();
	    Test.startTest();
	    ApexPages.StandardController stdCon = new ApexPages.StandardController(new Project__c());
	    ProjectControllerExt ext = new ProjectControllerExt(stdCon);
	    System.assertEquals(null, stdCon.getId());
	    
	    ApexPages.StandardController stdCon1 = new ApexPages.StandardController(proj);
	    ProjectControllerExt ext1 = new ProjectControllerExt(stdCon1);
	    ext1.save();
	    System.assertEquals(null,ext1.save());
	    createOpp(ext1);
	    ext1.save();
	    Test.stopTest();
	}
	private static void createOpp(ProjectControllerExt ext1){
	    ext1.oppModel.opp.StageName = 'Cultivation';
	    ext1.oppModel.opp.CloseDate = Date.Today().addMonths(2);
	}
	static void createTestData(){
	    proj = TestUtils.createProject('testProject','Afghanistan','Available',false);
	    ProjectModel pr = new ProjectModel(proj);
	    pr.saveProject();
	    
	}

}