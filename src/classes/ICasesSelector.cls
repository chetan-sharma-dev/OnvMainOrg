public interface ICasesSelector extends fflib_ISObjectSelector {
	List<Case> selectCasesById(Set<Id> idSet);
}