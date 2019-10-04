//
//  AppConstants.h
//  NHS
//
//  Created by Mac Pro on 8/15/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConstants : NSObject

#define NOTIFICATION_RELOAD_TABLE @"notif_reload_table"

#define SCREENING_PARTICIPANT_SIGNATURE  @"user_signature_path1"
#define SCREENING_CONSENT_TAKER_SIGNATURE  @"user_signature_path2"
#define RESEARCH_PARTICIPANT_6_PTS_SIGNATURE  @"user_signature_path3"
#define RESEARCH_WITNESS_SIGNATURE  @"user_signature_path4"
#define HEARING_REFERRER_SIGNATURE  @"user_signature_path5"

#define REMOTE_HOST_NAME @"www.apple.com"
#define ERROR_INFO @"com.alamofire.serialization.response.error.data"

#define DEFAULT_FONT_SIZE 15
#define DEFAULT_FONT_NAME @"AppleSDGothicNeo-Regular"
#define DEFAULT_ROW_HEIGHT_FOR_SECTIONS 70.0

#pragma mark - Section Names for Submission

#define SECTION_RESI_PART                       @"resi_particulars"
#define SECTION_MODE_OF_SCREENING               @"mode_of_screening"
#define SECTION_CONSENT_DISCLOSURE              @"consent_disclosure"
#define SECTION_CONSENT_RESEARCH                @"consent_research"
#define SECTION_PHLEBOTOMY_ELIGIBILITY_ASSMT    @"phlebotomy_eligibility_assmt"
#define SECTION_MAMMOGRAM_INTEREST              @"mammogram_interest"
#define SECTION_IMAGES                          @"images"
#define SECTION_PHLEBOTOMY_RESULTS              @"phlebotomy_results"
#define SECTION_PHLEBOTOMY                      @"phlebotomy"
#define SECTION_PROFILING_SOCIOECON             @"profiling_socioecon"
#define SECTION_FIN_ASSMT                       @"fin_assmt"
#define SECTION_CHAS_PRELIM                     @"chas_prelim"
#define SECTION_COLONOSCOPY_ELIGIBLE            @"colonoscopy_eligible"
#define SECTION_FIT_ELIGIBLE                    @"fit_eligible"
#define SECTION_MAMMOGRAM_ELIGIBLE              @"mammogram_eligible"
#define SECTION_PAP_SMEAR_ELIGIBLE              @"pap_smear_eligible"
#define SECTION_FALL_RISK_ELIGIBLE              @"fall_risk_eligible"
#define SECTION_GERIATRIC_DEMENTIA_ELIGIBLE     @"geriatric_dementia_eligible"
#define SECTION_PHYSIOTHERAPY                   @"physiotherapy"
#define SECTION_GENOGRAM                        @"genograms"
#define SECTION_PROFILING_COMMENTS              @"profiling_comments"
#define SECTION_PROFILING                       @"profiling"
#define SECTION_DIABETES                        @"diabetes"
#define SECTION_HYPERLIPIDEMIA                  @"hyperlipidemia"
#define SECTION_HYPERTENSION                    @"hypertension"
#define SECTION_STROKE                          @"stroke"
#define SECTION_MEDICAL_HISTORY                 @"medical_history"
#define SECTION_SURGERY                         @"surgery"
#define SECTION_HEALTHCARE_BARRIERS             @"healthcare_barriers"
#define SECTION_FAM_HIST                        @"fam_hist"
#define SECTION_RISK_STRATIFICATION             @"risk_stratification"
#define SECTION_DIET                            @"diet"
#define SECTION_EXERCISE                        @"exercise"

#define SECTION_EQ5D                            @"eq5d"
#define SECTION_GERIATRIC_DEMENTIA_ELIGIBLE     @"geriatric_dementia_eligible"

#define SECTION_CURRENT_SOCIOECO_SITUATION      @"current_socioeco_situation"

#define SECTION_SOCIAL_HISTORY                  @"social_history"
#define SECTION_SOCIAL_ASSMT                    @"social_assmt"

#define SECTION_LONELINESS                      @"loneliness"
#define SECTION_DEPRESSION                      @"depression"
#define SECTION_SUICIDE_RISK                    @"suicide_risk"

//#define SECTION_ADV_FALL_RISK_ASSMT             @"adv_fall_risk_assmt"
#define SECTION_GERIATRIC_DEMENTIA_ASSMT        @"geriatric_dementia_assmt"

