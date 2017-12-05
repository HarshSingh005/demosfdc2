/***********************************************************************************************************
* Appirio, Inc
* Name         : AddressComponentHostController
* Created By   : Karl Houseknecht (Appirio)
* Purpose      : Interface implemented by page controllers hosting the address component if they need
* 				 to subscribe to callbacks.
* Created Date : 01/11/2017
*
* Date Modified                Modified By             Description of the update
----------------------------------------------------------------------------------------------------------
* 01/11/2017                   Karl Houseknecht		   Created
**********************************************************************************************************/
public interface AddressComponentHostController 
{
	void AddressEvent(AddressValidationComponentController addressController);
}