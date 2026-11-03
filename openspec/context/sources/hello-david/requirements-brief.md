# Hello David — MVP Build Requirements Brief

**1\. Current state**

Hello David is an AI-powered insurance platform. A live prototype already exists at: hellodavid.com.au. 

The prototype shows the intended brand direction, product concept and customer journey. It is not yet a production-ready product. The next stage is to take the existing prototype, refine the missing product screens in Figma, and then build a production-ready MVP that can be tested with real users and real insurance documents.

**2\. What we are trying to build**

Hello David helps customers organise and understand their insurance documents. The product is not trying to sell insurance, replace a broker, make final coverage decisions or provide financial advice. It helps customers see what insurance they have, ask plain-English questions about their own documents, and know what to check or who to speak to next. The MVP should prove one simple thing:

Can a customer upload \[via sending an email\] their insurance documents, have the key policy details extracted, ask useful questions, and receive a clear summary they can use before speaking to an insurer, broker, adviser or claims team. The experience should feel clean, calm and intelligent — not like filling in another insurance form.

**3\. Target users**

The first users are likely to be:

* Personal customers with multiple policies.  
* SME / business customers with multiple insurance documents.  
* Customers preparing for renewal, a claim, a certificate request or a broker conversation.

The product should be insurance-class agnostic.

**4\. Required scope of work**

We are looking for a full-stack developer / product builder to help with three connected stages.

**Stage 1 — Review the prototype**

