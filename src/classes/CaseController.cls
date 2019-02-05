public class CaseController { 
    @AuraEnabled
    public static Case init(Id caseObjId){
        // Queried case fields with related details using controller caseObject id
        List<Case> cases = CasesService.getCasesById(new Set<Id>{caseObjId});
        System.debug('Cases' + cases);
        //Case caseObj = [SELECT Id, AccountId, Status, OwnerId, Owner.UserName, Account.Name, SuppliedEmail, ContactId, Contact.Email, Contact.FirstName, Contact.LastName, Contact.MiddleName, Contact.Suffix, Contact.Salutation, Sales_Process__c FROM Case WHERE Id=:caseObjId];
        UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :cases[0].Id];
        if(userAccess != null && !userAccess.HasEditAccess) { 
            return null;
        }
        return cases[0];
    }
    
    @AuraEnabled
    public static Lead convert(Case caseObj, Map<String, String> leadFields) {
        List<Lead> convertedLeads = new List<Lead>();
        String conversionValidationString = validateCaseFields(caseObj);
        String fieldValidationString = validateLeadFields(caseObj, leadFields);
        
        
        if(String.isNotEmpty(conversionValidationString)){
            throw new AuraHandledException(conversionValidationString);
            
        } 
        
        if(String.isNotEmpty(fieldValidationString)){
            throw new AuraHandledException(fieldValidationString);
        }
        
        try{ 
            List<CasesService.CaseConvertWrapper> cases = new List<CasesService.CaseConvertWrapper>();
            cases.add(new CasesService.CaseConvertWrapper(caseObj, leadFields.get('Title'), leadFields.get('LeadSource')));
            convertedLeads = CasesService.convertToLead(cases);
            /*
            Map<Case, Map<String, String>> casesWithLeadData = new Map<Case, Map<String, String>>{ caseObj => leadFields };
                cases.add(new CaseConvertWrapper(caseObj, leadFields.get('Title'), leadFields.get('LeadSource')));
                convertedLeads = CasesService.convertToLead(casesWithLeadData, cases);
			*/
            return convertedLeads.get(0);
        } catch(DmlException dml){
            throw new AuraHandledException(dml.getDMLMessage(0));
        }
    }
    
    private static String validateCaseFields(Case caseObj){
        String errorMessage = '';
        // Add Error when fields are null
        if( caseObj.Status == 'Converted'){
            errorMessage = 'Already converted case cannot be converted to Lead.\n';
        } else if(caseObj.Status == 'Closed'){
            errorMessage = 'Closed case cannot be converted to Lead.\n'
                + 'You can reopen the case if you want to convert the case.';
        } else if(caseObj.Sales_Process__c == 'Support' || caseObj.Sales_Process__c == 'Press' || caseObj.Sales_Process__c == 'Design'){
            errorMessage = caseObj.Sales_Process__c + ' Sales Process case cannot be converted to Lead.';
        } 
        return errorMessage;
    } 
    
    private static String validateLeadFields(Case caseObj, Map<String, String> leadFields){
        String title = leadFields.get('Title');
        String leadSource = leadFields.get('LeadSource');
        String status = leadFields.get('Status');
        String errorMessage = '';
        // Add Error when fields are null
        if(title == null) { 
            errorMessage+= 'Lead Title: You must enter a value.\n';
        }
        if(caseObj.Sales_Process__c == null) {
            errorMessage+= 'Case Sales process is not selected.\n';
        }
        if(leadSource == null){
            errorMessage+= 'Lead Source: You must enter a value.\n';
        }
        if(caseObj.AccountId == null) {
            errorMessage+= 'Account: Please select value on Case.\n';
            errorMessage+= 'Contact: Please select value on Case.\n';
        } else if(caseObj.ContactId == null) { 
            errorMessage+= 'Contact: Please select value on Case.\n';
        }
        return errorMessage;
    }

}