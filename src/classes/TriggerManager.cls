public interface TriggerManager { 
	/***************************************
	 * context methods
	 ***************************************/

	// context-specific methods for override
	void beforeInsert(List<sObject> listObjs);
	void beforeUpdate();
	void beforeDelete();
	void afterInsert();
	void afterUpdate();
	void afterDelete();
	void afterUndelete();
}