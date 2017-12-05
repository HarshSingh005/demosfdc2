/**
 * Class containing tests for SiteRegisterController
 */
@IsTest public with sharing class SiteRegisterControllerTest {
    @IsTest(SeeAllData=true) static void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        // To overcome this, When the code is run via Test class, setting up user id in code, to increase coverage
        System.assert(controller.registerUser() != null);    
        
        // Scenario | password != confirmPassword, So isValidPassword() returns False
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);
        
        // Scenario | password == confirmPassword, So isValidPassword() returns True
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        System.assert(controller.registerUser() == null);
        
    }
}