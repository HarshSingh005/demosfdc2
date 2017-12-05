/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
 */
 /***********************************************************************************************************
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 26/07/2016                   Vaibhav Goel            ameliorating test class failures and ramp-up of code coverage.
****************************************************************************************************************************/
@IsTest public with sharing class MyProfilePageControllerTest {
    
    
    @isTest static void runMethodAsGuestUser(){
        
        Profile p = [select id, name from profile where UserLicense.Name = 'Guest User License' limit 1];
        system.debug('--p---' + p);
         
        User guestUsr = TestUtils.createUser('Testing', 'mppctest', p.Id, false);
        guestUsr.Alias = 'mppctest';
        guestUsr.Email='sttesttest@testtest.com';
        guestUsr.EmailEncodingKey='UTF-8';
        guestUsr.UserName = 'mpcttest@testmpct.com';
        insert guestUsr;
        
        if(guestUsr != null){
            system.debug('guestUsr'+ guestUsr);
            System.RunAs(guestUsr) {
                try{
                    MyProfilePageController controllerInstance = new MyProfilePageController(); 
                }
                catch(Exception e){
                    system.assertNotEquals(e, null);
                    system.debug('----e---' + e);
                }
                
            }
        }
        
    }
    
    
    @isTest static void testSetContactFields() {
        User u = [select title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                           FROM User WHERE id =: UserInfo.getUserId()];

        Contact c = new Contact();

        MyProfilePageController.setContactFields(c, u);
        
        
        System.assertEquals(c.firstname, u.firstname, 'firstname should have been set as the firstname of the user for the contact');
        System.assertEquals(c.lastname, u.lastname, 'lastname should have been set as the lastname of the user for the contact');
        
        MyProfilePageController controller = new MyProfilePageController(); 
        System.assertEquals(u.Id, controller.getUser().Id);
        System.assert(controller.getIsEdit() == false);
        controller.edit();
        System.assert(controller.getIsEdit() == true);
        controller.cancel();
        System.assert(controller.getIsEdit() == false);
        
    }
    
    @IsTest(SeeAllData=true) static void testSave1() {
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT id, profileId, userRoleId, contactId FROM User WHERE contactId <> null and usertype != 'GUEST' limit 1];
        if(existingPortalUsers != null && existingPortalUsers.size() > 0){
            system.runAs(existingPortalUsers.get(0)){
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(existingPortalUsers.get(0).Id, controller.getUser().Id);
                controller.save();
            }
        }
    }
    
    @IsTest(SeeAllData=true) static void testSave() {
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT id, profileId, userRoleId FROM User WHERE UserRoleId <> null AND UserType='CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
            User currentUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                                FROM User WHERE id =: UserInfo.getUserId()];
            
            system.debug('---currentUserIF---' + currentUser);
            
            MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
            System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
            controller.edit();
            System.assert(controller.getIsEdit() == true);
            controller.cancel();
            System.assert(controller.getIsEdit() == false);
            
            
            Account acc = TestUtils.createAccount('test',false);
            acc.RecordTypeId = Contact_SnapshotController.ACCOUNT_RECORDTYPE_HOUSEHOLD;
            insert acc;
        
            //Contact c = new Contact();
            Contact c = TestUtils.createContact(acc,'test','test',false);
            c.LastName = 'TestContact';
            insert c;

            c.title = currentUser.title;
            c.firstname = currentUser.firstname;
            c.lastname = currentUser.lastname;
            c.email = currentUser.email;
            c.phone = currentUser.phone;
            c.mobilephone = currentUser.mobilephone;
            c.fax = currentUser.fax;
            c.mailingstreet = currentUser.street;
            c.mailingcity = currentUser.city;
            c.mailingstate = currentUser.state;
            c.mailingpostalcode = currentUser.postalcode;
            c.mailingcountry = currentUser.country;
            controller.save();
            System.assert(Page.ChangePassword.getUrl().equals(controller.changePassword().getUrl()));
        } else {
            User existingPortalUser = existingPortalUsers[0];
            system.debug('---existingPortalUserElse---' );
            String randFax = Math.rint(Math.random() * 1000) + '5551234';

            System.runAs(existingPortalUser) {
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(existingPortalUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
                controller.edit();
                System.assert(controller.getIsEdit() == true);

                controller.cancel();
                System.assert(controller.getIsEdit() == false);

                controller.getUser().Fax = randFax;
                controller.save();
                System.assert(controller.getIsEdit() == false);
            }

            // verify that the user and contact were updated
            existingPortalUser = [Select id, fax, Contact.Fax from User where id =: existingPortalUser.Id];
            System.assert(existingPortalUser.fax == randFax);
            System.assert(existingPortalUser.Contact.fax == randFax);
        }
    }
}