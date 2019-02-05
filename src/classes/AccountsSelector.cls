public class AccountsSelector extends fflib_SObjectSelector implements IAccountsSelector {    
    
    private static IAccountsSelector instance = null;
    
    public static IAccountsSelector getInstance() {
        
        if(instance == null) {
            instance = (IAccountsSelector)Application.selector().newInstance(Account.sObjectType);
        }
        
        return instance;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.Name
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }
}