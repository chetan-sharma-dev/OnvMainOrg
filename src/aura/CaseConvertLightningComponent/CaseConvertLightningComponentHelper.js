({
    init : function(component) {
        var recordId = component.get("v.recordId");
        var initAction = component.get("c.init");
        component.set("v.pageMessage", "");
        component.set("v.status", "New");
        component.set("v.leadSource", '');
        component.set("v.leadReceiptDate", (new Date()).toDateString());
        initAction.setParams({"caseObjId" : component.get("v.recordId")});
        initAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                if( response.getReturnValue() == null){
                    component.set("v.pageMessage",  "Insufficient privileges.");
                } else { 
                    component.set("v.caseObj", response.getReturnValue());
                    console.log(response.getReturnValue());
                    this.validateForConversion(component);
                }
            } 
        });
        $A.enqueueAction(initAction); 
    },
    validateForConversion : function(component){
        var leadObj = component.get("v.newLead");
        var caseObj = component.get("v.caseObj");
        var errorMessage = "";
        console.log('Status' + caseObj.Status);
        if( caseObj.Status == "Converted"){
            errorMessage = "Already Converted case cannot be converted to Lead.";
        } else if(caseObj.Status == "Closed"){
            errorMessage = "Closed case cannot be converted to Lead.\n "
            + "You can reopen the case if you want to convert the case.";
        } else if(caseObj.Sales_Process__c == "Support" || caseObj.Sales_Process__c == "Press" || caseObj.Sales_Process__c == "Design"){
            errorMessage = caseObj.Sales_Process__c + " Sales Process case cannot be converted to Lead.";
        } 
        if(errorMessage.length != 0){
            component.set("v.pageMessage", errorMessage);
        } else {
            component.set("v.showForm", true);
        }
    },
    handleErrors : function(component) {
        var caseObj = component.get("v.caseObj");
        var title = component.get("v.title");
        var leadSource = component.get("v.leadSource");
        console.log(leadSource);
        component.set("v.fieldErrorMessage", "");
        this.validateAndAddErrors(component, "Title", title);
        this.validateAndAddErrors(component, "Account", caseObj.AccountId);
        this.validateAndAddErrors(component, "Contact", caseObj.ContactId);
        this.validateAndAddErrors(component, "Lead Source", leadSource);
        this.validateAndAddErrors(component, "Sales Process", caseObj.Sales_Process__c);
        component.set("v.loadForm", true);
    },
    validateAndAddErrors : function(component, fieldName, fieldValue){
        console.log(fieldName + " = " + fieldValue);
        var errorMessage = "";
        if(typeof(fieldValue) == "undefined"){
            errorMessage = fieldName + " : You must enter a value.\n";
        } else if(fieldValue.trim().length == 0) {
            errorMessage = fieldName + " : Please enter valid value.\n";
        }
        component.set("v.fieldErrorMessage",  component.get("v.fieldErrorMessage") + errorMessage);
    },
    convert : function(component){
        var convertAction = component.get("c.convert");
        //case Map
        var caseObj = component.get("v.caseObj");
        //var casesWithLeadData = new Object();
        var leadFields = new Object();
        var caseWrapper =  new Object();
        //caseWrapper['caseObj'] = caseObj;
       // caseWrapper['leadTitle'] = component.get("v.title");
        //caseWrapper['leadSource'] = component.get("v.leadSource");
        
        
        leadFields['Title'] = component.get("v.title");
        leadFields['LeadSource'] = component.get("v.leadSource");
        leadFields['Status'] = component.get("v.status");
        //casesWithLeadData[caseObj] = leadFields;
        
        convertAction.setParams({"caseObj" : caseObj, "leadFields" : leadFields});
        convertAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('recordId' + response.getReturnValue().Id);
                var nwEvent = $A.get("e.force:navigateToSObject");
                nwEvent.setParams({
                    "recordId" : response.getReturnValue().Id,
                    "slideDevName": "Details"
                });
                nwEvent.fire();
            } else if(state === "ERROR"){
                component.set("v.fieldErrorMessage", response.getError()[0].message);
            }
        });
        $A.enqueueAction(convertAction); 
    }
})