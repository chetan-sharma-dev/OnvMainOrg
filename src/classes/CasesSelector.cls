public class CasesSelector extends fflib_SObjectSelector implements ICasesSelector {
    
    private static ICasesSelector instance = null;
    
    public static ICasesSelector getInstance() {
        
        if(instance == null) {
            instance = (ICasesSelector)Application.selector().newInstance(Case.sObjectType);
        }
        
        return instance;
    }
 
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Case.Id,
            Case.AccountId,
            Case.Status,
            Case.OwnerId,
            Case.SuppliedEmail,
            Case.ContactId,
            Case.Sales_Process__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Case.sObjectType;
    }
    
    public List<Case> selectCasesById(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory();
        fflib_SObjectSelector contactsSelector = new ContactsSelector();
        contactsSelector.configureQueryFactoryFields(query, 'Contact');
        query.selectField('Account.Name');
        query.setCondition('Id IN :ids');
        return Database.query(
            query.toSOQL()
        );
        
    }
}