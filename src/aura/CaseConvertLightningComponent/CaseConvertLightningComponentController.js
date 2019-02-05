({
	doInit : function(component, event, helper) {
		helper.init(component);
	},
    convertToLead : function(component, event, helper) {
        if(component.get("v.pageMessage").length == 0){
            helper.handleErrors(component);
            if(component.get("v.fieldErrorMessage").length == 0){
                helper.convert(component);
            }
        }
    },
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})