#define SECTION_CURRENT_PHY_STATUS              @"current_phy_status"
#define SECTION_SOCIAL_SUPPORT                  @"social_support"
#define SECTION_PSYCH_WELL_BEING                @"psych_well_being"
#define SECTION_SW_ADD_SERVICES                 @"sw_add_services"
#define SECTION_SOC_WORK_SUMMARY                @"soc_work_summary"
#define SECTION_CLINICAL_RESULTS                @"clinical_results"
#define SECTION_SNELLEN_TEST                    @"snellen_test"
#define SECTION_EMERGENCY_SERVICES              @"emergency_services"
#define SECTION_ADD_SERVICES                    @"add_services"
#define SECTION_DOC_CONSULT                     @"doc_consult"
#define SECTION_BASIC_DENTAL                    @"basic_dental"


#define SECTION_HEARING                         @"hearing"
#define SECTION_FOLLOW_UP                       @"follow_up"

#define SECTION_SERI_MED_HIST                   @"seri_med_hist"
#define SECTION_SERI_VA                         @"seri_va"
#define SECTION_SERI_AUTOREFRACTOR              @"seri_autorefractor"
#define SECTION_SERI_AR_IMAGES                  @"seri_ar_images"
#define SECTION_SERI_IOP                        @"seri_iop"
#define SECTION_SERI_AHE                        @"seri_ahe"
#define SECTION_SERI_PHE                        @"seri_phe"
#define SECTION_SERI_DIAG                       @"seri_diag"

// 11. Social Work
#define SECTION_SW_DEPRESSION                   @"sw_depression"
#define SECTION_SW_ADV_ASSMT                    @"sw_adv_assmt"
#define SECTION_SW_REFERRALS                    @"sw_referrals"

#define SECTION_FALL_RISK_ASSMT                 @"fall_risk_assmt"
#define SECTION_GERIATRIC_DEMENTIA_ASSMT        @"geriatric_dementia_assmt"
#define SECTION_PRE_HEALTH_EDU                  @"pre_health_edu"
#define SECTION_POST_HEALTH_EDU                 @"post_health_edu"


#define SECTION_CHECKS                          @"checks"
#define SECTION_POST_HEALTH_SCREEN              @"post_health_screen"
#define SECTION_PSFU_MED_ISSUES                 @"psfu_med"
#define SECTION_PSFU_SOCIAL_ISSUES              @"psfu_social"


#pragma mark - UserDefaults

extern NSString *const kResidentAge;
extern NSString *const kQualifySeri;
extern NSString *const kQualifyCHAS;
extern NSString *const kQualifyColonsc;
extern NSString *const kQualifyMammo;
extern NSString *const kQualifyFIT;
extern NSString *const kQualifyPapSmear;
extern NSString *const kQualifyFallAssess;
extern NSString *const kQualifyDementia;
extern NSString *const kQualifyPhleb;
extern NSString *const kFileType;


#pragma mark - Resident Particulars submission
extern NSString *const kTimestamp;
extern NSString *const kLastUpdateTs;
extern NSString *const kResidentId;
extern NSString *const kSectionName;
extern NSString *const kFieldName;
extern NSString *const kNewContent;
extern NSString *const kScreenLocation;
extern NSString *const kResiParticulars;

// 1700
extern NSString *const kNhsSerialId;

#pragma mark - Resident Particulars

extern NSString *const kOldRecord;
extern NSString *const kName;
extern NSString *const kNRIC;
extern NSString *const kNRIC2;
extern NSString *const kGender;
extern NSString *const kBirthDate;
extern NSString *const kBirthYear;
extern NSString *const kAge;

extern NSString *const kCitizenship;
//extern NSString *const kReligion;
extern NSString *const kReligionOthers;
extern NSString *const kHpNumber;
extern NSString *const kHouseNumber;
extern NSString *const kNokName;
extern NSString *const kNokRelationship;
extern NSString *const kNokContact;

extern NSString *const kSpokenLang;
extern NSString *const kBackupSpokenLang;
//extern NSString *const kLangCanto;
//extern NSString *const kLangEng;
//extern NSString *const kLangHindi;
//extern NSString *const kLangHokkien;
//extern NSString *const kLangMalay;
//extern NSString *const kLangMandarin;
//extern NSString *const kLangTamil;
//extern NSString *const kLangTeoChew;
//extern NSString *const kLangOthers;
//extern NSString *const kLangOthersText;

extern NSString *const kEthnicity;
extern NSString *const kWrittenLang;

extern NSString *const kAddress;
extern NSString *const kAddressStreet;
extern NSString *const kAddressBlock;
extern NSString *const kAddressOthersBlock;
extern NSString *const kAddressOthersRoadName;

extern NSString *const kAddressUnitNum;
extern NSString *const kAddressPostCode;

