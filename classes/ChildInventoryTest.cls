/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ChildInventoryTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the ChildInventory
 * Created Date : 22/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 22/07/2016                   Munib Ur Rehman         Created
 **********************************************************************************************************/
@isTest
public with sharing class ChildInventoryTest {

    static ChildInventory.ChildFilter filter;

    @isTest
	public static void testChildInventoryTest() {
	   createTestData();
       Test.startTest();
       ChildInventory.GetAvailableKidsForWeb(filter);
       Test.stopTest(); 
    } // END public static void testChildInventoryTest() {
    
    //create account and contact data
    public static void createTestData(){
    	 //creating account record
        filter = new ChildInventory.ChildFilter();
    }
    
} // END public with sharing class ChildInventoryTest