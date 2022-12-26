// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.0 < 0.9.0;
pragma experimental ABIEncoderV2;

import "./Libraries.sol";

//////////////////////////////////////////////////////////////////////////////////////////
// Access Control Interface
//////////////////////////////////////////////////////////////////////////////////////////
interface IAccessControl {
    function isDoctor(address _addr) external view returns(bool);
    function checkDocClrLvl(address _addr) external view returns(uint8);
    function checkObjClrLvl(address _addr) external view returns(uint8);
    function mustBeInternalDoc(address _addr) external view returns(bool);
}

//////////////////////////////////////////////////////////////////////////////////////////
// Admission Storage Interface
//////////////////////////////////////////////////////////////////////////////////////////
interface IStrgAccess {

    struct PatientRecords {
        uint HadmID;
        int AdmitTime;
        int DischTime;
        int DeathTime;
        bytes32 Admission_Type;
        bytes32 Admission_Location;
        bytes32 Discharge_Location;
        bytes32 Insurance;
    }

    function addPatient(uint16 _subjectID, PatientRecords memory addPnt) external;
    function getLatestOneRec(uint _subjectID) external view returns(PatientRecords memory);
    function getAllRecords(uint _subjectID) external view returns (PatientRecords[] memory);
}


//////////////////////////////////////////////////////////////////////////////////////////
// Patients' Admission Storage Control
//////////////////////////////////////////////////////////////////////////////////////////
contract AdmissionStorageControl {

    address private owner;
    address private AccesssControlAddr;
    address private AdmStrgAddr;

    constructor (address _AccesssControlAddr, address _AdmStrgAddr) {
        owner = msg.sender;
        AccesssControlAddr = _AccesssControlAddr;
        AdmStrgAddr = _AdmStrgAddr;
    }

     //////////////////////////////////////////////////////////////////////////////////////////
    // Setting Interfaces
    IAccessControl IAC;
    IStrgAccess IAS;

    //////////////////////////////////////////////////////////////////////////////////////////
    // Is This Doctor Valid?
    modifier isDoctor(address _addr) {
        IAC = IAccessControl(AccesssControlAddr);
        IAC.isDoctor(_addr);
        _;
    }

    // 
    modifier mustBeInternalDoc(address _addr) {
        IAC = IAccessControl(AccesssControlAddr);
        IAC.mustBeInternalDoc(_addr);
        _;
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // Signature Varification
    modifier onlyAuthenticated (string memory _message, bytes memory _sig) {
        require(VerifySig.verify(_message, _sig), "Failed Signature Verification!");
        _;
    }

    function _checkSubClr(address _addr) private returns(uint8){
        IAC = IAccessControl(AccesssControlAddr);
        return IAC.checkDocClrLvl(_addr);
    }

    function _checkObjClr(address _addr) private returns(uint8){
        IAC = IAccessControl(AccesssControlAddr);
        return IAC.checkObjClrLvl(_addr);
    }

    function addNewPatient(uint16 _subjectID, IStrgAccess.PatientRecords memory addPnt) 
    external    
    // onlyAuthenticated(_message, _sig) 
    isDoctor(msg.sender) 
    mustBeInternalDoc(msg.sender) {

        uint8 subjectClr = _checkSubClr(msg.sender);
        require(subjectClr > 0, "No Clerence!!!");
        uint8 objectClr = _checkObjClr(AdmStrgAddr);
        require(subjectClr <= objectClr, "You have no Write Clearence to Object Clearence Lower than you!!!");

        IAS = IStrgAccess(AdmStrgAddr);
        IAS.addPatient(_subjectID, addPnt);
    }

    function getLatestOneRec(uint _subjectID) 
    external 
    // onlyAuthenticated(_message, _sig) 
    isDoctor(msg.sender) 
    returns(IStrgAccess.PatientRecords memory) {

        uint8 subjectClr = _checkSubClr(msg.sender);
        require(subjectClr > 0, "No Clerence!!!");
        uint8 objectClr = _checkObjClr(AdmStrgAddr);
        require(subjectClr >= objectClr, "You have no Read Clearence to Object Clearence Higher than you!!!");

        IAS = IStrgAccess(AdmStrgAddr);
        return IAS.getLatestOneRec(_subjectID);
    }

    function getAllRecords(uint _subjectID) 
    external 
    // onlyAuthenticated(_message, _sig) 
    isDoctor(msg.sender) 
    returns (IStrgAccess.PatientRecords[] memory) {

        uint8 subjectClr = _checkSubClr(msg.sender);
        require(subjectClr > 0, "No Clerence!!!");
        uint8 objectClr = _checkObjClr(AdmStrgAddr);
        require(subjectClr >= objectClr, "You have no Read Clearence to Object Clearence Higher than you!!!");

        IAS = IStrgAccess(AdmStrgAddr);
        return IAS.getAllRecords(_subjectID);
    }

}

// [136572,-869122140000,-868901160000,0,"0x6e6577626f726e00000000000000000000000000000000000000000000000000","0x486f737000000000000000000000000000000000000000000000000000000000","0x486f6d6500000000000000000000000000000000000000000000000000000000","0x7072697661746500000000000000000000000000000000000000000000000000"]


    // subjectClearence:
    // Top_Clearence: 0xe6ed86d632a71c92fc78ee69edb0bb73ffd8753aecbcea56fb4b61c6d5d6eb55
    // GrpOrg: 0x62e462c3db967710b1e6fa7fa197989f3de6a7b5977c1c87b6bab9a4f32f19e0
    // Clr: 4

    // objectClearence: 
    // Normal_Clearence: 0x5f1bc39a0c0da458ccf46b80679bb262d55041ca3b69608c43a3835cbd3bb10f
    // Clr: 2