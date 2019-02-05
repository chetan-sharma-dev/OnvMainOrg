({
    getData : function(component, recordId){
        console.log('get helper');
        var getLeadAction = component.get("c.getLead");
        getLeadAction.setParams({"leadId" : recordId});
        getLeadAction.setCallback(this, function(response) {
        	console.log('save callback'+response.getState());
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('save callback'+response.getReturnValue());
                debugger;
            	component.set("v.LeadObj",response.getReturnValue());
                //return response.getReturnValue();
            }
        });
        $A.enqueueAction(getLeadAction); 
    },
    save : function(component, leadObj){
        console.log('save helper');
        var saveLeadAction = component.get("c.saveLead");
        saveLeadAction.setParams({"leadObj" : leadObj});
        saveLeadAction.setCallback(this, function(response) {
            console.log('save callback'+response.getState());
            var state = response.getState();
            if (state === "SUCCESS") {
                 var event = $A.get( 'e.force:navigateToSObject' );
                 event.setParams({
                            'recordId' : response.getReturnValue().Id
                        }).fire();
                
                /*
                if(response.getReturnValue().search('Please') >= 0){
                    console.log(response.getReturnValue());
                    
                   component.set("v.pageMessage", response.getReturnValue()); 
                }else {
                    var eUrl= $A.get("e.force:navigateToURL");
                    eUrl.setParams({
                        "url":  response.getReturnValue()
                    });
                    eUrl.fire();
                }*/
            } else if(state === "ERROR") {
                component.set("v.pageMessage", response.getError()[0].message); 
            }
            
        });
        $A.enqueueAction(saveLeadAction); 
    },
	handleErrors : function(component, leadObj) {
        console.log('handleErrors');
        component.set("v.pageMessage", "");
        this.checkAndAddErrors(component, "Title", leadObj.Title);
        //this.checkAndAddErrors(component, "Company", leadObj.Merchant__c);
        this.checkAndAddErrors(component, "Account", leadObj.Account__c);
        this.checkAndAddErrors(component, "Contact", leadObj.Contact__c);
        this.checkAndAddErrors(component, "Lead Source", leadObj.Lead_Source__c);
        this.checkAndAddErrors(component, "Sales Process", leadObj.Sales_Process__c);
    },
    checkAndAddErrors : function(component, fieldName, fieldValue){
        console.log('checkAndAddErrors');
        var errorMessage = "";
        if(typeof(fieldValue) == "undefined"){
            errorMessage = "Please add " + fieldName + "\n";
        } else if(fieldValue.trim().length == 0) {
            errorMessage = "Please enter valid " + fieldName + "\n";
        }
        component.set("v.pageMessage",  component.get("v.pageMessage") + errorMessage);
    }
})