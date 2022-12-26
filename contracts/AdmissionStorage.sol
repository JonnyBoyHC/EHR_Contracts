// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.0 < 0.9.0;
pragma experimental ABIEncoderV2;

import "./Libraries.sol";

contract Admission_Storage {

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

    // Patient's Records Count
    mapping(uint => uint16) private patientRecCnt;
    mapping(uint => mapping(uint16 => PatientRecords)) private medicalRecords;

    function addPatient(uint16 _subjectID, PatientRecords memory addPnt) external {
        uint16 length = patientRecCnt[_subjectID];

        medicalRecords[_subjectID][length].HadmID = addPnt.HadmID;
        medicalRecords[_subjectID][length].AdmitTime = addPnt.AdmitTime;
        medicalRecords[_subjectID][length].DischTime = addPnt.DischTime;
        medicalRecords[_subjectID][length].DeathTime = addPnt.DeathTime;
        medicalRecords[_subjectID][length].Admission_Type = addPnt.Admission_Type;
        medicalRecords[_subjectID][length].Admission_Location = addPnt.Admission_Location;
        medicalRecords[_subjectID][length].Discharge_Location = addPnt.Discharge_Location;
        medicalRecords[_subjectID][length].Insurance = addPnt.Insurance;

        patientRecCnt[_subjectID] ++;
    }

    function getLatestOneRec(uint _subjectID) external view returns(PatientRecords memory) {
        return medicalRecords[_subjectID][patientRecCnt[_subjectID]-1];
    }

    function getAllRecords(uint _subjectID) external view returns (PatientRecords[] memory){
        uint16 length = patientRecCnt[_subjectID];
        PatientRecords[] memory allRecords = new PatientRecords[](length);
        for (uint16 i = 0; i < length; i++) {
          PatientRecords memory record = medicalRecords[_subjectID][i];
          allRecords[i] = record;
        }
        return allRecords;
    }

}

// [1234,1234,1234,0,"newborn","Hosp","Home","private"]
// [1234,1234,1234,0,0x6e6577626f726e,0x486f7370,0x486f6d65,0x70726976617465]