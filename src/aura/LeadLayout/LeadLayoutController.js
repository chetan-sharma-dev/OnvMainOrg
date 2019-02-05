({
    doInit: function(component, event, helper) {
        // Prepare a new record from template
        var recordId = component.get("v.recordId");
        console.log('sad'+recordId);
        if(recordId != null){
        	helper.getData(component, recordId);
            console.log('dsd');
            //component.set("v.LeadObj",l);
        } else{
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            component.set("v.LeadObj.OwnerId",userId);
        }
    },
	save : function(component, event, helper) {
		console.log('save');
        //Apply validation on Lead Title, Account, Contact, LeadSource, Sales Process
        var leadObj = component.get("v.LeadObj");
        //console.log(LeadObj.Title);
        helper.handleErrors(component, leadObj);
        if(component.get("v.pageMessage").length == 0){
            helper.save(component,leadObj);
        }
	},
    closeModel : function(component){
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Lead"
        });
        homeEvt.fire();
    }
})