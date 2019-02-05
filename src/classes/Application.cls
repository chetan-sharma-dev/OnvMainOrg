public class Application {
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
            new List<SObjectType> {   
                Account.SObjectType,
                Lead.SObjectType,
                Case.SObjectType, 
                Opportunity.SObjectType,
                Contact.SObjectType
            }
        );
    
    private static fflib_Application.SelectorFactory s_Selector;
    public static fflib_Application.SelectorFactory selector() {
        if (s_Selector == null) {
            s_Selector = new fflib_Application.SelectorFactory(
                new Map<SObjectType, Type> {
                    Case.SObjectType => CasesSelector.class,
                    Lead.SObjectType => LeadsSelector.class,
                    Opportunity.SObjectType => OpportunitiesSelector.class,
                    Account.SObjectType => AccountsSelector.class,
                    Contact.SObjectType => ContactsSelector.class
                }
            );
        }
        
        return s_Selector;
    }
    
    private static fflib_Application.ServiceFactory s_Service;
    public static fflib_Application.ServiceFactory service() {
        if (s_Service == null) {
            s_Service = new fflib_Application.ServiceFactory(
                new Map<Type, Type> {
                    ILeadsService.class => LeadsServiceImpl.class,
                    ICasesService.class => CasesServiceImpl.class  
                }
            );
        }
        
        return s_Service;
    }
      
}