extern NSString *const kNeighbourhood;
extern NSString *const kScreeningLocation;;
extern NSString *const kRemarks;
extern NSString *const kPreregCompleted;
extern NSString *const kIsFinal;
extern NSString *const kConsent;

// consent_disclosure
extern NSString *const kLangExplainedIn;
extern NSString *const kLangExplainedInOthers;
extern NSString *const kConsentTakerFullName;
extern NSString *const kMatriculationNumber;
extern NSString *const kOrganisation;
extern NSString *const kOrganisationOthers;

// consent_research
extern NSString *const kConsentToResearch;
extern NSString *const kConsentRecontact;
extern NSString *const kAgree6PointsImageName;
extern NSString *const kConsentTakerFullName2;
extern NSString *const kConsentSignatureImageName;
extern NSString *const kTranslationDone;
extern NSString *const kWitnessTranslatorFullName;
extern NSString *const kWitnessTranslatorSignatureImageName;
extern NSString *const kNhsSerialNum;

extern NSString *const kMammogramInterest;
//extern NSString *const kHasChas;  //repeated
extern NSString *const kDoneBefore;
extern NSString *const kWillingPay;


/* Search Bar constants
 ********************************************/
extern NSString *const ViewControllerTitleKey;
extern NSString *const SearchControllerIsActiveKey;
extern NSString *const SearchBarTextKey;
extern NSString *const SearchBarIsFirstResponderKey;

#pragma mark - Phlebotomy Eligibility Assessment

//NSString *const kWasTaken = @"was_taken";     //no longer needed
//extern NSString *const kAge40;
extern NSString *const kChronicCond;
extern NSString *const kRegFollowup;
extern NSString *const kEligibleBloodTest;
extern NSString *const kNoBloodTest;
extern NSString *const kWantFreeBt;
extern NSString *const kDidPhleb;
extern NSString *const kIsPr;


#pragma mark - Phlebotomy - Results Collection
extern NSString *const kPhlebDone;
extern NSString *const kModeOfContact;
extern NSString *const kPreferredDay;
extern NSString *const kPreferredTime;
extern NSString *const kPreferredLanguage;
extern NSString *const kResultsCollection;
extern NSString *const kPhlebFollowUp;


#pragma mark - Phlebotomy (not in registration fields)
extern NSString *const kFastingBloodGlucose;
extern NSString *const kTriglycerides;
extern NSString *const kLDL;
extern NSString *const kHDL;
extern NSString *const kCholesterolHdlRatio;
extern NSString *const kTotCholesterol;

#pragma mark - Mode of Screening
extern NSString *const kScreenMode;
extern NSString *const kCentralDate;
extern NSString *const kApptDate;
//extern NSString *const kTicketNum;
extern NSString *const kApptTime;
extern NSString *const kPhlebAppt;
extern NSString *const kNotes;

#pragma mark - Profiling

/** Eligibility Assessments */
extern NSString *const kProfilingComments;
extern NSString *const kProfilingConsent;
extern NSString *const kEmployStat;
extern NSString *const kEmployReasons;
extern NSString *const kEmployOthers;
extern NSString *const kDiscloseIncome;
extern NSString *const kAvgMthHouseIncome;
extern NSString *const kNumPplInHouse;
extern NSString *const kAvgIncomePerHead;
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
extern NSString *const kMammo2Yrs;

extern NSString *const kNoBreastSymptoms;
extern NSString *const kNotBreastfeeding;
extern NSString *const kNotPregnant;

extern NSString *const kHasChas;
extern NSString *const kSporean;
extern NSString *const kWantMammo;
extern NSString *const kPap3Yrs;
extern NSString *const kEngagedSex;
extern NSString *const kWantPap;
extern NSString *const kAgeAbove60;
extern NSString *const kAgeAbove65;
extern NSString *const kAgeCheck;
extern NSString *const kAgeCheck2;
extern NSString *const kFallen12Mths;
extern NSString *const kScaredFall;
extern NSString *const kFeelFall;
extern NSString *const kCognitiveImpair;

/** Medical History */
//Generic variables
extern NSString *const kHasInformed;
extern NSString *const kCheckedBlood;
extern NSString *const kCheckedBp;
extern NSString *const kSeeingDocRegularly;
extern NSString *const kCurrentlyPrescribed;
extern NSString *const kTakingRegularly;

/** Diabetes Mellitus */
extern NSString *const kDMHasInformed;
extern NSString *const kDMCheckedBlood;
extern NSString *const kDMSeeingDocRegularly;
extern NSString *const kDMCurrentlyPrescribed;
extern NSString *const kDMTakingRegularly;