Review the current live prototype at [www.hellodavid.com.au](http://www.hellodavid.com.au) and provide feedback on:

* Current UX and product flow.  
* Technical feasibility.  
* Recommended architecture.  
* What should be kept, changed or simplified.  
* What is required to turn the prototype into a working MVP.

**Stage 2 — Build out Figma pages**

Take the current prototype and build out the product screens in Figma before development.

Expected Figma screens include:

* Landing / login page and registration flow.  
* Home dashboard.  
* Insurance Vault.  
* Upload documents \- although we believe the most helpful feature will be to simply email / forward your insurance documents directly from your insurer/advisor.  
* Policy summary cards.  
* Ask David chat screen.  
* Clarity Brief screen.  
* Request help / expert handover flow with key questions you can ask your insurer/broker.  
* Basic admin dashboard.  
* Contact us, about us, legal disclaimers – especially around the non-provision of advice.

The Figma stage should define the final MVP user journey before build starts.

**Stage 3 — Build production-ready MVP**

Build a mobile-first web app that can be tested with real users and real insurance documents.

The MVP should be secure, stable and ready for controlled customer testing.

**5\. Core customer journey**

The MVP journey should be:

1. User creates an account or connects via existing Google accont.  
2. User forwards insurance documents or can upload via cloud or photos.  
3. Hello David extracts key policy details.  
4. Policies are organised into simple policy cards.  
5. User asks David plain-English questions.  
6. User can generate a Clarity Brief / have a portfolio of questions they can ask their insurer/broker.  
7. User can request help or share the brief with consent.

**6\. User account**

Users should be able to create and access a secure account.

Preferred MVP options:

* Google sign-in.  
* Email login or magic link.  
* Mobile-first responsive web experience.

Each user should only be able to access their own documents, policy summaries and chat history.

**7\. Insurance Vault**

The Insurance Vault is where users upload and store their insurance documents.

The MVP should support:

* Manual document upload.  
* Drag-and-drop upload on desktop.  
* Mobile upload from files.  
* Multiple document upload.  
* PDF upload as the priority format.  
* Other common document formats where practical.

Documents should be organised by policy type, not by insurer.

Example policy types include home, motor, business package, public liability, professional indemnity, cyber, travel, pet, life and health.

**8\. Email-to-Vault upload**

A key requirement is the ability for users to forward insurance emails into Hello David.

Each user should have a unique Hello David upload email address.

When a user forwards an email containing insurance documents, the system should:

* Receive the email.  
* Identify the user.  
* Extract supported attachments.  
* Upload those attachments into the user’s vault.  
* Process the documents through the extraction workflow.  
* Show the user when documents are ready.

The MVP should also consider whether users can upload a saved email file, such as .eml, if practical.

The system should handle emails with no attachments, unsupported files, duplicate documents and failed processing.

**9\. Document processing and AI extraction**

The MVP should keep document extraction focused and practical.

Hello David does not need to capture or structure the whole policy wording and schedules. The first version should extract the key policy administration details that help the customer understand what they have, when it renews, who it is with, what it costs and who to contact.

For each uploaded policy, the system should attempt to extract:

* Insurer.  
* Policy type.  
* Policy number.  
* Next Renewal date.  
* Annual premium.  
* Excess.  
* Insurer/Advisor contact phone number.

The system should not attempt to fully summarise every limit, exclusion, condition or coverage section as structured data in the MVP.

Where the user asks a specific question through Ask David, the system can search the uploaded document and point back to relevant wording.

If a field cannot be found, the system should show it as “not found” or “not clear from document” rather than guessing.

**10\. Policy summary cards**

For each processed policy, the user should see a simple policy card.

The card should show details as noted above in previous section.

The policy card should not try to display every policy limit, exclusion or condition. Those details can be explored through Ask David when the user has a specific question.

**11\. Ask David**

Ask David is the conversational layer.

The user should be able to ask plain-English questions about their uploaded insurance documents.

Example questions:

* What policies do I have?  
* When do my policies renew?  
* What excess applies?  
* Who do I contact about this policy?  
* Am I covered for flood?  
* What should I check before renewal?  
* What should I ask my broker?  
* What documents might I need for a claim?

Ask David should answer based on the user’s uploaded documents.

Answers should:

* Be written in plain English.  
* Avoid jargon.  
* Reference the relevant document or wording where possible.  
* Say when something is unclear.  
* Avoid final coverage decisions.  
* Recommend a sensible next step where needed.

**12\. Claude AI backend**

We are committed to using Claude as the core AI backend.

The developer should recommend the best way to implement Claude within the product architecture, including:

* Which Claude model should be used for document extraction.  
* Which Claude model should be used for Ask David responses.  
* Whether a lower-cost model can be used for simple classification or metadata extraction.  
* Whether a more advanced model should only be used for complex document reasoning.  
* How prompts, retrieval and document references should be structured.  
* How the system should avoid guessing when the answer is unclear.  
* How answers should point back to the uploaded document where possible.

The system should use Claude carefully and efficiently, rather than sending unnecessarily large documents into the model every time a user asks a question.

**16\. Recommended technology and costing request**

Please recommend the most practical technology stack for a production-ready MVP.

The preferred direction is:

* Mobile-first responsive web app.  
* Next.js / React front end, or recommended alternative.  
* Secure user authentication.  
* Secure document storage.  
* Postgres database, or recommended alternative.  
* Claude AI backend.  
* Document text extraction and OCR where required.  
* Email-to-vault ingestion.  
* Lightweight admin dashboard.  
* Hosting suitable for controlled real-user testing – we currently use Hostinger.

Please provide a costed proposal to take the existing prototype through to a production-ready MVP.

Please break the estimate into:

**Phase 1 — Prototype review and technical plan**

Review [www.hellodavid.com.au](http://www.hellodavid.com.au/), assess the current user journey, identify gaps, recommend architecture and confirm what is required to build the MVP.

**Phase 2 — Figma product design**

Build out the required Figma pages and finalise the MVP user journey before development.

**Phase 3 — Production-ready MVP build**

Build the working product with account creation, upload, email-to-vault, Claude-powered document extraction, policy cards, Ask David, Clarity Brief, expert handover and admin dashboard.

**Phase 4 — Testing, security and deployment**

Prepare the MVP for controlled real-user testing, including QA, security review, error handling, deployment and basic monitoring.

Please include:

* Recommended technology stack.  
* Estimated cost by phase.  
* Estimated timeline by phase.  
* Monthly running cost assumptions.  
* Claude / AI usage assumptions.  
* Document processing assumptions.  
* Email ingestion assumptions.  
* Third-party tools required.  
* Main technical risks.  
* Key build assumptions.  
* What could be simplified to reduce cost.  
* What would be excluded from the first MVP.

**17\. Out of scope for MVP**

The MVP does not need to include:

* Live insurance quotes.  
* Policy purchase.  
* Bind functionality.  
* Claims lodgement.  
* Broker marketplace.  
* Payment processing.  
* Full insurer integrations.  
* Full CRM integration.  
* Native mobile app.  
* Automated coverage decisions.  
* Regulated personal financial advice.  
* Full structured extraction of every limit, exclusion and condition.

