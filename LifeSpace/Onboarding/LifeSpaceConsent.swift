//
//  LifeSpaceConsent.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 6/9/24.
//

import ResearchKit

// swiftlint:disable line_length function_body_length unavailable_function
class LifeSpaceConsent: ORKConsentDocument {
    override init() {
        super.init()

        title = "LifeSpace Consent"
        sections = []
        
        // MARK: SECTION 0 - Questions
        let questionsSection = ORKConsentSection(type: .custom)
        questionsSection.title = "For questions about the study, contact:"
        questionsSection.formalTitle = "For questions about the study, contact:"
        let questionsText = """
        Michelle C. Odden, PhD, 1701 Page Mill Rd., Palo Alto, CA 94304, (650) 721-0230, modden@stanford.edu
        """
        questionsSection.summary = questionsText
        questionsSection.content = questionsText
        
        sections?.append(questionsSection)

        // MARK: SECTION 1 - Description
        let descriptionSection = ORKConsentSection(type: .custom)
        descriptionSection.title = "Description"
        descriptionSection.formalTitle = "Description"
        let descriptionText = """
        You are invited to participate in a research study on life space, or the space within which people live, work, and recreate. Based on a custom iPhone Life Space application, we will develop individual life space maps (geographic footprint) in order to evaluate the association of aspects of environmental features with health and well-being. This research study is looking for 120 StrokeCog participants to be enrolled. Stanford University expects to enroll 120 research study participants.
        
        To participate in this study, you will download the LifeSpace App and complete the consent form. As a part of this research study, you will be asked to sign in using your AppleID. To do this, you will have to review and agree to the LifeSpace App Privacy Policy. This document is separate from this consent form.
        
        The LifeSpace App will passively capture your location for two weeks. Each evening, you will complete a brief survey of four questions on the app.

        """
        descriptionSection.summary = descriptionText
        descriptionSection.content = descriptionText

        sections?.append(descriptionSection)

        // MARK: SECTION 2 - RISKS AND BENEFITS
        let risksAndBenefitsSection = ORKConsentSection(type: .custom)
        risksAndBenefitsSection.title = "Risks and Benefits"
        risksAndBenefitsSection.formalTitle = "Risks and Benefits"
        let risksAndBenefitsText = """
        The primary risk associated with this study is a potential loss of privacy, and we have taken all measures to minimize this risk. If for any reason you do not wish to have your location recorded temporarily, you can toggle the “Track My Location” button and the app will stop recording until you start it again. Your data are stored securely, and your name and Apple ID will be removed from your data when it is downloaded.
        
        We cannot and do not guarantee or promise that you will receive any benefits from this study. The long-term goal of this research is to better understand the role of the physical environment in contributing to cognitive trajectory after stroke.
        
        Your decision whether or not to participate in this study will not affect your medical care.
        """
        risksAndBenefitsSection.summary = risksAndBenefitsText
        risksAndBenefitsSection.content = risksAndBenefitsText

        sections?.append(risksAndBenefitsSection)

        // MARK: SECTION 3 - TIME INVOLVEMENT
        let timeInvolvementSection = ORKConsentSection(type: .custom)
        timeInvolvementSection.title = "Time Involvement"
        let timeInvolvementText = """
        Our LifeSpace App will passively capture location for a period of two weeks. Each evening, you will be asked to complete a brief survey of three questions (1-2 minutes).
        """
        timeInvolvementSection.summary = timeInvolvementText
        timeInvolvementSection.content = timeInvolvementText

        sections?.append(timeInvolvementSection)

        // MARK: SECTION 4 - PAYMENTS
        let paymentsSection = ORKConsentSection(type: .custom)
        paymentsSection.title = "Payments"
        let paymentsText = """
        You will not receive payment for your participation.
        """
        paymentsSection.summary = paymentsText
        paymentsSection.content = paymentsText

        sections?.append(paymentsSection)

        // MARK: SECTION 5 - PARTICIPANT'S RIGHTS
        let participantsRightsSection = ORKConsentSection(type: .custom)
        participantsRightsSection.title = "Participant's Rights"
        let participantsRightsText = """
        If you have read this form and have decided to participate in this project, please understand your participation is voluntary and you have the right to withdraw your consent or discontinue participation at any time without penalty or loss of benefits to which you are otherwise entitled.
        
        The results of this research study may be presented at scientific or professional meetings or published in scientific journals.  However, your identity will not be disclosed.

        You have the right to refuse to answer particular questions.
        Your decision whether or not to participate in this study will not affect your participation in the StrokeCog study.
        """
        participantsRightsSection.summary = participantsRightsText
        participantsRightsSection.content = participantsRightsText

        sections?.append(participantsRightsSection)

        // MARK: SECTION 8 - WITHDRAWAL FROM STUDY
        let withdrawalFromStudySection = ORKConsentSection(type: .custom)
        withdrawalFromStudySection.title = "Withdrawal from Study"
        let withdrawalFromStudyText = """
        If you first agree to participate and then you change your mind, you are free to withdraw your consent and discontinue your participation at any time.

        If you decide to withdraw your consent to participate in this study, you should notify the LifeSpace study team (lifespace@stanford.edu) or Michelle Odden (650-721-0230, modden@stanford.edu).

        If you decide to withdraw from the study, you can delete the LifeSpace App from your phone.

        The Protocol Director may also withdraw you from the study without your consent for one or more of the following reasons:

        • Failure to follow the instructions of the Protocol Director and study staff.
        • Unanticipated circumstances.
        """
        withdrawalFromStudySection.summary = withdrawalFromStudyText
        withdrawalFromStudySection.content = withdrawalFromStudyText

        sections?.append(withdrawalFromStudySection)

        // MARK: SECTION 10 - CONTACT INFORMATION
        let contactSection = ORKConsentSection(type: .onlyInDocument)
        contactSection.title = "Contact Information"
        let contactSectionText = """
        Questions, Concerns, or Complaints: If you have any questions, concerns or complaints about this research study, its procedures, risks and benefits, you should ask the Protocol Director, Michelle Odden, (650) 721-0230. You should also contact her at any time if you feel you have been hurt by being a part of this study.

        Independent Contact: If you are not satisfied with how this study is being conducted, or if you have any concerns, complaints, or general questions about the research or your rights as a participant, please contact the Stanford Institutional Review Board (IRB) to speak to someone independent of the research team at 650-723-5244 or toll free at 1-866-680-2906.  You can also write to the Stanford IRB, Stanford University, 1705 El Camino Real, Palo Alto, CA 94306.
        """
        contactSection.summary = contactSectionText
        contactSection.content = contactSectionText

        sections?.append(contactSection)

        // MARK: SECTION 11 - SUMMARY
        let summarySection = ORKConsentSection(type: .onlyInDocument)
        summarySection.title = "Summary"
        summarySection.formalTitle = ""
        let summarySectionText = """
        A copy of this form is saved in your profile in the LifeSpace App – please print or save this locally to your iPhone. If you agree to participate in this research, please select the Agree button.
        """
        summarySection.content = summarySectionText

        sections?.append(summarySection)

        // MARK: SIGNATURE
        let signature = ORKConsentSignature(
            forPersonWithTitle: nil,
            dateFormatString: nil,
            identifier: "ConsentDocumentParticipantSignature"
        )
        signature.title = title
        signaturePageTitle = title
        addSignature(signature)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