/** Hyperlipidemia */
extern NSString *const kLipidHasInformed;
extern NSString *const kLipidCheckedBlood;
extern NSString *const kLipidSeeingDocRegularly;
extern NSString *const kLipidCurrentlyPrescribed;
extern NSString *const kLipidTakingRegularly;

/** Stroke */
extern NSString *const kStrokeHasInformed;
extern NSString *const kStrokeSeeingDocRegularly;
extern NSString *const kStrokeCurrentlyPrescribed;

/** Hypertension */
extern NSString *const kHTHasInformed;
extern NSString *const kHTCheckedBp;
extern NSString *const kHTSeeingDocRegularly;
extern NSString *const kHTCurrentlyPrescribed;
extern NSString *const kHTTakingRegularly;

/** Other Med History */
extern NSString *const kTakingMeds;
extern NSString *const kMedConds;

/** Surgery */
extern NSString *const kHadSurgery;
extern NSString *const kPastSurgeries;

/** Healthcare Barriers */
extern NSString *const kGpFamDoc;
extern NSString *const kFamMed;
extern NSString *const kPolyclinic;
extern NSString *const kSocHospital;
extern NSString *const kHCBRemarks;
extern NSString *const kNotSeeNeed;
extern NSString *const kCantMakeTime;
extern NSString *const kHCBMobility;
extern NSString *const kHCBFinancial;
extern NSString *const kScaredOfDoc;
extern NSString *const kPreferTraditional;
extern NSString *const kHCBOthers;
extern NSString *const kAeFreq;
extern NSString *const kHospitalizedFreq;
//extern NSString *const kWhyNotFollowUp;
extern NSString *const kOtherBarrier;

/** Family History */
extern NSString *const kFamHighBp;
extern NSString *const kFamHighCholes;
extern NSString *const kFamChd;
extern NSString *const kFamStroke;
extern NSString *const kFamNone;

/** Risk Stratification */
extern NSString *const kDiabeticFriend;
extern NSString *const kDelivered4kgOrGestational;
extern NSString *const kHeartAttack;
extern NSString *const kStroke;
extern NSString *const kAneurysm;
extern NSString *const kKidneyDisease;
extern NSString *const kSmoke;
extern NSString *const kSmokeYes;
extern NSString *const kSmokeNo;

/** Diet History */
extern NSString *const kAlcohol;
extern NSString *const kEatHealthy;
extern NSString *const kVege;
extern NSString *const kFruits;
extern NSString *const kGrainsCereals;
extern NSString *const kHighFats;
extern NSString *const kProcessedFoods;

/** Exercise History */
extern NSString *const kDoesEngagePhysical;
extern NSString *const kEngagePhysical;
extern NSString *const kNoTime;
extern NSString *const kTooTired;
extern NSString *const kTooLazy;
extern NSString *const kNoInterest;

/** Functional Self Rated Quality of Health (EQ5D) */
extern NSString *const kWalking;
extern NSString *const kTakingCare;
extern NSString *const kUsualActivities;
extern NSString *const kPainDiscomfort;

/** Fall Risk Eligible */
extern NSString *const kUndergoneAssmt;
extern NSString *const kMobility;
extern NSString *const kNumFalls;
extern NSString *const kAssistLevel;
extern NSString *const kSteadiness;
extern NSString *const kFallRiskScore;
extern NSString *const kFallRiskStatus;

/** Finance History */
extern NSString *const kEmployStat;
extern NSString *const kOccupation;
extern NSString *const kDiscloseIncome;
extern NSString *const kAvgMthHouseIncome;
extern NSString *const kNumPplInHouse;
extern NSString *const kAvgIncomePerHead;

/** Financial Assessment (Basic) */
extern NSString *const kCopeFin;
extern NSString *const kReceiveFinAssist;
extern NSString *const kSeekFinAssist;

/** CHAS Preliminary Eligibility Assessment */
extern NSString *const kBlueChas;
extern NSString *const kOrangeChas;
extern NSString *const kPgCard;
extern NSString *const kPaCard;
extern NSString *const kOwnsNoCard;

extern NSString *const kDoesOwnChas;
extern NSString *const kDoesNotOwnChasPioneer;
extern NSString *const kChasExpiringSoon;
extern NSString *const kLowHouseIncome;
extern NSString *const kLowHomeValue;
extern NSString *const kWantChas;

/** Social History */
extern NSString *const kMaritalStatus;
extern NSString *const kNumChildren;
extern NSString *const kReligion;
extern NSString *const kHousingType;
extern NSString *const kHousingNumRooms;
extern NSString *const kHighestEduLevel;
extern NSString *const kAddressDuration;
extern NSString *const kLivingArrangement;
extern NSString *const kCaregiverName;

