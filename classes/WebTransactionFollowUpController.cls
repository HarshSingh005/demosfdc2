public class WebTransactionFollowUpController {
    public Web_Transaction__c webTransaction;
    public Id myId {get; set;}

    public WebTransactionFollowUpController () {
            // Query however you want, based on Country for example
        webTransaction= [select Id, Contact__c, Contact__r.Name from Web_Transaction__c where Id= :myId];
    }

    public Web_Transaction__c  getWebTransaction() {
    webTransaction= [select Id, Contact__c, Contact__r.Name from Web_Transaction__c where Id= :myId];
        return webTransaction;
    }
}