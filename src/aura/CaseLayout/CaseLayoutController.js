({
	myAction : function(component, event, helper) {
		
	},
    
    cancelDialog : function(component, helper) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Case"
        });
        homeEvt.fire();
    }
})