public class ContactsSelector extends fflib_SObjectSelector implements IContactsSelector {
    
    private static IContactsSelector instance = null;
    
    public static IContactsSelector getInstance() {
        if(instance == null) {
            instance = (IContactsSelector)Application.selector().newInstance(Contact.sObjectType);
        }
        
        return instance;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Contact.Id,
            Contact.FirstName,
            Contact.MiddleName,
            Contact.LastName,
            Contact.Email,
            Contact.Suffix,
            Contact.Salutation,
            Contact.AccountId
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Contact.sObjectType;
    }
}