/** Social Assessment (basic) */
extern NSString *const kUnderstands;
extern NSString *const kCloseCare;
extern NSString *const kOpinionConfidence;
extern NSString *const kTrust;
extern NSString *const kSpiritsUp;
extern NSString *const kFeelGood;
extern NSString *const kConfide;
extern NSString *const kDownDiscouraged;
extern NSString *const kSocialAssmtScore;

/** Loneliness */
extern NSString *const kLackCompanionship;
extern NSString *const kLeftOut;
extern NSString *const kIsolated;

/** Depression Assessment (Basic) */
extern NSString *const kPhqQ1;
extern NSString *const kPhqQ2;
extern NSString *const kPhqQ2Score;

/** Suicide Risk Assessment (Basic) */
extern NSString *const kProblemApproach;
extern NSString *const kLivingLife;
extern NSString *const kPossibleSuicide;

#pragma mark - Geriatric Depression Assessment

extern NSString *const kPhqQ3;
extern NSString *const kPhqQ4;
extern NSString *const kPhqQ5;
extern NSString *const kPhqQ6;
extern NSString *const kPhqQ7;
extern NSString *const kPhqQ8;
extern NSString *const kPhqQ9;
extern NSString *const kPhq9Score;
extern NSString *const kDepressionSeverity;
extern NSString *const kQ10Response;

/* Risk Stratification */
extern NSString *const kDiabeticFriend;
extern NSString *const kDelivered4kgOrGestational;
extern NSString *const kHeartAttack;
extern NSString *const kStroke;
extern NSString *const kAneurysm;
extern NSString *const kKidneyDisease;
extern NSString *const kSmoke;
extern NSString *const kSmokeYes;
extern NSString *const kSmokeNo;


#pragma mark - Social Work

/** Social Work (Advanced) Assessment */
extern NSString *const kUnderwentFin;
extern NSString *const kUnderwentSoc;
extern NSString *const kUnderwentPsyc;

/** Social Work Referrals */
extern NSString *const kReferredSsoNil;
extern NSString *const kReferredSsoFinAssist;

extern NSString *const kReferredCoNil;
extern NSString *const kReferredCoDep;
extern NSString *const kReferredCoBefriend;
extern NSString *const kReferredCoAdls;

extern NSString *const kReferredFscNil;
extern NSString *const kReferredFscDep;
extern NSString *const kReferredFscRef;
extern NSString *const kReferredFscCase;

/* Demographics */
extern NSString *const kFilename;

#pragma mark Current Socioeconomic Situation
extern NSString *const kCopeFin;
extern NSString *const kDescribeWork;
extern NSString *const kWhyNotCopeFin;
extern NSString *const kMediExp;
extern NSString *const kHouseRent;
extern NSString *const kDebts;
extern NSString *const kDailyExpenses;
extern NSString *const kOtherExpenses;

extern NSString *const kMoreWhyNotCopeFin;
extern NSString *const kHasChas;
extern NSString *const kHasPgp;
extern NSString *const kHasMedisave;
extern NSString *const kHasInsure;
extern NSString *const kHasCpfPayouts;
extern NSString *const kNoneOfTheAbove;

extern NSString *const kCpfAmt;
extern NSString *const kChasColor;
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
extern NSString *const kMobilityEquipmentText;

#pragma mark Social Support
extern NSString *const kHasCaregiver;
//extern NSString *const kCaregiverName;
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
extern NSString *const kSocialNetwork;
extern NSString *const kParticipateActivities;
extern NSString *const kSac;
extern NSString *const kFsc;
extern NSString *const kCc;
extern NSString *const kRc;
extern NSString *const kRo;
extern NSString *const kSo;
extern NSString *const kOth;
extern NSString *const kNa;     //no longer used
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
extern NSString *const kOptionNil;
extern NSString *const kProblems;
extern NSString *const kInterventions;
extern NSString *const kCommReview;
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
extern NSString *const kIsDiabetic;
extern NSString *const kCbg;
extern NSString *const kBp2Sys;
extern NSString *const kBp2Dias;
extern NSString *const kBp12AvgSys;
extern NSString *const kBp12AvgDias;
extern NSString *const kBp3Sys;
extern NSString *const kBp3Dias;


#pragma mark - 4. Basic Vision
extern NSString *const kSpecs;
extern NSString *const kRightEye;
extern NSString *const kRightEyePlus;
extern NSString *const kLeftEye;
extern NSString *const kLeftEyePlus;
extern NSString *const kSix12;
extern NSString *const kTunnel;
extern NSString *const kVisitEye12Mths;

