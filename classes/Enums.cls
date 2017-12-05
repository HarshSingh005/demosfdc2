/***********************************************************************************************************
 * Appirio, Inc
 * Name         : Enums
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For Prototype child inventory web service for website consumption
 * Created Date : 02/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 12/15/2015                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class Enums 
{
    global static string Amex
    {
        get
        {
            return 'American Express';
        }
    }
    global static string Diners
    {
        get
        {
            return 'Diners Club';
        }
    }
    global static string Carte
    {
        get
        {
            return 'Carte Blanche';
        }
    }
    global static string Master
    {
        get
        {
            return 'Master Card';
        }
    }
    global static string FriendlyBadAddress
    {
        get
        {
            return 'Not Approved, Please check your Information';
        }
    }
    
    global enum OrgName
    {
        
        CHURCH,
            CORPORATION,
            INC,
            SCHOOL,
            UNIVERSITY,
            COLLEGE,
            FOUNDATION,
            UNITED_WAY
	}
    
    
    
    global enum CreditCardCountries
    {
        US,
            UK,
            CA
            
            }
    
    global enum AGPType
    {
        CR,
            DB,
            CH,
            SS,
            SA
            }
    
    
    global enum CardVendor
    {
        MasterCard,
            BankCard,
            Visa,
            AmericanExpress,
            Discover,
            DinersClub,
            EnRoute,
            JCB,
            MC,
            VI,
            AE,
            AMEX,
            DS,
            DI,
            DC,
            CB,
            JC,
            ER
            }
    
    global enum AgpStatus
    {
        A,
            I
            }
    
    global enum PaymentType
    {
        ACH,
            CC
            }
    
    global enum ContactType
    {
        INDV,
            ORG
            }
    
    global enum SponsorshipContactType
    {
        GF,
            ST
            }
    
    global enum SponsorshipStatus
    {
        P,
            S,
            N,
            C,
            O,
            R
            }
    
    global enum DBActivity
    {
        dbINSERT,
            dbUPDATE,
            dbDELETE
            }
    
    global enum EffDateType
    {
        NOW,
            WAIT
            }
    
    global enum EmailNotificationType
    {
        None,
            SuccessfulSponsorship,
            SuccessfulContribution,
            UnsuccessfulSponsorshipWithId,
            SponsorshipThankYouResponse,
            UnsuccessfulContribution,
            SuccessfulRmi,
            UnsuccessfulRegistration,
            SuccessfulGiftCat,
            UnsuccessfulGiftCat,
            SignInConfirmation,
            PasswordChangeReminder,
            PasswordChange,
            PasswordReset,
            SuccessfulRegistration,
            NonUniqueEmail,
            UnsuccessfulTrans,
            SuccessfulAgp,
            UnsuccessfulSponsorshipNoId,
            WithOffer,
            ForgottenUserID,
            DFConfirm,
            CreditCardReject,
            ChildLetter,
            PasswordLink,
            WebUserDelete,
            EktronAccount
            }
    
    global enum HouseHoldMatch
    {
        HOUSEHOLD,
            ABSOLUTEEXTITLE,
            ABSOLUTE,
            ALL
            }
    
    global enum Letter
    {
        WEB,
            AGR
            }
    
    global enum OriginCode
    {
        W
            }
    
    
    global enum RelationshipType
    {
        STANDARD,
            GIVER,
            RECIPIENT,
            ORG_CORR,
            ORG_ORIG
            }
    
    global enum QueueType
    {
        queueTrans,
            queuePending,
            queueError
            }
    
    global enum TransactionType
    {
        NEWTrans,
            REPROCESSED,
            PROCESSED,
            EXCEPTIONTrans,
            DELETED,
            PENDING,
            LOCKED,
            QUEUED
            }
    
    global enum WebAssignReplace
    {
        WEBMA,
            WEBMAR,
            WEBMAG,
            WEBMARG,
            NMA
            }
    
    global enum YesNo
    {
        N,
            Y
            }
    
    global enum ContactMatchType
    {
        NoMatch,
            ContactMatch,
            MultiNameAddressMatch,
            OneHouseHoldMatch,
            MultiHouseHoldMatch
            }
    
    global enum FinCode
    {
        Donation,
            Sponsorship,
            GiftCatalog,
            EssentialsForSurvival,
            Unknown
            }
    
    global enum MarketingId
    {
        InHonorOfDonation,
            WebDonation,
            WebSponsorship,
            WebRegistration,
            Unknown
            }
    
    global enum PaymentFrequency
    {
        //[Description("O")]
        OneTime,
            
            //[Description("M")]
            Monthly,
            
            //[Description("Q")]
            Quarterly,
            
            //[Description("S")]
            SemiAnnually,
            
            //[Description("A")]
            Annually
            }
    
    global enum DonationTransType
    {
        Sponsorship,
            GiftCatalog,
            DesignatedFund,
            FundAProject,
            StandardDonation,
            RecurringDonation,
            Unknown
            }
    
    global enum PixelType
    {
        INCLUDE,
            EXCLUDE
            }
    
    global enum Other
    {
        UNKNOWN,
            UN,
            U,
            P
            }
    
    
    global enum FriendlyEnums
    {
        None,
            AccountNumberInvalid,
            AgpError,
            AgpErrorOccurred,
            AgpErrorPaymentScheduleNotAdded,
            AgpPlanAlreadyExists,
            AgpPlanInactiveInES,
            CannotRegisterIAUsers,
            CardTypeInvalid,
            ChildAlreadySponsored,
            ChildNotAvailableForSponsorship,
            ChildSelectionRequired,
            ContactIdNotFoundInES,
            ContactMarkedAsDeceased,
            ContactUpdateErrorOccurred,
            ContactUsesAnInternalContactId,
            CorrespondenceCatalogOrderConfirmation,
            CorrespondenceGiftConfirmation,
            CorrespondenceInformationOnYourSponsoredChild,
            CorrespondenceSorryCouldNotCompleteRequest,
            CorrespondenceThankYou,
            DesignatedFundInvalid,
            DonationAmountExceedsMaxAllowed,
            DonationRequiredTransactionCannotProceed,
            DonorCareOfRequired,
            DonorCareOfRequiredForOrgTypeOnly,
            DonorEmailInvalid,
            DonorEmailRequired,
            DonorPhoneAreaCodeInvalid,
            DonorPhoneInvalid,
            FinancialCodeRequiredTransactionCannotProceed,
            FirstNameInvalid,
            FirstNameNotRequiredForOrgType,
            FirstNameRequired,
            GiftAmountExceedsMaxAllowed,
            GiftAmountRequired,
            GiverAndRecipientCannotBeSame,
            HeardAboutUsSelectionRequired,
            HouseholdMultipleMatchConditionsExist,
            HouseholdSingleMatchConditionExists,
            LastNameInvalid,
            LastNameRequired,
            MailingAddressInvalid,
            MarketingIdRequired,
            NameAndAddressMultipleAbsoluteMatchesExist,
            NotApprovedCheckBankInfo,
            NotApprovedContactBank,
            PaymentExpirationDateInvalid,
            PaymentFrequencyRequired,
            PaymentFrequencyRequiredTransactionCannotProceed,
            PaymentTypeInvalid,
            PreSponsorshipQtyMaxReached,
            RoutingNumberInvalid,
            SponsorshipBusinessRuleProhibitedSetup,
            SponsorshipCreationError,
            SponsorshipProhibitedAtThisTime,
            TransactionFailed,
            YouCannotSponsorAChildAtThisTime,
            InvalidCard
            }
    
    global enum BoxUploadQueueType
    {
        queueBoxUpload,
            queueBoxUploadError
            } 
    
    global enum ReturnMsg
    {
        Success,
        Failure,
        Unknown
    }
    
    global enum MCSLetterType
    {
        ChildWelcome,
        ChildBonding,
        ThankYou,
        Sponsor,
        ChildReply,
        ChildInitiated,
        ChildProgress,
        NationalDirectorWelcome,
        SubShiftNationalDirectorWelcome,
        ChildSpontaneous,
        ChildFarewell
    }
}