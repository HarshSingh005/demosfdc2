({
    echo : function(component ,event ,handler){
        var nameField=component.find("client");
        var expname=nameField.get("v.value");
        //setting the output values
        console.log('testing'+expname);
        var action=component.get("c.accInfo");
        action.setParams({nm : expname});
        //calling the function of the apex class
        action.setCallback(this, function(response) {
            console.log('inside set callback');
            var state = response.getState();
            console.log('State From the server'+state);
            if (state === "SUCCESS") {
                var obj=JSON.stringify(response.getReturnValue());
                var obj1=JSON.parse(obj);
                //  component.set("v.myText",obj1[1].Id);
                component.set("v.acList",obj1);
                console.log("Response from Server: " + JSON.stringify(response.getReturnValue()));
            }else if(state === "ERROR"){
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);        
    },
    editAccount : function(component, event, helper) {
        //Check if aura attribute is empty 
        var isEmpty = $A.util.isEmpty(component.get("v.acList"));
        console.log('Checkis empty '+isEmpty);
        var accList=component.get("{!v.acList}");
        var obj1=JSON.stringify(accList);
        var jsonObjArr=JSON.parse(obj1);
        var whichOne =   event.getSource().get("v.value");
        console.log('ID--'+whichOne);
        for(var count=0;count<jsonObjArr.length;count++)
        {
            // JSON Object 
            var JSONObj = jsonObjArr[count];
            // Map key : Contact Id
            var ConId = jsonObjArr[count].Id;
            if(ConId===whichOne){
                var myAcc=JSON.stringify(jsonObjArr[count]);
                var prs=JSON.parse(myAcc);
                console.log('Fianl outcome is as folloes'+myAcc);
                component.set("{!v.mAcc}",prs); 
                console.log('ACcount NAMes is'+jsonObjArr[count].Name);
                var accname= jsonObjArr[count].Name;
                component.set("{!v.acc}",accname);
                break;
            }
        }   
        console.log('Account List'+JSON.stringify(accList));
        var modal = component.find("myModal");
        var modalBackdrop = component.find("myModal-Back");
        // Now add and remove class
        $A.util.addClass(modal, 'slds-fade-in-open');
        $A.util.addClass(modalBackdrop, 'slds-fade-in-open');
        
    },openModal : function(component,event,helper) {
        var modal = component.find("myModal");
        var modalBackdrop = component.find("myModal-Back");
        // Now add and remove class
        $A.util.addClass(modal, 'slds-fade-in-open');
        $A.util.addClass(modalBackdrop, 'slds-fade-in-open');
    },
    closeModal : function(component, event, helper) {
        //find modal using aura id
        var modal = component.find("myModal");
        var modalBackdrop = component.find("myModal-Back");
        // Now add and remove class
        $A.util.removeClass(modal, 'slds-fade-in-open');
        $A.util.removeClass(modalBackdrop, 'slds-fade-in-open');
    },//Function to save the account records
    saveAccountRecord : function(component,event ,helper){
        var acobj=  component.get("v.mAcc");
        console.log('Account Object to update-->'+JSON.stringify(acobj));
        var action=component.get("c.updtAcco");
        action.setParams({acct : acobj});
        //calling the function of the apex class
        action.setCallback(this, function(response) {
            console.log('inside set callback');
            var state = response.getState();
            console.log('State From the server'+state);
            if (state === "SUCCESS") {
                var op=JSON.stringify(response.getReturnValue());
                console.log('State From the server is:'+state+'output'+JSON.stringify(response.getReturnValue()));
                //find modal using aura id
                if(op=='true'){
                    //logic to close the existing modal   
                    var modal = component.find("myModal");
                    var modalBackdrop = component.find("myModal-Back");
                    // Now add and remove class
                    $A.util.removeClass(modal, 'slds-fade-in-open');
                    $A.util.removeClass(modalBackdrop, 'slds-fade-in-open');
                    //Showing the success message for the record    
                    var svmodal = component.find("saveModal");
                    var svmodalBackdrop = component.find("saveModal-Back");
                    $A.util.addClass(svmodal, 'slds-fade-in-open');
                    component.set("{!v.msging}",'Account record have been saved successfully');
                    //get account id
                    var accobjs= component.get("v.mAcc");
                    var accstr=JSON.stringify(accobjs);
                    var accntobject=   JSON.parse(accstr);
                    console.log('Account ID=====>'+ accntobject.Id); 
                    //logic to update the record row in the table 
                    var accList=component.get("{!v.acList}");
                    var obj1=JSON.stringify(accList);
                    var jsonObjArr=JSON.parse(obj1);
                    //Logic to remove an object row at particular index
                          for(var count=0;count<jsonObjArr.length;count++){
                           var JSONObj = jsonObjArr[count];
                           var ConId = jsonObjArr[count].Id;
                              if(ConId==accntobject.Id){
                              jsonObjArr.splice(count,1);     
                              console.log('Updated array'+jsonObjArr);
                                jsonObjArr.push(accobjs);  
                                   }
                             }
                    component.set("{!v.acList}",jsonObjArr);
                    // $A.util.addClass(svmodalBackdrop, 'slds-fade-in-open');
                }
            }else if(state==="ERROR"){
            }            
        });
        $A.enqueueAction(action); 
        
    },closeSuccess : function(component,event,helper){
        var svmodal = component.find("saveModal");
        var svmodalBackdrop = component.find("saveModal-Back");
        $A.util.removeClass(svmodal, 'slds-fade-in-open');
        //  component.set("{!v.msging}",'');
        // $A.util.addClass(svmodalBackdrop, 'slds-fade-in-open');        
    },deleteAccount : function(component ,event ,helper){
         var whichOne =   event.getSource().get("v.value");
         var location;
         console.log('ID--'+whichOne);
        //logic for soft delete in the table              
            var accList=component.get("{!v.acList}");
            var obj1=JSON.stringify(accList);
            var jsonObjArr=JSON.parse(obj1);
         //Logic to remove an object row at particular index
            for(var count=0;count<jsonObjArr.length;count++){
             var ConId = jsonObjArr[count].Id;
                console.log('Counter==>'+count);
             if(ConId==whichOne){
                 location=count;
                      jsonObjArr.splice(count,1);     
                      console.log('Updated array'+jsonObjArr);
                          }
                    }
           component.set("{!v.acList}",jsonObjArr);        
    }   
})