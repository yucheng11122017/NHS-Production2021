//
//  AppConstants.m
//  NHS
//
//  Created by Mac Pro on 8/15/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "AppConstants.h"

@implementation AppConstants

/*

 * Form Constants
 ********************************************/
NSString *const kName = @"name";
NSString *const kNRIC = @"nric";
NSString *const kGender = @"gender";
NSString *const kDOB = @"dob";
NSString *const kSpokenLanguage = @"spokenlanguage";
NSString *const kSpokenLangOthers = @"spokenlangothers";
NSString *const kContactNumber = @"contactnumber";
NSString *const kAddStreet = @"addressstreet";
NSString *const kAddBlock = @"addressblock";
NSString *const kAddUnit = @"addressunit";
NSString *const kAddPostCode = @"addresspostcode";
NSString *const kPhleb = @"phleb";
NSString *const kFOBT = @"fobt";
NSString *const kDental = @"dental";
NSString *const kEye = @"eye";
NSString *const kReqServOthers = @"reqservothers";
NSString *const kPrefDate = @"preferreddate";
NSString *const kPrefTime = @"preferredtime";
NSString *const kNeighbourhood = @"neighbourhood";
NSString *const kRemarks = @"remarks";


/* Search Bar constants
 ********************************************/
 NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
 NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
 NSString *const SearchBarTextKey = @"SearchBarTextKey";
 NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";


/* Mode of Screening
 ********************************************/
NSString *const kScreenMode = @"screen_mode";
NSString *const kApptDate = @"appt_date";
NSString *const kApptTime = @"appt_time";

/* Phlebotomy
 ********************************************/
NSString *const kWasTaken = @"was_taken";
NSString *const kFastingBloodGlucose = @"fasting_blood_glu";
NSString *const kTriglycerides = @"trigycerides";
NSString *const kLDL= @"ldl";
NSString *const kHDL= @"hdl";
NSString *const kCholesterolHdlRatio= @"cholesterol_hdl_ratio";
NSString *const kTotCholesterol= @"total_cholesterol";


/* Profiling
 ********************************************/
NSString *const kProfilingConsent= @"consent";
NSString *const kEmployStat= @"employment_status";
NSString *const kEmployReasons= @"employment_reasons";
NSString *const kEmployOthers= @"employment_others";
NSString *const kDiscloseIncome= @"disclose_income";
NSString *const kAvgMthHouseIncome= @"avg_mth_house_income";
NSString *const kNumPplInHouse= @"num_ppl_in_house";
NSString *const kAvgIncomePerHead= @"avg_income_per_head";
NSString *const kDoesntOwnChasPioneer= @"does_not_own_chas_pioneer";
NSString *const kLowHouseIncome= @"low_house_income";
NSString *const kLowHomeValue= @"low_home_value";
NSString *const kWantChas= @"want_chas";
NSString *const kChasColor= @"chas_color";
NSString *const kSporeanPr= @"sporean_pr";
NSString *const kAgeAbove50= @"age_above_50";
NSString *const kRelWColorectCancer= @"rel_w_colorect_cancer";
NSString *const kColonoscopy3yrs= @"colonoscopy_3_yrs";
NSString *const kWantColonoscopyRef= @"want_colonoscopy_ref";
NSString *const kFitLast12Mths= @"fit_last_2_mths";
NSString *const kColonoscopy10Yrs= @"colonoscopy_10_yrs";
NSString *const kWantFitKit= @"want_fit_kit";
NSString *const kMammo2Yrs= @"mammo_2_yrs";
NSString *const kHasChas= @"has_chas";
NSString *const kWantMammo= @"want_mammo";
NSString *const kPap3Yrs= @"pap_3_yrs";
NSString *const kEngagedSex= @"engaged_sex";
NSString *const kWantPap= @"want_pap";
NSString *const kAgeAbove65= @"aged_above_65";
NSString *const kAgeCheck = @"age_check";
NSString *const kAgeCheck2 = @"age_check2";
NSString *const kFallen12Mths= @"fallen_12_mths";
NSString *const kScaredFall= @"scared_fall";
NSString *const kFeelFall= @"feel_fall";
NSString *const kCognitiveImpair= @"cognitive_impairment";

