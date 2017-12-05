/***********************************************************************************************************
* Appirio, Inc
* Name         : LightningLoginFormControllerTest
* Created By   : Ashu Gupta (Appirio)
* Purpose      : Test class for LightningLoginFormController
* Created Date : 26/July/2016
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 07/26/2016                   Ashu Gupta            Created
**********************************************************************************************************/

@isTest
private class LightningLoginFormControllerTest {

    private static testMethod void test() {
        String startURL = 'startURL';
        String communityURL = '/childfund--bridgedev.cs19.my.salesforce.com';
        Id networkId = Network.getNetworkId();
        LightningLoginFormController controller = new LightningLoginFormController();
    
   
        LightningLoginFormController.login('testUsername','testPassword','url');
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityURL,startURL);
    }

    @isTest
    private static void test1() {
        /*String startURL = 'startURL';
        String communityURL = '/childfund--bridgedev.cs19.my.salesforce.com';
        Id networkId = Network.getNetworkId(); */
        
        String communityUrl = '/childfund--bridgedev.cs19.my.salesforce.com';
        String startUrl = '/childfund--bridgedev.cs19.my.salesforce.com';
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,startUrl);
        List<AuthProvider> authPrvs = authConfig.getAuthProviders();

        String sso = Auth.AuthConfiguration.getAuthProviderSsoUrl(communityUrl, startUrl, 'developerName');
        
        Id networkId = Network.getNetworkId(); 
        //System.debug(Network.getNetworkId());
        /*LightningLoginFormController.getIsUsernamePasswordEnabled();
        LightningLoginFormController.getIsSelfRegistrationEnabled();
        LightningLoginFormController.getSelfRegistrationUrl();
        LightningLoginFormController.getForgotPasswordUrl();*/
        //LightningLoginFormController.getAuthConfig();
    }
}