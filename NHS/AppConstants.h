//
//  AppConstants.h
//  NHS
//
//  Created by Mac Pro on 8/15/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConstants : NSObject

#define DEFAULT_FONT_SIZE 15
#define DEFAULT_FONT_NAME @"AppleSDGothicNeo-Regular"
#define DEFAULT_ROW_HEIGHT_FOR_SECTIONS 70.0

#pragma mark - Section Names for Submission

#define SECTION_MODE_OF_SCREENING               @"mode_of_screening"
#define SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT    @"phlebotomy_eligibility_assmt"
#define SECTION_PHLEBOTOMY                      @"phlebotomy"
#define SECTION_PROFILING_SOCIOECON             @"profiling_socioecon"
#define SECTION_CHAS_PRELIM                     @"chas_prelim"
#define SECTION_COLONOSCOPY_ELIGIBLE            @"colonoscopy_eligible"
#define SECTION_FIT_ELIGIBLE                    @"fit_eligible"
#define SECTION_MAMMOGRAM_ELIGIBLE              @"mammogram_eligible"
#define SECTION_PAP_SMEAR_ELIGIBLE              @"pap_smear_eligible"
#define SECTION_FALL_RISK_ELIGIBLE              @"fall_risk_eligible"
#define SECTION_GERIATRIC_DEMENTIA_ELIGIBLE     @"geriatric_dementia_eligible"
#define SECTION_DIABETES                        @"diabetes"
#define SECTION_HYPERLIPIDEMIA                  @"hyperlipidemia"
#define SECTION_HYPERTENSION                    @"hypertension"
#define SECTION_DEPRESSION                      @"depression"
#define SECTION_RISK_STRATIFICATION             @"risk_stratification"
#define SECTION_CURRENT_SOCIOECO_SITUATION      @"current_socioeco_situation"
#define SECTION_CURRENT_PHY_STATUS              @"current_phy_status"
#define SECTION_SOCIAL_SUPPORT                  @"social_support"
#define SECTION_PSYCH_WELL_BEING                @"psych_well_being"
#define SECTION_SW_ADD_SERVICES                 @"sw_add_services"
#define SECTION_SOC_WORK_SUMMARY                @"soc_work_summary"
#define SECTION_CLINICAL RESULTS                @"clinical_results"
#define SECTION_SNELLEN_TEST                    @"snellen_test"
#define SECTION_ADD_SERVICES                    @"add_services"
#define SECTION_DOC_CONSULT                     @"doc_consult"
#define SECTION_BASIC_DENTAL                    @"basic_dental"
#define SECTION_SERI_MED_HIST                   @"seri_med_hist"
#define SECTION_SERI_VA                         @"seri_va"
#define SECTION_SERI_AUTOREFRACTOR              @"seri_autorefractor"
#define SECTION_SERI_IOP                        @"seri_iop"
#define SECTION_SERI_AHE                        @"seri_ahe"
#define SECTION_SERI_PHE                        @"seri_phe"
#define SECTION_SERI_DAG                        @"seri_dag"
#define SECTION_FALL_RISK_ASSMT                 @"fall_risk_assmt"
#define SECTION_GERIATRIC_DEMENTIA_ASSMT        @"geriatric_dementia_assmt"
#define SECTION_PRE_HEALTH_EDU                  @"pre_health_edu"
#define SECTION_POST_HEALTH_EDU                 @"post_health_edu"


#pragma mark - UserDefaults

extern NSString *const kResidentAge;
extern NSString *const kNeedSERI;
extern NSString *const kQualifyCHAS;
extern NSString *const kQualifyColonsc;
extern NSString *const kQualifyMammo;
extern NSString *const kQualifyFIT;
extern NSString *const kQualifyPapSmear;
extern NSString *const kQualifyFallAssess;
extern NSString *const kQualifyDementia;
extern NSString *const kQualifyPhleb;


#pragma mark - Resident Particulars submission
extern NSString *const kTimestamp;
extern NSString *const kLastUpdateTs;
extern NSString *const kResidentId;
extern NSString *const kSectionName;
extern NSString *const kFieldName;
extern NSString *const kNewContent;
extern NSString *const kScreenLocation;
extern NSString *const kResiParticulars;

#pragma mark - Resident Particulars

