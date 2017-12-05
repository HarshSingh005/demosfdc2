({
	doInit : function(component, event, helper) { //Logic to fetch the picklist from the controller and show it on the page       
        var action=component.get("c.getSLApickList"); 
        action.setCallback(this,function(response){
             //this.handleResponse(response, component);
        var state = response.getState();
        if(state=="SUCCESS"){
            var resp=response.getReturnValue();
            var respsplt=resp.split(",");
           //Logic to create elements of the array with new array respsplt
            var myarr=[];
            console.log('State of the response'+state+'Result>>>'+response.getReturnValue()+'After Splits');
            for(var i=0;i<respsplt.length;i++){
                 var ip=respsplt[i].replace(/[^a-zA-Z0-9 ]/g, "");
                 myarr.push(ip);
                 console.log(ip);}
            console.log(myarr);
            component.set("v.chkopt",myarr); 
          }
            //Pre Selected checkbox in lightning
           var cmpId=component.find("chekbx");
            for (var i = 0; i < cmpId.length; i++) {
                if(cmpId[i].get("v.label")=='T1'){
                    cmpId[i].set("v.value",true);
                }else if(cmpId[i].get("v.label")=='T3'){
                    cmpId[i].set("v.value",true);
                }
            }
        });
      $A.enqueueAction(action); 
    },sendpickVal : function(component, event, helper) {//Logic to show the value of the selected picklist
    var selected = component.find("o").get("v.value");
    console.log(selected);
    },chekclicked : function(component ,  event , helper){//logic to get the check box 
        var getAllId=component.find("chekbx");  
          for (var i = 0; i < getAllId.length; i++) {//looping on the checkboxes to get the value and lebel associated with it
            if(getAllId[i].get("v.value") == true){ 
                var lb=getAllId[i].get("v.label");//Fetching the label of the check box
                var vlu=getAllId[i].get("v.value");//Fetching the value of the check box
               console.log('Value--->'+vlu+'check label'+lb);
           }
        } 
    }
})