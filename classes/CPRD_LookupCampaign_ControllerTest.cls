/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CPRD_LookupCampaign_ControllerTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the CPRD_LookupCampaign_Controller
 * Created Date : 07/06/2016
 *
 * Date Modified                Modified By             Description of the update
  ------------------------------------------------------------------------------------------------------------------------
 * 07/06/2016                   Munib Ur Rehman         Created
 * 08/16/2016                   Ravi Chauhan            Increased Code Coverage, Used TestUtils method and Put assertions
 *************************************************************************************************************************/
@isTest
public with sharing class CPRD_LookupCampaign_ControllerTest {
    
    /**
     * @Description : Test method to test When proper query is run
     * 
     * @param       : null
     * @return      : null
     * 
     */ 
    @isTest
	public static void testCPRD_LookupCampaign_Controller() {
	    // Creation of Campaign
        Campaign testCamp = TestUtils.createCampaign('test camp',false);
        testCamp.Product_Type__c = 'Designated Fund';
        testCamp.Product_Sub_Type__c = 'Belated Christmas';
        insert testCamp;
        
        CPRD_LookupCampaign_Controller controller = new CPRD_LookupCampaign_Controller();
        
        // Before running the query | Assertion that doneLookup is false and list of campaign is null
	    System.assert(!controller.doneLookup);
	    System.assert(controller.campaigns == Null);
        
        // Run the Query
	    controller.query = 'camp';
	    controller.runQuery();
	    
	    // After running the query | Assertion that doneLookup is true and the campaign inserted has been populated in campaigns list
	    System.assert(controller.doneLookup);
	    System.assert(controller.campaigns != Null);
	    System.assertEquals('test camp', controller.campaigns.get(0).Name);

    } // END public static void testUpdateLocalPartnerNationalOffice() {
    
    /**
     * @Description : Test method to test When the query which is run is Blank
     * 
     * @param       : null
     * @return      : null
     * 
     */ 
    @isTest
	public static void testWhenQueryIsBlank() {

	    CPRD_LookupCampaign_Controller controller = new CPRD_LookupCampaign_Controller();
	    
	    // Before running the query | Assertion that doneLookup is false and list of campaign is null
	    System.assert(!controller.doneLookup);
	    System.assert(controller.campaigns == Null);
	    
	    // Run the Query
	    controller.query = '';
	    controller.runQuery();
	    
	    // After running the query | Assertion that doneLookup is still false and list of campaign is still null due to Blank Query
	    System.assert(!controller.doneLookup);
	    System.assert(controller.campaigns == Null);
      
    }
    
} // END public with sharing class MCSCPRRequestTest