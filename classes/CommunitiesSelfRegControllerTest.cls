/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
@IsTest public with sharing class CommunitiesSelfRegControllerTest {
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegController() {
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        // Scenario | password != confirmPassword, So isValidPassword() returns False
        CommunitiesSelfRegController.populateUserId = true;
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null); 
        
        // Scenario | password == confirmPassword, So isValidPassword() returns True
        CommunitiesSelfRegController.populateUserId = true;
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        System.assert(controller.registerUser() == null);
        
        CommunitiesSelfRegController.populateUserId = true;
        controller.password = null;
        controller.confirmPassword = null;
        System.assert(controller.registerUser() != null); 
        
    }    
}