#pragma mark - 5. Advanced Geriatrics
extern NSString *const kGivenReferral;
extern NSString *const kUndergoneDementia;
extern NSString *const kAmtScore;
extern NSString *const kEduStatus;
extern NSString *const kDementiaStatus;
extern NSString *const kReqFollowupAdvGer;

#pragma mark - 6. Fall Risk Assessment
extern NSString *const kSitStand;
extern NSString *const kBalance;
extern NSString *const kGaitSpeed;
extern NSString *const kSpbbScore;
extern NSString *const kTimeUpGo;
extern NSString *const kFallRisk;
extern NSString *const kPhysioNotes;
extern NSString *const kKeyResults;
extern NSString *const kExternalRisks;
extern NSString *const kOtherFactors;
extern NSString *const kRecommendations;

extern NSString *const kSupineBpSys;
extern NSString *const kSupineBpDias;
extern NSString *const kStandBpSys;
extern NSString *const kStandBpDias;
extern NSString *const kMoreComments;

#pragma mark - Emergency Services

extern NSString *const kUndergoneEmerSvcs;
extern NSString *const kDocNotes;
extern NSString *const kDocName;
extern NSString *const kDocReferred;

#pragma mark - Additional Services

extern NSString *const kAppliedChas;
extern NSString *const kReferColonos;
extern NSString *const kReceiveFit;
extern NSString *const kReferMammo;
extern NSString *const kReferPapSmear;

#pragma mark - Basic dental check-up

extern NSString *const kDentalUndergone;
extern NSString *const kUsesDentures;
extern NSString *const kOralHealth;
extern NSString *const kDentistReferred;

#pragma mark - Hearing

extern NSString *const kUsesAidRight;
extern NSString *const kUsesAidLeft;
extern NSString *const kAttendedHhie;
extern NSString *const kHhieResult;
extern NSString *const kAttendedTinnitus;
extern NSString *const kTinnitusResult;
extern NSString *const kOtoscopyLeft;
extern NSString *const kOtoscopyRight;
extern NSString *const kAttendedAudioscope;
extern NSString *const kPractice500Hz60;
extern NSString *const kAudioL500Hz25;
extern NSString *const kAudioR500Hz25;
extern NSString *const kAudioL1000Hz25;
extern NSString *const kAudioR1000Hz25;
extern NSString *const kAudioL2000Hz25;
extern NSString *const kAudioR2000Hz25;
extern NSString *const kAudioL4000Hz25;
extern NSString *const kAudioR4000Hz25;
extern NSString *const kAudioL500Hz40;
extern NSString *const kAudioR500Hz40;
extern NSString *const kAudioL1000Hz40;
extern NSString *const kAudioR1000Hz40;
extern NSString *const kAudioL2000Hz40;
extern NSString *const kAudioR2000Hz40;
extern NSString *const kAudioL4000Hz40;
extern NSString *const kAudioR4000Hz40;
extern NSString *const kApptReferred;
extern NSString *const kReferrerName;
extern NSString *const kHearingReferrerSign;
extern NSString *const kAbnormalHearing;
extern NSString *const kUpcomingAppt;
extern NSString *const kApptLocation;
extern NSString *const kHearingFollowUp;

#pragma mark - SERI Advanced Eye Screening

extern NSString *const kUndergoneAdvSeri;

#pragma mark Medical History
extern NSString *const kChiefComp;
extern NSString *const kOcuHist;
extern NSString *const kHealthHist;
extern NSString *const kMedHistComments;

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
extern NSString *const kPinLogmarOs;
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
extern NSString *const kGivenVoucher;
extern NSString *const kGivenSmf;
extern NSString *const kDiagComment;

//Just for the questions sake
extern NSString *const kDiagnosisOd;
extern NSString *const kDiagnosisOs;

#pragma mark - Fall Risk Assessment

/*
 (Enable only if criteria is fulfilled in PROFILING tab)
 (Fall Risk Assmt Tab does not need to be completed for final submission)"
 */
extern NSString *const kDidFallRiskAssess;
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
//extern NSString *const kReqFollowupGDA;


#pragma mark - Health Education


/* General education field for submission */
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