extern NSString *const kName;
extern NSString *const kNRIC;
extern NSString *const kGender;
extern NSString *const kBirthDate;
extern NSString *const kBirthYear;
extern NSString *const kCitizenship;
extern NSString *const kReligion;
extern NSString *const kReligionOthers;
extern NSString *const kHpNumber;
extern NSString *const kHouseNumber;
extern NSString *const kEthnicity;

extern NSString *const kSpokenLang;
extern NSString *const kLangCanto;
extern NSString *const kLangEng;
extern NSString *const kLangHindi;
extern NSString *const kLangHokkien;
extern NSString *const kLangMalay;
extern NSString *const kLangMandarin;
extern NSString *const kLangTamil;
extern NSString *const kLangTeoChew;
extern NSString *const kLangOthers;
extern NSString *const kLangOthersText;

extern NSString *const kMaritalStatus;
extern NSString *const kHousingOwnedRented;
extern NSString *const kHousingNumRooms;
extern NSString *const kHighestEduLevel;

extern NSString *const kAddress;  //not for submission
extern NSString *const kAddressStreet;
extern NSString *const kAddressBlock;
extern NSString *const kAddressOthers;
extern NSString *const kAddressUnitNum;
extern NSString *const kAddressDuration;
extern NSString *const kAddressPostCode;

extern NSString *const kIsFinal;

extern NSString *const kNeighbourhood;
extern NSString *const kRemarks;

#pragma mark - SearchBar constants
extern NSString *const ViewControllerTitleKey;
extern NSString *const SearchControllerIsActiveKey;
extern NSString *const SearchBarTextKey;
extern NSString *const SearchBarIsFirstResponderKey;


#pragma mark - Phlebotomy
//extern NSString *const kWasTaken;
extern NSString *const kAge40;
extern NSString *const kChronicCond;
extern NSString *const kWantFreeBt;
extern NSString *const kDidPhleb;
extern NSString *const kFastingBloodGlucose;
extern NSString *const kTriglycerides;
extern NSString *const kLDL;
extern NSString *const kHDL;
extern NSString *const kCholesterolHdlRatio;
extern NSString *const kTotCholesterol;

#pragma mark - Mode of Screening
extern NSString *const kScreenMode;
extern NSString *const kApptDate;
extern NSString *const kApptTime;

extern NSString *const kTime_8_10;
extern NSString *const kTime_10_12;
extern NSString *const kTime_12_2;
extern NSString *const kTime_2_4;

extern NSString *const kPhlebAppt;

#pragma mark - Profiling
extern NSString *const kProfilingConsent;
extern NSString *const kEmployStat;
extern NSString *const kEmployReasons;
extern NSString *const kEmployOthers;
extern NSString *const kDiscloseIncome;
extern NSString *const kAvgMthHouseIncome;
extern NSString *const kNumPplInHouse;
extern NSString *const kAvgIncomePerHead;
extern NSString *const kDoesntOwnChasPioneer;
extern NSString *const kLowHouseIncome;
extern NSString *const kLowHomeValue;
extern NSString *const kWantChas;
extern NSString *const kSporeanPr;
extern NSString *const kAgeAbove50;
extern NSString *const kRelWColorectCancer;
extern NSString *const kColonoscopy3yrs;
extern NSString *const kWantColonoscopyRef;
extern NSString *const kFitLast12Mths;
extern NSString *const kColonoscopy10Yrs;
extern NSString *const kWantFitKit;
extern NSString *const kSporean;
extern NSString *const kMammo2Yrs;
extern NSString *const kHasChas;
extern NSString *const kWantMammo;
extern NSString *const kPap3Yrs;
extern NSString *const kEngagedSex;
extern NSString *const kWantPap;
extern NSString *const kAgeAbove65;
extern NSString *const kAgeCheck;
extern NSString *const kAgeCheck2;
extern NSString *const kFallen12Mths;
extern NSString *const kScaredFall;
extern NSString *const kFeelFall;
extern NSString *const kCognitiveImpair;

#pragma mark - Health Assessment and Risk Stratisfaction

extern NSString *const kDMHasInformed;
extern NSString *const kDMCheckedBlood;
extern NSString *const kDMSeeingDocRegularly;
extern NSString *const kDMCurrentlyPrescribed;
extern NSString *const kDMTakingRegularly;

