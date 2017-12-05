/**
* Appirio (c) - 2017
*
* Modified By         Modified Date       Reason
* Alexander Miller      3.15.2017        00190837
* Dimpesh K Gehlot		7.17.2017		 T-617693 commented code
* Dimpesh K Gehlot		7.18.2017		 T-617694 uncommented code and changed Cart__c to Cart_Item__c
*/
public abstract class TFT_CartItems {
    // DG T-617693
	// DG T-617694 uncommented code and changed Cart__c to Cart_Item__c
    public static Integer count(String userId) {
        List<Cart_Item__c> cartList = [SELECT Id, Status__c, Session_Registration__c, 
                Session_Registration__r.Contact__c , Session_Registration__r.Listing_Session__c 
                FROM Cart_Item__c
                WHERE Status__c = 'In Process'
                // START AMILLER 
                AND Session_Registration__r.Status__c = 'In Process'
                // END AMILLER
                AND Session_Registration__c != Null
                AND Session_Registration__r.Contact__c != Null 
                AND Session_Registration__r.Listing_Session__c != Null
                AND CreatedById =: UserInfo.getUserId()
               ];
        System.Debug('#### cartList: ' + cartList);
        return cartList.size();
    }

    // START AMILLER 00190837 3.15.2017
    public static List<Cart_Item__c> getCartItems(){
        return ([SELECT Id, Name, Session_Registration__r.Id, Actual_Price__c, Session_Registration__r.Contact__r.Id,
                    Session_Registration__r.Contact__r.Name, Discount__c, Apply_Membership_Amount__c,
                 	// changed Membership_Price__c to Item_Price__c
                 	Item_Price__c, Financial_Aid_Applied__c,
                    Status__c, Session_Registration__r.Status__c, Membership_Registration__c
                FROM Cart_Item__c
                WHERE Status__c = 'In Process'
                // START AMILLER 
                AND Session_Registration__r.Status__c = 'In Process'
                // END AMILLER
                AND Session_Registration__c != Null
                AND Session_Registration__r.Contact__c != Null 
                AND Session_Registration__r.Listing_Session__c != Null
                AND CreatedById =: UserInfo.getUserId()
               ]);
    }

    public static List<Cart_Item__c> getCartItems(Set<Id> setSessionRegId){
        return ([SELECT Id, Status__c, Session_Registration__c, 
                        Session_Registration__r.Contact__c , Session_Registration__r.Listing_Session__c 
                FROM Cart_Item__c
                WHERE Status__c = 'In Process'
                // START AMILLER 
                AND Session_Registration__r.Status__c = 'In Process'
                // END AMILLER
                AND Session_Registration__c != Null
                AND Session_Registration__r.Contact__c != Null 
                AND Session_Registration__r.Listing_Session__c != Null
                AND CreatedById =: UserInfo.getUserId()
                AND Session_Registration__c IN : setSessionRegId
               ]);
    }
	// DG T-617693
	// DG T-617694
    // END AMILLER 00190837 3.15.2017
}