/* Pre-education Knowledge Quiz */
extern NSString *const kPreEdu1;
extern NSString *const kPreEdu2;
extern NSString *const kPreEdu3;
extern NSString *const kPreEdu4;
extern NSString *const kPreEdu5;
extern NSString *const kPreEdu6;
extern NSString *const kPreEdu7;
extern NSString *const kPreEdu8;
extern NSString *const kPreEdu9;
extern NSString *const kPreEdu10;
extern NSString *const kPreEdu11;
extern NSString *const kPreEdu12;
extern NSString *const kPreEdu13;
extern NSString *const kPreEdu14;
extern NSString *const kPreEdu15;
extern NSString *const kPreEdu16;
extern NSString *const kPreEdu17;
extern NSString *const kPreEdu18;
extern NSString *const kPreEdu19;
extern NSString *const kPreEdu20;
extern NSString *const kPreEdu21;
extern NSString *const kPreEdu22;
extern NSString *const kPreEdu23;
extern NSString *const kPreEdu24;
extern NSString *const kPreEdu25;

/* Post-education Knowledge Quiz */
extern NSString *const kPostEdu1;
extern NSString *const kPostEdu2;
extern NSString *const kPostEdu3;
extern NSString *const kPostEdu4;
extern NSString *const kPostEdu5;
extern NSString *const kPostEdu6;
extern NSString *const kPostEdu7;
extern NSString *const kPostEdu8;
extern NSString *const kPostEdu9;
extern NSString *const kPostEdu10;
extern NSString *const kPostEdu11;
extern NSString *const kPostEdu12;
extern NSString *const kPostEdu13;
extern NSString *const kPostEdu14;
extern NSString *const kPostEdu15;
extern NSString *const kPostEdu16;
extern NSString *const kPostEdu17;
extern NSString *const kPostEdu18;
extern NSString *const kPostEdu19;
extern NSString *const kPostEdu20;
extern NSString *const kPostEdu21;
extern NSString *const kPostEdu22;
extern NSString *const kPostEdu23;
extern NSString *const kPostEdu24;
extern NSString *const kPostEdu25;
extern NSString *const kPostEdScore;
extern NSString *const kDateEd;

/* Post-screening Knowledge Quiz */
extern NSString *const kPostScreenEdu1;
extern NSString *const kPostScreenEdu2;
extern NSString *const kPostScreenEdu3;
extern NSString *const kPostScreenEdu4;
extern NSString *const kPostScreenEdu5;
extern NSString *const kPostScreenEdu6;
extern NSString *const kPostScreenEdu7;
extern NSString *const kPostScreenEdu8;
extern NSString *const kPostScreenEdu9;
extern NSString *const kPostScreenEdu10;
extern NSString *const kPostScreenEdu11;
extern NSString *const kPostScreenEdu12;
extern NSString *const kPostScreenEdu13;
extern NSString *const kPostScreenEdu14;
extern NSString *const kPostScreenEdu15;
extern NSString *const kPostScreenEdu16;
extern NSString *const kPostScreenEdu17;
extern NSString *const kPostScreenEdu18;
extern NSString *const kPostScreenEdu19;
extern NSString *const kPostScreenEdu20;
extern NSString *const kPostScreenEdu21;
extern NSString *const kPostScreenEdu22;
extern NSString *const kPostScreenEdu23;
extern NSString *const kPostScreenEdu24;
extern NSString *const kPostScreenEdu25;

extern NSString *const kPostScreenEdScore;


#pragma mark - PSFU Questionnaire

/** Medical Issues */
extern NSString *const kFaceMedProb;
extern NSString *const kWhoFaceMedProb;

extern NSString *const kMedResident;
extern NSString *const kMedResFamily;
extern NSString *const kMedResFlatmate;
extern NSString *const kMedResNeighbour;

extern NSString *const kFamilyName;
extern NSString *const kFamilyAdd;
extern NSString *const kFamilyHp;
extern NSString *const kFlatmateName;
extern NSString *const kFlatmateAdd;
extern NSString *const kFlatmateHp;
extern NSString *const kNeighbourName;
extern NSString *const kNeighbourAdd;
extern NSString *const kNeighbourHp;

extern NSString *const kHaveHighBpChosCbg;
extern NSString *const kHaveOtherMedIssues;
extern NSString *const kHistMedIssues;
extern NSString *const kPsfuSeeingDoct;
extern NSString *const kNhsfuFlag;

/** Social Issues */
extern NSString *const kFaceSocialProb;
extern NSString *const kWhoFaceSocialProb;

extern NSString *const kSocialResident;
extern NSString *const kSocialResFamily;
extern NSString *const kSocialResFlatmate;
extern NSString *const kSocialResNeighbour;

// share the same from Med Issues

//extern NSString *const kSocialFamilyName;
//extern NSString *const kSocialFamilyAdd;
//extern NSString *const kSocialFamilyHp;
//extern NSString *const kSocialFlatmateName;
//extern NSString *const kSocialFlatmateAdd;
//extern NSString *const kSocialFlatmateHp;
//extern NSString *const kSocialNeighbourName;
//extern NSString *const kSocialNeighbourAdd;
//extern NSString *const kSocialNeighbourHp;