extern NSString *const kLipidHasInformed;
extern NSString *const kLipidCheckedBlood;
extern NSString *const kLipidSeeingDocRegularly;
extern NSString *const kLipidCurrentlyPrescribed;
extern NSString *const kLipidTakingRegularly;

extern NSString *const kHTHasInformed;
extern NSString *const kHTCheckedBp;
extern NSString *const kHTSeeingDocRegularly;
extern NSString *const kHTCurrentlyPrescribed;
extern NSString *const kHTTakingRegularly;

extern NSString *const kPhqQ1;
extern NSString *const kPhqQ2;
extern NSString *const kPhq9Score;
extern NSString *const kFollowUpReq;

extern NSString *const kDiabeticFriend;
extern NSString *const kDelivered4kgOrGestational;
extern NSString *const kCardioHistory;
extern NSString *const kSmoke;


#pragma mark - Social Work

#pragma mark Current Socioeconomic Situation
extern NSString *const kCopeFin;
extern NSString *const kWhyNotCopeFin;
extern NSString *const kMoreWhyNotCopeFin;
extern NSString *const kHasChas;
extern NSString *const kHasPgp;
extern NSString *const kHasMedisave;
extern NSString *const kHasInsure;
extern NSString *const kHasCpfPayouts;
extern NSString *const kCpfAmt;
extern NSString *const kChasColor;
extern NSString *const kReceivingFinAssist;
extern NSString *const kFinAssistName;
extern NSString *const kFinAssistOrg;
extern NSString *const kFinAssistAmt;
extern NSString *const kFinAssistPeriod;
extern NSString *const kFinAssistEnuf;
extern NSString *const kFinAssistEnufWhy;
extern NSString *const kSocSvcAware;

#pragma mark Current Physical Status
extern NSString *const kBathe;
extern NSString *const kDress;
extern NSString *const kEat;
extern NSString *const kHygiene;
extern NSString *const kToileting;
extern NSString *const kWalk;
extern NSString *const kMobilityStatus;
extern NSString *const kMobilityEquipment;

#pragma mark Social Support
extern NSString *const kHasCaregiver;
extern NSString *const kCaregiverName;
extern NSString *const kCaregiverRs;
extern NSString *const kCaregiverContactNum;
extern NSString *const kEContact;
extern NSString *const kEContactName;
extern NSString *const kEContactRs;
extern NSString *const kEContactNum;
extern NSString *const kUCaregiver;
extern NSString *const kUCareStress;
extern NSString *const kCaregivingDescribe;
extern NSString *const kCaregivingAssist;
extern NSString *const kCaregivingAssistType;
extern NSString *const kGettingSupport;
extern NSString *const kCareGiving;
extern NSString *const kFood;
extern NSString *const kMoney;
extern NSString *const kOtherSupport;
extern NSString *const kOthersText;
extern NSString *const kRelativesContact;
extern NSString *const kRelativesEase;
extern NSString *const kRelativesClose;
extern NSString *const kFriendsContact;
extern NSString *const kFriendsEase;
extern NSString *const kFriendsClose;
extern NSString *const kSocialScore;
extern NSString *const kParticipateActivities;
extern NSString *const kSac;
extern NSString *const kFsc;
extern NSString *const kCc;
extern NSString *const kRc;
extern NSString *const kRo;
extern NSString *const kSo;
extern NSString *const kOth;
extern NSString *const kNa;
extern NSString *const kDontKnow;
extern NSString *const kDontLike;
extern NSString *const kMobilityIssues;
extern NSString *const kWhyNotOthers;
extern NSString *const kWhyNoParticipate;
extern NSString *const kHostOthers;

#pragma mark Psychological well-being
extern NSString *const kIsPsychotic;
extern NSString *const kPsychoticRemarks;
extern NSString *const kSuicideIdeas;
extern NSString *const kSuicideIdeasRemarks;

#pragma mark Additional Services
extern NSString *const kBedbug;
extern NSString *const kDriedScars;
extern NSString *const kHoardingBeh;
extern NSString *const kItchyBites;
extern NSString *const kPoorHygiene;
extern NSString *const kBedbugStains;
extern NSString *const kBedbugOthers;
extern NSString *const kBedbugOthersText;
extern NSString *const kRequiresBedbug;
extern NSString *const kRequiresDecluttering;