/* Health Assessment and Risk Stratisfaction
 ********************************************/
NSString *const kDMHasInformed= @"dm_has_informed";
NSString *const kDMCheckedBlood= @"dm_checked_blood";
NSString *const kDMSeeingDocRegularly= @"dm_seeing_doc_regularly";
NSString *const kDMCurrentlyPrescribed= @"dm_currently_prescribed";
NSString *const kDMTakingRegularly= @"dm_taking_regularly";

NSString *const kLipidHasInformed= @"lipid_has_informed";
NSString *const kLipidCheckedBlood= @"lipid_checked_blood";
NSString *const kLipidSeeingDocRegularly= @"lipid_seeing_doc_regularly";
NSString *const kLipidCurrentlyPrescribed= @"lipid_currently_prescribed";
NSString *const kLipidTakingRegularly= @"lipid_taking_regularly";

NSString *const kHTHasInformed = @"ht_has_informed";
NSString *const kHTCheckedBp = @"ht_checked_bp";
NSString *const kHTSeeingDocRegularly = @"ht_seeing_doc_regularly";
NSString *const kHTCurrentlyPrescribed = @"ht_currently_prescribed";
NSString *const kHTTakingRegularly = @"ht_taking_regularly";

NSString *const kPhqQ1 = @"phq_q1";
NSString *const kPhqQ2 = @"phq_q2";
NSString *const kPhq9Score = @"phq9_score";
NSString *const kFollowUpReq = @"follow_up_req";

NSString *const kDiabeticFriend = @"diabetic_friend";
NSString *const kDelivered4kgOrGestational = @"delivered4kg_or_gestational";
NSString *const kCardioHistory = @"cardio_history";
NSString *const kSmoke = @"smoke";


/* Social Work
 ********************************************/

/* Current Socioeconomic Situation */
NSString *const kCopeFin = @"cope_fin";
NSString *const kWhyNotCopeFin = @"why_not_cope_fin";
NSString *const kMoreWhyNotCopeFin = @"more_why_not_cope_fin";
//NSString *const kHasChas = @"has_chas";
#warning  look into this
NSString *const kHasPgp = @"has_pgp";
NSString *const kHasMedisave = @"has_medisave";
NSString *const kHasInsure = @"has_insure";
NSString *const kHasCpfPayouts = @"has_cpf_payouts";
NSString *const kCpfAmt = @"cpf_amt";
NSString *const kReceivingFinAssist = @"receiving_fin_assist";
NSString *const kFinAssistName = @"fin_assist_name";
NSString *const kFinAssistORg = @"fin_assist_org";
NSString *const kFinAssistAmt = @"fin_assist_org";
NSString *const kFinAssistPeriod = @"fin_assist_period";
NSString *const kFinAssistEnuf = @"fin_assist_enuf";
NSString *const kFinAssistEnufWhy = @"fin_assist_enuf_why";
NSString *const kSocSvcAware = @"soc_svc_aware";

/* Current Physical Status */
NSString *const kBathe = @"bathe";
NSString *const kDress = @"dress";
NSString *const kEat = @"eat";
NSString *const kHygiene = @"hygiene";
NSString *const kToileting = @"toileting";
NSString *const kWalk = @"walk";
NSString *const kMobilityStatus = @"mobility_status";
NSString *const kMobilityEquipment = @"mobility_equipment";

