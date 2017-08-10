//
//  AppConstants.h
//  NHS
//
//  Created by Mac Pro on 8/15/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConstants : NSObject

/*
 * Form Constants
 ********************************************/
extern NSString* const baseURL;
extern NSString *const kName;
extern NSString *const kNRIC;
extern NSString *const kGender;
extern NSString *const kDOB;
extern NSString *const kSpokenLanguage;
extern NSString *const kSpokenLangOthers;
extern NSString *const kContactNumber;
extern NSString *const kAddStreet;
extern NSString *const kAddBlock;
extern NSString *const kAddUnit;
extern NSString *const kAddPostCode;
extern NSString *const kPhleb;
extern NSString *const kFOBT;
extern NSString *const kDental;
extern NSString *const kEye;
extern NSString *const kReqServOthers;
extern NSString *const kPrefDate;
extern NSString *const kPrefTime;
extern NSString *const kNeighbourhood;
extern NSString *const kRemarks;

/* Search Bar constants
 ********************************************/
extern NSString *const ViewControllerTitleKey;
extern NSString *const SearchControllerIsActiveKey;
extern NSString *const SearchBarTextKey;
extern NSString *const SearchBarIsFirstResponderKey;

/* Mode of Screening
********************************************/
extern NSString *const kScreenMode;
extern NSString *const kApptDate;
extern NSString *const kApptTime;

/* Phlebotomy
 ********************************************/
extern NSString *const kWasTaken;
extern NSString *const kFastingBloodGlucose;
extern NSString *const kTriglycerides;
extern NSString *const kLDL;
extern NSString *const kHDL;
extern NSString *const kCholesterolHdlRatio;
extern NSString *const kTotCholesterol;


/* Profiling
 ********************************************/
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
extern NSString *const kChasColor;
extern NSString *const kSporeanPr;
extern NSString *const kAgeAbove50;
extern NSString *const kRelWColorectCancer;
extern NSString *const kColonoscopy3yrs;
extern NSString *const kWantColonoscopyRef;
extern NSString *const kFitLast12Mths;
extern NSString *const kColonoscopy10Yrs;
extern NSString *const kWantFitKit;
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

/* Health Assessment and Risk Stratisfaction
 ********************************************/
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


/* Social Work
********************************************/

/* Current Socioeconomic Situation */
extern NSString *const kCopeFin;
extern NSString *const kWhyNotCopeFin;
extern NSString *const kMoreWhyNotCopeFin;
extern NSString *const kHasChas;
extern NSString *const kHasPgp;
extern NSString *const kHasMedisave;
extern NSString *const kHasInsure;
extern NSString *const kHasCpfPayouts;
extern NSString *const kCpfAmt;
extern NSString *const kReceivingFinAssist;
extern NSString *const kFinAssistName;
extern NSString *const kFinAssistOrg;
extern NSString *const kFinAssistAmt;
extern NSString *const kFinAssistPeriod;
extern NSString *const kFinAssistEnuf;
extern NSString *const kFinAssistEnufWhy;
extern NSString *const kSocSvcAware;

/* Current Physical Status */
extern NSString *const kBathe;
extern NSString *const kDress;
extern NSString *const kEat;
extern NSString *const kHygiene;
extern NSString *const kToileting;
extern NSString *const kWalk;
extern NSString *const kMobilityStatus;
extern NSString *const kMobilityEquipment;

/* Social Support */
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

/* Psychological well-being*/
extern NSString *const kIsPsychotic;
extern NSString *const kPsychoticRemarks;
extern NSString *const kSuicideIdeas;
extern NSString *const kSuicideIdeasRemarks;

/* Additional Services */
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

/* Summary */
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


/* Triage
 ********************************************/

/* Clinical Results */
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


/* Snellen Eye Test
 ********************************************/



@end