#pragma mark Summary
extern NSString *const kFinancial;
extern NSString *const kEldercare;
extern NSString *const kBasic;
extern NSString *const kBehEmo;
extern NSString *const kFamMarital;
extern NSString *const kEmployment;
extern NSString *const kLegal;
extern NSString *const kOtherServices;
extern NSString *const kAccom;
extern NSString *const kOtherIssues;
extern NSString *const kProblems;
extern NSString *const kCaseCat;
extern NSString *const kSwVolName;
extern NSString *const kSwVolContactNum;


#pragma mark - Triage

#pragma mark Clinical Results
extern NSString *const kBp1Sys;
extern NSString *const kBp1Dias;
extern NSString *const kHeightCm;
extern NSString *const kWeightKg;
extern NSString *const kBmi;
extern NSString *const kWaistCircum;
extern NSString *const kHipCircum;
extern NSString *const kWaistHipRatio;
extern NSString *const kCbg;
extern NSString *const kBp2Sys;
extern NSString *const kBp2Dias;
extern NSString *const kBp12AvgSys;
extern NSString *const kBp12AvgDias;
extern NSString *const kBp3Sys;
extern NSString *const kBp3Dias;


#pragma mark - Snellen Eye Test

extern NSString *const kRightEye;
extern NSString *const kLeftEye;
extern NSString *const kSix12;
extern NSString *const kTunnel;
extern NSString *const kVisitEye12Mths;


#pragma mark - Additional Services

extern NSString *const kAppliedChas;
extern NSString *const kReferColonos;
extern NSString *const kReceiveFit;
extern NSString *const kReferMammo;
extern NSString *const kReferPapSmear;

#pragma mark - Doctor's consult

extern NSString *const kDocNotes;
extern NSString *const kDocName;
extern NSString *const kDocReferred;


#pragma mark - Basic dental check-up

extern NSString *const kDentalUndergone;
extern NSString *const kDentistReferred;


#pragma mark - SERI Advanced Eye Screening

#pragma mark Medical History
extern NSString *const kChiefComp;
extern NSString *const kOcuHist;
extern NSString *const kHealthHist;

#pragma mark Visual Acuity
extern NSString *const kVaDone;
extern NSString *const kVa;
extern NSString *const kVaSnellenOd;
extern NSString *const kVaLogmarOd;
extern NSString *const kVaSnellenOs;
extern NSString *const kVaLogmarOs;
extern NSString *const kPinSnellenOd;
extern NSString *const kPinLogmarOd;
extern NSString *const kPinSnellenOs;
extern NSString *const  kPinLogmarOs;
extern NSString *const kNearLogmarOd;
extern NSString *const kNearNxOd;
extern NSString *const kNearLogmarOs;
extern NSString *const kNearNxOs;
extern NSString *const kVaComments;

#pragma mark Autorefractor
extern NSString *const kAutoDone;
extern NSString *const kSpRightR1;
extern NSString *const kSpRightR2;
extern NSString *const kSpRightR3;
extern NSString *const kSpRightR4;
extern NSString *const kSpRightR5;
extern NSString *const kCylRightR1;
extern NSString *const kCylRightR2;
extern NSString *const kCylRightR3;
extern NSString *const kCylRightR4;
extern NSString *const kCylRightR5;
extern NSString *const kAxisRightR1;
extern NSString *const kAxisRightR2;
extern NSString *const kAxisRightR3;
extern NSString *const kAxisRightR4;
extern NSString *const kAxisRightR5;
extern NSString *const kKerMmRightR1;
extern NSString *const kKerMmRightR2;
extern NSString *const kKerDioRightR1;
extern NSString *const kKerDioRightR2;
extern NSString *const kKerAxRightR1;
extern NSString *const kKerAxRightR2;
extern NSString *const kSpLeftR1;
extern NSString *const kSpLeftR2;
extern NSString *const kSpLeftR3;
extern NSString *const kSpLeftR4;
extern NSString *const kSpLeftR5;
extern NSString *const kCylLeftR1;
extern NSString *const kCylLeftR2;
extern NSString *const kCylLeftR3;
extern NSString *const kCylLeftR4;
extern NSString *const kCylLeftR5;
extern NSString *const kAxisLeftR1;
extern NSString *const kAxisLeftR2;
extern NSString *const kAxisLeftR3;
extern NSString *const kAxisLeftR4;
extern NSString *const kAxisLeftR5;
extern NSString *const kKerMmLeftR1;
extern NSString *const kKerMmLeftR2;
extern NSString *const kKerDioLeftR1;
extern NSString *const kKerDioLeftR2;
extern NSString *const kKerAxLeftR1;
extern NSString *const kKerAxLeftR2;
extern NSString *const kPupilDist;
extern NSString *const kAutorefractorComment;

