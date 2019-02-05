public class CaseConvertControllerExtension {
    private static Case caseObj;
    private static Lead leadObj{get;set;} 
    
/**
*  Controller Constructor to initializing propreties of class
*/
    @AuraEnabled
    public static List<SObject> init(Id caseObjId){
        List<SObject> responses = new List<SObject>();
        leadObj = new Lead();
        // Queried case fields with related details using controller caseObject id
        caseObj = [SELECT Id, AccountId, Status, OwnerId, Owner.UserName, Account.Name, SuppliedEmail, ContactId, Contact.Email, Contact.FirstName, Contact.LastName, Contact.MiddleName, Contact.Suffix, Contact.Salutation, Sales_Process__c FROM Case WHERE Id=:caseObjId];
        UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :caseObj.Id];
        if(userAccess != null && !userAccess.HasEditAccess) { 
            return null;
        }
        setLeadObjectRequiredFields();
        responses.add(caseObj);
        responses.add(leadObj);
        return responses;
    }

/**
* Method convert case into lead return lead page reference 
*/
    @AuraEnabled
    public static String convert(Lead leadObjFromUi, Case caseObjFromUi) {
        
        String result = '';
        leadObj = leadObjFromUi;
        caseObj = caseObjFromUi;
        checkAndUpdateLeadRequiredFields();
        String conversionValidationString = validateForConversionAndGetErrorString();
        String fieldValidationString = validateFieldsAndGetErrorString();
        if(conversionValidationString.length() == 0 && fieldValidationString.length() == 0){
            try{
                insert leadObj;
                caseObj.Status = 'Converted';
                upsert caseObj;
                result = (new PageReference('/' + leadObj.Id)).getUrl();
            } catch(DmlException dmlException) {
                throw new AuraHandledException('Lead with same name already exists.');
            } 
        }  else if(conversionValidationString.length() == 0){
            throw new AuraHandledException(conversionValidationString);
            //result = conversionValidationString;
        } else if(fieldValidationString.length() == 0){
            throw new AuraHandledException(fieldValidationString);
            //result = fieldValidationString;
        }
        return result;
    }
    
/**
* Method called for check and add error to the page. 
*/
    private static String validateForConversionAndGetErrorString(){
        String errorMessage = '';
        // Add Error when fields are null
        if( caseObj.Status == 'Converted'){
            errorMessage = caseObj.Status + 'case cannot be converted to Lead.\n';
        } else if(caseObj.Status == 'Closed'){
            errorMessage = caseObj.Status + 'case cannot be converted to Lead.\n';
            errorMessage = errorMessage + 'You can reopen the case if you want to convert the case.';
        } else if(caseObj.Sales_Process__c == 'Support' || caseObj.Sales_Process__c == 'Press' || caseObj.Sales_Process__c == 'Design'){
            errorMessage = caseObj.Sales_Process__c + ' Sales Process case cannot be converted to Lead.';
        } 
        return errorMessage;
    }
    
/**
* Method called for check and add error to the page. 
*/
    private static String validateFieldsAndGetErrorString(){
        String errorMessage = '';
        // Add Error when fields are null
        if(leadObj.Title == null) {
            errorMessage+= 'Lead Title: You must enter a value.\n';
        }
        if(caseObj.Sales_Process__c == null) {
            errorMessage+= 'Case Sales process is not selected.\n';
        }
        if(leadObj.Lead_Source__c == null){
            errorMessage+= 'Lead Source: You must enter a value.\n';
        }
        if(leadObj.Account__c == null) {
            errorMessage+= 'Account: Please select value on Case.\n';
            errorMessage+= 'Contact: Please select value on Case.\n';
        } else if(leadObj.Contact__c == null) { 
            errorMessage+= 'Contact: Please select value on Case.\n';
        }
        return errorMessage;
    }
    
/**
* Method to set Lead Object Required Fields 
*/
    private static void setLeadObjectRequiredFields() {
        //Set account realated details on lead
        leadObj.Account__c = caseObj.AccountId;
        leadObj.Company = caseObj.Account.Name;
        //Set Contact details
        leadObj.Contact__c = caseObj.ContactId;
        leadObj.Salutation = caseObj.Contact.Salutation;
        leadObj.FirstName = caseObj.Contact.FirstName;
        leadObj.MiddleName = caseObj.Contact.MiddleName;
        leadObj.LastName = caseObj.Contact.LastName;
        leadObj.Suffix = caseObj.Contact.Suffix;
        //Set other details on lead
        leadObj.Status = 'New';
        leadObj.Email = caseObj.Contact.Email;
        leadObj.OwnerId = caseObj.OwnerId;
        leadObj.Sales_Process__c = caseObj.Sales_Process__c;
        leadObj.Lead_Receipt_Date__c=Date.today();   
    }
    
/**
* Method to update Lead required fileds on lead conversion
*  when account and contacts are filled on case Convert page
*/
    private static void checkAndUpdateLeadRequiredFields() {
        if(leadObj.Contact__c != null) {
            Contact leadContact = [SELECT Id, Name, Salutation, FirstName, MiddleName, LastName,
                                   Suffix, AccountId, Account.Name, Email FROM Contact WHERE Id= :leadObj.Contact__c];
            leadObj.Account__c = leadContact.AccountId;
            leadObj.Company = leadContact.Account.Name;
            leadObj.Contact__c = leadContact.Id;
            leadObj.Salutation = leadContact.Salutation;
            leadObj.FirstName = leadContact.FirstName;
            leadObj.MiddleName = leadContact.MiddleName;
            leadObj.LastName = leadContact.LastName;
            leadObj.Suffix = leadContact.Suffix;
            leadObj.Email = leadContact.Email;
        } 
    }
    
    
}