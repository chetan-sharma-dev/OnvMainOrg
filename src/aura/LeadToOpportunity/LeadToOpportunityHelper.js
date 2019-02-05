({
    getLead : function(component, event, helper) {
        var leadId;
        var actionGetLead = component.get("c.getLead");
        console.log('Init');
        console.log(component.get("v.recordId"));
        actionGetLead.setParams({"leadId" : component.get("v.recordId")});
        actionGetLead.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getError());
            if (state === "SUCCESS") {
                console.log(state);
                console.log(response.getReturnValue());
                if(response.getReturnValue().Status == 'Qualified') {
                    component.set("v.isValid", false);
                    component.set("v.pageMessage", 'Qualified leads cannot be converted to Opportunity.');
                }
                component.set("v.lead", response.getReturnValue());
            } else if(state === "ERROR") {
                
                helper.handleError(component, response.getError());
                
            } else {
                //console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(actionGetLead);
    },
    
    convertLeadToOpportunity : function(component, event, helper) {
        let action = component.get("c.createOpportunity");
        action.setParams({
            "leadRecord": component.get("v.lead"),
            "opportunityName": component.get("v.opportunityName")
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                
                var sObectEvent = $A.get("e.force:navigateToSObject");
                sObectEvent .setParams({
                    "recordId": response.getReturnValue().Id  ,
                    "slideDevName": "Details"
                });
                sObectEvent.fire(); 
                
            } else if(state === "ERROR") {
                
                helper.handleError(component, response.getError());
                
            } else {
                //console.log('Transaction failed');
            }
        });
        $A.enqueueAction(action);
    },
    
    handleError : function(component, errors) {
        let message = 'Unknown error'; // Default error message
        
        // Retrieve the error message sent by the server
        if (errors && Array.isArray(errors) && errors.length > 0) {
            message = errors[0].message;
        }
        
        // Display the message
        component.set("v.pageMessage",message);
    }
})