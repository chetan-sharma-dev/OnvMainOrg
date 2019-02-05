public class LeadsSelector extends fflib_SObjectSelector implements ILeadsSelector {    
    
    private static ILeadsSelector instance = null;
    
    public static ILeadsSelector getInstance() {
        
        if(instance == null) {
            instance = (ILeadsSelector)Application.selector().newInstance(Lead.sObjectType);
        }
        
        return instance;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Lead.Id,
            Lead.Name,
            Lead.Status,
            Lead.Account__c,
            Lead.Contact__c,
            Lead.Lead_Source__c,
            Lead.Merchant__c,
            Lead.Title, 
            Lead.OwnerId, 
            Lead.Sales_Process__c, 
            Lead.Lead_Receipt_Date__c, 
            Lead.Lead_Particulars__c, 
            Lead.Lead_rejection_reason__c, 
            Lead.Type__c,
            Lead.Nature_Of_Query__c, 
            Lead.IntroductionToCompanySent__c,
            Lead.Catalogs_Sent__c,
            Lead.Other_Vendors_Dealing_With_Client__c,
            Lead.Other_References__c,
            Lead.Lead_Comments__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Lead.sObjectType;
    }
    
    public List<Lead> selectLeadsById(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('OwnerId.Id');
        query.selectField('OwnerId.Name');
        query.setCondition('Id IN :ids');
        return Database.query(
            query.toSOQL()
        );
    }
}