/* Social Support */
NSString *const kHasCaregiver = @"has_caregiver";
NSString *const kCaregiverName = @"caregiver_name";
NSString *const kCaregiverRs = @"caregiver_rs";
NSString *const kCaregiverContactNum = @"caregiver_contact_num";
NSString *const kEContact = @"e_contact";
NSString *const kEContactName = @"e_contact_name";
NSString *const kEContactRs = @"e_contact_rs";
NSString *const kEContactNum = @"e_contact_num";
NSString *const kUCaregiver = @"u_caregiver";
NSString *const kUCareStress = @"u_care_stress";
NSString *const kCaregivingDescribe = @"caregiving_describe";
NSString *const kCaregivingAssist = @"caregiving_assist";
NSString *const kCaregivingAssistType = @"caregiving_assist_type";
NSString *const kGettingSupport = @"getting_support";
NSString *const kCareGiving = @"care_giving";
NSString *const kFood = @"food";
NSString *const kMoney = @"money";
NSString *const kOtherSupport = @"other_support";
NSString *const kOthersText = @"others_text";
NSString *const kRelativesContact = @"relatives_contact";
NSString *const kRelativesEase = @"relatives_ease";
NSString *const kRelativesClose = @"relatives_close";
NSString *const kFriendsContact = @"friends_contact";
NSString *const kFriendsEase = @"friends_ease";
NSString *const kFriendsClose = @"friends_close";
NSString *const kSocialScore = @"social_score";
NSString *const kParticipateActivities = @"participate_activities";
NSString *const kSac = @"sac";
NSString *const kFsc = @"fsc";
NSString *const kCc = @"cc";
NSString *const kRc = @"rc";
NSString *const kRo = @"ro";
NSString *const kSo = @"so";
NSString *const kOth = @"oth";
NSString *const kNa = @"na";
NSString *const kDontKnow = @"dont_know";
NSString *const kDontLike = @"dont_like";
NSString *const kMobilityIssues = @"mobility_issues";
NSString *const kWhyNotOthers = @"why_not_others";
NSString *const kWhyNoParticipate = @"why_no_participate";
NSString *const kHostOthers = @"host_others";

/* Psychological well-being*/
NSString *const kIsPsychotic = @"is_psychotic";
NSString *const kPsychoticRemarks = @"psychotic_remarks";
NSString *const kSuicideIdeas = @"suicide_ideas";
NSString *const kSuicideIdeasRemarks = @"suicide_ideas_remarks";

/* Additional Services */
NSString *const kBedbug = @"bedbug";
NSString *const kDriedScars = @"dried_scars";
NSString *const kHoardingBeh = @"hoarding_beh";
NSString *const kItchyBites = @"itchy_bites";
NSString *const kPoorHygiene = @"poor_hygiene";
NSString *const kBedbugStains = @"bedbug_stains";
NSString *const kBedbugOthers = @"bedbug_others";
NSString *const kBedbugOthersText = @"bedbug_others_text";
NSString *const kRequiresBedbug = @"requires_bedbug";
NSString *const kRequiresDecluttering = @"requires_decluttering";

/* Summary */
NSString *const kFinancial = @"financial";
NSString *const kEldercare = @"eldercare";
NSString *const kBasic = @"basic";
NSString *const kBehEmo = @"beh_emo";
NSString *const kFamMarital = @"fam_marital";
NSString *const kEmployment = @"employment";
NSString *const kLegal = @"legal";
NSString *const kOtherServices = @"other_services";
NSString *const kAccom = @"accom";
NSString *const kOtherIssues = @"other_issues";
NSString *const kProblems = @"problems";
NSString *const kCaseCat = @"case_cat";
NSString *const kSwVolName = @"sw_vol_name";
NSString *const kSwVolContactNum = @"sw_vol_contact_num";


/* Triage
 ********************************************/

/* Clinical Results */
NSString *const kBp1Sys = @"bp1_sys";
NSString *const kBp1Dias = @"bp1_dias";
NSString *const kHeightCm = @"height_cm";
NSString *const kWeightKg = @"weight_kg";
NSString *const kBmi = @"bmi";
NSString *const kWaistCircum = @"waist_circum";
NSString *const kHipCircum = @"hip_circum";
NSString *const kWaistHipRatio = @"waist_hip_ratio";
NSString *const kCbg = @"cbg";
NSString *const kBp2Sys = @"bp2_sys";
NSString *const kBp2Dias = @"bp2_dias";
NSString *const kBp12AvgSys = @"bp12_avg_sys";
NSString *const kBp12AvgDias = @"bp12_avg_dias";
NSString *const kBp3Sys = @"bp3_sys";
NSString *const kBp3Dias = @"bp3_dias";


@end
