({
    init : function(component, event, helper) {
        helper.getLead(component, event, helper);
        
    },
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    convert :function(component, event, helper) {
        let opportunityName = component.get("v.opportunityName");
        let leadRecord = component.get("v.lead");
        if(opportunityName === '' || opportunityName === undefined) {
            component.set("v.pageMessage","Opportunity name should not be empty.");
            return;
        }
        if(leadRecord.Merchant__c == '' || leadRecord.Merchant__c == undefined) {
            component.set("v.pageMessage","Please select merchant.");
            return;
        }
        component.set("v.pageMessage","");
        
        helper.convertLeadToOpportunity(component, event, helper);
        
    }
})