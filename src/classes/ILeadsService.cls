public interface ILeadsService {
	List<Lead> getLeadsById(Set<Id> ids);
    List<Opportunity> convertLeadToOpportunity(List<LeadsService.LeadConvertWrapper> leadData);
    List<Lead> upsertLeads(List<Lead> leads);
}