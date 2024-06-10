//
//  HIPAAAuthorization.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 6/10/24.
//

import ResearchKit


// swiftlint:disable line_length function_body_length unavailable_function
class HIPAAAuthorization: ORKConsentDocument {
    override init() {
        super.init()
        
        title = "Authorization To Use Your Health Information For Research Purposes"
        sections = []
        
        let summarySection = ORKConsentSection(type: .custom)
        summarySection.title = ""
        summarySection.formalTitle = ""
        let summaryText = """
        Because information about you and your health is personal and private, it generally cannot be used in this research study without your written authorization.  If you sign this form, it will provide that authorization.  The form is intended to inform you about how your health information will be used or disclosed in the study.  Your information will only be used in accordance with this authorization form and the informed consent form and as required or allowed by law.  Please read it carefully before signing it.
        """
        summarySection.summary = summaryText
        summarySection.content = summaryText
        sections?.append(summarySection)
        
        let purposeSection = ORKConsentSection(type: .custom)
        purposeSection.title = "What is the purpose of this research study and how will my health information be utilized in the study?"
        purposeSection.formalTitle = "What is the purpose of this research study and how will my health information be utilized in the study?"
        let purposeText = """
        The long-term goal of this research is to better understand the role of the physical environment in contributing to cognitive trajectory after stroke. Data collected from this study will be linked to data from your StrokeCog annual visits.
        """
        purposeSection.summary = purposeText
        purposeSection.content = purposeText
        sections?.append(purposeSection)
        
        let authorizationSection = ORKConsentSection(type: .custom)
        authorizationSection.title = "Do I have to sign this authorization form?"
        authorizationSection.formalTitle = "Do I have to sign this authorization form?"
        let authorizationText = """
        You do not have to sign this authorization form.  But if you do not, you will not be able to participate in this research study. Signing the form is not a condition for receiving any medical care outside the study.
        """
        authorizationSection.summary = authorizationText
        authorizationSection.content = authorizationText
        sections?.append(authorizationSection)
        
        let revokeSection = ORKConsentSection(type: .custom)
        revokeSection.title = "If I sign, can I revoke it or withdraw from the research later?"
        revokeSection.formalTitle = "If I sign, can I revoke it or withdraw from the research later?"
        let revokeText = """
        If you decide to participate, you are free to withdraw your authorization regarding the use and disclosure of your health information (and to discontinue any other participation in the study) at any time.  After any revocation, your health information will no longer be used or disclosed in the study, except to the extent that the law allows us to continue using your information (e.g., necessary to maintain integrity of research).  If you wish to revoke your authorization for the research use or disclosure of your health information in this study, you must write to: Dr. Michelle Odden, Associate Professor of Epidemiology and Population Health at Stanford University at modden@stanford.edu.
        """
        revokeSection.summary = revokeText
        revokeSection.content = revokeText
        sections?.append(revokeSection)
        
        let personalInfoSection = ORKConsentSection(type: .custom)
        personalInfoSection.title = "What Personal Information Will Be Obtained, Used or Disclosed?"
        personalInfoSection.formalTitle = "What Personal Information Will Be Obtained, Used or Disclosed?"
        let personalInfoText = """
        Your health information related to this study, may be used or disclosed in connection with this research study, including, but not limited to:

        During recruitment, our study collects the following identifiers:
        1) your participation as a StrokeCog participant, which includes participants with a history of stroke, and
        2) your name, which is needed for enrollment

        The identifiers collected during recruitment will be removed as soon as the study data collection is completed and prior to analysis.

        Our study app also collects the following identifiers:
        1) Apple ID, which may be your email address
        2) Location/GPS coordinates and date/time
        """
        personalInfoSection.summary = personalInfoText
        personalInfoSection.content = personalInfoText
        sections?.append(personalInfoSection)
        
        let useSection = ORKConsentSection(type: .custom)
        useSection.title = "Who May Use or Disclose the Information?"
        useSection.formalTitle = "Who May Use or Disclose the Information?"
        let useText = """
        The following parties are authorized to use and/or disclose your health information in connection with this research study:
        • The Protocol Director Michelle Odden
        • The Stanford University Administrative Panel on Human Subjects in Medical Research and any other unit of Stanford University as necessary
        • Research Staff
        """
        useSection.summary = useText
        useSection.content = useText
        sections?.append(useSection)
        
        let receiveSection = ORKConsentSection(type: .custom)
        receiveSection.title = "Who May Receive or Use the Information?"
        receiveSection.formalTitle = "Who May Receive or Use the Information?"
        let receiveText = """
        The parties listed in the preceding paragraph may disclose your health information to the following persons and organizations for their use in connection with this research study:

        • The Office for Human Research Protections in the U.S. Department of Health and Human Services

        Your information may be re-disclosed by the recipients described above, if they are not required by law to protect the privacy of the information.
        """
        receiveSection.summary = receiveText
        receiveSection.content = receiveText
        sections?.append(receiveSection)
        
        let expirationSection = ORKConsentSection(type: .custom)
        expirationSection.title = "When will my authorization expire?"
        expirationSection.formalTitle = "When will my authorization expire?"
        let expirationText = """
        Your authorization for the use and/or disclosure of your health information will end on February 28, 2050 or when the research project ends, whichever is earlier.
        """
        expirationSection.summary = expirationText
        expirationSection.content = expirationText
        sections?.append(expirationSection)
        
        // MARK: SIGNATURE
        let signature = ORKConsentSignature(
            forPersonWithTitle: nil,
            dateFormatString: nil,
            identifier: "HIPAAAuthorizationParticipantSignature"
        )
        signature.title = title
        signaturePageTitle = title
        addSignature(signature)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
