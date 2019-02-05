public class LeadsService {
    private static ILeadsService instance;
    
    public static List<Lead> getLeadsById(Set<Id> ids) {
        
        return service().getLeadsById(ids);
        
    }
    
    public static List<Lead> upsertLeads(List<Lead> leads) {
        
        return service().upsertLeads(leads);
        
    }
    
    public static List<Opportunity> convertLeadToOpportunity(List<LeadsService.LeadConvertWrapper> leadData) {
        
        return service().convertLeadToOpportunity(leadData);
        
    }
    
    private static ILeadsService service() {
        
        if(instance == null) {
            instance = (ILeadsService) Application.service().newInstance(ILeadsService.class);
        }
        
        return instance;
        
    }
    
    public class LeadConvertWrapper {
        public Lead leadRecord;
        public String opportunityName;
        
        public LeadConvertWrapper(Lead leadRecord, String opportunityName) {
            this.leadRecord = leadRecord;
            this.opportunityName = opportunityName;
        }
    }
}