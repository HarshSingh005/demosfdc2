({
    doInit : function(component ,event ,handler){
      console.log('Inside the handler function');  
        //Calling the function to fetch the json string from the server using 
        var action =component.get("c.multpcklst");//Setting the name of function
        action.setCallback(this,function(response){ //calling and getting the response from the controller
            var state=response.getState();
            if(state==='SUCCESS'){
            console.log('State--->'+state); //Checking the state of response
            var resp=response.getReturnValue();    
            console.log('Response From Controller'+resp);  
              var respsplt=resp.split(",");
           //Logic to create elements of the array with new array respsplt
            var myarr=[];  //initializing the array to input the list
            console.log('State of the response'+state+'Result>>>'+response.getReturnValue()+'After Splits');
            for(var i=0;i<respsplt.length;i++){//iterating the list
             var ip=respsplt[i].replace(/[^a-zA-Z0-9 ]/g, "");//removing the extra elements from the string
             myarr.push(ip);//putting the element in the list
            console.log(ip);}
            console.log(myarr);
            component.set("v.strlst",myarr);//pushing the elements in the list
            console.log('--=='+component.get("v.strlst"));   
            }                     
         }); $A.enqueueAction(action);//Final call of the function.
        
        
    },clkevnt : function(component, event, helper) {
	var selectd=event.getSource().get("v.label");
    var slcft=component.find("t1");//don't use aura ID ever for this since once the value is set that will not updated
    //var ft2=component.find("t2");                      
     component.set("v.checkval",selectd);   
     console.log('Value is--->'+component.get("v.checkval")+'---'+slcft.get("v.value"));
    }, 
  handleMouseLeave: function(component, event, helper) {
   /* component.set("v.dropdownOver",false);
    var mainDiv = component.find('main-div');
    $A.util.removeClass(mainDiv, 'slds-is-open');*/
      console.log('Selecting the value in the drop down');
  },
   
  handleMouseEnter: function(component, event, helper) {
  console.log('event of selecting the value in the drop down');
  },
   handleSelection : function(component, event, helper){
   var item = event.currentTarget;
       console.log('SFDC Dummies'+item.dataset);
  }
    
})