#pragma mark Intra-ocular Pressure
extern NSString *const kIopDone;
extern NSString *const kIopRight;
extern NSString *const kIopLeft;
extern NSString *const kIopComment;

#pragma mark Anterior Health Examination
extern NSString *const kAheDone;
extern NSString *const kAheOd;
extern NSString *const kAheOdRemark;
extern NSString *const kAheOs;
extern NSString *const kAheOsRemark;
extern NSString *const kAheComment;

#pragma mark Posterior Health Examination
extern NSString *const kPheDone;
extern NSString *const kPheFundusOd;
extern NSString *const kPheFundusOdRemark;
extern NSString *const kPheFundusOs;
extern NSString *const kPheFundusOsRemark;
extern NSString *const kPheComment;

#pragma mark Diagnosis and Follow-up
extern NSString *const kOdNormal;
extern NSString *const kOdRefractive;
extern NSString *const kOdCataract;
extern NSString *const kOdGlaucoma;
extern NSString *const kOdAge;
extern NSString *const kOdDiabetic;
extern NSString *const kOdOthers;
extern NSString *const kDiagOdOthers;
extern NSString *const kOsNormal;
extern NSString *const kOsRefractive;
extern NSString *const kOsCataract;
extern NSString *const kOsGlaucoma;
extern NSString *const kOsAge;
extern NSString *const kOsDiabetic;
extern NSString *const kOsOthers;
extern NSString *const kDiagOsOthers;
extern NSString *const kFollowUp;
extern NSString *const kEyeSpecRef;
extern NSString *const kNonUrgentRefMths;
extern NSString *const kDiagComment;

//Just for the questions sake
extern NSString *const kDiagnosisOd;
extern NSString *const kDiagnosisOs;

#pragma mark - Fall Risk Assessment

/*
 (Enable only if criteria is fulfilled in PROFILING tab)
 (Fall Risk Assmt Tab does not need to be completed for final submission)"
 */

extern NSString *const kPsfuFRA;
extern NSString *const kBalance;
extern NSString *const kGaitSpeed;
extern NSString *const kChairStand;
extern NSString *const kTotal;
extern NSString *const kReqFollowupFRA;


#pragma mark - Geriatric Dementia Assessment

/*
 (Enable only if criteria is fulfilled in PROFILING tab)
 (Geriatric Dementia Tab does not need to be completed for final submission)"
 */

extern NSString *const kPsfuGDA;
extern NSString *const kAmtScore;
extern NSString *const kEduStatus;
extern NSString *const kReqFollowupGDA;


#pragma mark - Health Education


/* Pre-education Knowledge Quiz */
extern NSString *const kEdu1;
extern NSString *const kEdu2;
extern NSString *const kEdu3;
extern NSString *const kEdu4;
extern NSString *const kEdu5;
extern NSString *const kEdu6;
extern NSString *const kEdu7;
extern NSString *const kEdu8;
extern NSString *const kEdu9;
extern NSString *const kEdu10;
extern NSString *const kEdu11;
extern NSString *const kEdu12;
extern NSString *const kEdu13;
extern NSString *const kEdu14;
extern NSString *const kEdu15;
extern NSString *const kEdu16;
extern NSString *const kEdu17;
extern NSString *const kEdu18;
extern NSString *const kEdu19;
extern NSString *const kEdu20;
extern NSString *const kEdu21;
extern NSString *const kEdu22;
extern NSString *const kEdu23;
extern NSString *const kEdu24;
extern NSString *const kEdu25;
extern NSString *const kPreEdScore;

/* Post-education Knowledge Quiz */

extern NSString *const kPostEdScore;



@end
