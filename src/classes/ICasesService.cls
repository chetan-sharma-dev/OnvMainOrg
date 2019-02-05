public interface ICasesService {
    
    List<Case> getCasesById(Set<Id> ids); 
    
	List<Lead> convertToLead(List<CasesService.CaseConvertWrapper> cases);
    
}