({
  /*  getInput : function(cmp, event,helper) {
        alert('hi');
        var validity = cmp.find("myinput").get("v.validity");
        var txt=parseInt(event.getParams().keyCode);
        console.log('text--->'+txt);
        //console.log(txt);
        console.log('Event log===> '+String.fromCharCode(txt)); 
      
    }
    */
        
    handleChange : function(cmp, event,helper) {
           var txtstrg = cmp.find("myinput").get("v.value");
            if(txtstrg.length>0){  
             var gtAsci= txtstrg.substr(txtstrg.length - 1)
              console.log(gtAsci.charCodeAt(0));
            } 
        }
})