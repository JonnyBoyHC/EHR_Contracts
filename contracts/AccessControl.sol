// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.0 < 0.9.0;
pragma experimental ABIEncoderV2;

import "./Libraries.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Access Control
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract Access_Control {

    //////////////////////////////////////////////////////////////////////////////////////////
    // Which Organization is this Doctor From?
    //////////////////////////////////////////////////////////////////////////////////////////

    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);

    // Roles
    mapping(bytes32 => mapping(address => bool)) private groupsAndOrganizations;

    // 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    // bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    
    // Groups & Organizations
    // Other Hospitals 0x9aa2e9c5ee2a0e219eb64cfec18e450dc48c0f19df3e879600cf8bf5ef80c909
    bytes32 private constant REMOTE_HOSPITALS = keccak256(abi.encodePacked("REMOTE_HOSPITALS"));
    // Other Organizations 0x1fa9ca065b23077ae63712d2d47c4797e81ca17431c8c9047891859bf2d7032a
    bytes32 private constant REMOTE_ORGANIZATIONS = keccak256(abi.encodePacked("REMOTE_ORGANIZATIONS"));
    // Internal Departments 0x62e462c3db967710b1e6fa7fa197989f3de6a7b5977c1c87b6bab9a4f32f19e0
    bytes32 private constant INTERNAL_DEPARTMENTS = keccak256(abi.encodePacked("INTERNAL_DEPARTMENTS"));

    constructor () {
        // _grantRole(ADMIN, msg.sender);
        doctors[msg.sender] = true;
        isDocActive[msg.sender] = true;
        // clrRecords[msg.sender].creationDate = block.timestamp;
        // clrRecords[msg.sender].allowPeriod = 1 minutes;
        clrRecords[msg.sender].ClrLvl = 0xe6ed86d632a71c92fc78ee69edb0bb73ffd8753aecbcea56fb4b61c6d5d6eb55;
        clrRecords[msg.sender].GrpOrg = 0x62e462c3db967710b1e6fa7fa197989f3de6a7b5977c1c87b6bab9a4f32f19e0;
        // objectClearence[_objClr].clrLvl = 0x5f1bc39a0c0da458ccf46b80679bb262d55041ca3b69608c43a3835cbd3bb10f;
        // objectClearence[_objClr].clr == ClearenceLevel.Normal_Clearence;
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // Is This Doctor Valid?
    //////////////////////////////////////////////////////////////////////////////////////////

    // Qualified doctors Personel Accounts
    mapping(address => bool) private doctors;
    // Is the current request Doctor's Account still active?
    mapping(address => bool) private isDocActive;

    // Check Doctor's Availability
    function isDoctor(address _addr) external view returns(bool){
        require(doctors[_addr], "Not a Valid Doctor!!!");
        require(isDocActive[_addr], "This account is not active anymore, Please contact related Authority!");
        return true;
    }

    // Set Doctor's and still Active?
    function setNewDoc(address _addr) external {
        doctors[_addr] = true;
    }

    function setDoc2Active(address _addr) external {
        isDocActive[_addr] = true;
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // Bell Lapadula SUBJECT Clearence
    //////////////////////////////////////////////////////////////////////////////////////////

    // 0xe6ed86d632a71c92fc78ee69edb0bb73ffd8753aecbcea56fb4b61c6d5d6eb55
    bytes32 private constant Top_Clearence = keccak256(abi.encodePacked("Top_Clearence"));
    // 0xacff1cb24c81922a93356dc85841f211a4706a1b2f922e4b317833a707d75dfc
    bytes32 private constant High_Clearence = keccak256(abi.encodePacked("High_Clearence"));
    // 0x5f1bc39a0c0da458ccf46b80679bb262d55041ca3b69608c43a3835cbd3bb10f
    bytes32 private constant Normal_Clearence = keccak256(abi.encodePacked("Normal_Clearence"));
    // 0x6401c5a44cba529a825323c2d99750099d3a87dc75ab36d2c817fc71b9e54fbf
    bytes32 private constant Low_Clearence = keccak256(abi.encodePacked("Low_Clearence"));

    // Last Clerence Approval Record
    struct SubDatesClr {
        // uint creationDate;
        // uint allowPeriod;
        bytes32 ClrLvl;
        bytes32 GrpOrg;
    }

    mapping(address => SubDatesClr) private clrRecords;

    // Check Doctor's Clearence still Valid
    // function isValid(address _addr) private view returns(bool){
    //     return (clrRecords[_addr].creationDate + clrRecords[_addr].allowPeriod) > block.timestamp;
    // }

    function mustBeInternalDoc(address _addr) external view returns(bool){
        require(clrRecords[_addr].GrpOrg == INTERNAL_DEPARTMENTS, "Only Local Doctors are Authorized!!!");
        return true;
    }

    enum ClearenceLevel { No_Clearence, Low_Clearence, Normal_Clearence, High_Clearence, Top_Clearence}

    // Check Doctor's Current Clearence
    function checkDocClrLvl(address _addr) external view returns(uint8){
            if (clrRecords[_addr].ClrLvl == Top_Clearence) { return uint8(ClearenceLevel.Top_Clearence);}
            else if (clrRecords[_addr].ClrLvl == High_Clearence) { return uint8(ClearenceLevel.High_Clearence);}
            else if (clrRecords[_addr].ClrLvl == Normal_Clearence) { return uint8(ClearenceLevel.Normal_Clearence);}
            else if (clrRecords[_addr].ClrLvl == Low_Clearence) { return uint8(ClearenceLevel.Low_Clearence);}
            else { return uint8(ClearenceLevel.No_Clearence);}
    }

    // Set Doctor's New Clearence
    function setNewDocClrRec(address _addr, bytes32 _ClrLvl, bytes32 _GrpOrg) external {
        // clrRecords[_addr].creationDate = _creationDate;
        // clrRecords[_addr].allowPeriod = _allowPeriod;
        clrRecords[_addr].ClrLvl = _ClrLvl;
        clrRecords[_addr].GrpOrg = _GrpOrg;
        groupsAndOrganizations[_GrpOrg][_addr] = true;
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // Bell Lapadula OBJECT Clearence
    //////////////////////////////////////////////////////////////////////////////////////////

    struct ObjectClearence {
        // uint creationDate;
        bytes32 clrLvl;
        ClearenceLevel clr;
    }

    mapping(address => ObjectClearence) private objectClearence;

    function setNewObjClr(address _objAddr, bytes32 _clrLvl, ClearenceLevel _clr) external {
        require(uint8(_clr) > 0, "Clearence Level Must Be Bigger than 0");
        // objectClearence[_objAddr].creationDate = block.timestamp;
        objectClearence[_objAddr].clrLvl = _clrLvl;
        objectClearence[_objAddr].clr = _clr;
    }

    function checkObjClrLvl(address _addr) external view returns(uint8) {
        return uint8(objectClearence[_addr].clr);
    }

    mapping(address => bool) private admStrg_Clearence;



    //////////////////////////////////////////////////////////////////////////////////////////
    // Temp Testing Funcion
    //////////////////////////////////////////////////////////////////////////////////////////

    function toggleDoctors() external returns(bool){
        return doctors[msg.sender] = !doctors[msg.sender];
    }

    function toggleDocActive() external returns(bool){
        return isDocActive[msg.sender] = !isDocActive[msg.sender];
    }

    // function set30SecsSubLvl4() external {
    //     clrRecords[msg.sender].creationDate = block.timestamp;
    //     clrRecords[msg.sender].allowPeriod = 30 seconds;
    // }

    // function setSubLvl4(uint _secs) external {
    //     clrRecords[msg.sender].creationDate = block.timestamp;
    //     clrRecords[msg.sender].allowPeriod = _secs;
    // }

    function setMsgSenderClrLvl(bytes32 _clrLvl) external {
        clrRecords[msg.sender].ClrLvl = _clrLvl;
    }

}