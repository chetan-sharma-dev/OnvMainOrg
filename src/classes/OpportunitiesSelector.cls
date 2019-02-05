public class OpportunitiesSelector extends fflib_SObjectSelector implements IOpportunitiesSelector {
    
    private static IOpportunitiesSelector instance = null;
    
    public static IOpportunitiesSelector getInstance() {
        
        if(instance == null) {
            instance = (IOpportunitiesSelector)Application.selector().newInstance(Opportunity.sObjectType);
        }
        
        return instance;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Opportunity.Id,
            Opportunity.Name,
            Opportunity.RecordType.Name,
            Opportunity.Contact__c,
            Opportunity.Lead_Source__c,
            Opportunity.Merchant__c,
            Opportunity.OwnerId
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Opportunity.sObjectType;
    }
}