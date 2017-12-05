<aura:application >
<!--<ui:inputText label="Name" aura:id="name" keydown="{!c.getInput}"/>
<ui:inputText label="AName" aura:id="aname" keyup="{!c.getInput}"/>-->
  
   <!-- <c:TestApp123Comp/>The way you can embed a component in the application --> 
     <div class="slds-form-element">
      <lightning:input name="input" aura:id="myinput" label="Enter some text" onchange="{!c.handleChange}" />
      {!v.myinput}
        <lightning:input type="checkbox" label="Blue" name="blue" />
        <lightning:input type="email" label="Email" name="email" value="abc@domain.com" />
        <lightning:input type="radio" label="Red" name="red" value="red" checked="false" />
        <lightning:input type="radio" label="Blue" name="red" value="red" checked="false" />
        <lightning:input type="range" label="Number" name="number" min="0" max="10" />
        <lightning:input type="tel" label="Telephone" name="tel" value="343-343-3434" pattern="[0-9]{3}-[0-9]{3}-[0-9]{6}"/>
        <lightning:input type="toggle" label="Toggle value" name="togglevalue" checked="true" />
         <lightning:button variant="brand" label="Submit" onclick="{! c.handleClick }" />
    </div>
 <!-- <div class="slds-form-element"  >
      <lightning:button variant="brand" label="Search" 
                 onclick="{!c.buttonAction}" />

  </div>-->
</aura:application>