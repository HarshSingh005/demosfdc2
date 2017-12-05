/**
*    @ClassName    : CartTriggerHandler 
*    @CreatedOn    : 6/OCT/2016
*    @Task Number  : T-543594
*    @ModifiedBy   : Trekbin
*    @Description  : This Class is used to update fields of Cart records.
*
*  Modified By         Modified Date          Reason
*  Alexander Miller     4.21.2017            00194215
*  Alexander Miller     5.30.2017            00197265
*  Dimpesh K Gehlot		7.17.2017 			 T-617693
*  Dimpesh K Gehlot		7.18.2017			 T-617694 uncommented codes to bring back functionality
*/
public without sharing class CartTriggerHandler
{
    /* Static - Variable*/
    public Static Boolean isRecursion = false;
    public static User userObj;
    public static Contact contactObj;
    public static Account accountObj;
    /* Static - Variable*/
    
    /*Start - Constructor*/
    public CartTriggerHandler()
    {
        for(User u : [SELECT Id, ContactId, ChapterID__c FROM User WHERE Id = :UserInfo.getUserId() limit 1]){
            userObj = u;
        }
        if(userObj != null){
            for(Contact c : [SELECT Id, Military__c FROM Contact WHERE Id = :userObj.ContactId limit 1]){
                contactObj = c;
            }
            for(Account acc : [SELECT Id, Website, Membership_Offered__c FROM Account WHERE Id = :userObj.ChapterID__c limit 1]){
                accountObj = acc;
            }
        }
    }
    /*End - Constructor*/
    
    /*
        @MethodName : onAfterInsert 
        @Description: This method is called on before insert of Cart records // Cart Item records
    */

    public void onAfterInsert(Map<Id, Cart_Item__c> mapNew)
    {
    
        // Modified the below 1 line AMILLER 4.21.2017 00194215 updating hidden fields for historical data processing
        updateDiscounts(mapNew);
        updateCartField(new Map<Id, Cart_Item__c>(), mapNew); 
            
        
    }
    
    /*
        @MethodName : onAfterUpdate
        @Description: This method is called on before update of Cart records
    */
    public void onAfterUpdate(Map<Id, Cart_Item__c> mapOld, Map<Id, Cart_Item__c> mapNew)
    {
        updateCartField(mapOld, mapNew);
    }
    /* START AMILLER 4.21.2017 00194215
    *
    * updateDiscounts
    *
    * This function takes the old formula field algorithms and places them here 
    * since we saw any issue with historical data being overwritten on parent record
    * changes.
    */
    // DG
    public void updateDiscounts(Map<Id, Cart_Item__c> mapNew){
		List<Cart_Item__c> listOfCarts = new List<Cart_Item__c>();
		
        listOfCarts = ([SELECT Actual_Price__c, Apply_Membership_Amount__c, 
                        				//Cart_Price__c,  commented as this needs to be removed
        								// DG T-617694
        								Donation1__c,
                        // changed reference to Cart__c.Charge_Token 
                                        Charge_Amount__c, Cart__r.Charge_Token__c, CreatedById, CreatedDate, Discount__c, Donation__c, 
                                        Financial_Aid_Amount__c, Financial_Aid_Applied__c, Financial_Aid_Percent__c, Id, IsDeleted, 
                                        LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Membership_Discount__c, 
                                        // changed memberPrice to itemPrice
                                        Item_Price__c, Membership_Registration__c, Military_Discount__c, Name, 
                                        // DG T-617694 commented as ownerId not available on Cart_Item__c
                                        //OwnerId, 
                                        Participant__c, 
                                        Payment_Information__c, Session_Registration__c, Sibling_Discount__c, Status__c, SystemModstamp,
                                        Session_Registration__r.Listing_Session__r.Membership_Discount_Active__c, 
                                        Session_Registration__r.Listing_Session__r.Presented_By__r.Membership_Discount_Amount__c,
                                        Session_Registration__r.Listing_Session__r.Military_Discount_Active__c,
                                        Session_Registration__r.Listing_Session__r.Sibling_Discount_Active__c,
                                        Session_Registration__r.Listing_Session__r.Presented_By__r.Military_Discount_Amount__c,
                                        Session_Registration__r.Listing_Session__r.Actual_Price__c,
                                        Session_Registration__r.Listing_Session__r.Presented_By__r.Sibling_Discount_Percentage__c,
                                        Session_Registration__r.Listing_Session__r.Presented_By__r.Military_Discount_Percentage__c,
                                        Session_Registration__r.Listing_Session__r.Presented_By__r.Membership_Discount_Percentage__c,
                                        Session_Registration__r.Listing_Session__r.Presented_By__r.Sibling_Discount_Amount__c
                                    FROM Cart_Item__c
                                    WHERE Id IN :mapNew.keySet()]);
        

        Map<Id, Cart_Item__c> tempMap = new Map<Id, Cart_Item__c>();

        for(Cart_Item__c objCart : listOfCarts)
        {
            // membership discount
            if(objCart.Session_Registration__r.Listing_Session__r.Membership_Discount_Active__c == true)
            {
                if(String.isBlank(String.valueOf(objCart.Session_Registration__r.Listing_Session__r.Presented_By__r.Membership_Discount_Amount__c)))
                {
                    objCart.Membership_Discount_hidden__c = objCart.Session_Registration__r.Listing_Session__r.Actual_Price__c * (Double.valueOf(objCart.Session_Registration__r.Listing_Session__r.Presented_By__r.Membership_Discount_Percentage__c) / 100);
                }
                else
                {
                    objCart.Membership_Discount_hidden__c = objCart.Session_Registration__r.Listing_Session__r.Presented_By__r.Membership_Discount_Amount__c;
                }
            }
            else
            {
                objCart.Membership_Discount_hidden__c = null;
            }

            // military discount 
            if(objCart.Session_Registration__r.Listing_Session__r.Military_Discount_Active__c == true)
            {
                if(String.isBlank(String.valueOf(objCart.Session_Registration__r.Listing_Session__r.Presented_By__r.Military_Discount_Amount__c)))
                {
                    objCart.Military_Discount_hidden__c = objCart.Session_Registration__r.Listing_Session__r.Actual_Price__c * (Double.valueOf(objCart.Session_Registration__r.Listing_Session__r.Presented_By__r.Military_Discount_Percentage__c) / 100);
                }
                else
                {
                    objCart.Military_Discount_hidden__c = objCart.Session_Registration__r.Listing_Session__r.Presented_By__r.Military_Discount_Amount__c;
                }
            }
            else
            {
                objCart.Military_Discount_hidden__c = null;
            }

            // sibling discount
            if(objCart.Session_Registration__r.Listing_Session__r.Sibling_Discount_Active__c == true)
            {
                if(String.isBlank(String.valueOf(objCart.Session_Registration__r.Listing_Session__r.Presented_By__r.Sibling_Discount_Amount__c)))
                {
                    objCart.Sibling_Discount_hidden__c = objCart.Session_Registration__r.Listing_Session__r.Actual_Price__c * (Double.valueOf(objCart.Session_Registration__r.Listing_Session__r.Presented_By__r.Sibling_Discount_Percentage__c) / 100);
                }
                else
                {
                    objCart.Sibling_Discount_hidden__c = objCart.Session_Registration__r.Listing_Session__r.Presented_By__r.Sibling_Discount_Amount__c;
                }
            }
            else
            {
                objCart.Sibling_Discount_hidden__c = null;
            }

            tempMap.put(objCart.Id, objCart);
        }


        update tempMap.values();
    }
    // END AMILLER 4.21.2017 00194215

    /**
        @MethodName    : updateEngagementTypeFields 
        @Description  : This method is used to update fields of Engagement Type records.
    */
    // DG
    
    private void updateCartField(Map<Id, Cart_Item__c> mapOld, Map<Id, Cart_Item__c> mapNew)
    {
        
        Set<Id> setSesRegId = new Set<Id>();
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setContactId = new Set<Id>();
        
        Set<Id> setConActiveMemReg = new Set<Id>();
        Set<Id> setPartEngTypeConId = new Set<Id>();
       // Set<Id> setAccMiltAffilation = new Set<Id>();
        Set<Id> setCartNonZeroFinAid = new Set<Id>();
        
        Map<Id, Cart_Item__c> mapCartToUpdate = new Map<Id, Cart_Item__c>();
        Map<Id, Integer> mapAccountIdToPartConCount = new Map<Id, Integer>();
        Map<Id, Session_Registration__c> mapSesRegIdToAccountId = new Map<Id, Session_Registration__c>();
        
        for(Cart_Item__c objCart : mapNew.Values())
        {
            System.debug('debigRahulCart'+objCart);
            if(objCart.Financial_Aid_Applied__c != Null && objCart.Financial_Aid_Applied__c != 0)
            {
                setCartNonZeroFinAid.add(objCart.Id);
            }
            
            if(Trigger.isInsert && objCart.Session_Registration__c != Null)
            {
                setSesRegId.add(objCart.Session_Registration__c);
            }
            /*
            *
            * START AMILLER 5.15.2017 00194215
            *
            * Removed extra logic on whats needed to update the record based on this case.
            */
    
            //else if(Trigger.isUpdate && objCart.Session_Registration__c != Null && 
            //        (objCart.Discount__c != mapOld.get(objCart.Id).Discount__c || 
            //         objCart.Session_Registration__c != mapOld.get(objCart.Id).Session_Registration__c))
            else if(Trigger.isUpdate && objCart.Session_Registration__c != Null)
            {
                setSesRegId.add(objCart.Session_Registration__c);
            }
            // END AMILLER 5.15.2017 00194215
        }
        for(Session_Registration__c objSessReg : [SELECT Id, Contact__c, Contact__r.AccountId
                                                    FROM Session_Registration__c
                                                   WHERE Contact__c != Null
                                                     AND Id IN : setSesRegId])
        {
            setContactId.add(objSessReg.Contact__c);
            mapSesRegIdToAccountId.put(objSessReg.Id, objSessReg);
            
            if(objSessReg.Contact__r.AccountId != Null)
            {
                setAccountId.add(objSessReg.Contact__r.AccountId);
            }
        }
        
        //for(Engagement_Type__c objEngType : [SELECT Id, Contact__c, Contact__r.AccountId  FROM Engagement_Type__c  WHERE Participation_Status__c = 'Participant'  AND Contact__r.AccountId != Null AND Contact__r.AccountId IN : setAccountId]) // Commented for T-617691

        for(Engagement_Type__c objEngType : [SELECT Id, Contact__c, Contact__r.AccountId  FROM Engagement_Type__c  WHERE Contact__r.AccountId != Null AND Contact__r.AccountId IN : setAccountId])
        {
            if(!setPartEngTypeConId.contains(objEngType.Contact__c))
            {
                setPartEngTypeConId.add(objEngType.Contact__c);
                
                if(!mapAccountIdToPartConCount.containsKey(objEngType.Contact__r.AccountId))
                {
                    mapAccountIdToPartConCount.put(objEngType.Contact__r.AccountId, 1);
                }
                else
                {
                    mapAccountIdToPartConCount.put(objEngType.Contact__r.AccountId, mapAccountIdToPartConCount.get(objEngType.Contact__r.AccountId) + 1);
                }
            }
        }
        for(Membership_Registration__c objMR : [SELECT Id, Contact__c
                                                  FROM Membership_Registration__c
                                                 WHERE Active_Status__c = true
                                                   AND Contact__c != Null
                                                   AND Contact__c IN : setContactId])
        {
            setConActiveMemReg.add(objMR.Contact__c);
        }
        for(Cart_Item__c objCart : mapNew.Values())
        {
            system.debug('-CartTriggerHandler-xx-------objCart----143---'+objCart);
            
            Boolean isUpdated = false;
            Boolean isSiblingDis = false;
            Boolean isMilitaryDis = false;
            Boolean isMembershipDis = false;
            
            if(setCartNonZeroFinAid.contains(objCart.Id))
            {
                mapCartToUpdate.put(objCart.Id, new Cart_Item__c(Id = objCart.Id, Discount__c = 0));
                continue;
            }
            if(mapSesRegIdToAccountId.containsKey(objCart.Session_Registration__c))
            {
                if(mapAccountIdToPartConCount.containsKey(mapSesRegIdToAccountId.get(objCart.Session_Registration__c).Contact__r.AccountId))
                {
                    if(mapAccountIdToPartConCount.get(mapSesRegIdToAccountId.get(objCart.Session_Registration__c).Contact__r.AccountId) > 1)
                    {
                        isSiblingDis = true;
                    }
                }
                
                if(contactObj != null && contactObj.Military__c)
                {
                    isMilitaryDis = true;
                }
                if(setConActiveMemReg.contains(mapSesRegIdToAccountId.get(objCart.Session_Registration__c).Contact__c))
                {
                    isMembershipDis = true;
                }
            }
            decimal discountToUpdate = 0;
            map<string, decimal> mapDiscountTypeDiscountValue = new map<string, decimal>();
            /* START AMILLER 4.21.2017 00194215
            * 
            * changing these to hidden fields since they will hold the "true" historical data
            *
            * mapDiscountTypeDiscountValue.put('isSiblingDis',objCart.Sibling_Discount__c != null ? objCart.Sibling_Discount__c: 0);
            * mapDiscountTypeDiscountValue.put('isMilitaryDis',objCart.Military_Discount__c != null ? objCart.Military_Discount__c: 0);
            * mapDiscountTypeDiscountValue.put('isMembershipDis',objCart.Membership_Discount__c != null ? objCart.Membership_Discount__c: 0);
            */
		
            mapDiscountTypeDiscountValue.put('isSiblingDis',objCart.Sibling_Discount_hidden__c != null ? objCart.Sibling_Discount_hidden__c: 0);
            mapDiscountTypeDiscountValue.put('isMilitaryDis',objCart.Military_Discount_hidden__c != null ? objCart.Military_Discount_hidden__c: 0);
            mapDiscountTypeDiscountValue.put('isMembershipDis',objCart.Membership_Discount_hidden__c != null ? objCart.Membership_Discount_hidden__c: 0);
            
            // END AMILLER 4.21.2017 00194215

            System.debug(mapDiscountTypeDiscountValue);
            System.debug(accountObj);

            for(string s : mapDiscountTypeDiscountValue.keySet()){
                /* START AMILLER 4.21.2017 00194215
                * 
                * refactored since the highest possible discount was not consistantly given
                */
                //if((discountToUpdate < mapDiscountTypeDiscountValue.get(s)) && ((s == 'isSiblingDis' && isSiblingDis) || (s == 'isMilitaryDis' && isMilitaryDis) || (s == 'isMembershipDis' && isMembershipDis && accountObj.Membership_Offered__c)) ){
                //    discountToUpdate = mapDiscountTypeDiscountValue.get(s);
                //    system.debug('discountToUpdateRahulrahul'+discountToUpdate);
                //    isUpdated = true;
                //}
		
                Boolean setDiscountToCurrent = false;
                
                if(discountToUpdate < mapDiscountTypeDiscountValue.get(s))
                {
                    // Modified below two lines AMILLER 5.30.2017 00197265
                    //if(!s.equalsIgnoreCase('isMembershipDis')){
                    if((!s.equalsIgnoreCase('isMembershipDis')) && ((s == 'isSiblingDis' && isSiblingDis) || (s == 'isMilitaryDis' && isMilitaryDis))){
                        setDiscountToCurrent = true;
                    }
                    else if((s == 'isMembershipDis' && isMembershipDis) && accountObj != null && accountObj.Membership_Offered__c)
                    {
                        setDiscountToCurrent = true;
                    }

                    if(setDiscountToCurrent){
                        discountToUpdate = mapDiscountTypeDiscountValue.get(s);
                        isUpdated = true;
                    }
                }
                // END AMILLER 4.21.2017 00194215
            }
            if(isUpdated){
                if(objCart.Actual_Price__c <= discountToUpdate){
                    discountToUpdate = objCart.Actual_Price__c;
                }
                mapCartToUpdate.put(objCart.Id, new Cart_Item__c(Id = objCart.Id, Discount__c = discountToUpdate));
            }
        }
        if(!mapCartToUpdate.isEmpty())
        {
            System.debug('#### mapCartToUpdate.values(): ' + mapCartToUpdate.values());
            isRecursion = true;
            Database.update(mapCartToUpdate.values(), true);
        }
    }
    
}