extern NSString *const kNotConnectSocWkAgency;
extern NSString *const kUnwillingSeekAgency;
extern NSString *const kNhsswFlag;
extern NSString *const kSpectrumConcerns;
extern NSString *const kNatureOfIssue;
extern NSString *const kSocIssueCaregiving;
extern NSString *const kSocIssueFinancial;
extern NSString *const kSocIssueOthers;
extern NSString *const kSocIssueOthersText;

#pragma mark - Check Variables
/**     1. Triage       */
extern NSString *const kCheckClinicalResults;

/**     2. Phlebotomy       */
extern NSString *const kCheckPhlebResults;
extern NSString *const kCheckPhleb;

extern NSString *const kCheckScreenMode;
extern NSString *const kCheckProfiling;

/**     3a. Medical History (group)       */
extern NSString *const kCheckDiabetes;
extern NSString *const kCheckHyperlipidemia;
extern NSString *const kCheckHypertension;
extern NSString *const kCheckStroke;
extern NSString *const kCheckMedicalHistory;
extern NSString *const kCheckSurgery;
extern NSString *const kCheckHealthcareBarriers;
extern NSString *const kCheckFamHist;
extern NSString *const kCheckRiskStratification;

/**     3b. Diet & Exercise History (group)       */
extern NSString *const kCheckDiet;
extern NSString *const kCheckExercise;

/**     3c. Cancer Screening Eligibility Assessment (group)       */
extern NSString *const kCheckFitEligible;
extern NSString *const kCheckMammogramEligible;
extern NSString *const kCheckPapSmearEligible;

/**     3d. Basic Geriatric (group)       */
extern NSString *const kCheckEq5d;
extern NSString *const kCheckFallRiskEligible;
extern NSString *const kCheckGeriatricDementiaEligible;

/**     3e. Financial History & Assessment (group)       */

extern NSString *const kCheckProfilingSocioecon;
extern NSString *const kCheckFinAssmt;
extern NSString *const kCheckChasPrelim;

/**     3f. Social History & Assessment (group)       */
extern NSString *const kCheckSocialHistory;
extern NSString *const kCheckSocialAssmt;

/**     3g. Psychology History & Assessment (group)       */
extern NSString *const kCheckLoneliness;
extern NSString *const kCheckDepression;
extern NSString *const kCheckSuicideRisk;

/**     4. Basic Vision     */
extern NSString *const kCheckSnellenTest;

/**     5. Advanced Geriatric    */
extern NSString *const kCheckGeriatricDementiaAssmt;
extern NSString *const kCheckReferrals;

/**    6. Fall Risk Assessment     */
extern NSString *const kCheckPhysiotherapy;

/**    7. Dental     */
extern NSString *const kCheckBasicDental;

/**     8. Hearing     */
extern NSString *const kCheckHearing;
extern NSString *const kCheckFollowUp;

/**     9. Advanced Vision (group)     */
extern NSString *const kCheckSeriMedHist;
extern NSString *const kCheckSeriVa;
extern NSString *const kCheckSeriAutorefractor;
extern NSString *const kCheckSeriIop;
extern NSString *const kCheckSeriAhe;
extern NSString *const kCheckSeriPhe;
extern NSString *const kCheckSeriDiag;

/** 10. Emergency Services          */
extern NSString *const kCheckEmergencyServices;

/**     11. Additional Services     */
extern NSString *const kCheckAddServices;

/**     12. Social Work (group)     */
extern NSString *const kCheckSwDepression;
extern NSString *const kCheckSwAdvAssmt;
extern NSString *const kCheckSwReferrals;

/**     13. Summary & Health Education     */
//don't need any checks for this!

/**     UNUSED!!     */
extern NSString *const kCheckCurrentPhyStatus;
extern NSString *const kCheckSocialSupport;
extern NSString *const kCheckPsychWellbeing;
extern NSString *const kCheckSocWorkSummary;
extern NSString *const kCheckAdd;
extern NSString *const kCheckFall;
extern NSString *const kCheckDementia;
extern NSString *const kCheckEd;
extern NSString *const kCheckEdPostScreen;
extern NSString *const kCheckHhie;
extern NSString *const kCheckFuncHearing;
extern NSString *const kCheckPSFUMedIssues;
extern NSString *const kCheckPSFUSocialIssues;
extern NSString *const kCheckGeno;

//remove in 2019
extern NSString *const kCheckAdvFallRiskAssmt;
extern NSString *const kCheckDocConsult;



@end
