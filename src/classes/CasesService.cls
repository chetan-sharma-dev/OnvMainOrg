public class CasesService {
    
    private static ICasesService instance;
    
    public static List<Case> getCasesById(Set<Id> ids) {  
        
        return service().getCasesById(ids);
        
    }
    
    
    public static List<Lead> convertToLead(List<CasesService.CaseConvertWrapper> cases) {
        
        return service().convertToLead(cases);
        
    }
    
    
    private static ICasesService service() {
        
        if(instance == null) {
            instance = (ICasesService) Application.service().newInstance(ICasesService.class);
        }
        
        return instance;
        
    }
    
    public class CaseConvertWrapper { 
        public Case caseRecord;
        public String leadTitle;
        public Id leadSource;
        
        public CaseConvertWrapper(Case caseRecord, String leadTitle, Id leadSource) {
            this.caseRecord = caseRecord;
            this.leadTitle = leadTitle;
            this.leadSource = leadSource;
        }
    }
    
    
    
}