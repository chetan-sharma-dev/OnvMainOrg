public interface ILeadsSelector extends fflib_ISObjectSelector {
	List<Lead> selectLeadsById(Set<Id> ids);
}