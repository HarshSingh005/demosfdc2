/***********************************************************************************************************
* Appirio, Inc
* Name         : LightningSelfRegisterControllerTest
* Created By   : Ravi Chauhan (Appirio)
* Purpose      : Test class for LightningSelfRegisterController
* Created Date : 26/July/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 07/26/2016                   Ravi Chauhan            Created
**********************************************************************************************************/

@isTest
public class LightningSelfRegisterControllerTest {
    
    private static String extraFieldSet = '{\n' +
    ' "dbRequired" : true,\n' +
    ' "fieldPath" : "test",\n' +
    ' "label" : "test label",\n' +
    ' "required" : false,\n' +
    ' "type" : "test",\n' +
    ' "value" : 123\n' +
    '}';
    private static Account acc;
    
    @isTest
    public static void testSelfRegister(){
        
        LightningSelfRegisterController controller = new LightningSelfRegisterController();
        
        LightningSelfRegisterController.selfRegister('FirstName','LastName','LightningSelfRegisterController@gmail.com','Test@0010','Test@0010','12311234bhdjsdh','regConfirmUrl',JSON.serialize(extraFieldSet),'startUrl',True);
        
    }
    
    //@isTest
    public static void testSelfRegisterWhenExtraFieldSetIsNull(){
        createTestData();
        String accountid = String.valueOf(acc.Id);
        LightningSelfRegisterController controller = new LightningSelfRegisterController();
        
        LightningSelfRegisterController.selfRegister('FirstName','LastName','LightningSelfRegisterController@gmail.com','Test@0010','Test@0010',accountid,'regConfirmUrl',null,'startUrl',True);
        
    }
    
    @isTest
    public static void testSelfRegisterWhenLastNameAndEmailIsBlank(){
        
        LightningSelfRegisterController controller = new LightningSelfRegisterController();
        
        LightningSelfRegisterController.selfRegister('FirstName','','','Test@0010','Test@0010','12311234bhdjsdh','regConfirmUrl',extraFieldSet,'startUrl',True);
        
    }
    
    @isTest
    public static void testgetExtraFields(){
        
        LightningSelfRegisterController controller = new LightningSelfRegisterController();
        
        LightningSelfRegisterController.getExtraFields('Test');
        
    }
    
    private static void createTestData(){
        acc = TestUtils.createAccount('Test Account',true);
    }

}