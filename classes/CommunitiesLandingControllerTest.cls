/***********************************************************************************************************
* Appirio, Inc
* Name         : CommunitiesLandingControllerTest
* Purpose      : An apex page controller that takes the user to the right start page based on credentials or lack thereof
* 
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 28/07/2016                   Ashu Gupta             Increased code coverage 
**********************************************************************************************************/

@IsTest public with sharing class CommunitiesLandingControllerTest {
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        CommunitiesLandingController controller = new CommunitiesLandingController();
        
        PageReference pageRef = controller.forwardToStartPage();
        //returned PageReference is not null
        System.assertNotEquals(pageRef,null);
      }
}