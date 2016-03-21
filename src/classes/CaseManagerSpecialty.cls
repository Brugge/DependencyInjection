// Code to be called for Case Manager Specialty record types
public class CaseManagerSpecialty implements IManager
{

	public static void beforeInsert(List<sObject> newObjList)
	{
		List<Case> newCases = (List<Case>) newObjList;
		// Applicable Code Calls here
	}

	public static void beforeUpdate(List<sObject> newObjList, Map<Id, sObject> oldObjMap)
	{
		List<Case> newCaseList = (List<Case>) newObjList;
		List<Case> oldCaseList = (List<Case>) oldObjMap.values();
		Map<Id, Case> newCaseMap = new Map<Id, Case> (newCaseList);
		Map<Id, Case> oldCaseMap = new Map<Id, Case> (oldCaseList);
		// Applicable Code Calls here
	}

	public static void beforeDelete(Map<Id, sObject> oldObjMap)
	{
		List<Case> oldCaseList = (List<Case>) oldObjMap.values();
		Map<Id, Case> oldCaseMap = new Map<Id, Case> (oldCaseList);
		// Applicable Code Calls here
	}

	public static void afterInsert(List<sObject> newObjList)
	{
		List<Case> newCaseList = (List<Case>) newObjList;
		Map<Id, Case> newCaseMap = new Map<Id, Case> (newCaseList);
		// Applicable Code Calls here
	}

	public static void afterUpdate(List<sObject> newObjList, Map<Id, sObject> oldObjMap)
	{
		List<Case> newCaseList = (List<Case>) newObjList;
		List<Case> oldCaseList = (List<Case>) oldObjMap.values();
		Map<Id, Case> newCaseMap = new Map<Id, Case> (newCaseList);
		Map<Id, Case> oldCaseMap = new Map<Id, Case> (oldCaseList);
		// Applicable Code Calls here
	}

	public static void afterDelete(Map<Id, sObject> oldObjMap)
	{
		List<Case> oldCaseList = (List<Case>) oldObjMap.values();
		Map<Id, Case> oldCaseMap = new Map<Id, Case> (oldCaseList);
		// Applicable Code Calls here
	}

	public static void afterUndelete()
	{
		// We are not using this anywhere yet and are not worrying about it.
	}
}