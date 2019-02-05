public class LeadController {
    
    @AuraEnabled
    public static Lead getLead(Id leadId) {
        List<Lead> leadRecords;
        UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :leadId];
        if(userAccess != null && !userAccess.HasEditAccess) {
            throw new AuraHandledException('Insufficient Privileges.');
        } else {
            try{
                leadRecords = LeadsService.getLeadsById(new Set<id> {leadId});
                if(leadRecords == null || leadRecords.isEmpty()) {
                    throw new AuraHandledException('Something Went Wrong!');
                } else {
                    return leadRecords.get(0);
                }
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    
    @AuraEnabled
    public static Lead saveLead(Lead leadObj){
        System.debug('Lead Controller Save Called');
        Lead leadRecord;
        String errorMessage='';
        if(leadObj != null){
            if(String.isEmpty(leadObj.Title)){
                errorMessage='Please add Lead Title.';
            }
            if(leadObj.Lead_Source__c == null){
                errorMessage+='\n Please add Lead Source.';
            }
            if(leadObj.Merchant__c == null){
                errorMessage+='\n Please add Company.';
            }
            if(leadObj.Lead_Receipt_Date__c == null){
                errorMessage+='\n Please add Lead Reciept Date.';
            }
            if(leadObj.Account__c == null){
                errorMessage+='\n Please add Account.';
            }
            if(leadObj.Contact__c == null){
                errorMessage+='\n Please add Contact.';
            }
            if(!String.isEmpty(errorMessage)){
                throw new AuraHandledException(errorMessage);
            } else {
                try{
                    leadRecord = LeadsService.upsertLeads(new List<Lead> {leadObj}).get(0);
                    if(leadRecord == null) {
                        throw new AuraHandledException('Something Went Wrong!');
                }
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());
            	}
            }
        } else {
            throw new AuraHandledException('Something Went Wrong!');
        }
        return leadRecord;
    }
    
    @AuraEnabled
    public static Opportunity createOpportunity(Lead leadRecord, String opportunityName) {
        List<Opportunity> convertedOpportunities;
        
        if(leadRecord == null) {
            throw new AuraHandledException('Lead record should not be null.');
        }
        if(String.isEmpty(opportunityName)) {
            throw new AuraHandledException('Opportunity name should not be blank.');
        }
        if(leadRecord.Merchant__c == null) {
            throw new AuraHandledException('Company should not be blank.');
        }
        try{
            convertedOpportunities = LeadsService.convertLeadToOpportunity(new List<LeadsService.LeadConvertWrapper>{new LeadsService.LeadConvertWrapper(leadRecord, opportunityName)});
            if(convertedOpportunities == null || convertedOpportunities.isEmpty()) {
                throw new AuraHandledException('Something Went Wrong!');
            } else {
                return convertedOpportunities.get(0);
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    
}