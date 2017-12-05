/***********************************************************************************************************
* Appirio, Inc
* Name         : DisplayObjectDetailTest
* Created By   : Ravi Chauhan (Appirio)
* Purpose      : Test class for DisplayObjectDetail
* Created Date : 28/July/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 
**********************************************************************************************************/
@isTest
public class DisplayObjectDetailTest {
    
    // Method to test that the objects are getting fetched from Org and populated in repecting lists.
    @isTest
    public static void testObjectList(){
        
        DisplayObjectDetail dob = new DisplayObjectDetail();
        
        // Assertion | Both the lists are empty initially
        System.assertEquals(0, dob.standardObjList.size());
        System.assertEquals(0, dob.customObjList.size());
        
        // Calling the ObjectList() method to fetch all the sobjects and custom objects from Org
        dob.ObjectList();
        
        // Assertion | Either of the list has been populated with the objects defined in Organisation
        System.assert(dob.standardObjList.size() != 0 || dob.customObjList.size() != 0);
     }
}